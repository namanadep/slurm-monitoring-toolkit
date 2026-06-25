#!/usr/bin/env bash
# queue_analysis.sh - break down the job queue by state, partition, and user

echo ""
echo "  QUEUE ANALYSIS  $(date '+%H:%M:%S')"
echo "  ----------------------------------------------------------------"

TOTAL=$(squeue --noheader | wc -l)
echo ""
echo "  BY STATE"
if [[ "$TOTAL" -gt 0 ]]; then
    squeue --format="%T" --noheader \
        | sort | uniq -c | sort -rn \
        | awk '{printf "    %-8s  %s\n", $2, $1}'
else
    echo "    (queue is empty)"
fi

echo ""
echo "  BY PARTITION"
if [[ "$TOTAL" -gt 0 ]]; then
    squeue --format="%P" --noheader \
        | sort | uniq -c | sort -rn \
        | awk '{printf "    %-12s  %s jobs\n", $2, $1}'
else
    echo "    (queue is empty)"
fi

echo ""
echo "  BY USER (top 10)"
if [[ "$TOTAL" -gt 0 ]]; then
    squeue --format="%u" --noheader \
        | sort | uniq -c | sort -rn | head -10 \
        | awk '{printf "    %-16s  %s jobs\n", $2, $1}'
else
    echo "    (queue is empty)"
fi

echo ""
echo "  LONGEST RUNNING JOBS"
RUNNING=$(squeue -t R --noheader | wc -l)
if [[ "$RUNNING" -gt 0 ]]; then
    squeue -t R --sort=-M --format="%8i %14j %10u %9P %10M" | head -6 | awk '{print "  "$0}'
else
    echo "    (no running jobs)"
fi

echo ""
echo "  LONGEST WAITING (pending)"
PENDING=$(squeue -t PD --noheader | wc -l)
if [[ "$PENDING" -gt 0 ]]; then
    squeue -t PD --sort=S --format="%8i %14j %10u %9P %10M %R" | head -6 | awk '{print "  "$0}'
else
    echo "    (no pending jobs)"
fi

echo ""
echo "  Total jobs in queue: $TOTAL"
echo ""
