# Copy-FilesWithHash 

A file copy script which copy files from a defined source folder to a target folder computing hashes and saves it to an file in the target folder. Optionally you can compute hashes from both source and targe files as well as diff check the output.

## Parameters
| Parameters | Explanation (default values, in bold) |
| --------- | ------ |
|-SourceFolder | Source folder to copy files from.|
| -TargetFolder | Destination folder to copy files to.|
|-OutputFile | Filename of the hash file saved in -TargetFolder|
|-Algorithm | Algorithm (SHA1, **SHA256**, SHA384, SHA512, MD5)|
|-VerifySource | In addition to computing hashes for -TargetFolder it also computes hashes for files in -SourceFolder, to be able to perform a diff check.|
|-DiffType | Diff setting, default is to display only resutls of difference. With this you can chose to override default to IncludeEqual as well as ExcludeDifferent.|
|-Verbose | Script does not output much information to the console, with -Verbose flag on it does.|

## Example
Copy-FilesWithHash -SourceFolder '~\Downloads\patches' -TargetFolder G:\ -Algorithm SHA512 -VerifySource -Verbose

# Additional notes
This script is built around Get-Filehash as well as Compare-Object.
