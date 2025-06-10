<#
.SYNOPSIS
    從指定的MicroK8S叢集節點上刪除容器運行時內部儲存的容器影像。

.DESCRIPTION
    同上所述。

.PARAMETER nodeNames
    MicroK8S 多個叢集節點名稱。默認值為 microk8s-vm,node1,node2。

.PARAMETER imagename
    欲刪除的容器影像名稱。默認值為 docker.io/pihole/pihole:2025.02.6
    
.EXAMPLE
    .\RemoveImageToAllNodes.ps1 -nodeNames microk8s-vm,node1,node2 -imagename docker.io/pihole/pihole:2025.02.6
    此命令將從MicroK8S叢集節點microk8s-vm、node1、node2上的containerD容器運行時內部的k8s.io命名空間位置刪除指定的容器影像。

.NOTES
    作者：leonlee
    日期：2025-05-09
#>

# Define your node names, namespace, and imagename
param ([array]$nodeNames=@("microk8s-vm", "node1", "node2"), 
       [string]$imagename='docker.io/pihole/pihole:2025.02.6')

$namespace = "k8s.io" # Replace with your actual namespace
$nodeNamesString=$nodeNames -join ","

write-host "If this script were really going to do something, it would do it on these specific parameters : -nodeNames $nodeNamesString, -imagename $imagename"

# Loop through each node name
foreach ($nodename in $nodeNames) {
# Execute the command
$command = "multipass exec $nodename -- sudo microk8s ctr -namespace=`"$namespace`" image rm `"$imagename`""

# Invoke the command and capture output
$output = Invoke-Expression $command

# Display a message indicating the result
if ($output -eq $imagename) {
Write-Host "${nodename} has successfully removed image ${imagename}."
Write-Host "${output}"
} else {
Write-Host "Error deleteing image ${imagename} on ${nodename}: ${output}."
}
}
