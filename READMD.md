The script first checks to see if the file has not been downloaded to the .data directory. If it has not been downloaded it 
downloads the file and unzips it to the .data folder.

It next loads the activity labels.

Only labels that are for standard deviation and mean are used.

Training and test sets are merged using cbind.

dplyr grammar is used for filtering and manipulating the data.

melt and dcast are used to produce the final results.
