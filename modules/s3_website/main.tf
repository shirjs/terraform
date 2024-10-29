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
        .button-container {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
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
              
              try {
                  const response = await fetch('${lambda.api_endpoint}/${lambda.route_path}', {
                      method: 'POST',
                      headers: {
                          'Content-Type': 'application/json'
                      }
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