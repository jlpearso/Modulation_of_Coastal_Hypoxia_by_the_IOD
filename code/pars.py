figpath = '../figures/'

hyp_thresh = 61

# total
lat_bounds = [-1.5, 33]
lon_bounds = [48.5, 102.5]

# regional 
bounds_wAS = [51.125,64,14.5,28]
bounds_eAS = [64,79.75,3,28]
# bounds_wAS = [51.125,66,14.5,28]
# bounds_eAS = [66,79,3,28]
bounds_eAS_SL = [79,83,3,7]
# bounds_wBoB = [79,87,2,28]
bounds_wBoB = [79,87,10.25,28]
bounds_wBoB_SL = [80,87,7,10]
bounds_eBoB = [87,103,0,28]

# these are for grouping into the IOD years since the effects are 
# not confined to a single year. You chose this to have an even 
# number of months around the IOD peak..but now you left it in
# line with the SLA plots that start in 06 and end in 05
IODyear_begin = '-06-01' # month-day of IOD year
IODyear_end = '-05-31' # month-day of year AFTER IOD year

cm_bounds = [48.5, 102.5,-1.5, 33]