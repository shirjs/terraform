resource "aws_s3_bucket" "website_bucket" {
  bucket = var.bucket_name
}

resource "aws_s3_bucket_website_configuration" "website_config" {
  bucket = aws_s3_bucket.website_bucket.id

  index_document {
    suffix = "index.html"
  }
}

resource "aws_s3_bucket_public_access_block" "website_public_access" {
  bucket = aws_s3_bucket.website_bucket.id

  block_public_acls = false
  block_public_policy = false
  ignore_public_acls = false
  restrict_public_buckets = false
}

resource "time_sleep" "wait_for_public_access_block" {
  depends_on = [aws_s3_bucket_public_access_block.website_public_access]
  create_duration = "10s"
}

resource "aws_s3_bucket_policy" "website_bucket_policy" {
  bucket = aws_s3_bucket.website_bucket.id 
  depends_on = [time_sleep.wait_for_public_access_block]

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid = "PublicReadGetObject"
        Effect = "Allow"
        Principal = "*"
        Action = ["s3:GetObject"]
        Resource = "${aws_s3_bucket.website_bucket.arn}/*"
      }
    ]
  })
}

locals {
  html_content = <<-EOT
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Lambda Functions Dashboard</title>
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
        }
        button:hover {
            background-color: #0056b3;
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
        <h1>Lambda Functions Dashboard</h1>
        
        <!-- Input fields for developer_id, image_name, and port -->
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
            ${join("\n            ", [
              for idx, lambda in var.lambda_integrations : 
              <<-BUTTON
              <button onclick="callLambda${idx}()">${lambda.button_text}</button>
              <div id="response${idx}" class="response"></div>
              BUTTON
            ])}
        </div>
    </div>

    <script>
        ${join("\n        ", [
          for idx, lambda in var.lambda_integrations :
          <<-SCRIPT
          async function callLambda${idx}() {
              const responseDiv = document.getElementById('response${idx}');
              responseDiv.style.display = 'block';
              responseDiv.innerHTML = 'Loading...';

              // Capture input values
              const developerId = document.getElementById('developer_id').value;
              const imageName = document.getElementById('image_name').value;
              const port = document.getElementById('port').value;

              // Validate inputs
              if (!developerId || !imageName || !port) {
                  responseDiv.innerHTML = 'Please fill in all required fields.';
                  return;
              }
              
              try {
                  const response = await fetch('${lambda.api_endpoint}/${lambda.route_path}', {
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
          SCRIPT
        ])}
    </script>
</body>
</html>
EOT
}


resource "aws_s3_object" "index_html" {
  bucket = aws_s3_bucket.website_bucket.id
  key = "index.html"
  content_type = "text/html"
  content = local.html_content
  etag = md5(local.html_content)
}