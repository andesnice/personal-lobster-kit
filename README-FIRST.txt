個人龍蝦 v5.1：這是安裝腳本ZIP，不是單一exe，也不是離線安裝光碟。

【Windows＋Docker 安裝順序】解壓後，在本資料夾最上層「依數字由小到大」雙擊，不要點 windows 資料夾裡的 .ps1（那是內部腳本）。
  1-INSTALL-DOCKER-DESKTOP.bat  只有尚未安裝 Docker Desktop 時才跑。自己完成安裝、重開機及首次設定。已有 Docker 就跳過。
  2-DOCKER-CHECK.bat            先開啟 Docker Desktop，再跑這個，等畫面顯示 READY。只檢查，不安裝龍蝦。
  3-DOCKER-INSTALL.bat          第一次安裝龍蝦。依終端官方網址，在瀏覽器輸入當次裝置碼。只在第一次跑。
  4-DOCKER-START.bat            日後每次啟動都用這個。不重跑 3、不刪 volume。
  5-DOCKER-TOKEN.bat            只有控制台要求 Gateway 密鑰時才跑；token 只貼進自己本機網頁，不貼聊天。
  9a／9b-NATIVE-*.bat           不用 Docker 的備用方案，二選一，不要和 Docker 版同時使用。

第一次完整流程：
1. 完整解壓到本機資料夾，例如 D:\OpenClaw\personal-lobster。不要放網路磁碟或在ZIP內跑。
2. 沒有 Docker Desktop：先 1，完成安裝後開啟 Docker Desktop；已有就直接開啟。
3. 雙擊 2，等 READY。
4. 雙擊 3，登入自己的 Codex。
5. health passed 後，在同台電腦開控制台網址；若要求密鑰才跑 5。
6. 在控制台送「你好」，能取得真實AI回覆後才算對話驗收。

Mac：先開 Docker Desktop，依序 macos/DOCKER-INSTALL.command（第一次）、日後 macos/DOCKER-START.command。
Linux／VPS：bash linux/docker-install.sh（第一次）、日後 bash linux/docker-start.sh。
已經裝過舊版：先讀 UPGRADE-EXISTING.md，不重新部署、不覆蓋自己的登入／USER／MEMORY。
卡住先讀 KNOWN-ISSUES.md；根目錄CHECK-SAFE.bat提供去敏診斷。架構看 ARCHITECTURE.md 或 ARCHITECTURE.html。
