library("dplyr")

# Project directory
# setwd("~/R/rdir/coursera/GCD_project")

# FUNCTION SECTION
# read in all of the individual files by their fnames index
read.in.files <- function() {
	feature_names <<- read.table(file=fnames[2], stringsAsFactors=FALSE)[[2]]
	subject_test <<- read.table(file =fnames[16], header=FALSE, stringsAsFactors=FALSE)
	X_test <<- read.table(file =fnames[17], header=FALSE, stringsAsFactors=FALSE)
	y_test <<- read.table(file =fnames[18], header=FALSE, stringsAsFactors=FALSE)
	subject_train <<- read.table(file =fnames[30], header=FALSE, stringsAsFactors=FALSE)
	X_train <<- read.table(file =fnames[31], header=FALSE, stringsAsFactors=FALSE)
	y_train <<- read.table(file =fnames[32], header=FALSE, stringsAsFactors=FALSE)
	activity_labels <<- read.table(file=fnames[1], stringsAsFactors=FALSE)[[2]]
	
	reset.directory()
}

# merge the sets for the test and train data and relabel
merge.activity <- function() {
	# merge the subjects and activities to each table
	test = data.frame(subject_test, y_test, X_test)
	train = data.frame(subject_train, y_train, X_train)
	
	# rename the variables in each table
	variable_names = c("subject", "activity", c(feature_names))
	names(test) = variable_names
	names(train) = variable_names
	
	# merge the two table on top of each other
	activity <<- rbind(test, train)
}

# extract mean and std for measurements
extract.mean.std <- function() {
	i = grep("(subject|activity|mean\\(|std)", names(activity))
	activity.mean.std <<- activity[,i]
}

# convert activities to descriptive factors
descriptive.activities <- function() {
	activity.mean.std$activity <<- as.factor(activity.mean.std$activity)
	levels(activity.mean.std$activity) <<- activity_labels
}

# change subject number to factor
subject_to_factor <- function() {
	activity.mean.std$subject <<- as.factor(activity.mean.std$subject)
}

# reset working directory
reset.directory <- function() {
	setwd("../")
}

# rename variable names to be more descriptive
renames.variables <- function() {
	names(activity.mean.std) <<- gsub("^t","time", names(activity.mean.std))
	names(activity.mean.std) <<- gsub("^f","frequency", names(activity.mean.std))
	names(activity.mean.std) <<- gsub("Acc","Acceleration", names(activity.mean.std))
	names(activity.mean.std) <<- gsub("Gyro","Gyroscope", names(activity.mean.std))
	names(activity.mean.std) <<- gsub("\\(\\)","", names(activity.mean.std))
	names(activity.mean.std) <<- gsub("-","", names(activity.mean.std))
}

# END FUNCTION SECTION

if(!file.exists("data")) { # create directory if it doesn't exist
	dir.create("data")
}

setwd("./data")		# cd to data

if(!file.exists("tempsamsung.zip")) { # download file if it doesn't exist
	fileHandle <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
	download.file(fileHandle, destfile="tempsamsung.zip", method="curl")
	dateDownloaded <- date()
	fnames = unzip("tempsamsung.zip", list=TRUE)$Name
	unzip("tempsamsung.zip", files=fnames)
}

fnames = unzip("tempsamsung.zip", list=TRUE)$Name

# 561 variables measurement per person
# 2947 obs for total among test subjects; 7352 obs for total train subjects
# 561 x 10299 obs measurements

read.in.files()
merge.activity()
extract.mean.std()
descriptive.activities()
subject_to_factor()
renames.variables()

by_subject_act = group_by(activity.mean.std, subject, activity)
out = by_subject_act %>% summarise_each(funs(mean))

write.table(out, "./data/mean_by_subject_act.txt", row.names=FALSE)