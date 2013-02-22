<div align="center">
	<h1>macchiato</h1>
	<p>
		<img src="https://github.com/EtiennePerot/macchiato/blob/master/icon.png?raw=true" alt="macchiato"/><br/>
		<span style="font-style: italic;"><code>macchiato</code>: MAC Changer Hiding Identification And Transposing OUIs</span>
	</p>
</div>

## What

`macchiato` is a Bash script that assigns a random [MAC address] to specified network interfaces. It is meant to run at boot time.

Its twist is that the MAC addresses it assigns to network interfaces is limited to a few [OUI] prefixes. A MAC address's first 3 bytes indicates the manufacturer of the hardware, as defined by the [IEEE's OUI registry]. As such, attempting to randomize this part of the MAC address by simply picking a random sequence of 3 bytes uniformly results very often in MAC addresses that aren't registered to any publicized OUI, which is a very strong indication that the user is using a [spoofed MAC address][MAC spoofing].

Trying to be smarter about it by restricting the subset of 3-byte sequences to registered OUIs only is a good step, but many of the companies associated with those OUIs are obscure, and often have gone bankrupt or have manufactured very few chips. As such, seeing a MAC address from them is almost certainly a giveaway that the user is using a spoofed MAC address.

`macchiato` lets you define which network interfaces you want to use a spoofed MAC, and which classes of OUI prefixes the random MAC addresses should use. For example, you can restrict your laptop's onboard wireless interface to only be assigned MAC addresses that are actually found in laptop wireless chips.

## Why

If you need reasons as to why spoofing your MAC address can be a good thing, [read this blog post on the subject][MAC spoofing: What, why, how, and something about coffee] or [the Wikipedia article about it][MAC spoofing].

If you need reasons as to why you should use this over manual configuration or `machchanger`, you shouldn't. This script uses the `ip` command to do the actual MAC address assignment. The only thing you get out of it is control over the prefix of the MAC addresses assigned to each interface. This yields more believable spoofed MAC addresses. It also lets you define a blacklist of OUI prefixes you never want to see assigned to your network interface.

## How

### Install it

#### The Arch way:

	$ yaourt -S macchiato-git

#### The other way:

	$ git clone git://perot.me/macchiato /usr/share/macchiato

### Configure it

	$ sudo cp /etc/macchiato.d/{example.sh.sample,<interface>.sh}
	$ sudo $EDITOR /etc/macchiato.d/<interface>.sh

The `example.sh.sample` file you just copied should contain all the information you need.

### Generate udev rules

	$ sudo /usr/share/macchiato/install-udev-rules.sh <confdir>

### Run it manually

#### Usage 1: Apply configuration to all network interfaces:

	$ macchiato [<confdir>]

For each file inside confdir (or inside `$scriptDir/conf` if not provided), it will apply that configuration to the interface it is meant for. If `confdir` contains a file named `_default.sh`, this configuration will be applied to all network interfaces which don't have a interface-specific configuration file. If there is no such file, then no configuration will be applied to network interfaces which don't have a interface-specific configuration file.

#### Usage 2: Apply configuration to selected network interfaces:

	$ macchiato [<confdir>] <interface1> [<interface2> [...]] ...

`macchiato` will check for interface-specific configuration for each of the provided interfaces inside `confdir`, or inside `$scriptDir/conf` if `confdir` is not provided. It will not affect any other interface.

#### Usage 3: Config-less usage

	$ macchiato --manual <interface> -o <class1> [-o <class2> [...]] [-b <blacklisted1> [-b <blacklisted2> [...]]]

Manual mode allows you to run `macchiato` without having a config file. You must specify `--manual` as the first argument in order to use this. The next argument (`<interface>`) should be the name of the network interface to apply the rules to. Then, you can use the following:

* `-o <class>` or `--oui-class <class>`: Specifies a class of OUI prefixes to use for this interface. For example, if you specify `--oui-class wired_console`, then the OUIs defined in `$scriptDir/oui/wired_console.sh` will be added to the list of OUIs to consider. You can specify this multiple times to add other possible OUI classes.
* `-b <blaclistedOUI>` or `--blacklist <blaclistedOUI>`: Specifies single OUI that should never be used. You can specify this multiple times to blacklist multiple OUIs.


## License

macchiato is licensed under the [3-clause BSD license]

## Credits

* Name idea by Esky
* All the folks who helped gathering OUIs in the wild

[MAC address]: https://en.wikipedia.org/wiki/MAC_address
[OUI]: https://en.wikipedia.org/wiki/Organizationally_Unique_Identifier
[IEEE's OUI registry]: https://standards.ieee.org/develop/regauth/oui/
[MAC spoofing]: https://en.wikipedia.org/wiki/MAC_spoofing
[MAC spoofing: What, why, how, and something about coffee]: https://perot.me/mac-spoofing-what-why-how-and-something-about-coffee
[3-clause BSD license]: http://opensource.org/licenses/BSD-3-Clause
[iproute2]: http://www.linuxfoundation.org/collaborate/workgroups/networking/iproute2
