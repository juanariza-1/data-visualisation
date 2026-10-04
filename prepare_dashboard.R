library(sf)
library(dplyr)
library(ipumsr)

# Paths
shape_path <- "data/private/US_county_2020.shp"
pop_path   <- "data/private/nhgis0005_ts_geog2010_county.csv"

# Read shapefile
shape_us <- st_read(shape_path, quiet = TRUE) %>%
  mutate(STATEFP = as.integer(STATEFP)) %>%
  filter(STATEFP < 57, !(STATEFP %in% c(2, 15)))

# Read NHGIS population data
data_pop <- read_nhgis(pop_path)

# Build race variables
data_pop_clean <- data_pop %>%
  mutate(
    pop_white  = CW8AA2010 + CW8AG2010,
    pop_black  = CW8AB2010 + CW8AH2010,
    pop_native = CW8AC2010 + CW8AI2010,
    pop_asian  = CW8AD2010 + CW8AJ2010,
    pop_other  = CW8AE2010 + CW8AK2010,
    pop_two    = CW8AF2010 + CW8AL2010,
    total_pop  = pop_white + pop_black + pop_native + pop_asian + pop_other + pop_two
  ) %>%
  select(GISJOIN, pop_white, pop_black, pop_native, pop_asian, pop_other, pop_two, total_pop)

# Merge
shape_us <- shape_us %>%
  left_join(data_pop_clean, by = "GISJOIN")

# Save final file
saveRDS(
  shape_us,
  "data/private/shape_us_final.rds"
)

cat("File created: shape_us_final.rds\n")