#!/bin/bash
#
# This script is meant to run off a docker image from Jenkins
# It is meant to test a lot of ansible modules
# It expects the hierarchy to be: tasks, vars as top level.
# Under tasks, directory, then task and test
#

main_directory=$1
if [ -z "$main_directory" ] ; then
    echo "Missing directory"
    exit
fi

rm /etc/ansible/hosts -f

echo "=> Run Ansible"
success_provision=0
fail_provision=0
home=`pwd`
cd $home
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
                ansible-playbook $ansible_test --connection=local
                rc=$?
                if [[ $rc != 0 ]]; then
                    echo "=> PROVISIONING FAIL"
                    fail_provision=$((fail_provision+1))
                else
                    success_provision=$((success_provision+1))
                fi
            fi
        done
    else
        echo "No tests found"
    fi

done

echo "Success: $success_provision"
echo "Failures: $fail_provision"
