##1. Merges the training and the test sets to create one data set
### read the train files and combine them
subject_train<-read.table("./UCI HAR Dataset/train/subject_train.txt")
y_train<-read.table("./UCI HAR Dataset/train/y_train.txt")
x_train<-read.table("./UCI HAR Dataset/train/X_train.txt")
trainData<-cbind(subject_train, y_train)
trainData<-cbind(trainData, x_train)

### read the test tiles and combine them
subject_test<-read.table("./UCI HAR Dataset/test/subject_test.txt")
y_test<-read.table("./UCI HAR Dataset/test/y_test.txt")
x_test<-read.table("./UCI HAR Dataset/test/X_test.txt")
testData<-cbind(subject_test, y_test)
testData<-cbind(testData, x_test)

### combine the train data with test data. 
### Then rename the duplicate column names: Vsub for subject id, and VAct for activity id
allData<-rbind(trainData, testData)
names(allData)[1]<-"Vsub"
names(allData)[2]<-"VAct"

##2. Extracts only the measurements on the mean and standard deviation for
##   each measurement
### load in the variable names from features.txt file
features<-read.table("./UCI HAR Dataset/features.txt", stringsAsFactors = FALSE)

### find out the positions of all mean() and std() related variable names
rowid1<-grep("mean()", features$V2, fixed=TRUE)
rowid2<-grep("std()",features$V2, fixed=TRUE)
rowid<-c(rowid1, rowid2)
rowid<-sort(rowid)

### extracts the observations about the mean and standard deviation
library("dplyr")
narrowData<-select(allData, Vsub, VAct, num_range("V", rowid))

##3. Uses descriptive activity names to name the activities in the data set
activity_labels<-read.table("./UCI HAR Dataset/activity_labels.txt", 
                            stringsAsFactors = FALSE)
labelData<-merge(narrowData, activity_labels, by.x="VAct", by.y="V1",all=TRUE)

##4. Appropriately labels the data set with descriptive variable names
names(labelData)[1]="Activity_id"
names(labelData)[2]="Subject_id"
names(labelData)[3:68]=features[rowid, 2]
names(labelData)[69]="Activity_label"

##5. Creates a second, independent tidy data set with the average of each 
##   variable for each activity and each subject
attach(labelData)
TidyDataSet<-aggregate(labelData,by=list(Group.Activity=Activity_label,Group.Subject=Subject_id),
                    FUN=mean)
TidyDataSet<-TidyDataSet[c(-3, -4, -71)]
detach(labelData)

##  Output the tidy dataset
write.table(TidyDataSet, file="./UCI HAR Dataset/TidyDataSet.txt",
            row.names = FALSE)

