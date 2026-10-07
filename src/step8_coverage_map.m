% STEP 8 - Coverage maps: number of stations seeing each point
% Thesis Appendix A-8 "Coverage Map" (Figure 5.27)
%
% Each station's real-range polygon (step 6) is rasterised onto a 0.05 deg
% grid (42-50 N, 19-30 E) with inpolygon; summing over the 15 stations gives
% how many stations cover each grid point at each flight level. White areas
% are not covered by any station.
%
% In : data/processed/los_ranges.mat, antennas.mat, border.mat

clear
clc

root = fileparts(fileparts(mfilename('fullpath')));   % repository root
processed = fullfile(root, 'data', 'processed');

load(fullfile(processed, 'antennas.mat'));
load(fullfile(processed, 'border.mat'));
load(fullfile(processed, 'los_ranges.mat'));

% Define figure titles corresponding to different elevation values
titles = {'ADS-B Coverage at FL60', 'ADS-B Coverage at FL80', 'ADS-B Coverage at FL100', 'ADS-B Coverage at FL120'};

% Compute 4 separate figures
for figure_idx = 1:4
    
    % Extract memlat and memlon values for the current plot
    memlat_current = memlat{figure_idx};
    memlon_current = memlon{figure_idx};
    
    figure;  % Creates a new figure window
    
    plot(lon, lat,'r', 'LineWidth', 2)
    hold on
    scatter3(lonDME, latDME, altitude_meters, 'ro')
    
    [N,M] = size(memlat_current);
    ilatq = 42:0.05:50;
    ilonq = 19:0.05:30;
    
    [lonq, latq] = meshgrid(ilonq,ilatq);
    [NN,MM] = size(lonq);
    
    k = zeros(NN,MM);
    
    for i = 1:N
        % Get the ellipse for the antenna
        lat_ellipse = memlat_current(i, :);
        lon_ellipse = memlon_current(i, :);
        
        % Check which points in the grid are inside the ellipse
        inside = inpolygon(lonq, latq, lon_ellipse, lat_ellipse);
        k = k + inside;  % 'inside' is now a matrix of the same size as 'lonq' and 'latq'.
    end
    
    contourf(ilonq, ilatq, k, 1:N+1);
    colorbar
    title(titles{figure_idx});
    xlabel('LATITUDE (°)')
    ylabel('LONGITUDE (°)')
    
    hold off

end
