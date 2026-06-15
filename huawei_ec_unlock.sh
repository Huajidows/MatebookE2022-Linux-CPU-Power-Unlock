#!/bin/bash
# 确保脚本拥有绝对的 Root 执行上下文

# 1. 开机初次强制加载模块并解除写保护
modprobe ec_sys write_support=1

while true; do
    if [ -e /sys/kernel/debug/ec/ec0/io ]; then
        # 节点存在，直接直写 0x45 地址为 0x01
        echo -n -e "\x01" | dd of=/sys/kernel/debug/ec/ec0/io bs=1 seek=$((0x45)) count=1 conv=notrunc 2>/dev/null
    else
        # 如果发现节点意外消失（如休眠唤醒后），立刻重新加载模块
        modprobe ec_sys write_support=1
    fi
    
    # 每 0.5s 覆写EC寄存器
    sleep 0.5
done
