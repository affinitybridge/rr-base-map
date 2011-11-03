Resource Roads Base Map
=======================

This map is based on the TileMill's Open Streets DC, with some tweaks to colours, localized data, and contours.

Preparing the data
==================

Make sure to index all files using shapeindex so they are fast:

>     $ shapeindex *.shp

Shapefiles may also need to be reprojected into 900913, mostly for ease of use but sometimes to clean up problems with the file:

>     $ ogr2ogr data_900913.shp data.shp -t_srs EPSG:900913 -s_srs EPSG:4326

The data for this project is available from a number of sources, detailed below.

OpenStreetMap
---------------

A lot of the base data is from OpenStreetMap, which you can download from CloudMade's regional extracts here:
  > <http://downloads.cloudmade.com/americas/northern_america/canada/british_columbia/british_columbia.shapefiles.zip>

Running the following commands will index and make these files more manageable as zips:

>     $ unzip british_columbia.shapefiles.zip
>     $ cd british_columbia.shapefiles
>     $ shapeindex *.shp
>     $ for i in *.shp; do \
>     zip `basename $i .shp` `basename $i shp`*; done

OpenStreetMap data is used for the following layers:

- **#highway** - canada\_canada\_british\_columbia\_highway.zip
- **#highway-outline** - canada\_canada\_british\_columbia_highway.zip
- **#highway-label** - canada\_canada\_british\_columbia_highway.zip
- **#location** - canada\_canada\_british\_columbia_location.zip
- **#natural** - canada\_canada\_british\_columbia_natural.zip

Finally, you need two versions of shoreline data for different zoom levels. You can usually find these by searching the web as they are somewhat common and generated from OpenStreetMap. Newer versions of TileMill may come with their own versions. Both are in 900913 Web Mercator projection.

- **#shoreline\_300** - coarse data - <http://tile.openstreetmap.org/shoreline_300.tar.bz2>
- **#processed\_p** - highly detailed data - <http://tile.openstreetmap.org/processed_p.tar.bz2>

GeoBC
-----

Local data was downloaded from GeoBC, a service provided by the province:

> <http://geobc.gov.bc.ca/>

Click 'Download' -> 'Free Data', then 'Guest Users Enter Here' to access the catalogue. The easiest way to find data is to use their search feature.

Specifically, you need to search for data for the following layers:

- **#resource-roads** - 'DRA - Digital Road Atlas', downloaded filename: DRA\_LINESP\_DPC
- **#rivers** - 'Freshwater Atlas Watersheds', downloaded filename: FWRVRSPL
- **#districts**, **#districts-label** - 'FADM - District', downloaded filename: FADM\_DIST

Since GeoBC limits the file size you can download, when you submit your order you may need to select an 'Area of Interest' before downloading. This is especially true for the Digital Road Atlas, which is quite big.

GeoBC files are only available in BC Albers projection, TileMill should be able to autodetect this, but if not here is more information about the projection <http://spatialreference.org/ref/epsg/3005/>, it may be convenient to reproject to 900913.

In this version of the base map the Resource Roads are pulled from the Digital Road Atlas shapefile, in reality we are planning to pull this directly from PostGIS. For an example of what this configuration looks like, see example:

![PostGIS configuration screen](https://github.com/affinitybridge/rr-base-map/raw/master/postgis-config.png)

Contours
--------

Contours were created using this handy guide from Mapbox:

> <http://mapbox.com/tilemill/docs/tutorials/terrain-data/>

Following are the steps taken to produce the required files. In this project, the contours are used for the **#hill-shade** and **#slope-shade** layers. You will need GDAL installed, easiest is by installing GDAL complete from:

> <http://www.kyngchaos.com/software/frameworks>

The contours are GeoTIFFs created from Digital Elevation Model data available from NASA's Shuttle Radar Topography Mission (SRTM) mission and cleaned up by CGIAR:

> <http://srtm.csi.cgiar.org/>
  
You can download manually using their selection tool <http://srtm.csi.cgiar.org/SELECTION/inputCoord.asp> (you need at least tiles from 10-13 in the X direction and 1-3 in the Y) or run this command:

>     $ curl -O http://srtm.csi.cgiar.org/SRT-ZIP/SRTM_V41/SRTM_Data_GeoTiff/srtm_[10-13]_0[1-3].zip

The CGIAR server is really slow, so you might have to leave this running for a while. The following commands also take a little while and result in about 4GB of files.

Once you have all the data, unzip, place files in same directory, and then merge into one giant geoTIFF:

>     $ gdal_merge.py -o bc.tif *.tif

Reproject from WGS84 to Web Mercator (same as 900913):

>     $ gdalwarp -s_srs EPSG:4326 -t_srs EPSG:3785 -r bilinear bc.tif bc-3785.tif

Create hillshade:

>     $ gdaldem hillshade -co compress=lzw bc-3785.tif bc-hillshade-3785.tif

Generate slope (this file is not used in the stylesheet):

>     $ gdaldem slope bc-3785.tif bc-slope-3785.tif

Create a file called <code>slope-ramp.txt</code> with the following contents:

>     0 255 255 255
>     90 0 0 0

Finally, generate shopeshade:

>     $ gdaldem color-relief -co compress=lzw bc-slope-3785.tif slope-ramp.txt bc-slopeshade-3785.tif
  
This is all you need to basic shading, by using multiply and raster layer opacity you can create a pretty decent effect.

Colour shading
--------------

Although not currently used on this project, if you'd like to play around with colour shading, create a file called <code>ramp.txt</code> with the following:

>     0 184 222 230
>     5 184 222 230
>     6 46 154 88
>     1000 0 168 3
>     1800 155 155 155
>     3010 215 244 244

Each point in the gradation maps an elevation to an RBG
value, you can find statistic about the elevation by
running:

>     $ gdalinfo -stats bc-3785.tif

To generate a color shaded GeoTIFF:

>     $ gdaldem color-relief bc-3785.tif ramp.txt bc-color-3785.tif

Other
-----

Mapbox hosts some nice data for administrative boundaries
like country and state lines. These are included in the
project using a URL, check other TileMill projects for
newer links if these are unavailable:

- **#country\_border** - <http://tilemill-data.s3.amazonaws.com/natural-earth-10m-1.3.0/admin_0_boundary_lines_land.zip>
- **#state\_line** - <http://tilemill-data.s3.amazonaws.com/natural-earth-10m-1.3.0/admin_1_states_provinces_lines_shp.zip>
