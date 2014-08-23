require(data.table)

#If required files are not in current working directory, download and unzip file.
if (!("summarySCC_PM25.rds" %in% dir() && "Source_Classification_Code.rds" %in% dir())) {
  fileURL <- "http://d396qusza40orc.cloudfront.net/exdata%2Fdata%2FNEI_data.zip"
  download.file(fileURL, "projectTwoData")
  unzip("./projectTwoData")
}

#Load file containing emissions data into R.
emissionsData <- readRDS("summarySCC_PM25.rds")
emissionsData <- data.table(emissionsData)

#Group by year and sum emissions.
totalEmissionsByYear <- emissionsData[, lapply(.SD, sum), by=year, .SDcols=4]

#Create a barplot and output it to a PNG file with a width of 480 pixels and a height of 480 pixels. 
png("plot1.png", width=480, height=480)
options(scipen=10)
barplot(
  totalEmissionsByYear$Emissions/1000000,
  ylim=c(0, 8), 
  col="red", 
  names.arg=totalEmissionsByYear$year, 
  ylab="Emissions (millions of tons)", 
  main=expression("Total PM"[2.5]*" emissions by year"))
dev.off()
