function d = LBCN_filter_badchans(files,chanfile, bch, filter,conserv)

% This function first filters the channels for line noise + two harmonics
% using the batch 'Filter_NKnew_SPM_job.m'. It then takes the channel file
% to identify pathological channels and empty/flat electrodes. It is also
% possible manually specify which channels are bad, using their indexes 
%(typically for old NK or TDT systems). An automatic detection is then run
%for the provided sessions, based on the mean and std of the signal and on
%the detection of spikes. Important note: the resulting bad channels will
%be the union of the bad channels detected in the provided files!
% Inputs:
% files    : file names (optional)
% chanfile : name of the .mat containing channel information (can be empty)
% bch      : vector with indexes of bad channels or labels of bad channels
% filter   : flag to filter the data or not (default = 1)
% conserv  : 0 to be conservative and exclude the union of all bad
%           channels, a number between 1/n_files and 1 to exclude bad 
%           channels common to x% files (e.g. 0.5 for channels common to at 
%           least 50% of the files).
% Output:
% D        : MEEG object, filtered with bad channels marked as 'bad'.
%--------------------------------------------------------------------------
% Written by J. Schrouff and S. Bickel, 07/27/2015, LBCN, Stanford

% Check inputs
% -------------------------------------------------------------------------
if nargin<1 || isempty(files)
    files = spm_select([1 Inf],'.mat', 'Select files to process',{},pwd,'.mat');
end

if nargin<2 || isempty(chanfile)
    bchfile = [];
else
    try
        load(chanfile);
        bchfile = [];
        for i  = 1:size(elecs,1) % To modify according to final .mat form and variables
            if elecs{i,3}
                bchfile = [bchfile; i];
            end
        end
    catch
        error('Could not load the channel information file, please correct')
    end
end

if nargin<3 || isempty(bch)
    bch = [];
end

if nargin <4 || isempty(filter)
    filter = 1;
end

if nargin<5 || isempty(conserv)
    conserv = 0;
end

def = get_defaults_Parvizi;

% Step 1: Filter the data using the batch
% -------------------------------------------------------------------------
d = cell(size(files,1),1);
for i = 1:size(files,1)
    if filter
        if i==1
            spm_jobman('initcfg')
            spm('defaults', 'EEG');
        end
        jobfile = {which('Filter_NKnew_SPM_job.m')};
        [out] = spm_jobman('run', jobfile,{deblank(files(i,:))});
        d{i} = out{end}.D;
    else
        d{i} = spm_eeg_load(deblank(files(i,:)));
    end
end

% Step 2: Bad channels
% -------------------------------------------------------------------------
varmult = def.varmult;
stdmult = def.stdmult;
ibadchans = cell(length(d),1);

for i = 1:length(d)
    % Step 2.1: Set bad channels based on clinical recordings
    % ---------------------------------------------------------------------
    % reset all bad channels to good before detection
    d{i} = badchannels(d{i},1:nchannels(d{i}),zeros(nchannels(d{i}),1));
    if ~isempty(bch) && iscell(bch) % if channel names provided instead of indexes
        bchn = indchannel(d{i},bch);
    else
        bchn = bch;
    end
    bchfile2 = union(bchfile,bchn);
    goodchans = setdiff(1:nchannels(d{i}), bchfile2);
    
    % Step 2.2: Automatic detection of bad channels based on signal
    % variance
    % ---------------------------------------------------------------------
    vch = var(d{i}(goodchans,:),0,2); % only look at the non-pathological channels
    b = find(vch>(varmult*median(vch)));
    g = find(vch<median(vch)/varmult);
    addb = setdiff(b,g);
    if ~isempty(addb)
        disp(['Bad channels for file ', num2str(i),':', num2str(goodchans(addb))])
    else
        disp(['No bad channels for file ', num2str(i)])
    end
    ibadchans{i} = chanlabels(d{i},goodchans(addb)); 
    
    % Step 2.3: Automatic detection of bad channels based on signal spikes
    % ---------------------------------------------------------------------
%     std_chan = std(diff(d{i}(goodchans,:),1,2),0,2);
%     std_dat = mean(std_chan);
    nr_jumps = zeros(length(goodchans),1);
    for j=1:length(goodchans)
        nr_jumps(j) = length(find(abs(diff(d{i}(goodchans(j),:),1,2))>100)); 
%         nr_jumps(j) = length(find(abs(diff(d{i}(goodchans(j),:),1,2))>stdmult*std_dat)); 
    end
    jch = find(nr_jumps>stdmult*median(nr_jumps));
%     jch = find(nr_jumps>0.25*size(d{i}(goodchans(1),:),2));
    if ~isempty(jch)
        addjch = goodchans(jch);
        disp(['Spiky channels for file ', num2str(i),':', num2str(addjch)])
        ibadchans{i} = union(ibadchans{i},chanlabels(d{i},addjch)); 
    else
        disp(['No spiky channels for file ', num2str(i)])
    end    
end

nlistbad = {};
countbad = [];
for i= 1:numel(ibadchans)
    nbad = find(ismember(nlistbad,ibadchans{i}));
    if ~isempty(nbad)
        countbad(nbad) = countbad(nbad)+1;
    end
    nbadfile = ~ismember(ibadchans{i},nlistbad);
    if ~isempty(find(nbadfile))
        newbad = reshape(ibadchans{i}(find(nbadfile)),[1 numel(find(nbadfile))]);
        nlistbad = [nlistbad,newbad];
        countbad = [countbad;ones(length(find(nbadfile)),1)];
    end
end
    
if ~conserv
    totbad = union(chanlabels(d{end},bchfile2),nlistbad);
elseif conserv>0
    totbad = nlistbad(find(floor(countbad/(conserv*length(ibadchans)))));
    totbad = union(chanlabels(d{end},bchfile2),totbad);
end

% Save the bad channels into the SPM header
for i= 1:length(d)    
    ibchf = indchannel(d{i},totbad);
    d{i} = badchannels(d{i},ibchf,ones(length(ibchf),1));
    save(d{i});
    totbad = reshape(totbad,1,numel(totbad));
    if i==1
        disp(['Bad channels for all files: '])
        chanlabels(d{i},badchannels(d{i}))
    end
end


