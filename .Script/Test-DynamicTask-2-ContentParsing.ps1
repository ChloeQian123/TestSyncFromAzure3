$CurrentyDir = Split-Path -Parent $MyInvocation.MyCommand.Definition;
$CWDir= Split-Path -Parent $CurrentyDir;

Write-Host "ProjectDir"： $CWDir;
Write-Host "ObjectDir"： $CurrentyDir;
$DocFolder = "\";

Function Main() {
    $splitDir=$CWDir+$DocFolder;
	Write-Host "splitDir"： $splitDir;
    SplitContent($splitDir);
}

#Exclude inner content
Function SplitContent($SplitDir){

     #$fileList = Get-ChildItem -Path $SplitDir -Filter *.md;
	 $fileListAll = Get-ChildItem -Path $SplitDir . -recurse;
	 $internalFileList = New-Object -TypeName System.Collections.ArrayList;
	 $internalFolderList = @{};
	 
	 #Parsing files	 
	 foreach ($file in $fileListAll) {
	    Write-Host "File Name: " $file.FullName ;
	    if($file.Attributes -match 'Directory'){
		  Write-Host "This is a Directory" $file.FullName ",will continue";
		  Continue;
		}

		#1 checking
		#1.1 checking keyword
		if($file.FullName.toLower().contains("asset-internal")){
		  Write-Host "Find keyword asset-internal in filepath" $file.FullName;
		  $key = $file.FullName.replace($file.Name,"");
		  $value = $key;
		  $internalFolderList.add( $key, $value );
		  if($internalFolderList.containskey($key)){ Write-Host "internalFolderList contains key:"$key;}
		  else{ Write-Host "internalFolderList does not contain key:"$key;}
		  Write-Host "This is an internal file, will skip and checking for next one." $file.FullName;
		  continue;
		}
		#1.2 checking md file
		if($file.FullName.endswith(".md")){
		  Write-Host "This is a md file." $file.FullName;
		}else{
		  Write-Host "This is not a md file, will skip and checking for next one." $file.FullName;
		  continue;
		}

		#2 parsing Tags
		Write-Host "Start Parsing ...";	 
		$fileContentbefore= Get-Content $file.FullName ;
		Write-Host "File Content Before: " $fileContentbefore ;			
		$arForUpdate = New-Object -TypeName System.Collections.ArrayList;
		Write-Host "Part II Tags:";
		$arMaching = New-Object -TypeName System.Collections.ArrayList;
        $arMatchedList = New-Object -TypeName System.Collections.ArrayList;
		$beginTag = "---";
	    $endTag = "---";
		$syntax = "mmc.confidentiality: internal";
		$rowCount =0;
		$isInternal=$false;

		$fileContentbefore | ForEach-Object { 
		  $rowCount++;
		  Write-Host "row" $rowCount "content:"$_;
		  $trimContent = $_.Trim();
		  if($trimContent -eq $beginTag){ 
		      Write-Host "Find begin tag" $beginTag "in row" $rowCount;
			  if($arMaching.Count -gt 0){
			  }else{
			    $beginTagObj= [PSCustomObject]@{
                tagName = $begintag
                rowNum = $rowCount
                };
			  $arMaching.Add($beginTagObj);
			  }
			  
		  }
		  if($trimContent -eq $endTag){		      
			  if($arMaching.Count -gt 0){
			    if($arMaching[$arMaching.Count-1].rowNum -eq $rowCount){
				}else{
				  Write-Host "Find end tag" $endtag "in row" $rowCount;
				  $matchedTagObj= [PSCustomObject]@{
                  beginTagName = $arMaching[$arMaching.Count-1].tagName
                  beginRowNum = $arMaching[$arMaching.Count-1].rowNum
				  endTagName = $endTag
				  endRowNum = $rowCount
			      };
			      $arMatchedList.Add($matchedTagObj);
			      $arMaching.remove($arMaching[$arMaching.Count-1]);
				
				}
		      }
		  }	
		};
		
		if($arMatchedList.Count -ge 1){
		  for($i=$arMatchedList[0].beginRowNum; $i -lt $arMatchedList[0].endRowNum ;$i++){
		    if($fileContentbefore[$i].Trim() -eq $syntax){
			  $isInternal=$true;
			  $internalFileList.Add($file.FullName);
			  Write-Host "content["$fileContentbefore[$i].Trim()"] matchs syntax["$syntax"], set isinternal" $isInternal; 
			}else{
				Write-Host "content["$fileContentbefore[$i].Trim()"] does not match syntax["$syntax"]";
			}
		  }
		}

		Write-Host "Part II Complete:";	

		if($isInternal){
		   Write-Host "["$file.FullName"] is an internal artical, will not be push to public.";	
		   continue;
		}

		#3 parsing content
	    #3.1 preparing
		Write-Host "Part III Content:";	

		#$arForUpdate = New-Object -TypeName System.Collections.ArrayList;
	    $arMaching = New-Object -TypeName System.Collections.ArrayList;
        $arMatchedList = New-Object -TypeName System.Collections.ArrayList;
	    $beginTag = "::: Confidentiality:Internal";
	    $endTag = ":::";
	    
		
		#3.2 matching syntax then add its row number to matched list
		$rowCount = 0;
		Get-Content -Path $file.FullName | ForEach-Object { 
		  $rowCount++;
		  Write-Host "row" $rowCount "content:"$_;
		  $trimContent = $_.Trim();
		  if($trimContent -eq $beginTag){ 
		      Write-Host "Find" $beginTag "in row" $rowCount;
			  $beginTagObj= [PSCustomObject]@{
                 tagName = $begintag
                 rowNum = $rowCount
              };
			  $arMaching.Add($beginTagObj);
		  }
		  if($trimContent -eq $endTag){
		      Write-Host "Find" $endtag "in row" $rowCount;
			  if($arMaching.Count -gt 0){
			    $matchedTagObj= [PSCustomObject]@{
                 beginTagName = $arMaching[$arMaching.Count-1].tagName
                 beginRowNum = $arMaching[$arMaching.Count-1].rowNum
				 endTagName = $endTag
				 endRowNum = $rowCount
			     };
			    $arMatchedList.Add($matchedTagObj);
			    $arMaching.remove($arMaching[$arMaching.Count-1]);
		      }
		  }		    
		};
		#check and remove the duplicate row interval 
		#for ($i=0; $i -lt $arMatchedList.Count; $i++){
		#   for($j=$arMatchedList.Count-1; $j -gt $i+1; $j--){
		#      if(($arMatchedList[$j].beginRowNum -lt $arMatchedList[$i].beginRowNum) -and ($arMatchedList[$j].endRowNum -gt $arMatchedList[$i].endRowNum)){
		#	    Write-Host "row"$arMatchedList[$i].beginRowNum "to" $arMatchedList[$i].endRowNum "is included in row" $arMatchedList[$j].beginRowNum "to" $arMatchedList[$j].endRowNum;
		#	  }
		#	  else{
		##	    $arForUpdate.Add($arMatchedList[$i]);
		#	  }
		#   }
		#}
		$arMatchedList|ForEach-Object {
		  $arForUpdate.Add($_)
		}
		$arForUpdate|ForEach-Object {
		  Write-Host $_;
		}


		#3.3 update content according to rownumber from update list
		$newcontent = $fileContentbefore;
		$arForUpdate[$arForUpdate.Count..0]|ForEach-Object {
		  $begin = $_.beginRowNum;
		  $end = $_.endRowNum;
		  $newcontent=$newcontent[0..($begin-2)]+$newcontent[($end)..$newcontent.count]
		}
		Write-Host "Set new content";
		Set-Content -Path $file.FullName -Value $newcontent;
		$fileContentafter= Get-Content $file.FullName;
		Write-Host "File Content After: " $fileContentafter ;		
		Write-Host "Part III Complete:";	
	 }

	 #remove internal files and folders
	 $internalFileList|ForEach-Object{
	   Write-Host "Remove internal file" $_;	
	   Remove-Item -Path $_ -Force
	 }
	 $internalFolderList.keys|ForEach-Object{
	   Write-Host "Remove internal folders and files" $internalFolderList[$_];	
	   Remove-Item -Path $internalFolderList[$_] -Recurse
	 }
}

Function CheckRowInterval($rowNum,$arr){

  $result = $false;
  for($i=0;$i -lt $arr.Count;$i++){
    $begin = $_.beginRowNum ;
	$end = $_.endRowNum ;	
    if(($rowNum -ge $begin)-and($rowNum -le $end)){
	  $result = $true;
	} 
	Write-Host "checking row" $rowNum ",beginRowNum is:" $begin "endRowNum is" $end ", result is $result" ;
  }
  
  return $result;
}


Main;
Write-Host "--------------------------- Content Parsing Compete ---------------------------";

 

 