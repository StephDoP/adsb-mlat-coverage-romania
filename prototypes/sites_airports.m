% PROTOTYPE - candidate site set 1: international airports (thesis section 5.1)
% Original file: Border_Aero.m. Plots the 15 airports with a 300 mi range circle (viscircles: Image Processing Toolbox).
% Superseded by src/ - kept for reference, see prototypes/README.md.

clear 
clc

root = fileparts(fileparts(mfilename('fullpath')));   % repository root

tic

mm=12003;
nn=7202;

% Load the country border shapefile
shapefile = fullfile(root, 'data', 'border', 'ro_frontiera_poligon.shp');
S = shaperead(shapefile);

% Import airport coordinates
coordinates = fullfile(root, 'data', 'sites', 'site_coordinates.xlsx');
coord = readtable(coordinates, 'Range', 'C4:E20', 'ReadVariableNames', true);
latAero = str2double(coord{:, 3});
lonAero = str2double(coord{:, 2});
names=coord{:,1};

% Define the geographical coordinates
latref = 43;
lonref = 20;
pixel_size = 3 / 3600; % 1 arc-minute to degrees

% Convert pixel coordinates to geographical coordinates
lon_grid = lonref + (0:(mm-1)) * pixel_size;
lat_grid = latref + (0:(nn-1)) * pixel_size;

% Plot the border
latref=48.2460;
longref=26.7251;
lat=(S.Y-S.Y(1))/1852/60+latref;
lon=(S.X-S.X(1))/1852/60/cosd(45)+longref;

figure
plot(lon, lat)
hold on
plot(latAero, lonAero, 'ro')

for i = 1:numel(latAero)
    if names{i}=="Baia Mare Airport" || names{i}=="Aurel Vlaicu Bucharest"
    text(latAero(i), lonAero(i), names{i}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
    else 
        text(latAero(i), lonAero(i), names{i}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom')
    end

    % Plot circle
    lat_center = latAero(i);
    lon_center = lonAero(i);
    radius_miles = 300;
    radius_deg = radius_miles / 69; % Convert radius to degrees 
    viscircles([lat_center, lon_center], radius_deg, 'Color', 'b', 'LineStyle', '-', 'LineWidth', 0.2);

end
hold off

axis equal


toc