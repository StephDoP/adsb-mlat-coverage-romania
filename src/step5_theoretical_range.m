% STEP 5 - Theoretical (terrain-free) range of each ADS-B station
% Thesis Appendix A-5 "ADS-B Theoretical Range" (Figure 5.12)
%
% Draws the ideal coverage limit of every station: radius 250 mi converted
% with 69 mi per degree of latitude, with the longitude extent divided by
% cos(latitude), hence ellipses in degree coordinates.
%
% In : data/processed/border.mat, data/sites/site_coordinates.xlsx
% Out: data/processed/antennas.mat  (names, latDME, lonDME, altitude_meters)
%      - the station table used by steps 6 to 9

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

num_points = 100; % Number of points for the circular line of sight
theta = linspace(0, 2*pi, num_points);
lon = lonDME(i) + radius_deg * cos(theta)/cosd(latDME(i));
lat = latDME(i) + radius_deg * sin(theta);

plot(lon,lat)
drawnow;
% pause(1);

end
axis equal;
legend("ARAD ADS-B Range",'Antenna Position (lon,lat,m)','BRASOV ADS-B Range','CLUJ ADS-B Range','CONSTANTA ADS-B Range','CRAIOVA ADS-B Range','DEVA ADS-B Range','FLORESTI ADS-B Range','GALATI ADS-B Range','ROSIORI ADS-B Range','SATU MARE ADS-B Range','SUCEAVA ADS-B Range','STREJNIC ADS-B Range','TG JIU ADS-B Range','TULCEA ADS-B Range',"BACAU ADS-B Range");
title("ADS-B Antennas Theoretical Range");
grid on;
xlabel('LATITUDE (°)')
ylabel('LONGITUDE (°)')


save(fullfile(root, 'data', 'processed', 'antennas.mat'), 'altitude_meters','latDME','lonDME','names')
