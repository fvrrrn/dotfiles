HOSTNAME = $(shell hostname)

ifndef HOSTNAME
 $(error Hostname unknown)
endif

switch:
	sudo nixos-rebuild switch --flake .#${HOSTNAME} -L

boot:
	sudo nixos-rebuild boot --flake .#${HOSTNAME} -L

test:
	sudo nixos-rebuild test --flake .#${HOSTNAME} -L

update:
	nix flake update

upgrade:
	make update && make switch
