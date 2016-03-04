# The Underhanded PowerShell Contest

-   [FAQ](http://github.com/powershell/underhanded-powershell/blob/master/FAQ.md)
-   [RULES](http://github.com/powershell/underhanded-powershell/blob/master/Rules.md)
-   [TERMS OF USE](http://underhanded-powershell.azurewebsites.net/TermsOfUse.html)
-   [STANDINGS](http://github.com/powershell/underhanded-powershell/blob/master/Current-Standings.md)

## About This Series

In an effort to improve the validation capability of PowerShell Script Analyzer, we are running a series of contests. We want you - the community members - to help us identify underhanded PowerShell scripts, and then create rules to catch them. There are specific areas where Script Analyzer rules are needed and we need your skills to help us hone them.

What's underhanded PowerShell code? Basically, code that is designed to do something the user would not intend, or takes actions that are not apparent to someone who would casually read the code.

We have set up a web service that runs PowerShell Script Analyzer with a set of preliminary rules that are designed to detect underhanded script code, along with a set of commands built into the [UnderhandedScriptTesting](https://github.com/PowerShell/underhanded-powershell/tree/master/UnderhandedScriptTesting) module that will work against that service.

## Submission Guidelines and Deadlines

Full [Rules](http://github.com/powershell/underhanded-powershell/blob/master/Rules.md) are posted on [GitHub](http://github.com/powershell/underhanded-powershell), along with the rest of the documents and the module code required for participating in this contest. You must read all the rules before participating. The first contest in this series is focused on finding scripts that would do the equivalent of the following PowerShell code, but not be caught by the rules we have created.

`         [System.Runtime.InteropServices.Marshal]::SystemDefaultCharSize     `

An example of an underhanded approach to this would be:

``` powershell
$type = [Type] ("System.Runtime.InteropSe" + "rvices.Mar" + "shal")
$property = "SystemDef" + "aultCharSize"
$type::$property
```

Your goal is to submit your own creative approaches to underhanded scripting using the **Test-IsSuspiciousContent** command, and get a false IsSuspicious return value.

We will award prizes for the largest number of unique successful underhanded techniques submitted, and will also update the contest standings regularly so you can show off to your friends. Critical dates for this contest are:

|                   |                                 |
|-------------------|---------------------------------|
| **Jan. 19, 2016** | Contest opens                   |
| **Mar. 1, 2016**  | Submission deadline             |
| **Mar. 15, 2016** | Results of Judging              |
| **Mar. 15, 2016** | Next phase of contest announced |

**Important:** Before you submit any code, read the [Rules](http://github.com/powershell/underhanded-powershell/blob/master/Rules.md). Among other things you will see that by submitting code to this contest, you are granting Microsoft the ability to reuse in any way the code or content you submit, and that we will collect contact information from you to help us run the contest.

As mentioned above, we plan for this to be a series of contests. In future contests, we will share some of our rules that we want you to break, and will expand the prize rules to deal with adding support for defenders (those submitting new validation rules), and attackers (getting past the rules), etc.

## Module Usage

### Install the module

```
PS> Set-Location (Split-Path $profile)
PS> New-Item -Type Directory "Modules/UnderhandedScriptTesting" -Force 
PS> $webRequest = @{
    Uri = 'https://raw.githubusercontent.com/PowerShell/underhanded-powershell/master/UnderhandedScriptTesting/UnderhandedScriptTesting.psm1'
    OutFile = 'Modules/UnderhandedScriptTesting/UnderhandedScriptTesting.psm1'
}
PS> Invoke-WebRequest @webRequest
```

### Test a script

```
Test-IsUnderhandedPowerShell -ScriptBlock { Invoke-Expression "SOME_BASE64" } -Username superbadguy -ContactEmail redteam@example.com
```
