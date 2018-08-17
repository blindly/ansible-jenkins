#!/bin/bash
#
# This script is meant to run off a docker image from Jenkins
# It is meant to test a lot of ansible modules
# It expects the hierarchy to be: tasks, vars as top level.
# Under tasks, directory, then task and test

# Removing Default Hosts Inventory
rm /etc/ansible/hosts -f

# You must specify the directory where the playbooks are
main_directory=$1
if [ -z "$main_directory" ] ; then
    echo "Error: Missing directory"
    echo "$0 <directory_name> <optional extra-vars>"
    exit
fi

# Option to override any vars. Given how they are, this might work for just one
# Arrays start at 1
extra_vars=$2

# Variables
success_provision=0
fail_provision=0
success_categories=()
fail_categories=()
home=`pwd`

# Start at Home
cd $home

# Remove any retry files
find . -name *.retry -type f -delete

for dir in $(ls -1 $main_directory/tasks);
do
    cd $home
    if [ -d "$main_directory/tasks/$dir/test" ] ; then
        for ansible_test in $(ls -1 $main_directory/tasks/$dir/test);
        do
            cd $home
            echo "PWD: "`pwd`
            if [ -d "$main_directory/tasks/$dir/test" ] ; then
                cd $main_directory/tasks/$dir/test
                if [ -e $ansible_test ] ; then

                    filename=$(basename -- "$ansible_test")
                    extension="${filename##*.}"
                    filename="${filename%.*}"

                    if [ $extension == "yml" ] ; then

                        echo "Running $ansible_test"
                        if [ -n $extra_vars ] ; then
                            ansible-playbook $ansible_test --connection=local --extra-vars "${extra_vars}"
                        else
                            ansible-playbook $ansible_test --connection=local
                        fi
                        rc=$?
                        if [[ $rc != 0 ]]; then
                            echo "=> PROVISIONING FAIL"
                            fail_provision=$((fail_provision+1))
                            fail_categories+=($dir/$ansible_test)
                        else
                            success_provision=$((success_provision+1))
                        fi

                    fi
                fi
            fi
        done
    else
        echo "No tests found"
    fi

done

echo "Success: $success_provision"
echo
echo "Failures: $fail_provision"
printf '%s\n' "${fail_categories[@]}"
