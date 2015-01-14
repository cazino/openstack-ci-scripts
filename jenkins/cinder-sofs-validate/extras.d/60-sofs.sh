# sofs.sh - DevStack extras script

if [[ "$1" == "stack" && "$2" == "post-config" ]]; then
    if is_service_enabled nova; then
        echo_summary "Configuring Nova for Scality SOFS"
        iniset $NOVA_CONF libvirt scality_sofs_mount_point /sofs
        iniset $NOVA_CONF libvirt scality_sofs_config /etc/sfused.conf
    fi
fi
