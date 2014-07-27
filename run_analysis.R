# This analysis uses the following packages to aid in processing the data.
library(plyr);
library(reshape2);


# This analysis runs against data from the "Human Activity Recognition Using Smartphones Dataset" version 1.0

# Remote location of origial raw data...
rawDataSourceUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip";
#   License:
#   ========
#   Use of this dataset in publications must be acknowledged by referencing the following publication [1] 
#   
#   [1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012
#   This dataset is distributed AS-IS and no responsibility implied or explicit can be addressed to the authors or their institutions for its use or misuse. Any commercial use is prohibited.
#   Jorge L. Reyes-Ortiz, Alessandro Ghio, Luca Oneto, Davide Anguita. November 2012.


# local (in working directory) file name where we'll store the raw data (zip file)
rawDataLocalFile <- "getdata-projectfiles-UCI HAR Dataset.zip";


########################
## LOAD RELEVANT DATA ##
########################

# The data used in this analysis is wrapped up into a single zip file at the location set above.
# If the zip file can be found locally (presumably from a prior download), then use that.
# Else download the file.
if ( file.exists(rawDataLocalFile) ) {
    finfo <- file.info(rawDataLocalFile);
    message("Raw data previously downloaded to ", rawDataLocalFile, " on ", finfo$ctime);
    rm(finfo);
} else {
    download.file(rawDataSourceUrl, destfile=rawDataLocalFile);
    message("Raw data download to ", rawDataLocalFile, " on ", Sys.time());
}

# All of the data used in this analysis is stored in fixed width tables.  This function
# can be used to extract/read the file specified by pathInZip, and place the resulting 
# data frame of the files content into a variable named by the dfVariableName parameter.
# This is a convienence method, keeping code 'DRY' (Don't Repeat Yourself.)
loadData <- function(dfVariableName, pathInZip) {
    if ( exists(dfVariableName) ) {
        message("Variable ", dfVariableName, " previously loaded.  Remove variable to trigger reload.");
    } else {
        message("Loading ", dfVariableName, " from ", pathInZip);
        #open a file pointer into the zip file (does not fully decompress, but does allow internal read.)
        tmp <- unz(rawDataLocalFile, pathInZip);
        open(tmp);
        # Load it into memory.
        tmpData <- read.table(tmp, header=FALSE);
        # Push the data up into the calling frame using the specified variable name.
        eval(parse(text=paste(dfVariableName, "<<-", "tmpData")));
        # Clean up after yourself.
        rm(tmpData);
        close(tmp);
    }
}


# Primary data has been split into a test and train group.
# Within each the data has been split into measures, in the X file,
# and indexes in the y and subject files.  Load all 3 for each group.

# train group
loadData("subject_train", "UCI HAR Dataset/train/subject_train.txt");
loadData("y_train", "UCI HAR Dataset/train/y_train.txt");
loadData("X_train", "UCI HAR Dataset/train/X_train.txt");
#test group
loadData("subject_test", "UCI HAR Dataset/test/subject_test.txt");
loadData("y_test", "UCI HAR Dataset/test/y_test.txt");
loadData("X_test", "UCI HAR Dataset/test/X_test.txt");

# The raw data contains meta-information files, specifically the
# list of measures in the features file and the list of activities
# (labels) in the activity_labels file.  Load these as well.

loadData("features", "UCI HAR Dataset/features.txt");
loadData("activity_labels", "UCI HAR Dataset/activity_labels.txt");

# Out of an abundance of caution, verify that the required raw data was
# properly loaded into the expected variables.  If not, produce an error.
if ( !all(sapply(list("subject_train", "X_train", "y_train", "subject_test", "X_test", "y_test"), FUN=exists)) ) {
    message("Data required for this analysis is missing.  Was there an error loading the data?  Try running download-RAW-project-data.R directly.");
    stop("Terminating analysis; missing required data.");
}

# END - LOAD RELEVANT DATA




########################
## RUN ANALYSIS STEPS ##
########################


##  STEP 1: MERGE DATA  ##

# The primary data is in the 'X' files, while the 'subject' and 'y' files 
# contain the (row aligned) subject identifier and training activity ids respectively.

# Merge training and test data into one...
#   The data is broken into two sets, training and test.  Here we will merge these 
#   two sets into a one (X, y, and subject each), being sure to do so in the same
#   order, so that the row alignment between each of the three remains correct.
X <- rbind(X_test, X_train);
y <- rbind(y_test, y_train);
subject <- rbind(subject_test, subject_train);

# Let's label the columns to better reflect their content...

#   first, label the meta-data
colnames(features) <- c("num", "label");
# ensure feature lables are in order (since features.txt provided a num in first column, they may be out of order.)
features <- features[ order(features$num), ]; # resort features by num.
colnames(activity_labels) <- c("num", "label");
# ensure activity lables are in order (since activity_labels.txt provided a num in first column, they may be out of order.)
activity_labels <- activity_labels[ order(activity_labels$num), ]; # resort activity_labels by num.

#   now label the first-order data
colnames(y) <- "activityId";
colnames(subject) <- "subjectId";
colnames(X) <- features$label;  #There are 561 features listed in order in the features data frame.

# Merge into a master data frame...
#   Since the three files are row aligned, and the identifiers in the subject and y 
#   data frames apply to the data in the X data frame, lets merge all three into one
#   'master' data frame.
master <- cbind(subject, y, X);


## STEP 2 ##

# Extract the mean and standard deviation measures...
#   Acording to the README.txt and the features_info.txt documentation that came with the raw data,
#   the feature labels are structured as signal '-' variable [ '-' X|Y|Z ]
#   There are a handful of exceptions, for example the angle measures, as well as some otherwise unexplained suffixes.
#   However, the target measures conform to the distinct pattern of begining with a signal name, followed by a dash,
#   followed by the exact text "mean()" for mean variables or "std()" for standard deviation variables, and finally 
#   an optional suffix such as "-X", etc.
#   Since the feature labels conform to a pattern, I will extract the list of mead and standard deviation measures
#   using a regular expression.  See grep or regex for an explanation of text matching in this manner.
meanLabels <- grep("^[^-]+-mean\\(\\)", features$label, perl=TRUE, value=TRUE);
stdLabels <- grep("^[^-]+-std\\(\\)", features$label, perl=TRUE, value=TRUE);

# Now subset from master the columns of interest.  Note, I am retaining the subject and activity ids
# as they will be needed shortly.
dataOfInterest <- master[, c("subjectId", "activityId", meanLabels, stdLabels)];


## STEP 3 ##

# Replace the activity id with a more meaningful activity label.
dataOfInterest <- mutate(dataOfInterest, activity = activity_labels[activityId, "label"]);
# Remove the activity id as it is now duplicative of the label.
dataOfInterest$activityId <- NULL;


## STEP 4 ##

# Instructions are to "Appropriately labels the data set with descriptive variable names."
# However, this was done as part of STEP 1 when we labeled the X data frame using the 
# feature labels defined in the features.txt file.
#
# > str(dataOfInterest)
# 'data.frame':    10299 obs. of  68 variables:
#     $ subjectId                  : int  2 2 2 2 2 2 2 2 2 2 ...
# $ tBodyAcc-mean()-X          : num  0.257 0.286 0.275 0.27 0.275 ...
# $ tBodyAcc-mean()-Y          : num  -0.0233 -0.0132 -0.0261 -0.0326 -0.0278 ...
# $ tBodyAcc-mean()-Z          : num  -0.0147 -0.1191 -0.1182 -0.1175 -0.1295 ...
# $ tGravityAcc-mean()-X       : num  0.936 0.927 0.93 0.929 0.927 ...
# $ tGravityAcc-mean()-Y       : num  -0.283 -0.289 -0.288 -0.293 -0.303 ...
# ...
# Note how the columns are labeld appropriately above.


## STEP 5 ##

# Instructions are to "Creates a second, independent tidy data set with the average of 
#    each variable for each activity and each subject."
#
# In other words, the subjectId and the activity are a composite key.  Each unique pairing
# should have the mean computed for all values of a given variable.
# Lets talk numbers...
# There are 66 measures of interest in dataOfInterest (33 measures times 2, mean() and std())
# DataOfInterest currently has 68 columns.  subjectId, activity, and the 66 measures of interest.
# We also know that there are 30 subjects, and there are 6 activities.  So, if subjectId and 
# activity form a composite key (and we assume at least one measure for all combinations) then 
# when we compute the means by subjectId+activity pairs, we should end up with 180 rows 
# (30 subjects times 6 activities.) Of course, we should have a mean for every measure of 
# interest, so the resulting data frame sould have 68 columns (one per measure plus the 2 key 
# columns.)
# SO... 
#    I expect the results of this step to be a data frame with 180 rows and 68 columns.

# First, lets melt the data around the id columns...
meltedDataOfInterest <- melt(dataOfInterest, id=c("subjectId", "activity"));

# Lets validate the numbers before we recast the results...
# > dim(dataOfInterest)[1]          # What is the original row count in dataOfInterest?
# [1] 10299                         # A little over 10,000 as we previously stated, good.
# > dim(dataOfInterest)[1] * 66     # We melted 66 measures for each row, so lets predict the total
# [1] 679734                        # Ok, we should see this many rows in meltedDataOfInterest
# 
# > dim(meltedDataOfInterest)[1]    # Test our results against expectations...
# [1] 679734                        # VALID!

# Now, lets recast the melted data.  We need to recast around subjectId and activity, and
# cast each variable as a column, using the mean function to aggregate the data in that group.
measuresMeanPerSubjectActivity <- dcast(meltedDataOfInterest, subjectId + activity ~ variable, mean);

# Lets validate the numbers again.  We previously said that the results should be 180 by 68.
# > dim(measuresMeanPerSubjectActivity)
# [1] 180  68                       # VALID!

# FINAL RESULT: measuresMeanPerSubjectActivity
#
# measuresMeanPerSubjectActivity has as column 1 and 2, the keys where:
#   column 1, "subjectId", is the subject id from the experiment.
#   column 2, "activity", is the activity label from the experiment.
# These two columns form a unique key (only one row for each unique composite pair.)
#
# measuresMeanPerSubjectActivity has as columns 3 through 68 a series of columns
# whose name is an exact match to a feature listed in the experiment's features.txt
# meta-data.  (Note only the mean() and std() features were of interest to this analysis.)
# NOTE, even though the column names of measuresMeanPerSubjectActivity (col 3-68)
# match the feature name, the value of any given row is the MEAN of the recorded data
# for that feature for the subject and activity indicated by column 1 and 2.
# Traditionally, I would rename the column to reflect that the values are a mean of
# another value, but in this case, leaving the column names as exact matches to the 
# feature name will make additional coding against this data set easier.
#

message("Analysis complete.");
message("Mean of all '*-mean()*' and '*-std()*' features, accross test and train data, ");
message("has been computed for each subject and activity pair.");
message("The results are in the variable measuresMeanPerSubjectActivity");

# Thank you and good night.