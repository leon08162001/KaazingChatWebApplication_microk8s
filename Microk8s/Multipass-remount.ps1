Stop-VM -Name "microk8s-vm" -TurnOff
Stop-VM -Name "node1" -TurnOff
Stop-VM -Name "node2" -TurnOff

Start-VM -Name "microk8s-vm"
Start-VM -Name "node1"
Start-VM -Name "node2"

multipass unmount microk8s-vm:/shared
multipass unmount node1:/shared
multipass unmount node2:/shared

multipass mount --type=classic E:\shared microk8s-vm:/shared
multipass mount --type=classic E:\shared node1:/shared
multipass mount --type=classic E:\shared node2:/shared

