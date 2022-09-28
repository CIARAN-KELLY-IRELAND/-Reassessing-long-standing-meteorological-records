<!DOCTYPE html>
<head>
<meta charset='utf-8'>
<meta name='viewport' content='width=device-width, initial-scale=1' />
<title>Weclome</title>
<meta http-equiv="refresh" content="60">
<meta http-equiv='Cache-Control' content='no-store' />
<meta http-equiv='cache-control' content='max-age=0' />
<meta http-equiv='expires' content='Tue, 01 Jan 1980 1:00:00 GMT' />
<meta http-equiv='Cache-Control' content='no-cache, no-store, must-revalidate' />
<meta http-equiv='Pragma' content='no-cache' />
<meta http-equiv='Expires' content='0' />
<link rel="icon" href="https://image.shutterstock.com/image-vector/welcom-icon-invite-symbol-flat-260nw-311883779.jpg">
<script src='http://sol/sswww/sorttable.js'></script>
<link href='https://www.met.ie/css/bootstrap.css' rel='stylesheet' />
<link href='https://www.met.ie/css/met.css?v=2032' rel='stylesheet' />
<link href='http://sol/sswww/DATABASE/review/dba_tables.css' rel='stylesheet' type='text/css' >
<link href='index.css' rel='stylesheet' />
</head>
<body>

<h3><b>Welcome to Climate Services</b></h3>
<p style='margin-top:-10px; font-size:12px; color:darkgrey;'>Ciaran Kelly (2021)</p>
<p><b>Climate Services - Publications & Enquiries Unit (CPU)</b></p>

---
title: "**Reanalysis Script**"
output: html_document
---

```{r setup, include=FALSE}
knitr::opts_chunk$set(echo = TRUE)
```
# **Introduction**# 

This script loads netcdf files from a local directory and process the files and plots the data as maps to display to results. Two reanalysis products were used which are [20th Century Reanalysis V3: NOAA](https://psl.noaa.gov/data/gridded/data.20thC_ReanV3.html) and [cds.climate.copernicus.eu](https://cds.climate.copernicus.eu/cdsapp#!/search?type=dataset) with the parameters prmsl and 850 hpa temperatures ensemble mean gathered at 1500GMT. 

# **Process**#
### NOAA ###

* 20th Century Reanalysis V3: NOAA Physical Sciences Laboratory Netcdf files of prmsl and 850 hpa tempertures       ensemble mean at 1500GMT were downloaded at its native resolution of 0.5° x 0.5°.
* Files are imported into R and opened, processed and plotted using various libraries.
* The variable prmsl is converted into msl. 
* The variable temperature is changed from kelvin to degrees Celsius.
* The variables are then plotted on a map with temperature shown as colors and msl as contours. 

### ERA5 ###

* Search results (copernicus.eu), Netcdf files were downloaded from the Copernicus climate data store onto a local   directory. 
* The variables msl and 850 hpa tempertures were downloaded 
* Files are imported into R and opened, processed and plotted.
* As ERA5 is already in msl no processing was needed for this variable. 
* The variable temperature is changed from kelvin to degrees Celsius.
* The variables are then plotted on a map with temperature shown as colors and msl as contours.

### **Install packages and Load libraries** ### 
```{r}
library(ncdf4) # package for netcdf manipulation
library(raster) # package for raster manipulation
library(rgdal) # package for geospatial analysis
library(ggplot2) # package for plotting
#install.packages("weathermetrics")
library(weathermetrics)
library(rnaturalearth)       
library(rnaturalearthdata)
#install.packages("rcartocolor")
library(rcartocolor)
library(metR)
library(gridExtra)
library(grid)
```
### **Open local directory and import netcdf files** ###

This script loads the netcdf files one by one. The netcdf files have a naming structure as follows __T850_YYYY_mm__ and __MSLP_YYYY__. The follow script is an example of loading in the year 1796 and month 07

### Open local directory
```{r}
setwd("/home/ckelly/html/Reanalysis")
```
### Load files
```{r}
setwd("/home/ckelly/html/Reanalysis")
nc_data <- nc_open('T850_197607.nc')
nc_data_msl <- nc_open('MSLP_197607.nc')
```

### **Process 20th netcdf file of T850.** ###

Connect to the NetCDF file using the `nc_open()` function from the `ncdf4` package. We save the connection to the file as a variable called `nc`.
```{r}
lon <- ncvar_get(nc_data, "lon")
lon[lon > 180] <- lon[lon > 180] - 360
lat <- ncvar_get(nc_data, "lat", verbose = F)
t <- ncvar_get(nc_data, "time")
head(lon) 

ndvi.array <- ncvar_get(nc_data, "air") # store the data in a 3-dimensional array
dim(ndvi.array) 

fillvalue <- ncatt_get(nc_data, "air", "_FillValue")
fillvalue

nc_close(nc_data) 

ndvi.array[ndvi.array == fillvalue$value] <- NA


ndvi.slice <- ndvi.array

dim(ndvi.array)

r <- raster(t(ndvi.slice), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))

r <- flip(r, direction='y')
head(r)

```
### Process 20th netcdf file of prmsl.

Connect to the NetCDF file using the `nc_open()` function from the `ncdf4` package. We save the connection to the file as a variable called `nc`.
```{r}
setwd("C:/Users/Met Eireann/Desktop/2OTH_&_ERA5/May2022/1970S")

nc_data_msl <- nc_open('MSLP_197607.nc')

names(nc_data_msl$var)

lon <- ncvar_get(nc_data_msl, "lon")
lon[lon > 180] <- lon[lon > 180] - 360


lat <- ncvar_get(nc_data_msl, "lat", verbose = F)
t <- ncvar_get(nc_data_msl, "time")

head(lon) 

ndvi.array_msl <- ncvar_get(nc_data_msl, "prmsl") # store the data in a 3-dimensional array
dim(ndvi.array_msl) 

fillvalue_msl <- ncatt_get(nc_data_msl, "prmsl", "_FillValue")
fillvalue_msl

nc_close(nc_data_msl) 

ndvi.array_msl[ndvi.array_msl == fillvalue_msl$value] <- NA


ndvi.slice_msl <- ndvi.array_msl

dim(ndvi.array_msl)

r_msl <- raster(t(ndvi.slice_msl), xmn=min(lon), xmx=max(lon), ymn=min(lat), ymx=max(lat), crs=CRS("+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs+ towgs84=0,0,0"))

r_msl <- flip(r_msl, direction='y')

mslrasdf <-as.data.frame(r_msl, xy=TRUE)
head(mslrasdf)


mslrasdf$layer <-c (mslrasdf$layer /100 )
```

### Set up plots ###

Next we set up the plot by overlayin both parameters on top of each other. 

### Set up plots

### Run world package
```{r}
world <- ne_coastline(scale = "large", returnclass = "sf")
class(world)
```
### Save raster layer as data frames
```{r}
rasdf <-as.data.frame(r, xy=TRUE)
head(rasdf)
```
### Change kelvin to temp below is the formula to convert  F = (9/5)c + 32
```{r}
rasdf$layer <- kelvin.to.celsius(rasdf$layer)
names(nc_data$var)
```
### Create ggplot object 
```{r}
p<- ggplot()+
  geom_raster(aes(x=x,y=y, fill= layer),data=rasdf)+
  geom_sf(fill="transparent", data=world)+
  scale_fill_viridis_c(name="TEMP [°C]",direction=+1,option = "turbo")+
  labs( x = "LONGITUDE", y = "LATITUDE") +
  ggtitle("(02-07-1976)") +
  coord_sf(xlim = c(-20.5, 5.5), ylim = c(47,61), expand = T)+
  theme(text=element_text(family="Arial",face="bold", size=9))+
  theme_bw()
```
### Overlay and Plot
```{r}
B<- p +
  geom_contour(aes(x=x,y=y,z=layer),color="black",size=0.0005,data=mslrasdf) + 
  geom_text_contour(aes(x=x,y=y,z = layer),color="black", data=mslrasdf)   

B

###set up all plots on one pahe or in lattice plot
#NCEP_plot <- grid.arrange(A,B, nrow = 1, top = "NOAA 20CRv3 MSLP & 850-hPa Temperatures")+
  #theme(text=element_text(family="Arial",face="bold", size=9))

#NCEP_plot 

```
