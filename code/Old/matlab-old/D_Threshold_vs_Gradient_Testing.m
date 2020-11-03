close all; clear all; clc;

% define and add function path
addpath(genpath('Local_Tools/'))

outfp = 'Figures/';

plot_fig = 0;


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

%% Gradient Method %%

% find differences
% pressure changes linearly with depth so can be used to find depth differences
% diff_doxy = gradient(doxy);
% diff_temp = gradient(temp);
% diff_pres = gradient(pres);

% ave_pres = 0.5.*(circshift(pres,-2) + pres);
% ave_pres = ave_pres(2:end-1,:);
% ave_pres = repmat(ave_pres, [1,size(diff_temp,2)]);

% doxy = movmean(doxy,15,'omitnan');
% temp = movmean(temp,15,'omitnan');

diff_doxy = circshift(doxy,-2) - doxy;
diff_doxy = diff_doxy(2:end-1,:);

diff_temp = circshift(temp,-2) - temp;
diff_temp = diff_temp(2:end-1,:);

diff_pres = circshift(pres,-2) - pres;
diff_pres = diff_pres(2:end-1);

ave_pres = pres(2:end-1);
ave_pres = repmat(ave_pres, [1,size(diff_temp,2)]);

grad_doxy = diff_doxy./diff_pres;
grad_temp = diff_temp./diff_pres;

% smooth the gradient with a running mean - window = 5
grad_doxy_sm = movmean(grad_doxy,15,'omitnan');
grad_temp_sm = movmean(grad_temp,15,'omitnan');

figure
setfigsize(1600,800)
ps = 26;
pe = 26;
subplot(2,2,1)
plot(grad_doxy_sm(:,end-ps:end-pe),-1*ave_pres(:,end-ps:end-pe),'k')
hold on
plot(grad_doxy(:,end-ps:end-pe),-1*ave_pres(:,end-ps:end-pe),'m')
title('Grad DOXY - smoothed is black')

subplot(2,2,2)
plot(doxy(:,end-ps:end-pe),-1*pres,'b')
title('DOXY')

subplot(2,2,3)
plot(grad_temp_sm(:,end-ps:end-pe),-1*ave_pres(:,end-ps:end-pe),'k')
hold on
plot(grad_temp(:,end-ps:end-pe),-1*ave_pres(:,end-5:end),'m')
title('Grad Temp- smoothed is black')

subplot(2,2,4)
plot(temp(:,end-ps:end-pe),-1*pres,'k')
title('Temp')

tightfig();

% %find the three largest negative gradients
% [~, grad_temp_ind_3] = mink(grad_temp,3);
% [~, grad_doxy_ind_3] = mink(grad_doxy,3);
% 
% %take the smallest index (the closest to the surface)
% grad_temp_ind = min(grad_temp_ind_3);
% grad_doxy_ind = min(grad_doxy_ind_3);

[grad_temp_max,grad_temp_ind] = max(abs(grad_temp_sm));
[grad_doxy_max,grad_doxy_ind] = max(abs(grad_doxy_sm));

% take centered pressures of these values
TCD_grad = ave_pres(grad_temp_ind);
OCD_grad = ave_pres(grad_doxy_ind);

% set the places where there wasn't a minimum to NaN
TCD_grad(isnan(grad_temp_min))=nan;
OCD_grad(isnan(grad_doxy_min))=nan;

if plot_fig == 1
%--------------------------------------------------------------------------
figure(2) % plots of TCD and OCD with thresh/grad methods
%--------------------------------------------------------------------------

set(gcf,'color','white')
setfigsize(1600,800)

subplot(2,2,1)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_scatter(lon,lat,2,TCD_thresh','.')
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
colorbar
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
title('TCD Threshold Method')
xlabel('Longitude')
ylabel('Latitiude')
caxis([20,160])

subplot(2,2,2)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_scatter(lon,lat,2,OCD_thresh','.')
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
colorbar
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
title('OCD Threshold Method')
xlabel('Longitude')
ylabel('Latitiude')
caxis([20,160])

subplot(2,2,3)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_scatter(lon,lat,2,TCD_grad','.')
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
colorbar
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
title('TCD Gradient Method')
xlabel('Longitude')
ylabel('Latitiude')
caxis([20,160])

subplot(2,2,4)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_scatter(lon,lat,2,OCD_grad','.')
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
colorbar
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
title('OCD Gradient Method')
xlabel('Longitude')
ylabel('Latitiude')
caxis([20,160])

set(findall(gcf,'-property','FontSize'),'FontSize',16)

tightfig();

% save png
outfn = 'TCD_OCD_Threshold_vs_Gradient_Method.png';
print(gcf,[outfp outfn],'-dpng','-r300'); 
end

%% 1 Degree Binned

par.binwid = 1;
[TCD_grad_grid_vals,TCD_grad_grid,bincounts_T,lon_grid,lat_grid] = latlon_var_bin(TCD_grad,lon,lat,par);
[OCD_grad_grid_vals,OCD_grad_grid,bincounts_O,~,~] = latlon_var_bin(OCD_grad,lon,lat,par);

if plot_fig == 1
%--------------------------------------------------------------------------
figure(3) % plots of gridded/interp TCD and OCD with thresh/grad methods
%--------------------------------------------------------------------------

set(gcf,'color','white')
setfigsize(1600,800)

subplot(2,2,1)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_scatter(lon,lat,2,TCD_grad','.')
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
colorbar
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
title('TCD Gradient Method Scattered')
xlabel('Longitude')
ylabel('Latitiude')
caxis([20,160])

subplot(2,2,2)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_scatter(lon,lat,2,OCD_grad','.')
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
colorbar
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
title('TCD Gradient Method Scattered')
xlabel('Longitude')
ylabel('Latitiude')
caxis([20,160])

subplot(2,2,3)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_pcolor(lon_grid,lat_grid,TCD_grad_grid); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
colorbar
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
title('TCD Gradient Method Binned')
xlabel('Longitude')
ylabel('Latitiude')
caxis([20,160])


subplot(2,2,4)
m_pcolor(lon_grid,lat_grid,OCD_grad_grid); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
colorbar
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
title('OCD Gradient Method Binned')
xlabel('Longitude')
ylabel('Latitiude')
caxis([20,160])

set(findall(gcf,'-property','FontSize'),'FontSize',16)

tightfig();

% save png
outfn = 'TCD_OCD_Scattered_and_1_Degree_Binned_Gradient_Method.png';
print(gcf,[outfp outfn],'-dpng','-r300'); 

end
% 
% %% Find Correlations
% 
% par.binwid = 1;
% 
% [mean_seasonal_xcorr,seasonal_xcorr,seasonal_TCD_data,seasonal_OCD_data,...
%     seasonal_TCD_bincounts,seasonal_OCD_bincounts,lat_grid,lon_grid]...
%     = OCD_TCD_corr_latlon_bin(TCD_grad,OCD_grad,lon,lat,seasons,years,par);
% 
% %--------------------------------------------------------------------------
% figure(4) % plots of correlation of TCD and OCD with thresh/grad methods
% %--------------------------------------------------------------------------
% 
% set(gcf,'color','white')
% setfigsize(1100,600)
% 
% % subplot(1,2,1)
% m_pcolor(lon_grid,lat_grid,mean_seasonal_corr); shading flat;
% m_coast('patch',[.7 .7 .7],'edgecolor','none');
% m_grid('background color','k');
% colorbar
% title('Mean Seasonal TCD-OCD Cross-Correlation Coefficient')
% xlabel('Longitude')
% ylabel('Latitiude')
% % caxis([20,160])
% 
% set(findall(gcf,'-property','FontSize'),'FontSize',16)
% 
% tightfig();
% 
% % save png
% outfn = 'TCD_OCD_XCorrelation_1_Degree_Binned_Gradient_Method.png';
% print(gcf,[outfp outfn],'-dpng','-r300'); 
% 
% 
