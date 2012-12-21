#!/bin/bash
#print -Pn "^[]0;$1^G" 

function title {
  echo -en "\033]2;$1\007"
}

function icon_label {
  echo -en "\033]1;$1\007"
}

title "$1"
icon_label "$1"
