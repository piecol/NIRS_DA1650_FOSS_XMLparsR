# NIRS_DA1650_FOSS_XMLparsR
XML to dataframe parser written in R

## Store your XMLs in the DATA folder in your project

Required libraries are: 
-*tidyverse
-*xml2
-*lubridate

The script parses any .XML file located in the DATA folder and returns a dataframe. The aim is to get the samples located in the SampleList node and theri relative metadata.
