# SoftEther VPN + Alpine Linux

This repository contains a Dockerfile for generating an image
with [SoftEther VPN](https://www.softether.org/) and [Alpine Linux](https://alpinelinux.org/).

SoftEtherVPN is a simple and performant alternative to OpenVPN or StrongSwan. It provides a
handy CLI and supports multiple protocols including L2TP, IPsec, and OpenVPN.

## Running

Start the container:

    docker run -d \
      --name=softethervpn \
      --cap-add NET_ADMIN \
      --cap-add SYSLOG \
      -p 500:500/udp \
      -p 1194:1194/tcp \
      -p 1194:1194/udp \
      -p 1701:1701/udp \
      -p 4500:4500/udp \
      -p 5555:5555/tcp \
      softethervpn

The configuration is stored in `/etc/vpnserver/vpn_server.config`.

To preserve the settings locally, map the /etc/vpnserver like so:

    -v $PWD/config:/etc/vpnserver

## Logging Output

Logs are stored in `/var/log/vpnserver/*`. To show the latest log output:

    docker exec -it softethervpn sh -c "tail -f /var/log/vpnserver/*/*.log"

## Configuring

The HTTP status dashboard is available at `https://dockerip:5555/admin/`

Using the CLI to set administrator password, setup certificate, and enable VPN protocols:

    docker exec -it softethervpn vpncmd localhost /SERVER /ADMINHUB /CMD ServerPasswordSet
    docker exec -it softethervpn vpncmd localhost /SERVER /ADMINHUB /CMD ServerCertRegenerate yourhostname.com
    docker exec -it softethervpn vpncmd localhost /SERVER /ADMINHUB /CMD IPsecEnable
    docker exec -it softethervpn vpncmd localhost /SERVER /ADMINHUB /CMD OpenVpnEnable yes /PORTS:1194
    docker exec -it softethervpn vpncmd localhost /SERVER /ADMINHUB /CMD OpenVpnMakeConfig
    docker cp softethervpn:/openvpn_config.zip .

Enabling secure NAT and addng a user to the default hub:

    docker exec -it softethervpn vpncmd localhost /SERVER /HUB:DEFAULT /CMD SecureNatEnable
    docker exec -it softethervpn vpncmd localhost /SERVER /HUB:DEFAULT /CMD UserCreate myusername
    docker exec -it softethervpn vpncmd localhost /SERVER /HUB:DEFAULT /CMD UserPasswordSet myusername
    docker exec -it softethervpn vpncmd localhost /SERVER /HUB:DEFAULT /CMD StatusGet

