setwd("~/coursera/wearablecrap")  ## change to reflect your local workspace. data MUST be in your workspace and in in the original structure it was made available in for the script to work without additional changes
library(dplyr)
library(data.table)
make_list <- function(labels){  ## function for making labels to subset with later
  as.vector(mean_std <- c(1,2,grep(".*-mean\\(.*|.*-std\\(.*",labels, value = FALSE)))
  names(mean_std) <- c("activity","subject",grep(".*-mean\\(.*|.*-std\\(.*",labels, value = TRUE))
  return(mean_std)
}

labels <- c("activity","subject",grep(".*-mean\\(.*|.*-std\\(.*",as.vector(read.table("features.txt")[,"V2"]), value = TRUE)) ##list of all labels
act_list <- as.list(c(as.vector(read.table("activity_labels.txt")[,"V2"])))  ## list of activities performed during measurements
testbound <- dplyr::tbl_df(bind_cols(data.frame(as.list(read.table("./test/y_test.txt")),as.list(read.table("./test/subject_test.txt"))), read.table("./test/X_test.txt"))) ## coallation of X Y Z data into single set
names(testbound) <- 1:length(testbound) ## numbering columns for later bind
trainbound <- dplyr::tbl_df(bind_cols(data.frame(as.list(read.table("./train/y_train.txt")),as.list(read.table("./train/subject_train.txt"))), read.table("./train/X_train.txt"))) ## coallation of X Y Z data into single set
names(trainbound) <- 1:length(trainbound)  ## numbering columns for later bind
mss_df <- data.table(dplyr::select(dplyr::union(testbound,trainbound),make_list(labels)))  ## binding train and test datasets into single data.table
rm(testbound)
rm(trainbound)
mean_set = data.table() ## empty table for summary data
for(i in 1:30){
  tmp <- data.table()
  for(h in 1:6){
    tmp <- dplyr::summarise_each(mss_df[which((mss_df$activity == h) & (mss_df$subject == i))],funs(mean))  ## creation of summary data
    tmp[, activity := as.character(activity)][activity == h, activity := act_list[[h]]]  ##changing activity 'codes' into activity "names" for tidy set
    mean_set <- dplyr::bind_rows(mean_set,tmp)  ##combining summary data into tidy data set
  }
}
for(h in 1:6){
  mss_df[, activity := as.character(activity)][activity == h, activity := act_list[[h]]] ##changing activity 'codes' into activity "names" for wide set
}
rm(tmp)  ## mopping the floors
rm(act_list)
rm(labels)
rm(h)
rm(i)
