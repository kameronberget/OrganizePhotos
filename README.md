###THIS SCRIPT HELPS YOU ORGANIZE YOUR PICTURE LIBRARIES. IN DOING SO IT EITHER COPIES OR MOVES PHOTOS BASED ON YOUR PARAMETERS. AS WITH ANY AUTOMATION SCRIPT, IT IS IMPORTANT TO BACKUP YOUR DATA FIRST BEFORE RUNNING ANY COMMANDS BELOW.

#Summary
We all have photos stored all over the place. This script is inteded to find those photos and organize them to your liking. The script uses the `Date Picture Taken` property of your images to sort them according to the date they were actually taken. If it cannot find this property it will use the `Created` date instead.

#Recommendation
I recommend that you follow the tutorial at the bottom of this README with the sample photos to get a feel for how the script works.

## Organize-Photos
Organize-Photos is the single function that is used to organize all of your photos. 

###Syntax
```
Organize-Photos 

    -Recurse <switch>
  
    -Scope ['SortCurrentDirectory', 'SortTargetDirectory', 'SortTargetNewDestination']
    
    -target <path>
    
    -Destination <path>
    
    -Operation ['Copy,'Move']
    
    -OrganizeBy ['Month-Year', 'YearThenMonth', 'YearThenMonthThenDay']
    
    -AddDatePrefix <switch>
    
    -Filter "StartDate-EndDate"
    
    -LabelEvents <path>
````

| Parameter | Required | Type | Description |
|-----------|:---:|:---:|-------------|
| Recurse   | False    | Switch | This switch is used to add the recurse paramter when searching for photos. This ensures that all subdirectories and files are discovered. If you only want to search the root directory, do not use this switch.|
|Scope|True|String [TabComplete]|The scope parameter is used to define where to look for photos and where to place the new structure `-SortCurrentDirectory` (Default): This will search the directory in which the script was run and find all photos. It will then create a new structure based on your **OrganizeBy** parameter at the root of the directory. `-SortTargetDirectory`: This will search the target path you specifiy for photos. It will then create a new structure based on your **OrganizeBy** parameter at the root of the target directory you specified. `-SortTargetNewDestination`: This will search the target path you specifiy for photos. It will then create a new structure based on your **OrganizeBy** parameter at the destination path you specify.|
| Target | False | String | The target paramter accepts a string <path> to the directory you wish to organize. This parameter is only used when the `-Scope` parameter is set to either **SortTargetDirectory** or **SortTargetNewDestination**.
| Destination | False | String | The destination paramter accepts a string <path> to the directory you wish to store your new organized structure. This parameter is only used when the `-Scope` parameter is set to **SortTargetNewDestination**. Otherwise it is ignored.
| Operation | True | String [TabComplete] | This parameter defines whether we `copy` photos into the new structure or `move` them into the new structure. |
| OrganizeBy | True | String [TabComplete] | This parameters defines how you want the final structure to be organized. **Month-Year** provides a single level output with folders named Month-Year, e.g. January-2016\\*images*. **YearThenMonth** provides a two level structure of Year\Month, e.g 2016\January\\*images*. **YearThenMonthThenDay** provides a three level structure of Year\Month\Day, e.g 2016\January\1\\*images* 
| AddDatePrefix | False | Switch | This will add a date prefix to the start of the image. This helps when sorting images in explorer. e.g. 01012016_IMG_01.jpg 
| Filter | False | String | The filter switch accepts and string of StartDate-EndDate. It is important to sepearate the two date with a '-'. This will organize photos into a new structure but will only grab images from the specified date range.
| LabelEvents | False | String | This parameter will add an additiaonl level of sorting my creating folders for defined events. This paramter accepts a path to a CSV file that contains the structure fround in the **CSV Format** below. While processing images, the script will look at your labels to see if the picture matches. If it does, it creates a new folder for that Event.

- *Using the `LabelEvents` parameter can dramatically increase processing time for the script. When using this parameter it will help to work on small subsets of images*

#CSV Format (LabelEvents)
Prior to running the script you can create a CSV file that contains the following fields.

| Label | Start | End |
| ---   | ----- | ----|
| News Year's Eve | 1/1/2016 | 1/2/2016 | 

e.g. C:\users\jdoe\desktop\labels.csv

When using the `-LabelEvents` you pass it a path like this: `-LabelEvents c:\users\jdoe\desktop\labels.csv`

Your resulting file structure would be:

- `OrganizeBy Month-Year`: January-2016\New Year's Eve\\*images*
- `OrganizeBy YearThenMonth`: 2016\January\New Year's Eve\\*images*
- `OrganizeBy YearThenMonthThenDay`: 2016\January\01\New Year's Eve\\*images*

#Using the script
Copy the script Group-Pictures.ps1 into any location.

##Run in place
1. You can accept the defaults and simply right click the script and choose **Run with PowerShell**. This will search teh current directory BUT NOT subdirectories and create a new structure for your photos of `YearThenMonth`.

##Run with custom parameters
1. Open PowerShell.
  1. Navigate to the directory where the script resides.
  2. Run the command with your custom values:
    1. `.\Group-Photos.ps1 -Scope SortTargetNewDestination -target C:\Users\jdoe\Pictures\ -destination C:\Users\jdoe\Pictures\MyNewTree -Recurse`


#Tutorials

##Getting Started
To get started: 
1. First download this repo as a ZIP (upper right) to your computer and extract the contents. 
2. Next, copy the tutorial folder out of the repo into a new location on your computer.
3. Follow the tutorials below to get a feel for each operation.

##Organize the folders using defaults.
####By using defaults, we only search the current directory in which we ran the script. Additionally, we can simply run the script without passing any parameters. Give it a shot:
1. `Right-Click > Run with PowerShell` the Organize-Photos.ps1 file. (You might get prompted to allow the script to run)
2. Wait for the operation to complete.
3. You should have a new folder structure of YearThenMonth and a COPY of all your test photos. 
4. Nice work! 
5. Delete the folder(s) it created.

##Organize the folders by adding a single overriding parameter
####Next we will move the photos instead of copy:
1. Open a PowerShell window.
2. Change into the tutorial folder (e.g. cd C:\users\jdoe\downloads\organizephotos\tutorials
3. Run the follwing: `.\Organize-Photos.ps1 -Operation Move`
4. This will do the same thing as before but it will move the images into the folders instead of copy.

##Provide a target and destination
####Next, we will provide a target and destination for which to copy:
1. Open a PowerShell window.
2. Change into the tutorial folder (e.g. cd C:\users\jdoe\downloads\organizephotos\tutorials
3. Run the following: `.\Organize-Photos.ps1 -Scope SortTargetNewDestination -target "C:\OrganizePhotos\tutorial\2015" -destination "C:\OrganizePhotos\tutorial\My2015Photos" -Recurse`

**Note:**
- We added a parameter of `-Scope SortTargetNewDestination` because we wanted to specify a custom taget and destination.
- We copied our 2015 folder we created in tutorial 1 and oved them into a new folder called "My2015Photos"
- The script prompted use to create the new folder as it did not exist.
- We added the `-Recurse` param to ensure the script traversed the folder structure beneath our target. We needed this because tutorial #1 organized our photos into folders by month. Without it we would receive a `No images found` message.
- Our files were COPIED and not MOVED as the default operation is COPY. We can override that by using `-Operation Move`

##Filter out images
####Next, we will use the Filter param to provide a date range for our copy operation.
1. Open a PowerShell window.
2. Change into the tutorial folder (e.g. cd C:\users\jdoe\downloads\organizephotos\tutorials
3. Run the following: `.\Organize-Photos.ps1 -Scope SortTargetNewDestination -target "C:\OrganizePhotos\tutorial\2015" -destination "C:\OrganizePhotos\tutorial\MyFiltered2015Photos" -Filter "4/1/2015-9/1/2015" -Recurse`

**Note:**
- We added a parameter of `-Filter "4/1/2015-9/1/2015"` because we wanted to filter what was moved.
- We specified a destination of "MyFiltered2015Photos" to create a new structure.
- The script prompted use to create the new folder as it did not exist.
- We received a message of `Portrait_3.jpg is outside the filter values. Skipping`
- Our files were COPIED and not MOVED as the default operation is COPY. We can override that by using `-Operation Move`
- Our destination ended up only having 'April' and 'August' folders due to our filter.

##Provide Event Labels
####Next, we will provide a CSV that contains labels for our images.

1. Open the sampleLabel.csv file in notepad that is inside the tutorial folder.
2. Our CSV should look like this:

Label, Start, End

Summar Hike, 8/27/2015, 8/28/2015

*You can save the file as CSV or TXT. It doesn't matter which you choose.*

3. Run the following: `.\Organize-Photos.ps1 -Scope SortTargetNewDestination -target "C:\OrganizePhotos\tutorial\2015" -destination "C:\OrganizePhotos\tutorial\MyTrips" -LabelEvents C:\OrganizePhotos\tutorial\sampleLabel.csv -Recurse`

**Note:**
- We added a parameter of `-LabelEvents C:\OrganizePhotos\tutorial\sampleLabel.csv` because we wanted to put images that matched a date range into a 'Labeled' folder. 
- We specified a destination of "MyTrips" to create a new structure.
- The script prompted use to create the new folder as it did not exist.
- Our files were COPIED and not MOVED as the default operation is COPY. We can override that by using `-Operation Move`
- Our 'August' folder had an additional level of 'Summer Hike' that contained one image. This is because the image matched our date filter inside our CSV. This is a greate way to further orgnanize events.

#Logging
Everytime you run the script a log is created inside the folder in which it was ran.





