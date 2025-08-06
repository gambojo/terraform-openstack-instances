#! /usr/bin/env bash
read -r password
echo "{\"hash\": \"$(openssl passwd -6 -quiet $(cut -d\" -f4 <<< $password))\"}"
