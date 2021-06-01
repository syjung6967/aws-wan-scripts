Initial app setup:
```sh
./create_regional_policies.sh
./create_regional_accounts.sh
```

Scripts are on cmds/ directory.

Execution:
```sh
./execute_command.sh cmds/stop-all-instances.sh
```

Execution (no app speicified):
```sh
DISABLE_APP_FILTER=1 ./execute_command.sh cmds/stop-all-instances.sh
```

Main directories for each region are located in <code>$AWS_PWD</code> (<code>resources/$AWS_PROFILE_NAME/$AWS_APP_NAME</code>).
Each region directory contains shared home directory for instances <code>$AWS_PWD/$REGION</code> (TODO) and AWS CLI command logs in <code>$AWS_PWD/results/$REGION.stdout</code>.

Clean app setup:
```sh
./delete_regional_accounts.sh
./delete_regional_policies.sh
```

TrobleShooting:
* Q. Not enough credentials for running spot instances?
* A. Run <code>aws iam create-service-linked-role --aws-service-name spot.amazonaws.com</code> on host before app setup.
