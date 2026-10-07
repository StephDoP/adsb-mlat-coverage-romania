% STEP 9 - Share of Romanian territory covered by 0, 1, 2 and 3+ stations
% Thesis Appendix A-9 "Coverage Percentage" (Figure 5.31)
%
% Same coverage count as step 8, restricted to the grid points inside the
% border. MLAT needs at least 3 receiving stations (4 for an independent
% altitude), so the "3 or more antennas" share is the headline result.
% Prints the percentages and draws one pie chart per flight level.
%
% In : data/processed/los_ranges.mat, antennas.mat, border.mat
%
% Runtime: ~3 min, mostly the inpolygon test against the 33848-point border.

clear
clc

root = fileparts(fileparts(mfilename('fullpath')));   % repository root
processed = fullfile(root, 'data', 'processed');

load(fullfile(processed, 'antennas.mat'));
load(fullfile(processed, 'border.mat'));
load(fullfile(processed, 'los_ranges.mat'));

% Define figure titles corresponding to different elevation values
titles = {'ADS-B Coverage at FL60', 'ADS-B Coverage at FL80', 'ADS-B Coverage at FL100', 'ADS-B Coverage at FL120'};

% Initialize the figure for the pie charts
figure; 

% Compute 4 separate figures
for figure_idx = 1:4
    
    % Extract memlat and memlon values for the current plot
    memlat_current = memlat{figure_idx};
    memlon_current = memlon{figure_idx};
    
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
    
    % Get logical matrix for points inside the border
    inside_border = inpolygon(lonq, latq, lon, lat);
    total_points_border = sum(inside_border(:));
    
    % Compute the percentage of the area covered by 0, 1, 2, and 3 or more antennas inside the border
    perc_0 = sum(k(inside_border) == 0) / total_points_border * 100;
    perc_1 = sum(k(inside_border) == 1) / total_points_border * 100;
    perc_2 = sum(k(inside_border) == 2) / total_points_border * 100;
    perc_3_or_more = sum(k(inside_border) >= 3) / total_points_border * 100;
    
    fprintf('Coverage at %s:\n', titles{figure_idx});
    fprintf('0 antennas: %.2f%% of the area\n', perc_0);
    fprintf('1 antenna: %.2f%% of the area\n', perc_1);
    fprintf('2 antennas: %.2f%% of the area\n', perc_2);
    fprintf('3 or more antennas: %.2f%% of the area\n', perc_3_or_more);
    fprintf('\n');
    
    % Create a pie chart of the coverage percentages in the predefined figure
    subplot(2, 2, figure_idx);  % Create a new subplot for the pie chart
    pie([perc_0, perc_1, perc_2, perc_3_or_more], ...
        {['0 antennas: ', num2str(perc_0, '%.2f'), '%'], ...
         ['1 antenna: ', num2str(perc_1, '%.2f'), '%'], ...
         ['2 antennas: ', num2str(perc_2, '%.2f'), '%'], ...
         ['3 or more antennas: ', num2str(perc_3_or_more, '%.2f'), '%']});
    title(['Pie Chart of Coverage at ', titles{figure_idx}]);
end
