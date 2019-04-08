## K8s cluster installaion in offline servers:
* Download the docker and the dependency rpms in your local machine.
```
   wget https://download.docker.com/linux/centos/7/x86_64/stable/Packages/docker-ce-18.06.3.ce-3.el7.x86_64.rpm
   wget https://rpmfind.net/linux/centos/7.6.1810/extras/x86_64/Packages/container-selinux-2.74-1.el7.noarch.rpm
   wget https://rpmfind.net/linux/Mandriva/devel/cooker/x86_64/media/main/release/lib64ltdl7-2.4.2-6-mdv2012.0.x86_64.rpm
```
  * Copy  docker files to Master and Node to a seperate folder and run the below command
   ```
     yum install *.rpm
   ```
  * Enable and start the docker
  ```
    systemctl enable docker
    systemctl start docker
  ```

* Download the k8s rpms and dependencies.
  * Download the CNI Plugins.
  ```
    https://github.com/containernetworking/plugins/releases/download/v0.6.0/cni-plugins-amd64-v0.6.0.tgz
  ```
  Copy this binary to the master and node servers and extract to /opt/cni/bin
  ```
    mkdir -p /opt/cni/bin
    tar xvzf cni-plugins-amd64-v0.6.0.tgz -C /opt/cni/bin/
  ``` 
  * Install crictl (required for kubeadm / Kubelet Container Runtime Interface (CRI))
  ```
   wget https://github.com/kubernetes-incubator/cri-tools/releases/download/v1.13.4/crictl-v1.13.4-linux-amd64.tar.gz
  ```
  Copy the files to master and node servers and extract to /usr/bin
  ```
   tar xvzf crictl-v1.13.4-linux-amd64.tar.gz -C /usr/bin/
  ```
  * Install kubeadm, kubelet, kubectl and add a kubelet systemd service
  ```
    wget https://storage.googleapis.com/kubernetes-release/release/v1.13.4/bin/linux/amd64/{kubeadm,kubelet,kubectl}
    chmod +x {kubeadm,kubelet,kubectl}
  ```
  Copy this binaries to /usr/bin to the master and node servers.

* Copy the kubelet.service to /etc/systemd/system/
* Create a directory in Matser and Node /etc/systemd/system/kubelet.service.d/
* Copy the 10-kubeadm.conf to  /etc/systemd/system/kubelet.service.d/
  
* Enable and start kubelet
```
 systemctl enable kubelet
 systemctl start kubelet
```
* Pull the k8s docker images on your local machine.
```
 docker pull k8s.gcr.io/kube-proxy:v1.13.4
 docker pull k8s.gcr.io/kube-controller-manager:v1.13.4
 docker pull k8s.gcr.io/kube-scheduler:v1.13.4
 docker pull gcr.io/google_containers/kube-apiserver-amd64:v1.13.4
 docker pull k8s.gcr.io/kube-apiserver:v1.13.4
 docker pull registry:2
 docker pull quay.io/coreos/flannel:v0.11.0-s390x
 docker pulll quay.io/coreos/flannel:v0.11.0-ppc64le
 docker pull quay.io/coreos/flannel:v0.11.0-arm64
 docker pull quay.io/coreos/flannel:v0.11.0-arm
 docker pull quay.io/coreos/flannel:v0.11.0-amd64 
 docker pull k8s.gcr.io/coredns:1.2.6
 docker pull k8s.gcr.io/etcd:3.2.24
 docker pull k8s.gcr.io/pause:3.1

```
* Save docker images to tarball

```
 docker save k8s.gcr.io/kube-proxy:v1.13.4 > kube-proxy_v1.13.4.tar
 docker save k8s.gcr.io/kube-controller-manager:v1.13.4 > kube-controller-manager_v1.13.4.tar
 docker save k8s.gcr.io/kube-scheduler:v1.13.4 > kube-scheduler_v1.13.4.tar
 docker save gcr.io/google_containers/kube-apiserver-amd64:v1.13.4 > kube-apiserver-amd64_v1.13.4.tar
 docker save k8s.gcr.io/kube-apiserver:v1.13.4 > kube-apiserver_v1.13.4.tar
 docker save registry:2 > registry_2.tar
 docker save quay.io/coreos/flannel:v0.11.0-s390x > flannel_v0.11.0-s390x.tar
 docker save quay.io/coreos/flannel:v0.11.0-ppc64le > flannel_v0.11.0-ppc64le.tar
 docker save quay.io/coreos/flannel:v0.11.0-arm64 > flannel_v0.11.0-arm64.tar
 docker save quay.io/coreos/flannel:v0.11.0-arm > flannel_v0.11.0-arm.tar
 docker save quay.io/coreos/flannel:v0.11.0-amd64 > flannel_v0.11.0-amd64.tar
 docker save k8s.gcr.io/coredns:1.2.6 > coredns_1.2.6.tar
 docker save k8s.gcr.io/etcd:3.2.24 > etcd_3.2.24.tar
 docker save k8s.gcr.io/pause:3.1 > k8s.gcr.io/pause_3.1.tar
```
* Copy docker images tarball to Master and Node
```
 scp <folder_with_images>/*.tar <user>@<server>:<path>/<to>/<remote>/<folder>
```
* Ensure docker is started
```
 systemctl status docker
```
* Load docker images on Matser and Node
```
 docker load < kube-proxy_v1.13.4.tar 
 docker load < kube-controller-manager_v1.13.4.tar 
 docker load < kube-scheduler_v1.13.4.tar
 docker load < kube-apiserver-amd64_v1.13.4.tar
 docker load < kube-apiserver_v1.13.4.tar 
 docker load < registry_2.tar
 docker load < flannel_v0.11.0-s390x.tar
 docker load < flannel_v0.11.0-ppc64le.tar
 docker load < flannel_v0.11.0-arm64.tar 
 docker load < flannel_v0.11.0-amd64.tar
 docker load < coredns_1.2.6.tar
 docker load < etcd_3.2.24.tar
 docker load < k8s.gcr.io/pause_3.1.tar

```
* Create a local insecure_registry in the Master and Node servers.
```
 docker run -d -it -p 5000:5000 registry:2
```
* Push all the k8s images to the local registry in both servers.
```
docker tag k8s.gcr.io/kube-proxy:v1.13.4 localhost:5000/kube-proxy:v1.13.4
docker push localhost:5000/kube-proxy:v1.13.4
docker tag k8s.gcr.io/kube-apiserver:v1.13.4 localhost:5000/kube-apiserver:v1.13.4
docker push localhost:5000/kube-apiserver:v1.13.4
docker tag k8s.gcr.io/kube-controller-manager:v1.13.4 localhost:5000/kube-controller-manager:v1.13.4
docker push localhost:5000/kube-controller-manager:v1.13.4
docker tag k8s.gcr.io/kube-scheduler:v1.13.4 localhost:5000/kube-scheduler:v1.13.4
docker push localhost:5000/kube-scheduler:v1.13.4
docker tag quay.io/coreos/flannel:v0.11.0-s390x localhost:5000/flannel:v0.11.0-s390x
docker push localhost:5000/flannel:v0.11.0-s390x
docker tag quay.io/coreos/flannel:v0.11.0-ppc64le localhost:5000/flannel:v0.11.0-ppc64le
docker push localhost:5000/flannel:v0.11.0-ppc64le
docker tag quay.io/coreos/flannel:v0.11.0-arm64 localhost:5000/flannel:v0.11.0-arm64
docker push localhost:5000/flannel:v0.11.0-arm64
docker tag quay.io/coreos/flannel:v0.11.0-arm localhost:5000/flannel:v0.11.0-arm
docker push localhost:5000/flannel:v0.11.0-arm
docker tag quay.io/coreos/flannel:v0.11.0-amd64 localhost:5000/flannel:v0.11.0-amd64 
docker push localhost:5000/flannel:v0.11.0-amd64
docker tag k8s.gcr.io/coredns:1.2.6 localhost:5000/coredns:1.2.6
docker push localhost:5000/coredns:1.2.6
docker tag k8s.gcr.io/etcd:3.2.24 localhost:5000/etcd:3.2.24
docker push localhost:5000/etcd:3.2.24
docker tag k8s.gcr.io/pause:3.1 localhost:5000/pause:3.1
docker push localhost:5000/pause:3.1
```

* Run the kubeadm init
```
  kubeadm init --apiserver-advertise-address=<ip> --kubernetes-version=v1.13.4 --pod-network-cidr=10.244.0.0/16 --image-repository=localhost:5000
```
* Install the flannel from running the command
```
  kubectl  create -f kube-flannel.yaml
```
* Join the node to master by running the kubeadm join command.

