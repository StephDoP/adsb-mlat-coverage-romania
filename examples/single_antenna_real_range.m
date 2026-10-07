% EXAMPLE - Real (terrain-limited) range of one ADS-B station at one flight level
%
% Reproduces the single-station figures of the thesis and the defense
% presentation (Constanta: Figures 5.13, 5.14, 5.17, 5.18 and 5.21) using
% the same line-of-sight computation as step 6. Choose any station and
% flight level below.
%
% In : data/processed/dem.mat, antennas.mat, border.mat

clear
clc

station = 5;          % row of the 'VOR & DME' sheet: 1 ARAD, 2 BACAU, 3 BRASOV, 4 CLUJ, 5 CONSTANTA,
                      % 6 CRAIOVA, 7 DEVA, 8 FLORESTI, 9 GALATI, 10 ROSIORI, 11 SATU MARE,
                      % 12 SUCEAVA, 13 STREJNIC, 14 TG JIU, 15 TULCEA
flight_level = 100;   % the thesis used FL60, FL80, FL100 and FL120
rotate_view = false;  % true: spin the 3-D view once around the vertical axis

root = fileparts(fileparts(mfilename('fullpath')));   % repository root
processed = fullfile(root, 'data', 'processed');
assert(isfile(fullfile(processed, 'dem.mat')), 'dem.mat is missing: run download_dem (or step1_build_dem) first.')

load(fullfile(processed, 'dem.mat'))
load(fullfile(processed, 'antennas.mat'));
load(fullfile(processed, 'border.mat'));

elevation_FL = flight_level*100/3.281;

figure;

plot(lon, lat)
hold on
scatter3(lonDME, latDME, altitude_meters, 'ro')

drawnow;

for i = station
    lat_center = latDME(i);
    lon_center = lonDME(i);
    radius_miles = 250;
    radius_deg = radius_miles / 69; % Convert radius to degrees

    % Plot names of antennas
    text(lonDME(i), latDME(i), names{i}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')

    % Compute elevation (real+marigain)
    elevation_point = altitude_meters(i)+10;

    % Generate line of sight points
    num_points = 100; % Number of points for the circular line of sight
    theta = linspace(0, 2*pi, num_points);
    line_of_sight_lon = lonDME(i) + radius_deg * cos(theta)/cosd(latDME(i));
    line_of_sight_lat = latDME(i) + radius_deg * sin(theta);
    line_of_sight_altitude = elevation_FL*ones(1,length(theta));

    x=0:0.01:1;

    for ii=1:length(theta)
        latp=latDME(i)+(line_of_sight_lat(ii)-latDME(i))*x;
        lonp=lonDME(i)+(line_of_sight_lon(ii)-lonDME(i))*x;
        alt=elevation_point+(line_of_sight_altitude(ii)*x);
        teren=interp2(lon_grid, lat_grid, rotatedZ, lonp, latp);
        ijk=find(alt<teren,1);
        if ~isempty(ijk)
            line_of_sight_lon(ii)=lonp(ijk);
            line_of_sight_lat(ii)=latp(ijk);
            line_of_sight_altitude(ii)=teren(ijk);
        end
    end

    % Plot line of sight
    plot3(line_of_sight_lon, line_of_sight_lat, line_of_sight_altitude, 'r-', 'LineWidth',1.25);
    drawnow;
end

legend("Border", "Antenna Position (lon, lat, m)", "Line of Sight");

% convert the elevation_FL back to flight levels
FL = elevation_FL * 3.281 / 100;

title(['ADS-B Antenna Real Range for elevation FL', num2str(FL)]);
xlabel('LATITUDE (°)')
ylabel('LONGITUDE (°)')
axis equal

hold off;

% Spin the 3-D view once (the presentation version of this demo looped forever)
if rotate_view
    elevation = 45; % elevation angle
    for azimuth = 45:0.5:405
        view(azimuth, elevation);
        pause(0.01);
    end
end
