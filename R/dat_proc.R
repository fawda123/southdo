######
# processing DO time series data from Dumbarton Bridge and Newark, southern SF Bay
# wx from union city

library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)
library(WtRegDO)
# devtools::load_all('M:/docs/SWMP/WtRegDO')

##
# import data, clean up, save

##
dum <- read.csv('ignore/Dumbarton_07022013_04282016_L1.csv') %>% 
   rename(
     DateTimeStamp = DMB_TIMESTAMP, 
     Temp = DMB_EXOTemp_clean,
     Sal = sal, 
     DO_obs = DMB_EXODOmgL_clean, 
     Tide = DMB_EXODepth_clean
     ) %>% 
  select(DateTimeStamp, Temp, Sal, DO_obs, Tide) %>% 
  mutate(DateTimeStamp = as.POSIXct(DateTimeStamp, format = '%m/%d/%Y %H:%M', tz = 'Pacific/Pitcairn'))

# toplo <- gather(dum, 'var', 'val', -DateTimeStamp)
# ggplot(toplo, aes(DateTimeStamp, val)) + 
#   geom_line() + 
#   facet_wrap(~var)

##
new <- read.csv('ignore/Newark_04212015_05132016_L1 (1).csv') %>% 
   rename(
     DateTimeStamp = NW_TIMESTAMP, 
     Temp = NW_EXOTemp_clean,
     Sal = sal, 
     DO_obs = NW_EXODOmgL_clean, 
     Tide = NW_EXODepth_clean
     ) %>% 
  select(DateTimeStamp, Temp, Sal, DO_obs, Tide) %>% 
  mutate(DateTimeStamp = as.POSIXct(DateTimeStamp, format = '%m/%d/%Y %H:%M', tz = 'Pacific/Pitcairn'))

# toplo <- gather(new, 'var', 'val', -DateTimeStamp)
# ggplot(toplo, aes(DateTimeStamp, val)) + 
#   geom_line() + 
#   facet_wrap(~var)

# save raw files
save(dum, file = 'data/dum.RData', compress = 'xz')
save(new, file = 'data/new.RData', compress = 'xz')

######
# create objects of tidal correlation with sun angle for each site
# newark is full data range
# dumbarton is truncated by newark dates

rm(list = ls())

data(dum)
data(new)

# run weighted regression in parallel
# requires parallel backend
library(doParallel)
registerDoParallel(cores = 7)

##
# dumbarton evalcor

# subset dumbarton by newark date range
dtrng <- range(new$DateTimeStamp, na.rm = TRUE)
toeval <- filter(dum, DateTimeStamp >= dtrng[1] & DateTimeStamp <= dtrng[2])

# dum coords, tz
lat <- 37.504167
long <- -122.119444
tz <- 'Pacific/Pitcairn'

dum_evalcor <- evalcor(toeval, tz, lat, long, progress = TRUE)

save(dum_evalcor, file = 'data/dum_evalcor.RData', compress = 'xz')

##
# newark evalcor

# newark coords
lat <- 37.51338333
long <- -122.0821
tz <- 'Pacific/Pitcairn'

toeval <- new
new_evalcor <- evalcor(toeval, tz, lat, long, progress = TRUE)

save(new_evalcor, file = 'data/new_evalcor.RData', compress = 'xz')
