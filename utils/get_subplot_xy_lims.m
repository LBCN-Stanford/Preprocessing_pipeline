function lims=get_subplot_xy_lims(h_fig)
%function lims=get_subplot_xy_lims(h_fig)

chillun=get(h_fig,'children');

n_ax=length(chillun);

lims=zeros(n_ax,4);
for a=1:n_ax,
    xlim=get(chillun(a),'xlim');
    ylim=get(chillun(a),'ylim');
    lims(a,:)=[xlim ylim];
end