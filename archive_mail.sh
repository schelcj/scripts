#!/bin/bash

ACCOUNTS=(pobox umich)

for acct in "${ACCOUNTS[@]}"; do
  getmail --rcfile getmailrc-${acct}
  mairix -F -f ~/.mairixrc-${acct}
done

# mairix -F
# pidof mairix 
# if [ $? -eq "1" ]; then
#   lock_file="${HOME}/.mairix.db.lock"
#   test -e $lock_file && rm -v $lock_file
# fi
