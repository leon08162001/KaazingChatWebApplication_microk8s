$vmNames = @("microk8s-vm", "node1", "node2")
$sharePath = "E:\shared"
$mountPoint = "/shared"

function Wait-VMRunning {
    param ($vm)

    do {
        $state = (Get-VM -Name $vm).State
        Write-Host "$vm state: $state"
        Start-Sleep -Seconds 3
    } until ($state -eq "Running")
}

Write-Host "Stopping VMs..."
foreach ($vm in $vmNames) {
    Stop-VM -Name $vm -TurnOff -ErrorAction SilentlyContinue
}

Start-Sleep -Seconds 5

Write-Host "Starting VMs..."
foreach ($vm in $vmNames) {
    Start-VM -Name $vm
}

foreach ($vm in $vmNames) {
    Wait-VMRunning $vm
}

Write-Host "Remounting shared folders..."
foreach ($vm in $vmNames) {

    multipass unmount "${vm}:${mountPoint}" 2>$null
    multipass mount --type=classic $sharePath "${vm}:${mountPoint}"
}

Write-Host "All VMs restarted and mounted successfully."