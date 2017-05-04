function [crit_p,h] = LBCN_FDRcorrect(pvalues)

% Function to compute FDR corrected p-values at 0.05 (default). It return
% crit_p, the threshold p-value and h, vector of the same size as pvalues
% containing 1s where the pvalue is over the adjusted threshold (i.e. the 
%null hypothesis has been rejected).

ps = sort(pvalues(:),'ascend');
m = length(ps); % number of tests
thresh = (1:m)*0.05/m;
wtd_p = m*ps'./(1:m);
rej = ps'<= thresh;
max_id = find(rej,1,'last');
if isempty(max_id)
    disp('No significant result')
    crit_p = 0;
    h = ps*0;
else
    crit_p = ps(max_id);
    h = pvalues(:)<=crit_p;
end