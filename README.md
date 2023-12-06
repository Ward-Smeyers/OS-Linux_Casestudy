
# OS-Linux_Casestudy

This Github repo is for the cours OS (operating systems) in ITFactory at Thomasmore Geel. 

## GOAL of the project:
In this project, you will work on a Fedora machine.
You will apply the subject materials learned through the Operating System lectures to this new distribution. You will notice that commands can be applied to any distribution with only very small differences. 
Through this project we would like to challenge you to immerse yourself even more in the Linux world! Success…


## Table of contents

This documentation was made with and for 3 fedora 38 virtual machines. And gos over the folowing things.
- [Install an SSH server](#fedora-linux)
- [Bash script (Factorio)](#bash-script-factorio)
- [NFS Sharing](#nfs-sharing)
- [Apache webserver](#apache-webserver)

# Fedora Linux

To update the VM use:
```
sudo yum update
```

# Install an SSH server

If openssh-servern is not installed yet, install it with the folowing command (for Redhad based distros)
```
sudo yum install openssh-server
```
Enable the ssh deamon with these 3 commands.
```
sudo systemctl enable --now sshd
sudo systemctl status sshd
```
`systemctl enable` \
_Enable a service, without starting it. It will start automatically at the next system restart, or it can be started manually, or as a dependency of another service._

`systemctl disable` \
_Disable a service. If it is running, it will continue to run until it is stopped manually. It will not start at the next system restart, but can be started manually, or as a dependency of another service._

Option `--now` \
Enable/disable a service and start/stop it immediately.

`systemctl start` \
_Starts a service_

`systemctl stop` \
_Stops a service_

`systemctl status` \
_Check if a service is running, stopped, enabled, or masked, and display the most recent log entries._

`systemctl re-enable` \
_Stop and restart a service, and restore its default start behavior._



# Bash script Factorio

The script I made is based on a older tutorial https://gist.github.com/othyn/e1287fd937c1e267cdbcef07227ed48c

Factorio runs out of the `/opt` directory, [a directory resevered in UNIX for non-default software installation](http://www.tldp.org/LDP/Linux-Filesystem-Hierarchy/html/opt.html).
I wil be sharing this this directory with NFS in the next capter.


## Making the working directory:
This will be the directory structure:
```
/opt
└── Wube-Software
    ├── backup-factorio
    ├── factorio
    └── factorio_headless.tar.gz
```
```
mkdir /opt/Wube-Software/factorio/saves/ /opt/Wube-Software/factorio/mods/
```

## Download the factorio server:
```
wget -O /opt/Wube-Software/factorio_headless.tar.gz https://factorio.com/get-download/stable/headless/linux64
```

## Unzip and untar the file to a specific directory.
```
tar -xf /opt/Wube-Software/factorio_headless.tar.gz --directory /opt/Wube-Software
```
Add the `-v` for verbose te see what is hapening.

## Add factorio user:
```
sudo adduser --disabled-login --no-create-home --gecos factorio factorio
```
[The above command](http://www.unix.com/man-page/linux/8/adduser/) will add a user, not setting a password `--disabled-login`, without creating a home directory in `/home` `--no-create-home`, [without asking for user information](https://en.wikipedia.org/wiki/Gecos_field) `--gecos`, create user `factorio` and add them/create the group `factorio`.

Now that the new user is created, we need to make it the owner of the Factorio directory so that it can access and perform operations within it, `sudo chown -R factorio:factorio /opt/factorio`. The `-R` [flag being recursive](https://linux.die.net/man/1/chown).

## Adding the factorio.service to systemd.
```
sudo nano /etc/systemd/system/factorio.service

[Unit]
Description=Factorio Headless Server

[Service]
Type=simple
User=factorio
ExecStart=/opt/factorio/bin/x64/factorio --start-server /opt/factorio/saves/{save_file}.zip --server-settings /opt/factorio/data/server-settings.json
```

Backup all factorio files:
```
tar -czf /opt/Wube-Software/factorio --directory /opt/Wube-Software/backup-factorio
```
Yes No question:
```
while true; do
        read -p "Would you like to create a factorio folder $DIR ? [Y or n]" yn
        case $yn in
            [Yy]* ) mkdir -pv /opt/Wube-Software/factorio/saves/ /opt/Wube-Software/factorio/mods/; echo "Factorio directory created"; break;; # Making the working directory and break out prompt loop
            [Nn]* ) exit;; # Exit the script
            * ) echo "Please answer yes or no.";;
        esac
    done
```

The script name is ward_smeyers.sh


# NFS Sharing

## Install the NFS Server

```
sudo dnf -y install nfs-utils libnfsidmap
sudo systemctl enable rpcbind
sudo systemctl enable nfs-server
sudo systemctl start rpcbind
sudo systemctl start nfs-server
sudo systemctl start rpc-statd
sudo systemctl start nfs-idmapd
```

## Creating an NFS Share

We will create a unique folder for this example.
This folden will also to be universally readable and writeable as, for this example, we will rely solely on NFS permissions to manage access to the share.
```
mkdir /var/nfs_share1
chmod 777 /var/nfs_share1
```

## Edit /etc/exports

This file determines what directories will be exported and which clients can access it.

**Syntax:**
```
<export dir.> <host1>(<options>) [... <hostn>(<options>) ]
```
**Options:**
| Option                | Explanation                                                                                                                                                                                                                                                                                                                                                                                    |
| --------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| secure (default)      | This option states that requests for shares MUST come from ports whose port number is < than 1024.                                                                                                                                                                                                                                                                                             |
| insecure              | This option specifies that requests for shares may come from any port address.                                                                                                                                                                                                                                                                                                                 |
| ro (default)          | This option indicates that the directory is mounted or set read-only.Users can therefore read the files in this directory, but not write them.                                                                                                                                                                                                                                                 |
| rw                    | This option indicates that the directory read/write is mounted or set.                                                                                                                                                                                                                                                                                                                         |
| root_squash (default) | root (NFS client) --> anonymous (NFS server) All requests from the NFS client itself that are excuted by the user root (UID 0 on the client) or by the root group (GID 0 on the client) are then run on the server using the UID 65534. This UID is used by default by the user "nobody" or "anonymous". This means that the root of the NFS client then has minimal rights on the NFS server. |
| no_root_squash        | root (NFS client) --> root(NFS server) This option disables root squashing. In other words, this option ensures that the NFS client's root user also has access to the NFS server as a root user. **This is insecure!!!**                                                                                                                                                                      |


To continue with the example we add this line to the file _'/etc/exports'_
```
/var/nfs_share1 *(rw,sync,root_squash)
```
This way, **_anyone_** who can communicate with the server can mount, read and write to the share

With the command "exportfs", the root user can manually export or de-export directories without rebooting the NFS service.

The next step is to tell the service to read the '/etc/exports' file this can be don with the foloing command.
```
sudo exportfs -rv
```
| option |          |
| ------ | -------- |
| -r     | refresh  |
| -v     | verbose  |
| -a     | all      |
| -u     | unexport |

And that's it. We should now have a share available on our network.

If any problems occur restart all services
```
sudo systemctl restart rpcbind.service nfs-idmapd.service nfs-server.service
```

# NFS client

Installation NFS-client.
This wil install the package necessary to access the shared folder.
```
sudo dnf -y install nfs-utils
```

Creating a mount on the client to the shared folder on the server.
Syntax:
```
mount -t nfs <host>:</sharedir> </localdir>
```
Example:
```
mount -t nfs 192.168.56.102:/var /mnt
```
Result:
```
[ws@fedora3 ~]$ ls /mnt
nfs_share1
```

## Mount on reboot with fstab
The folowing command adds the lines `#nfs share mount` and `192.168.56.102:/var     /mnt    nfs     defaults        0 0` to the /etc/fstab file. [More info.](https://wiki.archlinux.org/title/fstab)
```
sudo sh -c "echo '#nfs share mount
192.168.56.102:/var     /mnt    nfs     defaults        0 0' >> /etc/fstab"
```
To check if it was added successfully:
```
sudo cat /etc/fstab | grep /mnt
```

# Apache webserver

Install, start and enable **The Apache HTTP Server** \

```
sudo dnf install httpd -y
sudo systemctl start httpd.service
sudo systemctl enable httpd.service
sudo systemctl status httpd.service
```
Desired output: \
enabled \
active (running)
```
Last metadata expiration check: 0:25:44 ago on Mon 04 Dec 2023 04:51:49 PM CET.
Package httpd-2.4.58-1.fc38.x86_64 is already installed.
Dependencies resolved.
Nothing to do.
Complete!
● httpd.service - The Apache HTTP Server
     Loaded: loaded (/usr/lib/systemd/system/httpd.service; enabled; preset: disabled)
    Drop-In: /usr/lib/systemd/system/service.d
             └─10-timeout-abort.conf
     Active: active (running) since Mon 2023-12-04 17:13:40 CET; 3min 54s ago
       Docs: man:httpd.service(8)
   Main PID: 11842 (httpd)
     Status: "Total requests: 0; Idle/Busy workers 100/0;Requests/sec: 0; Bytes served/sec:   0 B/sec"
      Tasks: 177 (limit: 4633)
     Memory: 19.5M
        CPU: 366ms
```
## Apache test page
This page should be viseble in fedora http://Localhost:80.
![Alt text](<Apache test page eg.png>)


## Firewall
### Important
This exposes your computer to the Internet and potential attackers. Secure your system and your Apache installation properly before exposing your server to the Internet. 

Apache uses port 80 for plain http connections and port 443 for TLS/SSL connections by default. To make this service available from other computers or the Internet, allow Apache through the firewall using any one the following commands:

**To allow Apache through the firewall at each boot:**

- For plain HTTP connections:
```
sudo firewall-cmd --permanent --add-service=http
```
- For TLS/SSL connections:

```
sudo firewall-cmd --permanent --add-service=https
```

**To allow Apache through the firewall instantly (this boot):**

- For plain HTTP connections:
```
sudo firewall-cmd --add-service=http
```
- For TLS/SSL connections:
```
sudo firewall-cmd --add-service=https
```
## Apache test page
This page should be viseble in fedora (http://Localhost:80) and now also on your main pc (http://192.168.56.104:80 IP of the fedora VM)
![Alt text](<Apache test page eg.png>)

## [Configuring Apache HTTPD](https://docs.fedoraproject.org/en-US/quick-docs/getting-started-with-apache-http-server/#_configuring_apache_httpd)

The foloing info is from the [docs.fedoraproject.org](https://docs.fedoraproject.org/en-US/quick-docs/getting-started-with-apache-http-server/#_configuring_apache_httpd) ist extra info on the configuration of apatche (httpd).

`/etc/httpd/conf/httpd.conf` is the main Apache configuration file. Custom confirguration files are specified under `/etc/httpd/conf.d/*.conf`. If the same settings are specified in both `/etc/httpd/conf/httpd.conf` and a .conf file in `/etc/httpd/conf.d/`, the setting from the `/etc/httpd/conf.d/` file will be used.

Files in `/etc/httpd/conf.d/` are read in alphabetical order: a setting from ``/etc/httpd/conf.d/z-foo.conf`` will be used over a setting from ``/etc/httpd/conf.d/foo.conf``. Similarly, a setting from ``/etc/httpd/conf.d/99-foo.conf``, will be used over a setting from ``/etc/httpd/conf.d/00-foo.conf``.

As a best practice, do not modify ``/etc/httpd/conf/httpd.conf`` or any of the ``/etc/httpd/conf.d`` files shipped by Fedora packages directly. If you make any local changes to these files, then any changes to them in newer package versions will not be directly applied. Instead, a .rpmnew file will be created, and you will have to merge the changes manually.

It is recommended to create a new file in ``/etc/httpd/conf.d/`` which will take precedence over the file you wish to modify, and edit the required settings. For instance, to change a setting specified in ``/etc/httpd/conf.d/foo.conf`` you could create the file ``/etc/httpd/conf.d/z-foo-local.conf``, and place your setting in that file.



## Add your own web page
Add the index.html to:
```
/var/www/html/
```
If you refresh the browser you should see your own page!!!

# Links and sources

## SSH
[Enabling and disabling systemd services](https://documentation.suse.com/smart/systems-management/html/reference-systemctl-enable-disable-services/index.html)

## Bash script
[[LINUX] Factorio Headless Server Guide](https://gist.github.com/othyn/e1287fd937c1e267cdbcef07227ed48c#file-factorio_headless_guide-md)

[Syntax For Tar Command To Extract Tar Files To a Different Directory](https://www.cyberciti.biz/faq/howto-extract-tar-file-to-specific-directory-on-unixlinux/)

## NFS server 
[How to configure a NFS mounting in fstab?](https://askubuntu.com/questions/890981/how-to-configure-a-nfs-mounting-in-fstab)

[Sudo echo "something" >> /etc/privilegedFile doesn't work](https://stackoverflow.com/questions/84882/sudo-echo-something-etc-privilegedfile-doesnt-work)

## Apache webserver
[Getting-started-with-apache-http-server](https://docs.fedoraproject.org/en-US/quick-docs/getting-started-with-apache-http-server/)