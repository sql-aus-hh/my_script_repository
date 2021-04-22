$SQLInstance = 'sqlcl-service\service'

$Schedule = Get-DbaAgentSchedule -SqlInstance $SQLInstance -Schedule 'Weekly - Sa - 2100'
if (($Schedule -eq "") -OR ([string]::IsNullOrEmpty($Schedule))) {
    New-DbaAgentSchedule -SqlInstance $SQLInstance -Schedule 'Weekly - Sa - 2100' -FrequencyType Weekly -FrequencyInterval Saturday -StartTime 210000 -Force
}
$Schedule = Get-DbaAgentSchedule -SqlInstance $SQLInstance -Schedule 'Weekly - Sa - 2200'
if (($Schedule -eq "") -OR ([string]::IsNullOrEmpty($Schedule))) {
    New-DbaAgentSchedule -SqlInstance $SQLInstance -Schedule 'Weekly - Sa - 2200' -FrequencyType Weekly -FrequencyInterval Saturday -StartTime 220000 -Force
}
$Schedule = Get-DbaAgentSchedule -SqlInstance $SQLInstance -Schedule 'Weekly - So - 2100'
if (($Schedule -eq "") -OR ([string]::IsNullOrEmpty($Schedule))) {
    New-DbaAgentSchedule -SqlInstance $SQLInstance -Schedule 'Weekly - So - 2100' -FrequencyType Weekly -FrequencyInterval Sunday -StartTime 210000 -Force
}
$Schedule = Get-DbaAgentSchedule -SqlInstance $SQLInstance -Schedule 'Weekly - So - 2200'
if (($Schedule -eq "") -OR ([string]::IsNullOrEmpty($Schedule))) {
    New-DbaAgentSchedule -SqlInstance $SQLInstance -Schedule 'Weekly - So - 2200' -FrequencyType Weekly -FrequencyInterval Sunday -StartTime 220000 -Force
}
$Schedule = Get-DbaAgentSchedule -SqlInstance $SQLInstance -Schedule 'Daily - 2200'
if (($Schedule -eq "") -OR ([string]::IsNullOrEmpty($Schedule))) {
    New-DbaAgentSchedule -SqlInstance $SQLInstance -Schedule 'Daily - 2200' -FrequencyType Daily -FrequencyInterval EveryDay -StartTime 220000 -Force
}
$Schedule = Get-DbaAgentSchedule -SqlInstance $SQLInstance -Schedule 'Every 2hours'
if (($Schedule -eq "") -OR ([string]::IsNullOrEmpty($Schedule))) {
    New-DbaAgentSchedule -SqlInstance $SQLInstance -Schedule 'Every 2hours' -FrequencyType Daily -FrequencyInterval EveryDay -FrequencySubdayType Hour -FrequencySubdayInterval 2 -Force
}


Set-DbaAgentJob -SqlInstance $SQLInstance -Job 'CommandLog Cleanup' -Schedule 'Weekly - Sa - 2100' -Enabled                     
Set-DbaAgentJob -SqlInstance $SQLInstance -Job 'Output File Cleanup' -Schedule 'Weekly - Sa - 2100' -Enabled
Set-DbaAgentJob -SqlInstance $SQLInstance -Job 'sp_delete_backuphistory' -Schedule 'Weekly - Sa - 2100' -Enabled
Set-DbaAgentJob -SqlInstance $SQLInstance -Job 'sp_purge_jobhistory' -Schedule 'Weekly - Sa - 2100' -Enabled
Set-DbaAgentJob -SqlInstance $SQLInstance -Job 'syspolicy_purge_history' -Schedule 'Weekly - Sa - 2100' -Enabled
Set-DbaAgentJob -SqlInstance $SQLInstance -Job 'DatabaseIntegrityCheck - USER_DATABASES' -Schedule 'Weekly - Sa - 2200' -Enabled
Set-DbaAgentJob -SqlInstance $SQLInstance -Job 'DatabaseIntegrityCheck - SYSTEM_DATABASES' -Schedule 'Weekly - So - 2100' -Enabled
Set-DbaAgentJob -SqlInstance $SQLInstance -Job 'IndexOptimize - USER_DATABASES' -Schedule 'Weekly - So - 2200' -Enabled


Set-DbaAgentJob -SqlInstance $SQLInstance -Job 'DatabaseBackup - SYSTEM_DATABASES - FULL' -Schedule 'Weekly - Sa - 2100' -Enabled
Set-DbaAgentJob -SqlInstance $SQLInstance -Job 'DatabaseBackup - USER_DATABASES - FULL' -Schedule 'Weekly - So - 2200' -Enabled
Set-DbaAgentJob -SqlInstance $SQLInstance -Job 'DatabaseBackup - USER_DATABASES - DIFF' -Schedule 'Daily - 2200' -Enabled
Set-DbaAgentJob -SqlInstance $SQLInstance -Job 'DatabaseBackup - USER_DATABASES - LOG' -Schedule 'Every 2hours' -Enabled
