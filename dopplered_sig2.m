function res=dopplered_sig2(f0,tele_h,analayzer_h,t_offset)

tele_var = getappdata(tele_h,'var');

channel = size(tele_var.sGroup.data.x,1);

x = tele_var.sGroup.data.x(channel,:);
y = tele_var.sGroup.data.y(channel,:);
z = tele_var.sGroup.data.z(channel,:);
time = tele_var.sGroup.data.time(channel,:);

day00 = datevec(time(1));
start_time = get(tele_var.handles.time_min,'string');
start_time(start_time==':')=' ';
start_time = datenum([day00(1:3) str2num(start_time)])+t_offset./(24*3600);
% datevec(start_time);
end_time = get(tele_var.handles.time_max,'string');
end_time(end_time==':')=' ';
end_time = datenum([day00(1:3) str2num(end_time)])+t_offset./(24*3600);
% datevec(end_time);

%ind=1:length(x);

ind = find((time>=start_time).*(time<=end_time));
time = time(ind);
x = x(ind);
y = y(ind);
z = z(ind);
% figure;plot(x,y,'.');
r = sqrt(x.*x + y.*y + z.*z);
dr= r(2:end) - r(1:(end-1)); dr = [dr dr(end)];
dt= time(2:end) - time(1:(end-1)); dt = [dt dt(end)].*24.*3600;
% dx = x(2:end) - x(1:(end-1));
% dy = y(2:end) - y(1:(end-1));
% dr = sqrt(dx.*dx + dy.*dy);

c_speed = 340;
%f = f0.*(c_speed-dr)./c_speed;
f = f0.*c_speed./(c_speed+(dr./dt));
t = (1:length(f))-1;
% figure;plot(t,f,'.');ylim([0 200]);
% figure;plot(1:length(f),dr,'.');
% figure;
% plot(x(ind),y(ind),'.');hold on;
% plot(0,0,'kx');

var = getappdata(analayzer_h,'var');
b_mat = 20.*log10(abs(var.b_mat));
t_vec = var.t_vec;
f_vec = var.f_vec;
f = interp1(t,f,t_vec,'pchip');
f_mat = repmat(f',length(f_vec),1);
f0_mat = repmat(f_vec,1,length(t_vec));

diff_mat = abs(f_mat - f0_mat);
min_mat = repmat(min(diff_mat),length(f_vec),1);
f_mat = (diff_mat==min_mat);
% figure;imagesc(t_vec,f_vec,f_mat);axis xy;
% figure;imagesc(t_vec,f_vec,f_mat.*b_mat);axis xy;

res=sum(sum(f_mat.*b_mat));