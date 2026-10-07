function download_dem()
%DOWNLOAD_DEM  Download the pre-built DEM (data/processed/dem.mat, ~95 MB).
%
%   dem.mat is the output of step1_build_dem: SRTM 1 arc-second elevation
%   of 43-49 N, 20-30 E down-sampled 3x3. It is attached to the GitHub
%   release because it is too large to keep in the repository itself.
%   Steps 3, 6, 7 and the example need it; steps 4, 5, 8 and 9 do not.

url = 'https://github.com/StephDoP/adsb-mlat-coverage-romania/releases/latest/download/dem.mat';
dest = fullfile(fileparts(mfilename('fullpath')), 'data', 'processed', 'dem.mat');

if isfile(dest)
    fprintf('dem.mat is already in place: %s\n', dest);
    return
end

fprintf('Downloading %s (~95 MB) ...\n', url);
part = [dest '.part'];   % so an interrupted download never looks complete
websave(part, url, weboptions('Timeout', 120));
movefile(part, dest);
fprintf('Saved %s\n', dest);
end
