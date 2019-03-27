function combine_plots(h,varargin);

if length(varargin)>0
    target_color=varargin{1};
else
    target_color=[];
end

numfigs=length(h);
lines=[];
cmat=get(gca,'ColorOrder');
linestyle_cell={'-','--',':','-.'};

for i=1:numfigs
    a(i)=get(h(i),'CurrentAxes');
    if isempty(target_color)
       lines = [lines; get(a(i),'Children')];
    else
        lines = [lines; findobj(a(i),'color',target_color)];
    end
end
numplots=length(lines);

figure; clf; hold on;
for i=1:numplots
    data(i).x=get(lines(i),'XData');
    data(i).y=get(lines(i),'YData');
    data(i).disp_name=get(lines(i),'displayname');
    if isempty(data(i).disp_name)
        data(i).disp_name=[get(get(get(lines(i),'parent'),'parent'),'name') ' color: ' num2str(get(lines(i),'color'))];
    end
    plot(data(i).x,data(i).y,'color',cmat(1+mod(i-1,size(cmat,1)),:),'displayname',data(i).disp_name,'linewidth',2,'linestyle',linestyle_cell{ceil(i/size(cmat,1))});
end;

set(gca,'xscale',get(a(1),'xscale'));
set(gca,'xlim',get(a(1),'xlim'));
grid on;
legend('show');
