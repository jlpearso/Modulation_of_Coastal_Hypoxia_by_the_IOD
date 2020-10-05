function lab99 = Lab_to_DIN99(lab)
% Convert a matrix of CIELAB L*a*b* values to DIN99 values (DIN 6176).
%
% (c) 2018-2020 Stephen Cobeldick
%
%%% Syntax:
% lab99 = Lab_to_DIN99(lab)
%
%% Inputs and Outputs
%
%%% Input Argument:
% lab = Numeric Array, size Nx3 or RxCx3, with CIELAB L*a*b* values [L,a,b,].
%
%%% Output Argument:
% lab99 = Numeric Array, same size as <lab>, with DIN99 values [L99,a99,b99].
%
% See also LAB_TO_SRGB SRGB_TO_LAB SRGB_TO_JAB MAXDISTCOLOR MAXDISTCOLOR_VIEW

%% Input Wrangling %%
%
isz = size(lab);
assert(isnumeric(lab),'SC:Lab_to_DIN99:NotNumeric',...
	'1st input <lab> must be numeric.')
assert(isreal(lab),'SC:Lab_to_DIN99:Complex',...
	'1st input <lab> cannot be complex.')
assert(isz(end)==3,'SC:Lab_to_DIN99:InvalidSize',...
	'1st input <lab> last dimension must have size 3 (e.g. Nx3 or RxCx3).')
lab = reshape(lab,[],3);
err = 1e-4;
assert(all(lab(:,1)>=(0-err)&lab(:,1)<=(100+err)),'SC:Lab_to_DIN99:OutOfRange',...
	'1st input <lab> L values must be within the range 0<=L<=100')
%
if ~isfloat(lab)
	lab = double(lab);
end
%
%% Lab2DIN99 %%
%
L99 = 105.51 * log(1 + 0.0158*lab(:,1));
e =     (lab(:,2).*cosd(16)+lab(:,3).*sind(16));
f = 0.7*(lab(:,3).*cosd(16)+lab(:,2).*sind(16));
G = sqrt(e.^2 + f.^2);
C99 = log(1 + 0.045*G)./0.045;
h99 = atan2(f,e);
a99 = C99 .* cos(h99);
b99 = C99 .* sin(h99);
%
lab99 = reshape([L99,a99,b99],isz);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Lab_to_DIN99