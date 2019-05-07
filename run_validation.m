%enter signal txt
tagging_folder = './tagging';
wav_folder = './14.9.18/recordings';

files_in_dir = dir(tagging_folder);

for file_ind = 3:length(files_in_dir)
    tag_path = fullfile(files_in_dir(file_ind).folder,  files_in_dir(file_ind).name);
    
    file_name = files_in_dir(file_ind).name(1:(end-4));
    
    open_brace_loc = strfind(file_name, '(');
    close_brace_loc = strfind(file_name, ')');
    
    wav_name = [file_name(1:(open_brace_loc(1)-1)) '.wav'];
    
    wav_path = fullfile(wav_folder,  wav_name);
    
    disp_params= sscanf( file_name(open_brace_loc(1):close_brace_loc(1)),  ...
        '(%d,%d,%d)');
    
    gui_handle = disp_file(wav_path, disp_params(1), disp_params(2), disp_params(3));
    
    var = getappdata(gui_handle,'var');
    
    cc_list = produce_best_CC(var, true);
    
end

function cc_list = produce_best_CC(var, do_plot)
% this function runs the CC and selection thresholds (entropy, energy)
% and returns the CC that passed the threshold

if nargin<2
    do_plot=0;
end

low_cut = 100;
high_cut = 2000;
perentile_of_power_thresh = 90;
min_cc_size = 50;
upper_ent_thresh = 0.9;

stft_mag = abs(var.b_mat);
spl = mag2db(abs(stft_mag));
noise_clean = NoiseCleaning();
var.first_f=length(find(var.f_vec<=low_cut));
var.last_f=length(find(var.f_vec<=high_cut));

spl_max = max(spl(:));
spl_bw = spl;

spl_temp = noise_clean.PCA_mag(stft_mag, 1, var.first_f, var.last_f);

CC = noise_clean.cpp(spl_temp, perentile_of_power_thresh, min_cc_size);  % spl, percentile of power thershold, min cc size

ent_list = OnsetDetector.ent_per_cc(10.^(spl./10), CC);

CC.PixelIdxList(ent_list>upper_ent_thresh) = [];


for index=1:length(CC.PixelIdxList)
    spl_bw(CC.PixelIdxList{index}) = 0;
end
B = bwboundaries(logical(spl_bw));
for ind = 1:length(B)
    boundary = B{ind};
    spl(sub2ind(size(spl),boundary(:,1),boundary(:,2))) = spl_max;
end

if do_plot
    var.image=imagesc(var.t_vec,var.f_vec(var.first_f:var.last_f),spl(var.first_f:var.last_f,:));
    caxis([min([20 max(max(spl))-40]) max(max(spl))]);
    
    axis tight; axis xy;
    
    setappdata(gui_figure,'var',var);
end

end
%
% cells=strsplit(signal_name,')');
% daphnastr=strcat(cells{1},')');
%
%  eval(daphnastr);
% char=fileread(signal_name);
% index=find(char=='s');
