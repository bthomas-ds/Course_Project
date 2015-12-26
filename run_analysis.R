# B. Thomas
# 12/25/2015
# Getting and Cleaning Data
# The purpose of this project is to demonstrate your ability to collect, work with, and clean a data set. The goal is to prepare tidy data that can be used 
# for later analysis. You will be graded by your peers on a series of yes/no questions related to the project. 
# You will be required to submit: 1) a tidy data set as described below, 2) a link to a Github repository with your script for performing the analysis, 
# and 3) a code book that describes the variables, the data, and any transformations or work that you performed to clean up the data called CodeBook.md. 
# You should also include a README.md in the repo with your scripts. This repo explains how all of the scripts work and how they are connected. 
# 
# One of the most exciting areas in all of data science right now is wearable computing - see for example this article . Companies like Fitbit, Nike, 
# and Jawbone Up are racing to develop the most advanced algorithms to attract new users. The data linked to from the course website represent 
# data collected from the accelerometers from the Samsung Galaxy S smartphone. A full description is available at the site where the data was obtained:
# http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones
# 
# Here are the data for the project:
#   
#  https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
#
# You should create one R scri#pt called run_analysis.R that does the following. 
# 
# 1. Merges the training and the test sets to create one data set.
# 2. Extracts only the measurements on the mean and standard deviation for each measurement. 
# 3. Uses descriptive activity names to name the activities in the data set
# 4. Appropriately labels the data set with descriptive variable names. 
# 5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

# clean up global environment
rm(list = ls())

# set working directory for the course project
setwd("/home/bthomas/Coursera_Cleaning_Data/Course_Project")

# load dply & tidy libraries
library(dplyr)
library(tidyr)
library(data.table)
library(reshape2)


# download zip archive to the data folder inside of the data folder - check to make sure that it has not already been downloaded

if(!file.exists("./data/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip")){
  fileUrl1 <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"  
  download.file(fileUrl1,destfile="./data/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip",method="curl")
  
  # unzip to the data folder - assume that if a download was necessary, the files should be extracted
  unzip(zipfile = "./data/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip", list = FALSE, overwrite = TRUE, exdir = "/home/bthomas/Coursera_Cleaning_Data/Course_Project/data")
    
}

# set working directory to location where the archive was extracted
setwd("/home/bthomas/Coursera_Cleaning_Data/Course_Project/data")

# Load activity labels + features
activityLabels <- read.table("UCI HAR Dataset/activity_labels.txt")
activityLabels[,2] <- as.character(activityLabels[,2])
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# Retrieve only the data on mean and standard deviation
featuresWanted <- grep(".*mean.*|.*std.*", features[,2])
featuresWanted.names <- features[featuresWanted,2]
featuresWanted.names = gsub('-mean', 'Mean', featuresWanted.names)
featuresWanted.names = gsub('-std', 'Std', featuresWanted.names)
# Remove all column names that have a () in the name
featuresWanted.names <- gsub('[-()]', '', featuresWanted.names)


# Get datasets from the data folder
train <- read.table("UCI HAR Dataset/train/X_train.txt")[featuresWanted]
trainActivities <- read.table("UCI HAR Dataset/train/y_train.txt")
trainSubjects <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(trainSubjects, trainActivities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[featuresWanted]
testActivities <- read.table("UCI HAR Dataset/test/y_test.txt")
testSubjects <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(testSubjects, testActivities, test)

# merge datasets and add labels
allData <- rbind(train, test)
colnames(allData) <- c("subject", "activity", featuresWanted.names)

# turn activities & subjects into factors
allData$activity <- factor(allData$activity, levels = activityLabels[,1], labels = activityLabels[,2])
allData$subject <- as.factor(allData$subject)

allData.melted <- melt(allData, id = c("subject", "activity"))
allData.mean <- dcast(allData.melted, subject + activity ~ variable, mean)

write.table(allData.mean, "tidy.txt", row.names = FALSE, quote = FALSE)


