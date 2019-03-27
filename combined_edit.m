function combined_edit(fig_num,type)

% function gets lines from the same graph(after combine_plots), calculates:
% envelope - the biggest difference between them and shows it in a new figure.
% mean - means mean
% percentile - The default is 80%. one can change it manualy in the
% function, "high_per{


% read data
axes_fig = get(fig_num,'CurrentAxes');
lines = get(axes_fig,'Children');
x_data_cell = get(lines,'XData');
x_data_mat = cell2mat(x_data_cell);
x_data = x_data_mat(1,:);
y_data_cell = get(lines,'YData');
y_data = cell2mat(y_data_cell);

% original title
title_dad = get(axes_fig,'title');
title_org = get(title_dad,'string');

% choose and calculate operation
switch type
    case 'envelope'
        y_max = max(y_data);
        y_min = min(y_data); 
        results = y_max - y_min;
        plot_title = 'Min - Max';
    case 'mean'
        results = mean(y_data);
        plot_title = 'Mean';
    case 'max'
        results = max(y_data);
        plot_title = 'Max';
    case 'percentile'
        high_per_num=0.1;
        data_mat=sort(y_data,1);
        high_per=ceil(high_per_num*size(data_mat,1));
        results=data_mat(high_per,:);
        plot_title = ['Percentile ' num2str((high_per_num*100)) '%'];
    case 'perc_vs_max'
        high_per_num=0.75;
        data_mat=sort(y_data,1);
        high_per=ceil(high_per_num*size(data_mat,1));
        y_max = max(y_data);
        results=y_max - data_mat(high_per,:);
        plot_title = ['Percentile ' num2str((high_per_num*100)) '%' 'vs. Max'];
    case 'perc_vs_min'
        low_per_num=0.5;
        data_mat=sort(y_data,1);
        low_per=ceil(low_per_num*size(data_mat,1));
        y_min = min(y_data);
        results=data_mat(low_per,:) - y_min;
        plot_title = ['Percentile ' num2str((low_per_num*100)) '%' 'vs. Min'];
    case 'low_high_comparison'
        low_mics = mean ( [y_data(4,:);y_data(2,:)] );
        high_mics = mean ( [y_data(3,:);y_data(1,:)] );
        results = [low_mics; high_mics];
        plot_title = 'Low vs High Mics'; 
        plot_title_words = regexp(plot_title,' ','split');
    case 'adjusted'
        y_mean = mean(y_data);
        y_min = min(y_data);
        results= y_mean - y_min;
        plot_title = 'Mean vs. Min';
end 

% plot
figure();hold on;

if size(results,1)<2
    plot(x_data,results,'color','r','displayname',plot_title,'linewidth',2);
else
    plot(x_data,results(1,:),'color','r','displayname',plot_title_words{1},'linewidth',2);
    plot(x_data,results(2,:),'color','b','displayname',plot_title_words{3},'linewidth',2);
end
%plot(x_data,results_2,'color','b','displayname','low','linewidth',2);
title ([title_org,', ',plot_title]);
set(gca,'xscale',get(axes_fig,'xscale'));
set(gca,'xlim',get(axes_fig,'xlim'));
grid on;
legend('show');

