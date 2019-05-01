function varargout = signal_analyzer(varargin)
% signal,sample_rate,sig_name

% Begin initialization code - DO NOT EDIT
global vec_name
if  nargin==2 %~isempty(inputname(1))
    vec_name=inputname(1);
end

gui_Singleton = 0;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @signal_analyzer_OpeningFcn, ...
    'gui_OutputFcn',  @signal_analyzer_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
clear vec_name

% --- Executes just before signal_analyzer is made visible.
function varargout = signal_analyzer_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
% UIWAIT makes signal_analyzer wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% defaults
global vec_name
gui_figure=handles.figure1;
set(gui_figure,'UserData','signal_analyzer');
var=getappdata(gui_figure,'var');

if isempty(varargin) % override for load menu (no inputs)
    load_Callback(hObject, eventdata, handles);
        
else % MAIN ACTION
    var.signal=varargin{1};
    var.sample_rate=varargin{2};
    var.original_sample_rate=varargin{2};
    var.saves_dir=pwd;
    if length(varargin)==2
        var.main_title=vec_name;
    else
        var.main_title=['Figure ' {'gui_figure'} ': ' varargin{3}];
    end
    setappdata(gui_figure,'var',var);
    clear var;
    calculate_b_mat(gui_figure);
    var=getappdata(gui_figure,'var');
    axes(handles.main_axes);
    var.handles=handles;
    setappdata(gui_figure,'var',var);
    clear var;
    draw_main_axes(gui_figure);
    var=getappdata(gui_figure,'var');
    %set(gcf,'Name',char(var.main_title(2)));
end

clear vec_name
% end

% --------------------------------------------------------------------
% ------------------Empty Functions----------------------------------
% --------------------------------------------------------------------
% --- Outputs from this function are returned to the command line.
function varargout = signal_analyzer_OutputFcn(hObject, eventdata, handles) %#ok<*INUSL>
varargout{1} = handles.output;
if isfield(handles,'override_close_flag')
    if handles.override_close_flag;
        close(handles.figure1);
    end
end

% --- Executes when figure1 is resized.
function figure1_ResizeFcn(hObject, eventdata, handles)
%-----%-----%-----%-----%-----%-----%-----%-----%-----%----%-
%-----%-----%-----%-----%-----%-----%-----%-----%-----%----%-

% --------------------------------------------------------------------
% ------------------Non Emprty Create Functions----------------------
% --------------------------------------------------------------------
% --- Executes during object creation, after setting all properties.
function nfft_CreateFcn(hObject, eventdata, handles)
gui_figure=gcf;
var=getappdata(gui_figure,'var');
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
var.nfft_in=1024*4;
set(hObject,'string','1024*8');
setappdata(gui_figure,'var',var);

% --- Executes during object creation, after setting all properties.
function window_type_CreateFcn(hObject, eventdata, handles)
gui_figure=gcf;
var=getappdata(gui_figure,'var');
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
var.window_type='hanning';
set(hObject,'value',1);
setappdata(gui_figure,'var',var);

% --- Executes during object creation, after setting all properties.
function low_cut_CreateFcn(hObject, eventdata, handles)
gui_figure=gcf;
var=getappdata(gui_figure,'var');
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
var.low_cut=100;
set(hObject,'string',num2str(var.low_cut));
setappdata(gui_figure,'var',var);

% --- Executes during object creation, after setting all properties.
function high_cut_CreateFcn(hObject, eventdata, handles)
gui_figure=gcf;
var=getappdata(gui_figure,'var');
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
var.high_cut=5000;
set(hObject,'string',num2str(var.high_cut));
setappdata(gui_figure,'var',var);

% --- Executes during object creation, after setting all properties.
function spl_norm_CreateFcn(hObject, eventdata, handles)
gui_figure=gcf;
var=getappdata(gui_figure,'var');
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
var.spl_norm=113;
set(hObject,'string',num2str(var.spl_norm));
setappdata(gui_figure,'var',var);

% --- Executes during object creation, after setting all properties.
function tempo_CreateFcn(hObject, eventdata, handles)
gui_figure=gcf;
var=getappdata(gui_figure,'var');
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
var.tempo=1.0;
set(hObject,'string',num2str(var.tempo));
setappdata(gui_figure,'var',var);

% --- Executes during object creation, after setting all properties.
function gain_CreateFcn(hObject, eventdata, handles)
gui_figure=gcf;
var=getappdata(gui_figure,'var');
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
var.gain=-0;
set(hObject,'string',num2str(var.gain));
setappdata(gui_figure,'var',var);

% --- Executes during object creation, after setting all properties.
function doppler_speed_kts_CreateFcn(hObject, eventdata, handles)
gui_figure=gcf;
var=getappdata(gui_figure,'var');
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
var.doppler_speed_kts=0;
set(hObject,'string',num2str(var.doppler_speed_kts));
setappdata(gui_figure,'var',var);

% --- Executes during object creation, after setting all properties.
function doppler_azimuth_deg_CreateFcn(hObject, eventdata, handles)
gui_figure=gcf;
var=getappdata(gui_figure,'var');
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
var.doppler_azimuth=0;
set(hObject,'string',num2str(var.doppler_azimuth));
setappdata(gui_figure,'var',var);


%-----%-----%-----%-----%-----%-----%-----%-----%-----%----%-
%-----%-----%-----%-----%-----%-----%-----%-----%-----%----%-



% --------------------------------------------------------------------
% ------------------CallBack Functions--------------------------------
% --------------------------------------------------------------------

%-------------------
% Parameter Callbacks
%-------------------
function nfft_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
var.nfft_in=eval(get(hObject,'string'));
setappdata(gui_figure,'var',var);
clear var;
calculate_b_mat(gui_figure);
axes(handles.main_axes);
draw_main_axes(gui_figure);
update_side_plots(gui_figure);

% --------------------------------------------------------------------
function green_percentile_Callback(hObject, eventdata, handles)
gui_figure=gcf;
update_side_plots(gui_figure);
%----------------------------------------------------------
function red_percentile_Callback(hObject, eventdata, handles)
gui_figure=gcf;
update_side_plots(gui_figure);
%----------------------------------------------------------
function blue_percentile_Callback(hObject, eventdata, handles)
gui_figure=gcf;
update_side_plots(gui_figure);

% --------------------------------------------------------------------
function window_type_Callback(hObject, eventdata, handles)
gui_figure=gcf;
var=getappdata(gui_figure,'var');
switch get(hObject,'value')
    case 1
        var.window_type='hanning';
    case 2
        var.window_type='kaiser_bessel';
    case 3
        var.window_type='rectangular';
    case 4
        var.window_type='flat_top';
end;
setappdata(gui_figure,'var',var);
clear var;
calculate_b_mat(gui_figure);
axes(handles.main_axes);
draw_main_axes(gui_figure);
update_side_plots(gui_figure);

% ----------------------------------------------------------
function graph_type_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
axes(handles.main_axes);
var.handles=handles;
setappdata(gui_figure,'var',var);
clear var;
draw_main_axes(gui_figure);

%----------------------------------------------------------
function low_cut_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
var.low_cut=str2double(get(hObject,'string'));
axes(handles.main_axes);
setappdata(gui_figure,'var',var);
clear var;
draw_main_axes(gui_figure);

%----------------------------------------------------------
function high_cut_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
var.high_cut=str2double(get(hObject,'string'));
axes(handles.main_axes);
setappdata(gui_figure,'var',var);
clear var;
draw_main_axes(gui_figure);

%----------------------------------------------------------
function spl_norm_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
var.spl_norm=str2double(get(hObject,'string'));
setappdata(gui_figure,'var',var);

%----------------------------------------------------------
function tempo_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
var.tempo=str2double(get(hObject,'string'));
setappdata(gui_figure,'var',var);

%----------------------------------------------------------
function gain_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
var.gain=eval(get(hObject,'string'));
setappdata(gui_figure,'var',var);
clear var;
calculate_b_mat(gui_figure);
axes(handles.main_axes);
draw_main_axes(gui_figure);
update_side_plots(gui_figure);

%----------------------------------------------------------
function doppler_speed_kts_Callback(hObject, eventdata, handles)
gui_figure=gcf;
var=getappdata(gui_figure,'var');
var.doppler_speed_kts=str2num(get(hObject,'string'));
var.sample_rate=var.original_sample_rate/(1-var.doppler_speed_kts*0.504*cos(var.doppler_azimuth*pi/180)./340);
setappdata(gui_figure,'var',var);
clear var;
calculate_b_mat(gui_figure);
axes(handles.main_axes);
draw_main_axes(gui_figure);
update_side_plots(gui_figure);

%----------------------------------------------------------
function doppler_azimuth_deg_Callback(hObject, eventdata, handles)
gui_figure=gcf;
var=getappdata(gui_figure,'var');
var.doppler_azimuth=str2num(get(hObject,'string'));
var.sample_rate=var.original_sample_rate/(1-var.doppler_speed_kts*0.504*cos(var.doppler_azimuth*pi/180)./340);
setappdata(gui_figure,'var',var);
clear var;
calculate_b_mat(gui_figure);
axes(handles.main_axes);
draw_main_axes(gui_figure);
update_side_plots(gui_figure);


%-------------------
% Axes & Graphs Callbacks
%-------------------
%-------------------------------------------------------
function main_axes_click_callback(varargin)
gui_figure=gcf;
update_side_plots(gui_figure);

% ----------------------------------------------------------
function x_axes_click_callback(varargin)
gui_figure=gcf;
var=getappdata(gui_figure,'var');
x_out=figure;
figure(x_out);
set(gcf,'units','normalized','position',[1 1 1 1]);
plot(var.t_vec(1:size(var.graph,2)),var.graph(var.f_ind,:),'LineWidth',2);
title(['Time Dependance on ' num2str(var.f_vec(var.f_ind),'%.1f') ' Hz (' var.title_s ')']);
axis tight;

% ----------------------------------------------------------
function y_axes_click_callback(varargin)
gui_figure=gcf;
var=getappdata(gui_figure,'var');
y_out=figure;
figure(y_out);
set(gcf,'units','normalized','position',[1 1 1 1]);
plot(var.f_vec(var.first_f:var.last_f),var.graph(var.first_f:var.last_f,var.t_ind),'r','LineWidth',2);%%%%% changed to red by orel
title(['Frequency Dependance on the ' num2str(var.t_vec(var.t_ind),'%.1f') ' Sec (' var.title_s ')']);
axis tight;
% figure(gui_figure);

% ----------------------------------------------------------
function p_density_axes_click_callback(varargin)
gui_figure=gcf;
var=getappdata(gui_figure,'var');
p_out=figure;
figure(p_out);
set(gcf,'units','normalized','position',[1 1 1 1]);
kde_numel=32;
data_vec=var.graph(var.f_ind,:);
data_vec=repmat(data_vec(:),1,5); %%%% WARNING : REPMAT FOR ACCURATE KDE
[bandwidth,density,xmesh]=kde(data_vec,kde_numel);  %#ok<ASGLU>
plot(xmesh,density,'LineWidth',2,'color','b');
axis tight;
axes_prob=gca;
axes_integral = axes('Position',get(gca,'Position'),'XAxisLocation','bottom','YAxisLocation','right','Color','w','XColor','k','YColor','r');
line(xmesh,cumsum(density)*(xmesh(end)-xmesh(1))/kde_numel,'Color','r','Parent',axes_integral,'linewidth',2);
axis tight;
axes(axes_prob); set(gca,'color','none');

title(['Stastistics at ' num2str(var.f_vec(var.f_ind),'%.1f') ' Hz (' var.title_s ')']);
axis tight;

% ----------------------------------------------------------
function time_mean_axes_click_callback(varargin)
gui_figure=gcf;
var=getappdata(gui_figure,'var');
try
    y_out = figure('name',char(var.main_title(1)));
catch 
    y_out = figure;
end
figure(y_out); hold on;
% set(gcf,'units','normalized','position',[1 1 1 1]);
plot(var.stats.f_vec,var.stats.high_per_vec,'LineWidth',2,'color','r');
plot(var.stats.f_vec,var.stats.med_per_vec,'LineWidth',2,'color','b');
plot(var.stats.f_vec,var.stats.low_per_vec,'LineWidth',2,'color','g');
plot(var.stats.f_vec,var.stats.average_std,'LineWidth',2,'color','k');
title(['Red ' get(var.handles.red_percentile,'string') '% Blue ' get(var.handles.blue_percentile,'string') '% Green ' get(var.handles.green_percentile,'string') '% (' var.title_s ')']);
set(gca,'xscale','log');
axis tight; grid on;

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
function red_text_ButtonDownFcn(hObject, eventdata, handles)
time_mean_axes_click_callback;
delete(findobj('parent',gca,'color','b'));
delete(findobj('parent',gca,'color','g'));

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
function blue_text_ButtonDownFcn(hObject, eventdata, handles)
time_mean_axes_click_callback;
delete(findobj('parent',gca,'color','r'));
delete(findobj('parent',gca,'color','g'));

% --- If Enable == 'on', executes on mouse press in 5 pixel border.
function green_text_ButtonDownFcn(hObject, eventdata, handles)
time_mean_axes_click_callback;
delete(findobj('parent',gca,'color','r'));
delete(findobj('parent',gca,'color','b'));


%-------------------
% Button Callbacks
%-------------------

%-------------------------------------------------------
function crop_button_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
% the control part
% stop;
mode = questdlg('Crop or Block?','Cropper','Crop','Block','Crop');
%         helpdlg('Zoom in and press a key when ready');
axes(handles.main_axes);
[box_x,box_y]=ginput(2);
box_fmin=min(box_y);
box_fmax=max(box_y);
box_tmin=min(box_x);
box_tmax=max(box_x);
box_f=(var.f_vec<=box_fmax & var.f_vec>=box_fmin);
box_t=(var.t_vec<=box_tmax & var.t_vec>=box_tmin)';
switch mode
    case 'Crop'
        b_box=var.b_mat(:,(find(box_t))).*box_f(:,ones(1,length(find(box_t))));
    case 'Block'
        box_i=box_t(ones(length(box_f),1),:).*box_f(:,ones(1,length(box_t)));
        b_box=var.b_mat.*(box_i==0);
    otherwise
        b_box=var.b_mat;
end
new_sig = inverse_specgram(b_box,var.nfft_in,var.window_type,round(var.nfft_in*0.8));
new_sample_rate=var.sample_rate;
setappdata(gui_figure,'var',var);
clear var;
signal_analyzer(new_sig,new_sample_rate);


%-------------------------------------------------------
function crop_time_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
% the control part
% stop;
mode = questdlg('Crop or Block?','Cropper','Crop','Block','Crop');
%         helpdlg('Zoom in and press a key when ready');
axes(handles.main_axes);
[box_x,box_y]=ginput(2); %#ok<ASGLU>
% box_fmin=min(box_y);
% box_fmax=max(box_y);
box_tmin=min(box_x);
box_tmax=max(box_x);
box_f=ones(size(var.f_vec)); %(var.f_vec<=box_fmax & var.f_vec>=box_fmin);
box_t=(var.t_vec<=box_tmax & var.t_vec>=box_tmin)';
switch mode
    case 'Crop'
        b_box=var.b_mat(:,(find(box_t))).*box_f(:,ones(1,length(find(box_t))));
    case 'Block'
        box_i=box_t(ones(length(box_f),1),:).*box_f(:,ones(1,length(box_t))); %#ok<NASGU>
        b_box=var.b_mat;
        b_box(:,find(box_t))=[]; %#ok<FNDSB>
    otherwise
        b_box=var.b_mat;
end;
new_sig = inverse_specgram(b_box,var.nfft_in,var.window_type,round(var.nfft_in*0.8));
new_sample_rate=var.sample_rate;
setappdata(gui_figure,'var',var);
clear var;
signal_analyzer(new_sig,new_sample_rate);

%-------------------------------------------------------
function export_plots_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
if ~isempty(var.t_ind)
    sig_out=figure;
    figure(sig_out);
    set(gcf,'units','normalized','position',[1 1 1 1]);
    plot(var.signal(round(var.t_vec(var.t_ind)*var.sample_rate):round(var.t_vec(var.t_ind)*var.sample_rate)+var.nfft_in).*10^(var.gain/20));
    title(['The signal : ' num2str(var.t_vec(var.t_ind)) ' to ' num2str(var.t_vec(var.t_ind)+var.nfft_in/var.sample_rate)]);
    axis tight;
end;

%-------------------------------------------------------
function play_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
switch get(hObject,'String')
    case 'Play'
        if ~isempty(findobj('Color','r','LineWidth',3)) delete(findobj('Color','r','LineWidth',3)); end;
        set(hObject,'string','Stop');
        sample_time=1/(var.sample_rate*var.tempo);
        if isfield(var,'t_ind') sample_time=var.t_vec(var.t_ind); end;
        if isnan(var.spl_norm)
            var.au=audioplayer(var.signal.*10^(var.gain/20)/min([max(abs(var.signal.*10^(var.gain/20))) 10.^(125/20)]),round((var.sample_rate*var.tempo)));
        else
            var.au=audioplayer(var.signal.*10^(var.gain/20)/10.^(var.spl_norm/20),round((var.sample_rate*var.tempo)));
        end
        setappdata(gui_figure,'var',var);
        play(var.au,sample_time*var.sample_rate);
        h_main_line=[]; h_side_line=[];
        while isplaying(var.au)
            sample_time=get(var.au,'CurrentSample')/var.sample_rate;
            target_time=var.t_vec(find(abs(var.t_vec-sample_time)==min(abs(var.t_vec-sample_time))))-var.nfft_in/(2*var.sample_rate); %#ok<FNDSB>
            target_time=target_time(1);
            axes(handles.main_axes);
            delete(h_main_line);
            h_main_line=line([target_time target_time],get(gca,'YLim'),'Color','r','LineWidth',3);
            var.t_ind=find(abs(var.t_vec-target_time)==min(abs(var.t_vec-target_time)));
            var.t_ind=var.t_ind(1);
            setappdata(gui_figure,'var',var);
            axes(var.handles.y_axes);
            plot(var.graph(var.first_f:var.last_f,var.t_ind),var.f_vec(var.first_f:var.last_f),'LineWidth',2);
            axis tight;
            set(var.handles.y_axes,'Xdir','reverse');
            set(var.handles.y_axes,'ButtonDownFcn',@y_axes_click_callback);

            axes(handles.x_axes);
            if isfield(var,'t_ind')
                delete(h_side_line);
                h_side_line=line([target_time target_time],get(gca,'YLim'),'Color','r','LineWidth',3);
            end;
            pause(0.1);
            if abs(length(var.signal.*10^(var.gain/20))/var.sample_rate-sample_time)<=0.3
                stop(var.au);
                if ~isplaying(var.au)
                    play(var.au);
                end
%                 set(hObject,'string','Play');
%                 break
            end;
        end;
    case 'Stop'
        set(hObject,'string','Play');
        if isfield(var,'au'); stop(var.au); end;
        %         if ~isempty(findobj('Color','r','LineWidth',3)) delete(findobj('Color','r','LineWidth',3)); end;
end;
setappdata(gui_figure,'var',var);

%-------------------------------------------------------
function custom_crop_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
% the control part
mode = questdlg('Crop or Block?','Cropper','Crop','Block','Crop');
axes(handles.main_axes);
hold on;

xy = [];
n = 0;
h_point=[];
hlp=helpdlg('Select Top border (right - undo , "ENTER" to finish)');
waitfor(hlp);
top_line=[];
but = 1;
while but <= 3
    [xi,yi,but] = ginput(1);
    if isempty(but); break; end

    if but == 3 && ishandle(h_point)
        delete(h_point);
        n = n-1;
        xy = xy(:, 1:n);
        if n > 1; delete(top_line); end
    else
        h_point = plot(xi,yi,'wo','MarkerFaceColor','w');
        n = n+1;
        xy(:,n) = [xi;yi];
    end

    if (n > 2 && ishandle(top_line)); delete(top_line); end
    % Plot the interpolated curve.
    if n > 1
        % Interpolate with a spline curve and finer spacing.
        top_y = interp1(xy(1, :), xy(2, :), var.t_vec(:), 'pchip');
        top_line = plot(var.t_vec,top_y,'w-','LineWidth',2);
    end
end

xy = [];
n = 0;
h_point=[];
hlp=helpdlg('Select Bottom border (right - undo , "ENTER" to finish)');
waitfor(hlp);
bottom_line=[];
but = 1;
while but <= 3
    [xi,yi,but] = ginput(1);
    if isempty(but); break; end

    if but == 3 && ishandle(h_point)
        delete(h_point);
        n = n-1;
        xy = xy(:, 1:n);
        if n > 1; delete(bottom_line); end
    else
        h_point = plot(xi,yi,'wo','MarkerFaceColor','w');
        n = n+1;
        xy(:,n) = [xi;yi];
    end

    if (n > 2 && ishandle(bottom_line)) delete(bottom_line); end
    % Plot the interpolated curve.
    if n > 1
        % Interpolate with a spline curve and finer spacing.
        bottom_y = interp1(xy(1, :), xy(2, :), var.t_vec(:), 'pchip');
        bottom_line = plot(var.t_vec,bottom_y,'w-','LineWidth',2);
    end
end
hold off;

top_mat=top_y(:,ones(1,length(var.f_vec)))';
bottom_mat=bottom_y(:,ones(1,length(var.f_vec)))';
selection_i=var.f_vec(:,ones(1,length(var.t_vec)));
selection_i=(selection_i>=bottom_mat).*(selection_i<=top_mat);

switch mode
    case 'Crop'
        b_box=var.b_mat.*(selection_i==1);
    case 'Block'
        b_box=var.b_mat.*(selection_i==0);
    otherwise
        b_box=var.b_mat;
end;

new_sig = inverse_specgram(b_box,var.nfft_in,var.window_type,round(var.nfft_in*0.8));
new_sample_rate=var.sample_rate;
setappdata(gui_figure,'var',var);
clear var;
signal_analyzer(new_sig,new_sample_rate);


%-------------------------------------------------------
function save_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
[FileName,PathName] = uiputfile;%([var.main_title '.mat'],'Save');
% name = inputdlg('File name','Save',1,{var.main_title});
var.main_title=FileName;
set(gui_figure,'Name',var.main_title);
save([PathName var.main_title],'var');
setappdata(gui_figure,'var',var);

%-------------------------------------------------------
function load_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
[FileName,PathName] = uigetfile;
try 
    load([PathName FileName],'var');
    set(gui_figure,'Name',var.main_title);
    var.handles=handles;
    axes(handles.main_axes);
    setappdata(gui_figure,'var',var);
    clear var;
    draw_main_axes(gui_figure);
    update_side_plots(gui_figure);
    update_state(gui_figure)
catch
    var.signal=rand(1,10000)*eps; 
    var.sample_rate=10000;
    var.handles=handles;
    setappdata(gui_figure,'var',var);
    calculate_b_mat(gui_figure);
    axes(handles.main_axes);
    draw_main_axes(gui_figure);
    update_side_plots(gui_figure);
    update_state(gui_figure)
end

%-------------------------------------------------------
function save_wave_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
[FileName,PathName] = uiputfile;
var.main_title=FileName;
set(gui_figure,'Name',var.main_title);
signal_vec=(var.signal).*10^(var.gain/20);
maxamp=20*log10(max(abs(signal_vec)));
audiowrite(signal_vec/(max(abs(signal_vec))+eps),var.sample_rate,32,[PathName var.main_title '_cl' num2str(maxamp,'%.1f') '.wav']);

%-------------------------------------------------------
function load_wave_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
[FileName,PathName] = uigetfile('*.*');
[y,Fs,bits] = audioread([PathName FileName]);
k=strfind(FileName, '_cl');
if ~isempty(k)
    maxamp=10^(str2num(FileName((k(end)+3):end-4))/20);
else
    maxamp=1;
end
var.sample_rate=Fs;
var.signal=y(:,1)'.*maxamp; %only first channel
var.main_title=FileName;
set(gui_figure,'Name',var.main_title);
axes(handles.main_axes);
setappdata(gui_figure,'var',var);
calculate_b_mat(gui_figure);
draw_main_axes(gui_figure);
update_side_plots(gui_figure);
update_state(gui_figure)

%------------------------------------
function name_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
name = inputdlg('Figure name','Name',1,{var.main_title});
var.main_title=name{1};
set(gui_figure,'Name',var.main_title);
setappdata(gui_figure,'var',var);


% --------------------------------------------------------------------
% ------------------Independent Functions----------------------------
% --------------------------------------------------------------------

% --------------------------------------------------------------------
function calculate_b_mat(gui_figure)
var=getappdata(gui_figure,'var');
[var.b_mat,var.f_vec,var.t_vec]=specgram_proper(var.signal.*10^(var.gain/20),var.nfft_in,var.sample_rate,var.window_type,round(var.nfft_in*0.8));
setappdata(gui_figure,'var',var);

% --------------------------------------------------------------------
function draw_main_axes(gui_figure)
var=getappdata(gui_figure,'var');
contents = get(var.handles.graph_type,'String');
var.title_s=contents{get(var.handles.graph_type,'Value')};
var.selected_tag=contents{get(var.handles.graph_type,'Value')};
setappdata(gui_figure,'var',var);
selected_tag=var.selected_tag;
clear var;
switch selected_tag   
    case 'specgram dB'
        spec_plot(gui_figure);
    case 'specgram dBA'
        spec_plot_dba(gui_figure);
    case 'integral dB'
        spec_plot_integral(gui_figure);
    case 'integral dBA'
        spec_plot_integral_dba(gui_figure);
    case 'PCA+CCP'
        noise_rm(gui_figure);
    case 'PCA+energyCPP'
        noise_and_EnergyDetector(gui_figure)
end
var=getappdata(gui_figure,'var');
set(var.image,'ButtonDownFcn',@main_axes_click_callback);
% var.image=surf(var.t_vec,var.f_vec(var.first_f:var.last_f),zeros(size(var.graph(var.first_f:var.last_f,:))),var.graph(var.first_f:var.last_f,:));
% shading interp
% set(gca,'yscale','log');
% view(2)
% axis tight; axis xy;
% set(var.image,'ButtonDownFcn',@main_axes_click_callback);
if isfield(var,'f_ind') 
    clear var;
    update_side_plots(gui_figure); 
end;
% --------------------------------------------------------------------

%----%----%----%----%----%----%----%----%
function spec_plot(gui_figure)
var=getappdata(gui_figure,'var');
stft_mag = abs(var.b_mat);
var.first_f=length(find(var.f_vec<=var.low_cut));
var.last_f=length(find(var.f_vec<=var.high_cut));
spl=20*log10(stft_mag+eps);

var.first_f=length(find(var.f_vec<=var.low_cut));
var.last_f=length(find(var.f_vec<=var.high_cut));
var.graph=spl;
var.image=imagesc(var.t_vec,var.f_vec(var.first_f:var.last_f),spl(var.first_f:var.last_f,:));
caxis([min([20 max(max(spl))-40]) max(max(spl))]);
axis tight; axis xy;
setappdata(gui_figure,'var',var);

%----%----%----%----%----%----%----%----%
function noise_rm(gui_figure)

var=getappdata(gui_figure,'var');
stft_mag = abs(var.b_mat);
noise_clean = NoiseCleaning();
var.first_f=length(find(var.f_vec<=var.low_cut));
var.last_f=length(find(var.f_vec<=var.high_cut));
% assign parameters to cleaning code
pca_num = 1; 
energy_percentiel = 95;
cc_min_size = 50;
entropy_thresh = 1;
spl_temp = noise_clean.PCA_mag(stft_mag, pca_num, var.first_f, var.last_f);
CC = noise_clean.cpp(spl_temp, energy_percentiel, cc_min_size);  % spl, percentile of power thershold, min cc size
spl = noise_clean.final_display(mag2db(abs(stft_mag)), CC, entropy_thresh); % spl, CC, highest entropy to display
stft_mag = 10.^(spl/20);
b_box = stft_mag.*exp(1i*angle(var.b_mat));
new_sig = inverse_specgram(b_box,var.nfft_in,var.window_type,round(var.nfft_in*0.8));

var.graph = spl;
var.signal=new_sig;
var.image=imagesc(var.t_vec,var.f_vec(var.first_f:var.last_f),spl(var.first_f:var.last_f,:));
caxis([min([20 max(max(spl))-40]) max(max(spl))]);

axis tight; axis xy;

setappdata(gui_figure,'var',var);

%----%----%----%----%----%----%----%----%
function noise_and_EnergyDetector(gui_figure)

var=getappdata(gui_figure,'var');
stft_mag = abs(var.b_mat);
noise_clean = NoiseCleaning();
var.first_f=length(find(var.f_vec<=var.low_cut));
var.last_f=length(find(var.f_vec<=var.high_cut));
spl_temp = noise_clean.PCA_mag(stft_mag, 1, var.first_f, var.last_f);
CC = noise_clean.cpp(spl_temp, 90, 50);  % spl, percentile of power thershold, min cc size
spl = noise_clean.marked_cc_after_energy(mag2db(abs(stft_mag)), CC, 0.9); % spl, CC, 90% energy
var.image=imagesc(var.t_vec,var.f_vec(var.first_f:var.last_f),spl(var.first_f:var.last_f,:));
caxis([min([20 max(max(spl))-40]) max(max(spl))]);

axis tight; axis xy;

setappdata(gui_figure,'var',var);
%----%----%----%----%----%----%----%----%
function spec_plot_dba(gui_figure)
var=getappdata(gui_figure,'var');
dba_vec=dba(var.f_vec);
dba_vec=dba_vec(:);
spl_dba=20*log10(abs(var.b_mat).*10.^(dba_vec(:,ones(1,size(var.b_mat,2)))/20)+eps);
var.first_f=length(find(var.f_vec<=var.low_cut));
var.last_f=length(find(var.f_vec<=var.high_cut));
var.graph=spl_dba;
var.image=imagesc(var.t_vec,var.f_vec(var.first_f:var.last_f),spl_dba(var.first_f:var.last_f,:));
caxis([min([20 max(max(spl_dba))-40]) max(max(spl_dba))]);
%     title(var.title_s);
axis tight; axis xy;
setappdata(gui_figure,'var',var);

%----%----%----%----%----%----%----%----%
function spec_plot_integral(gui_figure)
var=getappdata(gui_figure,'var');
b_en=(var.b_mat.^2);
var.first_f=length(find(var.f_vec<=var.low_cut));
var.last_f=length(find(var.f_vec<=var.high_cut));
b_energy=cumsum(abs(b_en),1);
b_energy=10*log10(b_energy+eps);
var.graph=b_energy;
var.image=imagesc(var.t_vec,var.f_vec(var.first_f:var.last_f),b_energy(var.first_f:var.last_f,:));
caxis([min([max(max(b_energy(var.first_f:var.last_f,:)))-40 15]) max(max(b_energy))]);
%     title(var.title_s);
axis tight; axis xy;
setappdata(gui_figure,'var',var);

%----%----%----%----%----%----%----%----%
function spec_plot_integral_dba(gui_figure)
var=getappdata(gui_figure,'var');
dba_vec=dba(var.f_vec);
dba_vec=dba_vec(:);
b_en=abs(var.b_mat).*10.^(dba_vec(:,ones(1,size(var.b_mat,2)))/20);
var.first_f=length(find(var.f_vec<=var.low_cut));
var.last_f=length(find(var.f_vec<=var.high_cut));
b_energy=cumsum(b_en.^2,1);
b_energy=10*log10(b_energy+eps);
var.graph=b_energy;
var.image=imagesc(var.t_vec,var.f_vec(var.first_f:var.last_f),b_energy(var.first_f:var.last_f,:));
caxis([min([max(max(b_energy(var.first_f:var.last_f,:)))-40 15]) max(max(b_energy))]);
%     title(var.title_s);
axis tight; axis xy;
setappdata(gui_figure,'var',var);
%----%----%----%----%----%----%----%----%

%----%----%----%----%----%----%----%----%
function dBA_vec = dba(freq_vec)
f_vec = [25 31.5 40 50 63 80 100 125 160 200 250 315 400 500 630 800 1000 1250 1600 2000 2500 3150 4000 5000 6300 8000 10000];
a_vec = [-44.7 -39.4 -34.6 -30.2 -26.2 -22.5 -19.1 -16.1 -13.4 -10.9 -8.6 -6.6 -4.8 -3.2 -1.9 -0.8 0.0 0.6 1.0 1.2 1.3 1.2 1.0 0.5 -0.1 -1.1 -2.5];
dBA_vec = interp1(f_vec, a_vec, freq_vec, 'spline','extrap');

%----%----%----%----%----%----%----%----%
function update_side_plots(gui_figure)
var=getappdata(gui_figure,'var');
if ~isempty(findobj(gui_figure,'Color','r','LineWidth',3)); delete(findobj(gui_figure,'Color','r','LineWidth',3)); end;
c_point=get(var.handles.main_axes,'CurrentPoint');
c_x=c_point(2,1); c_y=c_point(2,2);
f_ind=find(abs(var.f_vec-c_y)==min(abs(var.f_vec-c_y)));
t_ind=find(abs(var.t_vec-c_x)==min(abs(var.t_vec-c_x)));
var.f_ind=f_ind(1);
var.t_ind=t_ind(1);
set(var.handles.point_value,'string',num2str(var.graph(var.f_ind,var.t_ind)));
set(var.handles.point_coord,'string',['( ' num2str(var.t_vec(var.t_ind),'%.2f') ' , ' num2str(var.f_vec(var.f_ind),'%.2f') ' )']);
% main axes
axes(var.handles.main_axes);
h_lines=findobj(gui_figure,'Color','w','LineWidth',2);
if ~isempty(h_lines) delete(h_lines); end;
var.hor_line=line(get(gca,'XLim'),[var.f_vec(var.f_ind) var.f_vec(var.f_ind)],'Color','w','LineWidth',2);
var.ver_line=line([var.t_vec(var.t_ind) var.t_vec(var.t_ind)],get(gca,'YLim'),'Color','w','LineWidth',2);
% x axes
axes(var.handles.x_axes);
plot(var.t_vec(1:size(var.graph,2)),var.graph(var.f_ind,:),'LineWidth',2);
axis tight;
set(var.handles.x_axes,'ButtonDownFcn',@x_axes_click_callback);
% y axes
axes(var.handles.y_axes);
plot(var.graph(var.first_f:var.last_f,var.t_ind),var.f_vec(var.first_f:var.last_f),'LineWidth',2);
axis tight;
try
    set(gca,'xlim',[max([max(var.graph(var.first_f:var.last_f,var.t_ind))-60 min(var.graph(var.first_f:var.last_f,var.t_ind))]) max(var.graph(var.first_f:var.last_f,var.t_ind))]);
catch
    ;
end  
set(var.handles.y_axes,'Xdir','reverse');
set(var.handles.y_axes,'ButtonDownFcn',@y_axes_click_callback);
% prob axes
axes(var.handles.p_density_axes);
kde_numel=32;
data_vec=var.graph(var.f_ind,:);
data_vec=repmat(data_vec(:),1,5); %%%% WARNING : REPMAT FOR ACCURATE KDE
[bandwidth,density,xmesh]=kde(data_vec,kde_numel); 
plot(xmesh,density,'LineWidth',2,'color','b');
axis tight;
set(var.handles.p_density_axes,'ButtonDownFcn',@p_density_axes_click_callback);
set(var.handles.p_integral_axes,'ButtonDownFcn',@p_density_axes_click_callback);
% integral axes
axes(var.handles.p_integral_axes);
cla;
set(var.handles.p_integral_axes,'XAxisLocation','bottom','YAxisLocation','right','Color','none','XColor','k','YColor','r');
prob_integral=cumsum(density)*(xmesh(end)-xmesh(1))/kde_numel;
line(xmesh,prob_integral,'Color','r','Parent',var.handles.p_integral_axes,'linewidth',2);
axis tight;
% stats update
set(var.handles.mean_val,'string',num2str(mean(var.graph(var.f_ind,:)) ,'%.2f'));
set(var.handles.std_val,'string',num2str(std(var.graph(var.f_ind,:)) ,'%.2f'));
set(var.handles.low_percentile,'string',num2str( xmesh(find((abs(prob_integral-0.1))==min(abs(prob_integral-0.1)))),'%.2f'));
set(var.handles.high_percentile,'string',num2str( xmesh(find((abs(prob_integral-0.9))==min(abs(prob_integral-0.9)))),'%.2f'));
% time mean axes
axes(var.handles.time_mean_axes); cla; hold on;
data_mat=sort(var.graph(var.first_f:var.last_f,:),2);
high_per=ceil(0.01*str2num(get(var.handles.red_percentile,'string'))*size(data_mat,2));
med_per=ceil(0.01*str2num(get(var.handles.blue_percentile,'string'))*size(data_mat,2));
low_per=ceil(0.01*str2num(get(var.handles.green_percentile,'string'))*size(data_mat,2));
%
var.stats.high_per=get(var.handles.red_percentile,'string');
var.stats.med_per=get(var.handles.blue_percentile,'string');
var.stats.low_per=get(var.handles.green_percentile,'string');
var.stats.f_vec=var.f_vec(var.first_f:var.last_f);
var.stats.high_per_vec=data_mat(:,high_per);
var.stats.med_per_vec=data_mat(:,med_per);
var.stats.low_per_vec=data_mat(:,low_per);
var.stats.average_std=std(data_mat,0,2);
var.stats.graph_type=var.selected_tag;
%
plot(var.f_vec(var.first_f:var.last_f),data_mat(:,high_per),'LineWidth',1,'color','r');
plot(var.f_vec(var.first_f:var.last_f),data_mat(:,med_per),'LineWidth',1,'color','b');
plot(var.f_vec(var.first_f:var.last_f),data_mat(:,low_per),'LineWidth',1,'color','g');
plot(var.f_vec(var.first_f:var.last_f),var.stats.average_std,'LineWidth',1,'color','k');
set(gca,'xscale','log');
axis tight; grid on; hold off;
set(var.handles.time_mean_axes,'ButtonDownFcn',@time_mean_axes_click_callback);
setappdata(gui_figure,'var',var);

%----%----%----%----%----%----%----%----%
function update_state(gui_figure)
var=getappdata(gui_figure,'var');
set(var.handles.nfft,'string',num2str(var.nfft_in));
set(var.handles.low_cut,'string',num2str(var.low_cut));
set(var.handles.high_cut,'string',num2str(var.high_cut));
set(var.handles.graph_type,'value',strmatch(var.selected_tag,get(var.handles.graph_type,'string'),'exact'));


%-----%-----%-----%-----%-----%-----%-----%-----%-----%----%-
%-----%-----%-----%-----%-----%-----%-----%-----%-----%----%-


% --- Executes during object creation, after setting all properties.
function y_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to y_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate y_axes


% --- Executes on mouse press over axes background.
function time_mean_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to time_mean_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in hpf.
function hpf_Callback(hObject, eventdata, handles)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
mode = questdlg('Crop or Block?','Cropper','Crop','Block','Crop');
box_f=(var.f_vec<=50 & var.f_vec>=-2);
box_t=(var.t_vec<=1000 & var.t_vec>=0.00001)';
switch mode
    case 'Crop'
        b_box=var.b_mat(:,(find(box_t))).*box_f(:,ones(1,length(find(box_t))));
    case 'Block'
        box_i=box_t(ones(length(box_f),1),:).*box_f(:,ones(1,length(box_t)));
        b_box=var.b_mat.*(box_i==0);
    otherwise
        b_box=var.b_mat;
end
new_sig = inverse_specgram(b_box,var.nfft_in,var.window_type,round(var.nfft_in*0.8));
new_sample_rate=var.sample_rate;
setappdata(gui_figure,'var',var);
clear var;
signal_analyzer(new_sig,new_sample_rate);

% --- Executes on button press in bounding_boxes.
function bounding_boxes_Callback(hObject, eventdata, handles)

gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
stft_mag = abs(var.b_mat);
noise_clean = NoiseCleaning();
var.first_f=length(find(var.f_vec<=var.low_cut));
var.last_f=length(find(var.f_vec<=var.high_cut));
% assign parameters to cleaning code
pca_num = 1; 
energy_percentiel = 95;
cc_min_size = 50;
entropy_thresh = 1;
spl_temp = noise_clean.PCA_mag(stft_mag, pca_num, var.first_f, var.last_f);
CC = noise_clean.cpp(spl_temp, energy_percentiel, cc_min_size);  % spl, percentile of power thershold, min cc size
spl = noise_clean.marked_cc_mag(mag2db(abs(stft_mag)), CC, entropy_thresh); % spl, CC, highest entropy to display

var.image=imagesc(var.t_vec,var.f_vec(var.first_f:var.last_f),spl(var.first_f:var.last_f,:));
caxis([min([20 max(max(spl))-40]) max(max(spl))]);

axis tight; axis xy;

setappdata(gui_figure,'var',var);


% --- Executes on button press in doc_biosignals.
function doc_biosignals_Callback(hObject, eventdata, handles)
% hObject    handle to doc_biosignals (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
gui_figure=handles.figure1;
var=getappdata(gui_figure,'var');
pathforsave = uigetdir(cd, 'Please choose path for saving .txt files');
relevant_string=strcat(char(var.main_title{4}),num2str(clock),'.txt');
fid = fopen( [pathforsave filesep relevant_string], 'wt' );

FS = stoploop({'Choose the two corners of the boxes containing the signal one after another', 'press enter in text box when finished'}) ; 
while(~FS.Stop()) 
    axes(handles.main_axes);
    [box_x,box_y, button]=ginput(2);
    if FS.Stop()
        break
    end
    box_fmin=min(box_y);
    box_fmax=max(box_y);
    box_tmin=min(box_x);
    box_tmax=max(box_x);
    [~,box_fmin_up_ind]=min(abs( (var.f_vec-box_fmin)));
    box_fmin_up=var.f_vec(box_fmin_up_ind);
    [~,box_fmax_up_ind]=min(abs( (var.f_vec-box_fmax)));
    box_fmax_up=var.f_vec(box_fmax_up_ind);
    [~,box_tmin_up_ind]=min(abs( (var.t_vec-box_tmin)));
    box_tmin_up=var.t_vec(box_tmin_up_ind);
    [~,box_tmax_up_ind]=min(abs( (var.t_vec-box_tmax)));
    box_tmax_up=var.t_vec(box_tmax_up_ind);

    if button(1) == 3 || button(2) == 3
        fprintf(fid, 'social call \n');
    end
    fprintf(fid, [ num2str(box_fmin_up) ' ' num2str(box_fmax_up) '\n'  num2str(box_tmin_up) ' ' num2str(box_tmax_up) '\n']);
end 
fprintf(fid, ['high cut' ''  num2str(var.high_cut) '\n']);
fprintf(fid, ['low cut' ''  num2str(var.low_cut) '\n']);
fprintf(fid, ['nfft' ''  num2str(var.nfft_in) '\n']);
fprintf(fid, ['window type' ''  num2str(var.window_type) '\n']);
FS.Clear() ; % Clear up the box 
clear FS ; % this structure has no use anymore
fclose(fid);
