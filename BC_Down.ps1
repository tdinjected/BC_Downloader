<# **  v0.1: Added prompt for webpage, download web source code functionality, split to create end
   **        of line functionality, keyword ID vars, and code to identify remote file names.
   **  v0.2: Added ability to download to loaded-from directory with 'System.Net.WebClient'.
   **  v0.3: Added prompt to select download location and a ForEach loop to discover song name.
   **        It applies it to the file name with associated track number based off an index var.
   **  v0.4: Added leading "0" to track # in file name (tracks <10 are equal length for sorting.)
   **  v0.5: Fixed numbering (tracks>9 had leading 0) - cast "$track"=string.  Prompts to do another.
   **  v1.0: Checks to see if destination folder already exists and what to do if it does.      
   **  v1.1: Fixed track name detection for file naming due to BandCamp's source code change.
   **  v1.2: Shortened script.  Excluding intro comments, it's now only 58 lines (9/26/2016).					
   **  v1.3: Fixed special char filenames MS won't permit (replace w/ underscore.) 
   **  v1.4: Fixed the "Public\Desktop" var so that it should be universal.   61 lines 10/25/2016 #>
CLS
Write-Host "`r`n  **   BandCamp Downloader v1.4 R. Callahan   **"
Write-Host "  (Limited to 128Kbps by BandCamp for streaming)`r`n"
$wc = New-Object System.Net.WebClient
$loadedfrom = $PWD.Path + "\BC_Down.ps1"

#  Downloads source of webpage user entered, splits into lines, then sets keywords for finding name/download URL
$BC_Url = Read-Host -Prompt "Please paste the album URL (The files will be on your desktop in 'BandCamp_Downloaded')"
$DL_Folder = Read-Host -Prompt 'Please enter a folder name'
$DL_Path = ([Environment]::GetEnvironmentVariable("Public"))+"\Desktop\BandCamp_Downloaded\" + $DL_Folder
If (Test-Path $DL_Path) {
	Do { $Rslt = Read-Host -Prompt "`r`nThis folder already exists.  Overwrite? (Y/N)" }
	While (($Rslt.ToUpper() -ne "Y") -and ($Rslt.ToUpper() -ne "N"))
	If($Rslt.ToUpper() -eq "Y") {RI -recurse $DL_Path -Force }
	Else {
		Do {
			$DL_Folder = Read-Host -Prompt "Please enter a new folder name"
			$DL_Path = "c:\users\public\desktop\BandCamp_Downloaded\" + $DL_Folder
		} While (Test-Path $DL_Path) }
}

New-Item -Path $DL_Path -Type directory | Out-Null
$Src = (New-Object Net.Webclient).DownloadString($BC_Url) -Split '\}\,'
$file_ID = '\"mp3\-128\"'; $title_ID = '\"title\":'

#  Creates an array of song names by searching for the keyword mentioned above
$name_list = @(); $char_chng = $False
$char2excl = '\', '/', ':', '*', '?', '"', '<', '>', '|'
ForEach ($title in $Src) {
	If ($title -Match $title_ID) {
		$title = ($title -split $title_ID)[1]
		$title = (($title -split '\"\,')[0]).SubString(1)
		ForEach ($ch in $char2excl) {
			If ($title.contains($ch)) {$title = $title.Replace($ch, "_"); $char_chng = $True }
		}
		$name_list += $title
	}
}

#  Downloads file based off keyword and matches with song name.  Downloads to file name from list and shows progress.
Write-Host; $i = 1
ForEach ($url in $Src) {
	If ($url -Match $file_ID)  {
		$url = (($url -split $file_ID)[1]).SubString(4) -replace ".$"
		$url = "https://" + $url; $track = $i
		If ($track -lt 10) { $track = "0" + $track }
		$short_name = [string]$track + " " + $name_list[$i] + ".mp3"
		$out = $DL_Path + "\" + $short_name
		$start_time = Get-Date; $wc.DownloadFile($url, $out)
		Write-Output "$short_name downloaded in $((Get-Date).Subtract($start_time).Seconds) second(s)"
		$i++
	}
}
If ($char_chng -eq $True) {Write-Host "`r`n**  One or more titles contained invalid characters and were replaced with an underscore.  **"}

Do {
	Write-Host
	$Rslt = Read-Host -Prompt "Would you like to download a different album? (Y/N)"
}
While (($Rslt.ToUpper() -ne "Y") -and ($Rslt.ToUpper() -ne "N"))
If($Rslt.ToUpper() -eq "Y") {& $loadedfrom}