% STEP 1 - Digital Elevation Model (DEM) of Romania from SRTM tiles
% Thesis Appendix A-1 "Elevation Map" (Figures 5.3 and 5.4)
%
% Mosaics the 59 SRTM 1 arc-second GeoTIFF tiles covering 43-49 N, 20-30 E
% (n43_e029 does not exist and is filled with zeros), then down-samples the
% mosaic 3x3 by taking the maximum of each block (~3 arc-seconds, ~90 m).
%
% In : data/srtm/n{43..48}_e0{20..29}_1arc_v3.tif   (see data/README.md)
% Out: data/processed/dem.mat  (rotatedZ, lon_grid, lat_grid, mm, nn)
%
% Only needed to rebuild the DEM: dem.mat can be downloaded instead with
% download_dem.m. Needs several GB of RAM.

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
            a=a*0;
        end
        c = [c a];
    end
    b = [b; c];
end


%Scale down the matrix
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

% Elevation map matrix dimensions
mm=12003;
nn=7202;

% Rotate the surf image by 180 degrees around the X-axis
rotatedZ = flipud(b_0);

% Define the geographical coordinates
latref = 43;
lonref = 20;
pixel_size = 3 / 3600; % 1 arc-minute to degrees

% Convert pixel coordinates to geographical coordinates
lon_grid = lonref + (0:(mm-1)) * pixel_size;
lat_grid = latref + (0:(nn-1)) * pixel_size;

% Display the final form Elevation Map in geographical coordinates
figure
% Plot every 6th sample: MATLAB R2025a and later cannot render the full
% 86-million-point surface (dem.mat keeps the full grid)
k = 6;
surf(lon_grid(1:k:end), lat_grid(1:k:end), rotatedZ(1:k:end, 1:k:end), 'EdgeColor', 'none')
title('Digial Elevation Map (DEM)')
view(0,90)
colorbar
axis equal;
xlabel('LATITUDE (°)')
ylabel('LONGITUDE (°)')
axis([20 30 43 49]);


save(fullfile(root, 'data', 'processed', 'dem.mat'), 'rotatedZ','lon_grid','lat_grid','mm','nn')
