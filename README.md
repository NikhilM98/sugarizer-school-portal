# Sugarizer School Portal

[**Sugarizer**](https://github.com/llaske/sugarizer) is the open-source learning platform based on Sugar that began in the famous One Laptop Per Child project.

[**Sugarizer Server**](https://github.com/llaske/sugarizer-server) allows the deployment of Sugarizer on a local server, for example on a school server, so expose Sugarizer locally as a Web Application. Sugarizer Server can also be used to provide collaboration features for Sugarizer Application on the network. Sugarizer Server could be deployed in a Docker container or on any computer with Node.js 6+ and MongoDB 2.6+.

**Sugarizer School Portal** is a new tool in the Sugarizer family which provides a way for schools interested by Sugarizer to host and manage themselves their Sugarizer deployment. It provides an on-demand (SaaS) Sugarizer Server deployment tool so that every school will be able to create a Sugarizer Server to host its own deployment without any technical skill in just a few clicks.

Under the hood, Sugarizer School Portal is a [Kubernetes](https://kubernetes.io/) cluster that is able to create/manage on-demand new Sugarizer Server instances.

The Sugarizer School Portal consists of multiple components:
- [Sugarizer School Portal Server](https://github.com/nikhilm98/sugarizer-school-portal-server)
- [Sugarizer Chart](https://github.com/nikhilm98/sugarizer-chart)
- [Sugarizer School Portal Chart](https://github.com/nikhilm98/sugarizer-school-portal-chart)

[**Sugarizer School Portal Server**](https://github.com/nikhilm98/sugarizer-school-portal-server) provides a web interface for the Sugarizer School Portal. It provides a role-based authentication for Clients, Moderators and Administrators, where the users can request for deployment by filling a simple form. The users can also monitor their deployment requests. The deployment administrators can monitor the users and approve/reject/deploy the requested deployments. It also allows the users to create admin accounts on their Sugarizer Server deployment directly from the interface

[**Sugarizer Chart**](https://github.com/nikhilm98/sugarizer-chart) is a collection of [Helm](https://helm.sh/) Charts for setting up [Sugarizer Server](https://github.com/llaske/sugarizer-server) deployment on a Kubernetes cluster. You can deploy multiple Sugarizer Server instances by editing the values of the YAML file and running simple `helm install` command. The Sugarizer Server instances are accessible from the browser by opening the `hostName` URL. Currently, it supports two providers:
- [Google Kubernetes Engine](https://cloud.google.com/kubernetes-engine) (GKE) - [README](https://github.com/NikhilM98/sugarizer-chart/tree/master/gke-environment)
- [Microk8s](https://microk8s.io) (For bare-metal Kubernetes cluster) - [README](https://github.com/NikhilM98/sugarizer-chart/tree/master/microk8s-environment)

The **Sugarizer School Portal Server** uses **Sugarizer Chart** to install a deployment in the Sugarizer School Portal Cluster.

[**Sugarizer School Portal Chart**](https://github.com/nikhilm98/sugarizer-school-portal-chart) is a [Helm](https://helm.sh/) Chart for setting up [Sugarizer School Portal Server](https://github.com/nikhilm98/sugarizer-school-portal-server) deployment on a Kubernetes cluster. You can deploy Sugarizer School Portal Server instance by editing the values of the YAML file and running simple `helm install` command. The Sugarizer School Portal Server instance can be accessed from the browser by opening the `hostName` URL.

The **Sugarizer School Portal Chart** also contains a set of [scripts](https://github.com/NikhilM98/sugarizer-school-portal-chart/tree/master/scripts) which can be used to set up the **Sugarizer School Portal Environment** with a simple `sh setup.sh` command.

The **Sugarizer School Portal Server** uses [**nodejs-helm**](https://www.npmjs.com/package/nodejs-helm) to interact with the Helm process. It is an [npm package](https://www.npmjs.com) which is a wrapper that integrates with the helm.sh process. The repository for the project is available on the [GitHub](https://github.com/) as [nikhilm98/nodejs-helm](https://github.com/NikhilM98/nodejs-helm).
