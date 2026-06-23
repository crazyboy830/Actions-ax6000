# Redmi AX6000 ImmortalWrt 自动编译

本仓库用于构建 `hanwckf/immortalwrt-mt798x` 的 Redmi AX6000 固件（`openwrt-21.02` 分支）。

## 当前构建方案

- 编译入口：单 `diy.sh`（`pre|feeds|post` 三阶段）
- CI 工作流：单 `.github/workflows/openwrt-builder.yml`
- PassWall2：使用官方 feed（`passwall2 + passwall_packages`），并采用 `Xray` 内核
- 默认管理地址：`192.168.31.1`
- 网络优化：保留 `BBR`（`kmod-sched-core + kmod-tcp-bbr`）

## 已移除的软件

- `mosdns`
- `openlist`
- `tailscale`

上述软件在 `.config` 中已关闭。

## 固件产物

Release 默认上传：

- `*factory.bin`
- `*sysupgrade.bin`
- `*initramfs-kernel.bin`

## 文档

当前仓库未保留独立刷机文档，刷机与升级建议以 Release 说明和工作流产物命名为准。
