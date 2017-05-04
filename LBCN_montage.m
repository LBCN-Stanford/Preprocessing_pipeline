function d = LBCN_montage(files,option,montmat)

% Function to re-reference the data. This function first computes a montage
% matrix, that will then be applied to the data. 
% Inputs:
% files  : list of file names (optional)
% option : type of re-referencing.
%            - 'average': performs an average re-referencing using all
%            channels
%            - 'av_good': does the same as 'average' but uses only the good
%            channels (default option)
%            - 'custom': provide your own montage files
% montmat: name of .mat containing the selected montage for custom option.
% Outputs:
% re-referenced MEEG objects
%--------------------------------------------------------------------------
% Written by J. Schrouff, 07/27/2015, LBCN, Stanford. From SPM MEEG tools
% toolbox written by Rik Henson and Vladimir Litvak.

% Get inputs
% -------------------------------------------------------------------------
if nargin<1 || isempty(files)
    files = spm_select([1 Inf],'.mat', 'Select files to process',{},pwd,'.mat');
end

if nargin<2 || isempty(option)
    option = 'av_good'; % default to CAR with good channels only
elseif ~strcmpi(option,'average') || ~strcmpi(option,'av_good') || ...
        ~strcmpi(option,'custom')
    disp('Unknown option for re-referencing, please correct. Exiting.')
    return
end

if strcmpi(option, 'custom') 
    if nargin<3 || isempty(montmat)
        montmat = spm_select(1,'.mat', 'Select montage to apply',{},pwd,'.mat');
    else
        try
            load(montmat,'montage')
        catch
            disp('Could not load montage matrix, please correct.')
            return
        end
        if ~isstruct(montage)
            disp('Montage file not saved in proper format, please correct')
        end
    end
end
    

% Compute re-reference matrix
% -------------------------------------------------------------------------
d = cell(size(files,1),1);
for i = 1:size(files,1)
    % Load file
    D = spm_eeg_load(deblank(files(i,:)));
    % get number of channels and channel labels
    eegchan  = D.indchantype('EEG');
    goodchan = setdiff(eegchan, D.badchannels);
    if strcmpi(option,'av_good')
        refchan = goodchan;
    elseif strcmpi(option,'average')
        refchan = eegchan;
    end
    % Build or import matrix
    if strcmpi(option, 'av_good') || strcmpi(option, 'average')
        refind  = find(ismember(eegchan, refchan));
        goodind = find(ismember(eegchan, goodchan));
        badind  = find(ismember(eegchan, D.badchannels));

        tra                 = eye(length(eegchan));
        tra(goodind,refind) = tra(goodind,refind) - 1/length(refchan);
        tra(badind,refind)  = tra(badind,refind)  - 1/length(refchan);
        montage             = struct();
        montage.labelorg    = D.chanlabels(eegchan);
        montage.labelnew    = D.chanlabels(eegchan);
        montage.chantypeorg = lower(D.chantype(eegchan)');
        montage.chantypenew = lower(montage.chantypeorg);
        montage.chanunitorg = D.units(eegchan)';
        montage.chanunitnew = montage.chanunitorg;
        montage.tra = tra;
        paths = D.path;
        save([paths,filesep,'Montage.mat'],'montage')
        montage_name = [paths,filesep,'Montage.mat'];
    elseif strcmpi(option, 'custom')
        montage_name = montmat;
    end
    
    % Apply montage to data and create new dataset
    if i==1
        spm_jobman('initcfg')
        spm('defaults', 'EEG');
    end
    jobfile = {which('Montage_NKnew_SPM_job.m')};
    input_array{1} = {deblank(files(i,:))};
    input_array{2} = {deblank(montage_name)};
    [out] = spm_jobman('run', jobfile,input_array{:});
    d{i} = out{end}.D;
    
    % Rewrite the channels as EEG
    save(d{i});
end
    
    
    
    
    
    
    
    
    
    
    

