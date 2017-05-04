function LBCN_plot_power_spectrum(fname, goodonly, power, indchan, timewin)

% Function to plot the power spectrum of all (good) channels.
% Inputs:
% fname     : name of file to plot (optional)
% goodonly  : plot only good channels (1), or all (0: default)
% power     : flag to plot the power (1) or the psd (0: default)
% indchan   : indexes of specific channel to plot
% timewin   : time window to plot spectrogram on (default: length of recording)
% Outputs:
% plot of the power spectrum using pwelch
% -------------------------------------------------------------------------
% Written by J. Schrouff, LBCN, 07/29/2015, based on LBCN code


% Get inputs
% -------------------------------------------------------------------------
if nargin<1 || isempty(fname)
    fname = spm_select(1,'mat','Select file to plot',[],pwd,'.mat');
end
D = spm_eeg_load(fname);

if nargin<2 || isempty(goodonly) || goodonly == 0
    nchan = 1:D.nchannels;
elseif goodonly ==1
    nchan = setdiff(1:D.nchannels,badchannels(D));
end

if nargin<3 || isempty(power)
    type = 'psd';
elseif power ==1
    type = 'power';
elseif power == 0 
    type = 'psd';
end

if nargin == 4 && ~isempty(indchan)
    nchan = indchan;
end

if nargin<5 || isempty(timewin)
    timewin = 1:nsamples(D);
end

% Compute and plot power spectrum
% -------------------------------------------------------------------------

set_w=D.fsample;%window
set_ov=0;%overlap
set_nfft=D.fsample;%nfft

data_pxx=zeros(round(D.fsample/2)+1,length(nchan));

for k=1:length(nchan)
    [Pxx,f] = pwelch(D(nchan(k),timewin),set_w,set_ov,set_nfft,D.fsample,type);
    data_pxx(:,k)=Pxx;
end

figure,hold on


% Plot channels in different colors:
plotthis=log(data_pxx);
nn = floor(length(nchan)/6);

plot(f,plotthis(:,1:nn),'k');
plot(f,plotthis(:,nn+1:nn*2),'b');
plot(f,plotthis(:,nn*2+1:nn*3),'r');
plot(f,plotthis(:,nn*3+1:nn*4),'g');
plot(f,plotthis(:,nn*4+1:nn*5),'c');
plot(f,plotthis(:,nn*5+1:end),'m');
