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

#Extract only rows relating to Baltimore City and Los Angeles County.
baltimoreAndLAData <- emissionsData[emissionsData$fips %in% c("24510", "06037"),] 

#Lookup data point types.
baltimoreAndLAData <- merge(baltimoreAndLAData, classificationCodeTable, by=c("SCC"))

#Subset to only the rows relating to motor vehicles.
baltimoreAndLAMotorVehicle <- baltimoreAndLAData[grep("On-Road", baltimoreAndLAData$EI.Sector),]

#Find total yearly emissions for motor vehicles in Baltimore and LA.
baltimoreAndLAMotorVehicleYearlyEmissions <- baltimoreAndLAMotorVehicle[, lapply(.SD, sum), by=list(year, EI.Sector, fips), .SDcols=4]

#Update meta-data.
baltimoreAndLAMotorVehicleYearlyEmissions <- rename(baltimoreAndLAMotorVehicleYearlyEmissions, 
                                               c("EI.Sector" = "Sector", "year" = "Year", "fips" = "Location"))

#Transform year to factor variable.
baltimoreAndLAMotorVehicleYearlyEmissions <- transform(baltimoreAndLAMotorVehicleYearlyEmissions, Year = factor(Year))

#Creates a barplot and outputs it to a PNG file with a width of 480 pixels and a height of 480 pixels.
png("plot6.png", width=600, height=600)
print(ggplot() +
      geom_bar(data=baltimoreAndLAMotorVehicleYearlyEmissions, 
           aes(y = Emissions, 
               x = Location, 
               fill = Sector), 
           stat="identity",
           position='stack') + 
           ylab("Emissions (tons)") +
           ggtitle(expression("PM"[2.5]*" emissions from motor vehicles in Baltimore City and LA County")) +
           scale_fill_discrete(labels = c("Diesel heavy duty vehicles", 
                                       "Diesel light duty vehicles", 
                                       "Gaseoline heavy duty",
                                       "Gasoline light duty")) +
           scale_x_discrete(labels=c("LA","Baltimore")) +
           xlab(NULL) +
           theme(legend.position="bottom") +
           facet_grid( ~ Year))
dev.off()