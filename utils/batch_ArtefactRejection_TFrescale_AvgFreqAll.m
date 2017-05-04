% List of open inputs
% Artefact detection: File Name - cfg_files
% Time-frequency rescale: Baseline time window - cfg_entry
nrun = X; % enter the number of runs here
jobfile = {'C:\Users\parvizilab\Codes\codes\Preprocessing-pipeline\utils\batch_ArtefactRejection_TFrescale_AvgFreqAll_job.m'};
jobs = repmat(jobfile, 1, nrun);
inputs = cell(2, nrun);
for crun = 1:nrun
    inputs{1, crun} = MATLAB_CODE_TO_FILL_INPUT; % Artefact detection: File Name - cfg_files
    inputs{2, crun} = MATLAB_CODE_TO_FILL_INPUT; % Time-frequency rescale: Baseline time window - cfg_entry
end
spm('defaults', 'EEG');
spm_jobman('run', jobs, inputs{:});
