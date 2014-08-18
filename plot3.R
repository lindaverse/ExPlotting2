require(data.table)
require(plyr)
require(ggplot2)

#If required files are not in current working directory, download and unzip file.
if (!("summarySCC_PM25.rds" %in% dir() && "Source_Classification_Code.rds" %in% dir())) {
  fileURL <- "http://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
  download.file(fileURL, "projectTwoData")
  unzip("./projectTwoData")
}

#Load files into R.
emissionsData <- readRDS("summarySCC_PM25.rds")
emissionsData <- data.table(emissionsData)
classificationCodeTable <- readRDS("Source_Classification_Code.rds")
classificationCodeTable <- data.table(classificationCodeTable)


#Extract only rows relating to Baltimore.
baltimoreData <- emissionsData[emissionsData$fips == "24510",] 

#Look up data point types.
mergedData <- merge(baltimoreData, classificationCodeTable, by=c("SCC"))

#Find total emissions by year and type.
totalEmissionsBaltimoreByYearAndType <- mergedData[, lapply(.SD, sum), by=list(type,year), .SDcols=4]

#Update meta-data.
totalEmissionsBaltimoreByYearAndType <- rename(totalEmissionsBaltimoreByYearAndType, 
                                               c("type" = "Type", "year" = "Year"))

#Transform year to a factor variable.
totalEmissionsBaltimoreByYearAndType <- transform(totalEmissionsBaltimoreByYearAndType, Year = factor(Year))

#Creates a barplot and outputs it to a PNG file with a width of 480 pixels and a height of 480 pixels. 
png("plot3.png", width=720, height=480)
qplot(x=Year, 
      y=Emissions, 
      fill=Type, 
      data=totalEmissionsBaltimoreByYearAndType, 
      geom="bar", 
      stat="identity", 
      position="dodge", 
      facets = . ~ Type)
dev.off()

