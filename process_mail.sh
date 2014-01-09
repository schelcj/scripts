#!/bin/bash
ACCOUNTS=(Pobox Umich)
for account in "${ACCOUNTS[@]}"; do
  offlineimap -u basic -o -a $account
done
