#!/bin/bash
set -e

NOW=$(date +%F-%H%M%S)
BACKUP_ROOT="/var/backups/microk8s"
BACKUP_DIR="${BACKUP_ROOT}/backup-${NOW}"
ARCHIVE="${BACKUP_ROOT}/microk8s-backup-${NOW}.tar.gz"

mkdir -p "$BACKUP_DIR"

echo "🔹 備份 YAML 資源..."
microk8s kubectl get --all-namespaces all,configmap,secret,serviceaccount,pvc,pv,ingress,crd,role,rolebinding,clusterrole,clusterrolebinding,namespace -o yaml > "$BACKUP_DIR/k8s-resources.yaml"

echo "🔹 備份 Dqlite 資料庫..."
cp -r /var/snap/microk8s/current/var/kubernetes/backend "$BACKUP_DIR/dqlite-backend"

echo "🔹 備份 PVC 資料（hostPath）..."
PVC_DIR="/var/snap/microk8s/common/default-storage"
if [ -d "$PVC_DIR" ]; then
    cp -r "$PVC_DIR" "$BACKUP_DIR/pvc-data"
else
    echo "⚠️ 找不到 PVC 路徑，略過 PVC 備份。"
fi

echo "🗜 壓縮備份檔案..."
tar -czf "$ARCHIVE" -C "$BACKUP_DIR" .

echo "✅ 備份完成！壓縮檔案：$ARCHIVE"