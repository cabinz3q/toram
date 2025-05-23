#!/system/bin/sh

BASE_DIR="/sdcard/Documents/toram"
TMP_DIR="/data/local/tmp"

# Create directories if they don't exist
su -c "mkdir -p $BASE_DIR $TMP_DIR"

PID_FILE="$BASE_DIR/bypass_toram_pid.log"
# Check for existing PID and kill if exists
if [ -f "$PID_FILE" ]; then
    OLD_PID=$(su -c "cat $PID_FILE")
    if [ -n "$OLD_PID" ]; then
        su -c "kill -9 $OLD_PID" 2>/dev/null
    fi
    su -c "rm -f $PID_FILE"
fi

# Save current PID
echo $$ | su -c "tee $PID_FILE"

# Find Toram Online app path (unchanged as it's system path)
APP_PATH=$(su -c "find /data/app -type d -name \"com.asobimo.toramonline-*\" | head -1")

# Backup existing library if it exists
su -c "mv $APP_PATH/lib/arm64/libil2cpp.so $BASE_DIR/libil2cpp.so"

# Copy base.apk
#su -c "cp -f $APP_PATH/base.apk $TMP_DIR/base.apk"

# Function to check if app is running
is_app_running() {
    APP_RUNNING=$(su -c "dumpsys activity processes | grep com.asobimo.toramonline" 2>/dev/null)
    [ -n "$APP_RUNNING" ]
}

# Main monitoring loop
while true; do
    if ! is_app_running; then
        
        # Reinstall original apk if it exists
    
        #su -c "chmod 755 $TMP_DIR/base.apk"
        #su -c "pm install -r $TMP_DIR/base.apk"
        #su -c "rm -f $TMP_DIR/base.apk"
        su -c mv $BASE_DIR/libil2cpp.so $APP_PATH/lib/arm64/libil2cpp.so
        su -c chmod 755 $APP_PATH/lib/arm64/libil2cpp.so
        su -c "rm -f $TMP_DIR/bypassT.sh"
        
        # Clean up PID file
        su -c "rm $BASE_DIR"
        
        exit 0
    fi
    
    # Sleep for 5 seconds before checking again
    sleep 5
done
