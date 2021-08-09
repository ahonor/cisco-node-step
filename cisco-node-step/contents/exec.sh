#!/usr/bin/env bash
set -eu

#env|grep RD_CONFIG

ssh_command="ssh"
#sshpass -p $password ssh $RD_CONFIG_SSH_OPTIONS

# Read the key data and write it to a temp file.
ssh_key_file=$(mktemp -t)
echo "$RD_CONFIG_SSH_KEY_STORAGE_PATH" > $ssh_key_file
chmod 600 $ssh_key_file

# Create a temp file for the script content.
command_script=$(mktemp -t "ios.command.script.XXXX")
echo "$RD_CONFIG_IOS_SCRIPT" > $command_script
chmod 600 $command_script
# Clean up temp files after exit
trap 'rm $command_script $ssh_key_file' EXIT


# Get ready to run

ssh_options=("-i $ssh_key_file" $RD_CONFIG_SSH_OPTIONS)

if [[ ${RD_CONFIG_DRY_RUN:-} == "true" ]]
then
	echo "ssh_key_file contents:"
	cat $ssh_key_file
	echo "[dry-run] $ssh_command ${ssh_options[*]} $RD_NODE_USERNAME@$RD_NODE_HOSTNAME ..."
	echo "$command_script" | while read line; do echo "[dry-run] $line"; done
else
	cat $command_script | $ssh_command ${ssh_options[*]} $RD_NODE_USERNAME@$RD_NODE_HOSTNAME
fi

exit $?
