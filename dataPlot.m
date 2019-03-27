function plot_data = dataPlot(varargin)

% input: fig num. if fig has legend, input should be (fig_num,2)
% output: a structe contains the x,y and color of the line

switch nargin
    case 0  %no input
        %h_fig = get(0,'children');
        %h_fig = h_fig(1);
        h_fig = gcf;
        h_axes = get(h_fig,'children');
    case 1  %figure name/number input
        if ischar(varargin{1})
            h_fig = findobj('name',varargin{1});
        else
            h_fig = varargin{1};
        end
        h_axes = get(h_fig,'children');
    case 2 %figure name/number + axes input
        if ischar(varargin{1})
            h_fig = findobj('name',varargin{1});
        else
            h_fig = varargin{1};
        end
        if ischar(varargin{2})
            h_axes = findobj('tag',varargin{2});
        else
            h_axes = get(h_fig,'children');
            h_axes = h_axes(varargin{2});
            %             pos = cell2mat(get(h_axes,'position'));
            %             pos1 = 1:size(pos,1);
            %             pos = [pos1(:) pos];
            %             pos(:,3) = -pos(:,3);
            %             pos = sortByNcol([2 3],pos);
            %             h_axes = h_axes(pos(varargin{2},1));
        end
end

h_plots = get(h_axes,'children');
num_of_plots = length(h_plots);
for ii = 1:num_of_plots
    plot_data(ii).x = get(h_plots(ii),'XData');
    plot_data(ii).y = get(h_plots(ii),'YData');
    plot_data(ii).color = get(h_plots(ii),'color');
end

