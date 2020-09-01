#!/bin/bash

###
# Copyright (C) Balena.io - All Rights Reserved
# Unauthorized copying of this file, via any medium is strictly prohibited.
# Proprietary and confidential.
###

set -eu

./scripts/check-filenames.sh
./scripts/check-licenses.sh
./scripts/check-deployable-lib.sh
