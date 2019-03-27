function Looker_180914_150127_context(channel,start,len)


t_start = [2018 09  14  15 01 27+start];
t_end = t_start; t_end(6)=t_end(6)+len;
sSignal=createCPanel;
sSignal=LoadSignal(sSignal, t_start, t_end, channel, 'BracketOverRide_handle', @LoadSignal_180914_150127_context);
signal_analyzer(sSignal.sSignal.Signal_vec,sSignal.sSignal.SampleRate);

