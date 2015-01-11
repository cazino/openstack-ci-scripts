#!/bin/bash -xue

echo "Loading srb..."
sudo insmod ./srb/srb.ko

sudo groupadd jenkins
sudo gpasswd -a jenkins jenkins

sudo useradd -m -U stack
sudo gpasswd -a stack wheel

export ZUUL_PROJECT=openstack-dev/sandbox
export ZUUL_BRANCH=master

export PYTHONUNBUFFERED=true

export DEVSTACK_GATE_TIMEOUT=180
export DEVSTACK_GATE_TEMPEST=1
export RE_EXEC=true

export DEVSTACK_GATE_TEMPEST_REGEX=tempest.api.volume

function pre_test_hook() {
    echo "Running pre test hook"

    ls /opt/stack
    ps afx

    echo "Setting up devstack utility scripts"

    echo "Loading SRB"
}
export -f pre_test_hook

./devstack-gate/devstack-vm-gate-wrap.sh
RC=$?

cd $WORKSPACE
mkdir jenkins-logs
cp -R /opt/stack/logs/* jenkins-logs/
sudo chown jenkins jenkins-logs/*

exit $RC
