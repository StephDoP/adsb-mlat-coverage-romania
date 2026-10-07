% STEP 4 - Positions of the 15 ADS-B ground stations
% Thesis Appendix A-4 "ADS-B Antenna Positions" (Figure 5.9)
%
% One ADS-B antenna is placed at each Romanian VOR/DME site. Coordinates
% and site elevations (ft) come from the 'VOR & DME' sheet of
% data/sites/site_coordinates.xlsx.
%
% In : data/processed/border.mat, data/sites/site_coordinates.xlsx

clear
clc

root = fileparts(fileparts(mfilename('fullpath')));   % repository root

load(fullfile(root, 'data', 'processed', 'border.mat'));


% Import DME coordinates from Excel
coordinates = fullfile(root, 'data', 'sites', 'site_coordinates.xlsx');
sheetName = 'VOR & DME';
coord = readtable(coordinates, 'Sheet', sheetName, 'Range', 'C3:F18', 'ReadVariableNames', true);
latDME = coord{:, 3};
lonDME = coord{:, 4};
names=coord{:,1};
altitude_feet=coord{:,2};
altitude_meters = altitude_feet /3.281; % Convert altitude from feet to meters


figure
plot(lon, lat)
hold on
scatter3(lonDME, latDME, altitude_meters, 'ro')

for i = 1:numel(latDME)
    lat_center = latDME(i);
    lon_center = lonDME(i);
    radius_miles = 250;
    radius_deg = radius_miles / 69; % Convert radius to degrees

    % Plot names of antennas
    text(lonDME(i), latDME(i), names{i}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')

end
axis equal;
legend("Romanian Border",'Antenna Position (lon,lat,m)');
title("ADS-B Antenna Positions");
grid on;
xlabel('LATITUDE (°)')
ylabel('LONGITUDE (°)')
