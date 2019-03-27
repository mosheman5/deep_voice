function sSignal = readDCF(sDCF)
%readDCF function for reading .DCF audio files
%
%input:
%
%sDCF structure with following fields:
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
% sSignal = sDCF
% .Signal_vec                   : Vector with read data
%
% Written by Ilia
% Last eddited by Arthur 2007

NoiseFilePath = sDCF.DataPathName;
NoiseFile = sDCF.FileName;
NumOfChannels = sDCF.NumOfChannels;
ChannelNum = sDCF.ChannelNumber;
SampleRate = sDCF.SampleRate;
FileStartTime = datenum(sDCF.FileStartTime);
WindowStartTime = datenum(sDCF.WindowStartTime);
WindowEndTime = datenum(sDCF.WindowEndTime);


% SignalStartTime = round((WindowStartTime-FileStartTime)*3600*24);
% SignalEndTime = round((WindowEndTime-FileStartTime)*3600*24);
% sig_vec_length = ((SignalEndTime-SignalStartTime)*SampleRate);

SignalStartTime = ((WindowStartTime-FileStartTime)*3600*24);
SignalEndTime = ((WindowEndTime-FileStartTime)*3600*24);
sig_vec_length = ceil((SignalEndTime-SignalStartTime)*SampleRate);


%the following values were found by reverse engenering
%if proper documentaion found please fix them
%*_header_size - amount of 8bit numbers
DCF_header_size = 16;
chanel_header_size = 120-16;
total_header_size = DCF_header_size+NumOfChannels*chanel_header_size;

%open file
[fid, message] = fopen([NoiseFilePath NoiseFile],'r');

if fid == -1
    error(message)
end;

%detrmine total signal length
fseek(fid, 0, 'eof');
filesize = ftell(fid);
%signal_length - amount of 32bit numbers in each channel
signal_length = round((filesize - total_header_size)/NumOfChannels/4); %WARNING '-1' might be needed;


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
    %go to chanel number X to second number Y
    jump_to = DCF_header_size+chanel_header_size*ChannelNum+4*signal_length*(ChannelNum-1);
    jump_to = jump_to + 4*(floor(SignalStartTime*SampleRate));
%     fseek(fid, round(jump_to), 'bof');
    fseek(fid, jump_to, 'bof');

    %read data and close the file
    sig_vec_length = ceil((SignalEndTime-SignalStartTime)*SampleRate);
    if sig_vec_length < 0
        error('Neganive signal length. Hint: Probably you need to switch window times');
    end
    sig_vec = fread(fid, sig_vec_length, 'float');
    fclose(fid);

    %add zeros to end of signal if window end time other rides file end time
    if zero_bonus < 0 
        sig_vec(end+1:end-zero_bonus*SampleRate) = 0;
    end
    if zero_header>0
        sig_vec(zero_header+1:zero_header+size(sig_vec,1))=sig_vec;
        sig_vec(1:zero_header)=0;
    end;
end

sSignal = sDCF;
sSignal.Signal_vec = sig_vec;