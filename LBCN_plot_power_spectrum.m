function LBCN_plot_power_spectrum(fname, timewin, power, indchan, savespect,spectdata)

% Function to plot the power spectrum of all (good) channels.
% Inputs:
% - fname     : name of file to plot (optional)
% - timewin   : time window to plot spectrogram on (default: length of recording)
% - power     : flag to plot the power (1) or the psd (0: default)
% - indchan   : indexes of specific channel to plot
% - savespect : whether or not to save the spectrogram (0 = no: default)
% - spectdata : file name of previously saved spectrogam data (should contain 
%               variables 'data_pxx' and 'f')
% Outputs:
% - plot of the power spectrum using pwelch, interactive
% -------------------------------------------------------------------------
% Written by J. Schrouff, LBCN, 07/29/2015, based on LBCN code


% Get inputs
% -------------------------------------------------------------------------
donotcompute = 0;
if nargin == 6 && ~isempty(spectdata)
    try
        load(spectdata)
        if exist('data_pxx','var') && exist('f','var') && exist('fname','var')
            disp('Loading data from provided file')
            donotcompute = 1;
        else
            disp('Could not find spectrogram data, recomputing')
            if nargin<1 || isempty(fname)
                fname = spm_select(1,'mat','Select file to plot',[],pwd,'.mat');
            end
        end
        D = spm_eeg_load(fname);
    catch
        error('LBCN_plot_power_spectrum:CouldNotLoadFile',...
            'Could not load spectrogram data')
    end
else
    if nargin<1 || isempty(fname)
        fname = spm_select(1,'mat','Select file to plot',[],pwd,'.mat');
    end
    D = spm_eeg_load(fname);
end

if nargin< 5 || isempty(savespect)
    savespect = 0;
end

nchan = 1:D.nchannels;
if nargin == 4 && ~isempty(indchan)
    nchan = indchan;
end

if nargin<3 || isempty(power)
    type = 'psd';
elseif power ==1
    type = 'power';
elseif power == 0 
    type = 'psd';
end

if nargin<2 || isempty(timewin)
    timewin = 1:nsamples(D);
else
    timestart = indsample(D,timewin(1));
    timeend = indsample(D,timewin(2));
    timewin = timestart:timeend;
end


% Compute and plot power spectrum
% -------------------------------------------------------------------------

if ~donotcompute
    set_w=D.fsample;%window
    set_ov=0;%overlap
    set_nfft=1:250;%nfft
    
    data_pxx=zeros(length(set_nfft),length(nchan));
    
    for i = 1:length(nchan)
        data = D(nchan(i),timewin) - mean(D(nchan(i),timewin),2); % demean before spectrogram
        [Pxx,f] = pwelch(data',set_w,set_ov,set_nfft,D.fsample,type);
        data_pxx(:,i)= Pxx;
    end
    
    if nargin >= 5 && savespect
        [path,fname] = spm_fileparts(fname);
        save(fullfile(path,['Spectrogram_',fname,'.mat']),'data_pxx','f','fname')
    end
end

LBCN_bad_chan_SPM_spectGUI([],{D,log(data_pxx),f});


% figure,hold on
% 
% 
% % Plot channels in different colors:
% plotthis=log(data_pxx(:,nchan));
% nn = floor(length(nchan)/6);
% 
% plot(f,plotthis(:,1:nn),'k');
% plot(f,plotthis(:,nn+1:nn*2),'b');
% plot(f,plotthis(:,nn*2+1:nn*3),'r');
% plot(f,plotthis(:,nn*3+1:nn*4),'g');
% plot(f,plotthis(:,nn*4+1:nn*5),'c');
% plot(f,plotthis(:,nn*5+1:end),'m');
