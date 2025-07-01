#!/bin/bash

# Ensure we're in the kernel source root directory
if [ ! -f "Makefile" ] || [ ! -f "scripts/config" ]; then
  echo "Run this script from the root of the Linux kernel source tree."
  exit 1
fi

# Example: List of ARM-relevant config options to toggle
ARM_CONFIGS=(
  CONFIG_ARM
  CONFIG_ARM_THUMB
  CONFIG_ARM_THUMBEE
  CONFIG_ARM_UNWIND
  CONFIG_ARM_PMU
  CONFIG_ARM_APPENDED_DTB
  CONFIG_ARM_ATAG_DTB_COMPAT
  CONFIG_ARM_CPU_TOPOLOGY
  CONFIG_ARM_LPAE
  CONFIG_ARM_SMMU
  CONFIG_ARM_AMBA
  CONFIG_ARM_GIC
  CONFIG_ARCH_SUNXI              # Allwinner SoC family (adds lots of board files)
  CONFIG_ARCH_MXC                # i.MX (NXP/Freescale)
  CONFIG_ARCH_OMAP2PLUS          # Texas Instruments OMAP2/3/4/5
  CONFIG_ARCH_S3C64XX            # Samsung S3C (older ARM9 SoCs)
  CONFIG_ARCH_VEXPRESS           # Versatile Express platform (ARM reference boards)
  CONFIG_ARCH_EXYNOS             # Samsung Exynos family (pulls in clocks, DRM, PM)
  CONFIG_ARCH_ZYNQ               # Xilinx Zynq (FPGA + ARM)
)

# Mode: enable, disable, module
MODE=${1:-enable}  # Default to enable

# Validate mode
if [[ "$MODE" != "enable" && "$MODE" != "disable" && "$MODE" != "module" ]]; then
  echo "Usage: $0 [enable|disable|module]"
  exit 1
fi

echo "Applying '$MODE' to ARM-related config options..."

for CONFIG in "${ARM_CONFIGS[@]}"; do
  echo " - $CONFIG"
  scripts/config --$MODE "$CONFIG"
done

echo "Done."
