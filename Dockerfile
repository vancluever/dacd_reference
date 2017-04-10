FROM alpine:latest

ARG BUILD_VERSION
ENV BUILD_VERSION ${BUILD_VERSION:-undefined}

RUN mkdir -p /opt/dacd_reference/bin && \
  addgroup dacd_reference && \
  adduser -S -G dacd_reference -h /opt/dacd_reference dacd_reference && \
  chown dacd_reference:dacd_reference -R /opt/dacd_reference 

COPY ./dacd_reference /opt/dacd_reference/bin

RUN chown dacd_reference:dacd_reference -R /opt/dacd_reference

EXPOSE 8080

USER dacd_reference

WORKDIR /opt/dacd_reference

CMD /opt/dacd_reference/bin/dacd_reference
