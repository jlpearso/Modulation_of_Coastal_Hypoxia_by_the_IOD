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

latlon_lim_box_N = [10,22;85,95];
latlon_lim_box_S = [-5,10;72,90];

%--------------------------------------------------------------------------
% Paths
%--------------------------------------------------------------------------

% define and add function path
addpath(genpath('../../Local_Tools/'))

% add data path
addpath(genpath('../../Data/'))

outfp = '../../Figures/Testing/Vertical_Smoothing/';
indp = '../../Data/Testing/Smoothed/';

%--------------------------------------------------------------------------
% Filesnames
%--------------------------------------------------------------------------

infn = ['Profiles_qc_thresh_' num2str(qc_thresh) '_smoothed.mat'];

%--------------------------------------------------------------------------
% Other
%--------------------------------------------------------------------------

% set default figure properties
figprops;

% if the output directory doesn't exist create it
if ~exist(outfp, 'dir')
    mkdir(outfp)
end

load([indp infn]) 

%% Smoothed Profiles ======================================================
%{

    This section calculates the largest negative (i.e. min) gradient for
    each profile and counts it as the cline depth for various levels of
    vertical smoothing using a moving mean.

%}
%==========================================================================

% find the mean data bounded by the N box

ind_N = lat >= latlon_lim_box_N(1,1) & lat <= latlon_lim_box_N(1,2) & ...
    lon >= latlon_lim_box_N(2,1) & lon <= latlon_lim_box_N(2,2);  

lat_box_N = lat(ind_N);
lon_box_N = lon(ind_N);

temp_box_N = temp(:,ind_N);
doxy_box_N = doxy(:,ind_N);

grad_temp_box_N = grad_temp(:,ind_N);
grad_doxy_box_N = grad_doxy(:,ind_N);

TCD_grad_box_N = TCD_grad(ind_N);
OCD_grad_box_N = OCD_grad(ind_N);

mean_TCD_grad_box_N = nanmean(TCD_grad_box_N);
mean_OCD_grad_box_N = nanmean(OCD_grad_box_N);

mean_grad_temp_box_N = nanmean(grad_temp_box_N,2);
mean_grad_doxy_box_N = nanmean(grad_doxy_box_N,2);

mean_temp_box_N = nanmean(temp_box_N,2);
mean_doxy_box_N = nanmean(doxy_box_N,2);


% find the mean data bounded by the N box
ind_S = lat >= latlon_lim_box_S(1,1) & lat <= latlon_lim_box_S(1,2) & ...
    lon >= latlon_lim_box_S(2,1) & lon <= latlon_lim_box_S(2,2);  

lat_box_S = lat(ind_S);
lon_box_S = lon(ind_S);

temp_box_S = temp(:,ind_S);
doxy_box_S = doxy(:,ind_S);

grad_temp_box_S = grad_temp(:,ind_S);
grad_doxy_box_S = grad_doxy(:,ind_S);

TCD_grad_box_S = TCD_grad(ind_S);
OCD_grad_box_S = OCD_grad(ind_S);

mean_TCD_grad_box_S = nanmean(TCD_grad_box_S);
mean_OCD_grad_box_S = nanmean(OCD_grad_box_S);

mean_grad_temp_box_S = nanmean(grad_temp_box_S,2);
mean_grad_doxy_box_S = nanmean(grad_doxy_box_S,2);

mean_temp_box_S = nanmean(temp_box_S,2);
mean_doxy_box_S = nanmean(doxy_box_S,2);


% Plot Box N ===================================================
pr = 100;
figure('visible','off')
setfigsize(1300,750)

% Plot Dissolved Oxygen ===================================================

subaxis(1,2,1, 'Spacing', 0.03, 'Padding', 0.03, 'MR', 0.03,'ML', 0.03,'MB', 0.05,'MT', 0.05);

% bottom x axis
l1 = plot(mean_grad_doxy_box_N,-1*ave_pres(:,1),'k','linewidth',3);
% l1 = plot(grad_doxy_box_N(:,pr),-1*ave_pres(:,1),'k','linewidth',3);
ax1 = gca; % current axes

xlabel(ax1,'Dissolved Oxygen Gradient ($\mu mol/kg/dbar$)')
ylabel(ax1,'Pressure ($dbar$)')
yt = yticks;
yticklabels(ax1,sprintfc('%d',-1*yt))

% top x axis
ax1_pos = ax1.Position; % position of first axes
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');

ax2.XColor = 'r';

l5 = line(mean_doxy_box_N,-1*pres,'Parent',ax2,'Color','r','linewidth',5);
% l5 = line(doxy_box_N(:,pr),-1*pres,'Parent',ax2,'Color','r','linewidth',5);
xlims = xlim;
x = xlims(1):xlims(2); y = ones(size(x));
l6 = line(x,-1*mean_OCD_grad_box_N.*y,'Parent',ax2,'linewidth',3,'Color','k', 'linestyle',':');
% l6 = line(x,-1*OCD_grad_box_N(:,pr).*y,'Parent',ax2,'linewidth',3,'Color','k', 'linestyle',':');


xlabel(ax2,'Dissolved Oxygen ($\mu mol/kg$)')
yt = yticks;
yticklabels(ax2,sprintfc('%d',-1*yt))

% legend
% l = legend( [l1;l2;l3;l4;l5;l6] ,...
%     {'Unsmoothed','Window Length = 5','Window Length = 10','Window Length = 15','Profile','OCD/TCD'});
% set(l,'Position',[0.185 0.18 0.15 0.2]) % x,y,w,h


% Plot Temperature ========================================================

subaxis(1,2,2, 'Spacing', 0.03, 'Padding', 0.03, 'MR', 0.03,'ML', 0.03,'MB', 0.05,'MT', 0.05);
l1 = plot(mean_grad_temp_box_N,-1*ave_pres(:,1),'k','linewidth',3);
% l1 = plot(grad_temp_box_N(:,pr),-1*ave_pres(:,1),'k','linewidth',3);
ax1 = gca; % current axes
xlabel(ax1,'Temperature Gradient ($^\circ C/dbar)$')
ylabel(ax1,'Pressure ($dbar$)')
yt = yticks;
yticklabels(ax1,sprintfc('%d',-1*yt))

ax1_pos = ax1.Position; % position of first axes
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');

ax2.XColor = 'r';

l5 = line(mean_temp_box_N,-1*pres, 'Parent',ax2,'Color','r','linewidth',5);
% l5 = line(temp_box_N(:,pr),-1*pres, 'Parent',ax2,'Color','r','linewidth',5);
xlims = xlim;
x = xlims(1):xlims(2); y = ones(size(x));
l6 = line(x,-1*mean_TCD_grad_box_N.*y,'Parent',ax2,'linewidth',3,'Color','k', 'linestyle',':');
% l6 = line(x,-1*TCD_grad_box_N(:,pr).*y,'Parent',ax2,'linewidth',3,'Color','k', 'linestyle',':');

% create inset with location of profile
hf1=gcf;                                   
axes('parent',hf1,'position',[0.67 0.15 0.15 0.3]);  % x y width height
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
lat_lon_bound_box(latlon_lim_box_N(1,1),latlon_lim_box_N(1,2),latlon_lim_box_N(2,1),latlon_lim_box_N(2,2))

m_scatter(lon_bb,lat_bb,200,'y.'); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k','xtick',([30, 60, 90, 120]), 'ytick',([-20,0,20]));
title('Bounding Box')


xlabel(ax2,'Temperature ($^\circ C$)')
yt = yticks;
yticklabels(ax2,sprintfc('%d',-1*yt))


% save png
% outfn = ['Box_N_Profile_' num2str(pr) '.png'];
outfn = 'Box_N_Mean_Profile.png';
print(gcf,[outfp outfn],'-dpng','-r300'); 


% Plot Box S ===================================================

pr = 100;
figure('visible','off')
setfigsize(1300,750)

% Plot Dissolved Oxygen ===================================================

subaxis(1,2,1, 'Spacing', 0.03, 'Padding', 0.03, 'MR', 0.03,'ML', 0.03,'MB', 0.05,'MT', 0.05);

% bottom x axis
l1 = plot(mean_grad_doxy_box_S,-1*ave_pres(:,1),'k','linewidth',3);
% l1 = plot(grad_doxy_box_S(:,pr),-1*ave_pres(:,1),'k','linewidth',3);
ax1 = gca; % current axes

xlabel(ax1,'Dissolved Oxygen Gradient ($\mu mol/kg/dbar$)')
ylabel(ax1,'Pressure ($dbar$)')
yt = yticks;
yticklabels(ax1,sprintfc('%d',-1*yt))

% top x axis
ax1_pos = ax1.Position; % position of first axes
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');

ax2.XColor = 'r';

l5 = line(mean_doxy_box_S,-1*pres,'Parent',ax2,'Color','r','linewidth',5);
% l5 = line(doxy_box_S(:,pr),-1*pres,'Parent',ax2,'Color','r','linewidth',5);
xlims = xlim;
x = xlims(1):xlims(2); y = ones(size(x));
l6 = line(x,-1*mean_OCD_grad_box_S.*y,'Parent',ax2,'linewidth',3,'Color','k', 'linestyle',':');
% l6 = line(x,-1*OCD_grad_box_S(:,pr).*y,'Parent',ax2,'linewidth',3,'Color','k', 'linestyle',':');


xlabel(ax2,'Dissolved Oxygen ($\mu mol/kg$)')
yt = yticks;
yticklabels(ax2,sprintfc('%d',-1*yt))

% legend
% l = legend( [l1;l2;l3;l4;l5;l6] ,...
%     {'Unsmoothed','Window Length = 5','Window Length = 10','Window Length = 15','Profile','OCD/TCD'});
% set(l,'Position',[0.185 0.18 0.15 0.2]) % x,y,w,h


% Plot Temperature ========================================================

subaxis(1,2,2, 'Spacing', 0.03, 'Padding', 0.03, 'MR', 0.03,'ML', 0.03,'MB', 0.05,'MT', 0.05);
l1 = plot(mean_grad_temp_box_S,-1*ave_pres(:,1),'k','linewidth',3);
% l1 = plot(grad_temp_box_S(:,pr),-1*ave_pres(:,1),'k','linewidth',3);
ax1 = gca; % current axes
xlabel(ax1,'Temperature Gradient ($^\circ C/dbar)$')
ylabel(ax1,'Pressure ($dbar$)')
yt = yticks;
yticklabels(ax1,sprintfc('%d',-1*yt))

ax1_pos = ax1.Position; % position of first axes
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');

ax2.XColor = 'r';

l5 = line(mean_temp_box_S,-1*pres, 'Parent',ax2,'Color','r','linewidth',5);
% l5 = line(temp_box_S(:,pr),-1*pres, 'Parent',ax2,'Color','r','linewidth',5);
xlims = xlim;
x = xlims(1):xlims(2); y = ones(size(x));
l6 = line(x,-1*mean_TCD_grad_box_S.*y,'Parent',ax2,'linewidth',3,'Color','k', 'linestyle',':');
% l6 = line(x,-1*TCD_grad_box_S(:,pr).*y,'Parent',ax2,'linewidth',3,'Color','k', 'linestyle',':');


xlabel(ax2,'Temperature ($^\circ C$)')
yt = yticks;
yticklabels(ax2,sprintfc('%d',-1*yt))


% save png
% outfn = ['Box_S_Profile_' num2str(pr) '.png'];
outfn = 'Box_S_Mean_Profile.png';
print(gcf,[outfp outfn],'-dpng','-r300'); 


