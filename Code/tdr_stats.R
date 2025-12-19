library(tidyverse)

# Load data files
tdr.fishing <- readRDS(file = "tdr_fishing.rds")
tdr.summ.haul <- readRDS(file = "tdr_summary.rds")
# Or
# load(file = "tdr_for_statistics.Rdata")

# Quick boxplot of raw data
ggplot(tdr.fishing, aes(cruise, height, fill = gear.type)) + 
  geom_boxplot() +
  labs(x = "Cruise", y = "Height (m)") 

# Quick boxplot of summary data
ggplot(tdr.summ.haul, aes(cruise, as.numeric(A), fill = gear.type)) + 
  geom_boxplot() +
  labs(x = "Cruise", y = "Area (m^2)")
