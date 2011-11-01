/**********************************************************

Open Streets, DC
================

*An example of street-level map design.*

Data used by this map is © OpenStreetMap contributors, 
CC-BY-SA. See <http://openstreetmap.org> for more info.

This map makes use of OpenStreetMap shapefile extracts
provided by CloudMade at <http://downloads.cloudmade.com>.
You can swap out the DC data with any other shapefiles 
provided by CloudMade to get a map of your area.

To prepare a CloudMade shapefiles zip package for TileMill,
download it and run the following commands:

    unzip your_area.shapefiles.zip
    cd your_area.shapefiles
    shapeindex *.shp
    for i in *.shp; do \
        zip `basename $i .shp` `basename $i shp`*; done

***********************************************************/

/* PALETTE */
@water:#D6E5F5;
@forest:#D6E7B0;
/*@land:#D9D9D9;*/
@land:#FFFFFF;

Map {
  background-color:#B2B2B2;
}

.natural[TYPE='water'][zoom>=9],
.water[zoom>=9] {
  polygon-fill:@water;
}

#rivers[zoom>=8][zoom<10] {
  line-color:@water;
  line-width:0.5;
}

.natural[TYPE='forest'][zoom>7],
#park_polygons[zoom>7] {
  polygon-fill:@forest;
  polygon-opacity: 0.6;
}

/*.glacier[zoom>7] { polygon-fill: #fff; polygon-opacity: 0.5; }*/

#color-relief,
#hill-shade,
#slope-shade {
    raster-scaling: bilinear;
    raster-mode: multiply;
}
#hill-shade {
  raster-opacity: 0.3;
}
#slope-shade {
  raster-opacity: 0.4;
}

/* These are not used, but if customizing this style you may
wish to use OSM's land shapefiles. See the wiki for info:
<http://wiki.openstreetmap.org/wiki/Mapnik#World_boundaries> */
#shoreline_300[zoom<8],
#processed_p[zoom>=8] {
  polygon-fill: @land;
}

/* Add the provinces and countries, based on data from road_trip */
#country_border::glow[zoom>2] {
  line-color:#ddd;
  line-opacity:0.33;
  line-width:4;
}

#country_border { line-color:#000; }
#country_border[zoom<3] { line-width:0.4; }
#country_border[zoom=3] { line-width:0.6; }
#country_border[zoom=4] { line-width:0.8; }
#country_border[zoom=5] { line-width:1.0; }

#state_line::glow[ADM0_A3='USA'],
#state_line::glow[ADM0_A3='CAN'] {
  [zoom>2] {
    line-color:#fff;
    line-opacity:0.2;
    line-width:3;
  }
}
#state_line[ADM0_A3='USA'],
#state_line[ADM0_A3='CAN'] {
  [zoom>2] {
    line-dasharray:2,2,10,2;
    line-width:0.6;
  }
}

.district[zoom>3][zoom<10] {
  line-color: #555;
  line-width: 0.1;
  [zoom>4] { line-width: 0.25; }
  [zoom>5] { line-width: 0.6; }
}

.district-label[zoom<10] {
  [zoom>5] {
    text-face-name:@font_reg;
    text-halo-radius:2;
    text-placement:interior;
    text-transform:uppercase;
    text-name:"[DIST_NAM]";
    text-fill:spin(darken(@motorway,70),-15);
    text-halo-fill:lighten(@motorway,8);
    /*text-min-padding: 1;*/
    text-wrap-width: 50;
    text-line-spacing: 5;
  }
  [zoom=7] { text-size:11; }
  [zoom=8] { text-size:12; }
  [zoom=9] { 
    text-size: 13;
    text-character-spacing:2;
  }
}

/*
.district[ORG_UNIT='DPC'] {
  polygon-pattern-file:url(textures/paperfolds_256.png);
}*/
