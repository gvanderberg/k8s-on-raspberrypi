#!/bin/bash

curl -sSL get.docker.com | sh && usermod pi -aG docker

dphys-swapfile swapoff #&& \
  #sudo dphys-swapfile uninstall && \
  #sudo update-rc.d dphys-swapfile remove