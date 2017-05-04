function LBCN_databrowser_FASST(fname,indchan)
% Function to display ECoG data using the FASST (http://www.montefiore.
%ulg.ac.be/~phillips/FASST.html) toolbox. It will display all channels and
%all time points.
% Inputs:
% - fname: name of file to display, in SPM format
% - indchan: indexes of specific channels to display (optional)
% Outputs:
% Display (interactive) of the dataset
%--------------------------------------------------------------------------
% Written by J. Schrouff, 10/26/2015, LBCN Stanford University

% Gather inputs
if nargin <1 || isempty(fname)
    fname = spm_select(1,'any','Select file to display',{},pwd);
end

D = crc_eeg_load(fname);

if nargin <2 || isempty(indchan)
    indchan = indchantype(D,'EEG');
elseif ~isempty(indchan) && iscell(indchan) % if channel names provided instead of indexes
    indchan = indchannel(D,indchan);
end

if isempty(indchan)
    indchan = 1:nchannels(D);
end


% Display using FASST
varargin.file = {D.fname};
varargin.index = indchan;
varargin.Dmeg{1} = D;

crc_dis_main(varargin)