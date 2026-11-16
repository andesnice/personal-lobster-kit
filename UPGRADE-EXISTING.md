# 已安裝舊版：只合併，不重新部署

## 先保留現況

備份原解壓資料夾，保留原.env、Compose project名稱、port與Docker volume。新ZIP先解壓到另一個本機資料夾比對；**不是把新空白workspace蓋到已使用的volume**。請勿down -v、重生token或重跑OAuth。

## 啟動器／診斷修正

1. 備份原解壓資料夾後，可把新版`windows/`與`docker/run.sh`同名檔案合併到原安裝資料夾；同時放入新版根目錄`CHECK-SAFE.bat`、`CHECK-SAFE.ps1`與`check-state.cjs`。保留原.env、compose.yaml、settings.json、使用者自訂檔。
2. 檔案仍須和原compose.yaml處於完整目錄結構；不用改project名或另建volume。
3. 執行原位置的2-DOCKER-CHECK，再執行4-DOCKER-START；運行中只resume，不重裝。
4. 若需要控制台憑證，用5-DOCKER-TOKEN；token只在本人終端與本人本機網頁流轉。

自訂過啟動器者先比較diff，不盲目覆蓋；共享規範只更新已採用的內容。

## 新架構規則／skills：另做選擇性合併

把`CODEX_SETUP.md`、`ARCHITECTURE.md`及新版`workspace/`交給接收者自己的Codex，要求：

- 盤點本人當前workspace、USER／記憶／角色與專案正本，先備份。
- 只將新的架構段落、索引與3個通用skills作差異合併；保留本人SOUL／IDENTITY／USER／MEMORY、已有STATUS、渠道及工具授權。
- 不將原作者private repo、social-post私版語氣或其他人的憑證／歷史帶進來；這些沒有隨包提供。
- 新的角色範本與HELD專案骨架不是啟用許可。每案實際配置／沙盒／mount／路由驗收通過才可接管。
- 初始化器只複製缺少的範本；Gateway運行中的INSTALL會resume，不會偷偷把已有AGENTS改成新版，也不代表已自動同步規範。

## 回復

本次只更新腳本／文件時，可用安裝資料夾備份回復那些檔案。不要回復／替換別人的token或volume。若本人另行修改了live config，按該次變更的精確備份局部回復並讀回，不能用分享包空範本重置。
