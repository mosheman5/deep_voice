function findH(fig,f,f0)

var = getappdata(fig,'var');

f_sigma = (f0/10)^2;
f_wheight = exp(-0.5.*((var.f_vec-f)./f_sigma).^2);

figure;
plot(var.f_vec,f_wheight,'.');
