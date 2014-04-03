#!/bin/sh

if kinit -R; then
  echo "[32;1mRenew success![0m"
else
  echo "[31;1mRenew fail, please if kinit was installed properly![0m"
fi
