---
name: root-cause-debugging
description: 流程或安裝失敗、代理回報無法操作時使用；先辨認第一個失敗邊界，不用猜測同時改多處。
---

# root-cause-debugging

讀`../../standards/工作與交接.md`；服務整合另讀`../../standards/GAS_n8n_Notion_跨專案作業規範.md`。先保留確切錯誤和前後條件，分開工具缺少／scope拒絕／網路／配額／程式問題，再以單一假設做最小驗證；驗證後才在既有授權內修復。安裝問題讀`../../standards/安裝踩坑.md`及`../../standards/踩坑索引.md`。不要清鎖、刪資料或換runtime繞過拒絕。

完成條件：本案來源及scope已核對、必要證據已記錄、正本已讀回，且未越過該案授權。
