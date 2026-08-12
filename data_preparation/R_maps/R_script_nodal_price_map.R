###########################################
#   R sript to create nodal price maps    #
###########################################
# further info on map formatting
#https://www.r-spatial.org/r/2018/10/25/ggplot2-sf.html

# set working directory to project folder
setwd("C:/Users/jonas/Documents/eu_electricity_model/data_preparation/R_maps/")

#load packages
library(sf)
library(rgdal)
library(ggplot2)
library(ggmap)
library(readxl)
library(dplyr)
library(sp)


#load countries
countries <- lapply(read_excel(paste0('countries.xlsx')),as.list)
countries_EU <- c('BE','BG','CZ','DK','DE','EE','IE','GR','ES','FR','HR','IT','CY','LV','LT','LU','HU','MT','NL','AT','PL','PT','RO','SI','SK','FI','SE')

#load countries shapefile
countries_sp <- st_read('shapefiles/CNTR_RG_60M_2020_4326.shp', crs = "+init=epsg:4326")

levels(countries_sp$FID) <- c(levels(countries_sp$FID), c("GB",'GR'))
countries_sp$FID[countries_sp$FID == 'UK'] <- 'GB'
countries_sp$FID[countries_sp$FID == 'EL'] <- 'GR'

#masking: only keep data overlaying shapefile
countries_sp_mask <- subset(countries_sp, FID %in% countries$Countries)
countries_sp_mask['iseu'][countries_sp_mask$FID %in% countries_EU] <- TRUE

countries_sp_EU <- subset(countries_sp_mask, FID %in% countries_EU)

#plot 
ggplot() +
  geom_sf(data = countries_sp, fill = "gainsboro", colour = "black") +
  geom_sf(data = countries_sp_mask, fill = "dodgerblue1", colour = "black") +
  geom_sf(data = countries_sp_EU, fill = "blue3", colour = "black") +
  geom_sf_text(data = countries_sp_mask, aes(label = FID),colour='white',size=2.5) +
  coord_sf(xlim = c(-25, 45), ylim = c(35, 70)) +
  theme_void()

ggsave(paste0('countries_map.png'),dpi = 600)
