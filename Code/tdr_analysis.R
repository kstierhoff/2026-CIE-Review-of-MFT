# Load packages
pacman::p_load(tidyverse, lubridate, here, patchwork)

# Process TDR files?
process.tdr <- TRUE

# Set ggplot2 theme
theme_set(theme_bw())

if (process.tdr) {
  # Load TDR data
  load(here("Data/TDR/all_tdr_raw.Rdata"))
  
  # Create unique ID for each haul
  tbl.all <- tbl.tdr.all %>% 
    mutate(key = paste(cruise, haul)) %>% 
    filter(cruise == "202307")
  
  # Load haul info
  load(here("Data/Trawl/trawl_data_raw.Rdata"))
  
  # Create unique ID for each haul
  haul <- haul %>% 
    mutate(key = paste(cruise, haul))
  
  # Create df for storing TDR data
  tdr.fishing <- data.frame()
  
  # Extract fishing data
  for (i in unique(tbl.all$key)) {
    # For testing
    # i = unique(tbl.all$key)[1]
    
    haul.tmp <- haul %>% 
      filter(key == i)
    
    tdr.tmp <- tbl.all %>%
      filter(key == i) %>% 
      # group_by(loc) %>% 
      # summarise(min.time = min(time),
      #           max.time = max(time)) %>% 
      filter(between(time.utc, haul.tmp$equilibriumTime, haul.tmp$haulBackTime)) %>% 
      select(haul, time.utc, loc, depth)
    
    if ("Kite" %in% tdr.tmp$loc & "Footrope" %in% tdr.tmp$loc) {
      tdr.tmp <- tdr.tmp %>% 
        pivot_wider(names_from = loc, values_from = depth) %>% 
        mutate(time.diff = c(0, diff(time.utc)),
               time.cum  = cumsum(time.diff)/60,
               height = Kite - Footrope)
      
      # Combine results
      tdr.fishing <- bind_rows(tdr.tmp, tdr.fishing)
      
      # # Plot TDR data
      # plot.tdr <- ggplot(tdr.tmp) +
      #   geom_path(aes(time.cum, Kite), colour = "red") +
      #   geom_path(aes(time.cum, Footrope), colour = "blue") +
      #   labs(x = "Cumulative time (mins)", y = "Depth (m)",
      #        title = paste("Cruise:", unlist(strsplit(i," "))[1],
      #                      "Haul:", unlist(strsplit(i," "))[2]))
      # 
      # # Plot vertical opening (height)
      # plot.spread <- ggplot(tdr.tmp) +
      #   geom_path(aes(time.cum, height), colour = "green") +
      #   labs(x = "Cumulative time (mins)", y = "Opening height (m)")
      # 
      # # Combine plots
      # plot.all <- plot.tdr / plot.spread
    }
  }  
  
  # Save processed data
  save(tdr.fishing, file = here("Data/TDR/tdr_data_fishing.Rdata"))
  
} else {
  # Load processed data
  load(here("Data/TDR/tdr_data_fishing.Rdata"))
}

# tdr.plot <- tdr.fishing %>% 
#   pivot_longer()

ggplot(tdr.fishing) +
  geom_path(aes(time.cum, Kite, group = haul), colour = "red") +
  geom_path(aes(time.cum, Footrope, group = haul), colour = "blue") +
  labs(x = "Cumulative time (mins)", y = "Depth (m)")

ggplot(tdr.fishing) +
  geom_path(aes(time.cum, height, group = haul), colour = "green") +
  labs(x = "Cumulative time (mins)", y = "Opening height (m)")

