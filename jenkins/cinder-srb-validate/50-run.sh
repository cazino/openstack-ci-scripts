#!/bin/bash -xue

export MY_LVM_CONF=/etc/lvm/lvm.conf

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
    local xtrace=$(set +o | grep xtrace)
    local eerror=$(set +o | grep errexit)

    set -o xtrace
    set -o errexit

    echo "Running pre test hook"

    echo "Updating LVM configuration"
    sudo sed -i 's/# types = \[\ "fd",\ 16\ \]/types = [ "srb", 16 ]/' $MY_LVM_CONF

    echo "Setting up devstack utility scripts"
    sudo cp jenkins/cinder-srb-validate/cinder_backends/srb /opt/stack/new/devstack/lib/cinder_backends/
    sudo cp jenkins/cinder-srb-validate/cinder_plugins/srb /opt/stack/new/devstack/lib/cinder_plugins/

    $eerror
    $xtrace
}
export -f pre_test_hook

DEVSTACK_LOCAL_CONFIG_FILE=$(mktemp)

cat > $DEVSTACK_LOCAL_CONFIG_FILE << EOF
CINDER_ENABLED_BACKENDS=srb:srb-1
CINDER_SRB_BASE_URLS=http://$JCLOUDS_IPS:8000/

TEMPEST_VOLUME_VENDOR='Scality'
TEMPEST_STORAGE_PROTOCOL='Scality Rest Block Device'
EOF

export DEVSTACK_LOCAL_CONFIG=$(cat $DEVSTACK_LOCAL_CONFIG_FILE)

rm $DEVSTACK_LOCAL_CONFIG_FILE

./devstack-gate/devstack-vm-gate-wrap.sh
RC=$?

cd $WORKSPACE
mkdir jenkins-logs
cp -R /opt/stack/logs/* jenkins-logs/
sudo chown jenkins jenkins-logs/*

exit $RC
