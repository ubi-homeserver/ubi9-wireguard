FROM registry.redhat.io/ubi9/ubi-init:latest

RUN dnf install -y iputils iproute nftables wireguard-tools && \
    chown 1001:0 /etc/wireguard && chmod g+rwx -R /etc/wireguard && \
    systemctl enable systemd-resolved && \
    systemctl enable wg-quick@wg0

CMD [ "/sbin/init" ]
