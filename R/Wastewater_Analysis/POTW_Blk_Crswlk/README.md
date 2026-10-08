\# SOP / Methodology for Running the POTW–Census Block Buffer Overlap Workflow



\## Purpose

This workflow identifies census blocks that intersect buffered POTW locations and calculates the percent of each block covered by POTW buffers at \*\*1 mile, 3 miles, and 5 miles\*\*.



The output is:

\- one CSV per buffer distance

\- one row per intersecting block piece

\- fields including:

&#x20; - block area

&#x20; - overlap area

&#x20; - decimal overlap

&#x20; - percent overlap



\---



\# 1) Required input data



Before running the script, make sure you have the following datasets updated and available.



\## A. Census block boundary files

Obtain these, as needed, by running this .R script: "00\_Import\_Census\_Blks.R" contained within the root folder of this readme.



These are the state block shapefiles in the folder:



\- `blocks\_2020\_sf`



Each file should be a \*\*state-level shapefile\*\* named like:

\- `blocks\_2020\_AK.shp`

\- `blocks\_2020\_AL.shp`

\- etc.



\### Requirements

\- One shapefile of census blocks per state/territory

\- Rerun the .R script as needed to obtain newer tigerline boundaries.

\- Geometry must be valid

\- File names should remain consistent with the script expectations



\---



\## B. POTW point feature class

This sf is obtained by running "Active\_POTW\_Coords\_sf.R" as needed.

This should be the point feature class stored in a geodatabase:



\- `Active\_POTW\_Coords.gdb\\Active\_POTW\_Coords`



\### Requirements

\- Points should represent individual POTW systems

\- Coordinates must be correct

\- The dataset should be in \*\*WGS 1984 (EPSG:4326)\*\* or at least defined as such if it was created from latitude/longitude

\- If the point dataset is replaced or refreshed, the path in the script must be updated if it changes



\---



\# 2) Folder and output structure



The script uses three important workspace locations:



\## A. `blocks\_folder`

Contains the state shapefiles.



\## B. `temp\_gdb`

A working geodatabase used for:

\- importing shapefiles

\- projecting data

\- buffering POTW points

\- temporary selections and intersections



This can be cleared between runs if needed.



\## C. `out\_gdb`

This stores final geodatabase outputs, such as:

\- `overlap\_allstates\_1mi`

\- `overlap\_allstates\_3mi`

\- `overlap\_allstates\_5mi`



\## D. `export\_folder`

This stores the final CSV files:

\- `overlap\_allstates\_1mi.csv`

\- `overlap\_allstates\_3mi.csv`

\- `overlap\_allstates\_5mi.csv`



\---



\# 3) What must be updated before each run



Before running the script, confirm or update:



\## A. File paths

Make sure these paths are correct in the script:

\- `blocks\_folder`

\- `potw\_points`

\- `out\_gdb`

\- `temp\_gdb`

\- `export\_folder`



\## B. Input census block files

If state block shapefiles are updated:

\- replace the files in `blocks\_folder`

\- make sure filenames still match the `blocks\_2020\_XX.shp` pattern



\## C. POTW dataset

If the POTW dataset is updated:

\- replace or refresh the geodatabase feature class

\- confirm the feature class name is still `Active\_POTW\_Coords`

\- confirm the geometry and coordinates are still valid



\---



\# 4) Coordinate system requirements



\## Census blocks

The script projects block data to:

\- \*\*EPSG:5070\*\* (NAD 1983 Contiguous USA Albers)



This is used because it is appropriate for area calculations in square meters.



\## POTW points

The script assumes the POTW data are based on:

\- \*\*WGS 1984 (EPSG:4326)\*\*



If the source points are created from lat/long coordinates and have an unknown spatial reference, they must be defined correctly before running the script.



\---



\# 5) How the workflow works



For each buffer distance:

\- \*\*1 mile\*\*

\- \*\*3 miles\*\*

\- \*\*5 miles\*\*



the script does the following:



\## Step 1: Load POTW points

The POTW point dataset is copied to a temporary geodatabase and projected to EPSG:5070.



\## Step 2: Process each state block shapefile

For each state:

\- import shapefile into temp GDB

\- project to EPSG:5070

\- calculate block area



\## Step 3: Filter POTW points near the state

The script creates a \*\*5-mile envelope\*\* around the state blocks and selects only POTW points that fall inside that envelope.



This reduces the number of POTW buffers that need to be created.



\## Step 4: Buffer selected POTW points

Only POTW points near that state are buffered at the target distance.



\## Step 5: Select candidate blocks

The script identifies blocks that intersect the buffer.



\## Step 6: Identify blocks fully within the buffer

Blocks entirely inside the buffer are automatically assigned:

\- `percent\_overlap = 100`



\## Step 7: Intersect only partial blocks

Blocks that are only partially covered are passed to `PairwiseIntersect` to calculate exact overlap area.



\## Step 8: Append to master table

Results from each state are appended into a master output table for that buffer distance.



\## Step 9: Export to CSV

The final master table is exported to a CSV file.



\---



\# 6) Expected outputs



For each run, the script creates:



\## In the geodatabase

\- `overlap\_allstates\_1mi`

\- `overlap\_allstates\_3mi`

\- `overlap\_allstates\_5mi`



\## In the export folder

\- `overlap\_allstates\_1mi.csv`

\- `overlap\_allstates\_3mi.csv`

\- `overlap\_allstates\_5mi.csv`



\---



\# 7) What each output field means



\## `buffer\_dist`

The buffer distance used for that record:

\- `1mi`

\- `3mi`

\- `5mi`



\## `block\_area\_m2`

Total area of the census block in square meters.



\## `overlap\_m2`

Area of the block that intersects the POTW buffer, in square meters.



\## `decimal\_overlap`

Fraction of the block covered by the buffer:

\- `overlap\_m2 / block\_area\_m2`



\## `percent\_overlap`

Percent of block covered by the buffer:

\- `decimal\_overlap \* 100`



\---



\# 8) What to check after running



After the script finishes, verify:



\- each CSV was created

\- each output table exists in `out\_gdb`

\- row counts look reasonable

\- percent overlap values are between 0 and 100

\- no unexpected empty outputs



You should also spot-check a few records to ensure:

\- fully contained blocks have `percent\_overlap = 100`

\- partial blocks have values less than 100



\---



\# 9) Troubleshooting notes



\## If the script is very slow

Likely causes:

\- many POTW points near a state

\- many candidate blocks

\- many partial blocks needing exact intersection



\## If the script fails at the POTW point step

Check:

\- feature class path

\- coordinate system

\- whether the source points are really WGS84



\## If the script fails at import

Check:

\- shapefile names

\- file paths

\- locked temp GDB contents



\## If CSV export fails

Try exporting the existing geodatabase table manually using the safer cursor-based export function.



\---



\# 10) Best practices for future runs



\- Keep the input shapefile names consistent

\- Keep the POTW point feature class name consistent

\- Run the script from top to bottom in a fresh notebook session

\- Avoid having temp GDB outputs open in ArcGIS Pro during execution

\- If OneDrive causes locking issues, consider using a local non-synced folder for temp data



\---



\# 11) Short version for another analyst



If someone else runs this workflow, they should:



1\. Update the input paths in the script

2\. Confirm state block shapefiles are current and named correctly

3\. Confirm POTW points are current and correctly projected/defined

4\. Ensure the output and temp geodatabases exist

5\. Run the notebook from top to bottom

6\. Check the three CSV outputs in the export folder



\---



