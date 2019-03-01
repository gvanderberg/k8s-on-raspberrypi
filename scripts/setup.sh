#!/bin/bash

curl -sSL get.docker.com | sh && \ 
    usermod pi -aG docker
