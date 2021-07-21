#!/bin/bash

source build.env

echo "Building the jhonny/odoo-ubuntu:$ODOO_VERSION image..."
docker build \
    --build-arg ODOO_VERSION=$ODOO_VERSION \
    --build-arg ODOO_REVISION=$ODOO_REVISION \
    -t jmespza/odoo-ubuntu:$ODOO_VERSION .
