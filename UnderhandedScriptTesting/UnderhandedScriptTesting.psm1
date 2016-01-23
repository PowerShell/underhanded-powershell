<#
.SYNOPSIS
    Starts the Powershell ScriptAnalyzer job.
#>
Function Start-PssaJob
{

    param(
    [Parameter(Mandatory=$true, Position=1)]
    [string]$serviceUrl,

    [Parameter(Mandatory=$true, Position=2)]
    [string]$content,

    [Parameter(Mandatory=$true, Position=3)]
    [string]$username,

    [string]$email
    )
        
    $jobStartContent = "/api/Invoke"
    $serviceUrl = $serviceUrl + $jobStartContent;

    $contentBase64 = [System.Convert]::ToBase64String($content.ToCharArray());

    $result = Invoke-WebRequest -Method Post `
  	      		      -Uri $serviceUrl `
  			      -Body @{content=$contentBase64;
                            username=$username;
                            email=$email};

    if($result.StatusCode -ne 201)
    {
        Throw ("Cannot create the job: {0}" -f $result)
    }

    return((ConvertFrom-Json -InputObject $result.Content).id); 
}

<#
.SYNOPSIS
    Returns the current status (Enqueued, Running, Finished, Failed or Cancelled) of the job.
#>
Function Get-PssaJobStatus
{
  param(
    [string]$serviceUrl,
    [Guid]$id
    )	
  $jobStatus = "/api/status"
  $url = "{0}/{1}/{2}" -f ($serviceUrl, $jobStatus, $id)
  $result = Invoke-WebRequest -Method Get `
  	    		      -Uri $url
  return($result)
}

<#
.SYNOPSIS
    Returns the result returned by the ScriptAnalyzer job. 
#>
Function Get-PssasJobResult
{
  param(
    [string]$serviceUrl,
    [Guid]$id
    )    
  $jobResult = "/api/result"
  $url = $url = "{0}/{1}/{2}" -f ($serviceUrl, $jobResult, $id)
  $result = Invoke-RestMethod -Method Get `
                              -Uri $url
  return($result)
}

<#
.SYNOPSIS
    Stops the ScriptAnalyzer job.
#>
Function Stop-PssasJob
{
  param(
    [string]$serviceUrl,
    [Guid]$id
    )
  $jobStop = "/api/cancel"
  $url = $url = "{0}/{1}/{2}" -f ($serviceUrl, $jobStop, $id)
  $result = Invoke-WebRequest -Method Delete `
                              -Uri $url
  return($result)
}

<#
.SYNOPSIS
    Tests a script block for any suspicious code. 

.DESCRIPTION
    This function takes a script block and sends it to the remote server for analysis. The server runs an instance of ScriptAnalyzer with a special set of security rules. These rules are designed to check the ScriptBlock for any suspicious content. If it finds anything suspicious, it returns an IsSuspicous boolean flag wherein a True value indicates suspicious code and a False value indicates otherwise. 

.PARAMETER ScriptBlock
    Script block to be submitted for analysis. 

.PARAMETER Username
    Username of the entity submitting the script block. 

.PARAMETER ContactEmail
    Email address of the entity submitting the script block. (Please see the contest website for privacy related information.)

.EXAMPLE 
    PS> Test-IsUnderhandedPowerShell -ScriptBlock {.\foo.exe} -Username foo -ContactEmail foo@bar.foobar
    Tests the given script block for any suspicious code. 
    
#>
Function Test-IsUnderhandedPowerShell
{
    param(
        [Parameter(Mandatory=$true)]
        [ScriptBlock] $ScriptBlock,

        [Parameter(Mandatory=$true)]
        [String] $Username,

        [Parameter(Mandatory=$true)]
        [String] $ContactEmail
    )

    $ServiceUrl = 'https://underhanded-powershell.azurewebsites.net/'
    $timeoutInSec = 180    
    $pollIntervalInSec = 1    

    $ScriptContent = $ScriptBlock.ToString()
    $id  = Start-PssaJob -ServiceUrl $ServiceUrl `
                            -Content $ScriptContent `
                            -UserName $Username `
                            -email $ContactEmail   
    $timeout = New-TimeSpan -Seconds $timeoutInSec    
    $stopWatch = [System.Diagnostics.Stopwatch]::StartNew();
    while ($stopWatch.elapsed -le $timeout)
    {
        $jobStatusReq = Get-PssaJobStatus -ServiceUrl $serviceUrl -id $id 
        $jobStatusObj = ConvertFrom-Json $jobStatusReq
        $jobStatus = $jobStatusObj.status
        # Write-Host ("Job Status: " + $jobStatus)
        if ($jobStatus -in ("Enqueued", "Running"))
        {
            $percentComplete = 0
            if ($jobStatus -eq "Enqueued")
            {
                $percentComplete = 33                                
            }

            if ($jobStatus -eq "Running")
            {
                $percentComplete = 67                                
            }
            Write-Progress -Activity "Checking for possible underhanded code..." `
                            -Status $jobStatus `
                            -PercentComplete $percentComplete

            Start-Sleep -Seconds $pollIntervalInSec            
            continue
        }
        if ($jobStatus -eq "Finished")
        {
            Write-Progress -Activity "Checking for possible underhanded code..." `
                            -Status $jobStatus `
                            -PercentComplete 100                            

            $results = Get-PssasJobResult -ServiceUrl $serviceUrl -id $id
            Write-Host ("IsSuspicious: " + $results.IsSuspicious.ToString())
            break
        }
        if ($jobStatus -eq "Failed")
        {
            Write-Host ("Job failed because of " + $jobStatusObj.message + ".")
            break
        }
        if ($jobStatus -eq "Cancelled")
        {
            Write-Host "Job has been cancelled."
            break
        }
    }
    if ($stopWatch.elapsed -gt $timeout)
    {
        Write-Host "Timed out! Sorry, something isn't right. Please try again in a few minutes."       
    }
}

Export-ModuleMember -Function Test-IsUnderhandedPowerShell