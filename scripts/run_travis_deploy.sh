#!/usr/bin/env bash

case "${TRAVIS_TAG}" in
  v*)
    make docker
    ;;
  infrastructure*)
    make terraform
    ;;
  *)
    echo "Not a deploy tag - ${TRAVIS_TAG} - ignoring."
    ;;
esac
