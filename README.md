# RuzTEE images

## Clone the repository:

```bash
git clone --recursive https://github.com/Zondax/buildroot-zondax/tree/dk2_secure_boot
cd buildroot-zondax
```

## Generating Keys

| Command              | Description          |
| -------------------- | -------------------- |
| `make genkeys_optee` | Generates OPTEE keys |
| `make genkeys_uboot` | Generates UBOOT keys |
| `make genkeys_tfa`   | Generates TFA keys   |
| `make genkeys`       | Generates all keys   |

these keys will be placed in the corresponding directories (relative to this file)

| Keys  | Description         |
| ----- | ------------------- |
| OPTEE | `./keys/optee_keys` |
| UBOOT | `./keys/uboot_keys` |
| TFA   | `./keys/tfa_keys`   |

you can also use `make showkeys` to list the existing keys and locations

## Building

This repository contains three different configurations

### Qemu

```bash
make zondaxtee_qemu_defconfig
make
```

to start Qemu, you should run

```
make start-qemu-host
```

To exit, you can use `CTRL+A X`

### iMX8MMevk

```bash
make zondaxtee_imx8mmevk_defconfig
make
```

### STM32MP157

```bash
BUILDROOT=st make zondaxtee_stm32mp157_dk2_defconfig
BUILDROOT=st make
```

## Signing STM FIP image
:warning: Should we direct to the corresponding documentation?

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
