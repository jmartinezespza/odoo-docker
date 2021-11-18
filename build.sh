#!/bin/bash

source build.env

echo "Building the jmespza/odoo-ubuntu:$ODOO_VERSION image..."
docker build --network host \
    --build-arg ODOO_VERSION=$ODOO_VERSION \
    --build-arg ODOO_REVISION=$ODOO_REVISION \
    -t jmespza/odoo-ubuntu:$ODOO_VERSION .
