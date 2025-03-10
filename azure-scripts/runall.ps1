. .\common.ps1

$tests="org clean all bce bve se up no_bce no_bve no_se no_up".split()

# Upload files to blob
$datafiles=Get-ChildItem -Path $datalocation -File
$storageAccount = Get-azStorageAccount -ResourceGroupName "$($ResourceGroupName)" -Name "$($StorageName)"

# Generate tempeorary sas token for the next 48 hours, 
# If the tasks run more than 48 hours you will have to change $now.AddHours(<number of hours you want the connection to the storage will be active)
$now=get-date
$blobsas=New-AzStorageContainerSASToken -Context $storageAccount.Context -Container tasks -Permission rwdl -StartTime $now.AddHours(-1) -ExpiryTime $now.AddHours(48)
$bloburl="https://$($StorageName).blob.core.windows.net/tasks"

# Generate json file with all the tasks will be sent to the job in Batch account
$tasks=@()
foreach($test in $tests)
{
    # Change this with the name of you executable file
    $executablefilename="edusat_$($test).exe"
    # In executableparams you can add other parameters to your executable
    $executableparams="-timeout 900"
  
    foreach($file in $datafiles)
    {
        # Undocumented bug - taskid must be short enough...
        $taskid= ("$($test)-$($file.baseName)").Replace('.','_')
        $rfiles=@()
        $fileobj = New-Object -TypeName psobject
        $fileobj  | Add-Member -MemberType NoteProperty -Name filePath -Value "$($file.Name)"
        $fileobj  | Add-Member -MemberType NoteProperty -Name httpUrl -Value "$($bloburl)/$($studentid)/$($file.Name)$($blobsas)"
        $rfiles+=$fileobj
        
		# Add the relevant executable :)
        $fileobj = New-Object -TypeName psobject
        $fileobj  | Add-Member -MemberType NoteProperty -Name filePath -Value "$($executablefilename)"
        $fileobj  | Add-Member -MemberType NoteProperty -Name httpUrl -Value "$($bloburl)/$($studentid)/$($executablefilename)$($blobsas)"
        $rfiles+=$fileobj
        
        $outputs=@()
        $outobj = New-Object -TypeName psobject
        $outobj  | Add-Member -MemberType NoteProperty -Name destination -Value @{"container"=@{"path"="$($studentid)/output/$($taskid)";"containerUrl"= "$($bloburl)/$($blobsas)"}}
        $outobj  | Add-Member -MemberType NoteProperty -Name filePattern -Value "..\**\*.txt"
        $outobj  | Add-Member -MemberType NoteProperty -Name uploadOptions -Value @{"uploadCondition"="taskCompletion"}
        $outputs+=$outobj

        $obj = New-Object -TypeName psobject
        $obj  | Add-Member -MemberType NoteProperty -Name id -Value $taskid
        $obj  | Add-Member -MemberType NoteProperty -Name commandLine -Value "$($executablefilename) $($executableparams) $($file.Name)"
        $obj  | Add-Member -MemberType NoteProperty -Name resourceFiles -Value $rfiles
        $obj  | Add-Member -MemberType NoteProperty -Name outputFiles -Value $outputs

        $tasks+=$obj
    }
}

$tasks | ConvertTo-Json -Depth 100 | Out-File "$($location)\tasks.json"


# Connect to Batch account
$context = Get-AzBatchAccountKey -AccountName "$($BatchName)"

# Delete a job and all its tasks
# Uncomment if you want that the script will delete the job if exists, be aware not to run it if the tasks didn't complete
# Because if the tasks didn't complete, no output data is save to the Azure storage account
# If you delete the job from here the script won't send the tasks because the status of the job is Deleting
# Afte you check that the job was deleted from the job using the Azure Portal, comment the "az batch delete" line and run the script again

#invoke-expression "&az batch job delete --job-id  $($studentid) --account-endpoint $($context.AccountEndpoint) --account-key $($context.PrimaryAccountKey) --account-name $($context.AccountName) --yes"

# Create a job in pool Class1
invoke-expression "&az batch job create --id $($studentid) --account-endpoint $($context.AccountEndpoint) --account-key $($context.PrimaryAccountKey) --account-name $($context.AccountName) --pool-id $($PoolId)"

# Submit all tasks in json file to job
invoke-expression "&az batch task create --job-id $($studentid) --account-endpoint $($context.AccountEndpoint) --account-key $($context.PrimaryAccountKey) --account-name $($context.AccountName) --json-file $($location)\tasks.json"
