# Project ReadMe, for Getting and Cleaning Data

## Overview

This project involved a minor analysis of a set of data that was recorded via smart phone accelerometers and other sensors.  The original data comes from another project by the authors of this coursera course.  That original data had been split into two parts, one for testing and one for training, and had also been broken down into separate files for the indexes versus the actual measurement values.

The objective of this analysis was to reform the data and to determine the average value of the measures that were themselves either a mean or standard deviation measurement.  The average was to be calculated for each activity performed by each subject.  That is, one average per subject and activity pair.

## Process

The analysis is broken down into 5 steps, as defined in the instruction of the assignment:

1. Merge the training and the test sets to create one data set.
1. Extract only the measurements on the mean and standard deviation for each measurement. 
1. Use descriptive activity names to name the activities in the data set.
1. Appropriately label the data set with descriptive variable names. 
1. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

Prior to these steps though, the data had to be obtained from the original source:
```
https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
```


### Step 0 - Obtaining Data

The analysis script (see run_analysis.R in repo) begins by loading the data needed for performing the analysis.  After examination of the README in the original data and understanding of what was being asked in the assignment, it was clear that there were 6 primary files of interest:

* subject_train - UCI HAR Dataset/train/subject_train.txt
* y_train - UCI HAR Dataset/train/y_train.txt
* X_train - UCI HAR Dataset/train/X_train.txt
* subject_test - UCI HAR Dataset/test/subject_test.txt
* y_test - UCI HAR Dataset/test/y_test.txt
* X_test - UCI HAR Dataset/test/X_test.txt

Each of these files is a fixed width table without headers.  The actual measurements are in the 'X' files.  The 'y' file contained the activity id and the 'subject' contained the subject id, both of which we row for row aligned to the 'X' data.

The meaningful label for the activities was defined by the file:

* activity_labels - UCI HAR Dataset/activity_labels.txt

And the meaningful labels for the data in the X files (what should be the column labels) was defined by the file:

* features - UCI HAR Dataset/features.txt

To simplify processing, a utility method (loadData) is used to read these files, load the data into a data frame, and store that data frame in an appropriately named variable (as indicated above).


### Step 1 - Merge Data

Since the 6 data tables were row aligned and split into two groups, I first combined the two groups being sure to do so in the same order for each of the 3 file types.  This ensured that row alignments remained correct.  This produced three new data tables as follows:

* subject = subject_test + subject_train (row bind, such that train rows followed test rows.)
* y = y_test + y_train (row bind, such that train rows followed test rows.)
* X = X_test + X_train (row bind, such that train rows followed test rows.)

All 3 data tables had matching row counts before and after the merge as one would expect for row level alignment.

Next, I merged the identifiers, subject and y, to the data X.  This was a column bind operation and the result was what I labeled the 'master' data table.

For clarity sake I renamed the columns to accurately reflect their content.  I used the features data to apply meaningful labels to that data as well, which is especially handy in the upcoming steps.


### Step 2 - Extract Data of Interest

The instruction at this point indicate that we need to extract only the features that are a mean and a standard deviation.  After review of the original data's readme and the features readme, it was clear that the feature names followed an explicit pattern, and that features that are a mean have -mean() in the name and features that are a standard deviation have -std() in the name.

There are some features that do not follow the pattern, such as the angles, but these are not mean or standard deviations.  Also, there are some features that have the word mean but are part of a different calculation.  These too are ignored as not fitting the requirement given.

Since the feature names follow a specific pattern, I used a regular expression to match against that pattern for mean() and std() based features.  This resulted in 33 features each which matched the number expected based on reading the features readme within the original data.  The names of the features of interest were stored in two vectors, meanLabels and stdLabels.

Finally, with the features of interest known and the master data table having columns named by the feature, it was trivial to subset the master data table into only the features of interest (plus the subject and activity ids that the features were associated to.)  This resulting trimmed down view of the master data is stored in the variable dataOfInterest.


### Step 3 - Name the Activity

This step asked that the activity id's be replaced with more meaningful labels.  The mapping of id to label was already loaded in step 0, and was present in the activity_labels variable.  Using the mutate command, I was able to create a new column on the existing dataOfInterest table, called activity, who's value was based on a lookup of the activity label for the id of that row.  I then deleted the original activityId row, as it was logically duplicative of the newly added label.


### Step 4 - Name's for Everything!

The instructions ask for appropriate names at this point, but as you may have noticed, I did that at the very beginning.  It was far easier to work with well named columns from the start than to defer it to this late in the processing.


### Step 5 - Compute Means, Create Tidy Data

While this ended up being two lines of R code, it took a bit of time to determine the correct commands.  Many of the commands I considered expected named column labels explicitly listed in their arguments.  However, I had a vector of column names in meanLabels and stdLabels.

I ended up finding that by melting the data, the column labels became irrelevant.  All that was required for melt to operate was a list of the id columns, which were well known: subjectId and activity.  Melt then turns each feature measurement column into a row variable and value.

Finally, I recast the melted data, applying the mean function in the process, with the subjectId and activity as the factors that determine the groups.  dcast naturally creates a column for each distinct variable name.  Thus I arrived at the final result, a data frame with a row per subject and activity pair and a column for each of the 66 measures with the mean applied to the original data values that compose that group.

I was able to validate the size of both dimension as matching predicted sizes, and a manual verification of the resulting mean values matched against calculations against original data, in a sampling of cases.

The results of the analysis are available in the variable named: measuresMeanPerSubjectActivity



## Parting Thoughts

The variables mentioned above are maintained after execution of the run_analysis.R script.  Thus, intermediate data can be validated.  The final results are in the variable measuresMeanPerSubjectActivity.  See the code book for a listing of specific variables.

Last but not least, the measuresMeanPerSubjectActivity data was written to a file for upload to Coursera and is present in the repository as well.  The file was written with headers, as a table with no row numbers.  It can be read using this command (assuming file is in local working directory):

```
read.table("measuresMeanPerSubjectActivity.txt", header = TRUE)
```

