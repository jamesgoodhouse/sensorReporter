ARG PYTHON_VERSION=3.7
ARG S6_OVERLAY_PLATFORM=armhf
ARG S6_OVERLAY_VERSION=2.2.0.3

################################################################################

# download and extract the s6 tarball
FROM alpine:latest as s6
ARG S6_OVERLAY_PLATFORM
ARG S6_OVERLAY_VERSION
ARG TARGETPLATFORM
COPY ./get_s6.sh /
RUN apk add curl && /get_s6.sh

################################################################################

FROM python:${PYTHON_VERSION}

# setup s6 overlay
COPY --from=s6 /s6 /
ENV S6_BEHAVIOUR_IF_STAGE2_FAILS=2

RUN apt-get update && apt-get install -y libglib2.0-dev bluetooth bluez python3-bluez
RUN pip3 install pybluez paho-mqtt bluepy

WORKDIR /usr/src/app

COPY . .

COPY ./etc /etc

ENTRYPOINT [ "/init" ]

CMD [ "python", "sensor_reporter.py", "/etc/sensor_reporter/config.ini" ]
