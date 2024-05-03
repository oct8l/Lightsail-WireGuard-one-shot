# What is the purpose of this repo?

This repo allows us to stand up/tear down an AWS Lightsail instance running a WireGuard server. We can achieve this with the help of HashiCorp's [Terraform](https://www.terraform.io/). It is an infrastructure as code tool (or IaC), which allows us to describe the end state we want, and then Terraform does the heavy lifting for us together with AWS Lightsail (in this specific case at least) to achieve that state.

# How do I run it?

*Note*: This will stand up an AWS Lightsail instance just fine, but it's really intended to be run with the `run-all.sh` script from the parent directory. 😊

## A little setup first

Inside of this `terraform` folder, there is a file named ".envrc.example" which has your preferred region to run the VM. This should be copied to a file named ".envrc" and the values edited. Replace everything in <>s with your own information.

*Note*: the `.envrc` setup utilizes the package [direnv](https://direnv.net/) to automatically load and unload environment variables when switching directories. Like most things in Linux, there are a million different ways to do this, but this is the easy (lazy 😊) way that I like to use. If you're feeling particularly motivated, you can change the Terraform file to use variables in another way besides environment variables.

## Creating and destroying

### Creating instances

Once in the `terraform` folder, you can now either create or destroy the WireGuard server!

Since Terraform is declarative, you can attempt to `apply` the files any time with no issues. Either it creates instances if nothing exists, or if the cluster already exists, it won't do anything (or will correct things like the location or tier of instance to use).

To spin up the server, you can run:
```
terraform apply
```

Be sure to read the prompt and see that only 1 instance will be created, and then you can confirm with "yes" at the Terraform prompt. You can also append `-auto-approve` to skip the prompt.

### Destroying instances

To destroy the instances, you can run the following command:
```
terraform destroy
```

Be sure to read the prompt and see that only 1 instance will be destroyed, and then you can confirm with "yes" at the Terraform prompt. You can also append `-auto-approve` to skip the prompt.
```
