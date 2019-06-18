%enter signal txt
tagging_folder = ['.' filesep 'tagging_social_only'];
wav_folder = ['.' filesep 'recordings'];
save_validation_results_in = ['.' filesep 'evaluation_results'];
plot_flag = true;

files_in_dir = dir(tagging_folder);

seg_params = containers.Map;
paramsList=containers.Map;
seg_params('low_cut') = 100;
seg_params('high_cut') = 2000;
paramsList('perentile_of_power_thresh') = [88,90,92];
paramsList('min_cc_size') = [40,50,60];
paramsList('upper_ent_thresh') = [0.3,0.4,0.5];


for file_ind = 3:length(files_in_dir)
    tag_path = fullfile(files_in_dir(file_ind).folder,  files_in_dir(file_ind).name);
    
    file_name = files_in_dir(file_ind).name(1:(end-4));
    
    open_brace_loc = strfind(file_name, '(');
    close_brace_loc = strfind(file_name, ')');
    
    wav_name = [file_name(1:(open_brace_loc(1)-1)) '.wav'];
    
    wav_path = fullfile(wav_folder,  wav_name);
    
    disp_params= sscanf( file_name(open_brace_loc(1):close_brace_loc(1)),  ...
        '(%d,%d,%d)');
    
    %try
    gui_handle = disp_file(wav_path, disp_params(1), disp_params(2), disp_params(3));
    
    var = getappdata(gui_handle,'var');
    j=1; %min CC index
    k=1; %ent index
    for i=1:length(paramsList('perentile_of_power_thresh'))*length(paramsList('min_cc_size'))*length(paramsList('upper_ent_thresh'))
        temp_p=paramsList('perentile_of_power_thresh');
        temp_CC=paramsList('min_cc_size');
        temp_E=paramsList('upper_ent_thresh');
        seg_params('perentile_of_power_thresh')=temp_p(length(paramsList('perentile_of_power_thresh'))-mod(i,length(paramsList('perentile_of_power_thresh'))));
        seg_params('min_cc_size')=temp_CC(length(paramsList('min_cc_size'))-mod(j,length(paramsList('min_cc_size'))));
        seg_params('upper_ent_thresh')=temp_E(length(paramsList('upper_ent_thresh'))-mod(k,length(paramsList('upper_ent_thresh'))));
        j=j+isequal(mod(i,length(paramsList('perentile_of_power_thresh'))),1); %every new loop of i, change j
        k=k+isequal(mod(i,length(paramsList('min_cc_size'))*length(paramsList('perentile_of_power_thresh'))),1); %every new loop of j, change k
        save_validation_results_in = ['.' filesep ['evaluation_results',num2str(seg_params('perentile_of_power_thresh')),...
            '_',num2str(seg_params('min_cc_size')),'_dot',num2str(seg_params('upper_ent_thresh')*10,'%d')]]; %folder name e.g. "evaluation_results_90_50_0.4"
        CC = produce_best_CC(var, seg_params, plot_flag);
        
        [song_cell, social_cell] = bounding_box(gui_handle, tag_path, plot_flag);
        
        tag_cell = [song_cell social_cell];
        tag_cell(cellfun('isempty',tag_cell)) = [];
        
        [accuracy, precisions, precision]  = calc_detector_matrics(var, CC, tag_cell, false, plot_flag);
        [time_accuracy, time_precisions, time_precision]  = calc_detector_matrics(var, CC, tag_cell, true, plot_flag);
        if(isfolder(save_validation_results_in)==false)
            mkdir(save_validation_results_in)
        end
        if(plot_flag==true)
            fig = gcf;
            fig.PaperPositionMode = 'auto';
            print(fullfile(save_validation_results_in, [file_name '.jpg']),'-djpeg','-r300')
            save(fullfile(save_validation_results_in, [file_name '_val.txt']),...
                'accuracy','precisions','precision',... % precision = full file precision
                'time_accuracy','time_precisions','time_precision',...
                '-ASCII');
        end
        
        save(fullfile(save_validation_results_in, 'params.mat'),...
            'seg_params' );
    end
    %catch
    %   disp(['file ' wav_path ' should exist but dosnt' ]);
    %end
    
end

function [accuracy, precisions, precision]  = calc_detector_matrics(var, CC, tag_cell, do_time, do_plot)
% returns matrices for the operation of our detector
% In:
%   var = contians the current spect data
%   CC - the connected component struct representing the result of our
%       detector
%   tag_cell - cell array {'f1','f2','t1','t2'...} of the bounding box in
%       the tag file
%   do_time - calc all detections only in the time domain, ignoring
%       good/bad detection in respect to frequency
%
% Out:
%  accuracy - the precent of pixels in each tag that are coverd by the
%      total of CC's. is a vector, with a value for each tagged signal
%  precision - the percent of total CC pixels that are in a bb. thats a
%      single number
%  precision_best_CC - same but for the best CC per tag file. is a vector
%      matching accuracy

accuracy = zeros(1, length(tag_cell)/4);
precisions=zeros(length(CC.PixelIdxList));

im_shape = size(var.b_mat);

total_CCs = zeros(im_shape(1),im_shape(2));
for CC_ind = 1:length(CC.PixelIdxList)
    CC_mask = zeros(im_shape(1),im_shape(2));
    
    CC_mask(CC.PixelIdxList{CC_ind}) = 1;
    total_CCs(CC.PixelIdxList{CC_ind}) = 1;
end

if do_time
    total_CCs = any(total_CCs,2);
end

total_tags = zeros(im_shape(1),im_shape(2));
for tag_ind = 1:4:length(tag_cell)
    tag_mask = zeros(im_shape(1),im_shape(2));
    
    first_f=length(find(var.f_vec<= str2num(tag_cell{tag_ind})));
    last_f=length(find(var.f_vec<= str2num(tag_cell{tag_ind+1})));
    
    first_t=length(find(var.t_vec<= str2num(tag_cell{tag_ind+2})));
    last_t=length(find(var.t_vec<= str2num(tag_cell{tag_ind+3})));
    
    tag_mask(first_f:last_f, first_t:last_t) = 1;
    if do_time
        tag_mask = any(tag_mask,2);
    end
    
    total_tags(first_f:last_f, first_t:last_t) = 1;
    
    accuracy(1+(tag_ind-1)/4)= sum(sum((total_CCs & tag_mask)))/sum(sum(tag_mask));
    
end

if do_time
    total_tags = any(total_tags,2);
end

for CC_ind = 1:length(CC.PixelIdxList)
    
    CC_mask = zeros(im_shape(1),im_shape(2));
    CC_mask(CC.PixelIdxList{CC_ind}) = 1;
    
    if do_time
        CC_mask = any(CC_mask,2);
    end
    single_cc_precision = sum(sum((CC_mask & total_tags)))/sum(sum(CC_mask));
    precisions(CC_ind)=single_cc_precision;
end

precision = sum(sum((total_CCs & total_tags)))/sum(sum(total_CCs));

if do_plot
    if do_time
        disp('time matrices:')
    end
    disp(['accuracy: ' num2str(accuracy)])
    disp(['precisions: ' num2str(precisions)])
    disp(['full file precision: ' num2str(precision)])
end

end

function [song_cell, social_cell] = bounding_box(gui_handle, tag_file_path, do_plot)

string_file_contents=fileread(tag_file_path);
lines_in_file=splitlines(string_file_contents);
file_one_line='';
for ii=1:1:(length(lines_in_file)-5)
    file_one_line=horzcat(file_one_line,' ',lines_in_file{ii});
end
string_file_contents=file_one_line;
index=find(string_file_contents=='s');
index_end=length(index);
%number of social calls
song_call_string=string_file_contents;
social_call_string='';
for ii=1:1:length(index)
    s_call_container=[string_file_contents(index(ii):end) ' '];
    pivot=find(s_call_container==' ',7);
    index_end(ii)=pivot(end);
    num=12;%number of letters to the coordiantes of tagging
    social_call_string=horzcat(social_call_string,string_file_contents((index(ii)+num):(index(ii)+index_end(ii)-2)));
    song_call_string((index(ii)):(index(ii)+index_end(ii)-2))=repmat('q',1,index_end(ii)-1);
end
%now build a matrix where I drop off the q sequence
song_call_string=song_call_string(find (song_call_string~='q'));


song_cell=strsplit(song_call_string);
social_cell=strsplit(social_call_string);
m=1;
ii_last_one=-3;
if do_plot
    for ii=1:m:(length(song_cell)-3)
        
        if ~isempty(str2num(song_cell{1,ii})) && ~isempty(str2num(song_cell{1,ii+3})) && (ii-ii_last_one)>3
            f_coord = sort([str2num(song_cell{1,ii}), str2num(song_cell{1,ii+1})]);
            t_coord = sort([str2num(song_cell{1,ii+2}), str2num(song_cell{1,ii+3})]);
            rectangle('position',[t_coord(1), f_coord(1), diff(t_coord), diff(f_coord)],'EdgeColor','k',...
                'LineWidth',3)   ;
            m=4;
            ii_last_one=ii;
        else
            m=1;
            
        end
    end
    
    m=1;
    ii_last_one=-3;
    for ii=1:m:(length(social_cell)-3)
        
        if ~isempty(str2num(social_cell{1,ii})) && ~isempty(str2num(social_cell{1,ii+3}))  && (ii-ii_last_one)>3
            f_coord = sort([str2num(social_cell{1,ii}), str2num(social_cell{1,ii+1})]);
            t_coord = sort([str2num(social_cell{1,ii+2}), str2num(social_cell{1,ii+3})]);
            rectangle('position',[t_coord(1), f_coord(1), diff(t_coord), diff(f_coord)],'EdgeColor','r',...
                'LineWidth',3)   ;
            m=4;
            ii_last_one=ii;
        else
            m=1;
            
        end
    end
    
    sprintf ('black-song, red-social call');
end

end

function CC = produce_best_CC(var, seg_params, do_plot)
% this function runs the CC and selection thresholds (entropy, energy)
% and returns the CC that passed the threshold

if nargin<2
    do_plot=0;
end

low_cut = seg_params('low_cut');
high_cut =  seg_params('high_cut');
perentile_of_power_thresh =  seg_params('perentile_of_power_thresh');
min_cc_size =  seg_params('min_cc_size');
upper_ent_thresh =  seg_params('upper_ent_thresh');

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
    
    %     setappdata(gui_figure,'var',var);
end

end

