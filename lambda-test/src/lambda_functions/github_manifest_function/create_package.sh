python3 -m venv venv
source venv/bin/activate
mkdir -p deployment_package
pip install -t deployment_package/ PyGithub
cd deployment_package
cp ../lambda_function.py .
zip -r ../deployment_package.zip .
cd ..
rm -rf deployment_package venv