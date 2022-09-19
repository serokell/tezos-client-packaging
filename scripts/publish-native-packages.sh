#! /usr/bin/env bash
# SPDX-FileCopyrightText: 2021 Oxhead Alpha
# SPDX-License-Identifier: LicenseRef-MIT-OA

set -euo pipefail

source_packages_path="$1"

# Basic dput configuration
cat >dput.cfg <<EOL
[DEFAULT]
login	 = *
method = ftp
hash = md5
allow_unsigned_uploads = 0
allow_dcut = 0
run_lintian = 0
run_dinstall = 0
check_version = 0
scp_compress = 0
post_upload_command	=
pre_upload_command =
passive_ftp = 1
default_host_main	=
allowed_distributions	= (?!UNRELEASED)

[tezos-serokell]
fqdn      = ppa.launchpad.net
method    = ftp
incoming  = ~serokell/ubuntu/tezos
login     = anonymous

[tezos-rc-serokell]
fqdn        = ppa.launchpad.net
method      = ftp
incoming    = ~serokell/ubuntu/tezos-rc
login       = anonymous
EOL

if [[ $OCTEZ_VERSION =~ v.*-rc[0-9]* ]]; then
  launchpad_ppa="tezos-rc-serokell"
  copr_project="@Serokell/Tezos-rc"
else
  launchpad_ppa="tezos-serokell"
  copr_project="@Serokell/Tezos"
fi

for f in "$source_packages_path"/*.src.rpm; do
  rpmsign --define="%_gpg_name Serokell <tezos-packaging@serokell.io>" --define="%__gpg $(which gpg)" --addsign "$f"
done
