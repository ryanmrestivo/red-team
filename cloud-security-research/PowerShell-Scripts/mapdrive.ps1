param
(
    [Parameter (Mandatory=$false)]
    [object] $inputfscredobj,

    [string] $inputfsurl
)

Remove-PSDrive -Name S -Force

start-sleep -Seconds 60

New-PSDrive -Name S -PSProvider FileSystem -Root "\\$($inputfsurl)\samplefileshare" -Credential $inputfscredobj -Persist