# First steps

### Clone the repository:

```bash
git clone --recursive --branch tprrt/master https://github.com/Zondax/buildroot-zondax/
cd buildroot-zondax
```
### Generate optee-keys
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

## iMX8MMevk

```bash
make zondaxtee_imx8mmevk_defconfig
make
```

Keys will be generated in
```bash
buildroot-zondax/keys/cst_keys
```

## Program the SRK to close the board

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

## Verify HAB successfully authenticates the signed image

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

## Close the device

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
