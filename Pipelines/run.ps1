# Script to upload file to Gbucket

Add-Type -AssemblyName System.Web.Extensions
$computerName = [System.Net.Dns]::GetHostName()
$EnvDir = "$Env:BUILD_SOURCESDIRECTORY"
if ($computerName -eq "DESKTOP-JB4B9G5") {
    $EnvDir = "E:\OTH_CODE\DEV.AZURE.COM\othdell210217gmailcom\TestDeploy"
}
$bytes = [System.IO.File]::ReadAllBytes($EnvDir + '\OTH.PowerShell.dll')
[System.Reflection.Assembly]::Load($bytes)
$optionPipline = [OTH.PowerShell.OCall]::ReadconfigPipelineOrNew($EnvDir + "\Pipelines\configPipeline.json")
Write-Output($optionPipline)
Class FileAssemblyInfo {
    [String]$OriginalFilename
    [String]$AssemblyFullName
    [String]$AssemblyFullNameMD5
    [String]$AssemblyFullNameSHA1
    [String]$AssemblyName
    [String]$AssemblyVersion
    [String]$AssemblyProcessorArchitecture
    [String]$AssemblyImageRuntimeVersion
    [String]$GetVersionInfoFileVersion
    [String]$GetVersionInfoFileDescription
    [String]$FileHashMD5
    [String]$FileHashSHA1
    [String]$FileLength
    [Boolean]$IsMainExe
}
Class DeployExe {
    [String]$Name
    [String]$Version
    [String]$DateCreate
    [Int32]$CountFileAssemblyInfo
    [System.Collections.Generic.List[String]]$Descriptions
    [FileAssemblyInfo]$MainFileAssemblyInfo
    [System.Collections.Generic.List[FileAssemblyInfo]]$FileAssemblyInfos
}
Class EnvLocal {
    [String]$RootPathDir
}
Class EnvAzure {
    [String]$RootPathDir
}
Class EnvRunning {
    [String]$RootPathDir
}
Class Target {
    [String]$KeyMail
    [String]$GBucket    
}
Class configPipeline {
    [System.Collections.Generic.List[Target]]$Targets
    [EnvLocal]$EnvLocal
    [EnvAzure]$EnvAzure
    [EnvRunning]$EnvRunning
}
Function ReadconfigPipeline() {
    $pathFile_config = $EnvDir + "\Pipelines\configPipeline.json"
    Write-Output($pathFile_config)
    $serializer = [System.Web.Script.Serialization.JavaScriptSerializer]::new()
    $config = $serializer.Deserialize((Get-Content -Path $pathFile_config), [OTH.PowerShell.Entities.configPipeline])
    $config | ConvertTo-Json;
    # if ($computerName -eq "DESKTOP-JB4B9G5") {
    #     $config.EnvRunning.RootPathDir = $config.EnvLocal.RootPathDir;
    # }
    # else {
    #     $config.EnvRunning.RootPathDir = "$Env:BUILD_SOURCESDIRECTORY";
    # }
    return $config
}
$configPipeline = ReadconfigPipeline
$configPipeline | ConvertTo-Json;
Function Get-StringHashMD5($String) {    

    $stringAsStream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.StreamWriter]::new($stringAsStream)
    $writer.write($String)
    $writer.Flush()
    $stringAsStream.Position = 0
    $result = Get-FileHash -InputStream $stringAsStream -Algorithm MD5 | Select-Object -ExpandProperty Hash
    return $result
}
Function Get-StringHashSHA1($String) {    

    $stringAsStream = [System.IO.MemoryStream]::new()
    $writer = [System.IO.StreamWriter]::new($stringAsStream)
    $writer.write($String)
    $writer.Flush()
    $stringAsStream.Position = 0
    $result = Get-FileHash -InputStream $stringAsStream -Algorithm SHA1 | Select-Object -ExpandProperty Hash
    return $result
}
Function Get-AssemblyOfFile($pathSourceFile) {
    $objResult = New-Object -TypeName "FileAssemblyInfo" -Property @{
        OriginalFilename              = [System.IO.Path]::GetFileName($pathSourceFile)
        FileHashMD5                   = Get-FileHash $pathSourceFile -Algorithm MD5 | Select-Object -ExpandProperty Hash
        FileHashSHA1                  = Get-FileHash $pathSourceFile -Algorithm SHA1 | Select-Object -ExpandProperty Hash
        FileLength                    = (Get-Item $pathSourceFile).length
        IsMainExe                     = $false
        AssemblyFullName              = ""
        AssemblyFullNameMD5           = ""
        AssemblyFullNameSHA1          = ""
        AssemblyName                  = ""
        AssemblyVersion               = ""
        AssemblyProcessorArchitecture = ""
        AssemblyImageRuntimeVersion   = ""
        GetVersionInfoFileVersion     = ""
        GetVersionInfoFileDescription = ""
    }
    #Thông tin assembly
    try {  
        $Assembly = [Reflection.Assembly]::Load([System.IO.File]::File.ReadAllBytes($pathSourceFile))
        $AssemblyGetName = $Assembly.GetName()

        $objResult.AssemblyFullName = $Assembly.FullName
        $objResult.AssemblyFullNameMD5 = Get-StringHashMD5($Assembly.FullName)
        $objResult.AssemblyFullNameSHA1 = Get-StringHashSHA1($Assembly.FullName)
        $objResult.AssemblyName = $AssemblyGetName.Name
        $objResult.AssemblyVersion = $AssemblyGetName.Version
        $objResult.AssemblyProcessorArchitecture = $AssemblyGetName.ProcessorArchitecture
        $objResult.AssemblyImageRuntimeVersion = $Assembly.ImageRuntimeVersion
    }
    catch {
    }
    #Thông tin fileVersion
    try {
        $versionFileInfo = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($pathSourceFile)
        $objResult.GetVersionInfoFileVersion = $versionFileInfo.FileVersion
        $objResult.GetVersionInfoFileDescription = $versionFileInfo.FileDescription
    }
    catch {
    }
    return $objResult
}

Function Get-access_token($client_id, $client_secret, $refresh_token) {  
    $access_token = ''
    $body = '{
        "client_id": "'+ $client_id + '",
        "client_secret": "'+ $client_secret + '",
        "grant_type": "refresh_token",
        "refresh_token": "'+ $refresh_token + '"
    }'
    $urlPost = 'https://www.googleapis.com/oauth2/v4/token'
    $response = Invoke-RestMethod $urlPost -Method Post -Body $body -ContentType 'application/json'
    if ($response.scope.length -gt 1000) {
        $access_token = $response.access_token
    }
    return $access_token
}
Function Get-access_token_byGOAuth2($gOAuth2) {  
    $access_token = Get-access_token -client_id $gOAuth2.GOAuth2Owner.web.client_id -client_secret $gOAuth2.GOAuth2Owner.web.client_secret -refresh_token $gOAuth2.GOAuth2Owner.refresh_token
    if ($access_token -eq "") {
        $access_token = Get-access_token -client_id $gOAuth2.GOAuth2Other.web.client_id -client_secret $gOAuth2.GOAuth2Other.web.client_secret -refresh_token $gOAuth2.GOAuth2Other.refresh_token
    }
    return $access_token
}

class configFBs {
    [System.Collections.Generic.List[string]] $GOAuth2
    [System.Collections.Generic.List[string]] $GScriptDeploy
    [System.Collections.Generic.List[string]] $GArrayResources
    [System.Collections.Generic.List[string]] $GObjectResources
    [System.Collections.Generic.List[string]] $GStatusResourcesRTDB
}
Function ReadConfigFBs($pathFile_configFBsJSON) {
    $serializer = [System.Web.Script.Serialization.JavaScriptSerializer]::new()
    $configFBs = $serializer.Deserialize((Get-Content -Path $pathFile_configFBsJSON), [configFBs])
    return $configFBs
}
Function Get-AccessToken($keyMail) {   
    $pathFile = $configPipeline.EnvRunning.RootPathDir + "\Pipelines\configFBs.json"
    $configFBs = ReadConfigFBs -pathFile_configFBsJSON  $pathFile
    $fbUrl = $configFBs.GOAuth2[(Get-Date).Day].Replace("|", "/ClientGet/GOAuth2/" + $keyMail + ".json?auth=")
    $fbGOAuth2Data = Invoke-RestMethod -Uri $fbUrl
    return Get-access_token_byGOAuth2 -gOAuth2 $fbGOAuth2Data
}
Function UploadFileGBucket($keyMail, $pathFile, $gBucket) {
    $headers = New-Object "System.Collections.Generic.Dictionary[[String],[String]]"
    $access_token = (Get-AccessToken -keyMail $keyMail)
    $headers.Add("Authorization", "Bearer " + $access_token)
    $headers.Add("Content-Type", "text/plain")
    $nameFile = [System.IO.Path]::GetFileName($pathFile)
    $urlPost = 'https://www.googleapis.com/upload/storage/v1/b/' + $gBucket + '/o?uploadType=media&name=OriginalFilenames/' + $nameFile + ''
    $response = Invoke-RestMethod $urlPost -Method 'POST' -Headers $headers -InFile $pathFile
    $response | ConvertTo-Json
}

Function SyncFiles() {
    $Include = "*.js", "*.dll", "*.exe"
    $pathDir = $configPipeline.EnvRunning.RootPathDir + '\*'
    $files = Get-ChildItem -Path $pathDir -Include $Include
    
    for ($i = 0; $i -lt $files.Count; $i++) {
        $pathFileUpload = $files[$i].FullName
        $assemblyOfFile = Get-AssemblyOfFile($pathFileUpload)

        Write-Output($pathFileUpload)
        $resultGBucket = UploadFileGBucket -keyMail $configPipeline.Targets[0].KeyMail -gBucket $configPipeline.Targets[0].GBucket -pathFile $pathFileUpload
        Write-Output $resultGBucket

        Write-Output($assemblyOfFile)
    }
}
SyncFiles