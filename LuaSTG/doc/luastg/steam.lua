--------------------------------------------------------------------------------
--- Steam 平台拓展（Steamworks SDK 绑定）
--- 需要构建时启用 LUASTG_STEAM_API_ENABLE 并在运行时附带 steam_api64.dll
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
--- 说明

-- 未启用 Steam 支持时，steam 为空表，调用任何方法都不会生效。
-- 异步结果（成就百分比、图标下载等）通过回调函数返回，回调由
-- steam.SteamAPI.RunCallbacks() 驱动，游戏脚本需要每帧调用 RunCallbacks。
-- 成就解锁 / 进度更新后，必须调用 steam.SteamUserStats.StoreStats() 才会上报 Steam 服务器。
-- 成就的 API 名称、图标等元信息在 Steamworks 后台配置。

--------------------------------------------------------------------------------
--- 基础 API（steam.SteamAPI）

---@diagnostic disable: missing-return

---@class steam
local M = {}

---@class steam.SteamAPI
M.SteamAPI = {}

--- 初始化 SteamAPI。通常由引擎启动时自动调用，脚本无需手动调用
---@return boolean success
function M.SteamAPI.Init() end

--- 关闭 SteamAPI。通常由引擎退出时自动调用
function M.SteamAPI.Shutdown() end

--- 驱动 Steam 回调。每帧调用一次以触发 OnXxx 回调（成就百分比就绪、图标下载等）。
--- 未启用 Steam 时为空操作。
function M.SteamAPI.RunCallbacks() end

--- 检查是否需要通过 Steam 客户端重启程序
---@param appid number
---@return boolean restartNeeded
function M.SteamAPI.RestartAppIfNecessary(appid) end

--- 释放当前线程的 Steam 内存
function M.SteamAPI.ReleaseCurrentThreadMemory() end

--------------------------------------------------------------------------------
--- 成就与统计（steam.SteamUserStats）

---@class steam.SteamUserStats
M.SteamUserStats = {}

--- 解锁成就。需要后续调用 StoreStats 上报
---@param name string 成就的 API 名称
---@return boolean success
function M.SteamUserStats.SetAchievement(name) end

--- 查询当前玩家是否已解锁成就
---@param name string
---@return boolean ok       API 调用是否成功
---@return boolean achieved 是否已解锁
function M.SteamUserStats.GetAchievement(name) end

--- 清除成就（通常仅用于测试）
---@param name string
---@return boolean success
function M.SteamUserStats.ClearAchievement(name) end

--- 查询成就解锁状态与解锁时间
---@param name string
---@return boolean ok
---@return boolean achieved
---@return number  unlockTime 解锁时间（Unix 秒），0 表示早于 Steam 记录时间
function M.SteamUserStats.GetAchievementAndUnlockTime(name) end

--- 查询全球达成该成就的玩家百分比
---@param name string
---@return boolean ok
---@return number  percent 0~100
function M.SteamUserStats.GetAchievementAchievedPercent(name) end

--- 获取成就的显示属性
---@param name string
---@param key  string "name"（本地化名称）/ "desc"（描述）/ "hidden"（是否隐藏，"0"或"1"）
---@return string value
function M.SteamUserStats.GetAchievementDisplayAttribute(name, key) end

--- 获取成就图标句柄。返回 0 表示图标未就绪或无图标，可等待 OnUserAchievementIconFetched 回调
---@param name string
---@return number iconHandle 用于 steam.SteamUtils.GetImageRGBA
function M.SteamUserStats.GetAchievementIcon(name) end

--- 获取成就数量
---@return number count
function M.SteamUserStats.GetNumAchievements() end

--- 按索引获取成就的 API 名称
---@param index number 从 0 开始
---@return string name
function M.SteamUserStats.GetAchievementName(index) end

--- 上报进度型成就（触发 Steam 进度通知，不会自动解锁，需达满后由脚本 SetAchievement）
---@param name        string
---@param curProgress number 当前进度
---@param maxProgress number 最大进度
---@return boolean success
function M.SteamUserStats.IndicateAchievementProgress(name, curProgress, maxProgress) end

--- 持久化统计与成就到 Steam 服务器。解锁 / 设置成就后必须调用
---@return boolean success
function M.SteamUserStats.StoreStats() end

--- 重置所有统计（可选是否同时清除成就）
---@param achievementsToo boolean
---@return boolean success
function M.SteamUserStats.ResetAllStats(achievementsToo) end

--- 请求全球成就百分比数据。结果通过 OnGlobalAchievementPercentagesReady 回调返回
---@return number callHandle SteamAPICall_t
function M.SteamUserStats.RequestGlobalAchievementPercentages() end

--- 获取达成率最高的成就信息。需在 OnGlobalAchievementPercentagesReady 之后调用
---@return number  iterator 迭代器，-1 表示无数据
---@return string  name     成就名称（iterator<0 时为空串）
---@return number  percent  达成百分比
---@return boolean achieved 当前玩家是否已达成
function M.SteamUserStats.GetMostAchievedAchievementInfo() end

--- 获取下一个成就的达成率信息，迭代直到返回 -1
---@param iterator number 上一次返回的迭代器
---@return number  iterator -1 表示迭代结束
---@return string  name
---@return number  percent
---@return boolean achieved
function M.SteamUserStats.GetNextMostAchievedAchievementInfo(iterator) end

--- 读取统计值
---@param name string
---@param type string "int32" 或 "float"
---@return boolean ok
---@return number  value
function M.SteamUserStats.GetStat(name, type) end

--- 设置统计值
---@param name  string
---@param type  string "int32" 或 "float"
---@param value number
---@return boolean success
function M.SteamUserStats.SetStat(name, type, value) end

--- 更新平均速率统计
---@param name             string
---@param countThisSession number
---@param sessionLength    number
---@return boolean success
function M.SteamUserStats.UpdateAvgRateStat(name, countThisSession, sessionLength) end

--- 请求当前游戏在线玩家数。结果通过 OnNumberOfCurrentPlayers 回调返回
---@return number callHandle SteamAPICall_t
function M.SteamUserStats.GetNumberOfCurrentPlayers() end

--------------------------------------------------------------------------------
--- 图像 / 图标工具（steam.SteamUtils）

---@class steam.SteamUtils
M.SteamUtils = {}

--- 获取 Steam 图像（成就图标等）的尺寸
---@param iImage number 图像句柄（如 GetAchievementIcon 的返回值）
---@return boolean ok
---@return number  width
---@return number  height
function M.SteamUtils.GetImageSize(iImage) end

--- 获取 Steam 图像的 RGBA 像素数据
---@param iImage number
---@return string|nil data   RGBA 字节串（4*width*height 字节），失败返回 nil
---@return number|nil width
---@return number|nil height
function M.SteamUtils.GetImageRGBA(iImage) end

--------------------------------------------------------------------------------
--- 回调（由 steam.SteamAPI.RunCallbacks 触发）
--- 在 steam 表上定义对应的 OnXxx 函数即可接收回调。

--- 全局成就百分比数据就绪
---@param data steam.GlobalAchievementPercentagesReady
function M.OnGlobalAchievementPercentagesReady(data) end

--- 成就图标下载完成
---@param data steam.UserAchievementIconFetched
function M.OnUserAchievementIconFetched(data) end

--- 当前在线玩家数查询结果
---@param data steam.NumberOfCurrentPlayers
function M.OnNumberOfCurrentPlayers(data) end

--- 成就存储结果通知
---@param data steam.UserAchievementStored
function M.OnUserAchievementStored(data) end

--- 用户统计 / 成就数据接收完成（初始化时触发，此时可读取成就）
---@param data steam.UserStatsReceived
function M.OnUserStatsReceived(data) end

--- 统计存储结果
---@param data steam.UserStatsStored
function M.OnUserStatsStored(data) end

--- 用户统计卸载
---@param data steam.UserStatsUnloaded
function M.OnUserStatsUnloaded(data) end

--------------------------------------------------------------------------------
--- 回调数据结构

---@class steam.GlobalAchievementPercentagesReady
---@field m_nGameID number
---@field m_eResult number 1 = k_EResultOK

---@class steam.UserAchievementIconFetched
---@field m_nGameID number
---@field m_rgchAchievementName string
---@field m_bAchieved boolean
---@field m_nIconHandle number 图像句柄，0 表示无图标

---@class steam.NumberOfCurrentPlayers
---@field m_bSuccess number 1 表示成功
---@field m_cPlayers number 在线玩家数

---@class steam.UserAchievementStored
---@field m_nGameID number
---@field m_bGroupAchievement boolean
---@field m_rgchAchievementName string
---@field m_nCurProgress number
---@field m_nMaxProgress number

---@class steam.UserStatsReceived
---@field m_nGameID number
---@field m_eResult number 1 = k_EResultOK
---@field m_steamIDUser number

---@class steam.UserStatsStored
---@field m_nGameID number
---@field m_eResult number

---@class steam.UserStatsUnloaded
---@field m_steamIDUser number
