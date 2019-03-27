function [yo,fo,to] = specgram_proper(varargin)
%SPECGRAM Calculate spectrogram from signal.
% WARNING: the hanning window is corrected for energy conservation
% purposes!! 
% Input: everything (signal,nfft,samplerate,nwind.noverlap)
%   modified to give properly calibrated vaules.
%   taken out of the 6.5 SP toolbox, gives complex values,
%   energy(not in db) for versatility (inverse specgram) but normalized
%   uses hanning window for the fft.


error(nargchk(1,5,nargin))
[msg,x,nfft,Fs,window,noverlap]=specgramchk(varargin);
error(msg)
    
nx = length(x);
nwind = length(window);
if nx < nwind    % zero-pad x if it has length less than the window length
    x(nwind)=0;  nx=nwind;
end
x = x(:); % make a column vector for ease later
window = window(:); % be consistent with data set

ncol = fix((nx-noverlap)/(nwind-noverlap));
colindex = 1 + (0:(ncol-1))*(nwind-noverlap);
rowindex = (1:nwind)';
if length(x)<(nwind+colindex(ncol)-1)
    x(nwind+colindex(ncol)-1) = 0;   % zero-pad x
end

if length(nfft)>1
    df = diff(nfft);
    evenly_spaced = all(abs(df-df(1))/Fs<1e-12);  % evenly spaced flag (boolean)
    use_chirp = evenly_spaced & (length(nfft)>20);
else
    evenly_spaced = 1;
    use_chirp = 0;
end

if (length(nfft)==1) || use_chirp
    y = zeros(nwind,ncol);

    % put x into columns of y with the proper offset
    % should be able to do this with fancy indexing! 
    y(:) = x(rowindex(:,ones(1,ncol))+colindex(ones(nwind,1),:)-1);
    % some crazy ass fancy indexing indeed!

    % Apply the window to the array of offset signal segments.
    y = window(:,ones(1,ncol)).*y;

    if ~use_chirp     % USE FFT
        % now fft y which does the columns
        y = fft(y,nfft);
        if ~any(any(imag(x)))    % x purely real
            if rem(nfft,2),    % nfft odd
                select = 1:(nfft+1)/2;
            else
                select = 1:nfft/2+1;
            end
            y = y(select,:);
        else
            select = 1:nfft;
        end
        f = (select - 1)'*Fs/nfft;
    else % USE CHIRP Z TRANSFORM
        f = nfft(:);
        f1 = f(1);
        f2 = f(end);
        m = length(f);
        w = exp(-1i*2*pi*(f2-f1)/(m*Fs));
        a = exp(1i*2*pi*f1/Fs);
        y = czt(y,m,w,a);
    end
else  % evaluate DFT on given set of frequencies
    f = nfft(:);
    q = nwind - noverlap;
    extras = floor(nwind/q);
    x = [zeros(q-rem(nwind,q)+1,1); x];
    % create windowed DTFT matrix (filter bank)
    D = window(:,ones(1,length(f))).*exp((-1i*2*pi/Fs*((nwind-1):-1:0)).'*f'); 
    y = upfirdn(x,D,1,q).';
    y(:,[1:extras+1 end-extras+1:end]) = []; 
end
t = (colindex-1)'/Fs;

%Normalize so that output will be independent of signal/fft/fs length
y = 2 * (y./ nfft);

% take abs, and use image to display results
if nargout == 0
    newplot;
    if length(t)==1
        imagesc([0 1/f(2)],f,(20*log10(abs(y)+eps)));axis xy; colormap(jet)
    else
        imagesc(t,f,(20*log10(abs(y)+eps)));axis xy; colormap(jet)
    end
    xlabel('Time')
    ylabel('Frequency')
elseif nargout == 1,
    yo = y;
elseif nargout == 2,
    yo = y;
    fo = f;
elseif nargout == 3,
    yo = y;
    fo = f;
    to = t;
end

%---------------------------------------------------------------------
function [msg,x,nfft,Fs,window,noverlap] = specgramchk(P)
%SPECGRAMCHK Helper function for SPECGRAM.
%   SPECGRAMCHK(P) takes the cell array P and uses each cell as 
%   an input argument.  Assumes P has between 1 and 5 elements.
msg = [];
x = P{1}; 
nfft = P{2};
Fs = P{3};
window = P{4};
if ischar(window) 
    window = sym_window(nfft,window);
elseif isa(window,'numeric')
    if length(window) == 1
        window = sym_window(window,'hanning'); 
    end
end
noverlap = P{5};

% NOW do error checking
if (length(nfft)==1) && (nfft<length(window)), 
    msg = 'Requires window''s length to be no greater than the FFT length.';
end
if (noverlap >= length(window)),
    msg = 'Requires NOVERLAP to be strictly less than the window length.';
end
if (length(nfft)==1) && (nfft ~= abs(round(nfft)))
    msg = 'Requires positive integer values for NFFT.';
end
if (noverlap ~= abs(round(noverlap))),
    msg = 'Requires positive integer value for NOVERLAP.';
end
if min(size(x))~=1,
    msg = 'Requires vector (either row or column) input.';
end


%---------------------------------------------------------------------
function w = sym_window(n,type)
%SYM_HANNING   Symmetric  window. 
% WARNING: corrected for energy conservation purposes!! (last factorisation)
switch type
    case 'hanning'
        window_function=@calc_hanning;
    case 'kaiser_bessel'
        window_function=@calc_kb;
    case 'rectangular'
        window_function=@calc_rect;
    case 'flat_top'
        window_function=@calc_flattop;
end;

if ~rem(n,2)
   % Even length window
   half = n/2;
   w = window_function(half,n);
   w = [w; w(end:-1:1)];
else
   % Odd length window
   half = (n+1)/2;
   w = window_function(half,n);
   w = [w; w(end-1:-1:1)];
end
w=w*sqrt(sum(w)/sum(w.^2));
%---------------------------------------------------------------------
function w = calc_hanning(m,n)
%CALC_HANNING   Calculates Hanning window samples.
%   CALC_HANNING Calculates and returns the first M points of an N point
%   Hanning window.
w = .5*(1 - cos(2*pi*(1:m)'/(n+1))); 
%---------------------------------------------------------------------
function w = calc_kb(m,n)
w = .5*(1 - 1.24*cos(2*pi*(1:m)'/(n+1))+0.244*cos(4*pi*(1:m)'/(n+1))-0.00305*cos(6*pi*(1:m)'/(n+1))); 
%---------------------------------------------------------------------
function w = calc_rect(m,n)
w = .5*(ones(size((1:m)'))); 
%---------------------------------------------------------------------
function w = calc_flattop(m,n)
w = .5*(1 - 1.93*cos(2*pi*(1:m)'/(n+1))+1.29*cos(4*pi*(1:m)'/(n+1))-0.388*cos(6*pi*(1:m)'/(n+1))+0.0322*cos(8*pi*(1:m)'/(n+1))); 