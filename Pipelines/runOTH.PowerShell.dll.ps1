# Script to run on pipeline

Add-Type -AssemblyName System.Web.Extensions
$computerName = [System.Net.Dns]::GetHostName()
$EnvDir = "$Env:BUILD_SOURCESDIRECTORY"
if ($computerName -eq "DESKTOP-JB4B9G5") {
    $EnvDir = "E:\OTH_CODE\DEV.AZURE.COM\othdell210217gmailcom\TestDeploy"
}
Function LoadENVVariablesJSON() {
    $dicResults = @{}
    $dicResults.Add("SYSTEM_TEAMPROJECT", "$ENV:SYSTEM_TEAMPROJECT")
    $dicResults.Add("SYSTEM_TEAMFOUNDATIONSERVERURI", "$ENV:SYSTEM_TEAMFOUNDATIONSERVERURI")
    $dicResults.Add("SYSTEM_TEAMFOUNDATIONCOLLECTIONURI", "$ENV:SYSTEM_TEAMFOUNDATIONCOLLECTIONURI")
    $dicResults.Add("SYSTEM_COLLECTIONID", "$ENV:SYSTEM_COLLECTIONID")
    $dicResults.Add("SYSTEM_DEFAULTWORKINGDIRECTORY", "$ENV:SYSTEM_DEFAULTWORKINGDIRECTORY")
    $dicResults.Add("BUILD_DEFINITIONNAME", "$ENV:BUILD_DEFINITIONNAME")
    $dicResults.Add("BUILD_DEFINITIONVERSION", "$ENV:BUILD_DEFINITIONVERSION")
    $dicResults.Add("BUILD_BUILDNUMBER", "$ENV:BUILD_BUILDNUMBER")
    $dicResults.Add("BUILD_BUILDURI", "$ENV:BUILD_BUILDURI")
    $dicResults.Add("BUILD_BUILDID", "$ENV:BUILD_BUILDID")
    $dicResults.Add("BUILD_QUEUEDBY", "$ENV:BUILD_QUEUEDBY")
    $dicResults.Add("BUILD_QUEUEDBYID", "$ENV:BUILD_QUEUEDBYID")
    $dicResults.Add("BUILD_REQUESTEDFOR", "$ENV:BUILD_REQUESTEDFOR")
    $dicResults.Add("BUILD_REQUESTEDFORID", "$ENV:BUILD_REQUESTEDFORID")
    $dicResults.Add("BUILD_SOURCEVERSION", "$ENV:BUILD_SOURCEVERSION")
    $dicResults.Add("BUILD_SOURCEBRANCH", "$ENV:BUILD_SOURCEBRANCH")
    $dicResults.Add("BUILD_SOURCEBRANCHNAME", "$ENV:BUILD_SOURCEBRANCHNAME")
    $dicResults.Add("BUILD_REPOSITORY_NAME", "$ENV:BUILD_REPOSITORY_NAME")
    $dicResults.Add("BUILD_REPOSITORY_PROVIDER", "$ENV:BUILD_REPOSITORY_PROVIDER")
    $dicResults.Add("BUILD_REPOSITORY_CLEAN", "$ENV:BUILD_REPOSITORY_CLEAN")
    $dicResults.Add("BUILD_REPOSITORY_URI", "$ENV:BUILD_REPOSITORY_URI")
    $dicResults.Add("BUILD_REPOSITORY_TFVC_WORKSPACE", "$ENV:BUILD_REPOSITORY_TFVC_WORKSPACE")
    $dicResults.Add("BUILD_REPOSITORY_TFVC_SHELVESET", "$ENV:BUILD_REPOSITORY_TFVC_SHELVESET")
    $dicResults.Add("BUILD_REPOSITORY_GIT_SUBMODULECHECKOUT", "$ENV:BUILD_REPOSITORY_GIT_SUBMODULECHECKOUT")
    $dicResults.Add("AGENT_NAME", "$ENV:AGENT_NAME")
    $dicResults.Add("AGENT_ID", "$ENV:AGENT_ID")
    $dicResults.Add("AGENT_HOMEDIRECTORY", "$ENV:AGENT_HOMEDIRECTORY")
    $dicResults.Add("AGENT_ROOTDIRECTORY", "$ENV:AGENT_ROOTDIRECTORY")
    $dicResults.Add("AGENT_WorkFolder", "$ENV:AGENT_WorkFolder")
    $dicResults.Add("BUILD_REPOSITORY_LOCALPATH", "$ENV:BUILD_REPOSITORY_LOCALPATH")
    $dicResults.Add("BUILD_SOURCESDIRECTORY", "$ENV:BUILD_SOURCESDIRECTORY")
    $dicResults.Add("BUILD_ARTIFACTSTAGINGDIRECTORY", "$ENV:BUILD_ARTIFACTSTAGINGDIRECTORY")
    $dicResults.Add("BUILD_STAGINGDIRECTORY", "$ENV:BUILD_STAGINGDIRECTORY")
    $dicResults.Add("AGENT_BUILDDIRECTORY", "$ENV:AGENT_BUILDDIRECTORY")
    $dicResults.Add("SYSTEM_DEFINITIONID", "$ENV:SYSTEM_DEFINITIONID")
    $dicResults.Add("SYSTEM_ACCESSTOKEN", "$ENV:SYSTEM_ACCESSTOKEN")
    return ($dicResults | ConvertTo-Json)
}

$bytes = [System.IO.File]::ReadAllBytes($EnvDir + '\OTH.PowerShell.dll')
$assemblyOTHPowerShellLib = [System.Reflection.Assembly]::Load($bytes)
Write-Output($assemblyOTHPowerShellLib.FullName)

$bytes = [System.IO.File]::ReadAllBytes($EnvDir + '\Newtonsoft.Json.dll')
$assemblyNewtonJsonLib = [System.Reflection.Assembly]::Load($bytes)
Write-Output($assemblyNewtonJsonLib.FullName)

$bytes = [System.IO.File]::ReadAllBytes($EnvDir + '\RestSharp.dll')
$assemblyRestSharpLib = [System.Reflection.Assembly]::Load($bytes)
Write-Output($assemblyRestSharpLib.FullName)

$eNVVariablesJSON = LoadENVVariablesJSON
$runPipeline = [OTH.PowerShell.OCall]::RunPipeline($EnvDir, $eNVVariablesJSON)
Write-Output( $runPipeline)
