#!/bin/bash
###############################################################################
# start_jupyter.command
#
# *** FOR MAC OS USERS ONLY ***
#
# PURPOSE:
#   Automate launching a remote JupyterLab server over SSH and opening it
#   securely in your local browser with a matching SSH tunnel and token.
#
# WHAT IT DOES:
#   1. Opens a new Terminal tab that SSHs into a remote Linux server and starts
#      JupyterLab within a specified Conda environment (e.g. hds_code).
#   2. Duplicates Jupyter’s startup output to a local log file so the script
#      can detect the chosen port (which may vary each run) and the unique
#      tokenised access URL.
#   3. Automatically opens a second Terminal tab that sets up an SSH port
#      forwarding tunnel from localhost:<port> on the Mac to the same port on
#      the remote host.
#   4. Waits until both the tunnel and the Jupyter token URL are ready, then
#      launches the exact authenticated URL in the user’s default web browser.
#   5. Deletes the temporary local log file when done.
#
# TYPICAL USAGE:
#   • Place this file on your Mac (e.g. ~/Desktop/Exeter/start_jupyter.command)
#   • Make it executable:
#         chmod +x ~/Desktop/Exeter/start_jupyter.command
#   • Double-click the file in Finder (macOS will open Terminal and run it).
#   • The script will start Jupyter on the remote server and open your browser
#     directly to the correct lab interface — no manual token copying required.
#
# REQUIREMENTS:
#   • macOS with Terminal and `osascript` (default on all Macs)
#   • SSH key access to the remote host (update `nb770.pem` path and IP)
#   • JupyterLab installed in the target Conda environment on the server
#   • `grep`, `nc` (netcat), and `open` commands available locally (default)
#
# TO ADAPT FOR OTHER USERS:
#   • Replace:
#         ubuntu@10.121.4.67     → your remote username@host
#         nb770.pem              → path to your own SSH key
#         hds_code               → name of your remote Conda environment
#         ~/Desktop/Exeter/      → your preferred local working folder
#
# SECURITY:
#   The SSH tunnel ensures that Jupyter is only accessible through your local
#   machine. No token or notebook data is exposed to the public internet.
#
# AUTHOR:
#   Nick Berry, 2025 - github.com/nyberry
###############################################################################


# === USER CONFIGURATION =====================================================
LOCAL_DIR=~/Desktop/Exeter            # Local working folder
SSH_KEY="$LOCAL_DIR/nb770.pem"        # Path to SSH private key
REMOTE_HOST="ubuntu@10.121.4.67"      # Remote username@host
CONDA_ENV="hds_code"                  # Remote Conda environment
BASE_PORT=4569                        # Preferred starting port
###############################################################################

# Step 1 — Start Jupyter remotely and write output to a local log
osascript -e "tell application \"Terminal\" to do script \"
cd $LOCAL_DIR;
ssh -i $SSH_KEY $REMOTE_HOST -t \\\"bash -i -c 'conda activate \
$CONDA_ENV && jupyter lab --no-browser --port=$BASE_PORT'\\\" | \
tee $LOCAL_DIR/jupyter_output.log\""

# Step 2 — Wait for Jupyter to start and detect which port it chose
echo \"Waiting for Jupyter to choose its port...\"
LOGFILE=$LOCAL_DIR/jupyter_output.log
PORT=\"\"
TOKEN_URL=\"\"

for i in {1..60}; do
    if [ -f \"$LOGFILE\" ]; then
        PORT=$(grep -m1 -Eo 'localhost:[0-9]+' \"$LOGFILE\" | \
            cut -d: -f2)
        TOKEN_URL=$(grep -m1 -Eo \
            'http://(localhost|127\.0\.0\.1):[0-9]+/lab\?token=[a-z0-9]+' \
            \"$LOGFILE\")
        if [[ -n \"$PORT\" && \"$TOKEN_URL\" == *token=* ]]; then
            break
        fi
    fi
    sleep 1
done

if [ -z \"$PORT\" ]; then
    PORT=$BASE_PORT
    echo \"⚠️  Could not detect port automatically — defaulting to $PORT\"
else
    echo \"✅ Detected Jupyter port: $PORT\"
fi

# Step 3 — Open a new terminal tab with matching SSH tunnel
osascript -e "tell application \"Terminal\" to do script \"
cd $LOCAL_DIR;
ssh -i $SSH_KEY -CNL localhost:${PORT}:localhost:${PORT} \
$REMOTE_HOST\""

# Step 4 — Wait until the tunnel port is listening, then open browser
echo \"Waiting for SSH tunnel...\"
for i in {1..30}; do
    nc -z localhost $PORT >/dev/null 2>&1 && break
    sleep 1
done

if [[ \"$TOKEN_URL\" == *token=* ]]; then
    echo \"🌐 Opening $TOKEN_URL\"
    open \"$TOKEN_URL\"
else
    echo \"⚠️  Could not find token URL automatically — copy from \
Jupyter terminal.\"
fi

# Step 5 — Clean up: delete the local log file
if [ -f \"$LOGFILE\" ]; then
    rm \"$LOGFILE\"
    echo \"🧹 Deleted temporary log file.\"
fi
