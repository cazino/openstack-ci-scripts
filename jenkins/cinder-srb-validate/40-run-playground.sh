#!/bin/bash -xue

SRB_REPOSITORY=https://github.com/scality/RestBlockDriver.git
NODE=$JCLOUDS_IPS
SCRIPT_FILE=$(mktemp)

# Accept host key
ssh-keyscan $NODE >> ~/.ssh/known_hosts

# Start stuff

cat > $SCRIPT_FILE << EOF
sudo aptitude install -y git python-dev libffi-dev python-virtualenv

git clone $SRB_REPOSITORY srb

cd srb/playground
virtualenv --no-site-packages venv

set +u
source venv/bin/activate
set -u

pip install -r requirements.txt

# Make Circus listen on 0.0.0.0
sed -i s/127\.0\.0\.1$/0.0.0.0/ circus.ini

circusd --daemon circus.ini

ps afx
EOF

chmod a+x $SCRIPT_FILE

scp $SCRIPT_FILE $NODE:
ssh $NODE /bin/bash -xue $(basename $SCRIPT_FILE)
