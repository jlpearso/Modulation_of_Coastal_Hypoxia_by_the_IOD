function setfigsize(w,h)

% w = width of figure
% h = height of figure

hF = gcf;
if nargin < 1
    hF.Position = [45, 1000000 1350,800];
elseif nargin<2 % set defaults for a 13 in laptop screen
    hF.Position = [45, 1000000 1350,h];
else
    hF.Position = [45, 1000000 w h];
end

end