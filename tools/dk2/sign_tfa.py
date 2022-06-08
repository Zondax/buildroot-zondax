#!/usr/bin/env python3

import sys
import struct

from Cryptodome.Hash import SHA256
from Cryptodome.PublicKey import ECC
from Cryptodome.Signature import DSS

img_path = sys.argv[1]
key_path = sys.argv[2]
key_pass = sys.argv[3]

with open(key_path, "rb") as key_file:
    key = ECC.import_key(key_file.read(), passphrase=key_pass)

prime256_names = ["NIST P-256", "p256", "P-256", "prime256v1", "secp256r1"]
if key.curve not in prime256_names:
    raise ValueError(f"Unsupported curve: {key.curve}")

bytes_x_point = key.pointQ.x.to_bytes().rjust(32, b"\0")
bytes_y_point = key.pointQ.y.to_bytes().rjust(32, b"\0")

with open(img_path, "rb") as img_file:
    data = bytearray(img_file.read())

if data[0:4] != b"STM2":
    raise ValueError("Invalid image format")

data[100:104] = struct.pack("<I", 0)
data[104:108] = struct.pack("<I", 1)
data[108:140] = bytes_x_point
data[140:172] = bytes_y_point

img_hash = SHA256.new(data[72:])
data[4:68] = DSS.new(key, "fips-186-3").sign(img_hash)

with open(img_path, "wb") as img_file:
    img_file.write(data)
