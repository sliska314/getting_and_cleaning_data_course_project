######################################################################
#                                                                    #
#   Coursera: Getting and Cleaning Data (Aug 15 - Sept 15, 2016)     #
#   Course Project                                                   #
#                                                                    #
#   Overview:                                                        #
#     Create tidy dataset from the files of "Human Activity          #
#     Recognition Using Smartphones Data Set" obtained from the      #
#     UCI Machine Learning Repository. The tidying process           #
#     follows steps 1 - 5 discussed in the README.md file.           #
#                                                                    #
#   See also:                                                        #
#     ./README.md                                                    #
#     ./CodeBook.md                                                  #
#                                                                    #
######################################################################

library( reshape2 )

# SECTION 1: OBTAIN AND LOAD THE DATA
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

# STEP 1.1: download and extract raw data
# note: "local path" corresponds the path of a file relative
# to the raw data directory
#--------------------------------------------------------------------#

# url to raw data zipfile
RAW_DATA_ZIPFILE_URL = paste0(
  'https://d396qusza40orc.cloudfront.net/',
  'getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip' )

# path to raw data work directory
RAW_DATA_DIR_PATH = '.raw'

# path to raw data zipfile
RAW_DATA_ZIPFILE_PATH = file.path(
  RAW_DATA_DIR_PATH,
  'uci_har_dataset.zip' )

# download raw data zipfile from url
if ( !file.exists( RAW_DATA_ZIPFILE_PATH ) ) {

  download.file(
    url = RAW_DATA_ZIPFILE_URL,
    destfile = RAW_DATA_ZIPFILE_PATH,
    method = "curl" )

}

# get list of files inside zipfile
raw_data_zip_list <- unzip(
  zipfile = RAW_DATA_ZIPFILE_PATH,
  exdir = RAW_DATA_DIR_PATH,
  list = TRUE )

# get list of file paths after unzipping
raw_data_zip_file_paths = file.path(
  RAW_DATA_DIR_PATH,
  raw_data_zip_list$Names )

# unzip raw data zipfile
if ( any( !file.exists( raw_data_zip_file_paths ) ) ) {

  unzip(
    zipfile = RAW_DATA_ZIPFILE_PATH,
    exdir = RAW_DATA_DIR_PATH )

}


# STEP 1.2: read relevant files containing meta data
# note: "local path" corresponds the path of a file relative
# to the raw data directory
#--------------------------------------------------------------------#

# local path to "features" file
FEATURES_FILE_LOCAL_PATH = file.path(
  'UCI HAR Dataset',
  'features.txt' )

# local path to "activities" file
ACTIVITIES_FILE_LOCAL_PATH = file.path(
  'UCI HAR Dataset',
  'activity_labels.txt' )

# function for reading meta data files
read_meta <- function( file_local_path ) {

  # read file as data frames
  # * we do not read the first column since its values corresponds
  #   to the line number (and the order of entries)
  df <- read.table(
    file = file.path( RAW_DATA_DIR_PATH, file_local_path ),
    header = FALSE,
    sep = '',
    stringsAsFactors = FALSE,
    colClasses = c( 'NULL', 'character' ),
    col.names = c( NA, 'label' ) )

  # return character vector with labels
  return( df$label )

}

# read "features" data file
features <- read_meta(
  file_local_path = FEATURES_FILE_LOCAL_PATH )

# read "activities" data file
activities <- read_meta(
  file_local_path = ACTIVITIES_FILE_LOCAL_PATH )

# STEP 1.3: read relevant files containing data
#--------------------------------------------------------------------#

# suffix to "test" data set
TEST_FILES_SUFFIX = 'test'

# suffix to "train" data set
TRAIN_FILES_SUFFIX = 'train'

# function for reading data files
read_data <- function( file_local_paths ) {

  # read files as data frames
  df_list <- lapply(
    X = file_local_paths,
    FUN = function( x ) {
      read.table(
        file = file.path( RAW_DATA_DIR_PATH, x ),
        header = FALSE,
        sep = '',
        colClasses = 'numeric' )
    } )

  # return merged data frames
  return( do.call( what = cbind, args = df_list ) )

}

# function for returning vector of data file local paths
get_data_file_local_paths <- function( suffix ) {

  out <- sprintf(
    file.path(
      'UCI HAR Dataset',
      '%1$s',
      c('subject_%1$s.txt','y_%1$s.txt','X_%1$s.txt') ),
    suffix )

  return( out )

}

# read "test" data files
df_test <- read_data(
  file_local_paths =
    get_data_file_local_paths( suffix = TEST_FILES_SUFFIX ) )

# read "train" data files
df_train <- read_data(
  file_local_paths =
    get_data_file_local_paths( suffix = TRAIN_FILES_SUFFIX ) )




# SECTION 2: TIDY THE DATA
#++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++#

# STEP 2.1: merge the training and test sets to create one data set
#--------------------------------------------------------------------#

# merge rows of "train" and "test" data frames
df <- rbind( df_train, df_test )


# STEP 2.2: extracts only the measurements on the mean and
# standard deviation for each measurement
#--------------------------------------------------------------------#

# selected feature indices (names finishing in
# either '-mean()' or  '-std()')
select_feature_ind <- grep(
  pattern = '-(mean\\(\\)|std\\(\\))',
  x = features )

# selected data frame columns, recall 'subject', 'activity'
# are the first and second columns
select_df_ind <- c( 1:2, select_feature_ind + 2 )

# extract data columns
df <- df[ , select_df_ind ]

# assign column names
names( df ) <- c(
  'subject',
  'activity',
  features[ select_feature_ind ] )


# STEP 2.3: use descriptive activity names to name the
# activities in the data set
#--------------------------------------------------------------------#

df$activity <- factor(
  x = df$activity,
  labels = tolower( activities ) )


# STEP 2.4: use appropriate labels the data set
# with descriptive variable names
#--------------------------------------------------------------------#

# replace prefix 't' with 'time_'
names( df ) <- gsub( '^t', 'time_', names( df ) )

# replace prefix 'f' with 'frequency_'
names( df ) <- gsub( '^f', 'frequency_', names( df ) )

# replace 'Body', 'BodyBody', ... with 'body_'
names( df ) <- gsub( '(Body)+', 'body_', names( df ) )

# replace 'Gravity', ... with 'gravity_'
names( df ) <- gsub( 'Gravity', 'gravity_', names( df ) )

# replace 'Acc', ... with 'accelerometer'
names( df ) <- gsub( 'Acc', 'accelerometer', names( df ) )

# replace 'Gyro', ... with 'gyroscope'
names( df ) <- gsub( 'Gyro', 'gyroscope', names( df ) )

# replace 'Mag', ... with '_magnitude'
names( df ) <- gsub( 'Mag', '_magnitude', names( df ) )

# replace 'Jerk', ... with '_jerk'
names( df ) <- gsub( 'Jerk', '_jerk', names( df ) )

# replace '()', ... with ''
names( df ) <- gsub( '\\(\\)', '', names( df ) )

# replace '-', ... with '_'
names( df ) <- gsub( '-', '_', names( df ) )

# replace 'std', ... with 'stddev'
names( df ) <- gsub( 'std', 'stddev', names( df ) )

# use only lower case
names( df ) <- tolower( names( df ) )


# STEP 2.5: from the data set in step 4, creates a second,
# independent tidy data set with the average of each
# variable for each activity and each subject.
#--------------------------------------------------------------------#

df_avg <- dcast(
    data = melt(
      data = df,
      id = c( 'subject', 'activity' ) ),
    formula = subject + activity ~ variable,
    fun.aggregate = mean )

# file path of new tidy data set with average
OUT_DATA_FILE_PATH = 'averages.txt'

# write new data frame to file
write.table(
  df_avg,
  file = OUT_DATA_FILE_PATH,
  row.names = FALSE )


