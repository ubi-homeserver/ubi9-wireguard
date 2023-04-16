# ubi9-wireguard
Simplest wireguard container to run wg-quick

## Purpose

I needed :
- a simple container to connect to a remote internet host (VPN Provider) 
- to be able to simply attach another container and be part of the vpn without extra configuration
- to have NAT and be able to reach attached containers from local network

## Requirements

This container has been tested on podman 4.2.0 with CNI networking on a RHEL9 host with Proton VPN

You will need to create secrets or mount directly the value to `/run/secrets/$SECRET_ID`:

```bash
printf '%s' 'YOURPRIVATEKEY_FROM_VPN_PROVIDER' | podman secret create client_privatekey -
printf '%s' 'PUBLICKEY_OF_VPN_PROVIDER_HOST' | podman secret create server_publickey -
```
Retrieve the values from your VPN provider, example: https://protonvpn.com/support/wireguard-configurations/

## Run

Then start your container or [create a service](container-wireguard.service) :

```bash
podman run \
        -d \
        --privileged \ # necessary for wg-quick or will trigger a write error on sysctl even if we set it here
        --name wireguard \
        -v /lib/modules:/lib/modules \
        --cap-add=NET_ADMIN \
        --sysctl=net.ipv4.conf.all.src_valid_mark=1 \
        --secret client_privatekey,type=mount,mode=0440 \
        --secret server_publickey,type=mount,mode=0440 \
        -e HOMENETS=192.168.1.0/24,10.88.0.0/24 \ # networks you want to route and NAT
        -e IPV4_ADDRESS=10.2.0.2 \         # provided by your VPN provider
        -e IPV4_DNS=10.2.0.1 \             # provided by your VPN provider
        -e VPN_PEER_HOST=185.159.157.239 \ # provided by your VPN provider
        -e VPN_PEER_PORT=51820 \           # provided by your VPN provider
        docker.io/ubihomelab/ubi9-wireguard:master
```

## Using the VPN

Simply use the network stack of the wireguard container:

```bash
podman run \
        --rm \
        -it \
        --network container:wireguard \
        registry.redhat.io/ubi9/ubi \
        curl ipecho.net/plain
```
