# Prototypes

Early scripts written while developing the thesis code, kept to show how the method
evolved. They are superseded by [`../src`](../src); only their file paths were updated.
Each one reads the same data folders as the main pipeline.

| Script | Original name | What it does |
|---|---|---|
| `sites_airports.m` | `Border_Aero.m` | Candidate site set 1: the 15 international airports, each with a 300 mi range circle |
| `sites_vor_dme.m` | `Border_DME.m` | Candidate site set 2: the 15 VOR/DME sites with a 250 mi range circle. This is the set kept for the study |
| `sites_mountain_peaks.m` | `Border_Peek.m` | Candidate site set 3: the 10 highest Romanian peaks, each with a 300 mi range circle |
| `try1_dem_and_los.m` | `Try_1.m` | First end-to-end script: DEM mosaic, border and station map; its "line of sight" only lifts a range circle by the terrain height |
| `try2_terrain_los.m` | `Try_2.m` | First ray-based terrain line of sight at FL60, the algorithm later used in steps 6 and 7 |
| `try5_random_points.m` | `TRry_5.m` | Monte Carlo test of three-station coverage on 100 random points; abandoned for the grid count of steps 8 and 9 |

Requirements: the three `sites_*` scripts need the Mapping Toolbox (`shaperead`) and the
Image Processing Toolbox (`viscircles`); `try1` and `try2` rebuild the DEM, so they need
the SRTM tiles in `data/srtm/`.

`try5_random_points.m` is left as it was abandoned: it draws the FL60 line of sight, then
stops at the random-point check because `&&` receives a vector
(`point_elevation <= line_of_sight_altitude`).
