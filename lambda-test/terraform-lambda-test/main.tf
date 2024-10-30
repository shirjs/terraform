provider "aws" {
  region = "us-east-1"
}

module "api_gateway" {
  source = "../../modules/api_gateway"

  api_name = "hello-api"
}

# iam roles will be used across lambda functions
resource "aws_iam_role" "lambda_role" {
  name = "hello_lambda_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_policy" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role = aws_iam_role.lambda_role.name
}

# first function
# module "hello_lambda" {
#   source = "../../modules/lambda_api_integration"
#   lambda_function_name = "hello_function"
#   lambda_handler = "lambda_function.lambda_handler"
#   lambda_role_arn = aws_iam_role.lambda_role.arn
#   api_id = module.api_gateway.api_id
#   api_execution_arn = module.api_gateway.api_execution_arn
#   route_path = "hello"
#   deployment_package_path = "../src/lambda_functions/test_function/deployment_package.zip"

#   environment_variables = {
#     PYTHONPATH = "/var/task/package"
#   }
# }

# second function
module "github_manifest_lambda" {
  source = "../../modules/lambda_api_integration"

  lambda_function_name = "github_manifest_function"
  lambda_handler = "lambda_function.lambda_handler"
  lambda_role_arn = aws_iam_role.lambda_role.arn
  api_id = module.api_gateway.api_id
  api_execution_arn = module.api_gateway.api_execution_arn
  route_path = "deploy"

  deployment_package_path = "../src/lambda_functions/github_manifest_function/deployment_package.zip"

  environment_variables = {
    PYTHONPATH = "/var/task/package"
    GITHUB_TOKEN = var.github_token
    GITHUB_REPO = var.github_repo
    K3S_INSTANCE_IP = var.k3s_instance_ip
  }
}


module "website" {
  source = "../../modules/s3_website"

  bucket_name = "hello-lambda-website-bucket-${random_string.suffix.result}"

  # lambda_integrations = [
  #   {
  #     function_name = module.hello_lambda.lambda_function_name
  #     api_endpoint = module.api_gateway.api_endpoint
  #     route_path = "hello"
  #     button_text = "activate function"
  #   },
  #   {
  #     function_name = module.github_manifest_lambda.lambda_function_name
  #     api_endpoint = module.api_gateway.api_endpoint
  #     route_path = "deploy"
  #     button_text = "deploy to k3s"
  #   }
  # ]
}

resource "random_string" "suffix" {
  length = 8
  special = false
  upper = false
}

variable "github_token" {
  description = "github access"
  type = string 
  sensitive = true
}

variable "github_repo" {
  description = "github repo name"
  type = string
}

variable "k3s_instance_ip" {
  description = "ip of the k3 instance"
  type = string
}





locals {
  github_manifest_html = <<-EOT
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>K3s Deployment Dashboard</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background-color: white;
            padding: 20px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .input-group {
            margin-bottom: 15px;
        }
        label {
            display: block;
            margin-bottom: 5px;
        }
        input {
            width: 100%;
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
            box-sizing: border-box;
        }
        .button-container {
            margin-top: 20px;
        }
        button {
            padding: 12px 20px;
            background-color: #007bff;
            color: white;
            border: none;
            border-radius: 4px;
            cursor: pointer;
            transition: background-color 0.3s;
            margin-right: 10px;
        }
        button:hover {
            background-color: #0056b3;
        }
        button.delete {
            background-color: #dc3545;
        }

        .response {
            margin-top: 20px;
            padding: 10px;
            border: 1px solid #ddd;
            border-radius: 4px;
            display: none;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>K3s Deployment Dashboard</h1>
        
        <div class="input-group">
            <label for="developer_id">Developer ID</label>
            <input type="text" id="developer_id" placeholder="Enter Developer ID" required>
        </div>
        <div class="input-group">
            <label for="image_name">Image Name</label>
            <input type="text" id="image_name" placeholder="Enter Docker Image Name" required>
        </div>
        <div class="input-group">
            <label for="port">Port</label>
            <input type="number" id="port" placeholder="Enter Port Number" required>
        </div>

        <div class="button-container">
            <button onclick="deployToK3s()">Deploy to k3s</button>
            <button onclick="deleteFromK3s()" class="delete">Delete all</button>
        </div>
        <div id="response" class="response"></div>
    </div>

    <script>
        async function deployToK3s() {
            const responseDiv = document.getElementById('response');
            responseDiv.style.display = 'block';
            responseDiv.innerHTML = 'Loading...';

            const developerId = document.getElementById('developer_id').value;
            const imageName = document.getElementById('image_name').value;
            const port = document.getElementById('port').value;

            if (!developerId || !imageName || !port) {
                responseDiv.innerHTML = 'Please fill in all required fields.';
                return;
            }
            
            try {
                const response = await fetch('${module.api_gateway.api_endpoint}/deploy', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        developer_id: developerId,
                        image_name: imageName,
                        port: parseInt(port, 10)
                    })
                });
                const data = await response.json();
                responseDiv.innerHTML = JSON.stringify(data, null, 2);
            } catch (error) {
                responseDiv.innerHTML = 'Error: ' + error.message;
            }
        }

        async function deleteFromK3s() {
            const developerId = document.getElementById('developer_id').value;
            if (!developerId || !confirm('Delete all deployments for ' + developerId + '?')) return;
            
            const responseDiv = document.getElementById('response');
            responseDiv.style.display = 'block';
            responseDiv.innerHTML = 'Deleting...';

            try {
                const response = await fetch('${module.api_gateway.api_endpoint}/deploy', {
                    method: 'POST',
                    headers: {
                        'Content-Type': 'application/json'
                    },
                    body: JSON.stringify({
                        operation: 'delete',
                        developer_id: developerId
                    })
                });
                const data = await response.json();
                responseDiv.innerHTML = JSON.stringify(data, null, 2);
            } catch (error) {
                responseDiv.innerHTML = 'Error: ' + error.message;
            }
        }
    </script>
</body>
</html>
EOT
}

module "github_manifest_page" {
  source = "../../modules/s3_object"
  bucket_id = module.website.bucket_name
  object_key = "another.html"
  html_content = local.github_manifest_html
}