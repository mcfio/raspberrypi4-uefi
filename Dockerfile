FROM docker.io/library/alpine:3.14.3

LABEL org.opencontainers.image.source https://github.com/mcfio/raspberrypi4-uefi

COPY ./serials /serials

ADD https://github.com/pftf/RPi4/releases/download/v1.32/RPi4_UEFI_Firmware_v1.32.zip RPi4_UEFI_Firmware.zip

RUN apk add --update --no-cache \
  unzip \
  && mkdir /rpi4 \
  && mv RPi4_UEFI_Firmware.zip /rpi4/RPi4_UEFI_Firmware.zip \
  && cd /rpi4 \
  && ls \
  && unzip RPi4_UEFI_Firmware.zip \
  && rm RPi4_UEFI_Firmware.zip \
  && mkdir /tftp \
  && ls /serials | while read serial; do mkdir /tftp/$serial && cp -r /rpi4/* /tftp/$serial && cp -r /serials/$serial/* /tftp/$serial/; done
