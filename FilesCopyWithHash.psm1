<#  
  .SYNOPSIS   
    f
  .DESCRIPTION
	f
  .PARAMETER SourceFolder
	Source Folder
  .PARAMETER TargetFolder
	Target Folder
  
	

   .NOTES
	Version:	1.0
	Author:		mytsk
	Creation Date:	2024-02-24
	Purpose/Change: Initial development
  .LINK
	https:/www.github.com/mytsk/FilesCopyWithHash
#>
function Copy-FilesWithHash {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ Test-Path $_ -PathType Container })]
        [string]$SourceFolder,

        [Parameter(Mandatory = $true)]
        [string]$TargetFolder,

        [Parameter(Mandatory = $false)]
        [string]$OutputFile,

        [Parameter(Mandatory = $false)]
        [ValidateSet('SHA256', 'SHA384', 'SHA512', 'SHA1', 'MD5')]
        [string]$Algorithm,

        [switch]$VerifySource,

        [Parameter(Mandatory = $false)]
        [ValidateSet('IncludeEqual', 'ExcludeDifferent')]
        [string]$DiffType
    )
    
    $SourceFolder = $SourceFolder.ToLower()
    $TargetFolder = $TargetFolder.ToLower()

    # Set default output file if not provided
    if (!$OutputFile) {
        $OutputFile = "hashes_target.txt"
    }
    if (!$Algorithm) {
        $Algorithm = "SHA256"
    }


    # Start time for execution
    $startTime = Get-Date

    # Copy the entire folder structure from source to target
    Write-Verbose "Copying files from '$SourceFolder' to '$TargetFolder'..."
    $null = Copy-Item -Path $SourceFolder\* -Destination $TargetFolder -Recurse -Force

    # Get list of files in target folder and calculate hash for each file
    Write-Verbose "Calculating hashes for files in '$TargetFolder'..."
    $targetHashes = Get-ChildItem -Path $TargetFolder -Recurse -File | ForEach-Object {
        $relativePath = $_.FullName.Replace((Resolve-Path $TargetFolder).Path, '').TrimStart('\')
        $hash = Get-FileHash -Path $_.FullName -Algorithm $Algorithm
        [PSCustomObject]@{
            Filename   = $_.Name
            FolderPath = $relativePath
            Algorithm  = $Algorithm
            Hash       = $hash.Hash
        }
    }

    # Output target hashes to console and file
    #$targetHashes | Format-Table -AutoSize
    $targetHashes | Export-Csv -Delimiter ';' -Path "$TargetFolder\$OutputFile" -NoTypeInformation
    
    # Verify source hashes if -VerifySource switch is used
    if ($VerifySource) {
        Write-Verbose "Verifying hashes in '$SourceFolder'..."
        $sourceHashes = Get-ChildItem -Path $SourceFolder -Recurse -File | ForEach-Object {
            $sourceFolderResolved = (Resolve-Path $SourceFolder).Path.ToLower()
            $relativePath = $_.FullName.ToLower().Replace($sourceFolderResolved, '').TrimStart('\')
            $hash = Get-FileHash -Path $_.FullName -Algorithm $Algorithm
            [PSCustomObject]@{
                Filename   = $_.Name
                FolderPath = $relativePath
                Algorithm  = $Algorithm
                Hash       = $hash.Hash
            }
        }

        # Output source hashes to file
        $sourceHashes | Export-Csv -Delimiter ';' -Path "$TargetFolder\hashes_source.txt" -NoTypeInformation

        Write-Verbose "Comparing source hashes with target hashes..."
        # Compare source and target hashes
        if ($DiffType -eq 'IncludeEqual') {
            $differences = Compare-Object -ReferenceObject $sourceHashes -DifferenceObject $targetHashes -Property Filename, FolderPath, Algorithm, Hash -IncludeEqual
        }
        elseif ($DiffType -eq 'ExcludeDifferent') {
            $differences = Compare-Object -ReferenceObject $sourceHashes -DifferenceObject $targetHashes -Property Filename, FolderPath, Algorithm, Hash -ExcludeDifferent
        }
        else {
            $differences = Compare-Object -ReferenceObject $sourceHashes -DifferenceObject $targetHashes -Property Filename, FolderPath, Algorithm, Hash
        }

        # Output differences to file
        $differences | Export-Csv -Delimiter ';' -Path "$TargetFolder\diff_status.txt" -NoTypeInformation
    }

    Write-Verbose "Copy process completed"
    $endTime = Get-Date
    $executionTime = New-TimeSpan -Start $startTime -End $endTime
    
    Write-Verbose "Script execution took $($executionTime.ToString()) (hh:mm:ss.nnnnnnn)"
    Write-Verbose "Exiting ..."
}

# Uncomment the line below to enable verbose output
# $VerbosePreference = 'Continue'
Export-ModuleMember -Function 'Copy-FilesWithHash'