# Kubernetes on Raspberry Pi

I have been a huge fan of [Docker](https://www.docker.com/) over the years, and naturally that excitement would spill over to [Kubernetes](https://kubernetes.io/) which was designed by [Google](https://en.wikipedia.org/wiki/Google) and now maintained by [Cloud Native Computing Foundation](https://en.wikipedia.org/wiki/Cloud_Native_Computing_Foundation).

There are cloud options you can look at if you want to start experimenting with Kubernetes with very little effort.
This is in alphabetical order and has no personal preference attached to them.

* [AWS](https://aws.amazon.com/eks/)
* [Azure](https://azure.microsoft.com/en-us/free/kubernetes-service/)
* [Google](https://cloud.google.com/kubernetes-engine/)

So I started my journey by following this blog post [How to Build a Kubernetes Cluster with ARM Raspberry Pi then run .NET Core on OpenFaas](https://www.hanselman.com/blog/HowToBuildAKubernetesClusterWithARMRaspberryPiThenRunNETCoreOnOpenFaas.aspx) written by [Scott Hanselman](https://www.hanselman.com/) and there I was introduced to [Alex Ellis'](https://blog.alexellis.io/) blog post [Build your own bare-metal ARM cluster](https://blog.alexellis.io/build-your-own-bare-metal-arm-cluster/). 
With their combined knowledge and experience, I highly doubt I can add much more value to this topic. 

So this is purely for me to ducument what challenges I ran into and how I overcame them and of course, to give credit where credit is due.

### Set static ip address

```
sudo nano /etc/dhcpcd.conf
```

```
interface eth0
static ip_address=192.168.8.200/24
static routers=192.168.8.1
static domain_name_servers=192.168.8.1 8.8.8.8
```

### Initialize your master node

```
curl -sLSf https://raw.githubusercontent.com/gvanderberg/k8s-on-raspberrypi/master/scripts/prep.sh | sudo sh
```

* Pre-pull images

```
sudo kubeadm config images pull -v3
```

* For flannel to work correctly, you must pass ```--pod-network-cidr=10.244.0.0/24``` to kubeadm init.
* Set ```/proc/sys/net/bridge/bridge-nf-call-iptables``` to ```1``` by running ```sysctl net.bridge.bridge-nf-call-iptables=1``` to pass bridged IPv4 traffic to iptables’ chains. This is a requirement for some CNI plugins to work.

```
sudo kubeadm init --token-ttl=0 --pod-network-cidr=10.244.0.0/24
```

We pass in `--token-ttl=0` so that the token never expires - do not use this setting in production. The UX for `kubeadm` means it's currently very hard to get a join token later on after the initial token has expired. 

> Optionally also pass `--apiserver-advertise-address=192.168.8.200` with the IP of the Pi as found by typing `ifconfig`.

After the `init` is complete run the snippet given to you on the command-line:

```
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```

* Now save your join-token

Your join token is valid for 24 hours, so save it into a text file. Here's an example of mine:

```
sudo kubeadm join 192.168.8.200:6443 --token 648fsd.k9ss7yhfjlnkcxyb --discovery-token-ca-cert-hash sha256:4b508d932fab6a84bf216afb5acaed6d427f9fbbacac2b57b70135bdb3c6c883
```

### Setup networking with Flannel

* [Flannel CNI](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/#tabs-pod-install-4)

```
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
```

On each node that joins including the master:

```
sudo sysctl net.bridge.bridge-nf-call-iptables=1
```

So the first consideration for me here was the CNI (Container Network Interfaces) which is our Pod-to-Pod communication. I learned the hard way that if you want to use Flannel, you need to initialize your master node with a Pod network CIDR, using WeaveNet that is not required. I'm not sure about the rest as I only played with those 2 options and I ultimately chose Flannel. For a feature and performance comparison, there is a great article on [itnext.io](https://itnext.io/benchmark-results-of-kubernetes-network-plugins-cni-over-10gbit-s-network-36475925a560).

### Installing Kubernetes dashboard

```
kubectl set image deployment/kubernetes-dashboard kubernetes-dashboard=k8s.gcr.io/kubernetes-dashboard-arm:v1.10.1 -n kube-system
```

* [Dashboard Installation](https://github.com/kubernetes/dashboard/wiki/Installation)
* [Dashboard Access Token](https://github.com/kubernetes/dashboard/wiki/Creating-sample-user)

```
http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard-head:/proxy/
```
