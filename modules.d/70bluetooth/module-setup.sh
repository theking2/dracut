#!/bin/bash
# This module is only loaded on demand
if [[ -z "$hostonly" ]]; then
    return 255
fi

check() {
    if command -v hciconfig &>/dev/null; then
        # hciconfig lists Bluetooth controllers. Check if Bluetooth devices are present
        hciconfig | grep -q . && return 0
    fi

    if [[ -d "/sys/class/bluetooth" ]]; then
        # Another way: Check if there are any Bluetooth device entries. Filter based on Class of Device and check if module is already added,
        # and if Appearance is set to the value defined for keyboard (0x03C1)
        [ -d "/sys/class/bluetooth" ] && grep -qsiE -e 'Class=0x[0-9a-f]{3}5[4c]0' -e 'Appearance=0x03c1' /var/lib/bluetooth/*/*/info \
            && [[ " $dracutmodules $add_dracutmodules $force_add_dracutmodules $prefer_dracutmodules " != *\ bluetooth\ * ]] \
            && dwarn "If you need to use Bluetooth during boot, please add the \"bluetooth\" Dracut module explicitly."
    fi

    return 255
}

install() {
    inst_multiple -o \
        hciattach hciconfig hcitool rfcomm sdpd \
        l2ping l2test

    inst_simple /etc/udev/rules.d/97-bluetooth.rules
}

install_initqueue() {
    return
}
