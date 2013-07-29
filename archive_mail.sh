#!/bin/bash -l

module load python
module load offlineimap
module load getmail

ACCOUNTS=(Pobox Umich)

for account in "${ACCOUNTS[@]}"; do
  getmail --rcfile getmailrc-$(echo $account|tr '[A-Z]' '[a-z')
done

/usr/local/bin/mairix -F
