import os
import json
import base64
import hashlib
from github import Github
from datetime import datetime

def generate_nodeport(developer_id, deploy_name):
    """Generate a predictable NodePort in the valid range (30000-32767)
    based on the developer_id and deploy_name."""
    # Create a hash of developer_id and deploy_name
    hash_input = f"{developer_id}-{deploy_name}"
    hash_value = int(hashlib.md5(hash_input.encode()).hexdigest(), 16)
    
    # Convert hash to a number in valid NodePort range (30000-32767)
    port_range = 32767 - 30000
    nodeport = 30000 + (hash_value % port_range)
    
    return nodeport

def create_manifests(developer_id, image_name, port):
    """Create Kubernetes manifest strings."""
    # Extract deployment name from image
    deploy_name = image_name.split('/')[-1].split(':')[0].replace('.', '-').replace('_', '-')
    timestamp = int(datetime.now().timestamp())
    unique_name = f"{deploy_name}-{timestamp}"
    
    # Generate predictable NodePort
    nodeport = generate_nodeport(developer_id, deploy_name)
    
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
  annotations:
    app.kubernetes.io/instance: {unique_name}
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
    nodePort: {nodeport}  # Specify the nodePort explicitly
  selector:
    app: {unique_name}
"""

    # Get instance IP from environment variable
    instance_ip = os.environ.get('K3S_INSTANCE_IP')
    if not instance_ip:
        raise ValueError("K3S_INSTANCE_IP environment variable is not set")

    return {
        'namespace': namespace_yaml,
        'application': app_yaml,
        'unique_name': unique_name,
        'developer_id': developer_id,
        'app_url': f"http://{instance_ip}:{nodeport}",
        'nodeport': nodeport
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
            'app_url': manifests['app_url'],
            'nodeport': manifests['nodeport'],
            'manifest_path': app_path
        }
        
    except Exception as e:
        return {
            'status': 'error',
            'message': str(e)
        }

def delete_developer_manifests(developer_id, github_token, repo_name, branch='main'):
    """Delete all manifests for a developer."""
    try:
        g = Github(github_token)
        repo = g.get_repo(repo_name)
        base_path = f"manifests/{developer_id}"
        
        # Get all contents recursively
        contents = repo.get_contents(base_path, ref=branch)
        while contents:
            file_content = contents.pop(0)
            if file_content.type == "dir":
                contents.extend(repo.get_contents(file_content.path, ref=branch))
            else:
                repo.delete_file(
                    file_content.path,
                    f"Delete manifest for {developer_id}",
                    file_content.sha,
                    branch=branch
                )
        return {'status': 'success', 'message': f'Deleted all manifests for {developer_id}'}
    except Exception as e:
        return {'status': 'error', 'message': str(e)}

def lambda_handler(event, context):
    """Lambda handler to process requests and update GitHub."""
    try:
        # Validate required environment variables
        required_env_vars = ['GITHUB_TOKEN', 'GITHUB_REPO', 'K3S_INSTANCE_IP']
        missing_vars = [var for var in required_env_vars if not os.environ.get(var)]
        if missing_vars:
            raise ValueError(f"Missing required environment variables: {', '.join(missing_vars)}")

        # Get parameters from event
        body = json.loads(event['body'])
        developer_id = body['developer_id']
        operation = body.get('operation', 'create')
        
        # Get GitHub token from environment
        github_token = os.environ['GITHUB_TOKEN']
        repo_name = os.environ['GITHUB_REPO']
        
        if operation == 'delete':
            result = delete_developer_manifests(developer_id, github_token, repo_name)
        else:
            image_name = body['image_name']
            port = int(body['port'])
            manifests = create_manifests(developer_id, image_name, port)
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
                    'message': 'operation completed successfully',
                    **(result if operation == 'create' else {})
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
            
    except ValueError as ve:
        return {
            'statusCode': 400,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            },
            'body': json.dumps({
                'message': str(ve)
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