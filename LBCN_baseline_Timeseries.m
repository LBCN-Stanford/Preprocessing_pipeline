function D = LBCN_baseline_Timeseries(fname,prefix,method,time_win,fnamebase)

% Performs baseline correction on a whole time series based on its average
% or on a specific time window.
% Inputs:
% fname   :   Name of file to baseline correct
% prefix  :   Prefix for output file (default: 'b')
% method  :   Method for baseline correction (default: 'average')
% time_win:   Time window for baseline correction, in ms (default: whole file)
% fnamebase:  Additional file to use as baseline
%--------------------------------------------------------------------------
% Written by J. Schrouff, LBCN, Stanford University, 08/22/2016

if nargin <1 || isempty(fname)
    fname = spm_select();
end
if ischar(fname)
    D = spm_eeg_load(fname);
elseif iscell(fname)
    D = spm_eeg_load(fname{1});
else
    D = fname;
end
sD = size(D);

if nargin <2 || isempty(prefix)
    prefix = 'b';
end

if nargin <3 || isempty(method)
    method = 'average';
end

if nargin>=5 && ~isempty(fnamebase)
    try
        Dbase = spm_eeg_load(fnamebase);
    end
    if ntrials(D) ~= ntrials(Dbase)
        disp('Number of trials in both files should match')
        return
    end
else
    Dbase = D;
end

if nargin <4 || isempty(time_win)
    t(1) = 1;
    t(2) = nsamples(Dbase);
else
    t(1) = indsample(Dbase,time_win(1)/1000);
    t(2) = indsample(Dbase,time_win(2)/1000);
end

%-Create a copy of the dataset
%--------------------------------------------------------------------------
Dnew = copy(D, [prefix D.fname]);

%-For each channel, remove the specified baseline
%--------------------------------------------------------------------------

% Exclude artefacts
ev = D.events;
badsamp = [];
tim = D.time;
fprintf(['Computing for channel (out of %d):',repmat(' ',1,ceil(log10(D.nchannels))),'%d'],nchannels(D), 1);
for i = 1:nchannels(D)
    %Get baseline time window for trial
    if ntrials(Dbase) ==1 %Continuous data file
        % For that channel, get bad events and take them away from the
        % baseline
        for iev = 1:length(ev)
            if ~isempty(strfind(ev(iev).type,'artefact')) && strcmpi(ev(iev).value,chanlabels(D,i))
                t_art(1) = indsample(D,max(ev(iev).time-ev(iev).duration,min(tim))); % Getting excision window
                t_art(2) = indsample(D,min(ev(iev).time+ev(iev).duration,max(tim)));
                badsamp = [badsamp,t_art(1):t_art(2)];
            end
        end
        tw = t(1):t(2);
        gs = ~ismember(tw,badsamp);
        tw = tw(gs);
    else
        tw = t(1):t(2);
    end
    if isempty(tw)
        tw = t(1):t(2);
        fprintf('\n Channel %s had only artefactual time points \n',char(chanlabels(D,i)));
        D = badchannels(D,i,1);
        fprintf(['Computing for channel (out of %d):',repmat(' ',1,ceil(log10(D.nchannels))),'%d'],i, 1);
    end
    % Counter of channels to be updated
    if i>1
        for idisp = 1:ceil(log10(i)) % delete previous counter display
            fprintf('\b');
        end
        fprintf('%d',i);
    end
    for j = 1:nfrequencies(D)
%         for ti = 1:ntrials(D)     
            if strcmpi(method,'average')
                
                % Compute baseline without the artefacts
                if numel(sD) == 3
                    baseline = mean(squeeze(Dbase(i,tw,:)),1);
                    % Remove baseline from signal
                    base(1,:,:) = repmat(baseline,[nsamples(Dnew),1]);
                    Dnew(i,:,:) = D(i,:,:) - base;
                else
                    baseline = mean(squeeze(Dbase(i,j,tw,:)),1);
                    % Remove baseline from signal
                    base(1,1,:,:) = repmat(baseline,[nsamples(Dnew),1]);
                    Dnew(i,j,:,:) = D(i,j,:,:) - base;
                end
                clear base
                
            elseif strcmpi(method,'logR')
                
                % Compute baseline without the artefacts
                if numel(sD) == 3
                    signal = squeeze(Dbase(i,tw,:));
                    l10            = log10(signal);
                    if ~isempty(find(l10==-Inf)) % one or more infinite values to take out
                        l10(l10==-Inf) = NaN;
                        xbase = mean(l10,1,'omitnan');
                    else
                        xbase     = mean(l10,1);
                    end
                    % Remove baseline from signal
                    base(1,:,:) = repmat(xbase,[Dnew.nsamples, 1]);
                    Dnew(i,:,:) = 10*(log10(D(i,:,:)) - base);
                else
                    signal = squeeze(Dbase(i,j,tw,:));
                    l10            = log10(signal);
                    if ~isempty(find(l10==-Inf)) % one or more infinite values to take out
                        l10(l10==-Inf) = NaN;
                        xbase = mean(l10,1,'omitnan');
                    else
                        xbase     = mean(l10,1);
                    end
                    % Remove baseline from signal
                    base(1,1,:,:) = repmat(xbase,[Dnew.nsamples 1]);
                    Dnew(i,j,:,:) = 10*(log10(D(i,j,:,:)) - base);
                end
                clear base
                
            elseif strcmpi(method,'Zscore')
                if numel(sD) == 3
                    baselinem = mean(squeeze(Dbase(i,tw,:)),1);
                    baselinestd = std(squeeze(Dbase(i,tw,:)),0,1);
                    % Remove baseline from signal
                    basem(1,:,:) = repmat(baselinem,[Dnew.nsamples,1]);
                    basestd(1,:,:) = repmat(baselinestd,[Dnew.nsamples,1]);
                    Dnew(i,:,:) = (D(i,:,:) - basem)./basestd;
                else
                    baselinem = mean(squeeze(Dbase(i,j,tw,:)),1);
                    baselinestd = std(squeeze(Dbase(i,j,tw,:)),0,1);
                    % Remove baseline from signal
                    basem(1,1,:,:) = repmat(baselinem,[Dnew.nsamples,1]);
                    basestd(1,1,:,:) = repmat(baselinestd,[Dnew.nsamples,1]);
                    Dnew(i,j,:,:) = (D(i,j,:,:) - baselinem)./baselinestd;
                end
                clear basem basestd
                
            end
%         end
    end
end
fprintf('\n');
D = Dnew;
save(D);