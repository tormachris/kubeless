# Kubernetes Cluster Deployer and Withdrawer

---

## Available CNI plugins (as for now)
* Calico
* Cilium
* Flannel
* WeawNet

---

## User's Manual

### Preparations
The commands must be run as root on the (future) master node. The SSH-key of the master node must be uploaded on the worker node for root, so it can run seamlessly.

Create a `worker.list` file and add the hostname or the IP address of the worker nodes in it line-by-line as you can see in the example file.

### Deploying Kubernetes Cluster
To install the cluster run the `./cluster-deploy <CNI>` command. A Kubernetes CNI plugin name must be given as an argument. If you give the word `help` as an argument, you will get the available CNI plugins.

### Withdraw Kubernetes Cluster
To undo the cluster installation run the `./cluster-withdraw` command and it will clean up the configurations on all nodes including the master as well. Command will purge all Kubernetes setups from nodes enlisted in the `worker.list` file!

---

## Használati útmutató

### Előkészületek
A parancsokat root-tal kell futtatni a (leendő) mester gépen. A worker gépek root felhasználójához töltsétek fel a mester SSH-kulcsát, így jelszókérés nem állítja meg a telepítési folyamatokat.

Hozz létre egy `worker.list` fájlt, mely soronként tartalmazza a worker gépek hosztnevét vagy IP címét, ahogy a példa fájlban is látható.

### Kubernetes Klaszter létrehozása

A klaszter létrehozásához futtasd le a `./cluster-deploy <cni>` parancsot. Paraméterként meg kell adni a Kubernetes klaszter hálózati bővítményét. Ha a `help` paraméterrel futtatod, akkor megkapod az elérhető Kubernetes CNI bővítmények listáját.


### Kubernetes Klaszter eltávolítása
A klaszter visszavonásához a `./cluster-withdraw` parancsot kell lefuttatni, és ezután eltávolítja az összes klaszter beállítást a gépeken, beleértve a mester gépet is. A parancs letörli az összes Kubernetes beállítást a hosztokról, melyek  a `worker.list` fájlban szerepelnek!