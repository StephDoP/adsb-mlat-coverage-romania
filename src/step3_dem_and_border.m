% STEP 3 - DEM with the Romanian border overlaid
% Thesis Appendix A-3 "DEM and Border" (Figure 5.6)
%
% In : data/processed/border.mat, dem.mat

clear
clc

root = fileparts(fileparts(mfilename('fullpath')));   % repository root
processed = fullfile(root, 'data', 'processed');
assert(isfile(fullfile(processed, 'dem.mat')), 'dem.mat is missing: run download_dem (or step1_build_dem) first.')

load(fullfile(processed, 'border.mat'));
load(fullfile(processed, 'dem.mat'));

%Plot DEM
figure
% Plot every 6th sample: MATLAB R2025a and later cannot render the full
% 86-million-point surface
k = 6;
surf(lon_grid(1:k:end), lat_grid(1:k:end), rotatedZ(1:k:end, 1:k:end), 'EdgeColor', 'none')
title('Romania DEM')
view(0,90)
colorbar
xlabel('LATITUDE (°)')
ylabel('LONGITUDE (°)')
axis([20 30 43 49]);

hold on

% Add border on DEM Z=3000
hold on
plot3(lon, lat, ones(size(lon)) * 3000, 'r', 'LineWidth', 2)

hold off
