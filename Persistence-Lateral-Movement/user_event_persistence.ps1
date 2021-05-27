function Gen-Task($eventid)
{
    $Service = new-object -ComObject("Schedule.Service")
    $Service.Connect()
    $RootFolder = $Service.GetFolder("\")
    $TaskDefinition = $Service.NewTask(0)
    $regInfo = $TaskDefinition.RegistrationInfo
    $regInfo.Description = 'Microsoft Windows performance monitor'
    $regInfo.Author = $taskRunAsuser
    $settings = $taskDefinition.Settings
    $settings.Enabled = $true
    $settings.StartWhenAvailable = $true
    $settings.Hidden = $true
    $Triggers = $TaskDefinition.Triggers
    $Trigger = $Triggers.Create(0)
    $Trigger.Id = $eventid
    $Trigger.Subscription = "<QueryList><Query Id='0'><Select Path='Application'>*[System[(EventID=$eventid)]]</Select></Query></QueryList>" 
    $Trigger.Enabled = $true    
    $Action = $TaskDefinition.Actions.Create(0)
    $Action.Path = 'cmd.exe'
    $Action.Arguments = '/c calc'
    $RootFolder.RegisterTaskDefinition('Windows Perflog',$TaskDefinition,6,$null,$null,3) | Out-Null    
}

function Find-Common-Events()
{
    $eventid = Get-Eventlog -Newest 500 -LogName Application | Group-Object -Property EventID -NoElement | Sort-Object -Property count -Descending | Select-Object -First 1 | Select -ExpandProperty Name
    Gen-Task($eventid)
}

Find-Common-Events