If the data folder does not exist, it is created and the tempsamsung.zip file is downloaded to the folder. 
The file names are collected from the zip file for later use.

The script modularizes each task to it own function. The variables in the function that are used between multiple functions are cached to allow global access.

The group_by function from the dplyr package groups each activity for each subject. The summarise_each function is then used to summarize each variable using the mean function. This result is returned to out.

out is then written to a .txt file using the write.table function.