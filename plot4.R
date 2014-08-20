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

#Merge data tables on SCC.
mergedData <- merge(emissionsData, classificationCodeTable, by=c("SCC"))

#Filter data to only entries relating to only coal-combustion related sources.
coalCombustionData <- mergedData[grep("Coal", mergedData$EI.Sector),]

#Find total emissions by year.
coalCombustionTotalYearlyEmissions <- coalCombustionData[, lapply(.SD, sum), by=list(year, EI.Sector), .SDcols=4]

#Update meta-data.
coalCombustionTotalYearlyEmissions <- rename(coalCombustionTotalYearlyEmissions, 
                                               c("EI.Sector" = "Sector", "year" = "Year"))

#Transform year to a factor variable.
coalCombustionTotalYearlyEmissions <- transform(coalCombustionTotalYearlyEmissions, Year = factor(Year))

#Creates a barplot and outputs it to a PNG file with a width of 480 pixels and a height of 480 pixels.
png("plot4.png", width=600, height=600)
print(ggplot(coalCombustionTotalYearlyEmissions,
              aes(x = Year, 
                  y = Emissions/1000000, 
                  fill = Sector)) + 
              geom_bar(stat = "identity") +
              ylab("Emissions (millions of tons)") +
              ggtitle(expression("PM"[2.5]*" emissions from coal combustion-related sources")) +
              scale_fill_discrete(labels = c("Comm/Institutional", 
                                             "Electric Generation", 
                                             "Industrial Boilers, ICEs")))
dev.off()
