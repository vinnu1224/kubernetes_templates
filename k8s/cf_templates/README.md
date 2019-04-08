# Creating CloudFormation Template Using AWSCLI

### To create kubernetes master stack by

* passing parameters directly

```

aws cloudformation create-stack --stack-name master  --template-body file:///root/AppZ-Images/k8s/cf_templates/master.json --region us-east-2 --parameters ParameterKey=KeyName,ParameterValue=xxxxxxxx ParameterKey=InstanceType,ParameterValue=t2.medium  ParameterKey=InstanceCount,ParameterValue=1 --capabilities CAPABILITY_IAM

```
                              *** or ***
* passing parameters from a file 

```

aws cloudformation create-stack --stack-name master  --template-body file:///root/AppZ-Images/k8s/cf_templates/master.json --region us-east-2 --parameters file:///root/AppZ-Images/k8s/cf_templates/masterpar.json 

```


### To create kubernetes nodes  stack by


* passing parameters directly

```


aws cloudformation create-stack --stack-name nodes --template-body file:///root/AppZ-Images/k8s/cf_templates/node.json --region us-east-2 --parameters ParameterKey=KeyName,ParameterValue=xxxxxxxx ParameterKey=VpcId,ParameterValue=vpc-xxxxxxxx  'ParameterKey=SubnetId,ParameterValue="subnet-xxxxxx,subnet-xxxxx"' ParameterKey=AZs,ParameterValue='us-east-2a\,us-east-2b\,us-east-2c' --capabilities CAPABILITY_IAM


```

### To describe the stack by

```

aws cloudformation describe-stacks --region us-east-2

```

### To delete the stack by 

```

aws cloudformation delete-stack --stack-name master --region us-east-2

```

master.json template creates a kubernetes master that uses Elastic Load Balancing and is configured to use multiple availability zones.This template also contains ssm role and policy to execte ssm document on the kubernetes master. master.json template creates vpc,subnets,internetgateway and public route table.
node.json template creates kubernetes nodes auto scaling group behind a load balancer with a simple health check.The autoscaling group contains min size :2 max size: 5 and with a desired capacity:2. node.json template creates lifecyclehook,sns topic and lambda function.

# Scale down a Kubernetes Cluster node without downtime using AWS Autoscaling Lifecycle Hook 
###### whenever we scale down , an autoscaling group terminates the kubernetes node then  kubectl drain command to be executed on the master to safely drain a node from cluster before the node is terminated.

* By implementing the following process, we will be able to terminate the node without affecting the application performance.
 
 * Put the lifecycle hook on Kubernetes node autoscaling group.
 * As the autoscaling will terminate the node instance, lifecycle hook will put the server in “Terminating:WAIT” state and it triggers an SNS notification.
 * SNS will trigger the Lambda function to implement the Lifecycle hook action.
 * Lambda will execute “kubectl drain node” command through SSM on the master node.
 * The given node will be marked as scheduling disabled to prevent new pods from arriving and all the pods will be evicted from the node for graceful termination.
 * Once the command is successful, the node will be terminated completely by AutoScaling Group.
 
## pre-requisites:

* s3 bucket to save the lambdacode(kube-lambda.zip)

* IAM Roles

###### Create an IAM Role for Lambda Function and give the required permissions that will be used for its execution like SSM, EC2 and S3. (node.json template creates IAM roles and required permissions for lambda function) 

* ssm document :

###### execute the below command to create the document in SSM:
  
   ```
    aws ssm create-document --content "file://document.json" --name "kubernetesDrainNodes" --document-type "Command" "
   ```
   document.json contains 
   
   ```
   {  
   "schemaVersion":"1.2",
   "description":"Draining Node",
   "parameters":{  
      "nodename":{  
         "type":"String",
         "description":"Specify the Node name to drain"
      }
   },
   "runtimeConfig":{  
      "aws:runShellScript":{  
         "properties":[  
            {  
               "id":"0.aws:runShellScript",
               "runCommand":[  
                  "#!/bin/bash",
                  "kubectl drain --force {{ nodename }}"
               ]
       } ] } } }
	   
  ```

