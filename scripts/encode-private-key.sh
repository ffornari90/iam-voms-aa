#!/bin/bash
if [ $# -eq 0 ]; then
  echo "No arguments supplied. Exit."
  exit 1
else
  FILE=$1
  if [ ! -f "$FILE" ]; then
    echo "$FILE does not exist. Exit."
    exit 2
  else
    if ! openssl rsa -in $FILE -noout -check > /dev/null 2>&1; then
      echo "$FILE is not a private key file. Exit."
      exit 3
    else
      echo "$(cat $FILE)" | base64 -w0
      printf '\n'
      exit 0
    fi
  fi
fi
