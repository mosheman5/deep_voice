function sOut = linkCPanel(sIn, fieldName, sField, varargin)
%this is main linker of sCPanel object

if nargin == 2
    sOut = outLink(sIn, fieldName);
elseif nargin == 3 && ~isempty(fieldName);
    sOut = inLink(sIn, fieldName, sField);
elseif mod(nargin, 2) == 0 %all even inputs starting from 4...
    %now, next line is tricky: varargin = {sField, varargin{:}}
    sOut = outLink(sIn, fieldName, sField, varargin{:});
else
    %Just preform overriding
    sOut = overLink(sIn, varargin{:}); 
end
    

function outField = outLink(struct, fieldWanted, varargin)

if isfield(struct, fieldWanted)
    %link this field
else
    %create this feild
end

switch fieldWanted;
case 'sSignal'
    outField=struct.sSignal;

case 'sFFT'
    outField = struct.sFFT;
    
    outField.Signal_vec = struct.sSignal.Signal_vec;
    outField.SampleRate = struct.sSignal.SampleRate;
    outField.channelCaliboartion = struct.sSignal.channelCaliboartion;
    
case 'sMap'
    outField=struct.sMap;
    
    outField.Signal_vec = struct.sSignal.Signal_vec;
    outField.SampleRate = struct.sSignal.SampleRate;
    outField.WindowStartTime = struct.sSignal.WindowStartTime;
    outField.WindowEndTime = struct.sSignal.WindowEndTime;
    outField.channelCaliboartion = struct.sSignal.channelCaliboartion;
    outField.fftResolution = struct.sFFT.fftResolution;
        
otherwise    
    disp('not known field-wanted');
end

outField = overLink(outField, varargin{:});
%**************************************************************************


%**************************************************************************
function struct=inLink(struct, fieldWanted, value)
% to avoid working with whole structure, this procedure inserts-back only the fields necessary for the work of a certain function, and drops it back to the user
% especially while using DSPControlPanel and like
%
% syntax: inLink(struct, value, fieldWanted)
%
% sturct is usually the SCPanel structure
% field wanted is the string-name of the mini-structure that was wanted for the specific work
% value is the updated mini-structure to be inserted back into struct
%
% see also: outLink

switch fieldWanted;
    case 'sSignal'
        struct.sSignal=value;
    
    case 'sFFT'
        struct.sFFT = value;
        
    case 'sMap'
        struct.sMap=value;
        
    otherwise    
        disp('not known field-wanted');
end
%**************************************************************************


%**************************************************************************
function outField = overLink(outField, varargin)

if ~isempty(varargin)
    input_cell = varargin;
    input_length = length(input_cell);
    
    for i = 1:2:input_length
        if isfield(outField, input_cell{i})
            outField = setfield(outField, input_cell{i}, input_cell{i+1});
        else
            warning(['No such field: ' input_cell{i}]);
        end
    end
end
%**************************************************************************