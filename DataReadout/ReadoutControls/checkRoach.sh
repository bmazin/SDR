#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Usage: $0 roachNum"
    exit 1
fi
ROACH=$1

check_status()
{
    status=$?
    if [ $status -ne 0 ]; then
        echo ""
        echo "ERROR"
        exit $status
    fi
    return 0
}

ssh root@10.0.0.1$ROACH "tail ~/PulseServer/logs/ps.log"
