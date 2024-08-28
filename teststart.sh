


#!/bin/bash

./run.sh \
  -t "testburnt/" \
  -w "./testburntwarm/warm.txt" \
  -c "reth" \
  -r 1 \
  -o "results" 

./run.sh \
  -t "testburnt/" \
  -w "./testburntwarm/warm.txt" \
  -c "nethermind" \
  -r 1 \
  -o "results" 

./run.sh \
  -t "testburnt/" \
  -w "./testburntwarm/warm.txt" \
  -c "erigon" \
  -r 1 \
  -o "results" 

python3 report_tables.py --resultsPath results --clients reth --testsPath testburnt --runs 1
python3 report_tables.py --resultsPath results --clients nethermind --testsPath testburnt --runs 1
python3 report_tables.py --resultsPath results --clients erigon --testsPath testburnt --runs 1
python3 report_tables.py --resultsPath results --clients erigon,besu,nethermind,geth,reth --testsPath testburnt --runs 2


python3 setup_node.py --client erigon

./nethermind/tools/Nethermind.Tools.Kute/bin/Release/net8.0/Nethermind.Tools.Kute -i testburnt/Burnt/Burnt_90M.txt -s /tmp/jwtsecret -r results/erigon_90.txt
./nethermind/tools/Nethermind.Tools.Kute/bin/Release/net8.0/Nethermind.Tools.Kute -i testburnt/Burnt/Burnt_94M.txt -s /tmp/jwtsecret -r results/erigon_94.txt
./nethermind/tools/Nethermind.Tools.Kute/bin/Release/net8.0/Nethermind.Tools.Kute -i testburnt/Burnt/Burnt_113M.txt -s /tmp/jwtsecret -r results/erigon_113.txt
./nethermind/tools/Nethermind.Tools.Kute/bin/Release/net8.0/Nethermind.Tools.Kute -i testburnt/Burnt/Burnt_265M.txt -s /tmp/jwtsecret -r results/erigon_265.txt
./nethermind/tools/Nethermind.Tools.Kute/bin/Release/net8.0/Nethermind.Tools.Kute -i testburnt/Burnt/Burnt_409M.txt -s /tmp/jwtsecret -r results/erigon_409.txt
./nethermind/tools/Nethermind.Tools.Kute/bin/Release/net8.0/Nethermind.Tools.Kute -i testburnt/Burnt/Burnt_968M.txt -s /tmp/jwtsecret -r results/erigon_968.txt

