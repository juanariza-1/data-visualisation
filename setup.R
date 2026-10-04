packages <- c(
  "rmarkdown", "knitr", "sf", "tidyverse", "ipumsr", "tmap", "leaflet",
  "shiny", "scales", "ncdf4", "lubridate", "rnaturalearth",
  "rnaturalearthdata", "ISOweek"
)

installed <- rownames(installed.packages())
missing <- setdiff(packages, installed)
if (length(missing)) {
  install.packages(missing, repos = "https://cloud.r-project.org")
}

# Optional acquisition packages are needed only when requesting new ERA5 data:
# install.packages(c("ecmwfr", "keyring"), repos = "https://cloud.r-project.org")
