# Code Book

The run_analysis.R script will produce 19 variables within the R session.  These variables are listed below along with information helpful in their interpritation.  The variables are listed in order of introduction by the script.  **The primary result of the run_analysis.R script, measuresMeanPerSubjectActivity, is the last entry in this code book.**

## rawDataSourceUrl
This is the url where the original data is loaded from, and is hard coded to the value:
```
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
```

## rawDataLocalFile
This is the name of the local file that the raw data, loaded from rawDataSourceUrl, will be written/stored to.  The value is unimportant, other than providing the script with a known location to see if the file was previously downloaded.  The current value is:
```
getdata-projectfiles-UCI HAR Dataset.zip
```

## subject_train
This is a raw data table from within the zip (UCI HAR Dataset/train/subject_train.txt).  This table is unmodified from that of the original data.  It contains a single column of numeric class that is the subject id of the subject which generated the measures on the same row within the X_train data.  There are 30 subjects and the values of this column range from 1 to 30.

This data table is structurally identical to the subject_test data table.  This data tables matches rows in the train measures in X_train.

## y_train
This is a raw data table from within the zip (UCI HAR Dataset/train/y_train.txt).  This table is unmodified from that of the original data.  It contains a single column of numeric class that is the activity id of the subject which generated the measures on the same row within the X_train data.  There are 6 activities and the values of this column range from 1 to 6.

This data table is structurally identical to the y_test data table.  This data tables matches rows in the train measures in X_train.

## X_train
This is a raw data table from within the zip (UCI HAR Dataset/train/X_train.txt).  This table is unmodified from that of the original data.  It contains 561 columns of numeric classes that are the measures computed in the original research.  Meaning of columns is defined by the features vector which has an equal length to the number of columns of this table.

This data table is structurally identical to the X_test data table.

## subject_test
This is a raw data table from within the zip (UCI HAR Dataset/test/subject_test.txt).  This table is unmodified from that of the original data.  It contains a single column of numeric class that is the subject id of the subject which generated the measures on the same row within the X_test data.  There are 30 subjects and the values of this column range from 1 to 30.

This data table is structurally identical to the subject_train data table.  This data tables matches rows in the train measures in X_test.

## y_test
This is a raw data table from within the zip (UCI HAR Dataset/test/y_test.txt).  This table is unmodified from that of the original data.  It contains a single column of numeric class that is the activity id of the subject which generated the measures on the same row within the X_test data.  There are 6 activities and the values of this column range from 1 to 6.

This data table is structurally identical to the y_train data table.  This data tables matches rows in the train measures in X_test.

## X_test
This is a raw data table from within the zip (UCI HAR Dataset/test/X_test.txt).  This table is unmodified from that of the original data.  It contains 561 columns of numeric classes that are the measures computed in the original research.  Meaning of columns is defined by the features vector which has an equal length to the number of columns of this table.

This data table is structurally identical to the X_train data table.


## features
This is a table of feature number and names based on the original data file from within the zip (UCI HAR Dataset/features.txt).  Column 1 is the numerical feature number which matches to the column number of the X data.  Column 2 is a character class that names the feature.  Features are named following a pattern.  See the original data's features readme for details on the naming pattern.

While this table remains unchanged from the raw data, it will be used to label the measures columns in the X data.  Thus, this table is handy for working with columns without hard coding column names.

There are 561 rows, which matches the column count on the X data.


## activity_labels
This is a table of activity id and names based on the original data file from within the zio (UCI HAR Dataset/activity_labels.txt).  Column 1 is a numeric class and column 2 is a factor which names the activity.  Column 1 is the activity id.  There are 6 activities defined in this file and they match the values found in the X data.  The values range from 1 to 6.

While this table remains unchanged, its data is used to apply meaningful values to rows in certain data.

See original research code book for activity meanings.


## X
This is a compoiste data table built from the rows of X_test and X_train.  It contains 561 columns of numeric classes that are the measures computed in the original research.  Meaning of columns is defined by the features vector which has an equal length to the number of columns of this table.

This is not part of the original data.  It is the result of a row bind of the test and train data.


## y
This is a compoiste data table built from the rows of y_test and y_train.  It contains a single column of numeric class that is the activity id of the subject which generated the measures on the same row within the X data.  There are 6 activities and the values of this column range from 1 to 6.

This is not part of the original data.  It is the result of a row bind of the test and train data.


## subject
This is a compoiste data table built from the rows of subject_test and subject_train.  It contains a single column of numeric class that is the subject id of the subject which generated the measures on the same row within the X data.  There are 30 subjects and the values of this column range from 1 to 30.

This is not part of the original data.  It is the result of a row bind of the test and train data.


## master
This is a composite table resulting from the column binding of the subject and y indexing information to the X data.  The first column is the subject id (from subject), the second column is the activity id (from y), and the remainding 561 are measures (from X).

This is not part of the original data, but is the most complete union of the original data available.  The columns are named subjectId, activityId, and the remainder are named by the feature for whic hthey measure.


## meanLabels
This is a vector variable that contains a list of feature measure names that contain a mean().  This is based off of a regular expression mapping against the original data's list of features.  These match the column names on X and master, as well as tables derrived from those.


## stdLabels
This is a vector variable that contains a list of feature measure names that contain a std().  This is based off of a regular expression mapping against the original data's list of features.  These match the column names on X and master, as well as tables derrived from those.


## dataOfInterest
This is a subset of the master table such that only the subjectId, activityId, and columns listed in meanLabels and stdLabels are present.  This table only contains data relevant to the processing peformed by this analysis.

The columns that are present include the subjectId (inherited), and a newly added activity column.  This latter column is a factor column based off the mapping of activityId to a meaningful label.  The remaining columns are feature named measures (numeric).


## meltedDataOfInterest

This is a transitionary table that contains the same data as dataOfInterest, but the data has been melted such that the subjectId and activity remain, while the feature measure columns have been reduced to the introduced variable and value columns.  Each feature column on dataOfInterest is now a factor in the variable column of meltedDataOfInterest.  The value is placed into the value clumn.


## measuresMeanPerSubjectActivity

This is the final result table of the analysis.  It contains 2 indexing columns, subjectId (numeric) and activity (factor), as well as 66 feature measure columns.  33 feature measure columns are based on original mean() data and the remaining 33 feature measure columns are based on original std() data.  The values on a per row basis are the mean of all measures for that subjectId and activity for that particular measure.  There are 180 rows, which is 30 subjects times 6 activities.

The measure columns are named by the original feature label.  However the values are a mean of that feature.

The units of the feature columns remain unchanged from the original data, as they are an average of that data.  See features_info.txt from the original data for an explanation of features and their units.

