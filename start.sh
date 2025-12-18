


#!/bin/bash

nohup \
  ./run.sh \
  -t "tests/" \
  -w "warmup/warmup-1000bl-16wi-24tx.txt" \
  -c "nethermind,geth,reth,erigon,besu,ethrex" \
  -r 8 \
  -o "results" \
  > output.log 2>&1 &

