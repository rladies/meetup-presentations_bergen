library("xml2")
library("rvest")
library( tidyverse )
library( magrittr )

# fetchin the data
# generate URLs per each year
years <- as.character( 2010:2019 )
urlYears <- paste0("http://www.planecrashinfo.com/", years, "/", years, ".htm")

# retrieve data from each year
urls <- mapply(function(urlYear, year) {
  rowNumber <- urlYear %>% 
    read_html %>% 
    html_table(header = TRUE) %>% 
    .[[1]] %>% nrow
  
  urlsSpec <- paste0("http://www.planecrashinfo.com/", year, 
                     "/", year, "-", 1:rowNumber, ".htm")
},
urlYears,
years
) %>% unlist

data.downloaded <- lapply(urls, function(url) {
  url %>% 
    # read each crash table
    read_html %>% 
    html_table %>% 
    data.frame %>%  
    setNames(c("Vars", "Vals")) %>%
    # header is a colunm and values are in a column -> tidy up
    spread(Vars, Vals) %>% 
    .[-1]
})

length( data.downloaded )
head( names( data.downloaded ) )
str( data.downloaded[[1]] )

# cleanup data
data <- data.downloaded %>% 
  bind_rows %>% 
  setNames(gsub(":", "", colnames(.)) %>% tolower)

# there is one column that has "\n" in the name, which when written to the file
#  would be interpreted as a newline
names( data )
colnames( data )[ 2 ] <- "type"

# some entries in "summary" contain newline symbol - this needs to be removed
data$summary %<>% gsub( pattern = "\n", replacement = "", x = . )

write.table( data, file = "plane_crash_2010-2019.dat", sep = "|", col.names = TRUE,
             quote = FALSE, row.names = FALSE )
