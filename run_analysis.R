library(reshape2)

# download zip file
file <- "GCD_projectdata.zip"
if (!file.exists(file)){
    fileURL <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip "
    download.file(fileURL, file, method="curl")
}  
# unzip file
if (!file.exists("UCI HAR Dataset")) { 
    unzip(file) 
}

# load activity labels 
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels[,2] <- as.character(activity_labels[,2])
## load features
features <- read.table("UCI HAR Dataset/features.txt")
features[,2] <- as.character(features[,2])

# extract only the measurements on the mean and standard deviation for each measurement
mini_set <- grep(".*mean.*|.*std.*", features[,2])
mini_set_names <- features[mini_set,2]
mini_set_names = gsub('-mean', 'Mean', mini_set_names)
mini_set_names = gsub('-std', 'Std', mini_set_names)
mini_set_names <- gsub('[-()]', '', mini_set_names)

# load data into environment
train <- read.table("UCI HAR Dataset/train/X_train.txt")[mini_set]
train_activities <- read.table("UCI HAR Dataset/train/Y_train.txt")
train_subject <- read.table("UCI HAR Dataset/train/subject_train.txt")
train <- cbind(train_subject, train_activities, train)

test <- read.table("UCI HAR Dataset/test/X_test.txt")[mini_set]
test_activities <- read.table("UCI HAR Dataset/test/Y_test.txt")
test_subject <- read.table("UCI HAR Dataset/test/subject_test.txt")
test <- cbind(test_subject, test_activities, test)

# merge both data sets
combined_set <- rbind(train, test)

# add labels to combined data set
colnames(combined_set) <- c("subject", "activity", mini_set_names)

# assign variable classes and levels
combined_set$activity <- factor(combined_set$activity, 
                                levels = activity_labels[,1], 
                                labels = activity_labels[,2])
combined_set$subject <- as.factor(combined_set$subject)

combined_set_melted <- melt(combined_set, id = c("subject", "activity"))
combined_set_mean <- dcast(combined_set_melted, subject + activity ~ variable, mean)

# create a second, independent tidy data set w/ average of each variable for each activity and each subject
write.table(combined_set_mean, "independent_dataset.txt", row.names = FALSE, quote = FALSE)