#!/usr/bin/env bash
# job_efficiency.sh - CPU and memory efficiency for completed jobs
# Usage: job_efficiency.sh [--user USER] [--days N] [--jobs JOB_IDS]

USER="$(whoami)"
DAYS=7
JOBS=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --user)  USER="$2";  shift 2 ;;
        --days)  DAYS="$2";  shift 2 ;;
        --jobs)  JOBS="$2";  shift 2 ;;
        *)       echo "Unknown option: $1"; exit 1 ;;
    esac
done

START_DATE=$(date -d "$DAYS days ago" '+%Y-%m-%d' 2>/dev/null || date -v"-${DAYS}d" '+%Y-%m-%d')

echo ""
echo "  JOB EFFICIENCY REPORT"
echo "  User: $USER  |  Last $DAYS days (since $START_DATE)"
echo "  ----------------------------------------------------------------"

if [[ -n "$JOBS" ]]; then
    SACCT_ARGS="-j $JOBS"
else
    SACCT_ARGS="-u $USER --starttime=$START_DATE"
fi

printf "  %-10s %-14s %-9s %-12s %-8s %-10s %-10s %-10s\n" \
       "JobID" "Name" "Partition" "State" "ExitCode" "Elapsed" "CPUTime" "MaxRSS"
echo "  ----------------------------------------------------------------"

sacct $SACCT_ARGS \
      --format="JobID%10,JobName%14,Partition%9,State%12,ExitCode%8,Elapsed%10,CPUTime%10,MaxRSS%10" \
      --noheader \
    | grep -v '\.batch\|\.extern' \
    | while IFS= read -r line; do
        echo "  $line"
      done

echo ""
echo "  NOTE: CPUTime = Elapsed x AllocCPUs. Compare with TotalCPU to"
echo "        spot jobs that over-requested cores (CPUTime >> TotalCPU)."
echo ""
