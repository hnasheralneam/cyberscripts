#!/usr/bin/env bash

# Simple remote SSH script runner
# Usage: remotessh.sh --user USER --host HOST --script local_script.sh [--password PASS] [--port PORT] [--out outfile]

set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 --user USER --host HOST --script SCRIPTFILE [--password PASS] [--port PORT] [--out OUTFILE]

Runs a local script on a remote host by piping it to the remote shell over ssh
and saves stdout+stderr to an output logfile.

Options:
  --user USER       Remote SSH user
  --host HOST       Remote host (IP or hostname)
  --script FILE     Local script file to run remotely
  --password PASS   Optional password (uses sshpass or expect if provided)
  --port PORT       Optional SSH port (default 22)
  --out OUTFILE     Optional output file (default: remotessh-<host>-<timestamp>.log)
  -h, --help        Show this help
EOF
  exit 1
}

USER=""
HOST=""
SCRIPTFILE=""
PASSWORD=""
PORT=22
OUTFILE=""

while [[ ${#@} -gt 0 ]]; do
  case "$1" in
    --user) USER="$2"; shift 2;;
    --host) HOST="$2"; shift 2;;
    --script) SCRIPTFILE="$2"; shift 2;;
    --password) PASSWORD="$2"; shift 2;;
    --port) PORT="$2"; shift 2;;
    --out) OUTFILE="$2"; shift 2;;
    -h|--help) usage;;
    *) echo "Unknown option: $1"; usage;;
  esac
done

if [ -z "$USER" ] || [ -z "$HOST" ] || [ -z "$SCRIPTFILE" ]; then
  echo "Missing required parameters." >&2
  usage
fi

if [ ! -f "$SCRIPTFILE" ]; then
  echo "Local script not found: $SCRIPTFILE" >&2
  exit 2
fi

if [ -z "$OUTFILE" ]; then
  TS=$(date +%Y%m%d_%H%M%S)
  OUTFILE="remotessh-${HOST}-${TS}.log"
fi

run_ssh_direct() {
  ssh -p "$PORT" -o StrictHostKeyChecking=no "${USER}@${HOST}" 'bash -s' < "$SCRIPTFILE" > "$OUTFILE" 2>&1
}

run_with_sshpass() {
  sshpass -p "$PASSWORD" ssh -p "$PORT" -o StrictHostKeyChecking=no "${USER}@${HOST}" 'bash -s' < "$SCRIPTFILE" > "$OUTFILE" 2>&1
}

run_with_expect() {
  # Use an inline expect script to provide password if sshpass not available
  expect <<'EXPECT'
  set timeout -1
  spawn ssh -p $env(PORT) -o StrictHostKeyChecking=no $env(USER)@$env(HOST) bash -s
  match_max 100000
  expect {
    -re ".*assword:.*" { send -- "$env(PASSWORD)\r"; exp_continue }
    eof
  }
  # pipe local script to spawned ssh
EXPECT
}

echo "Running $SCRIPTFILE on ${USER}@${HOST} (port $PORT)"

if [ -n "$PASSWORD" ]; then
  if command -v sshpass >/dev/null 2>&1; then
    echo "Using sshpass to supply password (if available)"
    run_with_sshpass
  elif command -v expect >/dev/null 2>&1; then
    echo "sshpass not found; using expect to supply password"
    # We'll pipe the script into expect->ssh and capture output
    # Build a small wrapper that uses expect and pipes the local script
    /usr/bin/env expect -c \
"set timeout -1; spawn ssh -p $PORT -o StrictHostKeyChecking=no $USER@$HOST bash -s;\nexpect -re \\".*assword:.*\\" { send \"$PASSWORD\\r\"; exp_continue }\nset fd [open \"$SCRIPTFILE\" r]; while {![eof $fd]} {puts -nonewline [read $fd 4096]; flush stdout}; close $fd; interact" > "$OUTFILE" 2>&1
  else
    echo "Password provided but neither sshpass nor expect are installed. Install sshpass or use key-based auth." >&2
    exit 3
  fi
else
  run_ssh_direct
fi

RET=$?
if [ $RET -eq 0 ]; then
  echo "Remote execution finished successfully. Output saved to: $OUTFILE"
else
  echo "Remote execution exited with code $RET. See: $OUTFILE" >&2
fi

exit $RET
