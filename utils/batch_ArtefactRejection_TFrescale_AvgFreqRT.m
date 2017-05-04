function [d,dtf] = batch_ArtefactRejection_TFrescale_AvgFreqRT(fname,script,namebc,twbc)

% Function to perform multiple pre-processing operations such as artefact
% rejection, time frequency decomposition, and averaging within a frequency
% band using SPM batch tools. The options within the batch should be
% modified depending on the question to investigate.
% Defaults:
% - Artefact rejection: jumps of 100muV excluded. Bad channel threshold set
%                    to 0.5 to make sure no other bad channels are excluded
% - Remove bad trials: Take bad trials out of file
% - Time-Frequency decomposition: Morlet wavelets, frequencies of interest
%                                 comprised between 1 and 170 Hz. Does not
%                                 save the phase by default.
% - Rescale TF: uses the log of power in a baseline (should be smaller than 
%               actual baseline to discard edge effects) to scale the power
%               of the signal in each frequency bin.
% - Average over frequency: average in band of frequency (e.g. 70 to 170Hz)
%                           and modifies prefix to the name of frequency 
%                           band (e.g. High Gamma)
% Inputs:
% - fname  : name of file(s) to process (SPM format)
% - script : name of batch script to call
% - namebc : name of file for baseline correction (should have the same 
%            dimensions and number of events as in fname)
% - twbc   : time window for baseline correction (LogR rescaling)
% Output:
% - d      : cell array with final MEEG objects
%--------------------------------------------------------------------------
% Written by J. Schrouff, LBCN, Stanford, 10/28/2015

% Get inputs
% -------------------------------------------------------------------------
if nargin<1 || isempty(fname)
    fname = spm_select([1 Inf],'.mat', 'Select files to process',{},pwd,'.mat');
end

if nargin<2 || isempty(script)
    jobfile = {which('batch_ArtefactRejection_TFrescale_AvgFreqAll_job.m')};
else
    jobfile = script;
end

if nargin<3 || isempty(namebc)
    [path,name,ext] = spm_fileparts(fname);
    namebc = ['tf_a',name];
    namebc = fullfile(path,[namebc,ext]);
end

if nargin<4 || isempty(twbc)
    twbc = [-100 0];
end

% Perform pre-processing
% -------------------------------------------------------------------------
d = cell(size(fname,1),1);
for i = 1:size(fname,1)
    if i==1
        spm_jobman('initcfg')
        spm('defaults', 'EEG');
    end
    input_array{1} = {deblank(fname(i,:))};
    input_array{2} = twbc;
    input_array{3} = {deblank(namebc(i,:))};   
    [out] = spm_jobman('run', jobfile,input_array{:});
    d{i} = out{end}.D;
    dtf{i} = out{2}.Dtf;
end
