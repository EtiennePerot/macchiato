#!/usr/bin/env bash

if [ "$UID" -ne 0 ]; then
	echo 'Run me as root.'
	exit 1
fi

scriptDir=$(dirname "$BASH_SOURCE")

install -D -m644 "$scriptDir/systemd/macchiato.service" '/usr/lib/systemd/system/macchiato.service' || exit 1
install -D -m644 "$scriptDir/conf/sample.sh.example" '/etc/macchiato.d/sample.sh.example' || exit 1

echo "systemd service installed at '/usr/lib/systemd/system/macchiato.service'."
echo "You should configure things first (see $scriptDir/README.md), and once ready:"
echo '    $ sudo systemctl enable macchiato'
echo '    $ sudo systemctl start macchiato'
