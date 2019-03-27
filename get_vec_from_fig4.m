function [x,y]= get_vec_from_fig4(fig_number)
a=get(fig_number);
b=get(a.Children,'Children');
l_b=length(b);
x=b.XData;
y=b(4).YData;