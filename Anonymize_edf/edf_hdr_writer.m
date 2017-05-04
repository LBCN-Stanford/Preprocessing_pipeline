function edf_hdr_writer(filename,edfhdr,option)
% edfhdr=edf_hdr_writer(filename,edfhdr,option)
%
% Writes the header to .edf (European Data Format) files. The file
% definition can be found here: http://www.edfplus.info/specs/edf.html.
%
% Inputs:   filename: full path and name of file to write.
%           edfhdr: structure containing the fields of the .edf header.
%           Please refer to the help for edf_hdr_reader for more
%           information.
%           option: 'orig' to write the fields from the orig substructure
%           of the edfhdr structure, 'mods' to write the fields from the
%           reformatted fields of edfhdr.
%
% NB always keep a backup copy of the file before overwriting its header.
%
% author of this script: pierre.megevand@gmail.com
% 2013/06/20

switch option
    case 'orig'
        % write from the original header fields
        fid=fopen(filename,'r+');
        fwrite(fid,edfhdr.orig.Version,'char');
        fwrite(fid,edfhdr.orig.PatientID,'char');
        fwrite(fid,edfhdr.orig.RecordID,'char');
        fwrite(fid,edfhdr.orig.StartDate,'char');
        fwrite(fid,edfhdr.orig.StartTime,'char');
        fwrite(fid,edfhdr.orig.HeaderLength,'char');
        fseek(fid,44,0);
        fwrite(fid,edfhdr.orig.NumDataRecords,'char');
        fwrite(fid,edfhdr.orig.DurDataRecord,'char');
        fwrite(fid,edfhdr.orig.NumSignals,'char');
        fwrite(fid,edfhdr.orig.Labels,'char');
        fwrite(fid,edfhdr.orig.TransducerType,'char');
        fwrite(fid,edfhdr.orig.PhysicalDim,'char');
        fwrite(fid,edfhdr.orig.PhysicalMin,'char');
        fwrite(fid,edfhdr.orig.PhysicalMax,'char');
        fwrite(fid,edfhdr.orig.DigitalMin,'char');
        fwrite(fid,edfhdr.orig.DigitalMax,'char');
        fwrite(fid,edfhdr.orig.PreFilt,'char');
        fwrite(fid,edfhdr.orig.NumSamples,'char');
        fseek(fid,32*edfhdr.NumSignals,0);
        fclose(fid);
        
    case 'mods'
        % write from (potentially modified) header fields
        fid=fopen(filename,'r+');
        fwrite(fid,edfhdr.orig.Version,'char');
        fwrite(fid,edfhdr.orig.PatientID,'char');
        fwrite(fid,edfhdr.orig.RecordID,'char');
        fwrite(fid,edfhdr.orig.StartDate,'char');
        fwrite(fid,edfhdr.orig.StartTime,'char');
        fwrite(fid,edfhdr.orig.HeaderLength,'char');
        fseek(fid,44,0);
        fwrite(fid,edfhdr.orig.NumDataRecords,'char');
        fwrite(fid,edfhdr.orig.DurDataRecord,'char');
        fwrite(fid,edfhdr.orig.NumSignals,'char');
        fwrite(fid,stringpad(edfhdr.Labels,16),'char');
        fwrite(fid,stringpad(edfhdr.TransducerType,80),'char');
        fwrite(fid,stringpad(edfhdr.PhysicalDim,8),'char');
        physmin=cellfun(@num2str,edfhdr.PhysicalMin,'UniformOutput',false);
        fwrite(fid,matrixpad(physmin,8),'char');
        physmax=cellfun(@num2str,edfhdr.PhysicalMax,'UniformOutput',false);
        fwrite(fid,matrixpad(physmax,8),'char');
        digimin=cellfun(@num2str,edfhdr.DigitalMin,'UniformOutput',false);
        fwrite(fid,matrixpad(digimin,8),'char');
        digimax=cellfun(@num2str,edfhdr.DigitalMax,'UniformOutput',false);
        fwrite(fid,matrixpad(digimax,8),'char');
        fwrite(fid,stringpad(edfhdr.PreFilt,80),'char');
        nsamples=cellfun(@num2str,edfhdr.NumSamples,'UniformOutput',false);
        fwrite(fid,matrixpad(nsamples,8),'char');
        fseek(fid,32*edfhdr.NumSignals,0);
        fclose(fid);
        
end

    function outputcellstring=stringpad(inputcellstring,padlen)
        outputcellstring=cell(edfhdr.NumSignals,1);
        for i=1:length(inputcellstring)
            len=numel(inputcellstring{i}{1});
            if len<padlen
                outputcellstring{i}=[inputcellstring{i}{1} blanks(padlen-len)];
            end
        end
        outputcellstring=[outputcellstring{:}]';
    end

    function outputcellstring=matrixpad(inputcellstring,padlen)
        outputcellstring=cell(edfhdr.NumSignals,1);
        for i=1:length(inputcellstring)
            len=numel(inputcellstring{i});
            if len<padlen
                outputcellstring{i}=[inputcellstring{i} blanks(padlen-len)];
            end
        end
        outputcellstring=[outputcellstring{:}]';
    end

end
