#!/usr/bin/env python3

import sys

from Cryptodome.Hash import SHA256
from Cryptodome.PublicKey import ECC
from Cryptodome.Signature import DSS

bin_path = sys.argv[1]
key_path = sys.argv[2]
key_pass = sys.argv[3]
print(key_pass)

with open(key_path, "rb") as key_file:
    key = ECC.import_key(key_file.read(), passphrase=key_pass)

prime256_names = ["NIST P-256", "p256", "P-256", "prime256v1", "secp256r1"]
if key.curve not in prime256_names:
    raise ValueError(f"Unsupported curve: {key.curve}")

bytes_x_point = key.pointQ.x.to_bytes().rjust(32, b"\0")
bytes_y_point = key.pointQ.y.to_bytes().rjust(32, b"\0")

key_hash = SHA256.new(bytes_x_point + bytes_y_point)

with open(bin_path, "wb") as bin_file:
    bin_file.write(key_hash.digest())
