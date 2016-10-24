require(dplyr)
rm(list=ls())

# Read human readable activity labels
activity_labels <- read.csv('UCI HAR Dataset/activity_labels.txt', sep=' ', col.names = c('num_label', 'label'), header=FALSE)

# Determine which feature indices correspond to mean or std.
feature_names <- read.csv('UCI HAR Dataset/features.txt', sep=' ', colClasses=c('integer', 'character'))
indices_to_keep <- grep('mean\\(\\)|std\\(\\)', feature_names[,2])

# read test data and filter to mean and std
testdf <- read.fwf('UCI HAR Dataset/test/X_test.txt', widths=rep(16, 561))
testdf <- testdf[,indices_to_keep]

# Read activity labels and subject labels.  Bind into a big data frame.
testlabeldf <- read.csv('UCI HAR Dataset/test/y_test.txt', sep=' ', header=FALSE, col.names = c('numeric_label'))
testlabeldf_merged <- merge(testlabeldf, activity_labels, by.x=c('numeric_label'), by.y=c('num_label'), sort=FALSE)
testlabels <- testlabeldf_merged['label']

testsubjectdf <- read.csv('UCI HAR Dataset/test/subject_test.txt', sep=' ', header=FALSE)
testall <- cbind(testdf, testlabels, testsubjectdf)

# read training data and filter to mean and std
traindf <- read.fwf('UCI HAR Dataset/train/X_train.txt', widths=rep(16, 561))

feature_names <- read.csv('UCI HAR Dataset/features.txt', sep=' ', colClasses=c('integer', 'character'))
indices_to_keep <- grep('mean\\(\\)|std\\(\\)', feature_names[,2])
traindf <- traindf[,indices_to_keep]

# Read activity labels and subject labels.  Bind into a big data frame.
trainlabeldf <- read.csv('UCI HAR Dataset/train/y_train.txt', sep=' ', header=FALSE, col.names = c('numeric_label'))
trainlabeldf_merged <- merge(trainlabeldf, activity_labels, by.x=c('numeric_label'), by.y=c('num_label'), sort=FALSE)
trainlabels <- trainlabeldf_merged['label']

trainsubjectdf <- read.csv('UCI HAR Dataset/train/subject_train.txt', sep=' ', header=FALSE)
trainall <- cbind(traindf, trainlabels, trainsubjectdf)

# Combine test and training data.
test_and_train <- rbind(testall, trainall)
names(test_and_train) <- c(feature_names[indices_to_keep,2], "label", "subject")

avgs_test_and_train <- aggregate(test_and_train, by=list(label, subject), FUN=mean)
avgs_test_and_train <- select(avgs_test_and_train, -label)
avgs_test_and_train <- select(avgs_test_and_train, -subject)
avgs_test_and_train <- rename(avgs_test_and_train, label=Group.1, subject=Group.2)

write.csv(avgs_test_and_train, "processed.csv")