function reconstruct_sound

answer = inputdlg('Enter figure handle and plot color for spec graph.','Get Graph',2,{'',''});
spec_vec=findobj(str2num(answer{1}(1,:)),'color',answer{1}(2,:));
spec_vec=spec_vec(1);
filter.a_vec=get(spec_vec,'ydata');
filter.f_vec=get(spec_vec,'xdata');


t_length=15;
sample_rate=filter.f_vec(end)*2+1;
nfft_in=filter.f_vec(end)*2+1;


time=linspace(0,ceil(t_length*sample_rate),ceil(t_length*sample_rate));
noise_vec=sqrt(2)*randn(size(time)).*10.^((0)/20); 
[new_mat,f_vec,t_vec]=specgram_proper(noise_vec,nfft_in,sample_rate,'rectangular',0);

filter_vec=interp1(filter.f_vec,filter.a_vec,f_vec,'nearest','extrap');

% amp_mat=abs(new_mat).*repmat((10.^(filter_vec/20)),1,length(t_vec));
amp_mat=abs(ones(size(new_mat))).*repmat((10.^(filter_vec/20)),1,length(t_vec));
% phase_mat=angle(new_mat);
% phase_mat=rand(size(new_mat))*2*pi;

[T,F]=meshgrid(t_vec,f_vec);
phase_mat=(2*pi.*T.*F)+rand(size(new_mat))*2*pi*0.1;
% phase_mat=rand(size(new_mat))*2*pi;
new_mat=amp_mat.*exp(i.*phase_mat);


noise_vec = inverse_specgram(new_mat,nfft_in,'rectangular',0);
signal_analyzer(noise_vec,sample_rate,'new noise');
