#This script is used to compare two folders and all contents to see if anything is missing from the production folder.

#Set the paths for these variables
$backupPath = "D:\Test\Backup"
$productionPath = "D:\Test\Production"


#Get the high level folders under the backup path
$backupFolders = Get-ChildItem $backupPath


#Sort through each folder in the backup path
foreach ($folder in $backupFolders)
    {

    #Set some variables to use more easily
    $foldername = $folder.Name
    $backupfolderPath = $backupPath + "\" + $foldername
    $productionfolderPath = $productionPath + "\" + $foldername
    
    #Search the content items of each folder under the backup
    $contentsofBackup = Get-ChildItem $backupfolderPath
    
    #Compare each item to see if the corresponding path in Production has that item
    foreach ($item in $contentsofBackup)
        {

        #Set some variables for use more easily
        $itemName = $item.Name
        $itemPath = $backupfolderPath + "\" + $itemName
        
        #Test to see if the item/file is in the same folder in Prodction
        $itemisInProd = Test-Path $productionfolderPath\$itemName
        
        #If it is already in Production, write a response, if not copy the file to the production folder
        If ($itemisInProd)
            {
            Write-Output "The file $itemName in Backup Folder: $foldername already exists in Production."
            }
            else
            {
            Write-Output "The file $itemName in Backup Folder: $folderName does not exists in Production, copying $itemName"
            Copy-Item $itemPath -Destination $productionfolderPath
            }
        }
    }