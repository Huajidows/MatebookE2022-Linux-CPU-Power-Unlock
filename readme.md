此项目用于对华为Matebook E 2022二合一笔记本刷入Linux后 CPU功耗异常锁死的情况进行解锁。
通过对EC寄存器0x45地址写入0x01 解开ec底层CPU功耗限制 解除后即可使用throttled或者其他软件设置PL1/PL2功耗

> [!NOTE]
> **Windows 环境说明**：在 Windows 下无需操作，可能华为相关驱动已进行类似操作，此方案仅针对 Linux 系统。

## 测试环境与效果

- **设备**：DRC-WXX (16GB+512GB)
- **CPU**：i5-1130G7
- **内核版本**：Linux 6.1.0
- **BIOS版本**：1.35
- **操作系统**：Ubuntu 24.04 LTS
- **CPU调度器**：intel-pstate
- **效果**：最高持续工作 PKG 功耗可达 20W，与 Windows 解锁后表现一致。
- **兼容性**：理论上可以应用于任何 Linux 发行版，只需要有写入 EC 寄存器的权限即可。

## 风险提醒

- **硬件损坏风险**：修改 EC 寄存器及解除功耗限制可能导致设备发热严重，长期高温可能损坏 CPU、主板或其他元器件。
- **电池寿命衰减**：更高的功耗会加速电池老化。
- **系统不稳定性**：脚本会持续向 EC 写入数据，在极少数情况下可能引起内核或系统崩溃。
- **免责声明**：本项目仅供学习与交流使用，作者不对使用此脚本造成的任何直接或间接损失负责。请在充分了解风险的前提下使用！

## 使用方法（注册为守护进程持续执行）

由于 EC 可能会在休眠唤醒或特定条件下重置该寄存器，建议将脚本配置为 systemd 守护进程持续运行。

### 1. 放置脚本并赋予执行权限

将 `huawei_ec_unlock.sh` 放到合适的目录（例如 `/usr/local/bin/`），并赋予执行权限：

```bash
sudo cp huawei_ec_unlock.sh /usr/local/bin/
sudo chmod +x /usr/local/bin/huawei_ec_unlock.sh
```

### 2. 创建 systemd 服务文件

使用文本编辑器创建服务文件：

```bash
sudo nano /etc/systemd/system/huawei-ec-unlock.service
```

填入以下内容：

```ini
[Unit]
Description=Huawei Matebook E 2022 EC Power Unlock Daemon
After=multi-user.target suspend.target hibernate.target

[Service]
Type=simple
ExecStart=/usr/local/bin/huawei_ec_unlock.sh
Restart=always
RestartSec=3
User=root

[Install]
WantedBy=multi-user.target suspend.target hibernate.target
```

### 3. 启动并设置开机自启

重新加载 systemd 配置，启用并启动该服务：

```bash
sudo systemctl daemon-reload
sudo systemctl enable huawei-ec-unlock.service
sudo systemctl start huawei-ec-unlock.service
```

### 4. 检查运行状态

可以通过以下命令检查服务是否正常运行：

```bash
sudo systemctl status huawei-ec-unlock.service
```

完成后 EC寄存器就会被持续覆写，解除CPU功耗限制。