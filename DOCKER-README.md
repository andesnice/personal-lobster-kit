# Docker版｜Windows／Mac／Linux共用

## 你這次應該用哪個

第一次建立這份獨立龍蝦時用 `3-DOCKER-INSTALL.bat`；已完成安裝後，日常只用 `4-DOCKER-START.bat`。不需要另外在Windows主機裝Node或OpenClaw；它們都在官方Linux映像裡。

## Windows先決條件（v2補充）

**3-DOCKER-INSTALL是安裝龍蝦，不是安裝Docker Desktop。ZIP沒有內附Docker Desktop完整exe。**

尚未安裝時依序：
1. `1-INSTALL-DOCKER-DESKTOP.bat`：官方線上安裝入口。下載amd64／arm64對應安裝器，驗證Authenticode狀態與Docker Inc發行者後開啟介面。簽章無法確認則停止，不執行下載的檔案。
2. 由本人完成安裝畫面的權限、系統需求及授權提示；若要求重新開機先完成。從開始選單開啟Docker Desktop，完成首次設定並等待啟動。
3. `2-DOCKER-CHECK.bat`：只檢查Windows Docker CLI／Compose／Linux引擎；READY後才往下。
4. `3-DOCKER-INSTALL.bat`：現在才安裝龍蝦，並登入自己的Codex。

已安裝者不用重裝：新版會找PATH、新的使用者／系統PATH、Docker Desktop官方常見安裝目錄及登錄的安裝位置。只讀檢查，不永久改PATH。若只有WSL內有Docker，可直接在**那個WSL內**進入解壓資料夾執行 `bash linux/docker-install.sh`，不是從Windows視窗猜它能找到WSL的指令。

`0-...`不是離線Docker分發包，不會替你接受條款、啟用WSL／BIOS／虛擬化、關閉防火牆或自動重開機。官方安裝程式很大，需要網路；下載暫存位置會在本機顯示，完成後可自行刪掉。

三平台共用同一Compose與工作區規則，只有操作入口不同：
- Windows：`3-DOCKER-INSTALL.bat`。
- Mac：`macos/DOCKER-INSTALL.command`；必要時以bash執行。
- Linux：`bash linux/docker-install.sh`。

執行前先啟動Docker Desktop／Docker Engine，Windows必須是Linux containers。映像已確認提供amd64與arm64；實際相容性仍需在接收者電腦驗收。

## 安裝會做什麼

1. 檢查Docker與Compose，拒絕接手同Compose project中不是本包建立的容器。
2. 拉取官方固定版本 `ghcr.io/openclaw/openclaw:2026.10.7`，不使用朋友的私人映像。
3. 在新named volume內初始化main、自己的workspace及新隨機Gateway token。初始化容器以root處理**這一個volume**的擁有者，完成後Gateway用uid/gid 1000執行；不掛主機家目錄或Docker socket。
4. 用你自己的帳號完成官方Codex裝置代碼登入。這一步必須由本人授權，不可預先打包別人的OAuth。
5. 啟動Gateway、檢查health，在本機終端顯示Dashboard登入網址。
6. 由本人在Dashboard發第一句測試，確認真實模型回覆。沒有這一步，不宣稱AI對話已驗收。

第一次開Dashboard若顯示需要device pairing，在另一個自己的終端查看待核准裝置：
```bash
docker compose exec gateway node /app/openclaw.mjs --profile personal-lobster devices list
```
確認確實是自己的瀏覽器後，再依其request ID執行 `devices approve <request-id>`（保留前面的同一Compose／node／profile前綴）。不要用關閉device auth或允許所有Origins來跳過。

## 日後常用動作

Windows（終端進入解壓目錄）：
```bat
4-DOCKER-START.bat
4-DOCKER-START.bat dashboard
4-DOCKER-START.bat channels
4-DOCKER-START.bat doctor
4-DOCKER-START.bat models
4-DOCKER-START.bat logs
4-DOCKER-START.bat stop
```
Mac對應 `bash macos/DOCKER-START.command <動作>`。
Linux對應 `bash linux/docker-start.sh <動作>`。

也可在根目錄直接用Compose：
```bash
docker compose ps
docker compose logs --tail 80 gateway
docker compose stop gateway
docker compose up -d gateway
```
stop／重建容器保留volume。**不要執行down -v或刪除volume**，否則自己的登入、記憶與對話會遺失。

## 資料與網路

- 預設Compose project名 `personal-lobster`，資料volume `personal-lobster_lobster-state`。
- 容器內profile：`/home/node/.openclaw-personal-lobster`；工作區為其內 `workspace`。
- Gateway容器內需要bind=lan，才能讓Docker的port forwarding進來；主機只發布 `127.0.0.1:19789`，**不是開放公網**。
- 自己的設定與登入留在volume，不在此分享資料夾。從未把原作者的實際設定或憑證複製進來。
- 初始只有main，沒有每案子沙盒、渠道、其他助手或業務憑證。規則與未啟用範本見 `workspace/standards/專案隔離與權限.md`。
- 本容器自己的volume有實際邊界，但不是保證抵禦所有不可信程式的安全產品；不要為了方便再掛主機根目錄、SSH或Docker socket。

## 主機連接埠或project名稱衝突

首次安裝前，可把 `.env.example` 複製成 `.env`，只改：
```dotenv
COMPOSE_PROJECT_NAME=my-personal-lobster
LOBSTER_HOST_PORT=20789
OPENCLAW_IMAGE=ghcr.io/openclaw/openclaw:2026.10.7
```
不覆蓋已存在的.env，不在其中放原作者的秘密。Docker內的profile及19789固定，不改settings.json；`LOBSTER_HOST_PORT`只改主機端。

若主機port改為20789，Dashboard命令印出的網址內如仍是容器19789，將網址的port換成20789即可，保留其登入資訊在本機，不轉貼聊天。首次完成之後再改port，需明確更新自己的allowedOrigins，初始化器不會擅自覆蓋。

VPS使用SSH轉發，沿用START-HERE中的方法；不用為了瀏覽Dashboard就把服務綁0.0.0.0。

## 已有自己的龍蝦：不要直接整份覆蓋

這份安裝器建立新實例，**不自動遷移既有Docker資料**。

如果接收者要把規則整合到現有龍蝦，把本包 `CODEX_SETUP.md` 與 `workspace/` 給她自己的Codex：
1. 請它先查現有Compose、volume、工作區與版本，備份。
2. 先比較規則；保留她原有名字、USER、記憶、身份、渠道與登入。
3. 只合併她確認採用的通用段落，不以新USER／MEMORY空範本覆蓋舊檔。
4. 動到現有配置時先官方dry-run，再讀回；不要因為多了一份分享包就重新開白名單或改模型。

若她原有Codex的AGENTS／skills／專案文件要交給龍蝦分析，先挑選相關檔案，排除auth與聊天秘密，再使用明確白名單的唯讀掛載。給資料夾不代表模型會自動完整讀完、更新或持續同步；需交代盤點／差異／採用範圍。不搬整個 `~/.codex`。

## 驗證層級與來源

見 `VERIFICATION.md`；未代登入她的帳號，也沒有在她的Windows實機跑過。Docker Desktop／WSL2安裝需要本機條件，包內不更改BIOS、WSL、主機防火牆或全機安全設定。

- https://docs.openclaw.ai/install/docker
- https://docs.docker.com/desktop/setup/install/windows-install/


## 已運行 Gateway 的操作
- Gateway運行中，設定／模型／登入／診斷命令必須透過 `docker compose exec` 在同一容器內執行。另開 `compose run` 即使共用資料卷也有不同PID namespace，會被ownership保護拒絕；這不等於資料庫損毀。
- 本版入口會先查運行狀態；若誤按INSTALL但Gateway已運行，只檢查health並列出控制台網址，不pull、不初始化、不重新登入。START也不重新建立已運行容器。
- 不刪鎖檔、不強制清SQLite、不使用host PID namespace或停掉其他服務來繞過保護。若上次Gateway剛停止而owner heartbeat仍新，遵循錯誤中的等待時間，不強制搶占。

## v5 本機路徑與控制台
Windows入口會在Compose之前拒絕UNC／映射網路分享；把整包移到本機C或D槽，不移動既有volume。解壓資料夾在D不等於Docker磁碟也在D，詳見KNOWN-ISSUES.md。

若health通過但控制台需要Gateway密鑰，執行5-DOCKER-TOKEN.bat；或在原compose.yaml同層互動終端執行：
```bash
docker compose exec gateway node /app/openclaw.mjs --profile personal-lobster gateway auth-token --show
```
不要加-T、不要擷取到log、不要貼聊天；只貼自己的本機網頁。這不重生token、不重登OAuth，Gateway需先運行。此入口的路由／TTY有測試，收件者真實瀏覽器與AI仍另驗。
