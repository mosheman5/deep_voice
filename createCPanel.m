function sCPanel = createCPanel
%**************************************************************************
%Description
%
%   constructive fuction for using the DSP control panel
%   must run before any other function operating the data
%   initializes all data fields to deafult values
%
%**************************************************************************


%*************************VAR**********************************************
%NOTE: Most! (but not all) [] fields are updated via some auto functions
%NOTE: All dir paths must contain "slash" at end, example:'..\data\fwd\'
%NOTE: All time variables are at internal matlab time format, if not stated else.
%      There are two posible time formats:
%      if a single value is passes it should be a string: 'dd-mmm-yyyy HH:MM:SS'     -> MATLAB 0 format
%      if a muliple values are passed they should be a column vector DAY.PART_OF_DAY -> MATLAB 
%**************************************************************************

%**************************************************************************
%Name
sCPanel.standardStructureName= 'sCPanel';

%After each run the whole sCPanel is dumped to a predefined dir
sCPanel.sSettings.DumpDirectory = 'c:\temp\';
%After each run the whole sCPanel is dumped to a predefined file
sCPanel.sSettings.DumpFileName = 'sCPanel_dump.mat';
%**************************************************************************

%**************************************************************************
%handle of function used to OVERRIDE the [] values
%this function is used to read the audio data and must be written for each experiment!
sCPanel.sSignal.BracketOverRide_handle = [];
sCPanel.sSignal.DataPathName = [];
sCPanel.sSignal.FileName = [];
sCPanel.sSignal.NumOfChannels = [];
sCPanel.sSignal.ChannelNumber = [];
sCPanel.sSignal.SampleRate = [];
sCPanel.sSignal.FileStartTime = []; 
sCPanel.sSignal.WindowStartTime = [];   %time in MATLAB format
sCPanel.sSignal.WindowEndTime = [];     %time in MATLBAB format
sCPanel.sSignal.Signal_vec = [];                            %output of LoadSignal function
sCPanel.sSignal.nextFileStartTime = [];
sCPanel.sSignal.channelGain = [];
sCPanel.sSignal.channelCaliboartion = [];
sCPanel.sSignal.standardStructureName = 'sSignal';          %mini structure name
%**************************************************************************

%**************************************************************************
sCPanel.sFFT.Signal_vec = [];
sCPanel.sFFT.fftResolution = [];
sCPanel.sFFT.SampleRate = [];
sCPanel.sFFT.channelCaliboartion = [];
sCPanel.sFFT.signalFFT_vec = [];
sCPanel.sFFT.freq_vec = [];
sCPanel.sFFT.standardStructureName='sFFT';
%**************************************************************************

%**************************************************************************
sCPanel.sMap.Signal_vec = [];                   %AUTO OVERRIDED by FindAndSumAllHarmonics function
sCPanel.sMap.SampleRate = [];                   %AUTO OVERRIDED by FindAndSumAllHarmonics function
sCPanel.sMap.FileStartTime = [];                %AUTO OVERRIDED by FindAndSumAllHarmonics function
sCPanel.sMap.WindowStartTime = [];              %AUTO OVERRIDED by FindAndSumAllHarmonics function
sCPanel.sMap.WindowEndTime = [];                %AUTO OVERRIDED by FindAndSumAllHarmonics function
sCPanel.sMap.fftResolution = [];                %AUTO OVERRIDED by FindAndSumAllHarmonics function
sCPanel.sMap.nOverlap = [];
sCPanel.sMap.windowType = [];
sCPanel.sMap.SigSegLength = [];                  %Time length of signal slice
sCPanel.sMap.sigSegOverLap = [];                 %
sCPanel.sMap.Map_mat = [];                      %output of CreateMap function
sCPanel.sMap.time_vec = [];                     %Time index of each slice
sCPanel.sMap.freq_vec = [];                     %vector of map frequncies
sCPanel.sMap.standardStructureName='sMap';
sCPanel.sMap.map_angle_mat = [];
%**************************************************************************
