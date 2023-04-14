FROM registry.redhat.io/ubi9/ubi-init:latest

RUN dnf install -y iputils iproute nftables wireguard-tools --enablerepo=rhel-9-for-x86_64-baseos-rpms --enablerepo=rhel-9-for-x86_64-appstream-rpms && \
    chown 1001:0 /etc/wireguard && chmod g+rwx -R /etc/wireguard && \
    systemctl enable systemd-resolved && \
    systemctl enable wg-quick@wg0

CMD [ "/sbin/init" ]
