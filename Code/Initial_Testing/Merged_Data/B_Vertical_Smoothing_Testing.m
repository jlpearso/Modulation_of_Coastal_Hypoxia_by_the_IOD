close all; clear all; clc; warning off;
%% Setup ==================================================================
%{

    This code applies quality control, reformats,10O

%}
%==========================================================================

%--------------------------------------------------------------------------
% Parameters
%--------------------------------------------------------------------------

plot_fig = 1;       % set to 1 to plot figs, 0 to supress
qc_thresh = 5;     % the min no. of pts that must be in each profile

pr = 305118; % AS = 305118 | double 305000 | bad one? 304100 | good ctd tcd 30000 | shelf 30400/30500
% surface with not tcd really 306100 | goot tcd/ocd 306050 | confusing 306050 ;

profiles = [266805,266810,304327,305118,304100,30000,30400,30500,306100,...
    306108,306029,306053,306073,306050,306099];

%--------------------------------------------------------------------------
% Paths
%--------------------------------------------------------------------------

% define and add function path
addpath(genpath('../../../Local_Tools/'))

% add data path
addpath(genpath('../../../Data/'))

outfp = '../../../Figures/Testing/Vertical_Smoothing/';
indp = '../../../Data/Testing/Processed/';
outdp = '../../../Data/Testing/Smoothed/';

%--------------------------------------------------------------------------
% Filesnames
%--------------------------------------------------------------------------

infn = ['Profiles_qc_thresh_' num2str(qc_thresh) '_processed.mat'];
outdfn = ['Profiles_qc_thresh_' num2str(qc_thresh) '_smoothed.mat'];

%--------------------------------------------------------------------------
% Other
%--------------------------------------------------------------------------

% set default figure properties
figprops;

% if the output directory doesn't exist create it
if ~exist(outfp, 'dir')
    mkdir(outfp)
end

if ~exist(outdp, 'dir')
    mkdir(outdp)
end

load([indp infn])

%% Gradient Vertical Smoothing ============================================
%{

    This section calculates the largest negative (i.e. min) gradient for
    each profile and counts it as the cline depth for various levels of
    vertical smoothing using a moving mean.

%}
%==========================================================================

% find one-sided differences
diff_doxy = diff(doxy);
diff_temp = diff(temp);
diff_pres = diff(pres);

ave_pres = 0.5.*(circshift(pres,-1) + pres);
ave_pres = ave_pres(1:end-1);
struc.ave_pres = repmat(ave_pres, [1,size(diff_temp,2)]);

struc.grad_doxy = diff_doxy./diff_pres;
struc.grad_temp = diff_temp./diff_pres;

% smooth the gradient with a running mean
struc.grad_doxy_sm_5 = movmean(struc.grad_doxy,5,'omitnan');
struc.grad_temp_sm_5 = movmean(struc.grad_temp,5,'omitnan');

struc.grad_doxy_sm_10 = movmean(struc.grad_doxy,10,'omitnan');
struc.grad_temp_sm_10 = movmean(struc.grad_temp,10,'omitnan');

struc.grad_doxy_sm_15 = movmean(struc.grad_doxy,15,'omitnan');
struc.grad_temp_sm_15 = movmean(struc.grad_temp,15,'omitnan');

%% TCD and OCD ============================================================
%{

    This section calculates the largest negative (i.e. min) gradient for
    each profile and counts it as the cline depth for various levels of
    vertical smoothing using a moving mean.

%}
%==========================================================================

% find the largest negative gradient (min)
[grad_temp_min,grad_temp_min_ind] = min(struc.grad_temp);
[grad_doxy_min,grad_doxy_min_ind] = min(struc.grad_doxy);

[grad_temp_min_sm_5,grad_temp_min_ind_sm_5] = min(struc.grad_temp_sm_5);
[grad_doxy_min_sm_5,grad_doxy_min_ind_sm_5] = min(struc.grad_doxy_sm_5);

[grad_temp_min_sm_10,grad_temp_min_ind_sm_10] = min(struc.grad_temp_sm_10);
[grad_doxy_min_sm_10,grad_doxy_min_ind_sm_10] = min(struc.grad_doxy_sm_10);

[grad_temp_min_sm_15,grad_temp_min_ind_sm_15] = min(struc.grad_temp_sm_15);
[grad_doxy_min_sm_15,grad_doxy_min_ind_sm_15] = min(struc.grad_doxy_sm_15);


% % take the two largest negative gradients
% [grad_temp_mink,grad_temp_mink_ind] = mink(grad_temp,2);
% [grad_doxy_mink,grad_doxy_mink_ind] = mink(grad_doxy,2);
% 
% [grad_temp_mink_sm_5,grad_temp_mink_ind_sm_5] = mink(grad_temp_sm_5,2);
% [grad_doxy_mink_sm_5,grad_doxy_mink_ind_sm_5] = mink(grad_doxy_sm_5,2);
% 
% [grad_temp_mink_sm_10,grad_temp_mink_ind_sm_10] = mink(grad_temp_sm_10,2);
% [grad_doxy_mink_sm_10,grad_doxy_mink_ind_sm_10] = mink(grad_doxy_sm_10,2);
% 
% [grad_temp_mink_sm_15,grad_temp_mink_ind_sm_15] = mink(grad_temp_sm_15,2);
% [grad_doxy_mink_sm_15,grad_doxy_mink_ind_sm_15] = mink(grad_doxy_sm_15,2);
% 
% % take the one closest to the surface
% [grad_temp_min_ind,~] = min(grad_temp_mink_ind);
% [grad_doxy_min_ind,~] = min(grad_doxy_mink_ind);
% 
% [grad_temp_min_ind_sm_5,~] = min(grad_temp_mink_ind_sm_5);
% [grad_doxy_min_ind_sm_5,~] = min(grad_doxy_mink_ind_sm_5);
% 
% [grad_temp_min_ind_sm_10,~] = min(grad_temp_mink_ind_sm_10);
% [grad_doxy_min_ind_sm_10,~] = min(grad_doxy_mink_ind_sm_10);
% 
% [grad_temp_min_ind_sm_15,~] = min(grad_temp_mink_ind_sm_15);
% [grad_doxy_min_ind_sm_15,~] = min(grad_doxy_mink_ind_sm_15);


% take average pressures at the mins
struc.TCD = ave_pres(grad_temp_min_ind);
struc.OCD= ave_pres(grad_doxy_min_ind);

struc.TCD_sm_5 = ave_pres(grad_temp_min_ind_sm_5);
struc.OCD_sm_5 = ave_pres(grad_doxy_min_ind_sm_5);

struc.TCD_sm_10 = ave_pres(grad_temp_min_ind_sm_10);
struc.OCD_sm_10 = ave_pres(grad_doxy_min_ind_sm_10);

struc.TCD_sm_15 = ave_pres(grad_temp_min_ind_sm_15);
struc.OCD_sm_15 = ave_pres(grad_doxy_min_ind_sm_15);

% set the places where there wasn't a minimum to NaN

struc.TCD(isnan(grad_temp_min))=nan;
struc.OCD(isnan(grad_doxy_min))=nan;

struc.TCD_sm_5(isnan(grad_temp_min_sm_5))=nan;
struc.OCD_sm_5(isnan(grad_doxy_min_sm_5))=nan;

struc.TCD_sm_10(isnan(grad_temp_min_sm_10))=nan;
struc.OCD_sm_10(isnan(grad_doxy_min_sm_10))=nan;

struc.TCD_sm_15(isnan(grad_temp_min_sm_15))=nan;
struc.OCD_sm_15(isnan(grad_doxy_min_sm_15))=nan;

% set TCD/OCD for depths greater than 400dbar to nans

% scatter(struc.OCD,grad_doxy_min,'.')
grad_O_thresh = -5;
grad_T_thresh = -0.05;

% pres_thresh = 300;
% 
struc.TCD(grad_temp_min>=grad_T_thresh) = nan;
struc.OCD(grad_doxy_min>=grad_O_thresh) = nan;

struc.TCD_sm_5(grad_temp_min_sm_5>=grad_T_thresh) = nan;
struc.OCD_sm_5(grad_doxy_min_sm_5>=grad_O_thresh) = nan;

struc.TCD_sm_10(grad_temp_min_sm_10>=grad_T_thresh) = nan;
struc.OCD_sm_10(grad_doxy_min_sm_10>=grad_O_thresh) = nan;

struc.TCD_sm_15(grad_temp_min_sm_15>=grad_T_thresh) = nan;
struc.OCD_sm_15(grad_doxy_min_sm_15>=grad_O_thresh) = nan;

% TCD_grad(isnan(grad_temp(grad_temp_min_ind)))=nan;
% OCD_grad(isnan(grad_doxy(grad_doxy_min_ind)))=nan;
% 
% TCD_grad_sm_5(isnan(grad_temp_sm_5(grad_temp_min_ind_sm_5)))=nan;
% OCD_grad_sm_5(isnan(grad_doxy_sm_5(grad_doxy_min_ind_sm_5)))=nan;
% 
% TCD_grad_sm_10(isnan(grad_temp_sm_10(grad_temp_min_ind_sm_10)))=nan;
% OCD_grad_sm_10(isnan(grad_doxy_sm_10(grad_doxy_min_ind_sm_10)))=nan;
% 
% TCD_grad_sm_15(isnan(grad_temp_sm_15(grad_temp_min_ind_sm_15)))=nan;
% OCD_grad_sm_15(isnan(grad_doxy_sm_15(grad_doxy_min_ind_sm_15)))=nan;

% put into 1 degree bins
gridspacing = 1;

[struc.TCD_binned,struc.bincounts_T,struc.lat_grid,struc.lon_grid] = latlon_var_bin(struc.TCD,lon,lat,gridspacing);
[struc.OCD_binned,struc.bincounts_O,~,~] = latlon_var_bin(struc.OCD,lon,lat,gridspacing);

[struc.TCD_binned_sm_5,struc.bincounts_T_sm_5,~,~] = latlon_var_bin(struc.TCD_sm_5,lon,lat,gridspacing);
[struc.OCD_binned_sm_5,struc.bincounts_O_sm_5,~,~] = latlon_var_bin(struc.OCD_sm_5,lon,lat,gridspacing);

[struc.TCD_binned_sm_10,struc.bincounts_T_sm_10,~,~] = latlon_var_bin(struc.TCD_sm_10,lon,lat,gridspacing);
[struc.OCD_binned_sm_10,struc.bincounts_O_sm_10,~,~] = latlon_var_bin(struc.OCD_sm_10,lon,lat,gridspacing);

[struc.TCD_binned_sm_15,struc.bincounts_T_sm_15,~,~] = latlon_var_bin(struc.TCD_sm_15,lon,lat,gridspacing);
[struc.OCD_binned_sm_15,struc.bincounts_O_sm_15,~,~] = latlon_var_bin(struc.OCD_sm_15,lon,lat,gridspacing);

% [struc.TCD_grad_grid,struc.TCD_grad_grid_ave,struc.TCD_grad_grid_sd,struc.bincounts_T,struc.lon_grid,struc.lat_grid] = latlon_var_bin(struc.TCD_grad,lon,lat,par);
% [struc.OCD_grad_grid,struc.OCD_grad_grid_ave,struc.OCD_grad_grid_sd,struc.bincounts_O,~,~] = latlon_var_bin(struc.OCD_grad,lon,lat,par);
% 
% [struc.TCD_grad_grid_sm_5,struc.TCD_grad_grid_ave_sm_5,struc.TCD_grad_grid_sd_sm_5,struc.bincounts_T_sm_5,~,~] = latlon_var_bin(struc.TCD_grad_sm_5,lon,lat,par);
% [struc.OCD_grad_grid_sm_5,struc.OCD_grad_grid_ave_sm_5,struc.OCD_grad_grid_sd_sm_5,struc.bincounts_O_sm_5,~,~] = latlon_var_bin(struc.OCD_grad_sm_5,lon,lat,par);
% 
% [struc.TCD_grad_grid_sm_10,struc.TCD_grad_grid_ave_sm_10,struc.TCD_grad_grid_sd_sm_10,struc.bincounts_T_sm_10,~,~] = latlon_var_bin(struc.TCD_grad_sm_10,lon,lat,par);
% [struc.OCD_grad_grid_sm_10,struc.OCD_grad_grid_ave_sm_10,struc.OCD_grad_grid_sd_sm_10,struc.bincounts_O_sm_10,~,~] = latlon_var_bin(struc.OCD_grad_sm_10,lon,lat,par);
% 
% [struc.TCD_grad_grid_sm_15,struc.TCD_grad_grid_ave_sm_15,struc.TCD_grad_grid_sd_sm_15,struc.bincounts_T_sm_15,~,~] = latlon_var_bin(struc.TCD_grad_sm_15,lon,lat,par);
% [struc.OCD_grad_grid_sm_15,struc.OCD_grad_grid_ave_sm_15,struc.OCD_grad_grid_sd_sm_15,struc.bincounts_O_sm_15,~,~] = latlon_var_bin(struc.OCD_grad_sm_15,lon,lat,par);
% 
struc.lat = lat;
struc.lon = lon;
struc.temp = temp;
struc.doxy = doxy;
struc.pres = pres;

% save the data
save([outdp outdfn],'-struct','struc','-v7.3');

% plot binned values
% figure('visible','off')
figure
setfigsize(2000,800)
sp = 0.015;
pad = 0.015;
mar = 0.015;
% cmin = -25;
% camx = 25;

% unsmoothed TCD
subaxis(2,4,1, 'Spacing', sp, 'Padding', pad,'Margin',mar)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_pcolor(struc.lon_grid,struc.lat_grid,struc.TCD_binned); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
c = colorbar;
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
delete(colorbar);
title('Unsmoothed')
caxis([20,160])

% unsmoothed OCD
subaxis(2,4,5, 'Spacing', sp, 'Padding', pad,'Margin',mar)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_pcolor(struc.lon_grid,struc.lat_grid,struc.OCD_binned); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
c = colorbar;
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
delete(colorbar);
caxis([20,160])

% window 5 smoothed TCD
subaxis(2,4,2, 'Spacing', sp, 'Padding', pad,'Margin',mar)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_pcolor(struc.lon_grid,struc.lat_grid,struc.TCD_binned_sm_5); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
c = colorbar;
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
delete(colorbar);
title('Window Length 5')
caxis([20,160])

% window 5 smoothed OCD
subaxis(2,4,6, 'Spacing', sp, 'Padding', pad,'Margin',mar)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_pcolor(struc.lon_grid,struc.lat_grid,struc.OCD_binned_sm_5); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
c = colorbar;
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
delete(colorbar);
caxis([20,160])

% window 10 smoothed TCD
subaxis(2,4,3, 'Spacing', sp, 'Padding', pad,'Margin',mar)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_pcolor(struc.lon_grid,struc.lat_grid,struc.TCD_binned_sm_10); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
c = colorbar;
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
delete(colorbar);
title('Window Length 10')
caxis([20,160])

% window 10 smoothed OCD
subaxis(2,4,7, 'Spacing', sp, 'Padding', pad,'Margin',mar)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_pcolor(struc.lon_grid,struc.lat_grid,struc.OCD_binned_sm_10); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
c = colorbar;
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
delete(colorbar);
caxis([20,160])


% window 15 smoothed TCD
subaxis(2,4,4, 'Spacing', sp, 'Padding', pad,'Margin',mar)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_pcolor(struc.lon_grid,struc.lat_grid,struc.TCD_binned_sm_15); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
c = colorbar;
ylabel(c,'TCD')
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
title('Window Length 15')
caxis([20,160])

% window 15 smoothed OCD
subaxis(2,4,8, 'Spacing', sp, 'Padding', pad,'Margin',mar)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_pcolor(struc.lon_grid,struc.lat_grid,struc.OCD_binned_sm_15); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
c = colorbar;
ylabel(c,'OCD')
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
caxis([20,160])



% save png
outfn = ['TCD_OCD_Smoothing_qc_thresh_' num2str(qc_thresh)  '.png'];
% outfn = ['TCD_OCD_Smoothing_qc_thresh_' num2str(qc_thresh)  '_mink.png'];
print(gcf,[outfp outfn],'-dpng','-r300'); 


%% plot anomalies

% plot binned values
% figure('visible','off')
figure
setfigsize(2000,800)
sp = 0.015;
pad = 0.015;
mar = 0.015;
cmin = -25;
cmax = 25;

% window 5 smoothed TCD
subaxis(2,3,1, 'Spacing', sp, 'Padding', pad,'Margin',mar)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_pcolor(struc.lon_grid,struc.lat_grid,struc.TCD_binned_sm_5-struc.TCD_binned); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
c = colorbar;
colormap(coolwarm);
delete(colorbar);
title('Window Length 5')
caxis([cmin,cmax])

% window 5 smoothed OCD
subaxis(2,3,4, 'Spacing', sp, 'Padding', pad,'Margin',mar)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_pcolor(struc.lon_grid,struc.lat_grid,struc.OCD_binned_sm_5-struc.OCD_binned); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
c = colorbar;
colormap(coolwarm);
delete(colorbar);
caxis([cmin,cmax])

% window 10 smoothed TCD
subaxis(2,3,2, 'Spacing', sp, 'Padding', pad,'Margin',mar)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_pcolor(struc.lon_grid,struc.lat_grid,struc.TCD_binned_sm_10-struc.TCD_binned); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
c = colorbar;
colormap(coolwarm);
delete(colorbar);
title('Window Length 10')
caxis([cmin,cmax])

% window 10 smoothed OCD
subaxis(2,3,5, 'Spacing', sp, 'Padding', pad,'Margin',mar)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_pcolor(struc.lon_grid,struc.lat_grid,struc.OCD_binned_sm_10-struc.OCD_binned); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
c = colorbar;
colormap(coolwarm);
delete(colorbar);
caxis([cmin,cmax])


% window 15 smoothed TCD
subaxis(2,3,3, 'Spacing', sp, 'Padding', pad,'Margin',mar)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_pcolor(struc.lon_grid,struc.lat_grid,struc.TCD_binned_sm_15-struc.TCD_binned); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
c = colorbar;
ylabel(c,'Smoothed TCD - TCD')
colormap(coolwarm);
title('Window Length 15')
caxis([cmin,cmax])

% window 15 smoothed OCD
subaxis(2,3,6, 'Spacing', sp, 'Padding', pad,'Margin',mar)
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_pcolor(struc.lon_grid,struc.lat_grid,struc.OCD_binned_sm_15-struc.OCD_binned); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
c = colorbar;
ylabel(c,'Smoothed OCD - OCD')
colormap(coolwarm);
caxis([cmin,cmax])

% save png
outfn = ['TCD_OCD_Smoothing_Anomaly_qc_thresh_' num2str(qc_thresh)  '.png'];
% outfn = ['TCD_OCD_Smoothing_Anomaly_qc_thresh_' num2str(qc_thresh)  '_mink.png'];

% 
% %% Smoothed Profiles ======================================================
% %{
% 
%     This section calculates the largest negative (i.e. min) gradient for
%     each profile and counts it as the cline depth for various levels of
%     vertical smoothing using a moving mean.
% 
% %}
% %==========================================================================
% 
% 
% % plot individual profiles
% for pp = 1:length(profiles)
%     pr = profiles(pp);
%     
%     figure('visible','off')
%     setfigsize(1300,750)
% 
% 
%     % Plot Dissolved Oxygen ===================================================
% 
%     subaxis(1,2,1, 'Spacing', 0.03, 'Padding', 0.03, 'MR', 0.03,'ML', 0.03,'MB', 0.05,'MT', 0.05);
%     
%     % bottom x axis
%     l1 = plot(struc.grad_doxy(:,pr),-1*struc.ave_pres(:,pr),'k','linewidth',3);
%     ax1 = gca; % current axes
%     hold(ax1,'on')
%     l2 = plot(struc.grad_doxy_sm_5(:,pr),-1*struc.ave_pres(:,pr),'m','linewidth',2);
%     l3 = plot(struc.grad_doxy_sm_10(:,pr),-1*struc.ave_pres(:,pr),'b','linewidth',2);
%     l4 = plot(struc.grad_doxy_sm_15(:,pr),-1*struc.ave_pres(:,pr),'g','linewidth',2);
%     
%     xlabel(ax1,'Dissolved Oxygen Gradient ($\mu mol/kg/dbar$)')
%     ylabel(ax1,'Pressure ($dbar$)')
%     yt = yticks;
%     yticklabels(ax1,sprintfc('%d',-1*yt))
% 
%     % top x axis
%     ax1_pos = ax1.Position; % position of first axes
%     ax2 = axes('Position',ax1_pos,...
%         'XAxisLocation','top',...
%         'YAxisLocation','right',...
%         'Color','none');
% 
%     ax2.XColor = 'r';
% 
%     l5 = line(doxy(:,pr),-1*pres,'Parent',ax2,'Color','r','linewidth',5);
%     xlims = xlim;
%     x = xlims(1):xlims(2); y = ones(size(x));
%     l6 = line(x,-1*struc.OCD_grad(pr).*y,'Parent',ax2,'linewidth',3,'Color','k', 'linestyle',':');
%     line(x,-1*struc.OCD_grad(pr).*y,'Parent',ax2,'linewidth',3,'Color','k', 'linestyle',':');
%     line(x,-1*struc.OCD_grad_sm_5(pr).*y,'Parent',ax2,'linewidth',3,'Color','m', 'linestyle',':');
%     line(x,-1*struc.OCD_grad_sm_10(pr).*y,'Parent',ax2,'linewidth',3,'Color','b', 'linestyle',':');
%     line(x,-1*struc.OCD_grad_sm_15(pr).*y,'Parent',ax2,'linewidth',3,'Color','g', 'linestyle',':');
% 
% 
%     xlabel(ax2,'Dissolved Oxygen ($\mu mol/kg$)')
%     yt = yticks;
%     yticklabels(ax2,sprintfc('%d',-1*yt))
% 
%     % legend
%     l = legend( [l1;l2;l3;l4;l5;l6] ,...
%         {'Unsmoothed','Window Length = 5','Window Length = 10','Window Length = 15','Profile','OCD/TCD'});
%     set(l,'Position',[0.185 0.18 0.15 0.2]) % x,y,w,h
% 
% 
%     % Plot Temperature ========================================================
% 
%     subaxis(1,2,2, 'Spacing', 0.03, 'Padding', 0.03, 'MR', 0.03,'ML', 0.03,'MB', 0.05,'MT', 0.05);
%     l1 = plot(struc.grad_temp(:,pr),-1*struc.ave_pres(:,pr),'k','linewidth',3);
%     ax1 = gca; % current axes
%     hold(ax1,'on')
%     l2 = plot(struc.grad_temp_sm_5(:,pr),-1*struc.ave_pres(:,pr),'m','linewidth',2);
%     l3 = plot(struc.grad_temp_sm_10(:,pr),-1*struc.ave_pres(:,pr),'b','linewidth',2);
%     l4 = plot(struc.grad_temp_sm_15(:,pr),-1*struc.ave_pres(:,pr),'g','linewidth',2);
%     xlabel(ax1,'Temperature Gradient ($^\circ C/dbar)$')
%     ylabel(ax1,'Pressure ($dbar$)')
%     yt = yticks;
%     yticklabels(ax1,sprintfc('%d',-1*yt))
% 
%     ax1_pos = ax1.Position; % position of first axes
%     ax2 = axes('Position',ax1_pos,...
%         'XAxisLocation','top',...
%         'YAxisLocation','right',...
%         'Color','none');
% 
%     ax2.XColor = 'r';
% 
%     l5 = line(temp(:,pr),-1*pres, 'Parent',ax2,'Color','r','linewidth',5);
%     xlims = xlim;
%     x = xlims(1):xlims(2); y = ones(size(x));
%     l6 = line(x,-1*struc.TCD_grad(pr).*y,'Parent',ax2,'linewidth',3,'Color','k', 'linestyle',':');
%     line(x,-1*struc.TCD_grad(pr).*y,'Parent',ax2,'linewidth',3,'Color','k', 'linestyle',':');
%     line(x,-1*struc.TCD_grad_sm_5(pr).*y,'Parent',ax2,'linewidth',3,'Color','m', 'linestyle',':');
%     line(x,-1*struc.TCD_grad_sm_10(pr).*y,'Parent',ax2,'linewidth',3,'Color','b', 'linestyle',':');
%     line(x,-1*struc.TCD_grad_sm_15(pr).*y,'Parent',ax2,'linewidth',3,'Color','g', 'linestyle',':');
% 
% 
%     xlabel(ax2,'Temperature ($^\circ C$)')
%     yt = yticks;
%     yticklabels(ax2,sprintfc('%d',-1*yt))
% 
% 
%     % create inset with location of profile
%     hf1=gcf;                                   
%     axes('parent',hf1,'position',[0.67 0.15 0.15 0.3]);  % x y width height
%     m_proj('mercator','longitudes',[30,120], ...
%                'latitudes',[-20,30]);
%     hold on
%     m_scatter(lon(pr),lat(pr),200,'y.'); shading flat;
%     m_coast('patch',[.7 .7 .7],'edgecolor','none');
%     m_grid('background color','k','xtick',([30, 60, 90, 120]), 'ytick',([-20,0,20]));
%     title('Profile Location')
% 
%     if type(pr) == 0
%         tp = 'ARGO CTD';
%     elseif type(pr) == 1
%         tp = 'ARGO BGC';
%     elseif type(pr) == 2
%         tp = 'WOD';
%     elseif type(pr) == 3
%         tp = 'GO SHIP';
%     end
% 
%     supertitle(['Profile Number: ' num2str(pr)  ' (' tp ')'],18);
%     % tightfig_with_supertitle(gcf);
%     % tightfig;
% 
%     % save png
%     outfn = ['Profile_no_' num2str(pr)  '.png'];
%     print(gcf,[outfp outfn],'-dpng','-r300'); 
% 
%     close all;
% end
