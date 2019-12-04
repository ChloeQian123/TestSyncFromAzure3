param($PAT, $OrganizationName, $ProjectName,$ReposName,$GlobalUserEmail, $GlobalUserName, $ExcutePSFile)

if(-not $ExcutePSFile)
{
	Write-Error "You must set the ExcutePSFile environment variable - For example, DynamicTask-Main-Daily.ps1";
    exit 1;
}

$ScriptFolder =".Script\";
$CurrentProjContentLocation=Get-location;
Write-Host "Current Project Content Location" $CurrentProjContentLocation;

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

Write-Host "pat number is " $PAT;
Write-Host "env pat number is " $env:PAT;
Write-Host "OrganizationName is " $OrganizationName;
Write-Host "ProjectName is " $ProjectName;
Write-Host "ReposName is " $ReposName;


Function FindChild($parentFolderPath,$sourcePath,$destinationPath){

  $newPath=$parentFolderPath.Replace($sourcePath,$destinationPath)

  Write-Host "ObjectPath:" $newPath;
  if(Test-Path -Path $newPath){
	Write-Host $newPath "exist";
  }else{
    Write-Host $newPath "not exist";
    New-Item -ItemType "directory" -path $newPath
  }

  $chlidItemsList=Get-childitem $parentFolderPath |where {$_.Attributes -match 'Directory'}
  if($chlidItemsList.Count -eq 0){}
  else{
    $chlidItemsList|Foreach-object{
	  if($_.FullName.contains("\.git")){}
	  else{
	    $newparentFolderPath=$parentFolderPath+"\"+$_.name;
	    FindChild  $newparentFolderPath $sourcePath $destinationPath;
	  }
	}
  }
}

Function PushtoRemote($CloneRepo,$GithubRepoPushUrl,$RepoName)
{

    $MixProjLocation = Get-Location;
    Write-Host "Current Location is:" $MixProjLocation;
    #$sshItemLocation = $MixProjLocation.ToString() + "\.test\.ssh\*";

	#back to parent folder of current project
	cd ..
    $GithubTempRepo=$RepoName;

    Write-Host "Remote Repo operations start:";
	Write-Host "Config account info";
	git config --global user.email $GlobalUserEmail
    git config --global user.name $GlobalUserName

    Write-Host "Clone Remote Repo to local ..\"$RepoName;
    git clone $CloneRepo $RepoName 

	#enter Destination project
	cd $RepoName 

	$updateFolder="\";
	$sourcePath=$CurrentProjContentLocation.ToString()+$updateFolder;
	$currentPath=Get-location;
	$destinationPath=$currentPath.ToString()+$updateFolder;
	Write-Host "sourcePath" $sourcePath;
	Write-Host "destinationPath" $destinationPath;

	#Remove items
	Write-Host "Remove all the item except .git folder in destinationPath before update";
	$projGitInfoLocation = $destinationPath+"\.git";
	Get-ChildItem -Path $destinationPath -Recurse|Where {$_.FullName -notlike $projGitInfoLocation}|Remove-Item -force -Recurse

	#Create Directory tree
	Write-Host "Create new directory in" $destinationPath;
	FindChild $sourcePath $sourcePath $destinationPath;

	#Coly files
	Write-Host "Copy Files from" $sourcePath "to" $destinationPath "exclude .git folder";	
	$sourceprojGitInfoLocation = $sourcePath+"\.git";
	Get-ChildItem -Path  $sourcePath -Recurse|Where {$_.FullName -notlike $sourceprojGitInfoLocation}|where {$_.Attributes -notmatch 'Directory'}|Foreach-Object{
	  $source=$_.FullName;
	  $destination=$_.FullName.Replace($sourcePath,$destinationPath);
	  Write-Host "Copy" $source "to" $destination;
	  Copy-Item $source -Destination $destination -Recurse
	}
	Write-Host "Copy items complete";

	$ItemListofDocFolder = Get-ChildItem -Path $destinationPath -Force;
	Write-Host "Items in" $ItemListofDocFolder;
	ForEach($Item in $ItemListofVssAdministratorssh){
	   Write-Host $Item.FullName;
	   git add $Item.name
	}

	git add .
	
	Write-Host "Git status after modification";
	git status

	Write-Host "Commit to local Repo";
	git commit -m "test commit 1129-1"

	Write-Host "Push to remote Repo using https";

	Write-Host "Set remote Repo";
	#$GithubRepoPushUrl="https://ChloeQian123:8a1458c5c85e66d8a67fcaa94772183016910118@github.com/ChloeQian123/TestSyncFromAzure2.git";
    git remote set-url --push origin $GithubRepoPushUrl

	Write-Host "Origin after";
	git remote show origin

	Write-Host "Push to remote Repo";
    git push -u origin master

    cd ..

		#if(Test-Path -Path $destinationPath){
	#	Write-Host $destinationPath "exist";
	#}else{
	#   Write-Host $destinationPath "not exist";
	#   New-Item -ItemType "directory" -path $destinationPath
	#}

	#$ItemListofVssAdministratorssh= Get-ChildItem -Path "C:\Users\VssAdministrator\.ssh" -Force;
	#Write-Host "C:\Users\VssAdministrator\.ssh";
	#ForEach($Item in $ItemListofVssAdministratorssh){
	#   Write-Host $Item.FullName;
	#}

	#$currentyDir = Split-Path -Parent $MyInvocation.MyCommand.Definition;
    #Copy-Item $sshItemLocation -Destination "C:\Users\VssAdministrator\.ssh" -Recurse

	#Write-Host "Copy ssh item manually to C:\Users\VssAdministrator\.ssh" $MixProjLocation;
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
		$RemoteURL = "https://${OrganizationName}:$PAT@$DevOPSDomain/$OrganizationName/$ProjectName/_git/$ReposName"
		$PRResponseURL = "https://$DevOPSDomain/$OrganizationName/$ProjectName/_apis/git/repositories/$ReposName/pullrequests?api-version=5.0"
    
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

#Run the script tasks
. ((Split-Path $MyInvocation.InvocationName) + $ScriptFolder + $ExcutePSFile);
RunDynamicPSTasks $ScriptFolder;

#Run Azure Git commit and push operations to spesified Repo
$AzureRepoName="Demo-SupportContent-Public-RP";
$CloneRepo="https://ChloeQian123:f5yvvtkgvu5r6d5feyqpmojwxdgkvjyese33vq2xspb6fve3kgqa@dev.azure.com/ChloeQian123/ChloeQian123.github.io/_git/Demo-SupportContent-Public-RP";
$AzureRepoPushUrl="https://ChloeQian123:f5yvvtkgvu5r6d5feyqpmojwxdgkvjyese33vq2xspb6fve3kgqa@dev.azure.com/ChloeQian123/ChloeQian123.github.io/_git/Demo-SupportContent-Public-RP";
PushtoRemote $CloneRepo $AzureRepoPushUrl $AzureRepoName;
#PubulishDynamicContent $PAT $OrganizationName $ProjectName $ReposName;

#Push to Github
$GithubRepoName="TestSyncFromAzure3";
$CloneRepo="https://github.com/ChloeQian123/TestSyncFromAzure3.git";
$GithubRepoPushUrl="https://ChloeQian123:8a1458c5c85e66d8a67fcaa94772183016910118@github.com/ChloeQian123/TestSyncFromAzure3.git";
PushtoRemote $CloneRepo $GithubRepoPushUrl $GithubRepoName;

