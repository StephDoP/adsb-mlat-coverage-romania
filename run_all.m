function run_all()
%RUN_ALL  Run the whole simulation chain (thesis Appendix A-1 to A-9) in order.
%
%   Steps 1 and 2 rebuild inputs that are already provided (border.mat ships
%   with the repository, dem.mat comes from download_dem), so they only run
%   when their output is missing. Steps 6 and 7 take ~14 min each, step 9
%   ~3 min, the rest a few seconds. Each step can also run on its own from src/.

root = fileparts(mfilename('fullpath'));
processed = fullfile(root, 'data', 'processed');

if ~isfile(fullfile(processed, 'dem.mat'))
    tiles = dir(fullfile(root, 'data', 'srtm', '*_1arc_v3.tif'));
    if numel(tiles) < 59
        error('dem.mat is missing. Run download_dem, or put the 59 SRTM tiles in data/srtm (see data/README.md).')
    end
    run_step(root, 'step1_build_dem')
end
if ~isfile(fullfile(processed, 'border.mat'))
    run_step(root, 'step2_romanian_border')
end

steps = {'step3_dem_and_border', 'step4_antenna_positions', 'step5_theoretical_range', ...
         'step6_real_range', 'step7_real_range_per_antenna', 'step8_coverage_map', ...
         'step9_coverage_percentage'};
for k = 1:numel(steps)
    run_step(root, steps{k})
end
end

function run_step(root, name)
t0 = tic;
run_script(fullfile(root, 'src', [name '.m']))
fprintf('%s finished in %.0f s\n', name, toc(t0));
end

function run_script(file)
% Every step starts with `clear`, so each one gets a workspace of its own.
run(file)
end
