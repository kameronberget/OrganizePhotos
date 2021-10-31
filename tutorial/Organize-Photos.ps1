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
        [ValidateSet('YEAR','YEAR-MONTH','MONTH-YEAR','YEAR\MONTHNAME','YEAR\MONTHNUMBER-MONTHNAME','YEAR\MONTHNAME\DAY','YEAR\MONTHNUMBER-MONTHNAME\DAY')]
        $OrganizeBy = "YEAR\MONTHNUMBER-MONTHNAME",

        [Parameter(Position=7, HelpMessage='Use this switch to prepend the Date to the filename after copying or moving')]
        [switch]$AddDatePrefix,

        [Parameter(Position=9, HelpMessage='Filter the scope by start and end dates in this format "8/1/2015-8/1/2016" ')]
        [string]$Filter,

        [Parameter(Position=10, HelpMessage='Use a CSV file to add named folder ')]
        [string]$LabelEvents

    )

    #Logging 
    $logDate = Get-Date -Format "MMddyyyyHHmm"
    $fLogDate = Get-Date



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
        $dateTaken = $picture.LastWriteTime

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
        [string]$destination,

        [Parameter(Mandatory=$false, Position=2, HelpMessage='Add a date prefix to the image.')]
        [switch]$DatePrefix
    )
    $random = Get-Random -Maximum 100
    $date = ($(Get-Date $dateTaken -Format MMddyyyy))
    if (Test-Path $picture.FullName) {
        if ($DatePrefix) {
            Copy-Item -Path $picture.FullName -Destination ($destination.TrimEnd("\") + "\" + "$date" + "_" + $picture.BaseName + "_$random" + $picture.Extension)
        } else {
            Copy-Item -Path $picture.FullName -Destination ($destination.TrimEnd("\") + "\" + $picture.BaseName + "_$random" + $picture.Extension)
        }
    } else {
        Copy-Item -Path $picture.FullName -Destination $destination
    }
}

function Move-Picture {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true, Position=1, HelpMessage='Pass the image file.')]
        $picture,
    
        [Parameter(Mandatory=$true, Position=2, HelpMessage='Define the destination for the picture.')]
        [string]$destination,

        [Parameter(Mandatory=$false, Position=2, HelpMessage='Add a date prefix to the image.')]
        [switch]$DatePrefix
    )
    
    $random = Get-Random -Maximum 100
    $date = ($(Get-Date $dateTaken -Format MMddyyyy))

    if (Test-Path $picture.FullName) {
        if ($DatePrefix) {
            Move-Item -Path $picture.FullName -Destination ($destination.TrimEnd("\") + "\" + "$date" + "_" + $picture.BaseName + "_$random" + $picture.Extension)
        } else {
            Move-Item -Path $picture.FullName -Destination ($destination.TrimEnd("\") + "\" + $picture.BaseName + "_$random" + $picture.Extension)
        }
    } else {
         Move-Item -Path $picture.FullName -Destination $destination
    }
   
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
	
	$scriptStart = Get-Date
	
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


    $html = '<!doctype html>
                  <head>
                    <meta charset="utf-8"/>
                    <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1"/>
                    <title></title>
                    <meta name="description" content="">
                    <meta name="viewport" content="width=device-width">
                    
                    <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css" integrity="sha384-BVYiiSIFeK1dGmJRAkycuHAHRg32OmUcww7on3RYdg4Va+PmSTsz/K68vbdEjh4u" crossorigin="anonymous">
                </head>'

    

	$actions = @()
	$dataMoved = 0

    if ($pictures.count -gt 0) {
        foreach ($p in $pictures) {
			
			#Metrics
			$dataMoved += $p.Length
			
            [datetime]$dateTaken = Get-DatePictureTaken -picture $p

			
            if (!([string]::IsNullOrEmpty($Filter))) {
                if ($dateTaken -lt (Get-Date $filter.Split("-")[0]) -or $dateTaken -gt (Get-Date $filter.Split("-")[1])) {
                    Write-Host "$($p.Name) is outside the filter values. Skipping" -ForegroundColor Yellow
                    continue;
                }
            }

            $month = Get-Month -m $dateTaken.Month
            switch($OrganizeBy) {

                "YEAR" {
                    $newFolder = $dateTaken.Year.toString()
                    break;
                }
                "MONTH-YEAR" {
                    $newFolder = $month + "-" + $dateTaken.Year.toString()
                    break;
                }

                "YEAR-MONTH" {
                    $newFolder = $dateTaken.Year.toString() + "-" + $month
                    break;
                }
            
                "YEAR\MONTHNAME" {
                    $newFolder = $dateTaken.Year.toString() + "\" + $month
                    break;
                }

                "YEAR\MONTHNUMBER-MONTHNAME" {
                    $newFolder = $dateTaken.Year.toString() + "\" + $dateTaken.Month.toString() + "-" + $month
                    break;
                }
            
                "YEAR\MONTHNAME\DAY" {
                    $newFolder = $dateTaken.Year.toString() + "\" + $month + "\" + $dateTaken.Day.toString()
                    break;
                }

                "YEAR\MONTHNUMBER-MONTHNAME\DAY" {
                    $newFolder = $dateTaken.Year.toString() + "\" + $dateTaken.Month.toString() + "-" + $month + "\" + $dateTaken.Day.toString()
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
                        $copyStart = Get-Date                       
                        if ($AddDatePrefix) {
                            Copy-Picture -picture $p -destination $newPath -DatePrefix
                        } else {
                            Copy-Picture -picture $p -destination $newPath
                        }

                        $copyEnd = Get-Date

                        Write-Host "Done" -ForegroundColor Green
                        $o = New-Object -TypeName PSObject -Property @{
                            Operation = "Copy";
                            Source = $p.FullName;
                            Destination = ($newPath.TrimEnd("\") + "\" + $p.Name);
                            Elapsed = "{0:N2}" -f ($copyEnd - $copyStart).TotalMilliseconds;
                            Status = "Success";
                            Size = "{0:N2}" -f ($p.Length /1MB);
                            LogType = "Ok";
                        }
						$actions += $o
                        break;

                    } catch {
                        $o = New-Object -TypeName PSObject -Property @{
                            Operation = "Copy";
                            Source = $p.FullName;
                            Destination = ($newPath.TrimEnd("\") + "\" + $p.Name);
                            Elapsed = "{0:N2}" -f ($copyEnd - $copyStart).TotalMilliseconds;
                            Status = "Error: $($Error[0].Exception)";
                            Size = "{0:N2}" -f ($p.Length /1MB);
                            LogType = "Error"
                        }
						$actions += $o
						
                    }
                }

                "Move" {
                
                    try {
                        Write-Host "Moving $($p.Name) to $newPath..." -NoNewline 
                        $moveStart = Get-Date
                        if ($AddDatePrefix) {
                            Move-Picture -picture $p -destination $newPath -DatePrefix
                        } else {
                            Move-Picture -picture $p -destination $newPath
                        }
                        
                        $moveEnd = Get-Date

                        Write-Host "Done" -ForegroundColor Green
                        $o = New-Object -TypeName PSObject -Property @{
                            Operation = "Move";
                            Source = $p.FullName;
                            Destination = ($newPath.TrimEnd("\") + "\" + $p.Name);
                            Status = "Success";
                            Elapsed = "{0:N2}" -f ($moveEnd - $moveStart).TotalMilliseconds;
                            Size = "{0:N2}" -f ($p.Length /1MB);
                            LogType = "Ok";
                        }
						$actions += $o
                        break;
                    } catch {
                        Write-Host "Error" -ForegroundColor Red
                        $o = New-Object -TypeName PSObject -Property @{
                            Operation = "Move";
                            Source = $p.FullName;
                            Destination = ($newPath.TrimEnd("\") + "\" + $p.Name);
                            Elapsed = "{0:N2}" -f ($moveEnd - $moveStart).TotalMilliseconds;
                            Status = "Error: $($Error[0].Exception)";
                            Size = "{0:N2}" -f ($p.Length /1MB);
                            LogType = "Error";
                        }
						$actions += $o
                    }
                }

            }

        }

    } ## If picture count is gt 0
    else {
        Write-Host "No images found" -ForegroundColor Red
        break;
    }
	
	$scriptEnd = Get-Date
    $htmlHeader += '<table class="table table-striped table-hover">
                <tr>
                    <th>Run Date</th>
                    <th>Success</th>
                    <th>Failure</th>
                    <th>Log File</th>
					<th>Duration (minutes)</th>
					<th>Total Moved (MB)</th>
					<th>Performance</th>
                </tr>
                <tbody>
                    <tr class="warning">
                        <td>' + $fLogDate + '</td>
                        <td>' + ($actions | ?{$_.Status -match "Success"}).Count + '</td>
                        <td>' + ($actions | ?{$_.Status -match "Error"}).Count + '</td>
                        <td>Log_' + $logDate + '.txt</td>
						<td>' + "{0:N2}" -f (($scriptEnd - $scriptStart).TotalMinutes) + '</td>
						<td>' + "{0:N2}" -f ($dataMoved /1MB)+ '</td>
						<td>~' + "{0:N2}" -f (($actions | ?{$_.Status -match "Success"}).Count / ($scriptEnd - $scriptStart).TotalSeconds) + ' Pictures/second<br>~
							' + "{0:N2}" -f (($dataMoved / ($scriptEnd - $scriptStart).TotalSeconds) /1MB ) + ' MB/second
						</td>
                    </tr>
                </tbody>
                </table>'
    
    foreach ($a in $actions) {
        
        $class = if ($a.Status -match "Error") { "danger" } else { "success" }

        $rows += '<tr class="' + $class + '">
                    <td>' + $a.Operation + '</td>
                    <td>' + $a.Source + '</td>
                    <td>' + $a.Destination + '</td>
                    <td>' + $a.Size + '</td>
                    <td>' + $a.Elapsed + '</td>
                    <td>' + $a.Status + '</td>
                </tr>'
        
    }
    
    $logTable =  '<table class="table table-striped table-hover">
                    <tr>
                        <th>Operation</th>
                        <th>Source</th>
                        <th>Destination</th>
                        <th>Size (MB)</th>
                        <th>Duration (ms)</th>
                        <th>Result</th>
                    </tr>
                    <tbody>
                        ' + $rows + '
                    </tbody>
                </table>'
    $html += '<body>
                
                <div class="container">
                    <h1>Your Photo Organizer Report</h1>
                    <small>Your command: ' + $cmdRun + '</small>
                    ' + $htmlHeader + '
                    ' + $logTable + '
                </div>
            </body>'

    $html | Out-File "Report_$logDate.html"
}


#RUN



Start-Transcript -Path "Log_$logDate.txt"
$cmdRun = ".\Organize-Pictures -Recurse $Recurse -Scope $Scope -target $target -destination $destination -Operation $Operation -OrganizeBy $OrganizeBy -AddDatePrefix $AddDatePrefix -Filter $Filter -LabelEvents $LabelEvents"
Group-Pictures -Recurse $Recurse -Scope $Scope -target $target -destination $destination -Operation $Operation -OrganizeBy $OrganizeBy -AddDatePrefix $AddDatePrefix -Filter $Filter -LabelEvents $LabelEvents

Stop-Transcript
