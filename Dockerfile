FROM ubuntu:20.04
MAINTAINER Elico Corp <webmaster@elico-corp.com>

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

ARG ODOO_VERSION
ARG ODOO_REVISION

# Set timezone to UTC
RUN ln -sf /usr/share/zoneinfo/Etc/UTC /etc/localtime

# Generate locales
RUN apt update \
  && apt -yq install locales \
  && locale-gen es_PE.UTF-8 \
  && update-locale LC_ALL=es_PE.UTF-8 LANG=es_PE.UTF-8

# Install APT dependencies
ADD sources/apt.txt /opt/sources/apt.txt
RUN apt update \
  && awk '! /^ *(#|$)/' /opt/sources/apt.txt | xargs -r apt install -yq

# Install wkhtmltopdf based on QT5
ADD https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.focal_amd64.deb \
  /opt/sources/wkhtmltox.deb
RUN apt update \
  && apt install -yq xfonts-base xfonts-75dpi \
  && dpkg -i /opt/sources/wkhtmltox.deb

# Install postgresql-client
RUN apt update && apt install -yq lsb-release
RUN curl https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
RUN sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'
RUN apt update && apt install -yq postgresql-client

# Install Node
RUN curl -fsSL https://deb.nodesource.com/setup_15.x | bash -
RUN apt-get install -y nodejs

# Create odoo user and directories and set permissions
RUN useradd -ms /bin/bash odoo \
    && mkdir /etc/odoo /opt/odoo /opt/odoo/scripts \
    && chown -R odoo:odoo /etc/odoo /opt/odoo

WORKDIR /opt/odoo

# Install Odoo and dependencies from source and check out specific revision
USER odoo
RUN git clone --branch=$ODOO_VERSION --depth=1000 https://github.com/odoo/odoo.git odoo
RUN cd odoo && git reset --hard $ODOO_REVISION

USER root
RUN pip3 install pip --upgrade
RUN pip3 install --no-cache-dir -r odoo/requirements.txt

# Define runtime configuration
COPY src/entrypoint.sh /opt/odoo
COPY src/scripts/* /opt/odoo/scripts
COPY src/odoo.conf /etc/odoo
RUN chown odoo:odoo /etc/odoo/odoo.conf

USER odoo

RUN mkdir /opt/odoo/data /opt/odoo/custom_addons \
    /opt/odoo/.vscode /home/odoo/.vscode-server

ENV ODOO_RC /etc/odoo/odoo.conf
ENV PATH="/opt/odoo/scripts:${PATH}"

EXPOSE 8069
ENTRYPOINT ["/opt/odoo/entrypoint.sh"]
CMD ["odoo"]