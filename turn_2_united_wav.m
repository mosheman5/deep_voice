function turn_2_united_wav(name,varargin)

% Help: The function gets the wanted name for the united file, and the
% names of the files to combine in the varargin. the input type should be a
%string, without the suffix of .wav

switch length(varargin)
    case 1
        error('It is already one file you dumbass!');
    case 2
        [recorder_ch1, F_1] = audioread([varargin{1} '.wav']);
        [recorder_ch2, ~] = audioread([varargin{2} '.wav']);
        y = [recorder_ch1, recorder_ch2];

    case 3
        [recorder_ch1, F_1] = audioread([varargin{1} '.wav']);
        [recorder_ch2, ~] = audioread([varargin{2} '.wav']);
        [recorder_ch3, ~] = audioread([varargin{3} '.wav']);
        y = [recorder_ch1, recorder_ch2, recorder_ch3];
    case 4
        [recorder_ch1, F_1] = audioread([varargin{1} '.wav']);
        [recorder_ch2, ~] = audioread([varargin{2} '.wav']);
        [recorder_ch3, ~] = audioread([varargin{3} '.wav']);
        [recorder_ch4, ~] = audioread([varargin{4} '.wav']);
        y =  [recorder_ch1, recorder_ch2, recorder_ch3, recorder_ch4];
end

audiowrite([name '.wav'],y,F_1,'BitsPerSample',24);


%[recorder, F_F] = audioread('recorder_united.wav');
%xxx 
%= recorder - y;
%xxxx = recorder_ch2 - recorder_ch1;