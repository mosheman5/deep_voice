function kill_noise(fig,ax,min_freq,max_freq)

% input: 1.fig num. 2. 2 in fig has legend, 1 else 3. minfreq 4. maxfreq
% output: plot of the fig with zeros in the given freq range

if (ax==1)
    plots = dataPlot(fig);
else
    plots = dataPlot(fig,ax);
end

figure;
for ii=1:length(plots)
    
    f_vec = plots(ii).x;
    kill_vec = 1-(f_vec>=min_freq).*(f_vec<=max_freq);
    sig_vec = plots(ii).y;
    sig_vec = sig_vec.*kill_vec;

    semilogx(f_vec(:),sig_vec(:),'color',plots(ii).color,'linewidth',2);hold on;
end
set(gca,'xscale','log');
axis tight; grid on; hold off;