"Please enable appropriate RBAC permissions to the system identity of this automation account. Otherwise, the runbook may fail..."

try
{
    "Logging in to Azure..."
    Connect-AzAccount -Identity
}
catch {
    Write-Error -Message $_.Exception
    throw $_.Exception
}

$ResourceGroupName = "intent-system-00"

$resources = Get-AzResource -ResourceGroupName $ResourceGroupName

foreach ($resource in $resources) {
    if ($resource.ResourceType -eq "Microsoft.Sql/servers/databases") {
        Set-AzSqlDatabase -ResourceGroupName $ResourceGroupName -ServerName $resource.ServerName -DatabaseName $resource.Name -Edition "Basic" -RequestedServiceObjectiveName "S0"
    } elseif ($resource.ResourceType -eq "Microsoft.Web/sites") {
        Stop-AzWebApp -ResourceGroupName $ResourceGroupName -Name $resource.Name
    } elseif ($resource.ResourceType -eq "Microsoft.Storage/storageAccounts") {
        Update-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $resource.Name -EnableHttpsTrafficOnly $false -AllowBlobPublicAccess $false
    }
}
