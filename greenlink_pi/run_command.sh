#!/bin/bash

cd /home/greenlink/greenlink
source /home/greenlink/greenlink/.venv/bin/activate

python3 command_worker.py >> /home/greenlink/greenlink/command.log 2>&1
