######
# processing DO time series data from Dumbarton Bridge and Newark, southern SF Bay
# wx from union city

library(dplyr)
library(tidyr)
library(ggplot2)
library(lubridate)
devtools::load_all('M:/docs/SWMP/WtRegDO')

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

toplo <- gather(dum, 'var', 'val', -DateTimeStamp)
ggplot(toplo, aes(DateTimeStamp, val)) + 
  geom_line() + 
  facet_wrap(~var)

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

toplo <- gather(new, 'var', 'val', -DateTimeStamp)
ggplot(toplo, aes(DateTimeStamp, val)) + 
  geom_line() + 
  facet_wrap(~var)


# # run weighted regression in parallel
# # requires parallel backend
library(doParallel)
registerDoParallel(cores = 6)

# dum coords
lat <- 37.504167
long <- -122.119444

# newark coords
# lat <- 37.51338333
# long <- -122.0821
tz <- 'Pacific/Pitcairn'
devtools::load_all('M:/docs/SWMP/WtRegDO')
toeval <- filter(dum, year(DateTimeStamp) %in% 2014)
tmp <- evalcor(toeval, tz, lat, long, progress = TRUE)
