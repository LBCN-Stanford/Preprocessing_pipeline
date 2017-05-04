function LBCN_plot_Kurtosis_Skewness(fname,threshold)

% Function to compute and plot the Kurtosis and the Skewness of each
% channel. A 'bad' channel detection can then be performed based on
% computed thresholds.
% Inputs:
% - fname    : Name of file to look at (SPM format)
% - threshold: Whether to perform thresholding or only plot (default)
% Output:
% Plot of Kurtosis versus Skewness for each channel. Channels plotted in
% blue are marked as 'good', in grey as 'bad' from previous analyses and in
% red as 'bad' based on Kurtosis or Skewness if 'threshold' was set to 1.
% The plot displays the channel label when clicking on a data point in the
% axes.
% -------------------------------------------------------------------------
% Written by J. Schrouff, 10/27/2015, LBCN, Stanford University


% Get inputs
% -------------------------------------------------------------------------

if nargin<1 || isempty(fname)
    fname = spm_select(1,'mat','Select file to plot',[],pwd,'.mat');
end
D = spm_eeg_load(fname);

if nargin<2 || isempty(threshold)
    threshold = 0;
end

nchan = nchannels(D);

% Demean the data compute the Kurtosis and Skewness
% -------------------------------------------------------------------------

kurt = zeros(length(nchan),1);
skew = zeros(length(nchan),1);
% Proceed channel by channel not to be out of memory
fprintf(['Computing for channel (out of %d):',repmat(' ',1,ceil(log10(nchan))),'%d'],nchan, 1);
for i= 1: nchan
    % Counter of channels to be updated
    if i>1
        for idisp = 1:ceil(log10(i)) % delete previous counter display
            fprintf('\b');
        end
        fprintf('%d',i);
    end
    % Demean data
    data = D(i,:) - mean(D(i,:),2);
    % Compute Kurtosis
    kurt(i) = kurtosis(data');
    % Compute Skewness
    skew(i) = skewness(data');
end
fprintf('\n');


% Compute thresholds for Kurtosis and Skewness
% -------------------------------------------------------------------------

goodchans = indchantype(D,'EEG','good'); %only consider brain signal channels
badchans  = indchantype(D,'EEG','bad');


% Kurtosis
def = get_defaults_Parvizi();
avg_kurt = median(kurt(goodchans));

if threshold
    diffmean = kurt' - repmat(avg_kurt, numel(kurt),1); % difference to median
    avgdiffmean = median(abs(diffmean)); 
    addbadkurt = find(abs(diffmean)>def.kurt_thresh*avgdiffmean);
    thresh_kurtb = avg_kurt -  def.kurt_thresh*avgdiffmean;
    thresh_kurta = avg_kurt +  def.kurt_thresh*avgdiffmean;
else
    addbadkurt = [];
    thresh_kurtb = 0;
    thresh_kurta = 0;
end

% Skewness
avg_skew = median(skew(goodchans));

if threshold
    diffmean = skew' - repmat(avg_skew, numel(skew),1); % difference to median
    avgdiffmean = median(abs(diffmean)); 
    addbadskew = find(abs(diffmean)>def.kurt_thresh*avgdiffmean); % For now same parameter for Skewness and Kurtosis
    thresh_skewb = avg_skew -  def.kurt_thresh*avgdiffmean;
    thresh_skewa = avg_skew +  def.kurt_thresh*avgdiffmean;
else
    addbadskew = [];
    thresh_skewb = 0;
    thresh_skewa = 0;
end

if threshold
    D = badchannels(D,addbadskew,ones(numel(addbadskew),1));
    D = badchannels(D,addbadkurt,ones(numel(addbadkurt),1));
    save(D);
end

% Plot values for Kurtosis and Skewness
% -------------------------------------------------------------------------

hfig = figure;
set(hfig,'Units','normalized')
hold on;
color = [60 60 255; 255 60 60; 115 115 115];
color = color/255;

for i=1:numel(kurt)
    name_chan = chanlabels(D,i);
    if any(ismember(goodchans,i)) && ~any(ismember(addbadkurt,i)) && ...
            ~any(ismember(addbadskew,i))
        h(i) = plot(skew(i),kurt(i),'d','Color',color(1,:),...
            'MarkerSize',5,'MarkerFaceColor',color(1,:),...
            'userdata',name_chan,'buttondownfcn',@dispchanname);
    elseif any(ismember(goodchans,i)) && any(ismember(addbadkurt,i)) || any(ismember(addbadskew,i))
        h(i) = plot(skew(i),kurt(i),'d','Color',color(2,:),...
            'MarkerSize',5,'MarkerFaceColor',color(2,:),...
            'userdata',name_chan,'buttondownfcn',@dispchanname);
    elseif any(ismember(goodchans,i)) && any(ismember(addbadskew,i))
        h(i) = plot(skew(i),kurt(i),'d','Color',color(2,:),...
            'MarkerSize',5,'MarkerFaceColor',color(2,:),...
            'userdata',name_chan,'buttondownfcn',@dispchanname);
    else
        h(i) = plot(skew(i),kurt(i),'d','Color',color(3,:),...
            'MarkerSize',5,'MarkerFaceColor',color(3,:),...
            'userdata',name_chan,'buttondownfcn',@dispchanname);
    end
end

% Add thresholds if computed

if thresh_kurta ~= 0 && thresh_kurtb ~= 0
    xlim([min(thresh_skewb,min(skew))-0.1, max(thresh_skewa,max(skew))+0.1])
    xl = xlim;
    plot(xl(1):0.1:xl(2),repmat(thresh_kurta,1,length([xl(1):0.1:xl(2)])),'--k','Linewidth',2)
    plot(xl(1):0.1:xl(2),repmat(thresh_kurtb,1,length([xl(1):0.1:xl(2)])),'--k','Linewidth',2)
end
xl = xlim;

if thresh_skewa ~= 0 && thresh_skewb ~= 0
    ylim([0, max(thresh_kurta,max(kurt))+1])
    yl = ylim;
    plot(repmat(thresh_skewa,1,length([yl(1):0.1:yl(2)])),yl(1):0.1:yl(2),'--k','Linewidth',2)
    plot(repmat(thresh_skewb,1,length([yl(1):0.1:yl(2)])),yl(1):0.1:yl(2),'--k','Linewidth',2)
end
yl = ylim;

xlim(xl)
ylim(yl)
title('Kurtosis - Skewness')
xlabel('Skewness')
ylabel('Kurtosis')



function dispchanname(gcbo, EventData, handles)
name_chan = get(gcbo, 'userdata');
currentpoint = get(gcf,'CurrentPoint');
prevannot = get(gcf,'UserData');
name_prevchan = get(prevannot,'String');
if strcmpi(name_chan,name_prevchan)
    % delete annotation
    set(gcf,'UserData',[]);
    delete(prevannot)
else
    % delete annotation
    delete(prevannot)
    h = annotation('textbox',[currentpoint 0.1 0.1],'String',char(name_chan));
    set(gcf,'UserData',h);
end
    









