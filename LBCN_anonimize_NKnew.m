
function LBCN_anonimize_NKnew(fname)
% Function to anonimize edf file. It takes as inputs
% the name of the file (optional).
%--------------------------------------------------------------------------
%Written by J. Schrouff, LBCN, Stanford, 07/21/2015


% Inputs
if nargin<1 || isempty(fname)
    fname = spm_select(inf,'any','Select file to convert');
end


% For each file
for id = 1:size(fname,1)
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
end




