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

Clean app setup:
```sh
./delete_regional_accounts.sh
./delete_regional_policies.sh
```
