function disp_file(file_path, channel, start, length)
% DISP display the file file_path with signal_analyzer
%   channel - channel to display from filec
%   start - start [sec] of file to display
%   length - length [sec] of file to display

[dirpath,name,ext] = fileparts(file_path) ;
filename = [name ext];
DataPathName = [dirpath filesep];

t_start = [2000 01  01  00 00 00+start];
t_end = t_start; t_end(6)=t_end(6)+length;
sSignal=createCPanel;
sSignal=LoadSignal(sSignal, t_start, t_end, channel, 'BracketOverRide_handle', @LoadSignal_specific, ...
    'DataPathName',DataPathName, 'FileName',filename);
signal_analyzer(sSignal.sSignal.Signal_vec,sSignal.sSignal.SampleRate, strcat(name,'(', num2str(channel) , ',' , num2str(start), ',' , num2str(length),')'));

end