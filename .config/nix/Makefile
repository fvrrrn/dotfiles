HOSTNAME = $(shell hostname)

ifndef HOSTNAME
 $(error Hostname unknown)
endif

switch:
	nixos-rebuild switch --sudo --flake .#${HOSTNAME} -L

boot:
	nixos-rebuild boot --sudo --flake .#${HOSTNAME} -L

test:
	nixos-rebuild test --sudo --flake .#${HOSTNAME} -L

update:
	nix flake update

upgrade:
	make update && make switch
