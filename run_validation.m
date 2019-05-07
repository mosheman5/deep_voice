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
          
    disp_file(wav_path, disp_params(1), disp_params(2), disp_params(3));
    
end
% 
% cells=strsplit(signal_name,')');
% daphnastr=strcat(cells{1},')');
% 
%  eval(daphnastr);
% char=fileread(signal_name);
% index=find(char=='s');