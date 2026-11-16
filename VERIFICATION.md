# v5 製作端驗證與接收者驗收界線（2026-11-16）

## v5範圍
- 既有固定映像、獨立profile／volume、非root／loopback Gateway及ownership保護保留。不是另一次安裝OpenClaw平台，也不升級接收者現有volume。
- 新增總機／專案分身方法、4個角色範本、3個純文件skills、只建HELD的專案骨架、完整包診斷、Windows本機路徑檢查、互動token入口及踩坑說明。
- 檔案完整性及敏感內容依allowlist與SHA256SUMS逐檔核對；不包含原作者OAuth／客戶資料／私人social-post聲線／個人Notion筆記。

## 不能從測試推論的事
- PowerShell是在Linux的官方runtime做AST與mock，不等於Windows 5.1／Docker Desktop或macOS實機驗收。
- 匿名假資料／離線圖解／角色範本／HELD骨架不證明原生專案agent已隔離；專案sandbox、mount、scope與路由另驗。
- 製作端不登入接收者Codex、不呼叫其模型、不展示／收集其token。控制台連線及真人AI回覆要本人完成。
- 既有接收者截圖只證明OAuth complete、Gateway health與控制台驗證頁等各自狀態；沒有把最後真人回覆標成已完成。
- 各入口檢查、重入保留、profile／scope拒絕、診斷／token路由及離線圖解的本輪結果，以交付訊息與本案製作紀錄為準，不把過去通過項目冒充本次新增實機測試。

## 本人完成判準
1. Docker READY；2. 本profile config有效；3. 自己OAuth完成；4. Gateway health通過；5. 本機控制台完成憑證與必要配對並取得真實AI回覆。渠道與業務API另驗。

以下保留原版驗證歷史，日期不代表v5新增實機證據。

---

# 製作端驗證｜2026-11-13

## v2：Windows先決條件修正
- 接收者截圖顯示Windows無法解析docker指令；後續表示開始選單找不到Docker Desktop。可確認尚未進入龍蝦安裝，不能僅憑截圖區分未安裝／PATH／WSL差異。
- 新增Docker Desktop官方線上安裝入口、架構選擇、下載簽章／發行者檢查，以及只讀CHECK入口。Windows啟動器先找CLI，再分辨Compose缺少、引擎無法連線、Windows containers及Linux ready。
- 16項PowerShell分支測試通過（Linux上的官方PowerShell 7.7.0）：PATH與已知位置、沒有修改PATH、無CLI不呼叫引擎、各先決條件分類、x64／ARM64選擇、無簽章與錯誤發行者拒絕等。這些使用mock，**不是Windows實機或真實Docker Desktop安裝驗收**。
- 修正版PowerShell來源以UTF-8 BOM／CRLF封裝，避免Windows PowerShell 5.1誤讀中文。語法檢查仍由PowerShell 7進行，不宣稱已在5.1真機測試。
- v2未變更Compose、Gateway初始化、OAuth或主機設定；原先Linux Docker驗證維持既有證據，未重跑未變動的容器鏈。官方Docker Desktop exe只在接收者自行執行0入口時下載／核驗，不包含於ZIP，也未在製作端下載或啟動Windows安裝程式。

## 已驗證
- 初始化程式8項自動測試全過：自己的profile／隨機token、重跑保留修改、不觸碰預設profile、拒絕未知既有profile、symlink保護、不同使用者不同token、移除繼承的provider秘密與profile環境、拓撲不符不覆蓋。
- Node程式語法與Bash／Mac command語法檢查通過。
- 官方OpenClaw 2026.10.7 schema驗證通過；獨立暫存profile的原生Gateway health成功，未安裝主機常駐服務。
- Compose包含gateway／init的設定解析通過，檢查本機loopback發布、非root Gateway、無Docker socket。
- 官方固定映像manifest可取得，提供amd64及arm64；在**Linux arm64 Docker Engine**以實際Compose建立暫存volume／容器、初始化、schema驗證、重跑不改config／token、Gateway health成功。
- Docker獨立檢查確認執行uid/gid 1000、本機loopback發布、不含Docker socket、僅自己的volume。暫存測試容器／network／volume已清除。
- 製作端原Gateway設定雜湊及容器啟動時間未變；未重啟原服務。

## 尚未驗證／不隨包交付
- 沒有在接收者的Windows／Mac實機執行；PowerShell／bat未做真實Windows執行驗證。
- 沒有登入接收者的Codex，也未借用原作者的憑證做模型推論。本人OAuth、實際模型回覆、帳號模型可用性、Dashboard裝置核准仍需在接收者端完成。
- Docker Desktop／WSL2、x86電腦、Mac M系列與平台權限以接收者實際條件為準。manifest支援不等於所有硬體已實測。
- Discord／LINE／Notion／n8n與各專案子沙盒沒有啟用；只有規則及未套用範本。
- 原生模式的自動service安裝未在三平台實機驗證。Docker模式不在主機安裝OpenClaw或Node。

## 無秘密包檢查
最終分享ZIP以明確檔案類型白名單建立；重新開啟逐檔掃描憑證模式、原owner／原環境識別字串，以及與製作端配置中秘密值的完整比對。通過才交付；不含.env、OAuth、session、log、備份、私有驗證證據或客戶資料。各檔雜湊見SHA256SUMS.txt。

這份報告不代表接收者已部署完成。請按START-HERE／DOCKER-README做本人環境的最後驗收。
