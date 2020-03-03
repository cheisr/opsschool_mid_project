# opsschool_mid_project

### Infrastructure:

1. git clone this repo 
* add your ip address as a cidr block to the variable "my_ip_cidr_blocks" , and run:
* terraform init
* terraform plan
* terraform apply -auto-approve

#### Result: 
- 1 new VPC, 4 subnets (2 private, 2 public), 1 IG, 2 security groups (1 private, 1 public). All in 2 availability zones.
- 1 jenkins master + 3 jenkins nodes (divided between the AZs)
- K8s Cluster (divided between the AZs)
- 3 Consul servers (divided between the AZs)

### Jenkins deployment:
(jenkins run includes consul agents on both instances)
1. Access jenkins master's <public_ip>:8080 in browser
2. Add plugins:
- SSH Build Agents 
- Pipeline
- GitHub plugin
- Kubernetes Continuous Deploy
3. Add the nodes:
- Add the credentials of it by: 
a. ssh-ing to the master 
b. and running cat ~/.ssh/id_rsa to get the master’s private key
- Add that to the credentials (+ user: ubuntu) 
- Add the node (multiple executors, launch agents via SSH, label: linux)
6. Github plugin integration:
- SSH to the master instance
- Run “cat ~/.ssh/id_rsa.pub”
- Copy the pub key to github (SSH)
7. Add dockerhub credentials
8. Create the pipeline project with Git repo URL as git@github.com:cheisr/opsschool_project.git

#### Result: 
The image of the python app running in the docker container via 
Jenkins will be in https://hub.docker.com/_/cheisr/{new-project}
 

### K8s deployment:
Run:
- aws eks --region us-east-1 update-kubeconfig --name {name of EKS cluster}
- kubectl create -f 7_EKS_k8s.yml
- kubectl get svc -o wide
---> take the public IP and run in browser to see the app is running

### Commands:

To present the project:
1. mkdir opsschool_project
2. cd opsschool_project
3. git clone https://github.com/cheisr/opsschool_project
4. cd .. 
5. terraform init
6. terraform plan
7. terraform apply --auto-approve

Open:
1. jenkins_ip:8080
2. consul_ip:8500/ui
3. k8s_ip
