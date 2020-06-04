#!/usr/bin/python3

import os
import time

command = [
    "certbot",
    "-n", "--agree-tos", # non-interactive
    "-d", os.environ["HOSTNAMES"],
    "-m", "{}@{}".format(os.environ["POSTMASTER"], os.environ["DOMAIN"]),
    "certonly", "--standalone",
    "--cert-name", "mailu",
    "--preferred-challenges", "http",
    "--keep-until-expiring",
    "--rsa-key-size", "4096",
    "--config-dir", "/certs/letsencrypt"
]

# Run certbot once
os.system(" ".join(command))

