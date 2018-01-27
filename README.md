# Swarm with nginx and per-app SSL certificates
Use nginx with different SSL certificates for each application on a docker swarm

---

Sets up the [Example Docker Voting App](https://github.com/dockersamples/example-voting-app) with SSL using nginx on a two-node swarm cluster using docker-machine Virtualbox VMs

## Prerequisites

 - docker-machine
 - virtualbox
 - sshfs

on ubuntu, you can quickly install everything with this snippet:
```
sudo apt update && sudo apt install -y curl virtualbox sshfs && \
curl -L https://github.com/docker/machine/releases/download/v0.13.0/docker-machine-`uname -s`-`uname -m` >/tmp/docker-machine && \
chmod +x /tmp/docker-machine && \
sudo cp /tmp/docker-machine /usr/local/bin/docker-machine
```

## Running

run `./manage-cluster up` to create the swarm cluster
it will take some time to be available

then go to vote.demo.com and results.demo.com
each will have it's own certificate

## Teardown

run `./manage-cluster down`
