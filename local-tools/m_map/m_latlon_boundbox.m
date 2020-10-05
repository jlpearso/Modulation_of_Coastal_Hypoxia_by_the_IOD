function h = m_latlon_boundbox(bbox_lims,varargin)
% I added this one

%bbox_lims = 2x2 matrix of corners of box wher row 1 is lat and row 2 is
%lon and column 1 is mins and column 2 is maxes

% Jenna Pearson 2020

global MAP_PROJECTION MAP_VAR_LIST

if isempty(MAP_PROJECTION)
  disp('No Map Projection initialized - call M_PROJ first!');
  return;
end

if nargin < 2
  help m_scatter
  return
end

% [x,y] = m_ll2xy(long,lat);
[x,y] = m_ll2xy(bbox_lims(2,:),bbox_lims(1,:));

h= rectangle('Position',[x(1),y(1),x(2)-x(1),y(2)-y(1)],varargin{:});

set(h,'tag','m_scatter');

if nargout == 0
  clear h
end

return



