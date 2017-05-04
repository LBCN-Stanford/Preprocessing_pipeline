function [res] = LBCN_Univariate_Condition_Baseline(fname,cond,twcond,twbas,ichan,nperm,suffix,tail)

% Function to perform univariate paired of trial (de-)activation compared
% to baseline, in a specific condition.
% Inputs:
% - fname: File name
% - cond: condition name, in character
% - twcond: time window to select for the condition (in ms)
% - twbas: time window to select for the baseline (in ms)
% - ichan: channels (names in a cell, indexes or 'good') to perform the test on
% - nperm: number of permutations (default: 10,000)
% - suffix: to append to name of saved results file (default: [])
% - tail: if tail is 1, testing for cond>baseline, otherwise testing for
% cond ~= baseline.
% -------------------------------------------------------------------------
% Written by J. Schrouff, LBCN, Stanford University, 12/10/2015

% Get inputs
if nargin<1 || isempty(fname)
    fname = spm_select(1,'mat','Select MEEG object');
end

D = spm_eeg_load(fname);

if ~iscell(cond)
    conds{1} = cond;
else
    conds = cond;
end
icond = setdiff(indtrial(D,conds),badtrials(D));

if isempty(icond)
    disp('Please provide valid condition name')
    return
end

itpcond = indsample(D,twcond/1000);
itpbas = indsample(D,twbas/1000);

if isempty(itpcond)
    disp('Please provide valid time window for condition (in ms)')
    return
end

if isempty(itpbas)
    disp('Please provide valid time window for baseline (in ms)')
    return
end

if nargin<5 || isempty(ichan)
    ichan = 1:D.nchannels;
elseif iscell(ichan)
    ichan = indchannel(D,ichan);
elseif strcmpi(ichan,'good')
    ichan = indchantype(D,'All','good');
end

if nargin<6 || isempty(nperm)
    nperm = 10000;
end

if nargin<7 || isempty(suffix)
    suffix = char(conds{1});
end

if nargin<8 || isempty(tail)
    tail = 0;
end

permutation = zeros(numel(icond),nperm);
pchan_CondBas = zeros(length(ichan),1);
pchan_WSR = zeros(numel(ichan),1);

% Compute permutations for each channel (same permutations)
fprintf(['Computing for channel (out of %d):',repmat(' ',1,ceil(log10(nchannels(D)))),'%d'],length(ichan), 1);

if length(size(D))==4
    ifreq = 1;
    flagf = 1;
else
    flagf = 0;
end

for i = 1:length(ichan)
    % Counter of channels to be updated
    if i>1
        for idisp = 1:ceil(log10(i)) % delete previous counter display
            fprintf('\b');
        end
        fprintf('%d',i);
    end
    if flagf
        conddata = mean(squeeze(D(ichan(i),ifreq,itpcond(1):itpcond(2),icond)));
        baseline = mean(squeeze(D(ichan(i),ifreq,itpbas(1):itpbas(2),icond)));
    else
        conddata = mean(squeeze(D(ichan(i),itpcond(1):itpcond(2),icond)));
        baseline = mean(squeeze(D(ichan(i),itpbas(1):itpbas(2),icond)));
    end
    if tail
        truediff = (mean(conddata - baseline));
    else
        truediff = abs(mean(conddata - baseline));
    end
    pchan_WSR(i) = signrank(conddata-baseline);
    
    perm = zeros(numel(conddata),nperm);
    permdiff = zeros(nperm,1);
    
    for p = 1:nperm
        if i == 1
            % Need to set the permutation matrix
            indperm = rand(numel(conddata),1);
            permutation(:,p) = indperm;
        end
        perm(:,p) =  permutation(:,p);       
        diff = conddata - baseline;
        multp = ones(numel(conddata),1);
        multp(perm(:,p)>0.5) = -1;
        diffp = diff' .* multp;
        if tail
            permdiff(p) = (mean(diffp));
        else
            permdiff(p) = abs(mean(diffp));
        end
    end
    permdiff = [permdiff;truediff];
    pchan_CondBas(i) = length(find(permdiff>=truediff))/(nperm + 1);
end
fprintf('\n');

% Correct for multiple comparisons using FDR
[crit_pCondBas,hCondBas] = LBCN_FDRcorrect(pchan_CondBas);

% Save results
sign_chans = chanlabels(D,ichan(find(hCondBas)));
path = spm_fileparts(fname);
res.sign_chans = sign_chans;
res.pchan_Cond = pchan_CondBas;
res.pchan_WSR = pchan_WSR;
res.hCond = hCondBas;
res.crit_pCond = crit_pCondBas;
res.ichan = ichan;
save([path,filesep,'Results_Univariate_ResponsiveChannels_',suffix,'.mat'],'res')

