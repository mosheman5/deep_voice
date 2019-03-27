function fillPlots (fig_num, blue_value, green_value)

% Help: fills a signal graph with blue,green and black artificial graphs in
% order to work with detection_gui
% Calculates the blue and green graphs based on the red one, by giving a
% gain (positive or negative) to the original signal.
% fig_num is integer
% blue_value, green_value are floating

if mod(fig_num,1) 
    error ('fig_num should be integers! change it you idiot!');
elseif ~isfloat(blue_value) || ~isfloat(green_value)
    error ('blue_value,green_value should be floating/double type numbers! change it you idiot!');
end   

try
    sig_data = dataPlot(fig_num);
catch 
    sig_data = dataPlot(fig_num,2);
end    

axes_fig = get(fig_num,'CurrentAxes');
title_dad = get(axes_fig,'title');
title_org = get(title_dad,'string');

fill_data.blue = sig_data.y - blue_value;
fill_data.green = sig_data.y - green_value;
fill_data.black = ones(1,length(sig_data.y));

figure();
hold on
plot(sig_data.x,sig_data.y,'color','r','linewidth',2);
plot(sig_data.x,fill_data.blue,'color','b','linewidth',2);
plot(sig_data.x,fill_data.green,'color','g','linewidth',2);
plot(sig_data.x,fill_data.black,'color','k','linewidth',2);

title (title_org);
set(gca,'xscale',get(axes_fig,'xscale'));
set(gca,'xlim',get(axes_fig,'xlim'));
grid on;
legend('show');