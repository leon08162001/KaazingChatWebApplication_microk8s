#!/bin/bash
set -e

ARCHIVE_PATH="$1"
if [ -z "$ARCHIVE_PATH" ]; then
    echo "❌ 請提供備份壓縮檔路徑（例如 ./microk8s_restore.sh /path/to/microk8s-backup-2025-06-17-0301.tar.gz）"
    exit 1
fi

RESTORE_DIR="/tmp/microk8s-restore"
rm -rf "$RESTORE_DIR"
mkdir -p "$RESTORE_DIR"

echo "🔽 解壓縮備份..."
tar -xzf "$ARCHIVE_PATH" -C "$RESTORE_DIR"

echo "🔁 還原 Dqlite 資料庫..."
sudo systemctl stop snap.microk8s.daemon-kubelet
sudo systemctl stop snap.microk8s.daemon-apiserver
sudo systemctl stop snap.microk8s.daemon-controller-manager
sudo systemctl stop snap.microk8s.daemon-scheduler

sudo cp -r "$RESTORE_DIR/dqlite-backend"/* /var/snap/microk8s/current/var/kubernetes/backend/

echo "✅ Dqlite 已還原。"

echo "🔁 還原 PVC 資料..."
PVC_PATH="/var/snap/microk8s/common/default-storage"
if [ -d "$RESTORE_DIR/pvc-data" ]; then
    sudo cp -r "$RESTORE_DIR/pvc-data"/* "$PVC_PATH/"
    echo "✅ PVC 資料已還原。"
else
    echo "⚠️ 無 PVC 資料可還原。"
fi

echo "🔁 還原 YAML 資源..."
microk8s kubectl apply -f "$RESTORE_DIR/k8s-resources.yaml"

echo "✅ 還原完成！請確認服務狀態。"

echo "🔼 重新啟動 MicroK8s..."
sudo systemctl start snap.microk8s.daemon-kubelet
sudo systemctl start snap.microk8s.daemon-apiserver
sudo systemctl start snap.microk8s.daemon-controller-manager
sudo systemctl start snap.microk8s.daemon-scheduler
