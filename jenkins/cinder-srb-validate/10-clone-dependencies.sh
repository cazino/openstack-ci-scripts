#!/bin/bash -xue

rm -rf srb devstack-gate

git clone https://github.com/scality/RestBlockDriver.git srb
git clone https://git.openstack.org/openstack-infra/devstack-gate.git devstack-gate
