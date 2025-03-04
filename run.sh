#!/bin/bash

###########################################
# Ethereum Client Benchmark Runner Script #
###########################################

# Print error message and exit
error_exit() {
    echo "ERROR: $1" >&2
    exit 1
}

# Validate directory existence
validate_directory() {
    local dir="$1"
    local dir_name="$2"
    if [ ! -d "$dir" ]; then
        error_exit "$dir_name directory '$dir' does not exist"
    fi
}

# Clean up docker resources for a client
cleanup_client() {
    local client="$1"
    cd "scripts/$client" || error_exit "Failed to change to client directory"
    docker compose down
    sudo rm -rf execution-data
    cd ../.. || error_exit "Failed to return to root directory"
}

# Default configuration
readonly DEFAULT_TEST_PATH="tests/"
readonly DEFAULT_WARMUP_FILE="warmup/warmup-100bl-16wi-32tx.txt"
readonly DEFAULT_CLIENTS="nethermind,geth,reth"
readonly DEFAULT_RUNS=8
readonly DEFAULT_IMAGES="default"
readonly DEFAULT_OUTPUT_DIR="results"

# Initialize variables with defaults
test_path="$DEFAULT_TEST_PATH"
warmup_file="$DEFAULT_WARMUP_FILE"
clients="$DEFAULT_CLIENTS"
runs="$DEFAULT_RUNS"
images="$DEFAULT_IMAGES"
output_dir="$DEFAULT_OUTPUT_DIR"

# Parse command line arguments
while getopts "t:w:c:r:i:o:" opt; do
    case $opt in
        t) test_path="$OPTARG" ;;
        w) warmup_file="$OPTARG" ;;
        c) clients="$OPTARG" ;;
        r) runs="$OPTARG" ;;
        i) images="$OPTARG" ;;
        o) output_dir="$OPTARG" ;;
        *) echo "Usage: $0 [-t test_path] [-w warmup_file] [-c clients] [-r runs] [-i images] [-o output_dir]" >&2
           exit 1 ;;
    esac
done

# Split comma-separated inputs into arrays
IFS=',' read -ra client_list <<< "$clients"
IFS=',' read -ra image_list <<< "$images"

echo "=== Configuration ==="
echo "Test Path: $test_path"
echo "Warmup File: $warmup_file"
echo "Clients: $clients"
echo "Runs: $runs"
echo "Images: $images"
echo "Output Directory: $output_dir"
echo "===================="

# Validate inputs
validate_directory "$test_path" "Test"
[ -f "$warmup_file" ] || echo "Warning: Warmup file '$warmup_file' not found, will run without warmup"

# Create output directory
mkdir -p "$output_dir" || error_exit "Failed to create output directory"

# Install dependencies
echo "=== Installing Dependencies ==="
pip install  -q -r requirements.txt || error_exit "Failed to install Python dependencies"
make prepare_tools || error_exit "Failed to prepare tools"

# Run benchmarks
echo "=== Starting Benchmark Runs ==="
for run in $(seq 1 "$runs"); do
    echo "Starting Run $run of $runs"
    
    for i in "${!client_list[@]}"; do
        client="${client_list[$i]}"
        image="${image_list[$i]}"
        
        echo "Processing client: $client"
        
        # Setup node
        if [ -z "$image" ]; then
            echo "Using default image for $client"
            python3 setup_node.py --client "$client" || error_exit "Failed to setup node for $client"
        else
            echo "Using custom image for $client: $image"
            python3 setup_node.py --client "$client" --image "$image" || error_exit "Failed to setup node for $client"
        fi
        
        # Run benchmark
        if [ -z "$warmup_file" ]; then
            echo "Running benchmark without warmup"
            python3 run_kute.py --output "$output_dir" --testsPath "$test_path" \
                              --jwtPath /tmp/jwtsecret --client "$client" --run "$run" || \
                error_exit "Benchmark failed for $client (run $run)"
        else
            echo "Running benchmark with warmup file: $warmup_file"
            python3 run_kute.py --output "$output_dir" --testsPath "$test_path" \
                              --jwtPath /tmp/jwtsecret --warmupPath "$warmup_file" \
                              --client "$client" --run "$run" || \
                error_exit "Benchmark failed for $client (run $run)"
        fi
        
        # Cleanup
        cleanup_client "$client"
    done
done

# Generate reports
echo "=== Generating Reports ==="
readonly REPORT_CLIENTS="nethermind,geth,reth,erigon,besu"
readonly REPORT_TYPES=("tables" "html" "json")

for report_type in "${REPORT_TYPES[@]}"; do
    echo "Generating $report_type report..."
    python3 "report_${report_type}.py" --resultsPath "$output_dir" \
                                      --clients "$REPORT_CLIENTS" \
                                      --testsPath "$test_path" \
                                      --runs "$runs" || \
        error_exit "Failed to generate $report_type report"
done

# Archive results
echo "=== Archiving Results ==="
zip -r "${output_dir}.zip" "$output_dir" || error_exit "Failed to archive results"

echo "=== Benchmark Complete ==="
echo "Results are available in ${output_dir}.zip"
