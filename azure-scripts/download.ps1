. .\common.ps1

if not (Test-Path $outputlocation) { mkdir $outputlocation }
$storageAccount = Get-azStorageAccount -ResourceGroupName "$($ResourceGroupName)" -Name "$($StorageName)"

$tests="org clean all bce bve se up no_bce no_bve no_se no_up".split()
foreach($test in $tests)
{
    $outputs = Get-AzStorageBlob -Container tasks -Context $storageAccount.Context -Prefix "$($studentid)/output/$($test)-" -MaxCount 1000000
    mkdir "$($outputlocation)\$($test)"
    foreach($output in $outputs)
    {
        if ($output.Name.EndsWith("stdout.txt"))
        {
            $resultname=$output.Name.Split("/")[-2]
            if (!(test-path "$($outuptlocation)\$($test)\$($resultname)")) {
                write-Host $($output.Name)
                Get-AzStorageBlobContent -Container tasks -Context $storageAccount.Context -Blob "$($output.Name)" -Destination "$($outuptlocation)\$($test)\$($resultname)"
            }
        }    
    }
}

