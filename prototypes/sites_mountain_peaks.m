% PROTOTYPE - candidate site set 3: the 10 highest peaks (thesis section 5.1)
% Original file: Border_Peek.m. Plots the peaks with a 300 mi range circle (viscircles: Image Processing Toolbox).
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

% Import airport coordinates from the second sheet
coordinates = fullfile(root, 'data', 'sites', 'site_coordinates.xlsx');
sheetName = 'peeks'; 
coord = readtable(coordinates, 'Sheet', sheetName, 'Range', 'B3:F13', 'ReadVariableNames', true);
latPeek = coord{:, 5};
lonPeek = coord{:, 4};
names=coord{:,2};
altitude=coord{:,3};


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
plot(latPeek, lonPeek, 'ro')
for i = 1:numel(latPeek)
    
    % Plot circle
    lat_center = latPeek(i);
    lon_center = lonPeek(i);
    radius_miles = 300;
    radius_deg = radius_miles / 69; % Convert radius to degrees 
    viscircles([lat_center, lon_center], radius_deg, 'Color', 'b', 'LineStyle', '-', 'LineWidth', 0.2);

    %Plot names
    text(latPeek(i), lonPeek(i), names{i}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
end
hold off

axis equal

toc