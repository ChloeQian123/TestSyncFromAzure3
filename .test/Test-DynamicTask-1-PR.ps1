param($PAT, $OrganizationName, $ProjectName,$ReposName,$GlobalUserEmail, $GlobalUserName, $ExcutePSFile)

if(-not $ExcutePSFile)
{
	Write-Error "You must set the ExcutePSFile environment variable - For example, DynamicTask-Main-Daily.ps1";
    exit 1;
}

$ScriptFolder =".test\";

#. ((Split-Path $MyInvocation.InvocationName) + $ScriptFolder + "Common.ps1");
. ((Split-Path $MyInvocation.InvocationName) + $ScriptFolder + $ExcutePSFile);
#Build at local: & ((Split-Path $MyInvocation.InvocationName) + "\Common.ps1");
#$ExcutePSFile = "DynamicTask-Main-Daily.ps1",  "DynamicTask-Main-EveryChange.ps1"

# set environment variables
if(-not $env:PAT)
{
	Write-Error "You must set the PAT environment variable";
    exit 1;
}
if(-not $env:OrganizationName)
{
	Write-Error "You must set the OrganizationName environment variable - For example, Supportability";
    exit 1;
}
if(-not $env:ProjectName)
{
	Write-Error "You must set the ProjectName environment variable - For example, Azure";
    exit 1;
}
if(-not $env:ReposName)
{
	Write-Error "You must set the ReposName environment variable - For example, WikiContent";
    exit 1;
}

$PAT = $env:PAT;
$OrganizationName = $env:OrganizationName;
$ProjectName = $env:ProjectName;
$ReposName = $env:ReposName;
$GlobalUserEmail = $env:GlobalUserEmail;
$GlobalUserName = $env:GlobalUserName;


git config --global user.email $GlobalUserEmail
git config --global user.name $GlobalUserName

#Run the script tasks
RunDynamicPSTasks $ScriptFolder;

Write-Host "pat number is " $PAT;
Write-Host "env pat number is " $env:PAT;
Write-Host "OrganizationName is " $OrganizationName;
Write-Host "ProjectName is " $ProjectName;
Write-Host "ReposName is " $ReposName;


Function PushtoGithub($GithubRepoUrl)
{

    $currentyLocation = Get-location;
    Write-Host "Currenty Location is:" $currentyLocation;
    $sshItemLocation = $currentyLocation.ToString() + "\.test\.ssh\*";
	Write-Host "ssh Item Location is:" $sshItemLocation;

    $GithubTempRepo="GithubTempRepo";
	$newfilename="Readme112104.md";

    Write-Host "Github operations start:";

	Write-Host "Config account info";
	git config --global user.name "Chloe Chloe"
    git config --global user.email "v-jichlo@microsoft.com"

    Write-Host "Clone Github Repo to local ../GithubTempRepo";
    git clone https://github.com/ChloeQian123/ChloeQian123.github.io.git $GithubTempRepo 

	cd $GithubTempRepo 

	Write-Host "modify a file";
	$filelist = Get-ChildItem -Filter *.md;
	ForEach($file in $filelist){
	  Add-Content $file.FullName -Value "This is a test section! 1124-5" ;
	  Write-Host "Add to commit";
	  git add $file.FullName
	 }
	
	Write-Host "Git status after modification";
	git status

	Write-Host "Commit to local Repo";
	git commit -m "test commit 1124-5"

	Write-Host "Push to remote Repo using https";

	Write-Host "Set remote Repo";
	$GithubRepoPushUrl="https://ChloeQian123:759bba943e7a7a4ec4a27136b9a4d6a6a261b8ce@github.com/ChloeQian123/ChloeQian123.github.io.git";
    git remote set-url --push origin $GithubRepoPushUrl

	Write-Host "Origin after";
	git remote show origin

	Write-Host "Push to remote Repo";
    git push -u origin master

	#$ItemListofVssAdministratorssh= Get-ChildItem -Path "C:\Users\VssAdministrator\.ssh" -Force;
	#Write-Host "C:\Users\VssAdministrator\.ssh";
	#ForEach($Item in $ItemListofVssAdministratorssh){
	#   Write-Host $Item.FullName;
	#}
	

    
	#$currentyDir = Split-Path -Parent $MyInvocation.MyCommand.Definition;
    #Copy-Item $sshItemLocation -Destination "C:\Users\VssAdministrator\.ssh" -Recurse

	#Write-Host "Copy ssh item manually to C:\Users\VssAdministrator\.ssh" $currentyLocation;
	#$ItemListofVssAdministratorssh= Get-ChildItem -Path "C:\Users\VssAdministrator\.ssh" -Force;
	#Write-Host "C:\Users\VssAdministrator\.ssh";
	#ForEach($Item in $ItemListofVssAdministratorssh){
	#   Write-Host $Item.FullName;
	#}


    #Write-Host "Try Again Push to remote Repo";
    #git push origin master

	#Write-Host "Delete local Repo ../GithubTempRepo";
	#Write-Host "Github operations complete";
}

Function PubulishDynamicContent($PAT, $OrganizationName,$ProjectName, $ReposName)
{
	if ((git status) -match "working tree clean") {
		# Nothing changed, we're done
		Write-Host "Working tree clean";
		return;
	}
	else {
		Write-Host "Status after scripts:"
		git status
		Write-Host "Diff after scripts:"
		git diff

		# Create a unique branch name
		$dateString = [DateTime]::Now.ToString("yyyyMMddHHmmss")
		$branchName = "autoupdate-$dateString"

		$CommitText = "Automatic Dynamic Content Update"
		$CommitTitleText = "Automatic Dynamic Content Update"

		$DevOPSDomain = "dev.azure.com"
		$ReposName2 = "SyncTestRepo"
		$RemoteURL2 = "https://${OrganizationName}:$PAT@$DevOPSDomain/$OrganizationName/$ProjectName/_git/$ReposName2"
		$RemoteURL = "https://${OrganizationName}:$PAT@$DevOPSDomain/$OrganizationName/$ProjectName/_git/$ReposName"
		$PRResponseURL = "https://$DevOPSDomain/$OrganizationName/$ProjectName/_apis/git/repositories/$ReposName/pullrequests?api-version=5.0"
        $RemoteURL2 = "https://ChloeQian123@dev.azure.com/ChloeQian123/ChloeQian123.github.io/_git/SyncTestRepo"
		# Commit our changes to a new branch, and push
		git branch $branchName
		git checkout $branchName
		git add .
		if ((git commit -m $CommitTitleText) -match "working tree clean") 
		{
			Write-Host "No actual changes made.";
			return;
		}
		git commit -m $CommitText
		git remote add auth $RemoteURL
		git push -u auth $branchName

        git remote set-url origin $RemoteURL
		git remote add origin $RemoteURL2

		$today = [DateTime]::Now;
        $dateStringDel= $today.AddDays(-7).ToString("yyyy-MM-dd")
		$dateStringDel
		Write-Host "View Branch"
        git branch -r
        Write-Host "Delete Branch 7 days ago"
		git branch --remote|
        Where-Object{!$_.contains("master") -and $_.contains("autoupdate-") }|
        Where-Object{[datetime]::Parse((git log -1 $_.trim() --pretty=format:"%cD")) -lt $dateStringDel}|
        ForEach-Object{git push origin --delete ($_.Replace("origin/","")).trim()}
        git branch -r
        
		# Open a pull request
		$encodedPAT = [Convert]::ToBase64String([System.Text.ASCIIEncoding]::ASCII.GetBytes(":" + $PAT))
		$createPRResponse = Invoke-RestMethod -Method POST `
			-Uri $PRResponseURL `
			-ContentType "application/json" `
			-Headers @{"Authorization" = "Basic $encodedPAT"} `
			-Body "{ sourceRefName: `"refs/heads/$branchName`", targetRefName: `"refs/heads/master`", title: `"$CommitTitleText`" }"

		$prid = $createPRResponse.pullRequestId
		$commitId = $createPRResponse.lastMergeSourceCommit.commitId | Select -First 1

		# Wait 5 seconds. Azure DevOps seems to need a few seconds before we try to complete.
		Start-Sleep 5
		$RestPATCHURL = "https://$DevOPSDomain/$OrganizationName/$ProjectName/_apis/git/repositories/$ReposName/pullrequests/" + $prid + "?api-version=5.0"

		# Now complete the pull request and override policies
		Invoke-RestMethod -Method PATCH `
			-Uri ($RestPATCHURL) `
			-ContentType "application/json" `
			-Headers @{"Authorization" = "Basic $encodedPAT"} `
			-Body "{ status: `"completed`", lastMergeSourceCommit: { commitId: `"$commitId`" }, completionOptions: { bypassPolicy: `"true`", bypassReason: `"$CommitTitleText`"  } }"
	
	}
}

#Run Git commit and push operations
PubulishDynamicContent $PAT $OrganizationName $ProjectName $ReposName;
$GithubRepoUrl="https://github.com/ChloeQian123/ChloeQian123.github.io.git";
PushtoGithub $GithubRepoUrl;
