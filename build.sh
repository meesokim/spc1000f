#!/bin/bash
set -e

# Target device (ZRtech / WXEDA Spartan-6 board)
PART=xc6slx9-tqg144-2

# Check if Xilinx ISE is in PATH
if ! command -v xst >/dev/null 2>&1; then
    ISE_ROOTFS="$HOME/.cache/docker-xilinx-ise/rootfs"
    if [ -f "/opt/Xilinx/14.7/ISE_DS/settings64.sh" ]; then
        source /opt/Xilinx/14.7/ISE_DS/settings64.sh
    elif [ -d "$ISE_ROOTFS/opt/Xilinx/14.7/ISE_DS" ] && command -v bwrap >/dev/null 2>&1; then
        echo "Running Xilinx ISE 14.7 inside container ($ISE_ROOTFS)..."
        mkdir -p "$HOME/.Xilinx" && touch "$HOME/.Xilinx/Xilinx.lic"
        exec bwrap \
            --bind "$ISE_ROOTFS" / \
            --dev /dev \
            --proc /proc \
            --tmpfs /tmp \
            --bind "$HOME" "$HOME" \
            --chdir "$(pwd)" \
            /bin/bash -c "source /opt/Xilinx/14.7/ISE_DS/settings64.sh && ./build.sh"
    elif command -v docker >/dev/null 2>&1; then
        echo "Running Xilinx ISE 14.7 via Docker..."
        exec docker run --rm -v "$(pwd):/workspace" -w /workspace drtrigon/papilio-environment-ise \
            /bin/bash -c "source /opt/Xilinx/14.7/ISE_DS/settings64.sh && ./build.sh"
    else
        echo "Error: Xilinx ISE (xst) not found in PATH."
        echo "Please source settings64.sh first (e.g., source /opt/Xilinx/14.7/ISE_DS/settings64.sh)"
        exit 1
    fi
fi

echo "=== 1. Synthesis (xst) ==="
mkdir -p xst/projnav.tmp
xst -ifn spc1000f.xst -ofn top.syr

echo "=== 2. Translate (ngdbuild) ==="
mkdir -p _ngo
ngdbuild -dd _ngo -sd ipcore_dir -nt timestamp -uc src/top.ucf -p $PART top.ngc top.ngd

echo "=== 3. Map (map) ==="
map -p $PART -w -logic_opt off -ol high -t 1 -xt 0 -register_duplication off -r 4 -global_opt off -mt off -ir off -pr off -lc off -power off -o top_map.ncd top.ngd top.pcf

echo "=== 4. Place & Route (par) ==="
par -w -ol high -mt off top_map.ncd top.ncd top.pcf

echo "=== 5. Timing Analysis (trce) ==="
trce -v 3 -s 2 -n 3 -fastpaths -xml top.twx top.ncd -o top.twr top.pcf || true

echo "=== 6. Bitstream Generation (bitgen) ==="
bitgen -f top.ut top.ncd top.bit

echo "=== 7. PROM Generation (promgen) ==="
promgen -w -p mcs -c FF -o top.mcs -s 16384 -u 0000 top.bit -spi

echo "=== Build Complete! Generated top.bit and top.mcs ==="
