function dopplered_sig(f0,start_time,end_time,tele_h)

var = getappdata(tele_h,'var');

channel = size(var.sGroup.data.x,1);

x = var.sGroup.data.x(channel,:);
y = var.sGroup.data.y(channel,:);
z = var.sGroup.data.z(channel,:);
time = var.sGroup.data.time(channel,:);

day00 = datevec(time(1));
start_time = datenum([day00(1:3) start_time]);
datevec(start_time);
end_time = datenum([day00(1:3) end_time]);
datevec(end_time);

%ind=1:length(x);

ind = find((time>=start_time).*(time<=end_time));
time = time(ind);
x = x(ind);
y = y(ind);
z = z(ind);

r = sqrt(x.*x + y.*y + z.*z);
dr= r(2:end) - r(1:(end-1));
% dx = x(2:end) - x(1:(end-1));
% dy = y(2:end) - y(1:(end-1));
% dr = sqrt(dx.*dx + dy.*dy);

c_speed = 340;
%f = f0.*(c_speed-dr)./c_speed;
f = f0.*c_speed./(c_speed+dr);

figure;plot(1:length(f),f,'.');ylim([0 200]);
% figure;plot(1:length(f),dr,'.');
% figure;
% plot(x(ind),y(ind),'.');hold on;
% plot(0,0,'kx');
