function disp_file(file_path, channel, start, length)
% DISP display the file file_path with signal_analyzer
%   channel - channel to display from file
%   start - start [sec] of file to display
%   length - length [sec] of file to display

     init_samples = [1,1000];
    [y, Fs] = audioread(file_path,init_samples);
    
    if channel> size(y,2) 
        error('requested channel non existnt in file')
    end
    
    sample = [1+start*Fs, 1+ (start+length)*Fs];
    [y, ~] = audioread(file_path, sample);
    
    signal_analyzer(y(:, channel), Fs);

end