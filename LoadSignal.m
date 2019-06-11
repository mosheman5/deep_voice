function sSignal = LoadSignal(sSignal, startTime, endTime, channelIndex, varargin)
%LOADSIGNAL load audio signal
%   The purpose of the function is to become transperent
%   interface for user who want to load an audio file.
%   Currently the function supports .DCF and .WAV files
%
%   SSIGNAL = LOADSIGNAL(SSIGNAL) load with default/last values
%   SSIGNAL = LOADSIGNAL(SSIGNAL, STARTTIME, ENDTIME) as previous,
%   but the time values are changed accordingly
%   FATHERSTRUCTURE=LOADSIGNAL(SSIGNAL, STARTTIME, ENDTIME, MICPLACE)
%   as previous, with predefined area 
%input
%
% sCPanel structure (also called father-structure) with sSignal as sub-structure
% OR
% sSignal structure with following feilds
%
% .DataPathName                 : Data path name must contain "slash" at end, example:'..\data\fwd\'
% .FileName                     : File name
%Following fields are currently only for .DCF files
% .NumOfChannels                : see readDCF.m
% .ChannelNumber                : see readDCF.m
% .SampleRate                   : see readDCF.m
% .FileStartTime                : see readDCF.m
% .WindowStartTime              : see readDCF.m
% .WindowEndTime                : see readDCF.m
%
%output:
%
% if input was a sSignal structure then:
% sSignal structure with following fields:
%
% sSignal = sSignal
% .Signal_vec                   : Vector with read data
%
% else, the output is a father structure with its sub-structure sSignal modified at the same manner


%this is a CPanel object linker, it is set to 'sSignal' field
%but in differnt function you have to change field name
fatherStructure = sSignal;
if ~strcmp(fatherStructure.standardStructureName, 'sSignal')
    sSignal = linkCPanel(fatherStructure, 'sSignal', varargin{:});
end

if nargin >= 3      %update times only
	sSignal.WindowStartTime = startTime;
	sSignal.WindowEndTime = endTime;
end

if nargin >= 4      %update channel nunber to be read
    sSignal.ChannelNumber = channelIndex;
end

%Michael add 11/6/19 
BracketOverRide_handle = sSignal.BracketOverRide_handle;
if ~isempty(BracketOverRide_handle)
    sSignal = feval(BracketOverRide_handle, sSignal);
end

%this linker can override any settings
sSignal = linkCPanel(sSignal, [], [], varargin{:});

%and now something comlitly different
nextFileStartTime = datenum(sSignal.nextFileStartTime);
WindowEndTime = datenum(sSignal.WindowEndTime);
if nextFileStartTime < WindowEndTime
    sRecurtionSignal = sSignal;
    sRecurtionSignal.WindowStartTime = nextFileStartTime; %used to be datestr
    sSignal.WindowEndTime = sRecurtionSignal.WindowStartTime;
%     disp('Loading signal recursivly...');
    sRecurtionSignal = LoadSignal(sRecurtionSignal);
    recurtionSignal_length = length(sRecurtionSignal.Signal_vec);
else
    recurtionSignal_length = 0;
end

FileName = sSignal.FileName;
dot_ind = find(FileName == '.');

switch lower(FileName(dot_ind+1:dot_ind+3))
    case 'wav'
        sSignal = readWAV(sSignal);
    case 'dcf'
        sSignal = readDCF(sSignal);
    case 'mat'% case for data as vector and no wav file
        sSignal = readMAT(sSignal);
end

%fix gain
%calibrate signal

sSignal.Signal_vec = sSignal.Signal_vec*sSignal.channelGain.*10.^(sSignal.channelCalibration(sSignal.ChannelNumber)/20);

%add recurtion signal to read signal
if recurtionSignal_length > 0
    sSignal.Signal_vec(end+1:end+recurtionSignal_length) = sRecurtionSignal.Signal_vec;
    sSignal.WindowEndTime = sRecurtionSignal.WindowEndTime;
else
%     disp(['DONE: Loading signal, length: ', num2str(length(sSignal.Signal_vec)), ' samples']);
end

%this linker rebuilds the structure so it is the same type as original input structure
if ~strcmp(fatherStructure.standardStructureName, 'sSignal')
    sSignal = linkCPanel(fatherStructure, 'sSignal', sSignal);
end

