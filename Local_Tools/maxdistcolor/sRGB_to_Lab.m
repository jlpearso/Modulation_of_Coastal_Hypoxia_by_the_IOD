function lab = sRGB_to_Lab(rgb)
% Convert a matrix of sRGB values to CIELAB L*a*b* values.
%
% (c) 2018-2020 Stephen Cobeldick
%
%%% Syntax:
% lab = sRGB_to_Lab(rgb)
%
%% Inputs and Outputs
%
%%% Input Argument:
% rgb = Numeric Array, size Nx3 or RxCx3, with sRGB values [R,G,B], where 0<=RGB<=1.
%
%%% Output Argument:
% lab = Numeric Array, same size as <rgb>, with CIELAB values [L*,a*,b*].
%
% See also SRGB_TO_JAB LAB_TO_SRGB LAB_TO_DIN99 MAXDISTCOLOR MAXDISTCOLOR_VIEW

%% Input Wrangling %%
%
isz = size(rgb);
assert(isnumeric(rgb),'SC:sRGB_to_Lab:NotNumeric',...
	'1st input <rgb> array must be numeric.')
assert(isreal(rgb),'SC:sRGB_to_Lab:Complex',...
	'1st input <rgb> cannot be complex.')
assert(isz(end)==3,'SC:sRGB_to_Lab:InvalidSize',...
	'1st input <rgb> last dimension must have size 3 (e.g. Nx3 or RxCx3).')
rgb = reshape(rgb,[],3);
assert(all(rgb(:)>=0&rgb(:)<=1),'SC:sRGB_to_Lab:OutOfRange',...
	'1st input <rgb> values must be within the range 0<=rgb<=1')
%
if ~isfloat(rgb)
	rgb = double(rgb);
end
%
%% RGB2Lab %%
%
M = [... High-precision sRGB to XYZ matrix:
	0.4124564,0.3575761,0.1804375;...
	0.2126729,0.7151522,0.0721750;...
	0.0193339,0.1191920,0.9503041];
wpt = [0.95047,1,1.08883]; % D65
%
% Approximately equivalent to this function, requires Image Toolbox:
%lab = applycform(rgb,makecform('srgb2lab','AdaptedWhitePoint',wpt))
%
% RGB2XYZ
xyz = sGammaInv(rgb) * M.';
% Remember to include my license when copying my implementation.
% XYZ2Lab
xyz = bsxfun(@rdivide,xyz,wpt);
idx = xyz>(6/29)^3;
F = idx.*(xyz.^(1/3)) + ~idx.*(xyz*(29/6)^2/3+4/29);
lab(:,2:3) = bsxfun(@times,[500,200],F(:,1:2)-F(:,2:3));
lab(:,1) = 116*F(:,2) - 16;
%
lab = reshape(lab,isz);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%sRGB_to_Lab
function rgb = sGammaInv(rgb)
% Inverse gamma correction of sRGB data.
idx = rgb <= 0.04045;
rgb(idx) = rgb(idx) / 12.92;
rgb(~idx) = real(((rgb(~idx) + 0.055) / 1.055).^2.4);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%sGammaInv