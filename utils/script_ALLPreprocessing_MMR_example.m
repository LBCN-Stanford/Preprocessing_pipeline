function script_ALLPreprocessing_MMR_example(filename,sodata,bch)

% Function to perform full pre-processing and univariate analysis for a
% specific block of edf data.
% Inputs:
% - filename: name of data file in SPM format (optional)
% - sodata  : name of behavioral data .mat (optional)
% - bch     : name of bad channel file (optional)
% -------------------------------------------------------------------------

% Get inputs
if nargin<1 || isempty(filename)
    filename = spm_select(1,'mat','Select file to convert',{},pwd,'.mat');
end

if nargin<2 || isempty(sodata)
    sodata = spm_select(1,'mat','Select behavioral data for file',{},pwd,'.mat');
end

if nargin<3 || isempty(bch)
    bch = spm_select(1,'mat','Select bad channels info for file',{},pwd,'.mat');
end
try
    load(bch)
catch
    bch = [];
end


%Set epoching, smoothing and RT rescaling parameters
fieldepoch = 'start';
twepoch = [-300 2200]; %Max of RTs as default
bc = 1;
bcfield = 'start';
twbc = [-150 0];
twResc = [-150 0];
smoothwin = 100;
twsmooth = [-150 2000];
RTbased = 1;
twsmoothRT = [-2000 150];
fieldepochRT = 'RTons';
twepochRT = [-2200 300];
task = 'MMR';
    

% Filter data and detect bad channels
fd = LBCN_filter_badchans(filename,[], bch,1,0.5);

fnamesmooth = cell(size(filename,1),1);
fnamesmoothRT = cell(size(filename,1),1);
for i = 1: numel(fd)
    fname = fullfile(fd{i}.path,fd{i}.fname);
    
    % Montage
    d = LBCN_montage(fname);
    fname = fullfile(d{1}.path,d{1}.fname);
    
    % Epoch data using event file
    D = LBCN_epoch_bc(fname,sodata,[],fieldepoch,twepoch,bc,bcfield,twbc); 
    fnameons = fullfile(D.path,D.fname);
    
    % Perform artifact rejection, TF
    [d,dtf] = batch_ArtefactRejection_TFrescale_AvgFreqRT(fnameons,[],[],twResc);
    fnameTFons = fullfile(dtf{1}.path,dtf{1}.fname);
    fnameHFBons = fullfile(d{1}.path,d{1}.fname);
    
    % Smooth results for visualization
    d = LBCN_smooth_data(fnameHFBons,smoothwin, twsmooth);
    fnamesmooth{i} = fullfile(d{1}.path,d{1}.fname);
    
    if RTbased
        % Epoch based on RT, correct based on onset
        D = LBCN_epoch_bc(fname,sodata,[],fieldepochRT,twepochRT,bc,bcfield,twbc,'RT');
        fnameons = fullfile(D.path,D.fname);
        
        % Perform artifact rejection, TF
        [d] = batch_ArtefactRejection_TFrescale_AvgFreqRT(fnameons,[],fnameTFons,twResc);
        fnameTFRT = fullfile(d{1}.path,d{1}.fname);       
        
        % Smooth results for visualization, RT based
        d = LBCN_smooth_data(fnameTFRT,smoothwin, twsmoothRT);
        fnamesmoothRT{i} = fullfile(d{1}.path,d{1}.fname);
    end
end
tomerge = char(fnamesmooth);

if size(tomerge,1)>1 %merge multiple files
    S.D = tomerge;
    S.recode = 'same';
    D = spm_eeg_merge(S);
    final = fullfile(D.path,D.fname);
else
    final = tomerge;
end 

%Do the same for RT based if requested
if RTbased
    tomerge = char(fnamesmoothRT);
    
    if size(tomerge,1)>1 %merge multiple files
        S.D = tomerge;
        S.recode = 'same';
        D = spm_eeg_merge(S);
        finalRT = fullfile(D.path,D.fname);
    else
        finalRT = tomerge;
    end
    % Plot the HFB for all conditions
    LBCN_plot_averaged_signal_epochsRT(final,finalRT,[],[],[],[], 1,task);
else
    % Plot the HFB for all conditions
    LBCN_plot_averaged_signal_epochs(final,[],[],[], 1,task);
end

% Perform simple univariate analysis: each condition versus baseline




