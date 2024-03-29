# Understanding Deleterious Effects of Storms using the NOAA Storm Data
Submitted for Coursera **Reproducable Research Peer Assessment 2**  
2015 NOV 22  
## Synopsis

A study was performed using the exploring the U.S. National Oceanic and Atmospheric Administration's (NOAA) storm database that includes data about major storms and interesting weather, particularly when and where they occurred and estimates of fatalities, injuries, and property damaage. The goal of the study was to understand the which types of weather events are the most harmful to people and the types of weather events that have the greatest economic impact. The study determined that the most harmful event to people is X when it comes to fatalities and Y when it comes to injurie; the event that causes the most economic harm is Z.

## Data Processing 

***NOTE: This section is full of arcane technical minutiae that will bore you if all you want is the answer; that can be found in the [Results](#results) section.***

In this section we will perform all the analysis in a way that you can reproduce the results. Note that due to the way this analysis starts with the current NOAA database, your results may vary.

### Load data for analysis

Before we can do any analysis, we need to get the data loaded into our tools. This is a three part exercise

1. Load necessary library for analysis
1. Get the data from it's source
1. Load the data into the tools to do the analysis
1. Tidy up the data to get it more amenable to work with

#### Load libraries
It's simpler to load all the libraries at the beginning, so we'll do that here. That way, any noise generated by loading the libraries are nicely contained in this section.

```r
library(downloader)
library(data.table)
library(ggplot2)
library(scales)
library(R.utils)
```

```
## Loading required package: R.oo
## Loading required package: R.methodsS3
## R.methodsS3 v1.7.0 (2015-02-19) successfully loaded. See ?R.methodsS3 for help.
## R.oo v1.19.0 (2015-02-27) successfully loaded. See ?R.oo for help.
## 
## Attaching package: 'R.oo'
## 
## The following objects are masked from 'package:methods':
## 
##     getClasses, getMethods
## 
## The following objects are masked from 'package:base':
## 
##     attach, detach, gc, load, save
## 
## R.utils v2.1.0 (2015-05-27) successfully loaded. See ?R.utils for help.
## 
## Attaching package: 'R.utils'
## 
## The following object is masked from 'package:utils':
## 
##     timestamp
## 
## The following objects are masked from 'package:base':
## 
##     cat, commandArgs, getOption, inherits, isOpen, parse, warnings
```

```r
library(dplyr)
```

```
## 
## Attaching package: 'dplyr'
## 
## The following objects are masked from 'package:data.table':
## 
##     between, last
## 
## The following objects are masked from 'package:stats':
## 
##     filter, lag
## 
## The following objects are masked from 'package:base':
## 
##     intersect, setdiff, setequal, union
```

#### Get the data from the source.
Now that the libraries are loaded and the tool is ready to do some real work, let's get the data from it's original source. We know the location of the data (the URL provided with the study request) and that's all the tool needs to get the data.

Note that this will always use the data you first received. To disable that feature, set `alwaysReload` to `TRUE`.

*NOTE: The work in this section is constucted in a way that allows other analyses to be performed without having to disturb this code.*


```r
alwaysReload = FALSE
url = "https://d396qusza40orc.cloudfront.net/repdata%2Fdata%2FStormData.csv.bz2"
csvFile = "stormData.csv"
if (alwaysReload || (! csvFile %in% list.files())) {
  localFile = paste0(csvFile,".bz2")
  if (alwaysReload || (! localFile %in% list.files())) {
    download.file(url=url,destfile=localFile,mode="wb",method="curl")
  }
  bunzip2(localFile, overwrite=TRUE)
}
```

#### Import the data into the analysis tools

Now that we have the data in a file on disk, it's time to load that data into our analysis tool. Because the data is large, we're using a caching feature that will make this processing time faster (the second time you run the analysis; the first time it will be slow). 

*NOTE: The work in this section is constucted in a way that allows other analyses to be performed without having to disturb this code.*

*NOTE 2: While we might get the data from the original source, the data that is returned is always the current data at the time that it's accessed. This data may include data that post-dates this study's publication. You don't need to do anything to remove those data elements as the analysis below will do that automatically. If you would prefer that the analysis is performed with the current data, change code that reads `postDatedEventsOk = false` to `postDatedEventsOk = true`.*


```r
allData <- fread(csvFile,verbose=TRUE)
```

```
## Input contains no \n. Taking this to be a filename to open
## File opened, filesize is 0.523066 GB.
## Memory mapping ... ok
## Detected eol as \r\n (CRLF) in that order, the Windows standard.
## Positioned on line 1 after skip or autostart
## This line is the autostart and not blank so searching up for the last non-blank ... line 1
## Detecting sep ... ','
## Detected 37 columns. Longest stretch was from line 1 to line 30
## Starting data input on line 1 (either column names or first row of data). First 10 characters: "STATE__",
## All the fields on line 1 are character fields. Treating as the column names.
## Count of eol: 1307675 (including 1 at the end)
## Count of sep: 34819802
## nrow = MIN( nsep [34819802] / ncol [37] -1, neol [1307675] - nblank [1] ) = 967216
## Type codes (   first 5 rows): 3444344430000303003343333430000333303
## Type codes (+ middle 5 rows): 3444344434444303443343333434440333343
## Type codes (+   last 5 rows): 3444344434444303443343333434444333343
## Type codes: 3444344434444303443343333434444333343 (after applying colClasses and integer64)
## Type codes: 3444344434444303443343333434444333343 (after applying drop or select (if supplied)
## Allocating 37 column slots (37 - 0 dropped)
## 
Read 8.3% of 967216 rows
Read 38.3% of 967216 rows
Read 54.8% of 967216 rows
Read 77.5% of 967216 rows
Read 85.8% of 967216 rows
Read 902297 rows and 37 (of 37) columns from 0.523 GB file in 00:00:07
```

```
## Warning in fread(csvFile, verbose = TRUE): Read less rows (902297) than
## were allocated (967216). Run again with verbose=TRUE and please report.
```

```
##    0.012s (  0%) Memory map (rerun may be quicker)
##    0.000s (  0%) sep and header detection
##    1.366s ( 21%) Count rows (wc -l)
##    0.000s (  0%) Column type detection (first, middle and last 5 rows)
##    0.491s (  7%) Allocation of 902297x37 result (xMB) in RAM
##    4.693s ( 71%) Reading data
##    0.000s (  0%) Allocation for type bumps (if any), including gc time if triggered
##    0.000s (  0%) Coercing data already read in type bumps (if any)
##    0.013s (  0%) Changing na.strings to NA
##    6.575s        Total
```

```r
# Remove columns that aren't of interest for this study
postDatedEventsOk = FALSE
if (! postDatedEventsOk) {
    # The number below comes from this query: allData$REFNUM[nrow(allData)]
    baselineEventRefNum = 902297
    allData <- subset(allData, REFNUM <= baselineEventRefNum)
}
```

```
## debug at <text>#6: baselineEventRefNum = 902297
## debug at <text>#7: allData <- subset(allData, REFNUM <= baselineEventRefNum)
```

#### Clean and tidy up the data
The data has been collected over a long period and some of it is a bit unruly. That unruliness shows up in three forms - the data is full of information we don't care about for this analysis (e.g., the location of the event), the data is not self-consistent (e.g., fields are sometimes upper case and other times they'er lower case) or it's not in a form that's easy to do the analysis (e.g., value codes instead of values). In this section the data is reshaped and filtered to be focused on the data we need to do the analysis. We tidy up the data in phases. 

1. Reduce the noise - get rid of columns we don't need.
    
    ```r
    allData <- subset(allData,,c("REFNUM", "EVTYPE", "FATALITIES", "INJURIES", "PROPDMG", "PROPDMGEXP", "CROPDMG", "CROPDMGEXP"))
    ```
1. Attempt to make the data MORE self-consistent
    
    ```r
    # Make EVTYPE uppercase
    allData$EVTYPE=toupper(allData$EVTYPE)
    # Fix some values that imply the same event type
    allData$EVTYPE[allData$EVTYPE=="TSTM WIND"]="THUNDERSTORM WINDS"
    allData$EVTYPE[allData$EVTYPE=="THUNDERSTORM WIND"]="THUNDERSTORM WINDS"
    ```
1. Convert some fields to other forms
    
    ```r
    # The ...EXP fields are really exponents for a multiplier. Let's convert them to strings of numbers then convert them to numbers
    convertFromExponentToMultiplier <- function(column) {
    column <- gsub("K|k", "1000", column)
    column <- gsub("M|m", "1000000", column)
    column <- gsub("B|b", "1000000000", column)
    column
    }
    allData$PROPDMGEXP <- convertFromExponentToMultiplier(allData$PROPDMGEXP)
    allData$CROPDMGEXP <- convertFromExponentToMultiplier(allData$CROPDMGEXP)
    str(allData)
    ```
    
    ```
    ## Classes 'data.table' and 'data.frame':	902297 obs. of  8 variables:
    ##  $ REFNUM    : num  1 2 3 4 5 6 7 8 9 10 ...
    ##  $ EVTYPE    : chr  "TORNADO" "TORNADO" "TORNADO" "TORNADO" ...
    ##  $ FATALITIES: num  0 0 0 0 0 0 0 0 1 0 ...
    ##  $ INJURIES  : num  15 0 2 2 2 6 1 0 14 0 ...
    ##  $ PROPDMG   : num  25 2.5 25 2.5 2.5 2.5 2.5 2.5 25 25 ...
    ##  $ PROPDMGEXP: chr  "1000" "1000" "1000" "1000" ...
    ##  $ CROPDMG   : num  0 0 0 0 0 0 0 0 0 0 ...
    ##  $ CROPDMGEXP: chr  "" "" "" "" ...
    ##  - attr(*, ".internal.selfref")=<externalptr>
    ```

## Results
In this section we present the events that are most harmful, based on a rather cursory analysis of the data. The data is too substantial to clean, and what is anticipated is that there are strong outliers in these damage categories that will dominate the results.

### Which events are most dangerous to people

When looking at danger to people, it's difficult to compare injuries with fatalaties, so they are treated differently.

#### Which events cause the most deaths
Here we look at which events cause the most deaths. This is a filtering and aggregation of the data, with a barchart showing the results.

```r
fatalities <- allData %>%
    filter(FATALITIES > 0) %>%
    group_by(EVTYPE) %>%
    summarize(EV_FAT=sum(FATALITIES)) %>%
    arrange(desc(EV_FAT))
fatalities <- subset(fatalities,,c("EVTYPE","EV_FAT"))
head(fatalities)
```

```
##               EVTYPE EV_FAT
## 1            TORNADO   5633
## 2     EXCESSIVE HEAT   1903
## 3        FLASH FLOOD    978
## 4               HEAT    937
## 5          LIGHTNING    816
## 6 THUNDERSTORM WINDS    701
```
#### Which events cause the most injuries
Here we look at which events cause the most injuries This is a filtering and aggregation of the data, with a barchart showing the results.

```r
injuries <- allData %>%
    filter(INJURIES > 0) %>%
    group_by(EVTYPE) %>%
    summarize(EV_INJ=sum(INJURIES)) %>%
    arrange(desc(EV_INJ))
injuries <- subset(injuries,,c("EVTYPE","EV_INJ"))
head(injuries)
```

```
##               EVTYPE EV_INJ
## 1            TORNADO  91346
## 2 THUNDERSTORM WINDS   9353
## 3              FLOOD   6789
## 4     EXCESSIVE HEAT   6525
## 5          LIGHTNING   5230
## 6               HEAT   2100
```

### Which events cause the most economic harm

There are two forms of economic harm, property damage and crop damage. Unlike injuries vs fatalaties, there is a unifying characteristics and that's money. That characteristic is used here however it does open up questions to which events are harmful to the different modes of damage.

```r
econDamage <- allData %>%
    filter(PROPDMG > 0 | CROPDMG > 0) %>%
    mutate(PROPDMGEXP = ifelse(PROPDMG>0 && !is.na(as.numeric(PROPDMGEXP)),PROPDMGEXP,"0")) %>%
    mutate(CROPDMGEXP = ifelse(CROPDMG>0 && !is.na(as.numeric(CROPDMGEXP)),CROPDMGEXP,"0")) %>%
    mutate(PROPDMG_NET = PROPDMG*as.numeric(PROPDMGEXP)) %>%
    mutate(CROPDMG_NET = CROPDMG*as.numeric(CROPDMGEXP)) %>%
    group_by(EVTYPE) %>%
    summarize(NET_DAMAGE=sum(PROPDMG_NET + CROPDMG_NET)) %>%
    arrange(desc(NET_DAMAGE))
```

```
## Warning in ifelse(PROPDMG > 0 && !is.na(as.numeric(PROPDMGEXP)),
## PROPDMGEXP, : NAs introduced by coercion
```

```r
econDamage <- subset(econDamage,,c("EVTYPE","NET_DAMAGE"))
# Summarize the 10th through last elements into one element
econDamage$NET_DAMAGE[10] <- sum(econDamage$NET_DAMAGE[10:nrow(econDamage)])
econDamage$EVTYPE[10] <- sprintf("All other event types (%d types)",nrow(econDamage)-10+1)
head(econDamage,10)
```

```
##                               EVTYPE NET_DAMAGE
## 1                            TORNADO 3212258160
## 2                 THUNDERSTORM WINDS 2659132960
## 3                        FLASH FLOOD 1420124590
## 4                              FLOOD  899938480
## 5                               HAIL  688693380
## 6                          LIGHTNING  603351780
## 7                          HIGH WIND  324731560
## 8                       WINTER STORM  132720590
## 9                         HEAVY SNOW  122251990
## 10 All other event types (386 types)  821296520
```

```r
econDamage$EVTYPE<-factor(econDamage$EVTYPE,levels=econDamage$EVTYPE)
ggplot(data=econDamage[1:10],aes(x=EVTYPE, y=NET_DAMAGE)) + 
    geom_bar(stat = "identity") + 
    scale_y_continuous(labels=comma) +
    labs(title="Event type damage, in $", x="Event type", y="Cumulative event damage, in $") +
    theme(title=element_text(face='bold')) +
    theme(axis.text.x=element_text(angle=45,hjust=1)) +
    theme(panel.background=element_rect(fill='white')) +
    theme(panel.grid.major=element_line(colour='gray')) +
    theme(panel.grid.major.x=element_blank()) +
    theme(panel.grid.minor.y=element_line(colour='gray',linetype='dashed'))
```

![](pa2_files/figure-html/econPlot-1.png) 
