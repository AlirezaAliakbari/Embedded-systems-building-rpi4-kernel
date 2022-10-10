
# Course Summery

## Requirements

  * Raspberry pi 4 model B 4G-RAM.
  * A PC as your host machine.
  * host IP: 192.168.1.101.
  * target IP: 192.168.1.60.
  >  * Note that this summery is for 64bit rpi4 processor, (for 32bit processors such as rpi2, rpi3 another summery is been created.) 
  * Downlaod the `el2genfile.sh` using following command and run it: (it automatically create all the required things for you in this cuarse)
  ```
  sudo curl -o . https://raw.githubusercontent.com/MMahdiSayadi/Embedded_Courses/main/embedded2/el2genfile.sh
  sudo chmod +x el2genfile.sh
  ./el2genfile.sh rpi4
  ```
  it create a directory `~/Project/EL/el2/rpi4` for you which contain following files: <br />
.<br />
├── build<br />
│   ├── build-busybox<br />
│   └── build-dropbear<br />
├── makefiles<br />
│   ├── main.c<br />
│   ├── Makefile<br />
│   ├── mult.c<br />
│   └── mult.h<br />
├── src<br />
│   ├── busybox<br />
│   ├── dropbear<br />
│   └── zlib<br />
├── staging<br />
└── target<br />

Let's talk a little about the folders inside the rpi4  folder: <br />
you can see five main folders which are `build`, `makefiles`, `src`, `staging`, `target`, the definition of which came in the below: <br />
 * `src`: it is the place where you save your sources in there, for example the zip file of the busybox which you download is stored here. <br />
 * `build`: is the folder where the sources are compoiled there <br />
 * `target`: this folder is your rootfile system directory that you can give it to the nfs-kernel-server
 * `staging` : is the folder which the build files are installed initially, and alos we remain all the libraries with all dependencies <br />


# Dynamically build a package steps 
To build a package wheter dynamic of static you need some tools such as <br />

 1. Auto tools <br />
 2. Cmake <br />
 3. ...<br />
 
here we use from autotools to build our packages. <br />
steps of build a pakage using autotools said in the following list: <br />

 * Download the package <br />
 * read its dependencies and helps <br />
 * configure the package <br />
 * make the package <br />
 * install the package <br />
 
here for example we want to install `alsalib` package: <br />
first we download it in the `src` folder, in the next step we make a folder called `build-alsalib` in the `build` folder, cd to such folder, as the next step we build the package in the build folder, the standard syntax for many of the packages came in this README, all the dependecies related to the installing packag could be found in its README in the build folder. and you can see theme, when you config your package corectlly you have to make it, some errors exists that you may face with theme in the make process, following hint helps you to solve theme: <br />
talk little about debugging with `make` instead of `make -jn`. when you see lots of errors this may cause that your make file is run parallel and this cause you face with many errors, so a good solution to find out what is the main error is to simply run `make` without -jn <br />
using `make -jn` actually compile your program. if your compilation completed correctly, you can install it, in the standard installtion, all the installing packages must be installed in the `staging` package. <br />
using `make install DESTDIR=/<staging_dir>` you can install your package in the staging folder. there are all the package's dependencies in the staging package related to what folder that you installed theme. 
 

## Course Steps of Creating Custom Kernel

  1. dynamically build the busybox 
  2. Add SSH to our kernel

## 2. Dynamically build busybox
oppose to the el1 in this part we want to build busybox dynamically.
whenever you open a new terminal you have to create `vp=~/Project/EL/el2/rpi4` as your environment variable.
```
vp=~/Project/EL/el2/rpi4
cd $vp/build/build-busybox  
export PATH=~/x-tools/aarch64-rpi4-linux-gnu/bin/:$PATH
export CROSS_COMPILE=aarch64-rpi4-linux-gnu-
export ARCH=arm64
echo $ARCH
echo $CROSS_COMPILE
make -C $vp/src/busybox defconfig O=$PWD
make menuconfig
```
in the `menuconfig --> setting` change the install directory to `/home/<YOUR_PC_NAME>/Project/EL/el2/rpi4` and save changes.<br />
> Hint: menu config does not work with directory like that `~/...`<br />
```
make -j12
```
after make type: `file busybox`<br />
its architecture must be `ARCH 64`.
> Note that if you build the busybox and see that it natively compiled, it means that your directory make as root. it means that your directory make command is somthing like that : `sudo mkdir <DIR> -p` 

before you install the busybox in the `target` folder, you need to copy the busybox requirements because it compiled dynamically.so to prepare the busybox requirments.
> we can see the instsallation requirements of any package using ldd.
```
cd target
mkdir lib
cp ~/x-tools/aarch64-rpi4-linux-gnu/aarch64-rpi4-linux-gnu/sysroot/lib/ld-linux-aarch64.so.1 lib
to see other reqirements: 
aarch64-rpi4-linux-gnu-ldd --root `aarch64-rpi4-linux-gnu-gcc --print-sysroot` busybox
```
after runnig the above command you can see the the requirements of the busybox is : 
```
libm.so.6 => /lib/libm.so.6 (0x00000000deadbeef)
libc.so.6 => /lib/libc.so.6 (0x00000000deadbeef)
ld-linux-aarch64.so.1 => /lib/ld-linux-aarch64.so.1 (0x00000000deadbeef)
libresolv.so.2 => /lib/libresolv.so.2 (0x00000000deadbeef)
```
in the next step you have to copy these requirement into the `target/lib` folder: 
```
cp ~/x-tools/aarch64-rpi4-linux-gnu/aarch64-rpi4-linux-gnu/sysroot/lib/libc.so.6 .
cp ~/x-tools/aarch64-rpi4-linux-gnu/aarch64-rpi4-linux-gnu/sysroot/lib/libresolv.so.2 .
cp ~/x-tools/aarch64-rpi4-linux-gnu/aarch64-rpi4-linux-gnu/sysroot/lib/libm.so.6 .
ls ./lib
```
now your requirement is completed, but in the 64bit systems you also need a lib64 directory which point to the lib directory, for create this folder
```
cd target 
ln -s lib lib64
ls
ls ./lib
```
now you can install the busybox
```
cd build-busybox
make install 
```

Once installation process is compolet do the following task in the `target` folder: 
```
mkdir proc sys dev etc lib
mkdir etc/init.d
nano etc/init.d/rcS
```
inside the text
```
#!/bin/sh
mount -t sysfs none /sys 
mount -t proc none /proc
```
after save the text file type the following command to make it executable: 
```
chomd +x etc/init.d/rcS
```
test the generated init file: 
set following command inside the u-boot environment: 
```
setenv bootcmd 'load mmc 0:1 ${kernel_addr_r} Image; load mmc 0:1 ${fdt_addr_r} bcm2711-rpi-4-b.dtb; booti ${kernel_addr_r} - ${fdt_addr}'
setenv bootargs console=ttyS0,115200 8250.nr_uarts=1 maxcpus=1 swiotlb=512 root=/dev/nfs ip=192.168.1.60 nfsroot=192.168.1.102://home/<PC_NAME>/Project/EL/el2/rpi4/target/,nfsvers=3,tcp init=/linuxrc rw
```
if every this is ok you can see the kernel command line in your console.<br />

## Add SSH to our kernel
now it is time to add zlib and dropbear to our kernel as wel.<br />
our goal is to add dropbear to our kernel. what is the dropbear: it is something like SSH, which is created for lunching on embedded boards. its main dependency is zlib (it is used to file compression). so our main steps here is following steps: <br />
 * add zlib to out kernel<br />
 * add dropbear to our kernel<br />
to do that follow the below operations: <br />
```
cd $vp/build/build-zlib
CC=aarch64-rpi4-linux-gnu-gcc ../../src/zlib/configure --prefix=/usr // to configure the package
make j8 // to compile the package
file libz.so.1.2.11
make DESTDIR=$vp/staging install // to install the program
```
to test the library: <br />
```
mkdir ../zlib-test
cd ../zlib-test
wget https://gist.githubusercontent.com/arq5x/5315739/raw/3044a8972f30a3ccc42456ef758195f361a0b3a9/zlib-example.cpp
export PKG_CONFIG_ALLOW_SYSTEM_LIBS=1
export PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1
PKG_CONFIG_LIBDIR=$vp/staging/usr/lib/pkgconfig PKG_CONFIG_SYSROOT_DIR=$vp/staging pkg-config --cflags --libs zlib
aarch64-rpi4-linux-gnu-g++ -o zlib-test zlib-example.cpp $(PKG_CONFIG_LIBDIR=$vp/staging/usr/lib/pkgconfig PKG_CONFIG_SYSROOT_DIR=$vp/staging pkg-config --cflags --libs zlib)
file zlib-test
```
the next step is to run compiled example: <br />
to run it, we have to no that there is anyother dependency for the compiled program, to know that: 
```
aarch64-rpi4-linux-gnu-ldd --root `aarch64-rpi4-linux-gnu-gcc --print-sysroot` zlib-test
```
the next step is to copy the dependencies of hte example: 
```
cp -a ../../staging/usr/lib/libz.so.1* ../../target/usr/lib
cp -a ../../staging/usr/lib/libz.so.1* ../../target/usr/lib
cp -a ~/x-tools/aarch64-rpi4-linux-gnu/aarch64-rpi4-linux-gnu/sysroot/lib/libstdc++.so.6* ../../target/usr/lib/
cp -a ~/x-tools/aarch64-rpi4-linux-gnu/aarch64-rpi4-linux-gnu/sysroot/lib/libgcc_s.so.1 ../../target/usr/lib/
cp zlib-test ../../target/usr/bin
```
to strip libraries you can use from following command: <br />
```
aarch64-rpi4-linux-gnu-strip ../../target/usr/lib/libz.so.1.2.11
```
this methos helps you to compress the libraries. <br />

### turn on the board 
in the board command: 
copy the ldconfig to into your target rootfile system directory (which here is `target` folder). <br />
```
cp $(find `aarch64-rpi4-linux-gnu-gcc --print-sysroot` -name ldconfig) ../../target/sbin
ldconfig // this helps you to kernel recognise the libraries 
zlib-test
```

>  when you type ldconfig in your board and you see the permission denied about the etc/ld.so.cache you have to unlock the target folder for doing this go to the rpi4 folder and do as follow:<br />
> `cd target` <br />
> `sudo chmod a+rwx *`<br />

### Adding dropbear 
dropbear installation process is an autotools installation process. so the steps of installing it is the same with mentioned installation process in this readme. for installing it go to the `build/build-dropbear` folder: <br />
```
../../src/dropbear/configure --host=aarch64-rpi4-linux-gnu --with-zlib=$vp/staging/usr --prefix=/usr
make -j8
file dropbear
make install DESTDIR=$vp/staging
tree $vp/staging
```
nest step is to copy required libraries, and binary files: <br />
to see dropbear dependenciese libraries you can use from following command. <br />
```
aarch64-rpi4-linux-gnu-ldd --root `aarch64-rpi4-linux-gnu-gcc --print-sysroot` 
```
copye the requirements: 
```
cp ~/x-tools/aarch64-rpi4-linux-gnu/aarch64-rpi4-linux-gnu/sysroot/lib/libcrypt.so.1 ../../target/lib
```
copy the binary files: <br />
```
cp $vp/staging/usr/bin/dropbear* ../../target/bin
cp $vp/staging/usr/bin/dbclient ../../target/bin
cp $vp/staging/usr/sbin/dropbear ../../target/usr/sbin
ssh-keygen -f "/home/mahdidesk/.ssh/known_hosts" -R "192.168.2.20"
```
### turn on the board 
run the dropbear: 
```
dropbear --version
mkdir etc/dropbear
```
create a file 
```
vi etc/passwd 
****** inside the text ******
roott:x:0:0:root:/root:/bin/sh
*****************************
mkdir /root
```
in the `etc/init.d/rcS` type following commands : 
```
mkdir dev/pts
mount -t devpts none /dev/pts
dropbear -ER 
```
run init file using `/etc/init.d/rcS`
```
passwd
enter a password 
```
in the host terminal: 
```
ssh root@192.168.1.60
enter your password
after enterin passwrod you can connect to your board using network
```

## 2. Adding audio features to our boards
for adding abality to read, play and write audio we have to add following libraries to our kernel. 
 1. vorbis-tools
 2. libao
 3. alsa-lib
 4. alsa-utils
 5. libvorbis
 6. libogg
 
compiling alsa-lib 
```
cd src
wget http://sources.buildroot.net/alsa-lib/alsa-lib-1.2.3.2.tar.bz2
tar -xf alsa-lib-1.2.3.2.tar.bz2
rm -r alsa-lib-1.2.3.2.tar.bz2
mv alsa-lib-1.2.3.2.tar.bz2 alsa-lib
mkdir ../build/build-alsa-lib
cd ../build/build-alsa-lib
CC=aarch64-rpi4-linux-gnu-gcc ../../src/alsa-lib/configure --prefix=/usr --host arm-linux 
make -j16
make install DESTDIR=$vp/staging
```
in the next step copy the required libraries to the target folder: 
```
cp -a ../../staging/usr/lib/libasound.so.2* ../../target/usr/lib
aarch64-rpi4-linux-gnu-strip ../../target/usr/lib/libasound.so.2*
```

compiling alsa-utils: 
```
cd src
wget http://sources.buildroot.net/alsa-utils/alsa-utils-1.2.4.tar.bz2
tar -xf alsa-utils-1.2.4.tar.bz2
rm -r alsa-utils-1.2.4.tar.bz2
mv alsa-utils-1.2.4 alsa-utils
mkdir ../build/build-alsa-utils
cd ../build/build-alsa-utils
LDFLAGS=-L/home/mahdidesk/Project/EL/el2/rpi4/staging/usr/lib CPPFLAGS=-I/home/mahdidesk/Project/EL/el2/rpi4/staging/usr/include CC=aarch64-rpi4-linux-gnu-gcc ../../src/alsa-utils/configure --prefix=/usr --host arm-linux --disable-alsamixer
make -j8
make install DESTDIR=$vp/staging 
```
copy the alsa-utils requirments: 
```
cp -a ../../staging/usr/bin/a* ../../staging/usr/bin/speaker-test ../../target/usr/bin
cp -a ../../staging/usr/sbin/alsa* ../../target/usr/sbin
mkdir ../../target/usr/share/alsa -p
cp -a  ../../staging/usr/share/alsa/cards ../../target/usr/share/alsa
cp -a  ../../staging/usr/share/alsa/alsa.conf ../../target/usr/share/alsa
mkdir ../../target/usr/share/alsa/pcm -p
cp -a  ../../staging/usr/share/alsa/pcm/default.conf ../../target/usr/share/alsa/pcm
```
go to the kernel and install audio drivers to the `target` folder
```
cd /home/mahdidesk/Project/EL/el1/rpi4/linux-1.20220331
export ARCH=arm64
export CROSS_COMPILE=aarch64-rpi4-linux-gnu-
export PATH=~/x-tools/aarch64-rpi4-linux-gnu/bin/:$PATH
make modules_install INSTALL_MOD_PATH=/home/mahdidesk/Project/EL/el2/rpi4/target
```
### turn on the board
tun on the board and test the audio card
#### host commands 
```
cd ../../target
mkdir usr/share/sound -p
cd usr/share/sound
#download the audio file to test the audio card
wget https://www2.cs.uic.edu/\~i101/SoundFiles/BabyElephantWalk60.wav
wget https://ia600902.us.archive.org/23/items/tvtunes_502/Pink%20Panther.ogg //for furthure works
sudo nano etc/init.d/rcS
```
#### target commands
```
sudo picocom -b 115200 /dev/ttyUSB0
cd usr/share/sound
BabyElephantWalk60.wav
```
compiling libogg: 
```
cd src
wget http://sources.buildroot.net/libogg/libogg-1.3.4.tar.xz
tar -xf libogg-1.3.4.tar.xz
rm -r libogg-1.3.4.tar.xz
mv libogg-1.3.4 libogg
cd libogg
mkdir ../../build/build-libogg
cd ../../build/build-libogg
CC=aarch64-rpi4-linux-gnu-gcc ../../src/libogg/configure --prefix=/usr --host arm-linux
make -j8
make install DESTDIR=$vp/staging
```
copy libogg requirements: 
```
cp -a ../../staging/usr/lib/libogg.so.0* ../../target/usr/lib
cp ../../staging/usr/bin/ogg* ../../target/usr/bin 
```

compiling libvorbis: 
```
cd src
wget http://sources.buildroot.net/libvorbis/libvorbis-1.3.7.tar.xz
tar -xf libvorbis-1.3.7.tar.xz
rm -r libvorbis-1.3.7.tar.xz
mv libvorbis-1.3.7 libvorbis
cd libvorbis
mkdir ../build/build-libvorbis
cd ../build/build-libvorbis
CC=aarch64-rpi4-linux-gnu-gcc ../../src/libvorbis/configure --prefix=/usr --host arm-linux --with-ogg-includes=/home/mahdidesk/Project/EL/el2/rpi4/staging/usr/include --with-ogg-libraries=/home/mahdidesk/Project/EL/el2/rpi4/staging/usr/lib
make -j8
make install DESTDIR=$vp/staging/
```
copy the requirements
```
cp -a ../../staging/usr/lib/libvorbis.so.0* ../../target/usr/lib
cp -a ../../staging/usr/lib/libvorbisfile.so.3* ../../target/usr/lib
cp -a ../../staging/usr/lib/libvorbisenc.so.2* ../../target/usr/lib
```
compiling libao 
```
wget http://sources.buildroot.net/libao/libao-1.2.0.tar.gz
tar -xf libao-1.2.0.tar.gz
rm -r libao-1.2.0.tar.gz
mv libao-1.2.0 libao
cd libao
mkdir ../../build/build-libao
cd ../../build/build-libao
LDFLAGS=-L/home/mahdidesk/Project/EL/el2/rpi4/staging/usr/lib CPPFLAGS=-I/home/mahdidesk/Project/EL/el2/rpi4/staging/usr/include CC=aarch64-rpi4-linux-gnu-gcc ../../src/libao/configure --prefix=/usr --host arm-linux --enable-alsa --disable-pulse
make -j16
make install DESTDIR=$vp/staging
```

copy the requirements: 
```
mkdir ../target/usr/lib/ao
cp -a usr/lib/libao.so.4* ../target/usr/lib
cp usr/lib/ao/plugins-4 ../target/usr/lib/ao
cp -r usr/lib/ao/plugins-4 ../target/usr/lib/ao
```

compiling vorbis-tools 
```
cd src 
wget http://sources.buildroot.net/vorbis-tools/vorbis-tools-1.4.2.tar.gz
tar -xf vorbis-tools-1.4.2.tar.gz
rm -r vorbis-tools-1.4.2.tar.gz
mv vorbis-tools-1.4.2 vorbis-tools
cd vorbis-tools
mkdir ../../build/build-vorbis-tools
cd ../../build/build-vorbis-tools 
export PKG_CONFIG_ALLOW_SYSTEM_LIBS=1
export PKG_CONFIG_ALLOW_SYSTEM_CFLAGS=1
PKG_CONFIG_SYSROOT_DIR=/home/mahdidesk/Project/EL/el2/rpi4/staging PKG_CONFIG_LIBDIR=/home/mahdidesk/Project/EL/el2/rpi4/staging/usr/lib/pkgconfig CC=aarch64-rpi4-linux-gnu-gcc ../../src/vorbis-tools/configure --prefix=/usr --host arm-linux --without-curl
make -j16
make install DESTDIR=$vp/staging
```
copy the librarie requirements: 
```
```

after that the setup audio on the board is completed you can play an ogg file which is downloaded already on your device as follows: 
```
aplay usr/share/sound/Pink Panther.ogg
```



## Appendix
### Learn how to make a simple makefile
cd to the makefiles folder and run following commands: <br />
to make the output you only need to type `make` into your terminal.<br />
> using `make clean` you can clean all your build files.<br />

what `ncurses` lib does? it create text user interface like menuconfig.




when you type `ldconfig` in your board and you see the permission denied about the `etc/ld.so.cache` you have to unlock the `target` folder for doing this go to the `rpi4` folder and do as follow: <br />
```
cd target
sudo chmod a+rwx *
```
this command ublock all the folders and premise them to read, write and change inside theme.




alsa-lib
http://sources.buildroot.net/alsa-lib/alsa-lib-1.2.3.2.tar.bz2

alsa-utils
http://sources.buildroot.net/alsa-utils/alsa-utils-1.2.4.tar.bz2

sample-wavefile
https://www2.cs.uic.edu/~i101/SoundFiles/BabyElephantWalk60.wav

libogg 
http://sources.buildroot.net/libogg/libogg-1.3.4.tar.xz

libvorbis
http://sources.buildroot.net/libvorbis/libvorbis-1.3.7.tar.xz

libao 
http://sources.buildroot.net/libao/libao-1.2.0.tar.gz

vorbis tools 
http://sources.buildroot.net/vorbis-tools/vorbis-tools-1.4.2.tar.gz

pink panther 
https://ia600902.us.archive.org/23/items/tvtunes_502/Pink%20Panther.ogg



> Diference between destdir and prefix is in minute 24:24 el2 ses3

pckconfig files do not require in our minimal kernel, bacaus they give us some informations about cflags and libdirectories.



application of ncurses: it is used for text UI.


if you see the following error once you `make -j8` the autotools-utils
`[Makefile:429: all-recursive] Error 1`
you can use from following solution
```
mkdir _install
make -k install DESTDIR=$PWD/_install
```
> https://chowdera.com/2022/169/202206180524244166.html this is the link which solve above prbolem


related to the audio card of the board we have to say that, whenever you turn off your board and turn on it again you have to install it driver again using modprobe command. to do that one can use from following command: <br />
for example here our driver is `bcm_2835` <br />
`modprobe bcm_2835`

talk little about debugging with `make` instead of `make -jn`. when you see lots of errors this may cause that your make file is run parallel and this cause you face with many errors, so a good solution to find out what is the main error is to simply run `make` without -jn

