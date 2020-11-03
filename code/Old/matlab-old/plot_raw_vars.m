close all; clear all; clc;

fname = 'Profiles_temp_psal_doxy.nc';
readncfile

% convert all to doubles - get some errors later if you don't
doxy = double(doxy);
temp = double(temp);
pres = double(pres);
psal = double(psal);

figure(1)
% setfigsize(1000,700)

subplot(1,3,1)
scatter(lon,lat,2,temp(1,:),'.')
% colorbar('Direction','reverse')
colorbar
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
title('Temperature')
xlabel('lon')
xlim([30,120])
ylabel('lat')
ylim([-20,30])
%caxis([20,160])

figure(1)
subplot(1,3,2)
scatter(lon,lat,2,psal(1,:),'.')
% colorbar('Direction','reverse')
colorbar
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
title('Salinty')
xlabel('lon')
xlim([30,120])
ylabel('lat')
ylim([-20,30])
%caxis([20,160])

subplot(1,3,3)
scatter(lon,lat,2,doxy(1,:),'.')
% colorbar('Direction','reverse')
colorbar
oldcmap = colormap('jet');
colormap( flipud(oldcmap) );
title('Oxygen')
xlabel('lon')
xlim([30,120])
ylabel('lat')
ylim([-20,30])
%caxis([20,160])

tightfig_w_cbar()



