#!/bin/bash

for acct in pobox umich; do
  getmail -v --rcfile getmailrc-${acct}
  mu index --nocleanup --maildir="~/Mail/${acct^}/[Gmail].Sent\ Mail" --muhome=~/.mu-sent-index
  mu index --maildir ~/Mail/${acct^}/$(date '+%Y')/$(date '+%m')/
done
