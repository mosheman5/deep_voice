function plot_data = dataPlot2(varargin)

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

%theres a possibilty of pressing mistakely in the plot, it adds then a
%parasite structre in h_plots as h_plots(1)that destroys the importing process
%of the plots, therefor  we are catching the error with j as escaping the
%loop just in case it happens;

j=0;
try
    plot_data(1).x = get(h_plots(1),'XData');
catch 
   j=1;
end
    
for ii = 1:(num_of_plots-j)
     
    plot_data(ii+j).x = get(h_plots(ii+j),'XData');
    plot_data(ii+j).y = get(h_plots(ii+j),'YData');
    plot_data(ii+j).color = get(h_plots(ii+j),'color');
end


function mat = sortByNcol(cols,mat)
for ii = 1:length(cols)
    [B,newOrder] = sort(mat(:,cols(ii)));
    mat = mat(newOrder,:);
end
