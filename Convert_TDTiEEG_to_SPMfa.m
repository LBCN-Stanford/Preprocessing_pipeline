function [D] = Convert_TDTiEEG_to_SPMfa(fsample,fchan,downsample,path_save,bch)

% -------------------------------------------------------------------------
% Function to convert TDT iEEG (raw ECoG data in .mat format) to an SPM MEEG
% file array, including events onsets and durations. The routine will load
% each channel and ask for the sampling rate and event file, before
% outputting the MEEG object. Optional downsampling.
% No pre-processing such as filtering is performed.
% inputs:
% - fsample: sampling rate, can be a number or one of those 3 options (in
%            string): 'TDT' (default: 1525.88Hz), 'oldNK' (default:1000Hz), 
%            'newNK'(default: 1000Hz after export)
% - fchan:   .mat file names corresponding to brain signal on each
%            electrode.
% - downsample: 1 to downsample (default is 0). The default
%               value (new sampling rate) for downsampling can be modified  
%               by opening the batch 'Downsample_NKnew_SPM_job.m'.
% - path_save: path where to save the dataset. Default: directory with the
%              electrode .mats
% - bch:     index of the bad channels (will not be included in the SPM 
%            object, optional, recommended: leave empty apart to discard 
%            empty channels at the end of the recording)
% output:
% - D:       SPM MEEG object D, also saved in a .mat and .dat on the drive,
%            downsampled (optional) and filtered.
%--------------------------------------------------------------------------
% Written by J. Schrouff, 10/17/2013, LBCN, Stanford University

% Get inputs
%--------------------------------------------------------------------------
% Load defaults if no input
def=get_defaults_Parvizi;

if nargin<1 || isempty(fsample)
    fsample = def.TDTfsample;
    fprintf('Using TDT sampling rate: %d \n', fsample)
elseif ~isnumeric(fsample)
    if strcmpi(fsample,'TDT')
        fsample = def.TDTfsample; %default to new files
    elseif strcmpi(fsample,'oldNK')
        fsample = def.oldNKfsample; %default to new files
    elseif strcmpi(fsample, 'newNK')
        fsample = def.newNKfsample; %default to new files
    end
end

% Fill in information from the channels
if nargin<2 || isempty(fchan)
    fchan = spm_select(inf,'mat','Select files for all channels');
end
if isempty(fchan)
    disp('Please select the channel mat files, exiting')
    return
end
[d1,fname] = fileparts(fchan(1,:));
fname = fname(1:end-3);

if nargin<3 || isempty(downsample)
    downsample = 0;
end
if nargin<4 || isempty(path_save)
    path_save = d1;
end
    
if nargin<5
    bch = [];
end
nchan = size(fchan,1);
D = [];

% Get channel names and indexes
%--------------------------------------------------------------------------
D.Fsample = fsample;

%Careful to the order the files are selected in, especially using the
%spm_selection if nchan>=100.

% Re-order the file names if number of channels >100
reord = zeros(nchan,1);
for i=1:nchan
    [dd,nfchan] = fileparts(fchan(i,:));
    % deal with channel numbers >100
    ind1 = str2double(nfchan(end-1:end));
    ind2 = str2double(nfchan(end-2:end));
    reord(i) = max([ind1,ind2]);
    [ina,ord] = sort(reord,'ascend');
end

%Exclude bad channels from import
ordchan = 1:nchan;
if ~isempty(bch)
    [tok,itk] = setdiff(ordchan,bch);
else
    itk = 1:nchan;
end
ord = ord(itk);
namchan = cell(length(ord),1);

for i=1:length(ord)
    namchan{i} = ['iEEG_',num2str(ina(itk(i)))];
end
fchan = fchan(ord,:);
nchan = length(ord);


% Initialize and fill the SPM data structure
%--------------------------------------------------------------------------
for i = 1:size(fchan,1)  % for  each channel
    try
        load(deblank(fchan(i,:)))       
    catch
        error('Could not load file')
    end
    if i==1 %create empty MEEG file with right number of samples and channels
        nsampl = size(wave,2);
        ntrials = size(wave,1);
        D.path = path_save;
        D.data.fnamedat = ['spm8_',fname,'.dat'];
        D.data.datatype = 'float32-le';
        D.fname = ['spm8_',fname,'.mat'];
        D.Nsamples = nsampl;
        datafile = file_array(fullfile(D.path, D.data.fnamedat), [nchan nsampl ntrials], 'float32-le');
        % physically initialise file
        datafile(end,end,:) = 0;
        spm_progress_bar('Init', size(fchan,1), 'reading and converting'); drawnow;
        if size(fchan,1) > 100
            Ibar = floor(linspace(1, size(fchan,1),100));
        else
            Ibar = 1:size(fchan,1);
        end
    end
    datafile(i,:,:) = reshape(wave,[1,nsampl]);                       %fill MEEG with data
    if ismember(i, Ibar)
        spm_progress_bar('Set', i);
    end
end

%Deal with channel information
D.channels = struct('bad',repmat({0}, 1, length(ord)),...
    'type', repmat({'EEG'}, 1, length(ord)),...
    'label', namchan');

% Create empty event field and transform into SPM MEEG object
if size(wave,1) == 1
    evtspm=[];
    D.trials.label = 'Undefined';
    D.trials.events = evtspm;
    D.trials.onset = 1/D.Fsample;
else
    evtspm = [];
    D.trials.label = 'Undefined';
    D.trials.events = evtspm;
    D.trials.onset = 1/D.Fsample;
end
%Create and save MEEG object
D = meeg(D);
D = link(D,fnamedat(D));
save(D);

% Downsample and filter the data using the batch system
%--------------------------------------------------------------------------
if downsample
    jobfile = {which('Downsample_NKnew_SPM_job.m')};
    spm_jobman('initcfg')
    spm('defaults', 'EEG');
    namef = fullfile(path_save,D.fname);
    [out]=spm_jobman('run', jobfile, {namef});
    D = out{1}.D;
end


    



