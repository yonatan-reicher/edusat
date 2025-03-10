# Storage account resource group and name
$ResourceGroupName="la096265course-infrastructure-group"
$StorageName="la096265datastorage"

#Batch account name
$BatchName="la096265coursebatch"

# Pool name in Batch account
$PoolId="Class1"

# Job name in pool (Class1), run your jobs with your email ID e.g efratmaimon
# You can run the jobs with date/number if you want to keep several copies in the Storage account 
# e.g efratmaimon1, efratmaimon2, efratmaimon3, efratmaimon22jan, efratmaimon23jan
$studentid="yonatan-reicher-test"

# Location of exe and data files (change it to the local directory you will use)
$location="C:\technion\2025\algorithms-in-logic\project"

# In codelocation put the executable and the DLLs
$codelocation="$($location)\Release"

#In datalocation put the .cnf files
$datalocation="$($location)\edusat\test\easy_cnf_instances"

# The outputs from Azure will be copied to this directory. Will be created if
# does not exist.
$outuptlocation="$($location)\azure-output"

# Change this with the name of you executable file
$executablefilename='edusat.exe'

# In executableparams you can add other parameters to your executable
$executableparams="-mode 1"
