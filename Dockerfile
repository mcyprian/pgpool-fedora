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

COPY root /

RUN dnf -y --setopt=tsflags=nodocs install postgresql-server postgresql-pgpool-II && \
    dnf clean all && \
    test "$(id postgres)" = "uid=26(postgres) gid=26(postgres) groups=26(postgres)" && \
    mkdir -p /var/lib/pgsql/data && \
    /usr/libexec/fix-permissions /var/lib/pgsql /var/run/postgresql /var/run/pgpool /etc/pgpool-II && \
    usermod -a -G root postgres && \
    /usr/libexec/fix-permissions --read-only "$APP_DATA"

EXPOSE 9999

VOLUME ["/var/lib/pgsql/data"]


USER 26

RUN cp /etc/pgpool-II-template/* /etc/pgpool-II/

CMD ["run-pgpool", "-n"]
