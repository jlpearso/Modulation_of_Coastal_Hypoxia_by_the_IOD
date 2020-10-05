function [mean_seasonal_corr,seasonal_corr, seasonal_TCD_data, seasonal_OCD_data,...
    seasonal_TCD_bincounts,seasonal_OCD_bincounts,lat_grid,lon_grid]...
    = OCD_TCD_corr_latlon_bin(TCD,OCD,lon,lat,seasons,years,par)
% function [mean_seasonal_corr,seasonal_corr, seasonal_TCD_data, seasonal_OCD_data,...
%     seasonal_TCD_bincounts,seasonal_OCD_bincounts,...
%     mean_interannual_corr,interannual_corr,interannual_TCD_data_,interannual_OCD_data,...
%     interannual_TCD_bincounts,interannual_OCD_bincounts,...
%     lat_grid,lon_grid] = OCD_TCD_corr_latlon_bin(TCD,OCD,lon,lat,seasons,years,par)

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
lat_bin_edges = minlat:par.binwid:maxlat;

lon_vec = lon(:);
lon_bin_edges = minlon:par.binwid:maxlon;

[lat_grid,lon_grid] = meshgrid(lon_bin_edges,lat_bin_edges);

season_bin_edges = [0.5,1.5,2.5,3.5,4.5];
% year_bin_edges = [0.5,1.5,2.5,3.5,4.5];

%-------------------------------------------------------------------------
%   Bin Data
%-------------------------------------------------------------------------
lat_disc = discretize(lat_vec,lat_bin_edges);
lon_disc = discretize(lon_vec,lon_bin_edges);

season_disc = discretize(seasons,season_bin_edges);
% interannual_disc(years

TCD_vec = TCD(:);
OCD_vec = OCD(:);

seasonal_TCD_data = cell([length(lat_bin_edges),length(lon_bin_edges),4]);
seasonal_TCD_bincounts = NaN([length(lat_bin_edges),length(lon_bin_edges),4]);

seasonal_OCD_data = cell([length(lat_bin_edges),length(lon_bin_edges),4]);
seasonal_OCD_bincounts = NaN([length(lat_bin_edges),length(lon_bin_edges),4]);

for ss = 1:4
    for xx = 1:length(lon_bin_edges)
        parfor yy = 1:length(lat_bin_edges)
            
            ind = lat_disc == yy & lon_disc == xx & season_disc == ss;
            
            if ~isempty(lat_vec(ind))
                
                seasonal_TCD_bincounts(yy,xx,ss) = length(TCD_vec(ind));
                seasonal_OCD_bincounts(yy,xx,ss) = length(OCD_vec(ind));
                
                if length(TCD_vec(ind)) < 10 || length(OCD_vec(ind)) < 10
                    seasonal_TCD_data{yy,xx,ss} = nan;
                    seasonal_OCD_data{yy,xx,ss} = nan;
                else
                    seasonal_TCD_data{yy,xx,ss} = TCD_vec(ind);
                    seasonal_OCD_data{yy,xx,ss} = TCD_vec(ind);
                end
            end
        end
    end
end

%-------------------------------------------------------------------------
%   Find Seasonal Correlation
%-------------------------------------------------------------------------

seasonal_corr = NaN([length(lat_bin_edges),length(lon_bin_edges)],length(season_key));

for ss = 1:4
    for xx = 1:length(lon_bin_edges)
        parfor yy = 1:length(lat_bin_edges)
            
            TCD_tmp =seasonal_TCD_data{yy,xx,ss};
            OCD_tmp =seasonal_OCD_data{yy,xx,ss};
            
            % find cross corr within a season at a location
            seasonal_corr(xx,yy,ss) = xcorr(TCD_tmp,OCD_tmp);
        end
    end
end


%-------------------------------------------------------------------------
%   Seaonal Statistics 
%-------------------------------------------------------------------------

mean_seasonal_corr = mean(seasonal_corr,3);




end