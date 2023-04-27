#!/bin/sh
emacsclient -c -F '((name . "emacs-capture"))' -e '(org-capture)'
