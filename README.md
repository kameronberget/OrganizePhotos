###THIS SCRIPT HELPS YOU ORGANIZE YOUR PICTURE LIBRARIES. IN DOING SO IT EITHER COPIES OR MOVES PHOTOS BASED ON YOUR PARAMETERS. AS WITH AY AUTOMATION SCRIPT, IT IS IMPORTANT TO BACKUP YOUR DATA FIRST BEFORE RUNNING ANY COMMANDS BELOW.

#Summary
We all have photos stored all over the place. This script is inteded to find those photos and organize them to your liking. The script uses the `Date Picture Taken` property of your images to sort them according to the date they were actually taken. If it cannot find this property it will use the `Created` date instead.

# Organize Photos PowerShell Script
PowerShell Script to automatically organize all of your photos. Allows for several options to organize.

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
    1. .\Group-Photos.ps1 -Scope SortTargetNewDestination -target C:\Users\jdoe\Pictures\ -destination C:\Users\jdoe\Pictures\MyNewTree -Recurse

