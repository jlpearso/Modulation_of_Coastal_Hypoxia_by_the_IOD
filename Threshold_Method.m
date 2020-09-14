close all; clear all; clc;

% define and add function path
addpath(genpath('Local_Tools/'))

outfp = 'Figures/';

plot_fig = 0;

fname = 'Profiles_temp_psal_doxy.nc';
readncfile

% convert all to doubles - get some errors later if you don't
doxy = double(doxy);
temp = double(temp);
pres = double(pres);
psal = double(psal);
lat = double(lat);
lon = double(lon);

%% Find Total Number of Profiles/ Time of Profiles%%

base = datenum('01-01-1800 00:00:00');
date_number = base + double(time);
date_string = datestr(date_number);

[years,months,days] = ymd(datetime(date_string));

for mm = 1:length(months)
    
    if months(mm) == 3 || months(mm) == 4 || months(mm) == 5
        seasons(mm) = 1;
        seasons_str{mm} = 'MAM';
    elseif months(mm) == 6 || months(mm) == 7 || months(mm) == 8
        seasons(mm) = 2;
        seasons_str{mm} = 'JJA';
    elseif months(mm) == 9 || months(mm) == 10 || months(mm) == 11
        seasons(mm) = 3;
        seasons_str{mm} = 'SON';
    else
        seasons(mm) = 4;
        seasons_str{mm} = 'DJF';
    end
end

if plot_fig == 1
% %--------------------------------------------------------------------------
% figure(1) % plot the total number profiles used as well as the type of 
% %           data over time
% %--------------------------------------------------------------------------
% set(gcf,'color','white')
% setfigsize(1500,800)
% 
% subplot(1,2,1)
% m_proj('mercator','longitudes',[30,120], ...
%            'latitudes',[-20,30]);
% hold on
% m_scatter(lon_doxy,lat_doxy,2,'m.')
% m_coast('patch',[.7 .7 .7],'edgecolor','none');
% m_grid('background color','k');
% colorbar
% caxis([-5000,-200])
% title('Total Profile Locations')
% xlabel('Longitude')
% ylabel('Latitiude')
% 
% set(findall(gcf,'-property','FontSize'),'FontSize',16)
% 
% subplot(1,2,2)

end
%% Mask Shelf %%

% mask out the shelf (200m ~20 atm =202.65 dbar)
% find out if the max pressure was ever this large...if it was, likely off
% the shelf.
shelf_pres_cutoff = 205;

% take only data that is below this pressure level
below_shelf_temp = temp(pres >= shelf_pres_cutoff,:);
below_shelf_doxy = doxy(pres >= shelf_pres_cutoff,:);

% find if all the data are nans below this
below_shelf_temp_sum = sum(~isnan(below_shelf_temp));
below_shelf_doxy_sum = sum(~isnan(below_shelf_doxy));

below_shelf_temp_ind = below_shelf_temp_sum >= 1;
below_shelf_doxy_ind = below_shelf_doxy_sum >= 1;

% set the whole columns to those on the shelf to NaNs
temp(:,~below_shelf_temp_ind) = nan;
doxy(:,~below_shelf_doxy_ind) = nan;

if plot_fig == 1
%--------------------------------------------------------------------------
figure(2) % plot bathymetry versus pressure cutoff to check that the shelf 
%           is weel realized
%--------------------------------------------------------------------------

set(gcf,'color','white')
setfigsize(1500,500)

% mask lat and lons
lon_temp = lon;
lon_temp(~below_shelf_temp_ind) = nan;

lat_temp = lat;
lat_temp(~below_shelf_temp_ind) = nan;

subplot(1,2,1)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_scatter(lon_temp,lat_temp,2,'m.')
[~,h]=m_elev;
h.LineWidth = 2;
colorbar
caxis([-5000,-200])
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
title('Shelf Masked TCD Locations')
xlabel('Longitude')
ylabel('Latitiude')


subplot(1,2,2)

% mask lat and lons
lon_doxy = lon;
lon_doxy(~below_shelf_doxy_ind) = nan;

lat_doxy = lat;
lat_doxy(~below_shelf_doxy_ind) = nan;

m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_scatter(lon_doxy,lat_doxy,2,'m.')
[~,h]=m_elev;
h.LineWidth = 2;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
colorbar
caxis([-5000,-200])
title('Shelf Masked OCD Locations')
xlabel('Longitude')
ylabel('Latitiude')

set(findall(gcf,'-property','FontSize'),'FontSize',16)

tightfig()

% save png
outfn = 'TCD_and_OCD_Shelf_Mask_vs_Bathymetry';
print(gcf,[outfp outfn],'-dpng','-r300'); 
end

%% Threshold Method %%

temp_thresh = 23;
doxy_thresh = 100/1.025; % converts the paper units to umol/kg = umol/L/1.025

TCD_thresh = NaN([1,length(doxy)]);
OCD_thresh = NaN([1,length(doxy)]);

% find all threshold crossings with depth
thresh_temp_ind = temp > temp_thresh & circshift(temp,-1) < temp_thresh...
    | temp < temp_thresh & circshift(temp,-1) > temp_thresh;

thresh_doxy_ind = doxy > doxy_thresh & circshift(doxy,-1) < doxy_thresh...
    | doxy < doxy_thresh & circshift(doxy,-1) > doxy_thresh;

for pr = 1:size(doxy,2)
    % find the index of the first threshold crossing
    first_ind_temp = find(thresh_temp_ind(:,pr),1);
    first_ind_doxy = find(thresh_doxy_ind(:,pr),1);
    
    % if there is a crossing to add, put it otherwise leave it NaN
    if ~isempty(first_ind_temp)
        TCD_thresh(:,pr) = pres(find(thresh_temp_ind(:,pr),1));
    end
    
    if ~isempty(first_ind_doxy)
        OCD_thresh(:,pr) = pres(find(thresh_doxy_ind(:,pr),1));
    end
end

