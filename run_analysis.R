##########
##########  This scpripts downloads data from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip 
##########  Purpose of the scrips is prepare tidy data set, according to Coursera Getting and Cleaning Data requiremet.
##########  This scripts  requires installed libraries: dplyr and reshape
##########  !!!! Instalation of those two libraries is out of the scope of the script !!!!
##########  !!!! Assure instalation of those two libraries before running this script !!!!
##########



########## Storing initial working directory and cleaning environment, reading libraries dplyp and reshape

rm(list=ls()) # cleaning environment
initial_wd<-getwd()

library(dplyr)
library(reshape)

########## Download and unzip data into data sub-directory in the current working directory, setting new working directory



if(!file.exists("./data")){dir.create("./data")}
fileUrl<-"https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl, destfile = "./data/dataset.zip")
setwd("./data")
unzip("dataset.zip")
setwd("./UCI HAR Dataset") 

rm(fileUrl)

########## Reading data from files and storing into variables  


activity_label<-read.table("activity_labels.txt")
features<-read.table("features.txt")
x_test<-read.table("./test/X_test.txt")
y_test<-read.table("./test/y_test.txt")
subject_test<-read.table("./test/subject_test.txt")
x_train<-read.table("./train/X_train.txt")
y_train<-read.table("./train/y_train.txt")
subject_train<-read.table("./train/subject_train.txt")

########## Adding indexes to variables which will be used later for merging



x_test<-mutate(x_test, ID=7353:10299)
x_train<-mutate(x_train, ID=1:7352)
y_test<-mutate(y_test, ID=7353:10299)
y_train<-mutate(y_train, ID=1:7352)
subject_test<-mutate(subject_test, ID=7353:10299)
subject_train<-mutate(subject_train, ID=1:7352)


########## Merging all data into one table


test_data<-merge(y_test,x_test, by.x = "ID", by.y = "ID")
test_data<-merge(subject_test,test_data, by.x = "ID", by.y = "ID")
train_data<-merge(y_train,x_train, by.x = "ID", by.y = "ID")
train_data<-merge(subject_train,train_data, by.x = "ID", by.y = "ID")
all_data<-bind_rows(train_data,test_data)

##########  Removing unessesary variables


rm(test_data)
rm(train_data)
rm(x_test)
rm(x_train)
rm(y_test)
rm(y_train)
rm(subject_test)
rm(subject_train)


########## Prepare vector with names variables, Name variables


new_names<-c("id","subject","activity", as.character(features$V2))
names(all_data)<-new_names

########## Name activity - change from number to description


all_data$activity<-activity_label[all_data$activity,2]

########## Finding all names which contains mean() and std() - TRUE



index_mean_std<-(grepl("mean()", names(all_data))&!grepl("meanFreq()", names(all_data)))|grepl("std()", names(all_data))

########## adding to index_mean_std "activity" and "subject" variable position, 
########## after that steps all variables will have TRUE on its position in index_mean_std - temprary variable


index_mean_std[2:3]<-TRUE

########## Creating tidy data set


tidy_data_set<-all_data[,index_mean_std]


########## Cleaning environment


rm(new_names)
rm(all_data)
rm(index_mean_std)
rm(features)
rm(activity_label)


########## Creating the second data set with averages by activity and subject 


preparation<-melt(tidy_data_set, id.vars = 1:2)

averages_final<-cast(preparation, activity + subject  ~ variable, mean)




########## Setting working directory to original


setwd(initial_wd)


########## Writing output into files

write.csv(tidy_data_set,"./data/tidy_data_set.csv")
write.csv(averages_final, "./data/averages_final.csv")


########## Cleaning environment


rm(preparation)
rm(initial_wd)



print("Tidy data are stored in tidy_data_set, averages in averages_final. csv files can be found in ./data directory.")