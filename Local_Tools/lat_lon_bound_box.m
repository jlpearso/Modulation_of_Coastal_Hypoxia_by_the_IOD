function lat_lon_bound_box(latmin, latmax, lonmin, lonmax,lw)

if nargin == 4
    lw = 2;
end

rectangle(latmin,lonmin,lonmax-lonmin,latmax-latmin,'LineWidth',lw) 

end

