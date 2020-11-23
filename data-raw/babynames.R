library(tidyverse)
library(lubridate)

url <- "https://www.ssa.gov/oact/babynames/names.zip"
download.file(url, dest="data-raw/temp/dataset.zip", mode="wb")
unzip("data-raw/temp/dataset.zip",  exdir="data-raw/temp")
keywords <- "yob"
files <- list.files("data-raw/temp", pattern = keywords)

us_data <- map_df(1 : length(files), function(i){
  this_data <- read_csv(paste0("data-raw/temp/",files[i]),
                        col_names = FALSE,
                        col_types = cols(col_character(),
                                         col_character(),
                                         col_integer()))
  colnames(this_data) <- c("Name", "Sex", "Count")
  this_year <- files[i] %>% str_replace("yob","") %>%
    str_replace(".txt","")
  this_data$Year <- this_year %>% as.integer()
  this_data$Country <- "US"
  this_data
})

unlink("data-raw/temp/*")

# get baby name data
url <- "https://catalogue.data.govt.nz/dataset/01ee87cd-ecf8-44a1-ad33-b376a689e597/resource/0b0b326c-d720-480f-8f86-bf2d221c7d3f/download/baby-names-2020-1-6.csv"
nz_data <- read_csv(url, col_types = cols(Year = col_integer(),
                                          Sex = col_character(),
                                          Name = col_character(),
                                          Count = col_integer())) %>%
  mutate(Country = "NZ")

babynames <- bind_rows(us_data, nz_data)

usethis::use_data(babynames, compress = "xz", overwrite = T)

babyjustnames <- babynames %>%
  group_by(Name, Year, Country) %>%
  summarise(Count = sum(Count))

usethis::use_data(babyjustnames, compress = "xz", overwrite = T)

