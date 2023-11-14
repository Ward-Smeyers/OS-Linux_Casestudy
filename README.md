
# OS-Linux_Casestudy

## Install an SSH server

If openssh-servern is not installed yet, install it with the folowing command (for Redhad based distros)
```
sudo yum install openssh-server
```
Enable the ssh deamon with these 3 commands.
```
sudo systemctl enable sshd
sudo systemctl start sshd
sudo systemctl status sshd
```

## Bash script

The script name is ward_smeyers.sh


## NFS Sharing

### Install the NFS Server

```
sudo dnf -y install nfs-utils libnfsidmap
sudo systemctl enable rpcbind
sudo systemctl enable nfs-server
sudo systemctl start rpcbind
sudo systemctl start nfs-server
sudo systemctl start rpc-statd
sudo systemctl start nfs-idmapd
```

### Creating an NFS Share

We will create a unique folder for this example.
This folden will also to be universally readable and writeable as, for this example, we will rely solely on NFS permissions to manage access to the share.
```
mkdir /var/nfs_share1
chmod 777 /var/nfs_share1
```

### Edit /etc/exports

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

## NFS client

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