function d = LBCN_smooth_data(files,win_length, time_win, evtfile, twfield)

% Function to smooth the data using a Gaussian window.
% Inputs:
% - files      : name of the .mat files to smooth
% - win_length : length of window to smooth on (in ms)
% - time_win   : time window of signal to consider (avoid edges effects for
%                TF signal), in ms, [start end].
% evtfile      : event file, as saved in LBCN format
% twfield      : field of event file to select time window around
% Output: cell array containing the smoothed MEEG objects created. Those 
% files are also saved on the disk, with the prefix 'S'.
%--------------------------------------------------------------------------
% Written by J. Schrouff, LBCN, Stanford University, 08/21/2015

if nargin<1 || isempty(files)
    files = spm_select([1 Inf],'.mat', 'Select files to process',{},pwd,'.mat');
end

if nargin<2 || isempty(win_length)
    def = get_defaults_Parvizi;
    win_length = def.smooth_win;
else
    win_length = win_length/1000;
end
    
    
d = cell(size(files,1),1);
for i = 1:size(files,1)
    D = spm_eeg_load(deblank(files(i,:)));
    win_length = win_length*D.fsample;
    gusWin= gausswin(win_length)/sum(gausswin(win_length));
    gusWin = gusWin';
    
    if nargin<3 || isempty(time_win)
        t_win = 1:D.nsamples;
        time_win(1) = D.time(1);
        time_win(2) = D.time(D.nsamples);
    else
        if nargin>=4 && ~isempty(evtfile)
            load(evtfile);
            evt = events;
            clear events;
        else
            t1 = D.indsample(time_win(1)/1000);
            t2 = D.indsample(time_win(2)/1000);
            t_win = t1:t2;
        end       
    end

    % Generate new MEEG object with new filenames
    % -------------------------------------------------------------------------
    if length(size(D))==4
        Dnew = clone(D, ['S' D.fname], [D.nchannels, D.nfrequencies, length(t_win), D.ntrials]);
        isTF = 1;
    else
        Dnew = clone(D, ['S' D.fname], [D.nchannels, length(t_win), D.ntrials]);
        isTF = 0;
    end
    
    Dnew = type(Dnew, 'single');
    
    if ~isTF
        fr = 1;
    else
        fr = D.frequencies;
    end
    
    for k=1:length(fr)
        for j = 1:D.ntrials
            if isTF
                data = D(:, k, :, j);
            else
                data = D(:,:,j);
            end
            tmp = zeros(size(squeeze(data)));
            for c = 1:D.nchannels
                tmp(c,:) = conv(data(c,:),gusWin,'same');
            end
            if isTF
                tmp2(:,1,:,1) = tmp(:,t_win);
                Dnew(:,k,:,j) = tmp2;
            else
                Dnew(:,:,j) = tmp(:,t_win);
            end
        end
    end
    Dnew = timeonset(Dnew,time_win(1)/1000);
    D = Dnew;
    save(D);
    d{i} = D;
end