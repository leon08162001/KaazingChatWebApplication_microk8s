Start-Transcript -Path "C:\Scripts\microk8s-recovery.log" -Append

$multipass = "C:\Program Files\Multipass\bin\multipass.exe"
$sharePath = "E:\shared"
$mountPoint = "/shared"

Write-Host "===== MicroK8s Multipass Recovery Start ====="

# 取得所有 Multipass instances
$instances = & $multipass list --format csv | Select-Object -Skip 1 | ForEach-Object {
    ($_ -split ",")[0]
}

foreach ($vm in $instances) {

    Write-Host "-----------------------------"
    Write-Host "Processing VM: $vm"

    try {

        # Stop VM
        Write-Host "Stopping VM: $vm"
        Stop-VM -Name $vm -TurnOff -ErrorAction SilentlyContinue

        Start-Sleep -Seconds 3

        # Start VM
        Write-Host "Starting VM: $vm"
        Start-VM -Name $vm

        # 等 VM Running
        do {
            Start-Sleep -Seconds 3
            $state = (Get-VM -Name $vm).State
        } until ($state -eq "Running")

        Write-Host "$vm Running"

        # Unmount
        Write-Host "Unmounting shared folder"
        & $multipass unmount "${vm}:${mountPoint}" 2>$null

        Start-Sleep -Seconds 2

        # Remount
        Write-Host "Mounting shared folder"
        & $multipass mount --type=classic $sharePath "${vm}:${mountPoint}"

        Start-Sleep -Seconds 3

        # Verify
        $mounted = & $multipass exec $vm -- bash -c "mount | grep $mountPoint"

        if ($mounted) {
            Write-Host "Mount SUCCESS on $vm"
        }
        else {
            Write-Host "Mount FAILED on $vm"
        }

    }
    catch {

        Write-Host "Error processing $vm"

    }
}

Write-Host "===== Recovery Finished ====="

Stop-Transcript