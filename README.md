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

```
curl -sLSf https://raw.githubusercontent.com/gvanderberg/k8s-on-raspberrypi/master/scripts/prep.sh | sudo sh
```

### Initialize your master node

So the first consideration for me here was the CNI (Container Network Interfaces) which is our Pod-to-Pod communication. I learned the hard way that if you want to use Flannel, you need to initialize your master node with a Pod network CIDR, using WeaveNet that is not required. I'm not sure about the rest as I only played with those 2 options and I ultimately chose Flannel due to the BIG-IP F5 support which was another feature I wanted to play with. For a feature and performance comparison, there is a great article on [itnext.io](https://itnext.io/benchmark-results-of-kubernetes-network-plugins-cni-over-10gbit-s-network-36475925a560).

### Installing Kubernetes dashboard

[Dashboard Installation](https://github.com/kubernetes/dashboard/wiki/Installation)
[User Token](https://github.com/kubernetes/dashboard/wiki/Creating-sample-user)

```
http://localhost:8001/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard-head:/proxy/
```