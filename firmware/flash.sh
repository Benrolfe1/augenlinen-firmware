#!/bin/bash
set -e
PORT="${1:-/dev/cu.usbmodem*}"
if [[ "$PORT" == *"*"* ]]; then
    ACTUAL_PORT=$(ls $PORT 2>/dev/null | head -1)
    if [ -z "$ACTUAL_PORT" ]; then
        echo "No USB device found."
        echo "Usage: ./flash.sh /dev/cu.usbmodemXXXX"
        exit 1
    fi
    PORT="$ACTUAL_PORT"
fi
echo "=== FLASH AugenLinien v1.1.0 ==="
echo "Port: $PORT"
command -v esptool.py &>/dev/null || pip3 install esptool
echo "Erasing flash..."
esptool.py --chip esp32c3 --port "$PORT" erase_flash
echo "Flashing v1.1.0..."
esptool.py --chip esp32c3 --port "$PORT" --baud 921600 \
    --before default_reset --after hard_reset write_flash \
    -z --flash_mode dio --flash_freq 80m --flash_size 4MB \
    0x0 bootloader.bin 0x8000 partitions.bin 0xe000 boot_app0.bin 0x10000 firmware.bin
echo "Done! Device will boot with v1.1.0"
