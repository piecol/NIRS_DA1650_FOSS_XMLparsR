library(tidyverse)
library(lubridate)
library(xml2)


# get samples to USB export from DA1650; if many samples are exported, the instrument splits chunks of ~100 samples in separate XMLs

dir_path <- "DATA/Samples_91751846_02-11-2021_02-36-03/" 
file_pattern <- '.XML' 

#list.files(dir_path, file_pattern)

read_dir <- function(dir_path, file_name){
  read_xml(paste0(dir_path, file_name)) %>% 
    xml_ns_strip() %>% 
    xml_find_all(".//SampleList//*") %>% 
    map_dfr(~ {xml_attrs(.x) %>% enframe() %>% pivot_wider()})
}

rawFOSS <- 
  list.files(dir_path, pattern = file_pattern) %>% 
  map_df(~ read_dir(dir_path, .)) # depending on file(s) size, this operation might take a few minutes - be patient !

rm(list=c("dir_path", "file_pattern", "read_dir"))

FOSS_EXT = rawFOSS %>% 
  select(AnalysisEndUTC, AnalysisStartUTC, SampleNumber, SampleID, # select relevant information 
         ProductCode, ProductName,Value,Name,Identification ) %>% 
  mutate_at(1:2, ~ as_datetime(.,"%Y-%m-%dT%H:%M:%S", tz="UTC")) %>% #format_ISO8601(date)
  filter(!Name %in% c("Cup id", "Cup type", "Distance")) %>% 
  fill(AnalysisEndUTC:ProductName) %>%
  filter(!is.na(Name)) %>% 
  mutate(Value = parse_number(Value)) %>% 
  mutate_at(c("SampleID", "SampleNumber", "Name", "Identification"), as.factor) %>% 
  group_by(SampleID, Name) %>% 
  filter(!duplicated(Name))
