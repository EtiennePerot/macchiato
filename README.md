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

*Note*: Throughout this document, items written in `<angle brackets>` are meant to be replaced by the user, and items in `[square brackets]` are optional.

### Install it

##### The Arch way:

There is a [macchiato-git package] available in the [Arch User Repository]:

	$ yaourt -S macchiato-git

##### The other way:

Check out the repository whever you wish to install the program:

	$ sudo git clone git://perot.me/macchiato /usr/share/macchiato

And you probably want to create a directory to stash your configuration into:

	$ sudo mkdir /etc/macchiato.d

### Configure it

	$ sudo cp /usr/share/macchiato/conf/sample.sh.example /etc/macchiato.d/<interface>.sh
	$ sudo $EDITOR /etc/macchiato.d/<interface>.sh

The `example.sh.sample` file you just copied should contain all the information you need as comments.

### Generate udev rules

	$ sudo /usr/share/macchiato/install-udev-rules.sh /etc/macchiato.d

This script will:

* Go through all your network interfaces
* Attempt to determine their burned-in MAC address
* Ask you for it if it cannot be sure about its decision
* Generate [udev] rules to run `macchiato` whenever that interface appears (whether that means on boot or when you plug it in)

Alternatively, you can also use the provided [systemd] service, `macchiato.service`. If you didn't install `macchiato` from a package, you need to install the service file to systemd's directory:

	$ sudo /usr/share/macchiato/install-systemd-service.sh

Then (whether you installed from a package or not), you need to enable it:

	$ sudo systemctl enable macchiato.service

This service assumes that you are using `/etc/macchiato.d` as configuration directory.

### Run it manually

##### Usage 1: Apply configuration to all network interfaces:

	$ macchiato [<confdir>]

For each file inside confdir (or inside `$scriptDir/conf` if not provided), it will apply that configuration to the interface it is meant for. If `confdir` contains a file named `_default.sh`, this configuration will be applied to all network interfaces which don't have a interface-specific configuration file. If there is no such file, then no configuration will be applied to network interfaces which don't have a interface-specific configuration file.

##### Usage 2: Apply configuration to selected network interfaces:

	$ macchiato [<confdir>] <interface1> [<interface2> [...]]

`macchiato` will check for interface-specific configuration for each of the provided interfaces inside `confdir`, or inside `$scriptDir/conf` if `confdir` is not provided. It will not affect any other interface.

##### Usage 3: Config-less usage

	$ macchiato --manual <interface>
	                     -o <class1> [-o <class2> [...]]
	                     [-b <blacklisted1> [-b <blacklisted2> [...]]]
	                     [-e <ending>]
	                     [-r]

Manual mode allows you to run `macchiato` without having a config file. You must specify `--manual` as the first argument in order to use this. The next argument (`<interface>`) should be the name of the network interface to apply the rules to. Then, you can use the following:

* `-o <class>` or `--oui-class <class>`: Specifies a class of OUI prefixes to use for this interface. For example, if you specify `--oui-class wired_console`, then the OUIs defined in `$scriptDir/oui/wired_console.sh` will be added to the list of OUIs to consider. You can specify this multiple times to add other possible OUI classes.
* `-b <blaclistedOUI>` or `--blacklist <blaclistedOUI>`: Specifies single OUI that should never be used. You can specify this multiple times to blacklist multiple OUIs.
* `-e <ending>` or `--ending <ending>`: Specifies the last 3 bytes to use for the generated MAC address (example: `dd:ee:ff`). If unspecified, these 3 bytes will be chosen randomly.
* `-r` or `--random`: If specified, macchiato will use `/dev/random` instead of `/dev/urandom` as a source of randomness. On Linux systems, this may block for some time until enough entropy is available, but provides higher-quality randomness used when generating a MAC address.

## Contribute

If you wish to expand the OUI list (and you are welcome to!), please send a pull request or [post a comment on this blog post][MAC spoofing: What, why, how, and something about coffee]. Your hardware should be "common enough", meaning that there should exist a decent number of this type of hardware actively in use. Make sure to specify:

* OUI prefix, in lowercase `hh:hh:hh` format
* Organization name corresponding to the OUI prefix, according to the [IEEE's public OUI listing]. Optional unless you are making a pull request.
* Device information (if it's a mobile device, what model is it? If it's a motherboard's integrated network adapter, what's the model and revision number of the board? etc.)

If sending a pull request, please make sure to follow the same format as existing OUI lists. Each line has the format `aa:bb:cc='Organization|Model name'`, with lowercase colon-separated OUI. Keep the lines sorted by OUI prefix. Feel free to suggest new files for new classes of hardware.

## License

`macchiato`'s source code and OUI lists are licensed under the [3-clause BSD license].

The logo above is part of the [Oxygen Icons project] and is licensed under the [Creative Common Attribution-ShareAlike 3.0 License]. It is *not included* as part of a `macchiato` installation. As such, packagers should exclude this file from redistributable packages, and use the license file `LICENSE.redistrib`.

## Credits

* Name idea by Esky
* Icon from the [Oxygen Icons project]
* All the folks who helped gathering OUIs in the wild

[MAC address]: https://en.wikipedia.org/wiki/MAC_address
[OUI]: https://en.wikipedia.org/wiki/Organizationally_Unique_Identifier
[IEEE's OUI registry]: https://standards.ieee.org/develop/regauth/oui/
[MAC spoofing]: https://en.wikipedia.org/wiki/MAC_spoofing
[MAC spoofing: What, why, how, and something about coffee]: https://perot.me/mac-spoofing-what-why-how-and-something-about-coffee
[macchiato-git package]: https://aur.archlinux.org/packages/macchiato-git/
[Arch User Repository]: https://aur.archlinux.org/
[udev]: https://en.wikipedia.org/wiki/Udev
[systemd]: http://freedesktop.org/wiki/Software/systemd/
[IEEE's public OUI listing]: https://standards.ieee.org/develop/regauth/oui/oui.txt
[3-clause BSD license]: http://opensource.org/licenses/BSD-3-Clause
[Oxygen Icons project]: http://www.oxygen-icons.org/
[Creative Common Attribution-ShareAlike 3.0 License]: https://creativecommons.org/licenses/by-sa/3.0/
