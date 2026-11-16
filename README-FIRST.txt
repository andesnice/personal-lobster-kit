個人龍蝦 v5：這是安裝腳本ZIP，不是單一exe，也不是離線安裝光碟。

Windows＋Docker第一次安裝：
1. 完整解壓到本機資料夾，例如 D:\OpenClaw\personal-lobster。不要放網路磁碟或在ZIP內跑。
2. 尚無Docker Desktop：雙擊 windows\0-INSTALL-DOCKER-DESKTOP.bat；自己完成安裝、重開機及Docker Desktop首次設定。
3. 開啟Docker Desktop，雙擊 windows\DOCKER-CHECK.bat，等READY。
4. 雙擊 windows\DOCKER-INSTALL.bat，依終端官方網址在瀏覽器輸入當次裝置碼。
5. health passed後在同台電腦開控制台網址。
6. 若控制台要求Gateway密鑰：雙擊 windows\DOCKER-TOKEN.bat，把token只貼進自己本機網頁，不貼聊天。
7. 在控制台送「你好」，能取得真實AI回覆後才算對話驗收。

日後啟動：windows\DOCKER-START.bat。不重跑INSTALL，不刪volume。
已經裝過舊版：先讀 UPGRADE-EXISTING.md，不重新部署、不覆蓋自己的登入／USER／MEMORY。
卡住先讀 KNOWN-ISSUES.md；根目錄CHECK-SAFE.bat提供去敏診斷。
Mac／Linux：看 START-HERE.md。架構看 ARCHITECTURE.md 或 ARCHITECTURE.html。
