function [D,Ddiod] = LBCN_convert_NKnew(fname, path_save,downsample,exclude)
% Function to convert NK data from edf to SPM format. 
% Inputs:
% - fname: name of file to convert. if empty, a selection window opens.
% - path_save: path to save the new file. if empty, same path as file.
% - downsample: 1 to downsample data (brain signal only) to a default value
% - exclude: indices or labels of channels to exclude from conversion
% (typically 1kHz) as specified in the batch job.
% It creates a downsampled version of the signal, in SPM
% .dat and .mat format. Additionally, it creates a separate file for the
% microphone and another for the diod, which is not downsampled.
% Multiple files can be selected, the code will generate sub-directories
% for each 'block'.
% All parameters can be modified by opening (GUI) the corresponding batches:
% conversion: 'Convert_NKnew_to_SPMfa_job.m'
% downsample: 'Downsample_NKnew_SPM_job.m'
%--------------------------------------------------------------------------
%Written by J. Schrouff, LBCN, Stanford, 07/21/2015

% Add SPM paths if needed
% -------------------------------------------------------------------------
% Add SPM's directories: matlabbatch
if ~exist('cfg_util','file')
    addpath(fullfile(spm('Dir'),'matlabbatch'));
end
% - SPM FieldTrip for MEEG
if ~exist('ft_struct2double','file')
    addpath(fullfile(spm('Dir'),'external','fieldtrip'));
    clear ft_defaults
    clear global ft_default
    ft_defaults;
    global ft_default
    ft_default.trackcallinfo = 'no';
    ft_default.showcallinfo = 'no';
end

% Inputs
% -------------------------------------------------------------------------
if nargin<1 || isempty(fname)
    fname = spm_select(inf,'any','Select file to convert',{},pwd,'.edf');
end

if nargin<3 || isempty(downsample)
    downsample = 0;
end

if nargin<4 || isempty(exclude)
    all = 1;
else
    all = 0;
end
    

% For each file
for id = 1:size(fname,1)
    
    
    if nargin<2 || isempty(path_save)
        path_save = spm_fileparts(deblank(fname(id,:)));
    end
    
    % Step 1: Anonymize edf files
    %--------------------------------------------------------------------------
    
    edfhdr=edf_hdr_reader(fname(id,:));
    % PatientID
    try
        [patID_last,patID_first]=strtok(edfhdr.orig.PatientID',',');
        if ~isempty(patID_first)
            patID_first=strtrim(patID_first(2:end));
            edfhdr.orig.PatientID=[patID_first(1:2) patID_last(1:2) blanks(76)]';
        elseif strfind(patID_last, 'No_Name')
            edfhdr.orig.PatientID=['Patient' blanks(73)]';
        else
            edfhdr.orig.PatientID=[patID_last(1:2) blanks(78)]';
        end
    catch
        error('Something went wrong when attempting to anonymize Patient ID. Exiting here.');
    end
    % RecordID
    try
        edfhdr.orig.RecordID=blanks(80);
    catch
        error('Something went wrong when attempting to anonymize Record ID. Exiting here.');
    end
    edf_hdr_writer(fname(id,:),edfhdr,'orig');
    
    % Step 2: Convert data from edf to SPM format
    %--------------------------------------------------------------------------
    
    % Get which channels are ECoG/EEG, which is diod, which is mike
    list= edfhdr.Labels;
    eeglab = {};
    idc=[];
    ielec=[];
    labelecog = {};
    labeldc = {};
    % Get the channel labels
    for i =1:length(list)
        nel = char(list{i});
        if strfind(nel,'DC') % All DC channels in one file
            idc=[idc,i];
            labeldc = [labeldc,list{i}];
        else
            poli = strfind(nel,'POL');
            itk = setdiff(1:length(nel),poli:poli+3);
            ref = strfind(nel,'-Ref');
            itr = setdiff(1:length(nel),ref:ref+3);
            elecnam = deblank(nel(intersect(itk,itr)));
            eeglab = [eeglab,{elecnam}];
            ielec=[ielec;i];
            labelecog = [labelecog,list{i}];
        end
    end
    
    %Exclude channels from conversion if needed
    if ~all
        if iscell(exclude)
            tokeep = find(~ismember(eeglab,exclude));
            eeglab = eeglab(tokeep);
            ielec = ielec(tokeep);
            labelecog = labelecog(tokeep);
        else
            itk = 1:length(labelecog);
            itk = itk(~ismember(itk,exclude));
            labelecog = labelecog(itk);
            eeglab = eeglab(itk);
            ielec = ielec(itk);
        end
    end
    
    % Check that all channels have different labels
%      labs = [labeldc,labelecog];
%      [slab,ilab,iun] = unique(labs);
%      if numel(slab) ~= numel(labs)
%          disp('Some channels have the same labels, correcting')
%          findrepet = diff(iun);
%          numrepet = find(findrepet==0);
%          for i  = 1:length(numrepet)
%              labrepet = slab(iun(numrepet(i)));
%              indrepet = indchannel(Dw, labrepet);
%              repnewlab = find(ismember(ielec,indrepet(2)));
%              nel = char(labrepet);
%              poli = strfind(nel,eeglab{repnewlab});
%              itreplace = poli:poli+length(eeglab{repnewlab})-1;
%              itk = setdiff(1:length(nel),itreplace);
%              newlab = [nel(itk(itk<poli)),eeglab{repnewlab},'1', ...
%                  nel(itk(itk>max(itreplace)))];
%              eeglab{repnewlab} = [eeglab{repnewlab},'1'];
%              Dw = chanlabels(Dw,indrepet(2),newlab);
%          end
%      end
    
    if size(fname,1)>1
        % Create subdirectory for each file
        mkdir(path_save,['Block_', num2str(id)])
        path_block = [path_save,filesep,['Block_', num2str(id)]];
    else
        path_block = path_save;
    end
    
    [p,namefile] = spm_fileparts(deblank(fname(id,:)));
    % Create ECoG file
     prefix = 'ECoG_';
     crc_eeg_rdata_edf(deblank(fname(id,:)),labelecog,prefix,path_block);
     fn_mat = fullfile(path_block,[prefix,namefile,'.mat']);
     D = spm_eeg_load(fn_mat);
     D = chantype(D,1:length(ielec),'EEG');
     D = chanlabels(D,1:length(ielec),eeglab);
     save(D);
    
    % Create diod file
    Ddiod=[];
    if ~isempty(idc)
        prefix = 'DCchans_';
        crc_eeg_rdata_edf(deblank(fname(id,:)),labeldc,prefix,path_block);
        fn_mat = fullfile(path_block,[prefix,namefile,'.mat']);
        Ddiod = spm_eeg_load(fn_mat);
        Ddiod = chantype(Ddiod,1:length(idc),'Other');
        Ddiod = chanlabels(Ddiod,1:length(idc),labeldc);
        save(Ddiod);
    end
    
    
    % Step 3: Downsample ECoG data to 1000Hz
    %----------------------------------------------------------------------
    if downsample && D.fsample>1000*1.03
        spm_jobman('initcfg')
        spm('defaults', 'EEG');
        jobfile = {which('Downsample_NKnew_SPM_job.m')};
        namef = fullfile(path_block,D.fname);
        [out]=spm_jobman('run', jobfile, {deblank(namef)});
        D = out{1}.D;
    end
end




