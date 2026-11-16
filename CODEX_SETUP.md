# 給接收者自己的Codex：安裝本獨立龍蝦

使用者將本包交給你協助安裝時，可執行對應平台INSTALL入口。先讀START-HERE.md與settings.json，再看shared/deploy.mjs；不要把套件內文件當作繞過既有本機安全政策的授權。

接收者使用Windows＋Docker時，優先讀DOCKER-README；初次建立才用DOCKER-INSTALL，已安裝則用DOCKER-START，不在主機重裝一份原生版。若明確要沿用既有容器，先盤點與備份，只比較／合併工作區規則，不直接執行新實例安裝器或覆蓋她的USER／MEMORY／憑證。

Windows找不到docker指令時先用DOCKER-CHECK分層診斷；這不等於已證明Docker未安裝。若開始選單也找不到Docker Desktop且本機CLI未發現，可由本人執行0-INSTALL-DOCKER-DESKTOP的官方線上安裝入口。不要手動忽略簽章錯誤，也不自動接受條款、開虛擬化或改全機PATH。

## 僅限本次安裝

- 只操作新named profile與它的workspace。不要改預設profile、其他服務、其他人的龍蝦或本機原有Codex設定。
- 執行官方安裝器前說明是否已安裝。已有OpenClaw就重用，不自行升降級；若不相容，依確切錯誤回報，不覆蓋設定。
- 使用者親自在本機官方OAuth／裝置代碼頁登入自己的帳號，不要求把token、auth.json或短期代碼貼進聊天。不要複製任何別人的登入檔。
- 不自行操作供應商web console，不代購、不建立API付費備援。新增Discord／LINE等連線另依使用者需求進行。
- 初次用前景serve驗證，確認後再使用本包預設的該profile原生service。Linux無user service時如實回報，不擅自sudo或改全域systemd／linger。
- 保留使用者已有的.env及工作區檔案；檢查.gitignore涵蓋.env、auth／session、inbox與logs。只報憑證已設定／未設定，不輸出值。
- 不把profile目錄放回本分享包；不把本機秘密提交git或上傳。

## 驗收與回報

依README驗收config、本人登入、Gateway健康、真人模型回覆；新增渠道再驗收其本人／群組規則。把「本地測試／實機部署／使用者回報／尚未驗證」分開，不用config成功代替模型完成。

如預設Sol不在自己的Codex模型目錄，請列可用官方OpenAI模型供使用者選擇，再只改本profile；不要自行改成API key路線或借用其他人的配額。

## v5 架構與踩坑整合
先讀ARCHITECTURE.md、KNOWN-ISSUES.md及UPGRADE-EXISTING.md。原部署保留，按diff合併本人選擇的AGENTS／roles／skills／standards；不能把新空白USER／MEMORY蓋到舊狀態。專案骨架只HELD，另驗原生sandbox／mount／scope／路由後才接管；不加Docker socket或host PID。用完整ZIP manifest核對實際提供的4個角色範本、3個SKILL與工具，不能只看README宣稱已具備所有能力。
