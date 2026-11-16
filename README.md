# 個人龍蝦安裝包（OpenClaw）v5.1

## 這是什麼
一包可以**在自己電腦上架起一隻獨立 AI 助理（龍蝦）**的安裝腳本，底層是 [OpenClaw](https://docs.openclaw.ai)，用你自己的 ChatGPT／Codex 帳號當大腦。

它會幫你做的事：
- 建立一個獨立的 OpenClaw 環境（Docker 版用專屬 volume，不碰你現有的 OpenClaw）
- 放入通用的助理個性、工作規則、記憶與交接範本、專案進度範本
- 提供角色範本（總部、專案、排程、審查）與 3 個通用方法技能；初始只有一個 agent（main）

它**不含**：任何人的金鑰、登入、私人記憶、聊天紀錄、客戶資料或排程。初始也**不連** Discord／LINE／Notion／n8n，要用再自己設定。

這是安裝腳本，不是單一 exe，也不是離線安裝光碟；第一次安裝需要網路。

## 事前準備
- 自己的 ChatGPT／Codex 帳號（安裝時用裝置碼登入，不要把代碼貼到群組）
- Docker Desktop（Windows／Mac）或 Docker Engine + Compose v2（Linux）。Windows 沒有的話，步驟 1 會協助取得官方安裝程式
- 一個本機可寫入的資料夾；不要放網路磁碟，也不要在 ZIP 裡直接執行

## 取得
點 GitHub 頁面右上 **Code → Download ZIP**，**完整解壓縮**到本機，例如 `D:\OpenClaw\personal-lobster`。

## 安裝順序

### Windows + Docker（推薦）
在解壓資料夾**最上層**，依數字由小到大雙擊：

| 順序 | 檔案 | 什麼時候跑 |
|---|---|---|
| 1 | `1-INSTALL-DOCKER-DESKTOP.bat` | 只有還沒裝 Docker Desktop 才跑；自己完成安裝、重開機與首次設定。已有就跳過 |
| 2 | `2-DOCKER-CHECK.bat` | 先開啟 Docker Desktop，再跑這個，等畫面顯示 **READY**。只檢查，不安裝 |
| 3 | `3-DOCKER-INSTALL.bat` | **第一次**安裝龍蝦；依終端機網址在瀏覽器輸入當次裝置碼登入 Codex。只跑一次 |
| 4 | `4-DOCKER-START.bat` | 日後**每次啟動**都用這個，不要重跑 3，也不要刪 volume |
| 5 | `5-DOCKER-TOKEN.bat` | 只有控制台要求 Gateway 密鑰時才跑；密鑰只貼進自己本機網頁，不貼聊天 |
| 9a／9b | `9a-NATIVE-INSTALL.bat`、`9b-NATIVE-START.bat` | 不用 Docker 的備用方案，與 Docker 版二選一，不要同時使用 |

`windows/` 資料夾裡是內部腳本，不用點。

### Mac + Docker
先開 Docker Desktop → 第一次：`macos/DOCKER-INSTALL.command`（沒有執行權限就 `bash macos/DOCKER-INSTALL.command`）→ 日後：`macos/DOCKER-START.command`。

### Linux／VPS + Docker
`bash linux/docker-install.sh`（第一次）→ 日後 `bash linux/docker-start.sh`。控制台只聽 127.0.0.1，遠端請用 SSH 轉發：`ssh -N -L 19789:127.0.0.1:19789 user@server`。

## 裝完怎麼驗收
1. 終端機顯示 health passed
2. 同一台電腦開終端機顯示的本機控制台網址（預設連接埠 19789）
3. 在控制台送一句「你好」，**拿到真實的 AI 回覆**才算完成。health 通過不等於對話通過

## 日常使用
- 啟動：Windows `4-DOCKER-START.bat`；Mac `macos/DOCKER-START.command`；Linux `bash linux/docker-start.sh`
- 在 START 後面加動作：`dashboard`（開控制台）、`channels`（設定 Discord／LINE 等，填**自己的** Bot）、`doctor`、`models`、`logs`、`stop`
- 想建立專案分身：看 `ARCHITECTURE.md`；專案骨架預設是「待驗」狀態，不會自動啟用

## 卡住時
- 先看 `KNOWN-ISSUES.md`（D 槽／網路磁碟、裝置碼與控制台密鑰、PowerShell、PID 等常見問題）
- `CHECK-SAFE.bat` 是去敏診斷，只讀取狀態，不修復也不重裝
- 已經裝過舊版：看 `UPGRADE-EXISTING.md`，不要重新部署，不覆蓋自己的登入、USER、MEMORY

## 重要提醒
- 這是獨立 profile／volume，**不是 OS 層的強制沙盒**，不要當成不可信的多人隔離環境
- 預設模型是 `openai/gpt-6.1-sol`，不含付費 API 備援，實際可用性看你自己的 Codex 帳號
- 已做離線／模擬檢查與隔離 Docker 驗證；**Windows／Mac 實機、接收者自己的 OAuth 登入與真人對話仍需你本人驗收**（見 `VERIFICATION.md`）
- 若要再分享給別人，只分享這份原始包，不要打包你本機的 `.openclaw-personal-lobster`（裡面有你自己的登入與對話）

## 文件導覽
`README-FIRST.txt` 新手最短流程 · `START-HERE.md` 三平台完整說明 · `DOCKER-README.md` Docker 細節 · `ARCHITECTURE.md／.html` 架構與分身方法 · `CODEX_SETUP.md` 交給自己的 Codex 協助安裝 · `KNOWN-ISSUES.md` 踩坑 · `UPGRADE-EXISTING.md` 舊版升級 · `VERIFICATION.md` 驗證範圍

## 授權
尚未指定授權；預設保留著作權。
