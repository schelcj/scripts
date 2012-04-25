#!/bin/bash -l

module load python
module load offlineimap
module load getmail

ACCOUNTS=(Pobox Umich Avlug)

for account in "${ACCOUNTS[@]}"; do
  offlineimap -u basic -o -a $account
  getmail --rcfile getmailrc-$(echo $account|tr '[A-Z]' '[a-z')
done

/usr/local/bin/mairix -F
