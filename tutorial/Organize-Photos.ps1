[CmdletBinding()]
    param (

	    [Parameter(Position=1, HelpMessage='Will recurse through the directory structure starting with your target. ')]
        [switch]$Recurse,

        [Parameter(Position=2, HelpMessage='Defines the scope in which the script works and where is saves files.')]
	    [ValidateSet('SortCurrentDirectory', 'SortTargetDirectory', 'SortTargetNewDestination')]
        $Scope = "SortCurrentDirectory",

        [Parameter(Position=3, HelpMessage='Define the target that you want to discover.')]
        [string]$target,

        [Parameter(Position=4, HelpMessage='Define the destination for the new structure.')]
        [string]$destination,

        [Parameter(Position=5, HelpMessage='Define whether you want to copy or move the images into their new folders.')]
	    [ValidateSet('Copy','Move')]
        $Operation = "Copy",

		[Parameter(Position=6, HelpMessage='How do you want your new folder structure to appear? Month-Year (Folder) YearThenMonth (Nested as Year/Month, etc).')]
        [ValidateSet('Month-Year', 'YearThenMonth', 'YearThenMonthThenDay')]
        $OrganizeBy = "YearThenMonth",

        [Parameter(Position=7, HelpMessage='Use this switch to prepend the Date to the filename after copying or moving')]
        [switch]$AddDatePrefix,

        [Parameter(Position=8, HelpMessage='What should the operation do on conflict of a file already existing?')]
        [ValidateSet('Skip','Rename','Prompt')]
        $Conflict,

        [Parameter(Position=9, HelpMessage='Filter the scope by start and end dates in this format "8/1/2015-8/1/2016" ')]
        [string]$Filter,

        [Parameter(Position=10, HelpMessage='Use a CSV file to add named folder ')]
        [string]$LabelEvents

    )

    #Load Drawing DLL
    $load = [reflection.assembly]::LoadFile("C:\Windows\Microsoft.NET\Framework\v4.0.30319\System.Drawing.dll") 

    # Stop if missing params

    if ($scope -eq "SortTargetDirectory" -and [string]::IsNullOrEmpty($target)) {
        Write-Error "Missing target param"
        break;
    }

    if ($scope -eq "SortTargetNewDestination" -and [string]::IsNullOrEmpty($target)) {
        Write-Error "Missing target param"
        break;
    }

    if ($scope -eq "SortTargetNewDestination" -and [string]::IsNullOrEmpty($destination)) {
        Write-Error "Missing destination param"
        break;
    }

    if (!([string]::IsNullOrEmpty($LabelEvents))) {
        $labelData = Import-Csv $LabelEvents
        if (!(Test-Path -Path $LabelEvents)) {
            Write-Host "The File path you specified for your labels does not exist."
            break;
        }
    }

    if (!([string]::IsNullOrEmpty($destination))) {
        if (!(Test-Path $destination)) {
            $r = Read-Host "Your destination path does not exist. Do you wish to create? Y/N"
            if ($r.ToUpper() -eq "Y") {
                New-Item $destination -ItemType Directory
            } else {
                throw("Destination does not exists, Exiting now")
            }
        }
    }

function Get-DatePictureTaken($picture) {
        
    # Gets image data 
    $ImgData = New-Object System.Drawing.Bitmap($picture.FullName)

    
    try {
    
        # Try to get Date in bytes 
        [byte[]]$ImgBytes = $ImgData.GetPropertyItem(36867).Value
        [string]$dateString = [System.Text.Encoding]::ASCII.GetString($ImgBytes) 
    
        # Formats the date to the desired format 
        [string]$dateTaken = [datetime]::ParseExact($dateString,"yyyy:MM:dd HH:mm:ss`0",$Null).ToString('MM-dd-yyyy')
    
    } catch {
        
        # Date picture taken not found
        $dateTaken = $picture.CreationTime

    }
    
    # Date Object
    $dDateTaken = Get-Date $dateTaken 


    #Dispose
    $ImgData.Dispose()


    return $dDateTaken
}

function Copy-Picture {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=1, HelpMessage='Pass the image file.')]
        $picture,
    
        [Parameter(Mandatory=$true, Position=2, HelpMessage='Define the destination for the picture.')]
        [string]$destination
    )

    Copy-Item -Path $picture.FullName -Destination $destination
}

function Move-Picture {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=1, HelpMessage='Pass the image file.')]
        $picture,
    
        [Parameter(Mandatory=$true, Position=2, HelpMessage='Define the destination for the picture.')]
        [string]$destination
    )

    Move-Item -Path $picture.FullName -Destination $destination
}

function Get-Month($m) {

    switch($m) {
        
        1 {
            return "January"
            break;
        }

        2 {
            return "February"
            break;
        }

        3 {
            return "March"
            break;
        }

        4 {
            return "April"
            break;
        }

        5 {
            return "May"
            break;
        }

        6 {
            return "June"
            break;
        }

        7 {
            return "July"
            break;
        }

        8 {
            return "August"
            break;
        }

        9 {
            return "September"
            break;
        }

        10 {
            return "October"
            break;
        }

        11 {
            return "November"
            break;
        }

        12 {
            return "December"
            break;
        }
    }

}

function Group-Pictures($Recurse, $Scope, $target, $destination, $Operation, $OrganizeBy, $AddDatePrefix, $Filter, $LabelEvents) {
    
    switch ($Scope) {
        
        "SortCurrentDirectory" {
            $pictures = if ($Recurse) { Get-ChildItem -Path * -Recurse -Include *.jpeg, *.png, *.gif, *.jpg, *.bmp, *.png } else { Get-ChildItem -Path * -Include *.jpeg, *.png, *.gif, *.jpg, *.bmp, *.png }
            break;
        }

        "SortTargetDirectory" {
            $pictures = if ($Recurse) { Get-ChildItem -Path $target -Recurse -Include *.jpeg, *.png, *.gif, *.jpg, *.bmp, *.png} else { Get-ChildItem -Path $target -Include *.jpeg, *.png, *.gif, *.jpg, *.bmp, *.png }
            break;
        }

        "SortTargetNewDestination" {
            $pictures = if ($Recurse) { Get-ChildItem -Path $target -Recurse -Include *.jpeg, *.png, *.gif, *.jpg, *.bmp, *.png } else { Get-ChildItem -Path $target -Include *.jpeg, *.png, *.gif, *.jpg, *.bmp, *.png }
            break;
        }
    }


    if ($pictures.count -gt 0) {
        foreach ($p in $pictures) {
        
            [datetime]$dateTaken = Get-DatePictureTaken -picture $p

            if (!([string]::IsNullOrEmpty($Filter))) {
                if ($dateTaken -lt (Get-Date $filter.Split("-")[0]) -or $dateTaken -gt (Get-Date $filter.Split("-")[1])) {
                    Write-Host "$($p.Name) is outside the filter values. Skipping" -ForegroundColor Yellow
                    continue;
                }
            }

            $month = Get-Month -m $dateTaken.Month
            switch($OrganizeBy) {

                "Month-Year" {
                    $newFolder = $month + "-" + $dateTaken.Year
                    break;
                }
            
                "YearThenMonth" {
                    $newFolder = $dateTaken.Year.toString() + "\" + $month
                    break;
                }
            
                "YearThenMonthThenDay" {
                    $newFolder = $dateTaken.Year.toString() + "\" + $month + "\" + $dateTaken.Day.toString()
                    break;
                }

            }

            switch ($Scope) {
        
                "SortCurrentDirectory" {
                    $newPath = $newFolder
                    if (!(Test-Path $newPath)) { New-Item -Path $newPath -ItemType Directory }
                    break;
                }

                "SortTargetDirectory" {
                    $newPath = $target.TrimEnd("\") + "\" + $newFolder
                    if (!(Test-Path $newPath)) { New-Item -Path $newPath -ItemType Directory }
                    break;
                }

                "SortTargetNewDestination" {
                    $newPath = $destination.TrimEnd("\") + "\" + $newFolder
                    if (!(Test-Path $newPath)) { New-Item -Path $newPath -ItemType Directory }
                    break;
                }
            }

            # Check for Label
            if (!([string]::IsNullOrEmpty($LabelEvents))) {
                $label = $labelData | ?{ $dateTaken -ge (Get-Date $_.Start) -and $dateTaken -le (Get-Date $_.End) } | select -First 1
                if (!([string]::IsNullOrEmpty($label))) {
                    $newPath = ($newPath.TrimEnd("\") + "\" + $label[0].Label)
                    if (!(Test-Path $newPath)) { New-Item -Path $newPath -ItemType Directory }
                }
            }

            switch ($Operation) {


                "Copy" {
                    try {
                        Write-Host "Copying $($p.Name) to $newPath..." -NoNewline 
                        Copy-Picture -picture $p -destination $newPath

                        if ($AddDatePrefix) {
                            Rename-Item -Path ($newPath.TrimEnd("\") + "\" + $p.Name) -NewName ($(Get-Date $dateTaken -Format MMddyyyy) + "-" + $p.Name)
                        }

                        Write-Host "Done" -ForegroundColor Green
                        break;

                    } catch {
                    
                    }
                }

                "Move" {
                
                    try {
                        Write-Host "Moving $($p.Name) to $newPath..." -NoNewline 
                        Move-Picture -picture $p -destination $newPath

                        if ($AddDatePrefix) {
                                Rename-Item -Path ($newPath.TrimEnd("\") + "\" + $p.Name) -NewName ($(Get-Date $dateTaken -Format MMddyyyy) + "-" + $p.Name)
                            }
                        Write-Host "Done" -ForegroundColor Green
                        break;
                    } catch {

                    }
                }

            }


        }
    } ## If picture count is gt 0
    else {
        Write-Host "No images found" -ForegroundColor Red
        break;
    }

}


#RUN

$logDate = Get-Date -Format "MMddyyyyHHmm"
Start-Transcript -Path "Log_$logDate.txt"
Group-Pictures -Recurse $Recurse -Scope $Scope -target $target -destination $destination -Operation $Operation -OrganizeBy $OrganizeBy -AddDatePrefix $AddDatePrefix -Filter $Filter -LabelEvents $LabelEvents
Stop-Transcript