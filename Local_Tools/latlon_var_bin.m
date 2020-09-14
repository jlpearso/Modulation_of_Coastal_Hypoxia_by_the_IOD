function [var_binned,var_binned_ave,bincounts,lat_grid,lon_grid] = latlon_var_bin(var,lon,lat,par)

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

for xx = 1:length(lonbins)
    parfor yy = 1:length(latbins)
        ind = lat_disc == yy & lon_disc == xx;
        if ~isempty(lat_vec(ind))
            var_binned{yy,xx} = var_vec(ind);
            bincounts(yy,xx) = length(var_vec(ind));
        end
    end
end

var_binned = var_binned;
%-------------------------------------------------------------------------
%   Statistics 
%-------------------------------------------------------------------------
if isfield(par,'stat') && strcmp(par.stat,'mode')
    [mode_cell, ~,full_mode_cell] = cellfun(@mode,var_binned);
    
    tot_len = cellfun(@length,full_mode_cell);
    ind = tot_len > 1;
    
    % remove places where more than one mode exists
    mode_cell(ind) = nan;
    mode = mode_cell;
    
elseif isfield(par,'stat') && strcmp(par.stat,'median')
    var_binned_ave = cellfun(@nanmedian,var_binned);
else
    var_binned_ave = cellfun(@nanmean,var_binned);
    var_binned_sd = cellfun(@nanstd,var_binned);
end


% %-------------------------------------------------------------------------
% %   Boostrapping 
% %-------------------------------------------------------------------------
% varci = NaN(length(struc.latbins),length(struc.lonbins),2);
% total = length(struc.latbins)*length(struc.lonbins);
% 
%  for yy = 1:length(struc.latbins)   
%     parfor xx = 1:length(struc.lonbins)
%         tmp = var_binned{yy,xx};
%         
%         % make sure there are enough data at a given location
%         if length(tmp(~isnan(tmp))) > par.bootci_thresh
%             [civar,] = bootci(par.bootsampno,@nanmean,var_binned{yy,xx});    
%             varci(yy,xx,:) = civar;
%         end
%     end
%  end


%-------------------------------------------------------------------------
%   Save Other Data to Structure
%-------------------------------------------------------------------------
% struc.varci = varci;


end