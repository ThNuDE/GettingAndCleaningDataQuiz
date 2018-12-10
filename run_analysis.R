###########################################################
#
# Author: Thomas Nüßlein
# File  : run_analysis.R
# 
# Getting and Cleaning Data Course Project
#
# Edited and testet with RStudio Version 1.1.456
#
###########################################################

# Loading/Attaching And Listing Of Packages (dplyr)
library(dplyr)


url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
zipArchive <- "UCI HAR Dataset.zip"

# check if zip archive has already been downloaded
if (!file.exists(zipArchive)){
  download.file(url, zipArchive, mode = "wb")
}

# unzip zip archive
dataPath <- "UCI HAR Dataset"
if (!file.exists(dataPath)) {
  unzip(zipArchive)
}

# read train data 
subjectTrain <- read.table("./UCI HAR Dataset/train/subject_train.txt", header = FALSE)
xTrain <- read.table("./UCI HAR Dataset/train/X_train.txt", header = FALSE)
yTrain <- read.table("./UCI HAR Dataset/train/Y_train.txt", header = FALSE)

# read test data
subjectTest <- read.table("./UCI HAR Dataset/test/subject_test.txt", header = FALSE)
xTest <- read.table("./UCI HAR Dataset/test/X_test.txt", header = FALSE)
yTest <- read.table("./UCI HAR Dataset/test/Y_test.txt", header = FALSE)

# read data description
features <- read.table("./UCI HAR Dataset/features.txt", as.is = TRUE)

# read activity labels
activities <- read.table("./UCI HAR Dataset/activity_labels.txt")
colnames(activities) <- c("activityId", "activityLabel")

# 1. Merges the training and the test sets to create one data set.
xData        <- rbind(xTrain, xTest)
yData        <- rbind(yTrain, yTest)
subjectData  <- rbind(subjectTrain, subjectTest)

# 2. Extracts only the measurements on the mean and standard deviation for each measurement.
xDataMeanStd <- xData[, grep("-(mean|std)\\(\\)", read.table("./UCI HAR Dataset/features.txt")[, 2])]
names(xDataMeanStd) <- read.table("./UCI HAR Dataset/features.txt")[grep("-(mean|std)\\(\\)", read.table("./UCI HAR Dataset/features.txt")[, 2]), 2] 

# View(xDataMeanStd)
# dim(xDataMeanStd)

# 3. Use descriptive activity names to name the activities in the data set
yData[, 1] <- read.table("./UCI HAR Dataset/activity_labels.txt")[yData[, 1], 2]
names(yData) <- "Activity"

# View(yData)

# 4. Appropriately label the data set with descriptive activity names.
names(subjectData) <- "Subject"

mergedData <- cbind(xDataMeanStd, yData, subjectData)

# Setting descriptive names for all variables.

names(mergedData) <- make.names(names(mergedData))
names(mergedData) <- gsub('Acc',"Acceleration",names(mergedData))
names(mergedData) <- gsub('GyroJerk',"AngularAcceleration",names(mergedData))
names(mergedData) <- gsub('Gyro',"AngularSpeed",names(mergedData))
names(mergedData) <- gsub('Mag',"Magnitude",names(mergedData))
names(mergedData) <- gsub('^t',"TimeDomain.",names(mergedData))
names(mergedData) <- gsub('^f',"FrequencyDomain.",names(mergedData))
names(mergedData) <- gsub('\\.mean',".Mean",names(mergedData))
names(mergedData) <- gsub('\\.std',".StandardDeviation",names(mergedData))
names(mergedData) <- gsub('Freq\\.',"Frequency.",names(mergedData))
names(mergedData) <- gsub('Freq$',"Frequency",names(mergedData))

View(mergedData)

# 5. From the data set in step 4, creates a second, independent tidy data set with the average 
# of each variable for each activity and each subject.
tightyData2<-aggregate(. ~Subject + Activity, mergedData, mean)
tightyData2<-tightyData2[order(tightyData2$Subject,tightyData2$Activity),]
write.table(tightyData2, file = "./UCI HAR Dataset/tidydata.txt",row.name=FALSE)





