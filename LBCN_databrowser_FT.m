function []=LBCN_databrowser_FT(fname)

% Script to open the FieldTrip data browser.
% Input:
% - fname: name of the file to display. The file should be in SPM format 
%(.mat) or in EDF format (.edf)
% Output:
% Data browser with basic options. Further options can be specified in the
% GUI or in the 'cfg' variable.
%--------------------------------------------------------------------------
% Written by Jessica Schrouff, 10/21/2015, LBCN, Stanford University

% Gather inputs
%--------------------------------------------------------------------------
if nargin<1 || isempty(fname)
    fname = spm_select(1,[], 'Select file to display',{},pwd,{'.mat','.edf'});
end

[path,name,ext]=spm_fileparts(fname);

if strcmpi(ext,'.mat')
    try
        D = spm_eeg_load(fname);
        data = D.ftraw;
    catch
        error('LBCN_databrowser_FT:CannotLoadFile', ...
            'Could not load mat file as SPM MEEG object');
    end
elseif strcmpi(ext,'.edf')
    cfg.dataset = fname;
    data = ft_preprocessing(cfg);
else
    error('LBCN_databrowser_FT:UnrecognizedExtension',...
        'The file to display should be an EDF or SPM MEEG file');
end

% Display data
%--------------------------------------------------------------------------
cfg = struct;

cfg.viewmode = 'vertical';
ft_databrowser(cfg,data);