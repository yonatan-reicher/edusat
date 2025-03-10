. .\common.ps1

# Upload files to blob
$codefiles=Get-ChildItem -Path $codelocation -File
$datafiles=Get-ChildItem -Path $datalocation -File
$files=@()
$files+=$codefiles
$files+=$datafiles
$storageAccount = Get-azStorageAccount -ResourceGroupName "$($ResourceGroupName)" -Name "$($StorageName)"
 
# Upload file to Azure storage
foreach ($file in $files) 
{
    $out=Set-AzStorageBlobContent -File $file.fullname `
    -Container tasks `
    -Blob "$($studentid)/$($file.name)" `
    -Context $storageAccount.Context -Force
    Write-Host "uploaded $($out.name)"
}
Write-Host "[*] Done!"
