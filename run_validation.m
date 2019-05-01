%enter signal txt 
tagging_folder = './tagging';
wav_folder = './14.9.18/recordings';

files_in_dir = dir(tagging_folder);

for file_ind = 3:length(files_in_dir)
    tag_path = fullfile(files_in_dir(file_ind).folder,  files_in_dir(file_ind).name);
    disp(tag_path)
    wav_path = fullfile(files_in_dir(file_ind).folder,  files_in_dir(file_ind).name);
    disp(wav_path)

    
    
end
% 
% cells=strsplit(signal_name,')');
% daphnastr=strcat(cells{1},')');
% 
%  eval(daphnastr);
% char=fileread(signal_name);
% index=find(char=='s');