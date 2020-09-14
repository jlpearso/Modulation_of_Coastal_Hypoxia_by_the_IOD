% close all;
% close all; clear all; clc;
% 
% % define and add function path
% addpath(genpath('Local_Tools/'))
% 
% outfp = 'Figures/';
% 
% plot_fig = 0;
% 
% fname = 'Profiles_temp_psal_doxy.nc';
% readncfile
% 
% % convert all to doubles - get some errors later if you don't
% doxy = double(doxy);
% temp = double(temp);
% pres = double(pres);
% psal = double(psal);
% lat = double(lat);
% lon = double(lon);
% 
% %% Gradients %%
% 
% % find differences
% diff_doxy = diff(doxy);
% 
% diff_temp = diff(temp);
% 
% diff_pres = diff(pres);
% 
% ave_pres = 0.5.*(circshift(pres,-1) + pres);
% ave_pres = ave_pres(1:end-1);
% ave_pres = repmat(ave_pres, [1,size(diff_temp,2)]);
% 
% grad_doxy = diff_doxy./diff_pres;
% grad_temp = diff_temp./diff_pres;
% 
% % smooth the gradient with a running mean
% grad_doxy_sm_5 = movmean(grad_doxy,5,'omitnan');
% grad_temp_sm_5 = movmean(grad_temp,5,'omitnan');
% 
% grad_doxy_sm_10 = movmean(grad_doxy,10,'omitnan');
% grad_temp_sm_10 = movmean(grad_temp,10,'omitnan');
% 
% grad_doxy_sm_15 = movmean(grad_doxy,15,'omitnan');
% grad_temp_sm_15 = movmean(grad_temp,15,'omitnan');
% 
% [grad_temp_max,grad_temp_ind] = max(abs(grad_temp));
% [grad_doxy_max,grad_doxy_ind] = max(abs(grad_doxy));
% 
% [grad_temp_max_sm_5,grad_temp_ind_sm_5] = max(abs(grad_temp_sm_5));
% [grad_doxy_max_sm_5,grad_doxy_ind_sm_5] = max(abs(grad_doxy_sm_5));
% 
% [grad_temp_max_sm_10,grad_temp_ind_sm_10] = max(abs(grad_temp_sm_10));
% [grad_doxy_max_sm_10,grad_doxy_ind_sm_10] = max(abs(grad_doxy_sm_10));
% 
% [grad_temp_max_sm_15,grad_temp_ind_sm_15] = max(abs(grad_temp_sm_15));
% [grad_doxy_max_sm_15,grad_doxy_ind_sm_15] = max(abs(grad_doxy_sm_15));
% 
% % take centered pressures of these values
% TCD_grad = ave_pres(grad_temp_ind);
% OCD_grad = ave_pres(grad_doxy_ind);
% 
% TCD_grad_sm_5 = ave_pres(grad_temp_ind_sm_5);
% OCD_grad_sm_5 = ave_pres(grad_doxy_ind_sm_5);
% 
% TCD_grad_sm_10 = ave_pres(grad_temp_ind_sm_10);
% OCD_grad_sm_10 = ave_pres(grad_doxy_ind_sm_10);
% 
% TCD_grad_sm_15 = ave_pres(grad_temp_ind_sm_15);
% OCD_grad_sm_15 = ave_pres(grad_doxy_ind_sm_15);
% 
% % set the places where there wasn't a minimum to NaN
% TCD_grad(isnan(grad_temp_max))=nan;
% OCD_grad(isnan(grad_doxy_max))=nan;
% 
% TCD_grad_sm_5(isnan(grad_temp_max_sm_5))=nan;
% OCD_grad_sm_5(isnan(grad_doxy_max_sm_5))=nan;
% 
% TCD_grad_sm_10(isnan(grad_temp_max_sm_10))=nan;
% OCD_grad_sm_10(isnan(grad_doxy_max_sm_10))=nan;
% 
% TCD_grad_sm_15(isnan(grad_temp_max_sm_15))=nan;
% OCD_grad_sm_15(isnan(grad_doxy_max_sm_15))=nan;

pr = 306110; % AS = 305118 | double 305000 | bad one? 304100 | good ctd tcd 30000 | shelf 30400/30500
% surface with not tcd really 306100 | goot tcd/ocd 306050 | confusing 306110;

figure
setfigsize(1600,800)
ps = 1000; % 50,26
subplot(1,2,1)
l1 = plot(grad_doxy(:,pr),-1*ave_pres(:,pr),'k','linewidth',3);
ax1 = gca; % current axes
hold(ax1,'on')
l2 = plot(grad_doxy_sm_5(:,pr),-1*ave_pres(:,pr),'m','linewidth',2);
l3 = plot(grad_doxy_sm_10(:,pr),-1*ave_pres(:,pr),'b','linewidth',2);
l4 = plot(grad_doxy_sm_15(:,pr),-1*ave_pres(:,pr),'g','linewidth',2);
% yline(OCD_grad_sm_5(pr),':m','linewidth',2)
% yline(OCD_grad_sm_10(pr),':b','linewidth',2)
% yline(OCD_grad_sm_15(pr),':g','linewidth',2)
xlabel(ax1,'Dissolved Oxygen Gradient (\mu mol/kg/dbar)')
ylabel(ax1,'Pressure (dbar)')
yt = yticks;
yticklabels(ax1,sprintfc('%d',-1*yt))

ax1_pos = ax1.Position; % position of first axes
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');

ax2.XColor = 'r';

l5 = line(doxy(:,pr),-1*pres,'Parent',ax2,'Color','r','linewidth',5);
xlims = xlim;
x = xlims(1):xlims(2); y = ones(size(x));
l6 = line(x,-1*OCD_grad(pr).*y,'Parent',ax2,'linewidth',3,'Color','k', 'linestyle',':');
line(x,-1*OCD_grad(pr).*y,'Parent',ax2,'linewidth',3,'Color','k', 'linestyle',':');
line(x,-1*OCD_grad_sm_5(pr).*y,'Parent',ax2,'linewidth',3,'Color','m', 'linestyle',':');
line(x,-1*OCD_grad_sm_10(pr).*y,'Parent',ax2,'linewidth',3,'Color','b', 'linestyle',':');
line(x,-1*OCD_grad_sm_15(pr).*y,'Parent',ax2,'linewidth',3,'Color','g', 'linestyle',':');


xlabel(ax2,'Dissolved Oxygen (\mu mol/kg)')
yt = yticks;
yticklabels(ax2,sprintfc('%d',-1*yt))

l = legend( [l1;l2;l3;l4;l5;l6] ,...
    {'Unsmoothed','Window Length = 5','Window Length = 10','Window Length = 15','Profile','OCD/TCD'});
set(l,'Position',[0.25 0.18 0.1 0.15])


subplot(1,2,2)
l1 = plot(grad_temp(:,pr),-1*ave_pres(:,pr),'k','linewidth',3);
ax1 = gca; % current axes
hold(ax1,'on')
l2 = plot(grad_temp_sm_5(:,pr),-1*ave_pres(:,pr),'m','linewidth',2);
l3 = plot(grad_temp_sm_10(:,pr),-1*ave_pres(:,pr),'b','linewidth',2);
l4 = plot(grad_temp_sm_15(:,pr),-1*ave_pres(:,pr),'g','linewidth',2);
xlabel(ax1,'Temperature Gradient (\circ C/dbar)')
ylabel(ax1,'Pressure (dbar)')
yt = yticks;
yticklabels(ax1,sprintfc('%d',-1*yt))

ax1_pos = ax1.Position; % position of first axes
ax2 = axes('Position',ax1_pos,...
    'XAxisLocation','top',...
    'YAxisLocation','right',...
    'Color','none');

ax2.XColor = 'r';

l5 = line(temp(:,pr),-1*pres,'Parent',ax2,'Color','r','linewidth',5);
xlims = xlim;
x = xlims(1):xlims(2); y = ones(size(x));
l6 = line(x,-1*TCD_grad(pr).*y,'Parent',ax2,'linewidth',3,'Color','k', 'linestyle',':');
line(x,-1*TCD_grad(pr).*y,'Parent',ax2,'linewidth',3,'Color','k', 'linestyle',':');
line(x,-1*TCD_grad_sm_5(pr).*y,'Parent',ax2,'linewidth',3,'Color','m', 'linestyle',':');
line(x,-1*TCD_grad_sm_10(pr).*y,'Parent',ax2,'linewidth',3,'Color','b', 'linestyle',':');
line(x,-1*TCD_grad_sm_15(pr).*y,'Parent',ax2,'linewidth',3,'Color','g', 'linestyle',':');


xlabel(ax2,'Temperature (\circ C)')
yt = yticks;
yticklabels(ax2,sprintfc('%d',-1*yt))

% create inset with location of profile
hf1=gcf;                                   
axes('parent',hf1,'position',[0.7 0.18 0.1 0.15]);  % x y width height
m_proj('mercator','longitudes',[30,120], ...
           'latitudes',[-20,30]);
hold on
m_scatter(lon(pr),lat(pr),200,'y.'); shading flat;
m_coast('patch',[.7 .7 .7],'edgecolor','none');
m_grid('background color','k');
title('Profile Location')
xlabel('Longitude')
ylabel('Latitiude')

set(findall(gcf,'-property','FontSize'),'FontSize',16)
if type(pr) == 0
    tp = 'ARGO CTD';
elseif type(pr) == 1
    tp = 'ARGO BGC';
elseif type(pr) == 2
    tp = 'WOD';
elseif type(pr) == 3
    tp = 'GO SHIP';
end

supertitle(['Profile Number: ' num2str(pr)  ' (' tp ')'],20);
tightfig_with_supertitle(gcf);

%%%%%
 %      add on the line with the calculated thermocline for each
 %      Find a few more int he location where the agreement without
 %      smoothing isn't great.
