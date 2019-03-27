function save_with_title(fig_num)
    axes_fig = get(fig_num,'CurrentAxes');
    title_dad = get(axes_fig,'title');
    file_name = get(title_dad,'string');
    saveas(fig_num,[file_name '.fig']);
end