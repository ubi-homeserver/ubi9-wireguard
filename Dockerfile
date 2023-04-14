FROM registry.redhat.io/ubi9/ubi-init:latest

# broken subscription manager in container since ubi9
# https://access.redhat.com/discussions/5889431
ARG SMDEV_CONTAINER_OFF=1
ARG REDHAT_ORG_ID
ARG REDHAT_ACTIVATION_KEY

#crazy entitlement system https://access.redhat.com/solutions/3341191
RUN --mount=type=secret,id=entitlement subscription-manager import --certificate=/run/secrets/entitlement && \
    subscription-manager register --org=${REDHAT_ORG_ID} --activationkey=${REDHAT_ACTIVATION_KEY} --name GithubActions && \
    dnf install -y iputils iproute nftables wireguard-tools --enablerepo=rhel-9-for-x86_64-baseos-rpms --enablerepo=rhel-9-for-x86_64-appstream-rpms && \
    subscription-manager remove --all && subscription-manager unregister && subscription-manager clean && \
    chown 1001:0 /etc/wireguard && chmod g+rwx -R /etc/wireguard && \
    systemctl enable systemd-resolved && \
    systemctl enable wg-quick@wg0

CMD [ "/sbin/init" ]
