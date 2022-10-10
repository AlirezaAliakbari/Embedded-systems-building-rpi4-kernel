# Course Summery

## Requirements

  * Raspberry pi 4 model B 4G-RAM.
  * A PC as your host machine.
  * host IP: 192.168.1.101.
  * target IP: 192.168.1.60
  >  * Note that this summery is for 64bit rpi4 processor, (for 32bit processors such as rpi2, rpi3 another summery is been created.) 

## Course Steps of Creating Custom Kernel

  1. Install Picocom to make connection beween host and target using uart.
  2. Generate Cross-Compiler using Crosstool-ng for compile the programs for target.
  3. Prepare bootloader ( in this case is U-BOOT ) for booting kernel.
  4. Downdload kernel from raspberrypi github and make it as well.
  5. Add some features to linux kernel using busybox

## 1. Picocom configuration
### 1.1 Picocom Installing

`sudo apt install picocom`

### 1.2 Testing Picocom 

```
sudo dmesg -w
ctrl c
sudo picocom -b 115200 /dev/ttyUSB0
ctrl c+a
```
## 2. Generate Cross-Compiler

### 2.1. Install compiler on you host machine and Test it

```
sudo apt install gcc
```
when gcc installation is completed, create a folder and inside that do the bellow tasks: 
Download the `rpi4dircreator.sh` from the repo and run it to create the rpi4 folder:
```
chmod +x rpi4dircreator.sh
./rpi4dircreator.sh 4
```
 * note that 4 in front of rpi4dircreator.sh is the version of the board which here is equal to 4
> download the cross compiler inside to folder 
>> what is the cross_compiler? generally we have 4 types of compiling, in here we talk about two types of them:
>>  1. native compiler<br />
>>  2. cross-compiler
>>  
>>  Native compiler : is compiler which compiler your program whic built in your host machine to run on your host machine
>>  Cross compiler : is a kine of compiler which compiler the programs which written on host to run on the target

in this case we use the crosstool-ng as our cross-compiler generator (Not cross-compiler), using below command you able to download it: 
```
wget http://crosstool-ng.org/download/crosstool-ng/crosstool-ng-1.25.0_rc1.tar.xz
```
### 2.2. Build the Cross-Compiler
```
tar -xf crosstool-ng-1.25.0_rc1.tar.xz
mv crosstool-ng-1.25.0_rc1 crosstool-ng
cd crosstool-ng 
```
as the next step you have to install crosstool-ng dependencies: 
```
cat testing/docker/ubuntu18.04/Dockerfile
```
usind above command you see the requirements of the crosstool-ng, for install them
```
sudo apt-get install -y gcc g++ gperf bison flex texinfo help2man make libncurses5-dev \
    python3-dev autoconf automake libtool libtool-bin gawk wget bzip2 xz-utils unzip \
    patch libstdc++6 rsync  
```
after installing the requirements of crosstool-ng you have make crosstool-ng.
```
cd crosstool-ng 
./bootstrap
./configure --enable-local
make
```
now your generator is ready to generate your own cross-compiler: 
> name of the generator is ct-ng 
```
ls 
./ct-ng list-samples
or 
./ct-ng list-samples|grep rpi
./ct-ng aarch64-rpi4-linux-gnu
./ct-ng menuconfig
```
inside the menu config you have to do the following task:<br />
go to <br />
`C-libraries --> Minimum Supported kernel version --> lets ./configure decied`<br />
save the configuration.<br />
build the cross-compiler:<br />
```
./ct-ng build
```
Once build process of the crosstool-ng is completed successfully, the result will be saved in the bellow directory: 
```
/home/<your_pc_name>/x-tools
you are able to see all the generated compilers in the follwing folder
ls ~/x-tools/aarch64-rpi4-linux-gnu/bin
```
### 2.3. Install Qemu and test the cross compiler

to install Qemu do as follow: 

```
sudo apt-get update
sudo apt-get install qemu-user
```
test cross-compiler

```
> go to the rpi4 directory
cd ..
gedit main.txt

*** inside text ***
#inculde <stdio.h>
int main()
{
 printf("Hello world/n");
 return 0;
}
*******************
gcc main.c -o app

> gcc is native compiler
> note that app is the name of the compiled main.c
> to run compiled program on your host:
./app 

> compile main.c for arm cores using generated cross-compiler
export PATH=~/x-tools/aarch64-rpi4-linux-gnu/bin/:$PATH
> to test exported path 
aarch64-rpi4-linux-gnu-gcc -v

> compile main.c 
aarch64-rpi4-linux-gnu-gcc main.c -o app-arm

```
test your program using Qemu:

`qemu-aarch64 -L ~/x-tools/aarch64-rpi4-linux-gnu/aarch64-rpi4-linux-gnu/sysroot ./app-arm`

## 3. Config U-BOOT for booting the kernel
> what is the bootloader? bootloader is a kind of program which load kernel on hardware and run it. there are some types of bootloader, here we use from 
> u-boot as our bootloader
>> you can use from a provided compiled cross-compiler instead of compiling your own compiler (because in some cases generate a new compiler is a time taker procedure ), this is not optimum for your work but satisfy 
>> your boot process for doing that you can use from bellow command 
>> 64bit prepared compiler: 
>> `sudo apt-get update` <br />
>> `sudo apt-get install gcc-aarch64-linux-gnu`

first you need to download u-boot: <br />
as the next step you have to find your board related config file from u-boot existed config files <br />
for the third step the generated cross-compiler has to export and then make your bootloader.

`wget https://source.denx.de/u-boot/u-boot/-/archive/v2022.01/u-boot-v2022.01.tar.gz`<br />
```
tar -xf u-boot.tar.gz
cd u-boot
ls ./configs 
ls ./configs|grep rpi
make rpi_4_defconfig
export PATH=~/x-tools/aarch64-rpi4-linux-gnu/bin/:$PATH
export CROSS_COMPILE=aarch64-rpi4-linux-gnu-
make menuconfig
make
mkdir ../sdcard
sudo cp u-boot.bin ../sdcard
```
now, your bootloader is ready to use, for booting rpi4 you need follwoing files: <br />

 * u-boot.bin
 * start4.elf
 * config.txt
 * bcm2711-rpi-4-b.dtb

> Note that the files used for booting rpi4 is differ from rpi2, and 3.

to prepare mentioned files : 
```
wget https://github.com/raspberrypi/firmware/raw/master/boot/start4.elf
wget https://github.com/raspberrypi/firmware/raw/master/boot/bcm2711-rpi-4-b.dtb 
gedit config.txt 

```
inside the text file 
```
enable_uart=1
kernel=u-boot.bin
arm64bit=1
```
### 3.1 Preparing SD card to load bootloader on it 

```
connect SD card to the pc 
```
> you can see all de block devices connected to your pc by making use of lsblk command, here our SD card 
> is /dev/sdb1, and /dev/sdb2
>> it means that there are two partitions in our SD card.

```
lsblk 
sudo umount /dev/sdb*
sudo cfdisk /dev/sdb
create a 100MiB FAT32 partition on your device
sudo mkfs.vfat /dev/sdb1 
sudo mount /dev/sdb1 /mnt 
cd sdcard
sudo cp * /mnt 
sudo umount /mnt 
eject the SD card from your device and connect it to target
```

### 3.2 Target part commands
> Note that 
>> host ip : 192.168.1.101 <br />
>> target(rpi4) ip : 192.168.1.60 

in this section we have to ping from target to device to ensure that our bootloader works correctly. 
to do that: <br />
put the SD card in the target and connect uart cable to it:<br />
```
sudo picocom -b 115200 /dev/ttyUSB0
TARGET COMMANDS

version
help
bdinfo $ this tells you about the board hardwares
fatls mmc 0:1 
ls mmc 0:1
printenv
printenv bootcmd

CONNECT ETHERNET CABLE TO THE TARGET 
setenv serverip 192.168.1.101 $ this is your host ip 
setenc netmask 255.255.255.0
setenv ipaddr 192.168.1.60 $ this is your target ip
ping 192.168.1.101
```
if you see `host is alive` message, it means that, you done all of the mentioned tasks succesfully!!

## 4. Generate RPI4 Kernel Image

steps of building kernel 
 * Download kernel repo
 * extract it 
 * cd to kernel directory 
 * specify architecture 
 * specify cross-compiler
 * make your board default configuration 
 * change whatever you want using menuconfig 
 * make the kernel 
 
> Note that the generated kerenl existed in the ./arch/arm64/boot directory.
```
cd rpi4/
wget https://github.com/raspberrypi/linux/archive/refs/tags/1.20220331.tar.gz
tar -xf 1.20220331.tar.gz
cd linux-1.20220331
export ARCH=arm64
export PATH=~/x-tools/aarch64-rpi4-linux-gnu/bin/:$PATH
export CROSS_COMPILE=aarch64-rpi4-linux-gnu-
ls ./arch/arm64/configs
```
in this case the default configuration of the rpi4 is bcm2711_defconfig, in fact the device tree of the bcm2711 processor (which is a 64 bit processor made by Broadcom for raspberry pi ) is that file. ( if you use other boards such as rpi2, rpi3 or any other board you have to use from the corresponding device tree file, for example for rpi2 the device tree is bcm2709_defconfig or bcm2835_defconfig depends on your board processor). 

> Another hint here is that if you use from cross-compiler which you build it, you have to add its path to path, but if you use early provided cross-compiler ( download it from internet and install it ) you do not need to add its path to system paths.
>> example of which is `sudo apt-get install gcc-aarch64-linux-gnu`

```
make bcm2711_defconfig
make menuconfig
make -j16
```
after making process is finished you can see the generated kernel image in the ./arch/arm64/boot directory.

### 4.1 Testing the generated Kernel Image
#### 4.1.1 Prepare tftp server
for testing kernel image you need to tftp server, and client. for create these two folders you have to do as follows: 

```
sudo apt update
sudo apt-get install -y tftpd-hpa 
sudo systemctl status tftpd-hpa  ( this is must be activated )
sudo nano /etc/default/tftpd-hpa

********* apply below changes to the opend file *********
TFTP_DIRECTORY="srv/lib/tftpboot" ==> "tftp"
TFTP_OPTIONS="--secure" ==> "--secure --create"
press ctrl + x followed by y and then press Enter (to save changes)
***********************************************************


****** Change tftp Directory ******
sudo mkdir /tftp
sudo chown tftp:tftp /tftp
sudo systemctl restart tftp-hpa 
sudo systemctl status tftp-hpa (tftp must be activated)
***********************************************************

****** Test the tftp installation ******
sudo apt update
sudo apt install -y tftp-hpa
hostname -I (get your ip addres)
tftp <your_ip_addres>
in the opened terminal 
vebose 
put rancheros.iso
quit
*****************************************
```

#### 4.1.2 Prepare nfs-server
> what is nfs-server? it is a file that simulate root directory for target, in other word from the target's point of view this direcotry
> is equal to root direcotry. and the installation of the kernel have to done in this folder.
>> Note that here: <br />
>> host ip: 192.168.1.101 <br />
>> target ip : 192.168.1.60 but for nfs test the target ip assume to be 192.168.1.101<br />

```
sudo apt update
sudo apt install nfs-kernel-server
sudo apt install nfs-common

sudo systemctl nfs-server   // Unknown operation nfs-server.
sudo mkdir /mnt/rootfs
sudo mkdir -p /mnt/client
sudo chown nobody:nogroup /mnt/rootfs
sudo chmod -R 777 /mnt/rootfs
sudo gedit /etc/exports 

******** Text Modifing ********
# add following to the opened text
/mnt/rootfs client-ip(rw,sync,no_subtree_check)
# for example: 
/mnt/rootfs 192.168.1.60(rw,sync,no_subtree_check)
/mnt/rootfs 192.168.0.0/24(rw,sync,no_subtree_check)
/mnt/rootfs 192.168.2.0/24(rw,sync,no_subtree_check)
# after save it 
***********************************************

sudo exportfs -r //  -r assumes as root
sudo ufw allow from 192.168.2.0/24 to any port nfs

***** test the installation ******
here i assume that host is the target and i put 
host ip instead of target ip in exportfs file 
sudo gedit /etc/exports
/mnt/rootfs 192.168.1.101(rw,sync,no_subtree_check)
# after save text file 
sudo mount 192.168.1.101:/mnt/rootfs /mnt/clientfs
cd /mnt/rootfs
touch nfs_share.txt
ls /mnt/clientfs
```

> -r means you have to access exports text file while you have root permission 

#### 4.1.3 Prepare SD card 
connect your memory to pc.
```
lsblk 
sudo umount /dev/sdb1
sudo cfdisk /dev/sdb 
sudo mkfs.vfat /dev/sdb1
sudo mount /dev/sdb1 /mnt  
cd sdcard
sudo cp * /mnt 
sudo umount /mnt
cd rpi4/linux-1.20220331
sudo cp ./arch/arm64/boot/Image /tftp
sudo cp ../../sdcard/bcm2711-rpi-4-b.dtb /tftp
sudo cp ../../sdcard/config.txt /tftp
```
unconnect the memory and connect it to the target machine. 

#### 4.1.4 Test the kernel

connect ETHERNET and UART cables to the Target and turn on the target.
```
sudo picocom -b 115200 /dev/ttyUSB0
setenv serverip 192.168.1.101 
setenv netmask 255.255.255.0
setenv ipaddr 192.168.1.60 
ping 192.168.1.60
ls /tftp
print kernel_addr_r
tftp ${kernel_addr_r} config.txt
printenv filesize
md 80000
tftp ${kernel_addr_r} Image
setenv bootcmd 'tftp ${kernel_addr_r} Image; load mmc 0:1 ${fdt_addr_r} bcm2711-rpi-4-b.dtb; booti ${kernel_addr_r} - ${fdt_addr}'
setenv bootargs console=ttyS0,115200 8250.nr_uarts=1 swiotlb=512 root=/dev/nfs ip=192.168.1.60 nfsroot=192.168.1.101:/mnt/rootfs,nfsvers=4.2,tcp init=/myinit rw
saveenv
res
```

if you see the kernel panic it means that you do correctly all the mentioned hints till now.


## 5. Adding features to generated kernel using busybox

> what is busy box? it is a software which provde several UNIX features in a single executable file, and it is compatible with several hardware architecture such as arm-based linux, android and etc.

for adding a real linux kernel features to our generated kernel we should be use from busybox, to use busybox do as follow: 

```
wget https://github.com/mirror/busybox/archive/refs/heads/master.zip
sudo unzip master.zip
sudo mv busybox-master busybox
export PATH=~/x-tools/aarch64-rpi4-linux-gnu/bin/:$PATH
export CROSS_COMPILE=aarch64-rpi4-linux-gnu-
make defconfig
make menuconfig
```

in the `menuconfig` you have to apply below changes:

 1. in the `Setting` part <br />
 2. select `Build static binary (no shared libs)` case <br />
 3. in the `Destination path for make install` type `/mnt/rootfs` <br />
> this item cause that your files installed on the rootfs directory

save and exit from the menuconfig

```
make -j16
```
after finishing the `make` process of the busybox you are able to see `busybox` file in the main directory. <br />
> using `file busybox` you can see some information about the generated file

now everything is ready for installing busybox: 

```
make install 
```
> Note that your files installed on which directory that you add it to busybox by making use of menuconfig.

here the files will be installed in the `/mnt/rootfs`

> Hint: the init file generated bu busybox is `linuxrc`<bt />

So as the next step you have to set the new generated files to bootloader: 
```
sudo picocom -b 115200 /dev/ttyUSB0
setenv serverip 192.168.1.101 
setenv netmask 255.255.255.0
setenv ipaddr 192.168.1.60 
ping 192.168.1.60
setenv bootcmd 'tftp ${kernel_addr_r} Image; load mmc 0:1 ${fdt_addr_r} bcm2711-rpi-4-b.dtb; booti ${kernel_addr_r} - ${fdt_addr}'
setenv bootargs console=ttyS0,115200 8250.nr_uarts=1 swiotlb=128 root=/dev/nfs ip=192.168.1.60 nfsroot=192.168.1.101:/mnt/rootfs,nfsvers=3,tcp init=/linuxrc rw
saveenv
res
```

> * Very Important Hint: i had some bad issue with `mmc0: unrecognised SCR structure version 4`, 
> this error wasted a lot of my time to solve it, the cause of that is in the `setenv bootcmd` command, 
> in this command there are two `fdt_addr`, in order to not to encounter this error the first `fdt_addres` has to be equalt to `fdt_addr_r`, and the second one has to be equal to `fdt_addr`, as you see in above commands.

if everything will be ok you have to see following warning or error inside you customized kernel:
`can't run '/etc/init.d/rcS': No such file or directory`

for resolving this problem, according to the `gedit busybox/examples/inittab`
```
Note: BusyBox init works just fine without an inittab. If no inittab is
found, it has the following default behavior: (Note : this file is an examples of busybox inittab file)
  ::sysinit:/etc/init.d/rcS
  ::askfirst:/bin/sh
  ::ctrlaltdel:/sbin/reboot
  ::shutdown:/sbin/swapoff -a
  ::shutdown:/bin/umount -a -r
  ::restart:/sbin/init
  tty2::askfirst:/bin/sh
  tty3::askfirst:/bin/sh
  tty4::askfirst:/bin/sh
```

what is loops in the linux? they used for Image filesystems

> It is good to say that here we use from busybox initfile instead of our initfile.

type `ifconfig` if you see the `/proc/net/dev: No such file of direcotry` it means that there is no `proc` folder, so you have to make it: <br />
```
mkdir /proc
ls /proc/
```
> what is proc: proc is the direcotry in which linux processes is loged.

as the next step you have to mount `proc` filesystem on the `/proc` direcotry, you can do it using following command: <br />
```
mount -t proc nodev /proc
ls proc
ps
```
> if proce does not existed `ps` command sould not be work.

57:00











  


