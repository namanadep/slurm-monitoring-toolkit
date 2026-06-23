#!/usr/bin/env bash
# job_history.sh — compact history of recent jobs with state summary
# Usage: job_history.sh [--user USER] [--days N]

USER="$(whoami)"
DAYS=7

while [[ $# -gt 0 ]]; do
    case "$1" in
        --user)  USER="$2";  shift 2 ;;
        --days)  DAYS="$2";  shift 2 ;;
        *)       echo "Unknown option: $1"; exit 1 ;;
    esac
done

START=$(date -d "$DAYS days ago" '+%Y-%m-%dT%H:%M' 2>/dev/null \
       || date -v"-${DAYS}d" '+%Y-%m-%dT%H:%M')

echo ""
echo "  JOB HISTORY  user=$USER  last=$DAYS days  (since $START)"
echo "  ----------------------------------------------------------------"
printf "  %-10s %-14s %-9s %-12s %-6s %-10s %-10s\n" \
       "JobID" "Name" "Partition" "State" "Exit" "Elapsed" "MaxRSS"
echo "  ----------------------------------------------------------------"

sacct -u "$USER" --starttime="$START" \
      --format="JobID%10,JobName%14,Partition%9,State%12,ExitCode%6,Elapsed%10,MaxRSS%10" \
      --noheader \
    | grep -v '\.batch\|\.extern' \
    | while IFS= read -r line; do
        echo "  $line"
      done

echo ""

# Count by state
TOTAL=$(sacct -u "$USER" --starttime="$START" --noheader \
        | grep -v '\.batch\|\.extern' | wc -l)
COMPLETED=$(sacct -u "$USER" --starttime="$START" --noheader \
            | grep -v '\.batch\|\.extern' | awk '$4 ~ /COMPLETED/ {c++} END{print c+0}')
FAILED=$(sacct -u "$USER" --starttime="$START" --noheader \
         | grep -v '\.batch\|\.extern' | awk '$4 ~ /FAILED/ {c++} END{print c+0}')
CANCELLED=$(sacct -u "$USER" --starttime="$START" --noheader \
            | grep -v '\.batch\|\.extern' | awk '$4 ~ /CANCELLED/ {c++} END{print c+0}')

echo "  Summary: $TOTAL jobs | $COMPLETED COMPLETED | $FAILED FAILED | $CANCELLED CANCELLED"
echo ""
