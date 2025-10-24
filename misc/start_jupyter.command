#!/bin/bash

# Step 1 — Start Jupyter remotely and write output to a local log
osascript -e 'tell application "Terminal" to do script "
cd ~/Desktop/Exeter;
ssh -i nb770.pem ubuntu@10.121.4.67 -t \"bash -i -c '\''conda activate hds_code && jupyter lab --no-browser --port=4569'\''\" | tee ~/Desktop/Exeter/jupyter_output.log"'

# Step 2 — Wait for Jupyter to start and detect which port it chose
echo "Waiting for Jupyter to choose its port..."
LOGFILE=~/Desktop/Exeter/jupyter_output.log
PORT=""
TOKEN_URL=""

for i in {1..60}; do
    if [ -f "$LOGFILE" ]; then
        # extract first port and token URL printed by Jupyter
        PORT=$(grep -m1 -Eo 'localhost:[0-9]+' "$LOGFILE" | cut -d: -f2)
        TOKEN_URL=$(grep -m1 -Eo 'http://(localhost|127\.0\.0\.1):[0-9]+/lab\?token=[a-z0-9]+' "$LOGFILE")
        if [[ -n "$PORT" && "$TOKEN_URL" == *token=* ]]; then
            break
        fi
    fi
    sleep 1
done

if [ -z "$PORT" ]; then
    PORT=4569
    echo "⚠️  Could not detect port automatically — defaulting to $PORT"
else
    echo "✅ Detected Jupyter port: $PORT"
fi

# Step 3 — Open a new terminal tab with matching SSH tunnel
osascript -e "tell application \"Terminal\" to do script \"
cd ~/Desktop/Exeter;
ssh -i nb770.pem -CNL localhost:${PORT}:localhost:${PORT} ubuntu@10.121.4.67\""

# Step 4 — Wait until the tunnel port is listening, then open browser
echo "Waiting for SSH tunnel..."
for i in {1..30}; do
    nc -z localhost $PORT >/dev/null 2>&1 && break
    sleep 1
done

if [[ "$TOKEN_URL" == *token=* ]]; then
    echo "🌐 Opening $TOKEN_URL"
    open "$TOKEN_URL"
else
    echo "⚠️  Could not find token URL automatically — copy from Jupyter terminal."
fi


# Step 5 — Clean up: delete the local log file
if [ -f "$LOGFILE" ]; then
    rm "$LOGFILE"
    echo "🧹 Deleted temporary log file."
fi