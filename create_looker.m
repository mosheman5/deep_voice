function create_looker(replace_str)


filetext = fileread('14.9.18/Looker_180914_150127.m');
% replace_str = '123456_098765';
filetext = regexprep(filetext,'180914_150127',replace_str);
% index = 13 + regexp(filetext,'t_start = [20');
% jindex = regexp(filetext,'+start]') - 1;
% 
% f_year=replace_str(1:2) ; f_month=replace_str(3:4); 
% f_day=replace_str(5:6); f_hour=replace_str(8:9); 
% f_min=replace_str(10:11); f_sec=replace_str(12:13); 
% 
% filetext(index:jindex) = [f_year, ' ', f_month, '  ', f_day, '  ', ...
%     f_hour, ' ', f_min, ' ', f_sec];

% filetext(index)
% filetext(jindex)

fileID = fopen(['Looker_' replace_str '.m'],'a');
fwrite(fileID,filetext);
fclose(fileID);