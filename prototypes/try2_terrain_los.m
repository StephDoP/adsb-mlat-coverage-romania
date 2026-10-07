% PROTOTYPE - first ray-based terrain line of sight (FL60 only)
% Original file: Try_2.m. The ray-casting loop that became steps 6 and 7.
% Superseded by src/ - kept for reference, see prototypes/README.md.

clear 
clc

root = fileparts(fileparts(mfilename('fullpath')));   % repository root

lat = 43:48; % 6
lon = 20:29; % 10

a = []; % stores coordinate
b = []; % final
c = []; % row

%compute the matrix without last column
for i = 6:-1:1
    a = [];
    c = [];
    for j = 1:10
        nume = fullfile(root, 'data', 'srtm', ['n' num2str(lat(i)) '_e0' num2str(lon(j)) '_1arc_v3.tif']);
        if isfile(nume)
            a = imread(nume);
        else
            disp(nume)
            a = a * 0;
        end
        c = [c a];
    end
    b = [b; c];
end

% Scale down the matrix
[n, m] = size(b);
nn = floor(n / 3);
mm = floor(m / 3);
b_0 = zeros(nn, mm);

for ii = 1:nn
    for jj = 1:mm
        for i = (ii - 1) * 3 + 1:ii * 3
            for j = (jj - 1) * 3 + 1:jj * 3
                b_0(ii, jj) = max(b_0(ii, jj), b(i, j));
            end
        end
    end
end

mm = 12003;
nn = 7202;

% Load the country border shapefile
shapefile = fullfile(root, 'data', 'border', 'ro_frontiera_poligon.shp');
S = shaperead(shapefile);

% Import airport coordinates from the second sheet
coordinates = fullfile(root, 'data', 'sites', 'site_coordinates.xlsx');
sheetName = 'VOR & DME'; 
coord = readtable(coordinates, 'Sheet', sheetName, 'Range', 'C3:F16', 'ReadVariableNames', true);
latDME = coord{:, 3};
lonDME = coord{:, 4};
names = coord{:, 1};
altitude_feet = coord{:, 2};
altitude_meters = altitude_feet * 0.3048; % Convert altitude from feet to meters

% Define the geographical coordinates
latref = 43;
lonref = 20;
pixel_size = 3 / 3600; % 1 arc-minute to degrees

% Convert pixel coordinates to geographical coordinates
lon_grid = lonref + (0:(mm-1)) * pixel_size;
lat_grid = latref + (0:(nn-1)) * pixel_size;

% Plot the border
latref = 48.2460;
longref = 26.7251;
lat = (S.Y - S.Y(1)) / 1852 / 60 + latref;
lon = (S.X - S.X(1)) / 1852 / 60 / cosd(45) + longref;

% figure
% plot(lon, lat)
% hold on
% scatter3(lonDME, latDME, altitude_meters, 'ro')
% for i = 1:numel(latDME)
% 
%     % Plot circle
%     lat_center = latDME(i);
%     lon_center = lonDME(i);
%     radius_miles = 250;
%     radius_deg = radius_miles / 69; % Convert radius to degrees 
%     viscircles([lon_center, lat_center], radius_deg, 'Color', 'b', 'LineStyle', '-', 'LineWidth', 0.2);
% 
%     % Plot names
%     text(lonDME(i), latDME(i), names{i}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')
% end
% legend("ADS-B Range", "Antenna Position (lon, lat, m)");
% title("ADS-B Antennas Theoretical Range");
% hold off
% axis equal

% Rotate the surf image by 180 degrees around the X-axis
rotatedZ = flipud(b_0);

% Display the rotated surf image with geographical coordinates
% figure
% surf(lon_grid, lat_grid, rotatedZ, 'EdgeColor', 'none')
% title('Elevation map - Romania')
% view(45, 45)
% colorbar
% axis([20 30 43 49])

% % Plot the border at Z=3000
% hold on
% plot3(lon, lat, ones(size(lon)) * 3000, 'r', 'LineWidth', 2)

hold off

% Calculate line of sight for each antenna based on the elevation map
figure
plot(lon, lat)
hold on
scatter3(lonDME, latDME, altitude_meters, 'ro')
elevetion_FL=60*100*0.303;
for i = 1:numel(latDME)
    lat_center = latDME(i);
    lon_center = lonDME(i);
    radius_miles = 250;
    radius_deg = radius_miles / 69; % Convert radius to degrees 
%    viscircles([lon_center, lat_center], radius_deg, 'Color', 'b', 'LineStyle', '-', 'LineWidth', 0.2);

    % Plot names
    text(lonDME(i), latDME(i), names{i}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')

    % Compute line of sight based on elevation map
%    elevation_map = interp2(lon_grid, lat_grid, rotatedZ, lonDME(i), latDME(i));
    elevation_point = altitude_meters(i);

    % Generate circular line of sight points


    num_points = 100; % Number of points for the circular line of sight
    theta = linspace(0, 2*pi, num_points);
    line_of_sight_lon = lonDME(i) + radius_deg * cos(theta)/cosd(latDME(i));
    line_of_sight_lat = latDME(i) + radius_deg * sin(theta);
    line_of_sight_altitude = elevetion_FL*ones(1,length(theta));

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
    plot3(line_of_sight_lon, line_of_sight_lat, line_of_sight_altitude, 'r-', 'LineWidth',2);
end
legend("ADS-B Range", "Antenna Position (lon, lat, m)", "Line of Sight");
title("ADS-B Antenna Real Range");
hold off
axis equal

toc
