FROM registry.fedoraproject.org/f29/s2i-core:latest

ENV NAME=pgpool \
    VERSION=0 \
    ARCH=x86_64 \
    \
    HOME=/var/lib/pgsql \
    PGUSER=postgres \
    APP_DATA=/opt/app-root

LABEL summary="$SUMMARY" \
      description="$DESCRIPTION" \
      io.k8s.description="$DESCRIPTION" \
      io.k8s.display-name="Pgpool-II" \
      io.openshift.expose-services="9999:pgpool" \
      io.openshift.tags="database,postgresql,pgpool" \
      com.redhat.component="$NAME" \
      name="$FGC/$NAME" \
      version="0"


RUN dnf -y --setopt=tsflags=nodocs install postgresql-pgpool-II && \
    dnf clean all

EXPOSE 9999

COPY root/usr/libexec/fix-permissions /usr/libexec/fix-permissions

# This image must forever use UID 26 for postgres user so our volumes are
# safe in the future. This should *never* change, the last test is there
# to make sure of that.
RUN INSTALL_PKGS="rsync tar gettext bind-utils postgresql-server postgresql-contrib nss_wrapper " && \
    INSTALL_PKGS+="python2 xz postgresql-pgpool-II" && \
    dnf -y --setopt=tsflags=nodocs install $INSTALL_PKGS && \
    dnf clean all && \
    test "$(id postgres)" = "uid=26(postgres) gid=26(postgres) groups=26(postgres)" && \
    mkdir -p /var/lib/pgsql/data && \
    /usr/libexec/fix-permissions /var/lib/pgsql /var/run/postgresql /var/run/pgpool /etc/pgpool-II
    # rpm -V $INSTALL_PKGS && \

# Get prefix path and path to scripts rather than hard-code them in scripts
ENV CONTAINER_SCRIPTS_PATH=/usr/share/container-scripts/postgresql

COPY root /

VOLUME ["/var/lib/pgsql/data"]

RUN usermod -a -G root postgres && \
    /usr/libexec/fix-permissions --read-only "$APP_DATA"

USER 26

RUN cp /etc/pgpool-II-template/* /etc/pgpool-II/

ENTRYPOINT ["container-entrypoint"]
CMD ["pgpool", "-n"]
