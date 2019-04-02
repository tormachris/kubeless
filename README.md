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

### Deploy function to kubeless
To deploy a function to kubeless run the `./function/deploy_function.sh <RUNTIME> <FILENAME> <FUNCTION NAME> <HANDLER NAME>` command with the appropriate parameters. You need to have the function available in a file next to the script.

### Benchmark the cluster
Benchmarking is pretty turnkey. Edit the appropriate variables in `./benchmark/benchmark.sh` file, then run it!
