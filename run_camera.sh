#!/bin/bash

cd /home/greenlink/greenlink
source /home/greenlink/greenlink/.venv/bin/activate

python3 camera_main.py >> /home/greenlink/greenlink/camera.log 2>&1

