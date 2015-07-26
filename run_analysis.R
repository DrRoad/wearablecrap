setwd("~/coursera/gettingdata")
library(dplyr)
library(data.table)
make_list <- function(labels){
  as.vector(mean_std <- c(1,2,grep(".*-mean\\(.*|.*-std\\(.*",labels, value = FALSE)))
  names(mean_std) <- c("activity","subject",grep(".*-mean\\(.*|.*-std\\(.*",labels, value = TRUE))
  return(mean_std)
}

labels <- as.list(c("activity","subject",as.vector(read.table("~/coursera/gettingdata/UCI HAR Dataset/features.txt")[,"V2"])))
act_list <- as.list(c(as.vector(read.table("~/coursera/gettingdata/UCI HAR Dataset/activity_labels.txt")[,"V2"])))
sub_act_df <- data.frame(as.list(read.table("~/coursera/gettingdata/UCI HAR Dataset/test/y_test.txt")),as.list(read.table("~/coursera/gettingdata/UCI HAR Dataset/test/subject_test.txt")))
testbound <- dplyr::tbl_df(bind_cols(sub_act_df, read.table("~/coursera/gettingdata/UCI HAR Dataset/test/X_test.txt")))
names(testbound) <- 1:length(testbound)
sub_act_df_train <- data.frame(as.list(read.table("~/coursera/gettingdata/UCI HAR Dataset/train/y_train.txt")),as.list(read.table("~/coursera/gettingdata/UCI HAR Dataset/train/subject_train.txt")))
trainbound <- dplyr::tbl_df(bind_cols(sub_act_df_train, read.table("~/coursera/gettingdata/UCI HAR Dataset/train/X_train.txt")))
names(trainbound) <- 1:length(trainbound)
test_train_all <- dplyr::union(testbound,trainbound)
mean_std <- make_list(labels)
mean_std_slect <- dplyr::select(test_train_all,mean_std) 
mss_df = data.table(mean_std_slect)
mean_set = data.table()

for(i in 1:30){
  tmp <- data.table()
  for(h in 1:6){
    tmp <- dplyr::summarise_each(mss_df[which((mss_df$activity == h) & (mss_df$subject == i))],funs(mean))
    tmp[, activity := as.character(activity)][activity == h, activity := act_list[[h]]]
    mean_set <- dplyr::bind_rows(mean_set,tmp)
  }
}
