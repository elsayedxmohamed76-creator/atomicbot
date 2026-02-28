#!/data/data/com.termux/files/usr/bin/bash
# AtomicBot OAuth Sync Widget
# Syncs Claude Code tokens to AtomicBot on l36 server
# Place in ~/.shortcuts/ on phone for Termux:Widget

termux-toast "Syncing AtomicBot auth..."

# Run sync on l36 server
SERVER="${ATOMICBOT_SERVER:-${ATOMICBOT_SERVER:-l36}}"
RESULT=$(ssh "$SERVER" '/home/admin/atomicbot/scripts/sync-claude-code-auth.sh' 2>&1)
EXIT_CODE=$?

if [ $EXIT_CODE -eq 0 ]; then
    # Extract expiry time from output
    EXPIRY=$(echo "$RESULT" | grep "Token expires:" | cut -d: -f2-)

    termux-vibrate -d 100
    termux-toast "AtomicBot synced! Expires:${EXPIRY}"

    # Optional: restart atomicbot service
    ssh "$SERVER" 'systemctl --user restart atomicbot' 2>/dev/null
else
    termux-vibrate -d 300
    termux-toast "Sync failed: ${RESULT}"
fi
