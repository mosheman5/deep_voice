function signal = inverse_specgram(b,nfft,nwind,nover)
% presumes the values were obtained using 'specgram_proper' - reverses
% its algorithm
% WARNING: the hanning window is corrected for energy conservation
% purposes!! 
% uses the stock 'ifft' function

y=[b ; zeros(size(b))];
% the 'symmetric' takes care of the mirror side

% reconstructs the complex scpectrum
y = y.*(nfft/2);

if ischar(nwind) 
    window = sym_window(nfft,nwind);
elseif isa(nwind,'numeric')
    if length(nwind) == 1
        window = sym_window(nwind,'hanning'); 
    end
end
window = window(:);
nwind=nfft;
x = ifft(y,nfft,'symmetric');

%reverses the hann window
x = (1./(window(:,ones(1,size(y,2)))+eps)).*x;

nx=(size(y,2))*(nwind-nover)+nover;
ncol=size(y,2);
colindex = 1 + (0:(ncol-1))*(nwind-nover);
delta=nwind-nover;

% rowindex = (1:nwind)';
% indexi=(rowindex(:,ones(1,ncol))+colindex(ones(nwind,1),:)-1);

signal=zeros(1,nx);


for xi=1:nx
    first=ceil((xi-nwind)/delta)+1;
    last=floor((xi-1)/delta)+1;
    columns=first:last;
    columns=columns(columns>=1 & columns<=ncol);
    rows=xi-colindex(columns)+1;
    ij=rows+(columns-1)*nwind;
    row_place=(rows-nwind/2).^2;
    middle=find(row_place==min(row_place));
    signal(xi)=x(ij(middle(1)));
end;




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