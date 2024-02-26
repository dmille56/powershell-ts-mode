# Define a simple function
function Get-MultipliedNumber {
    param (
        [int]$Number,
        [int]$Multiplier = 2
    )
    $Number * $Multiplier
}

# Use variables and basic arithmetic
$number = 5
$multipliedNumber = Get-MultipliedNumber -Number $number -Multiplier 3
Write-Host "Multiplied Number: $multipliedNumber"

# Working with arrays
$array = 1..10
$filteredArray = $array | Where-Object { $_ % 2 -eq 0 }
Write-Host "Even Numbers: $filteredArray"

# Conditional logic
if ($multipliedNumber -gt 10) {
    Write-Host "Greater than 10"
} else {
    Write-Host "10 or less"
}

# Looping through items
foreach ($item in $filteredArray) {
    Write-Host "Processing item: $item"
}

# Creating and using a custom object
$person = [PSCustomObject]@{
    FirstName = 'John'
    LastName = 'Doe'
    Age = 30
}
Write-Host "Person's Full Name: $($person.FirstName) $($person.LastName)"

# Error handling with Try/Catch
try {
    $content = Get-Content -Path "C:\nonexistentfile.txt"
} catch {
    Write-Host "Error: $_"
}

# Interacting with the file system
$desktopPath = [System.Environment]::GetFolderPath("Desktop")
$newFilePath = Join-Path -Path $desktopPath -ChildPath "testfile.txt"
"Hello, PowerShell!" | Out-File -FilePath $newFilePath
Write-Host "Created a new file at $newFilePath"

# Advanced feature: PowerShell workflows for parallel processing
workflow Test-ParallelProcessing {
    $computers = 'Computer1', 'Computer2', 'Computer3'
    foreach -parallel ($computer in $computers) {
        # This example just echoes the computer name
        # In a real scenario, you might perform actions like checking connectivity, services, etc.
        Write-Output "Processing $computer"
    }
}

# Invoke the workflow
Test-ParallelProcessing

# Working with PS Jobs for asynchronous tasks
$job = Start-Job -ScriptBlock {
    1..10 | ForEach-Object {
        Start-Sleep -Seconds 1
        $_
    }
}

# Wait for the job to complete and receive job results
Wait-Job $job
$results = Receive-Job $job
Write-Host "Asynchronous job results: $results"

# Remove the job
Remove-Job $job

# Working with Modules and Importing
# Note: This requires the `PSReadLine` module to be installed on your system.
Import-Module PSReadLine
Get-Command -Module PSReadLine

# Using .NET classes and methods
$dateTime = [System.DateTime]::Now
Write-Host "Current Date and Time: $dateTime"

# Creating and manipulating a Hashtable
$hashtable = @{
    Name = 'John Doe'
    Age = 30
    City = 'New York'
}
$hashtable['Country'] = 'USA'
Write-Host "Hashtable values: $($hashtable.GetEnumerator() | Out-String)"

# Advanced Function with CmdletBinding and Parameter Validation
function Get-AdvancedGreeting {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [string]$Name,

        [ValidateSet("Morning", "Afternoon", "Evening")]
        [string]$TimeOfDay
    )
    "Good $TimeOfDay, $Name!"
}

# PowerShell Profile Example (This line would typically go in a PowerShell profile file)
# Write-Host "Welcome to PowerShell!"

# PowerShell Remoting
Invoke-Command -ComputerName RemoteServer -ScriptBlock { Get-Process } -Credential (Get-Credential)

# Regular Expressions
if ("PowerShell" -match "shell$") {
    "Matches pattern"
}

# XML Parsing
[xml]$xmlContent = "<root><element>Value</element></root>"
$xmlContent.root.element

# JSON Parsing
$jsonString = '{"Name": "John", "Age": 30}'
$jsonObject = $jsonString | ConvertFrom-Json
$jsonObject.Name

# PowerShell Classes
class Person {
    [string]$Name
    [int]$Age

    Person([string]$name, [int]$age) {
        $this.Name = $name
        $this.Age = $age
    }

    [string] Greet() {
        return "Hello, my name is $($this.Name) and I am $($this.Age) years old."
    }
}

# DSC Configuration
Configuration ExampleConfiguration {
    Node "localhost" {
        File ExampleFile {
            DestinationPath = "C:\example.txt"
            Contents = "Hello, DSC!"
        }
    }
}

# PSProviders and PSDrives
Set-Location HKCU:
Get-ChildItem

# Transactions
Start-Transaction
New-Item -Path "HKCU:\Software\ExampleKey" -ItemType Directory -UseTransaction
Undo-Transaction

# Error Handling Enhancements
try {
    Get-Content NonExistentFile.txt -ErrorAction Stop
} catch {
    Write-Host "Caught an error: $_"
}

# Event Handling
$timer = New-Object timers.timer
$timer.Interval = 1000 # One second
Register-ObjectEvent -InputObject $timer -EventName Elapsed -Action { Write-Host "Timer ticked!" }
$timer.Start()

# Using Workflows for Parallel Processing
workflow Get-ParallelProcess {
    parallel {
        Get-Process powershell
        Get-Service WinRM
    }
}

# Security Features: Secure String
$secureString = ConvertTo-SecureString "PlainTextPassword" -AsPlainText -Force
$secureString

# Debugging Script Example (Place a breakpoint on the Write-Host line in an IDE)
Write-Host "Debug this line"

# Using Web Requests
$response = Invoke-WebRequest -Uri "https://api.github.com/users/octocat"
$response.Content

# Pipeline Enhancements
Get-Process | Where-Object {$_.WorkingSet -gt 100MB} | Sort-Object WorkingSet -Descending | Select-Object -First 5

# Writing and Importing a Module
# Module file content: function Get-ModuleGreeting { "Hello from the module!" }
Import-Module ./MyCustomModule.psm1
Get-ModuleGreeting

# Custom Tab Completion
Register-ArgumentCompleter -CommandName 'Get-AdvancedGreeting' -ParameterName 'TimeOfDay' -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)
    'Morning', 'Afternoon', 'Evening' | Where-Object { $_ -like "$wordToComplete*" }
}

# Scheduled Jobs
$trigger = New-JobTrigger -At 3:00pm -Daily
Register-ScheduledJob -Name "DailyProcessCheck" -ScriptBlock { Get-Process } -Trigger $trigger

# Cross-Platform Feature Example (Using PowerShell Core)
$os = [System.Runtime.InteropServices.RuntimeInformation]::OSDescription
Write-Host "Running on: $os"
