function rgb = Lab_to_sRGB(lab)
% Convert a matrix of CIELAB L*a*b* values to sRGB values.
%
% (c) 2018-2020 Stephen Cobeldick
%
%%% Syntax:
% rgb = Lab_to_sRGB(lab)
%
%% Inputs and Outputs
%
%%% Input Argument:
% lab = Numeric Array, size Nx3 or RxCx3, with CIELAB values [L*,a*,b*].
%
%%% Output Argument:
% rgb = Numeric Array, same size as <lab>, with sRGB values [R,G,B], where 0<=RGB<=1.
%
% See also SRGB_TO_LAB SRGB_TO_JAB LAB_TO_DIN99 MAXDISTCOLOR MAXDISTCOLOR_VIEW

%% Input Wrangling %%
%
isz = size(lab);
assert(isnumeric(lab),'SC:Lab_to_sRGB:NotNumeric',...
	'1st input <lab> must be numeric.')
assert(isreal(lab),'SC:Lab_to_sRGB:Complex',...
	'1st input <lab> cannot be complex.')
assert(isz(end)==3,'SC:Lab_to_sRGB:InvalidSize',...
	'1st input <lab> last dimension must have size 3 (e.g. Nx3 or RxCx3).')
lab = reshape(lab,[],3);
err = 1e-4;
assert(all(lab(:,1)>=(0-err)&lab(:,1)<=(100+err)),'SC:Lab_to_sRGB:OutOfRange',...
	'1st input <lab> L values must be within the range 0<=L<=100')
%
if ~isfloat(lab)
	lab = double(lab);
end
%
%% Lab2RGB %%
%
M = [... High-precision sRGB to XYZ matrix:
	0.4124564,0.3575761,0.1804375;...
	0.2126729,0.7151522,0.0721750;...
	0.0193339,0.1191920,0.9503041];
wpt = [0.95047,1,1.08883]; % D65
%
% Approximately equivalent to this function, requires Image Toolbox:
%rgb = applycform(lab,makecform('lab2srgb','AdaptedWhitePoint',wpt))
%
% Lab2XYZ
tmp = bsxfun(@rdivide,lab(:,[2,1,3]),[500,Inf,-200]);
tmp = bsxfun(@plus,tmp,(lab(:,1)+16)/116);
idx = tmp>(6/29);
tmp = idx.*(tmp.^3) + ~idx.*(3*(6/29)^2*(tmp-4/29));
xyz = bsxfun(@times,tmp,wpt);
% Remember to include my license when copying my implementation.
% XYZ2RGB
rgb = max(0,min(1, sGammaCor(xyz / M.')));
%
rgb = reshape(rgb,isz);
%
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Lab_to_sRGB
function rgb = sGammaCor(rgb)
% Gamma correction of sRGB data.
idx = rgb <= 0.0031308;
rgb(idx) = 12.92 * rgb(idx);
rgb(~idx) = real(1.055 * rgb(~idx).^(1/2.4) - 0.055);
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%sGammaCor