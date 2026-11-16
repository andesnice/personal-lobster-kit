# 個人龍蝦｜三平台獨立部署包

這是一份全新的可分享起點：保留通用助理個性、工作規則、進度回報與記憶／交接範本，**不含原作者的金鑰、登入、私人記憶、聊天、客戶資料或排程**。

## 已有Docker？優先看這裡

Windows、Mac、Linux共用本包根目錄的同一份 `compose.yaml`。**Windows＋Docker第一次安裝請雙擊 `3-DOCKER-INSTALL.bat`；已安裝後只用 `4-DOCKER-START.bat`，不必重跑INSTALL、改裝Linux或跑下面的原生安裝器。**

**Windows尚未安裝Docker Desktop時，先執行 `1-INSTALL-DOCKER-DESKTOP.bat`。** 它會從Docker官方網站下載符合CPU架構的安裝程式，檢查有效的Docker Inc數位簽章後開啟官方安裝介面；不是ZIP內附完整exe，也不是無人值守安裝。請自己完成權限／授權／系統提示，必要時重開機，再開啟Docker Desktop並等引擎就緒。

接著雙擊 `2-DOCKER-CHECK.bat`；顯示READY後再執行3-DOCKER-INSTALL安裝龍蝦。CHECK只讀取先決條件，不下載映像、不建立或修改容器。找不到CLI、不具備Compose、引擎未啟動及Windows-container模式會分別顯示說明。

- Windows：先啟動Docker Desktop的Linux容器模式（通常WSL2），雙擊 `3-DOCKER-INSTALL.bat`；日後用 `4-DOCKER-START.bat`。
- Mac：先啟動Docker Desktop，雙擊 `macos/DOCKER-INSTALL.command`；無執行權限時用 `bash macos/DOCKER-INSTALL.command`。
- Linux／VPS：先備妥Docker Engine與Compose v2或以上，執行 `bash linux/docker-install.sh`。

完整Docker說明見 `DOCKER-README.md`。它會用**新的專屬named volume**部署；不是自動覆蓋接收者現有的OpenClaw。若想沿用既有容器，先照該說明的「已有龍蝦」段由本人的Codex核對與合併，不能直接覆蓋。

以下三平台INSTALL（不含DOCKER字樣）是**不用Docker時的原生備用入口**；二選一，不要兩套同時佔用19789。

第一次安裝需要網路，OpenClaw／Node由官方安裝器下載；不是離線完整程式映像。Codex請登入你自己的ChatGPT／Codex帳號。已有Codex CLI登入不代表本OpenClaw profile已登入，仍要完成一次自己的OAuth。安裝包不含任何付費API備援。

## Windows：雙擊批次檔

1. 解壓整包到自己可寫入的資料夾；不要只拿出一個bat。
2. 雙擊 `9a-NATIVE-INSTALL.bat`。
3. 如缺少OpenClaw，官方安裝器會處理安裝／相依性；依畫面完成必要的Windows安裝提示。
4. 終端顯示裝置登入網址與代碼時，用自己的帳號授權。不要把代碼貼到群組。
5. 服務健康檢查通過後，畫面顯示本機Dashboard網址；在瀏覽器開啟。

之後啟動：雙擊 `9b-NATIVE-START.bat`。
其他動作（在終端執行）：
```bat
9b-NATIVE-START.bat dashboard
9b-NATIVE-START.bat channels
9b-NATIVE-START.bat doctor
9b-NATIVE-START.bat models
9b-NATIVE-START.bat serve
9b-NATIVE-START.bat stop
```
若受公司政策限制PowerShell或安裝套件，請在允許安裝的個人電腦執行；不要關閉全機安全策略。bat僅為此次子程序指定ExecutionPolicy，不改全機設定。

## Mac：雙擊command

1. 解壓完整資料夾。
2. 雙擊 `macos/INSTALL.command`，按照裝置登入提示登入自己的Codex。
3. 如解壓程式沒有保留執行權限，改在終端進入解壓資料夾後執行：
```bash
bash macos/INSTALL.command
```
4. 之後雙擊 `macos/START.command`。

其他動作：
```bash
bash macos/START.command dashboard
bash macos/START.command channels
bash macos/START.command doctor
bash macos/START.command serve
bash macos/START.command stop
```
macOS若要求允許官方套件或開啟下載的腳本，依本機政策個別確認，不要全域關閉Gatekeeper。

## Linux／VPS：一條安裝指令

先解壓並進入完整資料夾，用預計執行助理的普通使用者執行（不要整支sudo）：
```bash
bash linux/install.sh
```
依官方安裝器完成相依性，再用終端顯示的裝置代碼登入自己的帳號。

正常啟動／管理：
```bash
bash linux/start.sh
bash linux/start.sh dashboard
bash linux/start.sh channels
bash linux/start.sh doctor
bash linux/start.sh serve
bash linux/start.sh stop
```
Linux有可用的systemd user session時會安裝該profile的服務；沒有時**不冒充常駐部署成功**，改用 `bash linux/start.sh serve` 前景執行並保持視窗開啟。若需要登出後持續運作，再由本機管理者依官方Linux文件建立適當服務；安裝包不擅自更改登入／系統級服務政策。

VPS的Dashboard只聽127.0.0.1，不開公網。從自己的電腦另開終端：
```bash
ssh -N -L 19789:127.0.0.1:19789 your-user@your-server
```
再打開部署終端顯示的本機Dashboard網址。若你改了settings.json的port，轉發與瀏覽器連接埠也要一起改。包內不替你設定網域、HTTPS、路由器或防火牆。

## 共同設定與行為

- Profile：`personal-lobster`；狀態／登入／設定在 `~/.openclaw-personal-lobster/`（Windows為使用者家目錄下同名資料夾）。
- 工作區：該資料夾內的 `workspace/`。不讀取或複製預設 `~/.openclaw`。
- 連接埠：19789。與預設18789分開；若已有其他額外實例，首次安裝前改 `settings.json` 的profile和port。額外實例基礎port至少錯開120，衍生瀏覽器port也須檢查。
- Gateway token每次全新安裝在**接收者本機隨機產生**，不顯示於安裝包。Windows檔案權限繼承使用者資料夾ACL；不要裝進共用公開資料夾。
- 重跑不覆蓋現有設定、人格、筆記或token；遇到不認識的既有profile會停止。**不使用reset或force，不殺其他連接埠的程序。**
- 預設模型為 `openai/gpt-6.1-sol`，未設其他供應商備援。實際可用性以自己的Codex帳號為準；可用上面的models動作查看。需要更換時請自己的Codex協助使用該profile的官方模型設定，不修改別的profile。
- 初始不連Discord／LINE／Notion／n8n。用channels動作開官方設定，輸入**你自己的**Bot／帳號資料。Notion等工具另按需要設定；不要拿原作者的憑證。
- 初始沒有多助手、業務流程、定時提醒、模型heartbeat或語意索引。檔案記憶／關鍵字查找可用；背景任務如需AI仍可能消耗自己的額度。
- 這是named profile與資料分開，**不是Docker或OS層的強制沙盒**。檔案工具限工作區，shell採人工ask；不要把它當成不可信多租戶隔離。安裝器本身會安裝軟體／建立本使用者profile服務，缺少相依套件時可能出現系統安裝權限提示。
- 已有可用OpenClaw時重用，不自動升降級；缺少時下載官方當下提供的版本。若版本不支援此schema／命令，會停下來，不回寫別的profile；先請自己的Codex依錯誤核對相容性。

## 檔案內容

`openclaw.template.json`是無金鑰的配置範本；`shared/deploy.mjs`負責只建立自己的profile；三平台入口共用它。`workspace/`含SOUL、IDENTITY、空白USER／MEMORY、AGENTS與專案交接範本。`CODEX_SETUP.md`可直接交給自己的Codex協助安裝。

若已安裝之後要分享給下一個人，只分享本原始壓縮包。不要把本機 `.openclaw-personal-lobster` 打包出去，裡面會有**你自己的**登入與聊天資料。

## 驗收

1. config validate通過。
2. 自己的Codex登入完成，models可列出預期模型。
3. 本profile Gateway health通過。
4. Dashboard真人發一句「你好，請說明你的工作區與權限」，確認實際模型能回覆。
5. 如接Discord／LINE，再另驗本人、非本人與群組觸發規則；Gateway健康不代表這些渠道已通。

本包製作時的檢查與限制見 `VERIFICATION.md`。Windows／Mac無實機驗證，不宣稱三平台皆已上機部署。

## 官方來源

- 安裝與相依性：https://docs.openclaw.ai/install
- 官方安裝器：https://docs.openclaw.ai/install/installer
- 獨立profile／服務：https://docs.openclaw.ai/gateway/multiple-gateways
- OpenClaw Codex登入：https://docs.openclaw.ai/providers/openai/setup
- OpenAI官方登入說明：https://learn.chatgpt.com/docs/auth?surface=cli

## v5 先看哪裡
- 新手Windows：README-FIRST.txt。D槽／網路磁碟、裝置碼／控制台token、PowerShell及PID問題：KNOWN-ISSUES.md。
- 架構及分身方法：ARCHITECTURE.md／ARCHITECTURE.html；角色、3個通用skills及待驗專案骨架已收錄，但初始仍只有main。
- 控制台需要密鑰：Windows雙擊5-DOCKER-TOKEN.bat；Mac／Linux用Docker START入口加token，僅在自己的互動終端顯示既有token。
- 舊版升級：UPGRADE-EXISTING.md；根目錄CHECK-SAFE.bat是去敏診斷，不是修復／重裝工具。
