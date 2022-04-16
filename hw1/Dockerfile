FROM ubuntu:16.04
RUN apt update && apt install -y curl && curl -s https://packagecloud.io/install/repositories/akopytov/sysbench/script.deb.sh | bash && apt install -y sysbench
COPY sysbench-script.sh /var/scripts/sysbench-script.sh
COPY cpu-test.sh /var/scripts/cpu-test.sh
COPY fileio-test.sh /var/scripts/fileio-test.sh
WORKDIR /var/scripts