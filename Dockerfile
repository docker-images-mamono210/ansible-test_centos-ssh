FROM centos:7

RUN yum -y update \
  && yum clean all \
  && yum -y install openssh-server openssh-clients sudo

RUN sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config \
  && ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N ""


# Create `ansible` user with sudo permissions
ENV ANSIBLE_USER=ansible SUDO_GROUP=wheel
RUN set -xe \
  && groupadd -r ${ANSIBLE_USER} \
  && useradd -m -g ${ANSIBLE_USER} ${ANSIBLE_USER} \
  && usermod -aG ${SUDO_GROUP} ${ANSIBLE_USER} \
  && sed -i "/^%${SUDO_GROUP}/s/ALL\$/NOPASSWD:ALL/g" /etc/sudoers \
  && echo "${ANSIBLE_USER}:password" | chpasswd

RUN echo "#!/bin/bash" > /start.sh \
  && echo "/usr/sbin/sshd -D" >> /start.sh \
  && chmod 755 /start.sh

EXPOSE 22

CMD ["/start.sh"]
