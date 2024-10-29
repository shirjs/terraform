import os
import json
import base64
from github import Github
from datetime import datetime

def create_manifests(developer_id, image_name, port):
    """Create Kubernetes manifest strings."""
    # Extract deployment name from image
    deploy_name = image_name.split('/')[-1].split(':')[0].replace('.', '-').replace('_', '-')
    timestamp = int(datetime.now().timestamp())
    unique_name = f"{deploy_name}-{timestamp}"
    
    # Create namespace manifest
    namespace_yaml = f"""apiVersion: v1
kind: Namespace
metadata:
  name: {developer_id}
---
apiVersion: v1
kind: ResourceQuota
metadata:
  name: {developer_id}-quota
  namespace: {developer_id}
spec:
  hard:
    requests.cpu: "2"
    requests.memory: 2Gi
    limits.cpu: "4"
    limits.memory: 4Gi
    pods: "10"
    services: "5"
"""

    # Create deployment, service, and ingress manifests
    app_yaml = f"""apiVersion: apps/v1
kind: Deployment
metadata:
  name: {unique_name}
  namespace: {developer_id}
spec:
  replicas: 1
  selector:
    matchLabels:
      app: {unique_name}
  template:
    metadata:
      labels:
        app: {unique_name}
        developer: {developer_id}
    spec:
      containers:
      - name: {deploy_name}
        image: {image_name}
        ports:
        - containerPort: {port}
        resources:
          requests:
            memory: "256Mi"
            cpu: "200m"
          limits:
            memory: "512Mi"
            cpu: "500m"
---
apiVersion: v1
kind: Service
metadata:
  name: {unique_name}
  namespace: {developer_id}
spec:
  type: NodePort
  ports:
  - port: {port}
    targetPort: {port}
  selector:
    app: {unique_name}
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {unique_name}
  namespace: {developer_id}
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /
spec:
  rules:
  - host: {unique_name}.{developer_id}.apps.k3s.company.com
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: {unique_name}
            port:
              number: {port}
"""
    return {
        'namespace': namespace_yaml,
        'application': app_yaml,
        'unique_name': unique_name,
        'developer_id': developer_id
    }

def update_github_repo(manifests, github_token, repo_name, branch='main'):
    """Update manifest files in GitHub repository."""
    try:
        g = Github(github_token)
        repo = g.get_repo(repo_name)
        
        # Create or update namespace manifest
        namespace_path = f"manifests/{manifests['developer_id']}/namespace.yaml"
        try:
            # Try to get existing file
            contents = repo.get_contents(namespace_path, ref=branch)
            repo.update_file(
                namespace_path,
                f"Update namespace for {manifests['developer_id']}",
                manifests['namespace'],
                contents.sha,
                branch=branch
            )
        except Exception:
            # File doesn't exist, create it
            repo.create_file(
                namespace_path,
                f"Create namespace for {manifests['developer_id']}",
                manifests['namespace'],
                branch=branch
            )
        
        # Create new application manifest
        app_path = f"manifests/{manifests['developer_id']}/apps/{manifests['unique_name']}.yaml"
        repo.create_file(
            app_path,
            f"Create manifest for {manifests['unique_name']}",
            manifests['application'],
            branch=branch
        )
        
        return {
            'status': 'success',
            'app_url': f"http://{manifests['unique_name']}.{manifests['developer_id']}.apps.k3s.company.com",
            'manifest_path': app_path
        }
        
    except Exception as e:
        return {
            'status': 'error',
            'message': str(e)
        }

def lambda_handler(event, context):
    """Lambda handler to process requests and update GitHub."""
    try:
        # Get parameters from event
        body = json.loads(event['body'])
        developer_id = body['developer_id']
        image_name = body['image_name']
        port = int(body['port'])
        
        # Get GitHub token from environment
        github_token = os.environ['GITHUB_TOKEN']
        repo_name = os.environ['GITHUB_REPO']
        
        # Create manifests
        manifests = create_manifests(developer_id, image_name, port)
        
        # Update GitHub repository
        result = update_github_repo(manifests, github_token, repo_name)
        
        if result['status'] == 'success':
            return {
                'statusCode': 200,
                'headers': {
                  'Content-Type': 'application/json',
                  'Access-Control-Allow-Origin': '*',
                  'Access-Control-Allow-Headers': 'Content-Type',
                  'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
                },
                'body': json.dumps({
                    'message': 'Manifests updated successfully',
                    'app_url': result['app_url'],
                    'manifest_path': result['manifest_path']
                })
            }
        else:
            return {
                'statusCode': 500,
                'headers': {
                  'Content-Type': 'application/json',
                  'Access-Control-Allow-Origin': '*',
                  'Access-Control-Allow-Headers': 'Content-Type',
                  'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
                },
                'body': json.dumps({
                    'message': f"Error updating manifests: {result['message']}"
                })
            }
            
    except Exception as e:
        return {
            'statusCode': 500,
            'headers': {
                  'Content-Type': 'application/json',
                  'Access-Control-Allow-Origin': '*',
                  'Access-Control-Allow-Headers': 'Content-Type',
                  'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': json.dumps({
                'message': f"Error processing request: {str(e)}"
            })
        }