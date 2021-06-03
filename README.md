Parallel AWS instance setup tool across worldwide regions.
Implemented by bash scripts using AWS CLI invoked on docker.

Default VPC and subnets are chosen for launching instances.

Similar projects:
* [vagrant-aws](https://github.com/mitchellh/vagrant-aws): vagrant plugin for managing AWS-compatible box

Initial app setup:

Check env.sh before executing setup scripts.

```sh
./create_regional_policies.sh # Create regional policies.
./create_regional_accounts.sh # Create regional accounts.

# For AWS-side complete account setup, wait about 10 seconds.

./execute_command.sh cmds/init_region.sh # Create app keys and default VPC and subnets.
```

Scripts for executing by each regional credentials are on cmds/ directory.

Execution:
```sh
./execute_command.sh cmds/ec2-run-instances.sh # Run instances according to env.sh
./export_connection_info.sh # Collect instance information accross the regions.

# Check $AWS_PWD/ip_list.txt

./execute_command.sh cmds/stop-all-instances.sh
./execute_command.sh cmds/terminate-all-instances.sh
```

Execution (no app speicified):
```sh
DISABLE_APP_FILTER=1 ./execute_command.sh cmds/stop-all-instances.sh
```

Main directories for each region are located in <code>$AWS_PWD</code> (<code>resources/$AWS_PROFILE_NAME/$AWS_APP_NAME</code>).
Each region directory contains shared home directory for instances <code>$AWS_PWD/$REGION</code> (TODO) and AWS CLI command logs in <code>$AWS_PWD/results/$REGION.stdout</code>.

Clean app setup:
```sh
./execute_command.sh cmds/ec2-delete-key-pair.sh # For security, delete unused key pairs.
./delete_regional_accounts.sh
./delete_regional_policies.sh
```

TrobleShooting:
* Q. Not enough credentials for running spot instances?
* A. Run <code>aws iam create-service-linked-role --aws-service-name spot.amazonaws.com</code> on host before app setup.
* Q. How to handle MaxSpotInstanceCountExceeded error?
* A. Each instance type has some limit of its spot instance counts to restrict abuse. For more information, See <https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/using-spot-limits.html>.

TODO:
* File sync (rsync? sshfs?)
