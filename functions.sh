programExists() {
	which "$1" &> /dev/null
	return "$?"
}

getRandom() {
	if programExists xxd; then
		printf '%d' "0x$(cat /dev/urandom | xxd -p -l 2)"
	else
		echo "$RANDOM"
	fi
}

getRandomChoice() {
	local randomIndex
	randomIndex=$(expr "$(getRandom)" % "$#" + 1)
	eval "echo \"\${$randomIndex}\""
}

getRandomHex() {
	echo "$(getRandomChoice 0 1 2 3 4 5 6 7 8 9 a b c d e f)"
}

getRandomMACEnding() {
	echo "$(getRandomHex)$(getRandomHex):$(getRandomHex)$(getRandomHex):$(getRandomHex)$(getRandomHex)"
}

deviceExists() {
	if programExists ip; then
		ip link show "$1" &> /dev/null
		return "$?"
	elif programExists ifconfig; then
		ifconfig -a "$1" &> /dev/null
		return "$?"
	fi
	echo "Cannot determine whether network device '$1' exists or not; exitting."
	exit 1
}

deviceIsUp() {
	if programExists ip; then
		if [ -n "$(ip link show "$1" up)" ]; then
			return 0
		fi
		return 1
	elif programExists ifconfig; then
		ifconfig | grep "^$1:" &> /dev/null
		return "$?"
	fi
	echo "Cannot determine whether network device '$1' is up or not; exitting."
	exit 1
}

deviceBring() {
	if programExists ip; then
		ip link set "$1" "$2"
		return "$?"
	elif programExists ifconfig; then
		ifconfig "$1" "$2"
		return "$?"
	fi
	echo "Cannot bring network device '$1' $2."
	exit 1
}

deviceBringUp() {
	deviceBring "$1" up
	return "$?"
}

deviceBringDown() {
	deviceBring "$1" down
	return "$?"
}

deviceSetMAC() {
	if programExists macchanger; then
		macchanger -m "$2" "$1"
		return "$?"
	elif programExists ip; then
		ip link set "$1" address "$2"
		return "$?"
	elif programExists ifconfig; then
		ifconfig "$1" hw ether "$2"
		return "$?"
	fi
	echo "Cannot change the MAC address of network device '$1' to '$2'."
	exit 1
}

getDevicesList() {
	if programExists ip; then
		ip -o link | sed -r 's/[0-9]+\s*:\s*(\S+):.*/\1/' | sort
		return "$?"
	elif programExists ifconfig; then
		ifconfig -a -s | grep -v '^Iface' | cut -d ' ' -f 1 | sort
		return "$?"
	fi
	echo "Cannot enumerate device list."
	exit 1
}

isInArray() {
	needle="$1"
	shift
	for haystack; do
		if [ "$needle" == "$haystack" ]; then
			return 0
		fi
	done
	return 1
}

devHash() {
	# Try "poor" algorithms like md5 first because we don't want to make the variable names too long
	# and the probability of collision is very low given an innocent user
	for hashAlgorithm in md5sum sha1sum mdsum shasum cksum sum sha224sum sha256sum sha384sum sha512sum; do
		if programExists "$hashAlgorithm"; then
			echo -n "$1" | "$hashAlgorithm" | cut -d ' ' -f 1
			break
		fi
	done
}

ouiNormalizeBits() {
	echo "$oui" | sed -r 's/^\s+|\s+$//g' | tr '[:upper:]' '[:lower:]' | sed 's/-/:/g'
}

ouiGetBits() {
	echo "$1" | cut -d '=' -f 1
}

ouiGetOrganization() {
	echo "$1" | cut -d '=' -f 2 | cut -d '|' -f 1
}

ouiGetDeviceName() {
	echo "$1" | cut -d '=' -f 2 | cut -d '|' -f 2
}
