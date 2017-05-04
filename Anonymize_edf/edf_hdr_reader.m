function edfhdr=edf_hdr_reader(filename)
% edfhdr=edf_hdr_reader(filename)
%
% Opens and reads the header to .edf (European Data Format) files. The file
% definition can be found here: http://www.edfplus.info/specs/edf.html.
%
% Inputs:   filename: full path and name of file to open.
%
% Outputs:  edfhdr: structure containing the fields of the .edf header. The
% orig substructure contains the original fields as written in the header;
% the other fields of the structure have been reformatted for ease of use.
% NB the SamplingRate field is not included in the .edf header, but rather
% computed using the NumSamples and DurDataRecord fields.
%
% author of this script: pierre.megevand@gmail.com
% 2013/06/20

%% open file
fid=fopen(filename,'r');

%% read in header
edfhdr.orig.Version=fread(fid,8,'char=>char');
edfhdr.orig.PatientID=fread(fid,80,'char=>char');
edfhdr.orig.RecordID=fread(fid,80,'char=>char');
edfhdr.orig.StartDate=fread(fid,8,'char=>char');
edfhdr.orig.StartTime=fread(fid,8,'char=>char');
edfhdr.orig.HeaderLength=fread(fid,8,'char=>char');
edfhdr.HeaderLength=str2double(edfhdr.orig.HeaderLength'); % this conversion is performed here since that number is used for further fields
fseek(fid,44,0);
edfhdr.orig.NumDataRecords=fread(fid,8,'char=>char');
edfhdr.orig.DurDataRecord=fread(fid,8,'char=>char');
edfhdr.orig.NumSignals=fread(fid,4,'char=>char');
edfhdr.NumSignals=str2double(edfhdr.orig.NumSignals); % this conversion is performed here since that number is used for further fields
edfhdr.orig.Labels=fread(fid,16*edfhdr.NumSignals,'char=>char');
edfhdr.orig.TransducerType=fread(fid,80*edfhdr.NumSignals,'char=>char');
edfhdr.orig.PhysicalDim=fread(fid,8*edfhdr.NumSignals,'char=>char');
edfhdr.orig.PhysicalMin=fread(fid,8*edfhdr.NumSignals,'char=>char');
edfhdr.orig.PhysicalMax=fread(fid,8*edfhdr.NumSignals,'char=>char');
edfhdr.orig.DigitalMin=fread(fid,8*edfhdr.NumSignals,'char=>char');
edfhdr.orig.DigitalMax=fread(fid,8*edfhdr.NumSignals,'char=>char');
edfhdr.orig.PreFilt=fread(fid,80*edfhdr.NumSignals,'char=>char');
edfhdr.orig.NumSamples=fread(fid,8*edfhdr.NumSignals,'char=>char');
fseek(fid,32*edfhdr.NumSignals,0);

%% check whether end of header correctly reached
if edfhdr.HeaderLength~=ftell(fid)
    fclose(fid);
    error('I should have reached the end of the header, but my position does not match with stated header length !');
end
fclose(fid);

%% do some conversions
edfhdr.NumDataRecords=str2double(edfhdr.orig.NumDataRecords');
edfhdr.DurDataRecord=str2double(edfhdr.orig.DurDataRecord');
edfhdr.Labels=stringunpad(edfhdr.orig.Labels,16);
edfhdr.TransducerType=stringunpad(edfhdr.orig.TransducerType,80);
edfhdr.PhysicalDim=stringunpad(edfhdr.orig.PhysicalDim,8);
edfhdr.PhysicalMin=matrixunpad(edfhdr.orig.PhysicalMin,8);
edfhdr.PhysicalMax=matrixunpad(edfhdr.orig.PhysicalMax,8);
edfhdr.DigitalMin=matrixunpad(edfhdr.orig.DigitalMin,8);
edfhdr.DigitalMax=matrixunpad(edfhdr.orig.DigitalMax,8);
edfhdr.PreFilt=stringunpad(edfhdr.orig.PreFilt,80);
edfhdr.NumSamples=matrixunpad(edfhdr.orig.NumSamples,8);

%% sampling rate not included in EDF header, included for your convenience!
durrecceltmp=cell(size(edfhdr.NumSamples));
durrecceltmp(:)=num2cell(edfhdr.DurDataRecord);
edfhdr.SamplingRate=cellfun(@rdivide,edfhdr.NumSamples,durrecceltmp);
clear durrecceltmp;

%% subfunctions
    function cellarray=stringunpad(string,padlen)
        cellarray=cell(edfhdr.NumSignals,1);
        for i=1:edfhdr.NumSignals
            j=padlen*(i-1)+1;
            cellarray{i}=cellstr(string(j:j+padlen-1)');
        end
    end

    function cellarray=matrixunpad(string,padlen)
        cellarray=cell(edfhdr.NumSignals,1);
        for i=1:edfhdr.NumSignals
            j=padlen*(i-1)+1;
            cellarray{i}=str2double(string(j:j+padlen-1)');
        end
    end

end
