multipass unmount microk8s-vm:/shared
multipass unmount node1:/shared
multipass unmount node2:/shared
multipass mount --type=classic E:\shared microk8s-vm:/shared
multipass mount --type=classic E:\shared node1:/shared
multipass mount --type=classic E:\shared node2:/shared