function sSignal = readMAT(sMAT)
% copy of readDCF for MAT files - copied to minimize possible compatability issues
%
%input:
%
%sMAT structure with following fields:
%
% .DataPathName                 : Data path name must contain "slash" at end, example:'..\data\fwd\'
% .FileName                     : File name
% .NumOfChannels                : Number of channels in DCF file
% .ChannelNumber                : Number of channel to read
% .SampleRate                   : Sample rate (frequency)
% .FileStartTime                : Time of begining of audio stream in seconds
% .WindowStartTime              : Audio window start time in seconds
% .WindowEndTime                : Audio window end time in seconds
%
%NOTE: all input times are in seconds and with same starting point (Beginning of the week for example)
%
%output:
%
%sSignal structure with following fields:
%
% sSignal = sMAT
% .Signal_vec                   : Vector with read data
%
% by arthur. (original "readDCF" written by Ilia, eddited by arthur 2007)

NoiseFilePath = sMAT.DataPathName;
NoiseFile = sMAT.FileName;
NumOfChannels = sMAT.NumOfChannels;
ChannelNum = sMAT.ChannelNumber;
SampleRate = sMAT.SampleRate;
FileStartTime = datenum(sMAT.FileStartTime);
WindowStartTime = datenum(sMAT.WindowStartTime);
WindowEndTime = datenum(sMAT.WindowEndTime);

SignalStartTime = ((WindowStartTime-FileStartTime)*3600*24);
SignalEndTime = ((WindowEndTime-FileStartTime)*3600*24);
sig_vec_length = ceil((SignalEndTime-SignalStartTime)*SampleRate);

% file_size = MATread([NoiseFilePath NoiseFile],'size');
load(sMAT.FileName);
file_size = size(y);
signal_length=file_size(1);


if (signal_length - SignalStartTime*SampleRate < 0)||((SignalStartTime<0)&&(SignalEndTime<0)&&(signal_length>0))
    warning('Window start is after end of file, signal is zero padded.');
    sig_vec = zeros(1, sig_vec_length);
else
    zero_bonus = floor(signal_length/SampleRate - SignalEndTime); %negative number of seconds to add
    if zero_bonus < 0
        warning('Window end is after end of file, signal is zero padded.');
        SignalEndTime = (signal_length/SampleRate);
    end
    
    zero_header=-SignalStartTime*SampleRate;
    if zero_header>0
        warning('Window start is before file start: signal is zero padded');
        SignalStartTime=0;
    end;

    sig_vec_length = ceil((SignalEndTime-SignalStartTime)*SampleRate);
    if sig_vec_length < 0
        error('Neganive signal length. Hint: Probably you need to switch window times');
    end

    %[y,Fs,bits] = MATread([NoiseFilePath NoiseFile],[floor(SignalStartTime*SampleRate)+1  floor(SignalEndTime*SampleRate)]);
    sig_vec=y(:,ChannelNum);

    %add zeros to end of signal if window end time after file end time
    if zero_bonus < 0 
        sig_vec(end+1:end-zero_bonus*SampleRate) = 0;
    end
    if zero_header>0
        sig_vec(zero_header+1:zero_header+size(sig_vec,1))=sig_vec;
        sig_vec(1:zero_header)=0;
    end;
end

sSignal = sMAT;
sSignal.Signal_vec = sig_vec;