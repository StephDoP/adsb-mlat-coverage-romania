% PROTOTYPE - abandoned Monte Carlo check of >= 3 station coverage
% Original file: TRry_5.m. Replaced by the grid count of steps 8 and 9; does not run to completion.
% Superseded by src/ - kept for reference, see prototypes/README.md.

root = fileparts(fileparts(mfilename('fullpath')));   % repository root

%check if 100 random points are all inside 3 antenna coverage

tic
load(fullfile(root, 'data', 'processed', 'dem.mat'));
load(fullfile(root, 'data', 'processed', 'antennas.mat'));
toc

% Elevation map matrix dimensions
mm=12003;
nn=7202; 

% Load the country border shapefile
shapefile = fullfile(root, 'data', 'border', 'ro_frontiera_poligon.shp');
S = shaperead(shapefile);


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

% Calculate line of sight for each antenna based on the elevation map
figure
plot(lon, lat)
hold on
scatter3(lonDME, latDME, altitude_meters, 'ro')
elevetion_FL=60*100*0.303;
drawnow;
toc
memlat=[];
memlon=[];
for i = 1:numel(latDME)
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
    memlon=[memlon;line_of_sight_lon];
    memlat=[memlat;line_of_sight_lat];
    drawnow;
    toc
end
legend("ADS-B Range", "Antenna Position (lon, lat, m)", "Line of Sight");
title("ADS-B Antenna Real Range");
hold off
axis equal

toc

% Get min and max of lat and lon to generate random points inside them
min_lat = min(lat);
max_lat = max(lat);
min_lon = min(lon);
max_lon = max(lon);

% Generate 100 random points inside the border
random_lat = min_lat + rand(100,1) * (max_lat - min_lat);
random_lon = min_lon + rand(100,1) * (max_lon - min_lon);

% Initialize a matrix to store how many antennas cover each point
point_coverage = zeros(100, 1);

% Check if each point is inside the coverage of each antenna
for i = 1:numel(latDME)
    % Get the coordinates of the antenna's line of sight
    antenna_lon = memlon((i-1)*num_points+1:i*num_points);
    antenna_lat = memlat((i-1)*num_points+1:i*num_points);

    % Create a polygon for the antenna's coverage area
    coverage_area = polyshape(antenna_lon, antenna_lat);

    % Check if each point is inside the coverage area
    for j = 1:100
        % Get the elevation at the random point
        elevation_at_point = interp2(lon_grid, lat_grid, rotatedZ, random_lon(j), random_lat(j));

        % Add 10 to the elevation to be above the matrix
        point_elevation = elevation_at_point + 10;

        % Check if the point is inside the coverage area and below the antenna's elevation
        if isinterior(coverage_area, random_lon(j), random_lat(j)) && point_elevation <= line_of_sight_altitude
            point_coverage(j) = point_coverage(j) + 1;
        end
    end
end

% Find which points are covered by at least 3 antennas
covered_points = find(point_coverage >= 3);

% Print the number of points covered by at least 3 antennas
disp(['Number of points covered by at least 3 antennas: ' num2str(length(covered_points))])

% Plot the points covered by at least 3 antennas
figure
plot(lon, lat)
hold on
scatter3(random_lon(covered_points), random_lat(covered_points), point_elevation(covered_points), 'go')
title('Points covered by at least 3 antennas')
hold off
axis equal
