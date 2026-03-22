param(
    [Parameter(Mandatory = $true)]
    [string]$NodeName
)

# 取得該節點上所有 Pod（JSON 格式）
$podsJson = kubectl get pods -A -o json --field-selector spec.nodeName=$NodeName | ConvertFrom-Json

foreach ($item in $podsJson.items) {
    $ns = $item.metadata.namespace
    $name = $item.metadata.name

    Write-Host "Deleting pod $name in namespace $ns ..." -ForegroundColor Yellow
    kubectl delete pod $name -n $ns --force --grace-period=0
}
