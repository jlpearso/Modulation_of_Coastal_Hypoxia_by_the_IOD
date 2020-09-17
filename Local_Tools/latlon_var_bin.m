function [var_binned,var_binned_ave,var_binned_sd,bincounts,lat_grid,lon_grid] = latlon_var_bin(var,lon,lat,par)

% get lat lon bounds for bins
maxlat = nanmax(lat(:));
minlat = nanmin(lat(:));
maxlon = nanmax(lon(:));
minlon = nanmin(lon(:));

% Define the bin width
if  ~isfield(par,'binwid') 
   par.binwid = 0.5; % default is .5 degree (~ 55km)
end

if ~isfield(par,'bootsampno')
   par.bootsampno = 10000;
end

if ~isfield(par,'bootci_thresh')
    par.bootci_thresh = 10;
end


%-------------------------------------------------------------------------
%   Bin Vector
%-------------------------------------------------------------------------
lat_vec = lat(:);
latbins = minlat:par.binwid:maxlat;

lon_vec = lon(:);
lonbins = minlon:par.binwid:maxlon;

[lat_grid,lon_grid] = meshgrid(lonbins,latbins);
%-------------------------------------------------------------------------
%   Initialize matrices
%-------------------------------------------------------------------------
var_binned = cell([length(latbins),length(lonbins)]);

%-------------------------------------------------------------------------
%   Bin Data
%-------------------------------------------------------------------------
lat_disc = discretize(lat_vec,latbins);
lon_disc = discretize(lon_vec,lonbins);

var_vec = var(:);

% use a max of 5 cores in the parfor loop
for xx = 1:length(lonbins)
    parfor yy = 1:length(latbins,4)
        ind = lat_disc == yy & lon_disc == xx;
        if ~isempty(lat_vec(ind))
            var_binned{yy,xx} = var_vec(ind);
            bincounts(yy,xx) = length(var_vec(ind));
        end
    end
end


%-------------------------------------------------------------------------
%   Statistics 
%-------------------------------------------------------------------------

var_binned_ave = cellfun(@nanmean,var_binned);
var_binned_sd = cellfun(@nanstd,var_binned);

end