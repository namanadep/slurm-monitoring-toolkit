#!/usr/bin/env bash
# cluster_status.sh - concise cluster-wide overview combining sinfo + squeue

DIVIDER="----------------------------------------------------------------"

echo ""
echo "  CLUSTER STATUS  $(date '+%a %b %d %H:%M:%S %Z %Y')"
echo "  $DIVIDER"

echo ""
echo "  PARTITIONS"
sinfo --format="%10P %6a %11l %6D %8T %N" | awk 'NR==1{print "  "$0} NR>1{print "  "$0}'

echo ""
echo "  $DIVIDER"
echo ""
echo "  NODE DETAIL"
sinfo --Node --format="%8N %10P %5c %8m %8e %6t %G" | awk '{print "  "$0}'

echo ""
echo "  $DIVIDER"
echo ""
echo "  JOBS IN QUEUE"
COUNT=$(squeue | tail -n +2 | wc -l)
if [[ "$COUNT" -eq 0 ]]; then
    echo "  (no jobs queued)"
else
    squeue --format="%8i %14j %10u %2t %10M %6D %R" | awk '{print "  "$0}'
fi

echo ""
echo "  $DIVIDER"
echo ""
echo "  QUICK STATS"
RUNNING=$(squeue -t R  2>/dev/null | tail -n +2 | wc -l)
PENDING=$(squeue -t PD 2>/dev/null | tail -n +2 | wc -l)
echo "  Running : $RUNNING"
echo "  Pending : $PENDING"
echo "  Total   : $((RUNNING + PENDING))"
echo ""
