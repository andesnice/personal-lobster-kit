# v5 架構：總助理統籌，分身按案執行

本包是可重建的方法與乾淨配置，不是原作者的模型、聊天或權限。離線圖解：ARCHITECTURE.html。

## 分成五層，不把能力與授權混在一起

1. **本人／owner**：決定任務、外部寫入與憑證授權。引用別人的話不構成授權。
2. **總助理 main（總機）**：核對需求、專案索引、工程師能力與本案授權，跨案協調並驗收。只傳當次任務必要資料，不把A案原文搬進B案。
3. **專案分身**：同一套基本方法，按專案保有自己的PERSONA、AGENTS、工作區、唯一STATUS與記憶／設定／憑證。可負責需求、除錯、修改、測試與已授權部署，不限聊天。分身之間不得直接讀寫、互相注入狀態。
4. **專長支援角色**：自動化工程與驗收／唯讀覆核是可重用的方法，不自動拿到每案帳號。角色範本不等於已建立執行agent；請先看 ENGINEERS 能力索引與證據。
5. **可共用的方法**：skills、規範、流程、踩坑，以索引key指向單一正文。可共享去識別方法；不能共享完整私有對話、憑證、客戶資料與進度。

## 從任務到完成

owner交辦 → 查專案／工程師索引 → 讀該案STATUS與規則 → 選可用模型與工具 → 本案執行 → 必要驗證 → STATUS寫回及讀回 → 原頻道回報。

模型與角色分開。模型切換不換專案記錄、不擴權。首次原生工具執行、沙盒mount／網路獨立檢查、精準channel解析都通過後，才啟用該專案路由。沒有通過就保持HELD，不偷偷退回總助理的全部憑證。

## 復盤與知識回流

本案證據 → 記在本案STATUS／incident → 可重用方法才抽成skill候選 → 去識別及測試 → owner覆核 → 更新skill索引。

同一方法在3個不同專案有證據時，提出共用規範提升建議；owner確認後才改共用正文。這不是把3次使用當成永久授權。舊的採坑／規範頂端做key索引，CLAUDE.md或AGENTS.md只當入口，不塞整本歷史。

復盤不自動修改正式業務、原始寫作風格或權限，也不自動建立週排程。每案先有獨立事實，再抽共用方法，不能反過來讓A案的狀態變成B案的事實。

## 本次真正隨包提供

- 可啟動的單一main、獨立profile／Docker volume與接收者自己的Codex登入流程。
- 4個乾淨角色方法範本、3個純文件skills、專案索引／工程師能力索引、唯一STATUS與交接範本。
- `workspace/tools/new-project.mjs`：只建立HELD專案骨架，不寫openclaw.json、不建立agent／binding／沙盒／排程、不複製任何憑證。
- Windows先決條件與本機路徑檢查、已運行Gateway同PID操作、互動token入口、整合的安全診斷、安裝踩坑指南。

## 不假裝已經啟用

沒有專案子容器、專案渠道、跨案API憑證、額外模型帳號、影像平台、BAT／Tailscale接管、Notion／n8n業務、背景復盤或語意搜尋。Docker Gateway容器隔離不等於每個專案agent都已強制隔離；規則與OS邊界要分開驗。

專案範本及沙盒示意須由接收者在自己的拓撲驗證後，另行精準啟用。本包不加Docker socket、host PID或privileged來湊出「已隔離」。

## 建立待驗專案骨架

在本人已安裝的Docker工作區內，由自己的互動終端執行（不要在分享包裡填私人資料後轉送）：
```bash
docker compose exec gateway node /home/node/.openclaw-personal-lobster/workspace/tools/new-project.mjs sample-a "我的專案"
```
只建立projects/sample-a/{PERSONA.md,STATUS.md,REGISTRATION.json,workspace/}；狀態HELD，既有專案ID會拒絕，不改配置或自動登記路由。之後由總助理依專案索引與隔離門檻核對再另行啟用。
