# 安裝踩坑入口（v5）

完整單一正文：[workspace/standards/安裝踩坑.md](workspace/standards/安裝踩坑.md)。此正文會隨新工作區安裝，讓助理也能查同一份指南；本檔只做索引，避免人與AI各自維護不同答案。

- WIN-DOCKER：找不到docker、PATH、Compose／Linux引擎、WSL／BIOS。
- WIN-PATH：網路分享／映射磁碟、可放本機D槽，但不會自動搬Docker磁碟。
- AUTH-DEVICE：裝置碼在官方瀏覽器頁面輸入，不是在終端點格子。
- PS-LABEL：引號造成template function io及ownership誤判。
- STATE-PID：共用volume不同PID namespace，運行中改同容器exec。
- RESUME：誤按INSTALL只resume，不pull／init／重登。
- UI-TOKEN：OAuth完成／health通過但網頁缺Gateway token，使用本人互動token入口。
- ACCEPT：Docker／profile／OAuth／health／控制台真人回覆分層驗收。

Windows新手先讀README-FIRST.txt；舊安裝先讀UPGRADE-EXISTING.md。根目錄CHECK-SAFE.bat只做去敏診斷，不會重裝、登入或修復。
