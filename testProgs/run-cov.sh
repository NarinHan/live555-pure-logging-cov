#!/bin/bash

# Arguments
test_dir=$1          # Path to replayable-queue directory
port=$2              # Port number for the server
output_file=$3       # Path to the output CSV file

# Ensure required arguments are provided
if [ "$#" -ne 3 ]; then
    echo "Usage: $0 <test_dir> <port> <output_file>"
    exit 1
fi

# Initialize output file
echo "TestCase,Time,l_per,l_abs,b_per,b_abs" > "$output_file"

# Clear previous coverage data
gcovr -r .. -s -d > /dev/null 2>&1

# Iterate over all test cases in the directory
for testcase in "$test_dir"/*; do
    # Get timestamp of the test case
    time=$(stat -c %Y "$testcase")

    # Terminate any running servers
    pkill testOnDemandRTSPServer > /dev/null 2>&1

    # Replay the test case
    aflnet-replay "$testcase" RTSP "$port" 1 > /dev/null 2>&1 &
    
    # Run the server for 3 seconds
    timeout -k 0 -s SIGUSR1 3s ./testOnDemandRTSPServer "$port" > /dev/null 2>&1

    # Wait for the server to complete
    wait

    # Collect coverage data
    cov_data=$(gcovr -r .. -s | grep "[lb][a-z]*:")
    l_per=$(echo "$cov_data" | grep lines | cut -d" " -f2 | rev | cut -c2- | rev)
    l_abs=$(echo "$cov_data" | grep lines | cut -d" " -f3 | cut -c2-)
    b_per=$(echo "$cov_data" | grep branch | cut -d" " -f2 | rev | cut -c2- | rev)
    b_abs=$(echo "$cov_data" | grep branch | cut -d" " -f3 | cut -c2-)

    # Append results to the output file
    echo "$(basename "$testcase"),$time,$l_per,$l_abs,$b_per,$b_abs" >> "$output_file"
done

