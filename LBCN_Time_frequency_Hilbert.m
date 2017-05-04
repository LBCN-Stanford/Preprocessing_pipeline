function Dnew = LBCN_Time_frequency_Hilbert(fname,freq, prefix)

% Perform Hilbert Time Frequency decomposition on time series in SPM MEEG
% format.
% Inputs:
% - fname: file name (.mat of SPM MEEG)
% - freq: matrix of frequencies to bandpass the signal in before taking the
%         Hilbert amplitude. Size: 2x number of frequency bins/bands.
% - prefix: string to prepend the filename with
% -------------------------------------------------------------------------
% Written by J. Schrouff, Laboratory of Behavioral and Cognitive
% Neuroscience, Stanford University.
% Last modified: March, 6th 2017


if nargin<1 || isempty(fname)
    fname = spm_select();
end
D = spm_eeg_load(fname);

if nargin<2 || isempty(freq)
    freq = [70; 170];
end

if nargin<3 || isempty(prefix)
    prefix = 'tf_';
end

%-Create a copy of the dataset
%--------------------------------------------------------------------------
Dnew = clone(D, [prefix D.fname],[size(D,1), size(freq,2), size(D,2), size(D,3)]);

% work on blocks of channels
% determine blocksize
% determine block size, dependent on memory
memsz  = spm('Memory');
datasz = nchannels(D)*nsamples(D)*8; % datapoints x 8 bytes per double value
blknum = ceil(datasz/memsz);
blksz  = ceil(nchannels(D)/blknum);
blknum = ceil(nchannels(D)/blksz);
fprintf(['Computing for block (out of %d):',repmat(' ',1,ceil(log10(blknum))),'%d'],blknum, 1);

for fi=1:size(freq,2)
    
    % now filter blocks of channels
    chncnt=1;
    for blk=1:blknum
        % Counter of channels to be updated
        if blk>1
            for idisp = 1:ceil(log10(blk)) % delete previous counter display
                fprintf('\b');
            end
            fprintf('%d',blk);
        end
        % load old meeg object blockwise into workspace
        blkchan=chncnt:(min(nchannels(D), chncnt+blksz-1));
        if isempty(blkchan), break, end
        tempdata=D(blkchan,:,1);
        chncnt=chncnt+blksz;
        
        %loop through channels
        for j = 1:numel(blkchan)
            % Band-pass filter for frequency of interest
            [temp] = ft_preproc_bandpassfilter(tempdata(j,:),D.fsample,[freq(1,fi) freq(2,fi)],[],'fir');
            % Perform Hilbert transform
            tempdata(j, :) = abs(hilbert(temp));
            
        end
        
        % write tempdata to Dnew
        Dnew(blkchan,fi,:,1)=reshape(tempdata,[length(blkchan),1,D.nsamples,1]);
        clear tempdata;
    end
end
fprintf('\n');
save(Dnew);