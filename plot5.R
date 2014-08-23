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

#Lookup data point types.
mergedData <- merge(baltimoreData, classificationCodeTable, by=c("SCC"))

#Subset to only the rows relating to motor vehicles.
baltimoreMotorVehicle <- mergedData[grep("On-Road", mergedData$EI.Sector),]

#Find total yearly emissions for motor vehicles in Baltimore.
baltimoreMotorVehicleYearlyEmissions <- baltimoreMotorVehicle[, lapply(.SD, sum), by=list(year, EI.Sector), .SDcols=4]

#Update meta-data.
baltimoreMotorVehicleYearlyEmissions <- rename(baltimoreMotorVehicleYearlyEmissions, 
                                             c("EI.Sector" = "Sector", "year" = "Year"))

#Transform year to factor variable.
baltimoreMotorVehicleYearlyEmissions <- transform(baltimoreMotorVehicleYearlyEmissions, Year = factor(Year))

#Create a barplot and output it to a PNG file with a width of 600 pixels and a height of 600 pixels.
png("plot5.png", width=600, height=600)
print(ggplot(baltimoreMotorVehicleYearlyEmissions,
             aes(x = Year, 
                 y = Emissions, 
                 fill = Sector)) + 
        geom_bar(stat = "identity") +
        ylab("Emissions (tons)") +
        ggtitle(expression("PM"[2.5]*" emissions from motor vehicles in Baltimore")) +
        scale_fill_discrete(labels = c("Diesel heavy duty vehicles", 
                                     "Diesel light duty vehicles", 
                                     "Gaseoline heavy duty",
                                     "Gasoline light duty")))
dev.off()



