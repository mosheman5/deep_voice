%enter signal txt 
signal_name='Looker_180910_145000(1,470,15)2019              3             13             23             41         26.595.txt';
cells=strsplit(signal_name,')');
daphnastr=strcat(cells{1},')');

 eval(daphnastr);
char=fileread(signal_name);
Kitziea=splitlines(char);
itsikalice='';
for ii=1:1:length(Kitziea)
  itsikalice=horzcat(itsikalice,' ',Kitziea{ii});  
end
last_index=find(itsikalice(1:(length(char)-54))==' ',5,'last');
char=itsikalice(1:last_index(1));
itsikalice=char;
index=find(char=='s');
index_end=length(index);
%number of social calls
total_mat=char;
social_call_mat='';
for ii=1:1:length(index)
    itsik=itsikalice(index(ii):end);
    pivot=find(itsik==' ',7);
index_end(ii)=pivot(7); 
num=12;%number of letters to the coordiantes of tagging
social_call_mat=horzcat(social_call_mat,char((index(ii)+num):index_end(ii)));
total_mat((index):index_end(ii))=repmat('q',1,index_end(ii)-index+1);
end
%now build a matrix where I drop off the q sequence
total_mat=total_mat(find (total_mat~='q'));

% all_guns=strsplit(char,'high');
%  all_boys=strsplit(all_guns{1});
% index=find(all_boys=='social call');
% strsplit(all_boys,', ')
all_boys=strsplit(total_mat);
all_girls=strsplit(social_call_mat);
m=1;
noam=1;
ii_last_one=-3;
for ii=1:m:(length(all_boys)-3)
    
 if ~isempty(str2num(all_boys{1,ii})) && ~isempty(str2num(all_boys{1,ii+3})) && (ii-ii_last_one)>3
 rectangle('position',[str2num(all_boys{1,ii+2}) str2num(all_boys{1,ii}) (str2num(all_boys{1,ii+3})-str2num(all_boys{1,ii+2})) (str2num(all_boys{1,ii+1})-str2num(all_boys{1,ii}))],'EdgeColor','g',...
    'LineWidth',3)   ;
m=4;
ii_last_one=ii;
 else
     m=1;
%  elseif ( str2num(all_boys{1,ii})==0)
%   rectangle('position',[str2num(all_boys{1,ii+2}) str2num(all_boys{1,ii}) (str2num(all_boys{1,ii+3})-str2num(all_boys{1,ii+2})) (str2num(all_boys{1,ii+1})-str2num(all_boys{1,ii}))],'EdgeColor','r',...
%     'LineWidth',3)   ;    
 end
end

for ii=1:m:(length(all_girls)-3)
    
 if ~isempty(str2num(all_girls{1,ii})) && ~isempty(str2num(all_girls{1,ii+3}))
 rectangle('position',[str2num(all_girls{1,ii+2}) str2num(all_girls{1,ii}) (str2num(all_girls{1,ii+3})-str2num(all_girls{1,ii+2})) (str2num(all_girls{1,ii+1})-str2num(all_girls{1,ii}))],'EdgeColor','r',...
    'LineWidth',3)   ;
m=4;
 else
     m=1;
%  elseif ( str2num(all_boys{1,ii})==0)
%   rectangle('position',[str2num(all_boys{1,ii+2}) str2num(all_boys{1,ii}) (str2num(all_boys{1,ii+3})-str2num(all_boys{1,ii+2})) (str2num(all_boys{1,ii+1})-str2num(all_boys{1,ii}))],'EdgeColor','r',...
%     'LineWidth',3)   ;    
 end
end

sprintf ('green-song, red-social call');
