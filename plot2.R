require(data.table)

#If required files are not in current working directory, download and unzip file.
if (!("summarySCC_PM25.rds" %in% dir() && "Source_Classification_Code.rds" %in% dir())) {
  fileURL <- "http://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
  download.file(fileURL, "projectTwoData")
  unzip("./projectTwoData")
}

#Load files into R.
emissionsData <- readRDS("summarySCC_PM25.rds")
emissionsData <- data.table(emissionsData)
#classificationCodeTable <- readRDS("Source_Classification_Code.rds")
#classificationCodeTable <- data.table(classificationCodeTable)

#Extract only rows relating to Baltimore.
baltimoreData <- emissionsData[emissionsData$fips == "24510",] 

#Grouping by year and summing emissions.
totalEmissionsByYearBaltimore <- baltimoreData[, lapply(.SD, sum), by=year, .SDcols=4]

#Creates a barplot and outputs it to a PNG file with a width of 480 pixels and a height of 480 pixels. 
png("plot2.png", width=480, height=480)
options(scipen=10)
barplot(
  totalEmissionsByYearBaltimore$Emissions,
  ylim=c(0, 3500), 
  col="red", 
  names.arg=totalEmissionsByYearBaltimore$year, 
  ylab="Emissions (tons)", 
  main=expression("Total PM"[2.5]*" emissions by year (Balitmore)"))

dev.off()
