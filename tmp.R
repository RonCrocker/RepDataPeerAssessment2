bob <- function() {
  library(downloader)
  alwaysReload = FALSE
  url = "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
  csvFile = "stormData.csv.bz2"
  if (alwaysReload || (! csvFile %in% list.files())) {
    download.file(url=url,destfile=localFile,mode="wb",method="curl")
  }
  foo <- read.csv(csvFile)
  str(foo)
  foo
}

convert <- function(column) {
    column <- gsub("K|k", "1000", column)
    column <- gsub("M|m", "1000000", column)
    column <- gsub("B|b", "1000000000", column)
    column
}