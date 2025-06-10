<#
.SYNOPSIS
    將指定位置的轉出影像tar檔匯入到MicroK8S叢集節點上容器運行時內部儲存的容器影像。

.DESCRIPTION
    同上所述。

.PARAMETER nodeNames
    MicroK8S 多個叢集節點名稱。默認值為 microk8s-vm, node1, "node2。

.PARAMETER tarfileposition
    指定位置的轉出影像tar檔。默認值為/shared/DockerSave/pihole.tar
    
.EXAMPLE
    .\RemoveImageToAllNodes.ps1 -nodeNames microk8s-vm,node1,node2 -tarfileposition /shared/DockerSave/pihole.tar
    此命令將指定位置的轉出影像tar檔匯入到MicroK8S叢集節點microk8s-vm、node1、node2上的containerD容器運行時內部的k8s.io命名空間位置的容器影像。

.NOTES
    作者：leonlee
    日期：2025-05-09
#>

# Define your node names, namespace, and tar file position
param ([array]$nodeNames=@("microk8s-vm", "node1", "node2"), 
       [string]$tarfileposition='/shared/DockerSave/pihole.tar')

$namespace = "k8s.io" # Replace with your actual namespace
$nodeNamesString=$nodeNames -join ","

write-host "If this script were really going to do something, it would do it on these specific parameters : -nodeNames $nodeNamesString -tarfileposition $tarfileposition"

# Loop through each node name
foreach ($nodename in $nodeNames) {
# Execute the command
$command = "multipass exec $nodename -- sudo microk8s ctr -namespace=`"$namespace`" image import `"$tarfileposition`" --platform=linux/amd64"

# Invoke the command and capture output
$output = Invoke-Expression $command

# Display a message indicating the result
if ($output -and $output.Trim().EndsWith("done")) {
Write-Host "${nodename} has successfully imported image file ${tarfileposition}."
Write-Host "${output}"
} else {
Write-Host "Error importing image file ${tarfileposition} on ${nodename}: ${output}."
}
}
