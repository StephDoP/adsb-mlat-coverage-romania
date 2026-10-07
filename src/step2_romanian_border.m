% STEP 2 - Romanian national border from the shapefile
% Thesis Appendix A-2 "Romanian Border" (Figure 5.5)
%
% Reads the border polygon (Stereo 70 projection, metres) and converts it to
% approximate geographic degrees by scaling from the first vertex, which is
% anchored at 48.2460 N, 26.7251 E (1 NM = 1 arc-minute of latitude,
% longitude scaled by cos 45 deg).
%
% In : data/border/ro_frontiera_poligon.shp
% Out: data/processed/border.mat  (S, lat, lon)
%
% Requires the Mapping Toolbox (shaperead). border.mat already ships with
% the repository, so this step is only needed to rebuild it.

clear
clc

root = fileparts(fileparts(mfilename('fullpath')));   % repository root

% Load the country border shapefile
shapefile = fullfile(root, 'data', 'border', 'ro_frontiera_poligon.shp');
S = shaperead(shapefile);

% Plot the border
latref=48.2460;
longref=26.7251;
lat=(S.Y-S.Y(1))/1852/60+latref;
lon=(S.X-S.X(1))/1852/60/cosd(45)+longref;

figure
plot(lon, lat)
title('Romanian Border');
legend('Romanian Border');
xlabel('LATITUDE (°)');
ylabel('LONGITUDE (°)');
grid on;

save(fullfile(root, 'data', 'processed', 'border.mat'), 'S','lat','lon')
