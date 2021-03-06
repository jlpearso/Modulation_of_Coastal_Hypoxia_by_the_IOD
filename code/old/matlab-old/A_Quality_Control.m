close all; clear all; clc; warning off;
%% Setup ==================================================================
%{

    This code applies quality control, reformats,

%}
%==========================================================================

%--------------------------------------------------------------------------
% Parameters
%--------------------------------------------------------------------------

plot_fig = 1;       % set to 1 to plot figs, 0 to supress
qc_thresh = 5;     % the min no. of pts that must be in each profile

%--------------------------------------------------------------------------
% Paths
%--------------------------------------------------------------------------

% define and add function path
addpath(genpath('../../../Local_Tools/'))

% add data path
addpath(genpath('../../../Data/'))

outfp = '../../../Figures/Testing/Data_Processing/';
outdp = '../../../Data/Testing/Processed/';

%--------------------------------------------------------------------------
% Filesnames
%--------------------------------------------------------------------------

indfn = 'Profiles_temp_psal_doxy.nc';
outdfn = ['Profiles_qc_thresh_' num2str(qc_thresh) '_processed.mat'];

%--------------------------------------------------------------------------
% Other
%--------------------------------------------------------------------------

% set default figure properties
figprops;

% if the output directory doesn't exist create it
if ~exist(outdp, 'dir')
    mkdir(outdp)
elseif ~exist(outfp, 'dir')
    mkdir(outfp)
end

% load the data
infn = indfn;
readncfile

%% Formatting =============================================================
%{
    Many of the functions I use later on require these to all be of the
    same type. I also create date string variables and group by month,
    season, and year as well. This introduces a string version of the type
    of data too.
%}
%==========================================================================

% convert all to doubles
doxy = double(doxy);
temp = double(temp);
struc.pres = double(pres);
psal = double(psal);
struc.prof = double(prof);
struc.type = double(type);
struc.lat = double(lat);
struc.lon = double(lon);
struc.time = double(time);

% create dates
base = datenum('01-01-1800 00:00:00');
struc.date_number = base + double(time);
struc.date_string = datestr(struc.date_number);

[struc.years,struc.months,struc.days] = ymd(datetime(struc.date_string));

for mm = 1:length(struc.months)
    
    % group into seasons
    if struc.months(mm) == 3 || struc.months(mm) == 4 || struc.months(mm) == 5
        struc.seasons(mm) = 1;
        struc.seasons_str{mm} = 'MAM';
    elseif struc.months(mm) == 6 || struc.months(mm) == 7 || struc.months(mm) == 8
        struc.seasons(mm) = 2;
        struc.seasons_str{mm} = 'JJA';
    elseif struc.months(mm) == 9 || struc.months(mm) == 10 || struc.months(mm) == 11
        struc.seasons(mm) = 3;
        struc.seasons_str{mm} = 'SON';
    else
        struc.seasons(mm) = 4;
        struc.seasons_str{mm} = 'DJF';
    end
    
    
    % add in a string version of the type
    if struc.type(mm) == 0
        struc.type_str{mm} = 'ARGO CTD';
    elseif struc.type(mm) == 1
        struc.type_str{mm} = 'ARGO BGC';
    elseif struc.type(mm) == 2
        struc.type_str{mm} = 'WOD';
    else
        struc.seasons_str{mm} = 'GO SHIP';
    end
end


% subset for lats and lons of interest

%% Quality Control ========================================================
%{
    The section makes sure that there are at least 10 points along a
    profile so that the gradient can be accurately found. If there are less
    than 10 points in a given profile, the whole profile is set to NaNs. It
    applies on a variable by variable basis so that there can be some
    profiles that are NaNs when they lack data but others that are not.
%}
%==========================================================================

vars = {doxy,temp,psal};
varnames = {'doxy','temp','psal'};

% variable to count the number of profiles affected

for vv = 1:length(vars)
    
    struc.(varnames{vv}) = vars{vv};
    qc_struc.([varnames{vv} '_qc_counter']) = 0;
    qc_struc.([varnames{vv} '_total_no_pr']) = 0;
    qc_struc.([varnames{vv} '_qc_lats']) = [];
    qc_struc.([varnames{vv} '_qc_lons']) = [];
    qc_struc.([varnames{vv} '_qc_pr_no']) = [];
    qc_struc.([varnames{vv} '_qc_pr_type']) = [];
    
    for pp = 1:length(doxy)
    
        tmpvar = vars{vv}(:,pp);
        upper_tmpvar = tmpvar(pres>=300);
        
        % check to make sure it isn't empty and has fewer pts than the
        % threshold
        if ~isempty(tmpvar(~isnan(tmpvar)))
            if length(tmpvar(~isnan(tmpvar))) <= qc_thresh

                qc_struc.([varnames{vv} '_qc_counter']) = qc_struc.([varnames{vv} '_qc_counter']) + 1;
                qc_struc.([varnames{vv} '_qc_lats']) = [qc_struc.([varnames{vv} '_qc_lats']) lat(pp)];
                qc_struc.([varnames{vv} '_qc_lons']) = [qc_struc.([varnames{vv} '_qc_lons']) lon(pp)];
                qc_struc.([varnames{vv} '_qc_pr_no']) = [qc_struc.([varnames{vv} '_qc_pr_no']) prof(pp)];
                qc_struc.([varnames{vv} '_qc_pr_type']) = [qc_struc.([varnames{vv} '_qc_pr_type']) type(pp)];

                struc.(varnames{vv})(:,pp) = NaN(size(tmpvar));
                % check to make sure its not empty and that it has data above
                % 500m
            end
            
            % only consider profiles that aren't all nans to begin with
            qc_struc.([varnames{vv} '_total_no_pr']) = qc_struc.([varnames{vv} '_total_no_pr'])+1;
            
        end
    end
end

% plot profiles affected

if plot_fig == 1
    
    %----------------------------------------------------------------------
    % Bar Charts For QC Stats
    %----------------------------------------------------------------------
%     figure('visible','off')
    figure
    setfigsize(1200,800)
    
    % plot the total number of each variable that were affected
    subaxis(1,2,1, 'Spacing', 0.03, 'Padding', 0.03, 'MR', 0.03,'ML', 0.03,'MB', 0.05,'MT', 0.05);
    
    qc_bars=[qc_struc.doxy_qc_counter qc_struc.temp_qc_counter qc_struc.psal_qc_counter];
    colors = {[0 0.4470 0.7410],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880]};
    
    h = bar(1:3,qc_bars,'FaceColor','flat');
    for bb = 1:3
        h.CData(bb,:) = colors{bb};
    end
    set(gca,'xticklabel',varnames)
    
    title(['No.of QCed Profiles (Less Than ' num2str(qc_thresh)  ' Data Pts)'])
    
    % plot as a percentage of total profiles of each variable
    subaxis(1,2,2, 'Spacing', 0.03, 'Padding', 0.03, 'MR', 0.03,'ML', 0.03,'MB', 0.05,'MT', 0.05);
    
    tot_bars=[qc_struc.doxy_total_no_pr qc_struc.temp_total_no_pr qc_struc.psal_total_no_pr];
    per_bars = round((qc_bars./tot_bars).*100,2);
    colors = {[0 0.4470 0.7410],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880]};
    
    h = bar(1:3,per_bars,'FaceColor','flat');
    for bb = 1:3
        h.CData(bb,:) = colors{bb};
    end
    set(gca,'xticklabel',varnames)
    
    title('Percentage of QCed Profiles')
    
    % save png
    outfn = ['Profile_qc_numbers_qc_thresh_' num2str(qc_thresh)  '.png'];
    print(gcf,[outfp outfn],'-dpng','-r300'); 

    %----------------------------------------------------------------------
    % Locations For QC Stats and Type
    %----------------------------------------------------------------------
    
%     figure('visible','off')
    figure
    setfigsize(1800,400)
    
    colors = {[0 0.4470 0.7410],[0.4940 0.1840 0.5560],[0.4660 0.6740 0.1880],[0.8500 0.3250 0.0980]};
    colormat = [[0 0.4470 0.7410];[0.4940 0.1840 0.5560];...
        [0.4660 0.6740 0.1880];[0.8500 0.3250 0.0980]];
    
    for vv = 1:length(vars)
        
        % plot color coded locations of profiles that are affected by type
        subaxis(1,3,vv, 'Spacing', 0.01, 'Padding', 0.015, 'MR',0.01, 'ML',0.01, 'MT',0.1, 'MB',0.2);

        m_proj('mercator','longitudes',[30,120], ...
                   'latitudes',[-20,30]);
        hold on

        for gg = 0:3
            
            ind = qc_struc.([varnames{vv} '_qc_pr_type']) == gg;
            
            if ~isempty(qc_struc.([varnames{vv} '_qc_lons'])(ind))
                tmplon = qc_struc.([varnames{vv} '_qc_lons'])(ind);
                tmplat = qc_struc.([varnames{vv} '_qc_lats'])(ind);
                tmptype = qc_struc.([varnames{vv} '_qc_pr_type'])(ind);

                m_scatter(tmplon,tmplat,200,colors{gg+1},'.');
            end
        end
        
        m_coast('patch',[.7 .7 .7],'edgecolor','none');
        m_grid('background color','k','xtick',([30, 60, 90, 120]), 'ytick',([-20,0,20]));
        
        title(['QCed ' varnames{vv} ' Profile Locations'])
        
        if vv == 3
            % custom legend
            h1 = m_plot(NaN,NaN,'.','markersize',20,'color',colors{1});
            h2 = m_plot(NaN,NaN,'.','markersize',20,'color',colors{2});
            h3 = m_plot(NaN,NaN,'.','markersize',20,'color',colors{3});
            h4 = m_plot(NaN,NaN,'.','markersize',20,'color',colors{4});

            l = legend([h1;h2;h3;h4],'ARGO CTD','ARGO BCG','World Ocean Database','GO SHIP','fontsize',16);
            set(l,'orientation','horizontal');
            pos = get(l,'position');
            set(l,'Position',[0.5-(pos(3)/2) 0.05 pos(3) pos(4)]) % x,y,w,h
            set(l,'color','w')
            
        end
    end
    
    % save png
    outfn = ['Profile_qc_locations_qc_thresh_' num2str(qc_thresh)  '.png'];
    print(gcf,[outfp outfn],'-dpng','-r300'); 


end

%% Data Info ==============================================================
%{
    The section sets all ther relevant info of the data for easy access
%}
%==========================================================================
% 
% % order the field names alphabetically so that they match the 
struc = orderfields(struc);
varnames = fieldnames(struc);
units = {'days','Date','day','umol/kg','degrees N (+) and S (-)',...
    'degrees E (+) and W (-)','months',...
    'dbar','N/A','g/kg', 'N/A','N/A','degress C','days','N/A','N/A',...
    'years'};
description = {'Matlab Datenumber: Days Since January 0, 0000',...
    'Date of Measurement','Day of Measurement','Dissolved Oxygen',...
    'Latitude','Longitude','Month of Measurement','Pressure',...
    'Profile Number','Practical Salinity','Season of Measurement Number',...
    'Season of Measurement String','Temperature','Days Since 01-01-1800',...
    'Platform: 0 = ARGO CTD, 1 = ARGO BCG, 2 = World Ocean Database, 3 = GO SHIP',...
    'Platform String','Year of Measurement'};

for vv = 1:length(varnames)
    struc.DataInfo(vv).Name = varnames{vv};
    struc.DataInfo(vv).Units = units{vv};
    struc.DataInfo(vv).Description = description{vv};
end

struc.qc_struc = qc_struc;

% save the data
save([outdp outdfn],'-struct','struc','-v7.3');