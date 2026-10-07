% STEP 6 - ADS-B real (terrain-limited) range at FL60, FL80, FL100 and FL120
% Thesis Appendix A-6 "ADS-B Real Range" (Figure 5.26)
%
% For every station, 100 rays are cast from the antenna (site elevation
% + 10 m) towards its theoretical range limit (step 5). The ray climbs
% linearly by the flight-level altitude over its length; the terrain under
% it is interpolated from the DEM and the range along that bearing is cut
% at the first sample where the ray is below the terrain.
%
% In : data/processed/dem.mat, antennas.mat, border.mat
% Out: data/processed/los_ranges.mat  (memlon, memlat: 1x4 cell, one per
%      flight level, each 15 stations x 100 bearings) - used by steps 8, 9
%
% Runtime: ~14 min (15 stations x 4 flight levels x 100 rays).

clear
clc

root = fileparts(fileparts(mfilename('fullpath')));   % repository root
processed = fullfile(root, 'data', 'processed');
assert(isfile(fullfile(processed, 'dem.mat')), 'dem.mat is missing: run download_dem (or step1_build_dem) first.')

load(fullfile(processed, 'dem.mat'))
load(fullfile(processed, 'antennas.mat'));
load(fullfile(processed, 'border.mat'));

elevation_FL_vals = [60*100/3.281, 80*100/3.281, 100*100/3.281, 120*100/3.281];

memlat=[];
memlon=[];

figure;

for subplot_idx = 1:4

    elevation_FL = elevation_FL_vals(subplot_idx);
    
    subplot(2, 2, subplot_idx);

    % Initialize for each subplot
    memlat{subplot_idx} = [];
    memlon{subplot_idx} = [];
    
    plot(lon, lat)
    hold on
    scatter3(lonDME, latDME, altitude_meters, 'ro')
    
    drawnow;

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
        
        % Store values in the current cell
        memlon{subplot_idx} = [memlon{subplot_idx}; line_of_sight_lon];
        memlat{subplot_idx} = [memlat{subplot_idx}; line_of_sight_lat];
        
        drawnow;
    end

    legend("Border", "Antenna Position (lon, lat, m)", "Line of Sight");

   % convert the elevation_FL back to flight levels
    FL = elevation_FL * 3.281 / 100;
    
    title(['ADS-B Antenna Real Range for elevation FL', num2str(FL)]);
    xlabel('LATITUDE (°)')
    ylabel('LONGITUDE (°)')
    axis equal
    
end

hold off;

save(fullfile(processed, 'los_ranges.mat'), 'memlon', 'memlat')
