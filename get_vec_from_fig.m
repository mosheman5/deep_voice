function plot_data = get_vec_from_fig(fig_number)
a=get(fig_number);
b=get(a.Children,'Children');
l_b=length(b);
for i=1:l_b
c=cell2mat(b(i));
if (length(c)==4)
break;
end
end
d=get(c(1));
plot_data.x=d(1).XData;
l1=length(plot_data.x);
y=ones(l1,length(c))-ones(l1,length(c));
for i=1:length(c)
d=get(c(i));
plot_data.y(1:l1,i)=d.YData;
end

 