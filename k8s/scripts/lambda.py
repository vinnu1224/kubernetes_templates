from __future__ import print_function
import boto3
import json
print('Loading function')
ssm = boto3.client("ssm")
ec2 = boto3.client("ec2")
asg = boto3.client("autoscaling")
documentName = "kubernetesDrainNodes"


def lambda_handler(event, context):
    snsClient = boto3.client("sns")
    message = json.loads(event['Records'][0]['Sns']['Message'])
    print(message)
    instance_id = message[u'EC2InstanceId']
    print(instance_id)
    response = ec2.describe_instances(
        InstanceIds=[instance_id]
    )
    for r in response['Reservations']:
        for i in r['Instances']:
            nodename = i['PrivateDnsName']
            print(nodename)
    res = ssm.send_command(
          DocumentName=documentName,
          Parameters={
             'nodename': [
                 nodename,
              ]
          },
          Targets=[
              {
                 'Key': 'tag:master',
                 'Values': [
                      'yes',
                    ]
              },
          ]
)    
