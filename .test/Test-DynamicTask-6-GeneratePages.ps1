param($Server, $Database, $UserName, $Password)  # call like this . .\DynamicTask-6-GeneratePages.ps1 'csswiki.database.windows.net' 'CSSWikiDynamicDB' 'UserName' 'Password'

#. "$PSScriptRoot\Common.ps1"

#if (IsNull($Server)) {$Server = $env:Server;}
#if (IsNull($Database))  {$Database = $env:Database;}
#if (IsNull($UserName))  {$UserName = $env:UserName;}
#if (IsNull($Password))  {$Password = $env:Password;}

#write-host $Server
#write-host $Database
#write-host $UserName

$CurrentyDir = Split-Path -Parent $MyInvocation.MyCommand.Definition;
$CWDir= Split-Path -Parent $CurrentyDir;

#$SqlConn = New-Object System.Data.SqlClient.SqlConnection
#$SqlConn.ConnectionString = "Data Source=$Server;Initial Catalog=$Database;user id=$UserName;pwd=$Password;"

Write-Host "ProjectDir"： $CWDir;
Write-Host "ObjectDir"： $CurrentyDir;
#init param in local
<#
$env:WikiName="AzureVMPod";
$env:OrganizationName= "Supportability";
$env:ProjectName= "AzureVMPod";
$env:PAT= "4wkuiqj64xlyym6y52wnefq3lypbmrj2kuimc5ksv24cnbsng3kq";
#>


$OrganizationName = $env:OrganizationName
$ProjectName = $env:ProjectName
$DevOPSDomain = "dev.azure.com"
$wikiIdentifier=$env:WikiName;
$PAT = $env:PAT
$WikiResponseURL = "https://$DevOPSDomain/$OrganizationName/$ProjectName/_apis/wiki/wikis/wikiIdentifier/pages?path=pagePath&api-version=5.1-preview.1"

function GetPageID() {
    try
    {
        $createPRResponse = Invoke-RestMethod -Method GET `
        -Uri $WikiResponseURL `
        -ContentType "application/json" `
        -Headers @{"Authorization" = "Basic $encodedPAT"} `
 
       return $createPRResponse.id;
   }
  catch
    {
       
    }   
}

function GetPageIDByPagePath($pageURL){
        $WikiResponseURL=$WikiResponseURL.Replace("wikiIdentifier",$wikiIdentifier)
        $WikiResponseURL=$WikiResponseURL.Replace("path=pagePath","path="+$pageURL)
        $encodedPAT = [Convert]::ToBase64String([System.Text.ASCIIEncoding]::ASCII.GetBytes(":" + $PAT))
        $pageID=GetPageID;
        if($pageId.Length -gt 0 ) {
            $pageID="pageId="+$pageID
        } else {
            #$pageID="pagePath="+$pageURL
            $pageID=GetPageIDByPaghPathFromDB $pageURL
            if ($pageId.Length -gt 0 ){
                $pos=$pageId.IndexOf(',')
                $pageIdValue=$pageId.SubString(0,$pos)
                if ($pageIdValue.Length -gt 1 ) {
                     $pageID="pageId="+$pageIdValue
                } else {
                    $pageID="pagePath="+$pageID.SubString($pos+1);
                }
                
            } else {
                $pageID="pagePath="+$pageURL
            }
        }
        return $pageID;
}

function GetPageIDByPaghPathFromDB($pageURL){
$sql="select top 1 PageID,Project from pagetag where PageURL='"+$pageURL.Replace(" ","-").Replace("'","''")+"' and pageid<>''"
$dtPageID=ExecuteSQL $sql $SqlConn;
    if ($dtPageID.Table.Rows.Count -eq 1){
       return $dtPageID.Table.Rows[0][0]+","+$dtPageID.Table.Rows[0][1];
    }
return "";
}

Function Main() {
    $splitDir=$CurrentyDir+"\.split\";
    SplitContent($splitDir);

}

#Exclude inner content
Function SplitContent($SplitDir){
     $fileList = Get-ChildItem -Path $SplitDir -Filter *.md;
	 foreach ($file in $fileList) {
	    $fileContent= Get-Content $file.FullName ;
		Write-Host "File Name: " $file.FullName ;
        Write-Host "File Content Before: " $fileContent ;
		Write-Host "Start Parsing ...";

        #$contentTest1= $contentBefore | ForEach-Object {$_.Split("\n")};
		#$contentBefore | ForEach-Object { Add-Content $file.FullName -Value "This is line $_." };
		
		$fileContent | ForEach-Object { 		
		  $rowcontent = $_.tostring();
		  Write-Host "rowcontent: " $rowcontent;
		  Write-Host "length: " $rowcontent.length;		  
		  Write-Host "trimcontent: " $rowcontent.Trim(" ");
		  if($rowcontent.Trim(" ").length -ge 2){
		    Write-Host "first 3 chars: " $rowcontent.Trim(" ").SubString(0,2);		
		    if($rowcontent.Trim(" ").SubString(0,2) -eq ":::"){ 
		      Write-Host "This row start with ':::', which is defined as private content.";
		      $fileContent.Replace($rowcontent,"");}}		    
		};

		#Add-Content $file.FullName -Value "This is a test section! 1122-3" ;
		Write-Host "File Content After: " $fileContent ;
	  }
}

 Function GetWikiName($fullName){
    $pos=$fullName.LastIndexOf("CWQL\");
    $wikiName= $fullName.SubString($pos+5)
    $pos=$wikiName.IndexOf("\");
    $wikiName=$wikiName.SubString(0,$pos);
    return $wikiName; 
 }

 #Generate Page for 1 column
 Function GeneratePage($DataTables,$ProjectName1){
    $htmlFirst="<table><colgroup><col style='width: 100%' /></colgroup><tbody><tr class='odd'><td style='vertical-align:top'><div style='background: #E4F0F7; padding: 5px; margin: 3px; font-weight: bold; text-align: center; color: #033251; font-size: 120%;'>"+
                $ContentCell+"</div><div style='padding-left: 1em;'><ul>";
    $htmlLast="</ul></div></td></tr></tbody></table>"
    $DataTable=$DataTables[0];
    foreach ($row in $DataTable) {
           $pageIdValue = GetPageIDByPagePath $row.PageURL.Replace("-"," ");
           $html+="<li><a href='https://"+$OrganizationName+".visualstudio.com/"+$ProjectName+"/_wiki/wikis/"+$wikiName+"?wikiVersion=GBmaster&" + 
           $pageIdValue +"' title='"+$row.PageName+"'>"+$row.PageName.Replace("curated%3A","").Replace("%2D","-").Replace("-"," ")+"</a></li> "
    }
    $html= $htmlFirst+$html+ $htmlLast;
    $mdFile=$CWDir+"\"+$wikiName+"\.templates\CWQLContent\"+$directoryName+"\";
    If(-not(test-path $mdFile)){
        New-Item $mdFile -type Directory 
    }
    $mdFile=$mdFile+$fileName+".md";

    $html|Out-File  $mdFile;
 }

 #Generate Page for 2 columns
 #Function GeneratePageCol2($DataTables1, $DataTables2){ #if use param the $DataTables2 will null
 Function GeneratePageCol2 {
    $htmlFirst="<table><colgroup><col style='width: 50%' /><col style='width: 50%'/></colgroup><tbody><tr class='odd'><td style='vertical-align:top'><div style='background: #E4F0F7; padding: 5px; margin: 3px; font-weight: bold; text-align: center; color: #033251; font-size: 120%;'>"+
                $ContentCell+"</div><div style='padding-left: 1em;'><ul>";
    $htmlLast="</ul></div></td></tr></tbody></table>"
    #$DataTable=$DataTables[0];
    foreach ($row in $DataTable1) {
           $pageIdValue = GetPageIDByPagePath $row.PageURL.Replace("-"," ");
           $html+="<li><a href='https://"+$OrganizationName+".visualstudio.com/"+$ProjectName+"/_wiki/wikis/"+$wikiName+"?wikiVersion=GBmaster&"+
           $pageIdValue +"' title='"+$row.PageName+"'>"+$row.PageName.Replace("curated%3A","").Replace("%2D","-").Replace("-"," ")+"</a></li> "
    }
    $html+="</ul></div></td><td style='vertical-align:top'><div style='background: #E4F0F7; padding: 5px; margin: 3px; font-weight: bold; text-align: center; color: #033251; font-size: 120%;'>"+
            $ContentCell2+"</div><div style='padding-left: 1em;'><ul>";
    foreach ($row in $DataTable2) {
           $pageIdValue = GetPageIDByPagePath $row.PageURL.Replace("-"," ");
           $ProjectNameOther = $ProjectName;
           $pos = $pageIdValue.IndexOf(",");
           if ($pos -gt "-1") {
                $ProjectNameOther=$pageIdValue.SubString($pos+1);
                $pageIdValue= $pageIdValue.SubString(0,$pos);
           }
           $html+="<li><a href='https://"+$OrganizationName+".visualstudio.com/"+$ProjectNameOther+"/_wiki/wikis/"+$wikiName+"?wikiVersion=GBmaster&"+
           $pageIdValue +"' title='"+$row.PageName+"'>"+$row.PageName.Replace("curated%3A","").Replace("%2D","-").Replace("-"," ")+"</a></li> "
    }
    $html= $htmlFirst+$html+ $htmlLast;
    $mdFile=$CWDir+"\"+$wikiName+"\.templates\CWQLContent\"+$directoryName+"\";
    If(-not(test-path $mdFile)){
        New-Item $mdFile -type Directory 
    }
    $mdFile=$mdFile+$fileName.Replace("_2col2","")+".md";

    $html|Out-File  $mdFile;
 }

 #Generate Page for 3 columns
 Function GeneratePageCol3{

    $htmlFirst="<table><colgroup><col style='width: 33%' /><col style='width: 33%'/><col style='width: 33%'/></colgroup><tbody><tr class='odd'><td style='vertical-align:top'><div style='background: #E4F0F7; padding: 5px; margin: 3px; font-weight: bold; text-align: center; color: #033251; font-size: 120%;'>"+
                $ContentCell+"</div><div style='padding-left: 1em;'><ul>";
    $htmlLast="</ul></div></td></tr></tbody></table>"
    foreach ($row in $DataTable1) {
           $pageIdValue = GetPageIDByPagePath $row.PageURL.Replace("-"," ");
           $html+="<li><a href='https://"+$OrganizationName+".visualstudio.com/"+$ProjectName+"/_wiki/wikis/"+$wikiName+"?wikiVersion=GBmaster&"+
           $pageIdValue+"' title='"+$row.PageName+"'>"+$row.PageName.Replace("curated%3A","").Replace("%2D","-").Replace("-"," ")+"</a></li> "
    }
    $html+="</ul></div></td><td style='vertical-align:top'><div style='background: #E4F0F7; padding: 5px; margin: 3px; font-weight: bold; text-align: center; color: #033251; font-size: 120%;'>"+
            $ContentCell2+"</div><div style='padding-left: 1em;'><ul>";
    foreach ($row in $DataTable2) {
           $pageIdValue = GetPageIDByPagePath $row.PageURL.Replace("-"," ");
           $html+="<li><a href='https://"+$OrganizationName+".visualstudio.com/"+$ProjectName+"/_wiki/wikis/"+$wikiName+"?wikiVersion=GBmaster&"+
           $pageIdValue+"' title='"+$row.PageName+"'>"+$row.PageName.Replace("curated%3A","").Replace("%2D","-").Replace("-"," ")+"</a></li> "
    }
    $html+="</ul></div></td><td style='vertical-align:top'><div style='background: #E4F0F7; padding: 5px; margin: 3px; font-weight: bold; text-align: center; color: #033251; font-size: 120%;'>"+
            $ContentCell3+"</div><div style='padding-left: 1em;'><ul>";
    foreach ($row in $DataTable3) {
           $pageIdValue = GetPageIDByPagePath $row.PageURL.Replace("-"," ");
           $html+="<li><a href='https://"+$OrganizationName+".visualstudio.com/"+$ProjectName+"/_wiki/wikis/"+$wikiName+"?wikiVersion=GBmaster&"+
           $pageIdValue+"' title='"+$row.PageName+"'>"+$row.PageName.Replace("curated%3A","").Replace("%2D","-").Replace("-"," ")+"</a></li> "
    }
    $html= $htmlFirst+$html+ $htmlLast;  
    $mdFile=$CWDir+"\"+$wikiName+"\.templates\CWQLContent\"+$directoryName+"\";
    If(-not( test-path $mdFile)){
        New-Item $mdFile -type Directory 
    }
    $mdFile=$mdFile+$fileName.Replace("_3col3","")+".md";

    $html|Out-File  $mdFile;
 }

 #Generate Page for 4 columns
 Function GeneratePageCol4{

    $htmlFirst="<table><colgroup><col style='width: 25%' /><col style='width: 25%'/><col style='width: 25%'/><col style='width: 25%'/></colgroup><tbody><tr class='odd'><td style='vertical-align:top'><div style='background: #E4F0F7; padding: 5px; margin: 3px; font-weight: bold; text-align: center; color: #033251; font-size: 120%;'>"+
                $ContentCell+"</div><div style='padding-left: 1em;'><ul>";
    $htmlLast="</ul></div></td></tr></tbody></table>"
    foreach ($row in $DataTable1) {
           $pageIdValue = GetPageIDByPagePath $row.PageURL.Replace("-"," ");
           $html+="<li><a href='https://"+$OrganizationName+".visualstudio.com/"+$ProjectName+"/_wiki/wikis/"+$wikiName+"?wikiVersion=GBmaster&"+
           $pageIdValue+"' title='"+$row.PageName+"'>"+$row.PageName.Replace("curated%3A","").Replace("%2D","-").Replace("-"," ")+"</a></li> "
    }
    $html+="</ul></div></td><td style='vertical-align:top'><div style='background: #E4F0F7; padding: 5px; margin: 3px; font-weight: bold; text-align: center; color: #033251; font-size: 120%;'>"+
            $ContentCell2+"</div><div style='padding-left: 1em;'><ul>";
    foreach ($row in $DataTable2) {
           $pageIdValue = GetPageIDByPagePath $row.PageURL.Replace("-"," ");
           $html+="<li><a href='https://"+$OrganizationName+".visualstudio.com/"+$ProjectName+"/_wiki/wikis/"+$wikiName+"?wikiVersion=GBmaster&"+
           $pageIdValue+"' title='"+$row.PageName+"'>"+$row.PageName.Replace("curated%3A","").Replace("%2D","-").Replace("-"," ")+"</a></li> "
    }
    $html+="</ul></div></td><td style='vertical-align:top'><div style='background: #E4F0F7; padding: 5px; margin: 3px; font-weight: bold; text-align: center; color: #033251; font-size: 120%;'>"+
            $ContentCell3+"</div><div style='padding-left: 1em;'><ul>";
    foreach ($row in $DataTable3) {
           $pageIdValue = GetPageIDByPagePath $row.PageURL.Replace("-"," ");
           $html+="<li><a href='https://"+$OrganizationName+".visualstudio.com/"+$ProjectName+"/_wiki/wikis/"+$wikiName+"?wikiVersion=GBmaster&"+
           $pageIdValue+"' title='"+$row.PageName+"'>"+$row.PageName.Replace("curated%3A","").Replace("%2D","-").Replace("-"," ")+"</a></li> "
    }
    $html+="</ul></div></td><td style='vertical-align:top'><div style='background: #E4F0F7; padding: 5px; margin: 3px; font-weight: bold; text-align: center; color: #033251; font-size: 120%;'>"+
            $ContentCell4+"</div><div style='padding-left: 1em;'><ul>";
    foreach ($row in $DataTable4) {
           $pageIdValue = GetPageIDByPagePath $row.PageURL.Replace("-"," ");
           $html+="<li><a href='https://"+$OrganizationName+".visualstudio.com/"+$ProjectName+"/_wiki/wikis/"+$wikiName+"?wikiVersion=GBmaster&"+
           $pageIdValue+"' title='"+$row.PageName+"'>"+$row.PageName.Replace("curated%3A","").Replace("%2D","-").Replace("-"," ")+"</a></li> "
    }
    $html= $htmlFirst+$html+ $htmlLast;
    $mdFile=$CWDir+"\"+$wikiName+"\.templates\CWQLContent\"+$directoryName+"\";
    If(-not( test-path $mdFile)){
        New-Item $mdFile -type Directory 
    }
    $mdFile=$mdFile+$fileName.Replace("_4col4","")+".md";

    $html|Out-File  $mdFile;
 }

  #Generate Page for 1 PageUpdateHistory table
 Function GeneratePageUpdateHistory($DataTable){
    $htmlFirst="<table><colgroup><col style='width: 100%' /></colgroup><tbody><tr class='odd'><td style='vertical-align:top'><div style='background: #E4F0F7; padding: 5px; margin: 3px; font-weight: bold; text-align: center; color: #033251; font-size: 120%;'>"+
                $ContentCell+"</div><div style='padding-left: 1em;'><ul>";
    $htmlLast="</ul></div></td></tr></tbody></table>"
    foreach ($row in $DataTable) {
            if ( IsNull( $row.RelativePath)) { continue;}
            $displayRelativePath=$row.RelativePath.Replace("curated%3A","").Replace("%2D","-").Replace("-"," ");
            $pos=$displayRelativePath.LastIndexOf("/");
            if ($pos -ne "-1") {
                $displayRelativePath=$displayRelativePath.SubString($pos+1); # remove directory
            }
             $pageIdValue = GetPageIDByPagePath $row.RelativePath.Replace("-"," ").Replace("'","''");
           $html+="<li><a href='https://"+$OrganizationName+".visualstudio.com/"+$ProjectName+"/_wiki/wikis/"+$wikiName+"?wikiVersion=GBmaster&"+
           $pageIdValue +"' title='"+$row.RelativePath+"'>"+$displayRelativePath+"</a> - "+ $row.UpdateEmail +" - "+  $row.UpdateDate +"</li> "
    }
    $html= $htmlFirst+$html+ $htmlLast;
    $mdFile=$CWDir+"\"+$wikiName+"\.templates\CWQLContent\"+$directoryName+"\";
    If(-not(test-path $mdFile)){
        New-Item $mdFile -type Directory 
    }
    $mdFile=$mdFile+$fileName+".md";

    $html|Out-File  $mdFile;
 }

 Function GetSQLFromContent($content){
    if (IsNull($content)) {return  $content;}
    $pos=$content.IndexOf("SQL: `"");
    return $content.SubString($pos+6).Replace("`"","")
 }

 Function GetContentCellFromContent($content){
    $pos=$content.IndexOf("`"");
    $pos2=$content.SubString($pos+1).IndexOf("`"");
    return $content.SubString($pos+1,$pos2-$pos1);
 }

 Function GeneratePages($CWQLDir){
    $allFiles = Get-ChildItem -Path $CWQLDir -Filter *.cwql -Recurse 
    $colFlag=0;
    foreach ($file in $allFiles) {
        $wikiName=GetWikiName($file.FullName)
       if ($wikiName -eq "") {continue;}
       if ( -not (IsNull($env:WikiName)) -and ( $wikiName -ne $env:WikiName)) {continue;}

       $fileName=$file.Name.Replace(".cwql","");
       $directoryName=$file.DirectoryName;
       $pos=$directoryName.IndexOf($wikiName)+$wikiName.Length;
       $length=$directoryName.Length
       if ($length -gt $pos) { 
            $directoryName=$directoryName.SubString($pos+1);
       } else {
            $directoryName=$directoryName.SubString($pos);
       }

       #if ( $fileName -ne "Linux-VM_2col1" -and $fileName -ne "Linux-VM_2col2") {continue;}
       #if ( $fileName -ne "Extension-HowTo" ) {continue;}

       if ($fileName.EndsWith("2col1") -or $fileName.EndsWith("2col2") ){
            $content = Get-Content $file.FullName -Raw;
            if(IsNull($content)) {continue;}
            $CWQL=GetSQLFromContent($content);
            $file.FullName;

            if ($colFlag -eq 0){
                $DataTable1=ExecuteSQL $CWQL $SqlConn;
                $ContentCell=GetContentCellFromContent($content);
            }
            else {
                $DataTable2=ExecuteSQL $CWQL $SqlConn;
                $ContentCell2=GetContentCellFromContent($content);
            }
            $colFlag++;
            if ($colFlag -eq 2){
                $colFlag=0;
                GeneratePageCol2($DataTable1, $DataTable2);
            }
       } 
       elseif ($fileName.EndsWith("3col1") -or $fileName.EndsWith("3col2") -or $fileName.EndsWith("3col3") ){
            $content = Get-Content $file.FullName -Raw;
            if(IsNull($content)) {continue;}
            $CWQL=GetSQLFromContent($content);
            $file.FullName;

            if ($colFlag -eq 0){
                $DataTable1=ExecuteSQL $CWQL $SqlConn;
                $ContentCell=GetContentCellFromContent($content);
            }
            elseif ($colFlag -eq 1) {
                $DataTable2=ExecuteSQL $CWQL $SqlConn;
                $ContentCell2=GetContentCellFromContent($content);
            }
            else {
                $DataTable3=ExecuteSQL $CWQL $SqlConn;
                $ContentCell3=GetContentCellFromContent($content);
            }
            $colFlag++;
            if ($colFlag -eq 3){
                $colFlag=0;
                GeneratePageCol3($DataTable1, $DataTable2, $DataTable3);
            }
       }
       elseif ($fileName.EndsWith("4col1") -or $fileName.EndsWith("4col2") -or $fileName.EndsWith("4col3")-or $fileName.EndsWith("4col4") ){
            $content = Get-Content $file.FullName -Raw;
            if(IsNull($content)) {continue;}
            $CWQL=GetSQLFromContent($content);
            $file.FullName;

            if ($colFlag -eq 0){
                $DataTable1=ExecuteSQL $CWQL $SqlConn;
                $ContentCell=GetContentCellFromContent($content);
            }
            elseif ($colFlag -eq 1) {
                $DataTable2=ExecuteSQL $CWQL $SqlConn;
                $ContentCell2=GetContentCellFromContent($content);
            }
            elseif ($colFlag -eq 2) {
                $DataTable3=ExecuteSQL $CWQL $SqlConn;
                $ContentCell3=GetContentCellFromContent($content);
            }
            else {
                $DataTable4=ExecuteSQL $CWQL $SqlConn;
                $ContentCell4=GetContentCellFromContent($content);
            }
            $colFlag++;
            if ($colFlag -eq 4){
                $colFlag=0;
                GeneratePageCol4($DataTable1, $DataTable2, $DataTable3, $DataTable4);
            }
       }
       else {
            $content = Get-Content $file.FullName -Raw;
            if(IsNull($content)) {continue;}
           $content=$content.Replace("Â ","");
            $CWQL=GetSQLFromContent($content);
            
            $ContentCell=GetContentCellFromContent($content);
            $file.FullName;
            $DataTables=ExecuteSQL $CWQL $SqlConn;
            if ($CWQL.Contains("PageUpdateHistory")){
                GeneratePageUpdateHistory($DataTables);
            } else {
                GeneratePage($DataTables,$wikiName);
            }
        }
    }
 }

Main;
Write-Host "---------------------------Compete-----------------------";

 

 