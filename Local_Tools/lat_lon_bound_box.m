function lat_lon_bound_box(latmin, latmax, lonmin, lonmax,lw)

if nargin == 4
    lw = 2;
end

rectangle(latmin,lonmin,... % (a,b) = lower left corner,
    lonmax-lonmin,... % width
    latmax-latmin,... % height
    'LineWidth',lw) 

end

