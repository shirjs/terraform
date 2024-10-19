# vpc-main
vpc-main is based on
1 submodule:
- vpc 

# eks-main
eks-main is based on
1 root module:
- vpc-main
2 submodules:
- vpc_config
- eks


# vpc-project
vpc-project is based on
1 submodule:
- vpc

# vpc-config-project
vpc-config-project is based on:
1 root module:
- vpc-project

1 submodule:
- vpc_config

# instances-project
instances-project is based on:
1 root module:
- vpc-project

# alb-project
alb-project is based on:
2 root modules:
- vpc-project
- instances-project

and requires to be functional:
1 root module:
vpc-config-project
