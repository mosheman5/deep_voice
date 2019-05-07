function sSignal = LoadSignal_specific(sSignal)

%input: windowstarttime windowendtime channelnumber

file_info = audioinfo([sSignal.DataPathName(1,:) sSignal.FileName(1,:)]);
sSignal.NumOfChannels = file_info.NumChannels;
sSignal.SampleRate = file_info.SampleRate;
sSignal.offset=0;
sSignal.FileStartTime = [2000 01  01  00 00 00+sSignal.offset];

sSignal.channelCalibration= [140 140 140 140]; 
sSignal.channelGain=[1 1 1 1];
%_______________________________________________________
sSignal.WindowStartTime = datevec(datenum(sSignal.WindowStartTime));
sSignal.WindowEndTime = datevec(datenum(sSignal.WindowEndTime));

number_of_files=size(sSignal.FileName,1);
time_diff_vec=datenum(repmat(sSignal.WindowStartTime,size(sSignal.FileStartTime,1),1)-sSignal.FileStartTime);
time_diff_vec(time_diff_vec<0)=inf;
if min(time_diff_vec)==inf 
    file_ind=1;
else
    file_ind = find(time_diff_vec==min(time_diff_vec));
end

if file_ind < number_of_files
    sSignal.nextFileStartTime = sSignal.FileStartTime(file_ind+1,:);
else
    sSignal.nextFileStartTime = inf;
end

sSignal.FileName=sSignal.FileName(file_ind,:);
sSignal.FileStartTime=sSignal.FileStartTime(file_ind,:);
sSignal.channelCalibration = sSignal.channelCalibration(file_ind,:);
sSignal.channelGain = sSignal.channelGain(sSignal.ChannelNumber);
