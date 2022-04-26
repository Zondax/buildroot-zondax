# First steps

## Clone the repository:

```bash
git clone --recursive --branch master https://github.com/Zondax/buildroot-zondax/
cd buildroot-zondax
```
## Generate optee-keys
we have enabled optee-signing of TAs by default:
```bash
./tools/optee/gen_keys.sh
```
this will generate keys in
```bash
buildroot-zondax/keys/optee/
```

them we can start a build depending on the target platform:


# buildroot-zondax

This repository contains three different configurations

## Qemu

```bash
make zondaxtee_qemu_defconfig
make
```

to start Qemu, you should run

```
make start-qemu-host
```

To exit, you can use `CTRL+A X`

## iMX8MMevk

```bash
make zondaxtee_imx8mmevk_defconfig
make
```

Keys will be generated in
```bash
buildroot-zondax/keys/cst_keys
```

### Program the SRK to close the board

Values to use are stored in:
```bash
./keys/cst_keys/crts/SRK_1_2_3_4_fuse.hexdump
```

For example:
```bash
cat ./keys/cst_keys/crts/SRK_1_2_3_4_fuse.hexdump
0xB37AECC0
0xC2010914
0x3EFFED48
0x75CEDC7D
0xCC8E042
0xA4AE44AD
0xEED52F7B
0x1221E1C7
```

These values can be burn from U-Boot, as shown below:
```bash
fuse prog -y 6 0 0xB37AECC0
fuse prog -y 6 1 0xC2010914
fuse prog -y 6 2 0x3EFFED48
fuse prog -y 6 3 0x75CEDC7D
fuse prog -y 7 0 0xCC8E042
fuse prog -y 7 1 0xA4AE44AD
fuse prog -y 7 2 0xEED52F7B
fuse prog -y 7 3 0x1221E1C7
```

Next it to reboot the target,
```bash
reset
```

### Verify HAB successfully authenticates the signed image

HAB generates events when processing the commands if it encounters issues.
The U-Boot "hab_status" command displays any events that were generated.

Run it at the U-Boot command line:
```bash
hab_status
```

If everything is okay you should get the following output:
```bash
Secure boot disabled
HAB Configuration: 0xf0, HAB State: 0x66
No HAB Events Found!
```

### Close the device

After the device successfully boots a signed image without generating any HAB
events, it is safe to secure, or "close", the device.

```bash
fuse prog 1 3 0x02000000
reset
hab_status
Secure boot enabled
HAB Configuration: 0xcc, HAB State: 0x99
No HAB Events Found!
```

## STM31MP157C

### Generate keys for uboot

although we can use multiple keys in uboot to sign each partition
in image.its, we for now use only one keys to sign all of them.
```bash
./tools/uboot/gen_keys.sh
```
### Generate keys for signing the fip partition
we also have a script to generate keys using the ST tool,
moreover, there is a script we use to sign the fip image.
to generate keys:
```bash
./tools/dk2/generate_keys.sh
```
the keys will be stored in:
```bash
keys/tfa_keys/
```
if you already have keys for tfa_signing, put them all there. any of the
scripts described so far will overwrite any key already present in the
keys tree.

### Build the SDcard image

```bash
make zondaxtee_stm32mp157_dk2_defconfig
make
```

### Signing STM FIP image
in order to sign the image we need to run a complete build, them, run
the following script:
```bash
./tools/dk2/sign_image.sh
```
if the signing steps goes well you would see:

```bash
board           Config.in      external.mk  Makefile
buildroot       configs        images       package
buildroot-st    external       keys         README.md
busybox.config  external.desc  local.mk     tools
       -------------------------------------------------------------------
                       STM32MP Signing Tool v2.9.0
       -------------------------------------------------------------------

 Prime256v1 curve is selected.
 Header version 1 preparation ...
 Reading Private Key File...
 ECDSA signature generated.
 Signature verification:  SUCCESS
 The Signed image file generated successfully:  /home/neithanmo/Documents/test-uboot/tools/dk2/../..//images//tf-a-stm32mp157c-dk2-mx_Signed.stm32
*.stm32 signed successfully
```
after this step we need to build the final image again
so our [post_image](https://github.com/Zondax/buildroot-zondax/blob/dk2_secure_boot/board/zondax/stm32mp157/post-image.sh) script will recognize our signed image and will use
it instead of the plain image that was build initially.

# Known problem with secure-boot dk2
after signing the FIP partition, the  FSBL does not boot, BUT if we use
the optee config file [here](https://github.com/Zondax/buildroot-zondax/blob/dk2_secure_boot/board/zondax/stm32mp157/optee_conf.mk) and pass it to optee:
```bash
 CFG_OPTEE_CONFIG=$(BR2_EXTERNAL_ZONDAXTEE_PATH)/board/zondax/stm32mp157/optee_conf.mk
```
through the optee additional flags:
```bash
BR2_TARGET_OPTEE_OS_ADDITIONAL_VARIABLES="... CFG_OPTEE_CONFIG=$(BR2_EXTERNAL_ZONDAXTEE_PATH)/board/zondax/stm32mp157/optee_conf.mk"
```
We are able to boot,
however this causes the SSBL(uboot) not being loaded.

on the other hand, if we do not use that optee configuration file, and
dont sign the FIP image, the Uboot reports the following error:

```bash
Found /boot/extlinux/extlinux.conf
Retrieving file: /boot/extlinux/extlinux.conf
257 bytes read in 34 ms (6.8 KiB/s)
1:      stm32mp157c-dk2
Retrieving file: /fitImage
Failed to load '/fitImage'
Skipping stm32mp157c-dk2 for failure retrieving kernel
SCRIPT FAILED: continuing...
```
