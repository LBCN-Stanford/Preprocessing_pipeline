function [D] = get_events_SPMformat(filename,eventfile)


% Get inputs
% -------------------------------------------------------------------------
if nargin<1 || isempty(filename)
    filename = spm_select;
end
try
   D = spm_eeg_load(filename);
catch
    error('Could not load file');
end

if nargin<2 || isempty(eventfile)
    eventfile = spm_select;
end
try
   evt = load(eventfile);
   evt = evt.events;
catch
    error('Could not load file');
end

% Get events into SPM format
% -------------------------------------------------------------------------
evtspm = [];
ncat = length(evt.categories);
names = cell(1,ncat);
onsets = cell(1,ncat);
durations = cell(1,ncat);
for i = 1:ncat
    aa = evt.categories(i);
    if ~isempty(aa.name)
        if isempty(aa.stimNum)
            aa.stimNum = 1:aa.numEvents;
        end
        tempevt = struct('type',repmat({aa.name},1,aa.numEvents),...
            'value',num2cell(aa.stimNum),...
            'time',num2cell(aa.start),...
            'duration',num2cell(aa.duration),...
            'offset',repmat({0},1,aa.numEvents));
        evtspm = [evtspm , tempevt];
        names{i} = aa.name;
        onsets{i} = [aa.start];
        durations{i} = [aa.duration];
    end
end
%save events in SPM friendly format
[~,fname] = fileparts(D.fname);
save(['spm8_events_',fname,'.mat'],'names','durations','onsets')
%sort by event time
d1 = [evtspm(:).time];
[~,ids] = sort(d1,'ascend');
evtspm = evtspm(ids);
D = struct(D);
D.trials.label = 'Undefined';
D.trials.events = evtspm;
D.trials.onset = 1/D.Fsample;

%Create and save MEEG object
D = meeg(D);
save(D);