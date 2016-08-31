# Getting and Cleaning Data - Course Project - Code Book

## Overview

This document describes the constants, functions, variables, and transformations included in run_analysis.R.

The run_analysis.R script is organized by sections, and each section is organized by steps.

## Section 1: obtain and load the data

### Step 1.1: download and unzip raw data

If zipfile does not already exist, download zipfile containing the "Human Activity Recognition Using Smartphones Data Set". If all files contained in the zipfile does not already exist, unzip the zipfile. All download and unzipped files are stored inside a single directory with a relative path specified by RAW_DATA_DIR_PATH.

* RAW_DATA_ZIPFILE_URL (*constant*): url to raw data zipfile
* RAW_DATA_DIR_PATH (*constant*): path to raw data work directory
* RAW_DATA_ZIPFILE_PATH (*constant*): path to raw data zipfile
* raw_data_zip_list (*variable*): list of files inside zipfile
* raw_data_zip_file_paths (*variable*): get list of file paths after unzipping

### Step 1.2: read relevant files containing meta data

Read and store the contents of the "feature.txt" and "activity_labels.txt", which include meta data for the "train" and "test" data sets. The term "local path" is used to indicate paths relative to the path RAW_DATA_DIR_PATH.

* FEATURES_FILE_LOCAL_PATH (*constant*): local path to "features" file
* ACTIVITIES_FILE_LOCAL_PATH (*constant*): local path to "activities" file
* read_meta (*function*): function for reading meta data files
* features (*variable*): vector of feature names
* activities (*variable*): vector of activity names

### Step 1.3: read relevant files containing data

Read, column merge, and store the contents of "[T]/subject_[T].txt", "[T]/y_[T].txt", "[T]/y_[T].txt" for [T] = {"test","train"}. The term "local path" is used to indicate paths relative to the path RAW_DATA_DIR_PATH.

* TEST_FILES_SUFFIX (*constant*): suffix to "test" data set
* TRAIN_FILES_SUFFIX (*constant*): suffix to "train" data set
* read_data (*function*): function for reading and column merging a list of data files
* get_data_file_local_paths (*function*): returns list of "[T]/subject_[T].txt", "[T]/y_[T].txt", "[T]/y_[T].txt" for a given [T]
* df_test (*variable*): data frame of the "test" data set
* df_train (*variable*): data frame of the "train" data set

## Section 2: tidy the data

The steps of this section corresponds to step described in the Instruction section of README.md.

### Step 2.1: merge the training and test sets to create one data set

Merge the rows of the "train" and "test" data frames using rbind.

* df (*variable*): data frame obtained from merging the rows of df_train and df_test

### Step 2.2: extracts only the measurements on the mean and standard deviation for each measurement

The grep function is used to select features with names that include either '-mean()' or '-std()'. The subset of columns corresponding the the selected features, subjects, and activities are used to redefine the data frame df. Column names are also added in this substep.

* select_feature_ind (*variable*): selected feature indices (names finishing in either '-mean()' or  '-std()')
* select_df_ind (*variable*): selected data frame columns (recall 'subject', 'activity' are the first and second columns)

### Step 2.3: use descriptive activity names to name the activities in the data set

The 'activity' column of the data frame df is updated by converting original column vector of integers into a factor with labels corresponding to the activities variable.

### Step 2.4: use appropriate labels the data set with descriptive variable names


The gsub fucntion is used to update the names of the columns in order to reflect the following changes:
1. replace prefix 't' with 'time_'
2. replace prefix 'f' with 'frequency_'
3. replace 'Body', 'BodyBody', ... with 'body_'
4. replace 'Gravity', ... with 'gravity_'
5. replace 'Acc', ... with 'accelerometer'
6. replace 'Gyro', ... with 'gyroscope'
7. replace 'Mag', ... with '_magnitude'
8. replace 'Jerk', ... with '_jerk'
9. replace '()', ... with ''
10. replace '-', ... with '_'
11. replace 'std', ... with 'stddev'

In addition, the names of all column are switch to lower case letter using tolower function.

### Step 2.5: from the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

The melt and dcast function from the reshape2 package are used average of each measurement for each activity and each subject. The resulting data frame, df_avg, is written using the write.table() function with the row.names=FALSE to the file 'averages.txt'.

* df_avg (*variable*) : new tidy data set with the average of each measurement for each activity and each subject
* OUT_DATA_FILE_PATH (*constant*): path of new tidy data set file
