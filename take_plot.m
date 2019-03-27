function [x,y]=take_plot(h,varargin)

% take single line from plot by color

if length(varargin)>0
    target_color=varargin{1};
else
    target_color=[];
end


lines=[];
cmat=get(gca,'ColorOrder');
linestyle_cell={'-','--',':','-.'};
i=1;
    a(i)=get(h(i),'CurrentAxes');
    if isempty(target_color)
       lines = [lines; get(a(i),'Children')];
    else
        lines = [lines; findobj(a(i),'color',target_color)];
    end

numplots=length(lines);

   x=get(lines(i),'XData');
   y=get(lines(i),'YData');
    
