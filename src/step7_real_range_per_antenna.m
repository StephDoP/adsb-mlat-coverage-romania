% STEP 7 - Real range of each station, one subplot per station
% Thesis Appendix A-7 "MATRIX" (Figures 5.15, 5.16, 5.19, 5.20, 5.22-5.25)
%
% Same terrain line-of-sight computation as step 6, plotted per station:
% two figures per flight level (stations 1-9 and 10-15), eight in total.
%
% In : data/processed/dem.mat, antennas.mat, border.mat
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

memlat = cell(60,1);
memlon = cell(60,1);

% Loop over flight levels
for FL_idx = 1:4
    elevation_FL = elevation_FL_vals(FL_idx);

    % Loop over two figures for each flight level
    for fig_idx = 1:2
        figure;

        % Determine number of subplots based on the figure index
        if fig_idx == 1
            num_subplots = min(9, numel(latDME));
            subplot_rows = 3; subplot_cols = 3;
        else
            num_subplots = min(6, numel(latDME)-9);
            subplot_rows = 2; subplot_cols = 3;
        end

        % Convert the elevation_FL back to flight levels
        FL = elevation_FL * 3.281 / 100;

        % Set the title for the figure
        sgtitle(['ADS-B Antenna Real Range for elevation FL', num2str(FL), ', Figure ', num2str(fig_idx)]);

        % Loop over subplots
        for subplot_idx = 1:num_subplots
            antenna_idx = (fig_idx - 1)*9 + subplot_idx;

            subplot(subplot_rows, subplot_cols, subplot_idx);
            plot(lon, lat)
            hold on
            scatter3(lonDME(antenna_idx), latDME(antenna_idx), altitude_meters(antenna_idx), 'ro')

            grid on; % Adding grid
            drawnow;

            lat_center = latDME(antenna_idx);
            lon_center = lonDME(antenna_idx);
            radius_miles = 250;
            radius_deg = radius_miles / 69; % Convert radius to degrees 

            % Plot names of antennas
            text(lonDME(antenna_idx), latDME(antenna_idx), names{antenna_idx}, 'HorizontalAlignment', 'center', 'VerticalAlignment', 'top')

            % Compute elevation (real+marigain)
            elevation_point = altitude_meters(antenna_idx)+10;

            % Generate line of sight points
            num_points = 100; % Number of points for the circular line of sight
            theta = linspace(0, 2*pi, num_points);
            line_of_sight_lon = lonDME(antenna_idx) + radius_deg * cos(theta)/cosd(latDME(antenna_idx));
            line_of_sight_lat = latDME(antenna_idx) + radius_deg * sin(theta);
            line_of_sight_altitude = elevation_FL*ones(1,length(theta));

            x=0:0.01:1;

            for ii=1:length(theta)
                latp=latDME(antenna_idx)+(line_of_sight_lat(ii)-latDME(antenna_idx))*x;
                lonp=lonDME(antenna_idx)+(line_of_sight_lon(ii)-lonDME(antenna_idx))*x;
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
            memlon{antenna_idx} = line_of_sight_lon;
            memlat{antenna_idx} = line_of_sight_lat;

            drawnow;
            xlabel('LATITUDE (°)')
            ylabel('LONGITUDE (°)')
            % legend("Border", "Antenna Position (lon, lat, m)", "Line of Sight");
            axis equal
        end
    end
end

hold off;
