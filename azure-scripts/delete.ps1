. .\common.ps1

$env:AZURE_STORAGE_ACCOUNT = $StorageName

az storage blob delete-batch -s tasks --pattern "$($studentid)/*"
