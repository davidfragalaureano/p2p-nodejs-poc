WORKSPACE := .network
# Subnet that docker will use
SUBNET := 10.0.0.0/16
RANGE_PORT := 10000
DEFAULT_CONTAINER_PORT := 8080

#colors
BLUE :=\033[1;34m
GREEN:=\033[0;32m
RED:=\033[0;31m
NC:=\033[0m


clean: down $(shell find . -type d -name "node-*" | awk -F '/' '{print $$3"/down"}')
	@# docker network rm p2p-net || exit 0
	rm -rf .network

# Creates a workspace where all node-*/ will be saved
network:
	mkdir -p .network


# Create a new node environment by linking to the template docker-compose.yaml file.
node-%: network
	$(eval N = $*)
	$(eval ENV = $(WORKSPACE)/node-$(N)/.env)
	$(eval NODES := $(shell find . -maxdepth 2 -type d -name "node-*" | sed 's/.\/.network\///' | sed 's/$$/:$(DEFAULT_CONTAINER_PORT)/' | tail -r))

	mkdir -p $(WORKSPACE)/node-$(N)

	@# After node dir is created, we get all the previous nodes and add them as peers to the new one 
	$(eval NODES := $(if $(NODES), node-$(N):$(DEFAULT_CONTAINER_PORT) $(NODES), node-$(N):$(DEFAULT_CONTAINER_PORT)))

	@# Create an .env file to hold template variables for docker-compose.
	echo NODE_NUMBER=$(N) >> $(ENV)
	echo NODE_NAME=node-$(N) >> $(ENV)
	echo BOOTSTRAP_HOSTNAMES=$(NODES) >> $(ENV)

	@# Calculate the port for this node, starting at 10000 for the first node and increasing by 1 (node-0 -> 10000) for the next one and so on.
	echo NODE_PORT=$$(( $(RANGE_PORT) + $(N) )) >> $(ENV)

	@# Alternatively just make a copy so you can edit it independently.
	cp ${PWD}/template/docker-compose.yaml ./$(WORKSPACE)/node-$(N)/docker-compose.yaml
	cp ${PWD}/template/docker-compose.override.yaml ./$(WORKSPACE)/node-$(N)/docker-compose.override.yaml


# Start node.
node-%/up: node-% .make/docker/network
	cd $(WORKSPACE)/node-$* && docker-compose up -d

# Tear down node. Using docker to delete logs owned by root for now.
node-%/down: 
	$(eval NODE_DIR = $(WORKSPACE)/node-$*)
	if [ -d $(NODE_DIR) ]; then \
		cd $(NODE_DIR) && docker-compose down ; \
	fi;

# Start common components.
up: .make/docker/network .casperlabs
	@echo "${GREEN}STARTING NODES ...${NC}\n"
	docker-compose -p p2p-net up -d --remove-orphans

# Stop common components.
down:
	@echo "${GREEN}REMOVING  NODES...${NC}\n"
	-docker-compose -p p2p-net down
	
.make/docker/network:
	@echo "${GREEN}STARTING DOCKER NETWORK ...${NC}\n"
	-docker network create p2p-net --subnet $(SUBNET)
