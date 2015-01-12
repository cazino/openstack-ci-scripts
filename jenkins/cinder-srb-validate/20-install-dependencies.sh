#!/bin/bash -xue

sudo aptitude install -y "linux-headers-$(uname -r)" make gcc lvm2 thin-provisioning-tools
