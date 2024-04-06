function Ensure-ModuleInstalled($module) {
    # install psGet if Get-Module not exist
    if (!$script:installModule)
    {
        if (!(Get-Command 'Install-Module' -ErrorAction SilentlyContinue))
        {
            (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | Invoke-Expression
        }
    }

    if (!(Get-Module -name $module))
    {
        if (!(Get-Module -list $module))
        {
            if ($script:installModule.Parameters.ContainsKey('Scope'))
            {
                Install-Module $module -Scope CurrentUser -Force
            }
            else
            {
                Install-Module $module -Force
            }
        }

        Import-Module $module
        Test-a;
    }

    Test-A;
    Test-B;
}

cd TestA;
Ensure-ModuleInstalled `
    -module "Test" `
    -module "t";

{
    Get-A | `
        Test-B | `
        Test-C;
}

$a = New-WinUserLanguageList "zh-cn"
$a.Add("en-us", "ha-au")

Set-WinUserLanguageList $a -Force

$long_name = 12;

# write a function to login into azure cloud
function Login-AzureCloud()
{
    $azureCloud = "AzureCloud";
    $azureCloudId = "Microsoft Azure";
    $azureCloudTenantId = "";

    $azureCloudAccount = Get-AzureRmContext | Select-Object -ExpandProperty Account;
    if ($azureCloudAccount -eq $null)
    {
        $azureCloudAccount = New-AzureRmAccount -Environment $azureCloud -TenantId $azureCloudTenantId;
    }

    $azureCloudAccount | Select-Object -ExpandProperty Id;
}

{
    function test ([string] $a, [string] $b)
    {
        param ([string]$name,
               [version]$version,
               [bool]$prerelease = $true,
               [bool]$ondemand = $false);
        $test =
            {
                $a = 12;
            };
        Test-A;
        Test-B;
    }
}

{
    if (!$script:installModule -and
        ($test -eq 2) -or
        ($test -eq 3 -and
         $test -eq 3))
    {
    }

    if (!(Get-Command 'Install-Module' -ErrorAction SilentlyContinue))
    {
        (new-object Net.WebClient).DownloadString("http://psget.net/GetPsGet.ps1") | Invoke-Expression

    }
    elseif ($test -eq 3 -and $test -ne 4)
    {
        asd;
    }
    else
    {
        asd;
    }

}

{
    while ($test -eq 2 -and $test -ne 3)
    {
        $test = 3;
    }

    do
    {
        $test = 3;
    }
    while ($test -eq 2 -and
           $true -and $false 
    );
}

{

    for ($i = 0; $i -lt 10 -and $true; $i++)
    {
        $test = 3;
    }

    foreach ($i in 1..10)
    {
        $test = 3;
    }

    switch ($test -and $true)
    {
        1
        {
            $test = 3;
        }
        2
        {
            $test = 3;
        }

        default {
            $test = 3;
        }
    }

    try
    {
        $test = 3;
    }
    catch
    {
        $test = 3;
    }
    finally
    {
        $test = 3;
    }

    trap
    {
        $test = 3;
    }
}

{
    class
        Device
    {
        [string] $Brand = 12;
        [void]
            Test()
        {
        }
    }
}

{
    $a = $b =
        @(
            12,
            {$b, $s},
            4
        );
}

{

    $b = @{
        $azureCloud = 112;
        $ads        = 12;
        $ads        = 12;
    }
}

function ensure_params ([GitCommand] $command) {
    if (($command.Type -eq [GitCommandType]::Builtin) -and ($command.Params.Count -eq 0)) {
        git $command.Command.Display -h 2>&1 `
            | Select-String -AllMatches -Pattern '(?<=(^ +|, *|\[|\|))-{1,2}[^ ,|\[\]]+'  `
            | ForEach-Object { $_.Matches.Value; } `
            | Select-Object -Unique `
            | ForEach-Object { [void] $command.Params.Add([GitCompletionResult]::new($_, 'Param')); };
    }
}
