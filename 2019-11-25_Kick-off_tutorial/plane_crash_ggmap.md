ggmap
================

## Maps ⎪ get\_stamenmap( ) and ggmap( )

Use get\_stamenmap( ) to get a ggmap object of the site of the crash and
plot it using ggmap( ). You will have to get the latitude and longitude
coordinates from Google or enter the address directly in
<https://www.latlong.net>.

Note that stamenmaps do not cover the entire world.

If you are not registered with Google, you may need to install
devtools::install\_github(“dkahle/ggmap”)

<https://www.rdocumentation.org/packages/ggmap/versions/3.0.0>

### Alert\! A plane has crashed directly into Store Lungegårdsvannet\!

``` r
StoreLunge.map <- get_stamenmap(c(left =  5.3241501, bottom = 60.37500,
    right = 5.35500, top = 60.3900),
    zoom = 14)

ggmap(StoreLunge.map)
```

![](plane_crash_ggmap_files/figure-gfm/unnamed-chunk-1-1.png)<!-- -->

## Try other map types such as watercolor or toner-lines

``` r
StoreLunge.watercolor.map <- get_stamenmap(c(left =  5.3241501, bottom = 60.37500,
    right = 5.3600, top = 60.3900),
    zoom = 14, maptype = "watercolor")

ggmap(StoreLunge.watercolor.map)
```

![](plane_crash_ggmap_files/figure-gfm/unnamed-chunk-2-1.png)<!-- -->

## extent = “device” will remove long/lat axes

``` r
ggmap(StoreLunge.watercolor.map, extent = "device")
```

![](plane_crash_ggmap_files/figure-gfm/unnamed-chunk-3-1.png)<!-- -->

``` r
StoreLunge.tonerlines.map <- get_stamenmap(c(left =  5.3241501, bottom = 60.37500,
    right = 5.3600, top = 60.3900),
    zoom = 14, maptype = "toner-lines")

ggmap(StoreLunge.tonerlines.map, extent="device")
```

![](plane_crash_ggmap_files/figure-gfm/unnamed-chunk-4-1.png)<!-- -->

## Where can the injured be immediately relocated?

Add locations of sites in the vecinity of the crash. First, create a
tibble of locations using longitude and latitude

``` r
StoreLunge.places <- tibble(
  location = c("Bergen legevakt",
     "Ado",
     "Bergen døvsenter"),
      lon = c(5.336120,5.338080,5.350060),
      lat = c(60.377760,60.385660,60.384740))
```

When you have your locations dataset ready, use geom\_point( ) to add
markers to your map for your locations.

Try using geom\_text( ) to also add labels for your locations.

Notice that you can treat the ggmap( ) function like ggplot( ).

![](plane_crash_ggmap_files/figure-gfm/unnamed-chunk-6-1.png)<!-- -->
