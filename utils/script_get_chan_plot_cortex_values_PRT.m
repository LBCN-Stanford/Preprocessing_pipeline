function script_get_chan_plot_cortex_values_PRT(cortex,els,PRT, nm,bin,view,side,name)

% cortex: cortex file name (use spm_select e.g.)
% els: name of electrode file name
% PRT: loaded PRT structure
% nm: index of model (use prt_init_model e.g.)
% values: what you want to plot (one value per channel)
% bin: flag to say whether values are binary (i.e. [0 or 1]) or continuous
% view: 'P' for parietal, 'T' for temporal, 'M' for mesial
% side: 'L' or 'R', implanted hemisphere


load(cortex)
load(els)
rel=elecmatrix();
in.fs_name = PRT.model(nm).input.fs(1).fs_name;
fid = prt_init_fs(PRT,in);
aa = PRT.fs(fid).modality(1).dim_m{1}; %channel selection
values = mean(reshape([PRT.model(nm).output.fold(:).beta],length(PRT.model(nm).output.fold(1).beta),length(PRT.model(nm).output.fold)),2)*100;
% aa = ichan;
if nargin<5 || ~bin
    maxb = round(max(values(:,1)));
    cc = colormap(parula(maxb));
    cc = cc(end:-1:1,:);
    bin = 0;
else
    cc(1,:) = [1 1 1];
%     cc(1,:) = [200 10 150]/255; % pink
%     cc(1,:) = [224 114 195]/255; % light pink
%     cc(1,:) = [255 255 255]/255;
%     cc(1,:) = [171 115 186]/255; %light purple
    maxb = 1;
    values = double(values);
end
cc = cc(end:-1:1,:);
cc = [1,1,1;cc];

ic = zeros(size(values,1),3);
mecv = repmat([0 0 0]/255,size(values,1),1);
% mecv = repmat('k',size(values,1),1);
lwv = 1*ones(size(values,1),1);
marker = cell(size(values,1),1);
szv = 10*ones(size(values,1),1);
for i = 1:size(values,1)
    tmp = round(values(i,1));
    if tmp>0
        ic(i,:) = cc(tmp+1,:);
        marker{i} = 'o';
    else
        ic(i,:) = [0,0,0];
        marker{i} = 'kd';
        lwv(i) = 0.1;
        szv(i) = 4;
    end
    if size(values,2)>1 % binary variables to highlight some channels provided
        if values(i,2)
            %             mecv(i) = 'c';
            mecv(i,:) = [235 235 0]/255; % yellow
%             mecv(i,:) = [47 81 189]/255;%dark blue
%             mecv(i,:) = [7 121 166]/255;
            lwv(i) = 2;
            szv(i) = 10;
        end
    end
    if size(values,2)>2 % binary variables to highlight some channels provided (but less than first stage)
        if values(i,3)
            
            ic(i,:) = [200 10 150]/255;
            szv(i) = 10;
%             mecv(i) = 'w';
            
            if values(i,2)
                mecv(i,:) = [235 235 0]/255; % yellow
                lwv(i) = 2;
            else
                mecv(i,:) = [1 1 1];
                lwv(i) = 1;
            end
        end
    end
    if size(values,2)>3 % binary variables to highlight some channels provided (but less than first stage)
        if values(i,4)
            mecv(i,:) = [1 1 1];
%             mecv(i) = 'w';
            lwv(i) = 2;
        end
    end
    
end

% Plot colorbar
subplot('Position',[0.9 0.1 0.05 0.15])
barh(diag(ones(maxb+1,1)),'stacked','barwidth',1,'EdgeColor','none');
ylim([1 size(cc,1)])
colormap(cc)
set(gca,'xtick',[])
dd = get(gca,'ytick');
set(gca,'ytick',[dd(1) dd(end)])
set(gca,'yticklabel',{'0',num2str(maxb)})
freezeColors


% trc = 0.6*ones(size(rel,1),3);
% trc(aa,:) = ic;
% mec = repmat('k',size(rel,1),1);
rel = rel(aa,:);
hold on
h=subplot('Position',[0.05 0.05 0.8 0.8]);
ctmr_gauss_plot(cortex,[0 0 0],h,0)
for i = 1:size(rel,1)
    tmp = ic(i,:);
    hold on, plot3(rel(i,1),rel(i,2),rel(i,3)-1,marker{i},'MarkerFaceColor', tmp,'MarkerSize',szv(i),'LineWidth',lwv(i),'MarkerEdgeColor',mecv(i,:))
end
if ~exist('.\figs','dir')
    mkdir('.','figs');
end

if nargin <6
    view = 'P'; % parietal
end
if nargin<7
    side = 'L'; %left
end

% name = PRT.model(nm).model_name
if nargin<8 || isempty(name)
    name = 'cortex_plot';
end

switch side
    case 'L'
        if strcmpi(view,'P')
            v_d=[280,0]; %left H parietal view
            loc_view(v_d(1),v_d(2))
            print('-opengl','-r300','-dpng',strcat(['.',filesep,'figs',filesep,'LParietal_',name]));
        elseif strcmpi(view,'T')
            v_d = [180,270]; %left H patient temporal view
            loc_view(v_d(1),v_d(2))
            set(gcf,'PaperUnits','inches')
            set(gcf,'PaperSize',[6.1 9.2])
            set(gcf,'PaperPosition',[0.05 0.1 6 9])
            print('-opengl','-r300','-dpng',strcat(['.',filesep,'figs',filesep,'LTemporal_',name]));
        elseif strcmpi(view,'M')
            v_d = [270,0]; %Left H patient mesial view
            loc_view(v_d(1),v_d(2))
            print('-opengl','-r300','-dpng',strcat(['.',filesep,'figs',filesep,'LMesial_',name]));
        else
            disp('unknown view to project')
        end
    case 'R'
        if strcmpi(view,'P')
            v_d=[70,0]; %Right H parietal view
            loc_view(v_d(1),v_d(2))
            print('-opengl','-r300','-dpng',strcat(['.',filesep,'figs',filesep,'RParietal_',name]));
        elseif strcmpi(view,'T')
            v_d = [180,270]; %right patient temporal
            loc_view(v_d(1),v_d(2))
            set(gcf,'PaperUnits','inches')
            set(gcf,'PaperSize',[6.1 9.2])
            set(gcf,'PaperPosition',[0.05 0.1 6 9])
            print('-opengl','-r300','-dpng',strcat(['.',filesep,'figs',filesep,'RTemporal_',name]));
        elseif strcmpi(view,'M')
            v_d = [90,0]; %right H patient mesial view
            loc_view(v_d(1),v_d(2))
            print('-opengl','-r300','-dpng',strcat(['.',filesep,'figs',filesep,'RMesial_',name]));
        else
            disp('unknown view to project')
        end
end
% save(['Channels_locations_',PRT.model(nm).model_name,'.mat'],'trc','rel','lel','tr_el','b')