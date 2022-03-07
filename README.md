# buildroot-zondax

This repository contains three different configurations

## Qemu

```bash
make zondaxtee_qemu_defconfig
make
```

to state Qemu, you should run

```
make start-qemu-host
```

To exit, you can use `CTRL+A X`

## iMX8MMevk

```bash
make zondaxtee_imx8mmevk_defconfig
make
```

## STM32MP157

```bash
BUILDROOT=st make zondaxtee_stm32mp157_dk2_defconfig
BUILDROOT=st make
```
