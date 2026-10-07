% PROTOTYPE - candidate site set 2: VOR/DME sites (the set adopted in src/)
% Original file: Border_DME.m. Plots the 15 VOR/DME sites with a 250 mi range circle (viscircles: Image Processing Toolbox).
% Superseded by src/ - kept for reference, see prototypes/README.md.

clear 
clc

root = fileparts(fileparts(mfilename('fullpath')));   % repository root


load(fullfile(root, 'data', 'processed', 'border.mat'), '');
load(fullfile(root, 'data', 'processed', 'dem.mat'));


% Import airport coordinates from the second sheet
coordinates = fullfile(root, 'data', 'sites', 'site_coordinates.xlsx');
sheetName = 'VOR & DME'; 
coord = readtable(coordinates, 'Sheet', sheetName, 'Range', 'C3:F18', 'ReadVariableNames', true);
latDME = coord{:, 3};
lonDME = coord{:, 4};
names=coord{:,1};
altitude_feet=coord{:,2};
altitude_meters = altitude_feet * 0.3048; % Convert altitude from feet to meters


figure
plot(lon, lat)
hold on
scatter3(lonDME, latDME, altitude_meters, 'ro')
for i = 1:numel(latDME)
    
    % Plot circle
    lat_center = latDME(i);
    lon_center = lonDME(i);
    radius_miles = 250;
    radius_deg = radius_miles / 69; % Convert radius to degrees 
    viscircles([lon_center, lat_center], radius_deg, 'Color', 'b', 'LineStyle', '-', 'LineWidth', 0.2);

    %Plot names
    text(lonDME(i), latDME(i), names{i}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
end
hold off
legend ("ADS-B Range", "Antenna Position (lon,lat,m)");


axis equal
