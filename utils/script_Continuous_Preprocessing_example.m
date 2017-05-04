
function [d] = script_Continuous_Preprocessing_example(filename,bch)

%% Part I: check inputs
if nargin<1 || isempty(filename)
    filename = spm_select(inf,'any','Select file to convert',{},pwd,'.mat');
end

if nargin<2 || isempty(bch)
    bch = [];
end

 %% Part II: filter and find bad channels common to 50% of all files
 tofilter = char(filename);
 filt = LBCN_filter_badchans(tofilter,[], bch,1,0.5);
 
 %% Part III: TF and rescale for each file (separately)

 % You can try paralell computing if you have multiple files to run:
 % uncomment these two line and coment the 'for'
%  try parpool('local',8); end
%  parfor i =1:numel(filt)

for i =1:numel(filt)
    fname = [filt{i}.path,filesep,filt{i}.fname];
    % Montage
    d = LBCN_montage(fname);
    fnameM = fullfile(d{1}.path,d{1}.fname);
    
    %Artifact detection in raw signal: jumps>100 muV and z-score diff>6
    d = batch_artefact_detect_continuous(fnameM);
    fnamea = fullfile(d{1}.path,d{1}.fname);
    
    
    %Baseline correction in raw signal
    D = LBCN_baseline_Timeseries(fnamea);
    fnameb = fullfile(D.path,D.fname);
    
    
    % Hilbert Time Frequency decomposition
    % each frequency band, without resolution bins
    freqs = [1 4 8 13 30 40 70; 3 7 12 29 39 69 170];
    D = LBCN_Time_frequency_Hilbert(fnameb,freqs);
    fnametf = fullfile(D.path,D.fname);
    
    % Baseline correction using Zscore
    D = LBCN_baseline_Timeseries(fnametf,[],'Zscore');
    fname1 = fullfile(D.path,D.fname);
     
    % Extract high gamma broadband
    % modify the [7 7] to extract another band, e.g.
   % d = batch_extract_HFB(fname1,[],[3 3],'Alpha');
    d = batch_extract_HFB(fname1,[],[7 7],'HFB');
    fnamehfb = fullfile(d{1}.path,d{1}.fname);
    
    
    %Artifact rejection in TF signal
%    Modify the job file by replacing 'reject' by 'mark' if running this
%    step on continuous files.
%     d = batch_artefact_detect_continuous_TF(fnamehfb);
%     fname1 = fullfile(d{1}.path,d{1}.fname);

     % Smooth results for visualization
    d = LBCN_smooth_data(fname1,smoothwin, twsmooth);

    
    
end

end