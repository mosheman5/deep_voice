function shoot=get_vec_from_fig3(gc)

% take the 80% percentile from signal analyzer

%%
gui_figure=gcf;
var=getappdata(gui_figure,'var');
if ~isempty(findobj(gui_figure,'Color','r','LineWidth',3)); delete(findobj(gui_figure,'Color','r','LineWidth',3)); end;
c_point=get(var.handles.main_axes,'CurrentPoint');
c_x=c_point(2,1); c_y=c_point(2,2);
f_ind=find(abs(var.f_vec-c_y)==min(abs(var.f_vec-c_y)));
t_ind=find(abs(var.t_vec-c_x)==min(abs(var.t_vec-c_x)));
var.f_ind=f_ind(1);
var.t_ind=t_ind(1);
set(var.handles.point_value,'string',num2str(var.graph(var.f_ind,var.t_ind)));
set(var.handles.point_coord,'string',['( ' num2str(var.t_vec(var.t_ind),'%.2f') ' , ' num2str(var.f_vec(var.f_ind),'%.2f') ' )']);
% main axes
axes(var.handles.main_axes);
h_lines=findobj(gui_figure,'Color','w','LineWidth',2);
if ~isempty(h_lines) delete(h_lines); end;
var.hor_line=line(get(gca,'XLim'),[var.f_vec(var.f_ind) var.f_vec(var.f_ind)],'Color','w','LineWidth',2);
var.ver_line=line([var.t_vec(var.t_ind) var.t_vec(var.t_ind)],get(gca,'YLim'),'Color','w','LineWidth',2);
% x axes
axes(var.handles.x_axes);
plot(var.t_vec(1:size(var.graph,2)),var.graph(var.f_ind,:),'LineWidth',2);
axis tight;
set(var.handles.x_axes,'ButtonDownFcn',@x_axes_click_callback);
% y axes
axes(var.handles.y_axes);
plot(var.graph(var.first_f:var.last_f,var.t_ind),var.f_vec(var.first_f:var.last_f),'LineWidth',2);
axis tight;
set(gca,'xlim',[max([max(var.graph(var.first_f:var.last_f,var.t_ind))-60 min(var.graph(var.first_f:var.last_f,var.t_ind))]) max(var.graph(var.first_f:var.last_f,var.t_ind))]);
set(var.handles.y_axes,'Xdir','reverse');
set(var.handles.y_axes,'ButtonDownFcn',@y_axes_click_callback);
% prob axes
axes(var.handles.p_density_axes);
kde_numel=32;
data_vec=var.graph(var.f_ind,:);
data_vec=repmat(data_vec(:),1,5); %%%% WARNING : REPMAT FOR ACCURATE KDE
[bandwidth,density,xmesh]=kde(data_vec,kde_numel); 
plot(xmesh,density,'LineWidth',2,'color','b');
axis tight;
set(var.handles.p_density_axes,'ButtonDownFcn',@p_density_axes_click_callback);
set(var.handles.p_integral_axes,'ButtonDownFcn',@p_density_axes_click_callback);
% integral axes
axes(var.handles.p_integral_axes);
cla;
set(var.handles.p_integral_axes,'XAxisLocation','bottom','YAxisLocation','right','Color','none','XColor','k','YColor','r');
prob_integral=cumsum(density)*(xmesh(end)-xmesh(1))/kde_numel;
line(xmesh,prob_integral,'Color','r','Parent',var.handles.p_integral_axes,'linewidth',2);
axis tight;
% stats update
set(var.handles.mean_val,'string',num2str(mean(var.graph(var.f_ind,:)) ,'%.2f'));
set(var.handles.std_val,'string',num2str(std(var.graph(var.f_ind,:)) ,'%.2f'));
set(var.handles.low_percentile,'string',num2str( xmesh(find((abs(prob_integral-0.1))==min(abs(prob_integral-0.1)))),'%.2f'));
set(var.handles.high_percentile,'string',num2str( xmesh(find((abs(prob_integral-0.9))==min(abs(prob_integral-0.9)))),'%.2f'));
% time mean axes
axes(var.handles.time_mean_axes); cla; hold on;
data_mat=sort(var.graph(var.first_f:var.last_f,:),2);
high_per=ceil(0.01*str2num(get(var.handles.red_percentile,'string'))*size(data_mat,2));
med_per=ceil(0.01*str2num(get(var.handles.blue_percentile,'string'))*size(data_mat,2));
low_per=ceil(0.01*str2num(get(var.handles.green_percentile,'string'))*size(data_mat,2));
%
var.stats.high_per=get(var.handles.red_percentile,'string');
var.stats.med_per=get(var.handles.blue_percentile,'string');
var.stats.low_per=get(var.handles.green_percentile,'string');
var.stats.f_vec=var.f_vec(var.first_f:var.last_f);
var.stats.high_per_vec=data_mat(:,high_per);
var.stats.med_per_vec=data_mat(:,med_per);
var.stats.low_per_vec=data_mat(:,low_per);
var.stats.average_std=std(data_mat,0,2);
var.stats.graph_type=var.selected_tag;
%
plot(var.f_vec(var.first_f:var.last_f),data_mat(:,high_per),'LineWidth',1,'color','r');
plot(var.f_vec(var.first_f:var.last_f),data_mat(:,med_per),'LineWidth',1,'color','b');
plot(var.f_vec(var.first_f:var.last_f),data_mat(:,low_per),'LineWidth',1,'color','g');
plot(var.f_vec(var.first_f:var.last_f),var.stats.average_std,'LineWidth',1,'color','k');
set(gca,'xscale','log');
axis tight; grid on; hold off;
set(var.handles.time_mean_axes,'ButtonDownFcn',@time_mean_axes_click_callback);
setappdata(gui_figure,'var',var);

%%
gui_figure=gcf;
var=getappdata(gui_figure,'var');
% try
%     y_out = figure('name',char(var.main_title(1)));
% catch 
%     y_out = figure;
% end
% figure(y_out); hold on;
% set(gcf,'units','normalized','position',[1 1 1 1]);
% plot(var.stats.f_vec,var.stats.high_per_vec,'LineWidth',2,'color','r');
% %plot(var.stats.f_vec,var.stats.med_per_vec,'LineWidth',2,'color','b');
% %plot(var.stats.f_vec,var.stats.low_per_vec,'LineWidth',2,'color','g');
% %plot(var.stats.f_vec,var.stats.average_std,'LineWidth',2,'color','k');
% title(['Red ' get(var.handles.red_percentile,'string') '% Blue ' get(var.handles.blue_percentile,'string') '% Green ' get(var.handles.green_percentile,'string') '% (' var.title_s ')']);
% set(gca,'xscale','log');
% axis tight; grid on;
shoot.x=var.stats.f_vec;
shoot.y=var.stats.high_per_vec;

% % a=get(gc);
% % b=get(a.Children,'Children');
% % c=get(b);
% % shoot.x=c.XData;
% % shoot.y=c.YData;

end