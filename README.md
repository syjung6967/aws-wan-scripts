Parallel AWS instance setup tool across worldwide regions.
Implemented by bash scripts using AWS CLI invoked on docker.

Default VPC and subnets are chosen for launching instances.

Launch your instances accross worldwide regions within 20 seconds.
(For initial environment setup, it takes about one minute)

# Similar projects
* [vagrant-aws](https://github.com/mitchellh/vagrant-aws): vagrant plugin for managing AWS-compatible box

# Package requirements
For host (Ubuntu):
* **docker** for parallelizing regional AWS CLI commands including host commands.
* **jq** for formatting AWS CLI output.
* **sshfs** for mounting instance filesystems.

```sh
sudo apt install docker jq sshfs
sudo systemctl enable --now docker
```

For instance:
* None (but you can install additional packages when launching instances by using `$AWS_USER_DATA` in env.sh)

## Docker setup
Add current user into docker group:

```sh
sudo usermod -aG docker $USER
sudo loginctl terminate-user $USER # WARNING: your all login sessions are terminated.

#
# Login again.
#

docker run hello-world # Check the user has permission for docker.
```

Get the latest docker image for the AWS CLI:

```sh
docker pull amazon/aws-cli
```

# Initial app setup
Check env.sh before executing setup scripts.

```sh
./create_regional_policies.sh # Create regional policies.
./create_regional_accounts.sh # Create regional accounts.

#
# For AWS-side complete account setup, wait about 10 seconds.
#

./execute_command.sh cmds/init_region.sh # Create app keys and default VPC and subnets.
```

# Directory structure
* cmds: scripts for executing by each regional credentials.
* resources: root management directory. Subdirectories are created when running setup scripts.
  * `$AWS_PROFILE_NAME`: AWS account profile name for admin. (default: "default")
    * `$AWS_APP_NAME` (absolute path: `$AWS_PWD`): namespace for the app. (default: "myapp")
      * keys: private key files (*.pem) for each region.
      * results: standard output for each regional scripts.
      * `$REGION`: AWS region name. (not alias such as Virginia)
        * .aws: AWS CLI config for the region.
        * `$AZ`: availalbe zone for the region.
          * `$INSTANCE`: mount point of home directory for each instance named with its public IPv4 address.

The instance information accross the regions is saved on `$AWS_PWD` by executing `export_connection_info.sh`.

# Execution
The regional scripts can be run in one region or across all available regions specified in env.sh

```sh
./execute_command.sh cmds/ec2-run-instances.sh # Run instances according to env.sh

#
# Wait until all instances run SSH daemon.
#

./mount_remote_filesystems.sh # Mount filesystems after running export_connection_info.sh

./execute_command.sh cmds/stop-all-instances.sh # Stop all instances.
./execute_command.sh cmds/terminate-all-instances.sh # Terminate all instances.
```

## Execution (no app speicified)
```sh
DISABLE_APP_FILTER=1 ./execute_command.sh cmds/stop-all-instances.sh
```

# Clean app setup
```sh
./execute_command.sh cmds/ec2-delete-key-pair.sh # For security, delete unused key pairs.
./delete_regional_accounts.sh
./delete_regional_policies.sh
```

# TrobleShooting
* Q. Not enough credentials for running spot instances?
* A. Run `aws iam create-service-linked-role --aws-service-name spot.amazonaws.com` on host before app setup.
* Q. How to handle MaxSpotInstanceCountExceeded error?
* A. Each instance type has some limit of its spot instance counts to restrict abuse. For more information, See <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-limits.html>.

# TODO
* Reduce manual procedures.
* Add per-instance commands.
* Support hybrid use between spot and on-demand instances.
* Support to specify sub zones.
* Automatically delete files on obsolete containers.
* Add LICENSE.
