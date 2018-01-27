#!/usr/bin/env bash
set -e

function _create()
{
    # Create 3 docker machines
    echo "Creating virtualbox machines. This might take some time. \n\n"
    for MACHINE in 'manager' 'worker'
    do
        docker-machine create --driver=virtualbox --virtualbox-memory "512" $MACHINE >> /dev/null &
    done

    wait
    echo 'Machines created'

    echo 'Creating swarm cluster'
    # Setup swarm manager
    MANAGER_IP=$(docker-machine ip 'manager')
    JOIN_CMD=$(docker-machine ssh 'manager' -- docker swarm init --advertise-addr "$MANAGER_IP" | grep 'docker swarm join --token')

	# Setup worker
    docker-machine ssh 'worker' -- "$JOIN_CMD" >> /dev/null

	#setup hosts file
	echo "we'll need root access to setup your hosts file."
	echo "$MANAGER_IP vote.demo.com visualizer.demo.com results.demo.com" | sudo tee --append /etc/hosts

	# deploy stack
	if [ ! -d manager ]; then
		mkdir manager
	fi
	docker-machine mount manager:/home/docker manager
	cp -r stack/* manager/
	docker-machine ssh 'manager' -- sudo chown -R root ssl
	docker-machine ssh 'manager' -- docker stack deploy --compose-file docker-stack.yml vote

	echo "Stack deployed. Go to vote.demo.com or results.demo.com to access the application."
	echo "It may be a while until the services are available."
}


function _destroy()
{
	#remove from hosts file
	echo "we'll need root access to restore your hosts file."
	sudo sed --in-place '/vote\.demo\.com visualizer\.demo\.com results\.demo\.com/d' /etc/hosts

	for MACHINE in 'manager' 'worker'
    do
        docker-machine rm -y $MACHINE &
    done
	wait
	echo 'Done. Cluster destroyed'
}

case $1 in
	up) _create
	;;
	down) _destroy
	;;
	*) echo 'usage: manage-cluster.sh up|down'
esac


