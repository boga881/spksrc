#!/bin/sh

# Package
PACKAGE="mpd"
DNAME="Music Player Daemon"

# Others
INSTALL_DIR="/usr/local/${PACKAGE}"
PATH="${INSTALL_DIR}/bin:/usr/local/bin:/bin:/usr/bin:/usr/syno/bin"
RUNAS="mpd"
UPGRADE="/tmp/${PACKAGE}.upgrade"


preinst ()
{
    exit 0
}

postinst ()
{
    # Link
    ln -s ${SYNOPKG_PKGDEST} ${INSTALL_DIR}

    # Install busybox stuff
    ${INSTALL_DIR}/bin/busybox --install ${INSTALL_DIR}/bin

    # Create audio group for ALSA
    addgroup -S audio

    # Create user
    adduser -h ${INSTALL_DIR}/var -g "${DNAME} User" -G users -s /bin/sh -S -D ${RUNAS}
    addgroup ${RUNAS} audio

    # Correct the files ownership
    chown -R ${RUNAS}:root ${SYNOPKG_PKGDEST}

    exit 0
}

preuninst ()
{
    # Remove the user (if not upgrading)
    if [ ! -f ${UPGRADE} ]; then
        delgroup ${RUNAS} audio
        delgroup ${RUNAS} users
        deluser ${RUNAS}
    fi

    exit 0
}

postuninst ()
{
    # Remove link
    rm -f ${INSTALL_DIR}

    exit 0
}

preupgrade ()
{
    # Save some stuff
    rm -fr /tmp/${PACKAGE}
    mkdir /tmp/${PACKAGE}
    mkdir /tmp/${PACKAGE}/etc
    cp ${INSTALL_DIR}/etc/mpd.conf /tmp/${PACKAGE}/etc/
    mkdir /tmp/${PACKAGE}/var
    cp -r ${INSTALL_DIR}/var/* /tmp/${PACKAGE}/var/

    # Create the upgrade flag
    touch ${UPGRADE}

    exit 0
}

postupgrade ()
{
    # Restore some stuff
    for dir in etc var; do
        cp -r /tmp/${PACKAGE}/${dir}/* ${INSTALL_DIR}/${dir}/
    done
    rm -fr /tmp/${PACKAGE}

    # Remove the upgrade flag
    rm  ${UPGRADE}

    exit 0
}
