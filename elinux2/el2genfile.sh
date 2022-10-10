 #!/bin/bash


foldername=$1
varpath=~/Project/EL/el2
varpath1=$varpath/$foldername


sudo mkdir $varpath1 -p 
sudo mkdir $varpath1/build $varpath1/staging $varpath1/target $varpath1/src $varpath1/makefiles

# Prepare Makefile 
sudo curl -o $varpath1/makefiles/Makefile https://raw.githubusercontent.com/MMahdiSayadi/Embedded_Courses/main/embedded2/Makefile/Makefile
sudo curl -o $varpath1/makefiles/main.c https://raw.githubusercontent.com/MMahdiSayadi/Embedded_Courses/main/embedded2/Makefile/main.c
sudo curl -o $varpath1/makefiles/mult.h https://raw.githubusercontent.com/MMahdiSayadi/Embedded_Courses/main/embedded2/Makefile/mult.h
sudo curl -o $varpath1/makefiles/mult.c https://raw.githubusercontent.com/MMahdiSayadi/Embedded_Courses/main/embedded2/Makefile/mult.c


#make busy box requirements
sudo wget https://busybox.net/downloads/busybox-1.35.0.tar.bz2  -P $varpath1/src
sudo tar -xf $varpath1/src/busybox-1.35.0.tar.bz2 --directory $varpath1/src
sudo mv $varpath1/src/busybox-1.35.0 $varpath1/src/busybox
sudo mkdir $varpath1/build/build-busybox -p
sudo rm -r $varpath1/src/busybox-1.35.0.tar.bz2

#make zlib and its dependencies
sudo wget https://cytranet.dl.sourceforge.net/project/libpng/zlib/1.2.11/zlib-1.2.11.tar.xz -P $varpath1/src
sudo tar -xf $varpath1/src/zlib-1.2.11.tar.xz --directory $varpath1/src
sudo mv $varpath1/src/zlib-1.2.11 $varpath1/src/zlib
sudo rm -r $varpath1/src/zlib-1.2.11.tar.xz 

# Prepare dropbear for create the remote ssh between host and target 
sudo wget https://matt.ucc.asn.au/dropbear/dropbear-2022.82.tar.bz2 -P $varpath1/src
sudo tar -xf $varpath1/src/dropbear-2022.82.tar.bz2 --directory $varpath1/src
sudo mv $varpath1/src/dropbear-2022.82 $varpath1/src/dropbear 
sudo rm -r $varpath1/src/dropbear-2022.82.tar.bz2
sudo mkdir $varpath1/build/build-dropbear -p



echo "All needed folder have been generated !!"























