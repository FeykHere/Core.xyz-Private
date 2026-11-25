--// Core.xyz Loader (FlowAuth Auth + Universe ID Gate + Black-Themed Animated White-Glow Key System UI)
if type(flow_init) ~= "function" then
	getgenv().flow_init = function(cb)
		local k = cb("")
		if type(k) ~= "string" or k == "" then
			error("FlowAuth: Key verification cancelled.", 0)
		end
		return k
	end
end

flow_init(function(currentKey)
	local CONFIG = {
		ProjectId = 10959,
		LoaderHash = "5aadc1854f782322ada05d461c2cb0cd",
		ScriptLoaderHash = "940f8bacfe9c5b2cda8fa3d058fad0f4",
		ApiToken = "adb858e40cf5dc946478beaa63d0693f51ad4b83ac4bef78",
		RewardUrl = "https://flowauth.net/reward/5aadc1854f782322ada05d461c2cb0cd",
		SupportedGames = {
			[9294074907] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/One-shot.lua",
			[10766620257] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/BikeForEgg.lua",
			[9641502068] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/Knife.Duels",
			[10770730129] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/Ragdoll-soccer",
		},
		SupportedPlaces = {
			[90568084448279] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/One-shot.lua",
			[74023858073178] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/BikeForEgg.lua",
			[112731528776884] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/Knife.Duels",
			[106931373443671] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/Ragdoll-soccer",
		},
	}

	local KEY_FILE = "CoreXYZ_Key.txt"
	local KEY_META_FILE = "CoreXYZ_KeyMeta.json"
	local DEFAULT_KEY_DURATION_SECONDS = 86400

	local Players = game:GetService("Players")
	local TweenService = game:GetService("TweenService")
	local UserInputService = game:GetService("UserInputService")
	local StarterGui = game:GetService("StarterGui")
	local RunService = game:GetService("RunService")
	local HttpService = game:GetService("HttpService")

	local fToString = tostring
	local fOsTime = os.time
	local fMathFloor = math.floor

	local fSetClipboard = setclipboard or toclipboard or set_clipboard or (type(Clipboard) == "table" and Clipboard.set)
	local fRequest = request
		or http_request
		or syn_request
		or (type(syn) == "table" and syn.request)
		or (type(http) == "table" and http.request)
		or (type(fluxus) == "table" and fluxus.request)

	local function safeJsonEncode(tbl)
		local ok, res = pcall(function()
			return HttpService:JSONEncode(tbl)
		end)
		return ok and res or "{}"
	end

	local function safeJsonDecode(str)
		if type(str) ~= "string" or str == "" then
			return nil
		end
		local ok, res = pcall(function()
			return HttpService:JSONDecode(str)
		end)
		return ok and res or nil
	end

	local function getHwidStr()
		local ok, rawHwid = pcall(function()
			if type(gethwid) == "function" then
				return gethwid()
			end
			local localPlayer = Players.LocalPlayer
			if localPlayer then
				return localPlayer.UserId
			end
			return 0
		end)
		if ok and rawHwid ~= nil and fToString(rawHwid) ~= "" then
			return fToString(rawHwid)
		end
		local localPlayer = Players.LocalPlayer
		return localPlayer and fToString(localPlayer.UserId) or "0"
	end

	local function safeRequest(reqParams)
		if type(fRequest) ~= "function" then
			return nil, "Executor HTTP request function is unavailable."
		end
		local ok, res = pcall(fRequest, reqParams)
		if not ok or type(res) ~= "table" then
			return nil, "Network request failed."
		end
		local statusCode = res.StatusCode or res.status_code or res.status or 0
		local body = res.Body or res.body or ""
		return {
			StatusCode = tonumber(statusCode) or 0,
			Body = type(body) == "string" and body or fToString(body),
		}, nil
	end

	local function sendNotification(title, text, duration)
		pcall(function()
			StarterGui:SetCore("SendNotification", {
				Title = title,
				Text = text,
				Duration = duration or 5,
			})
		end)
	end

	local function trim(str)
		if type(str) ~= "string" then
			return ""
		end
		return (str:gsub("^%s+", ""):gsub("%s+$", ""))
	end

	local function getSafeGuiParent()
		if type(gethui) == "function" then
			local ok, hui = pcall(gethui)
			if ok and hui then
				return hui
			end
		end
		local okCore, coreGui = pcall(function()
			return game:GetService("CoreGui")
		end)
		if okCore and coreGui then
			return coreGui
		end
		local lp = Players.LocalPlayer
		if lp then
			return lp:WaitForChild("PlayerGui")
		end
		return nil
	end

	local function destroyExistingGui(parent, guiName)
		if not parent then
			return
		end
		pcall(function()
			local existing = parent:FindFirstChild(guiName)
			if existing then
				existing:Destroy()
			end
		end)
	end

	local function safeIsFile(path)
		if type(isfile) == "function" then
			local ok, res = pcall(isfile, path)
			return ok and res == true
		end
		return false
	end

	local function safeReadFile(path)
		if type(readfile) == "function" then
			local ok, res = pcall(readfile, path)
			if ok and type(res) == "string" then
				return res
			end
		end
		return nil
	end

	local function safeWriteFile(path, content)
		if type(writefile) == "function" then
			return pcall(writefile, path, content)
		end
		return false
	end

	local function safeDeleteFile(path)
		if type(delfile) == "function" then
			return pcall(delfile, path)
		end
		return false
	end

	local function formatRemainingTime(remSec, isLifetime)
		if isLifetime then
			return "Lifetime"
		end
		if type(remSec) ~= "number" or remSec <= 0 then
			return "Expired"
		end
		local days = fMathFloor(remSec / 86400)
		local hours = fMathFloor((remSec % 86400) / 3600)
		local mins = fMathFloor((remSec % 3600) / 60)
		local secs = fMathFloor(remSec % 60)
		if days > 0 then
			return string.format("%dd %02dh %02dm %02ds", days, hours, mins, secs)
		elseif hours > 0 then
			return string.format("%02dh %02dm %02ds", hours, mins, secs)
		end
		return string.format("%02dm %02ds", mins, secs)
	end

	local lastVerifiedSession = nil

	local function verifyFlowAuthKey(rawKey)
		local cleanedKey = trim(rawKey)
		if cleanedKey == "" then
			return false, "Please enter a key first."
		end

		local lookupUrl = string.format("https://flowauth.net/v1/projects/%d/keys/lookup", CONFIG.ProjectId)
		local res, reqErr = safeRequest({
			Url = lookupUrl,
			Method = "POST",
			Headers = {
				["Authorization"] = "Bearer " .. CONFIG.ApiToken,
				["Content-Type"] = "application/json",
			},
			Body = safeJsonEncode({
				key_value = cleanedKey,
			}),
		})

		if not res then
			return false, reqErr or "Failed to connect to FlowAuth."
		end

		if res.StatusCode == 404 then
			return false, "Invalid key. Please check your key and try again."
		elseif res.StatusCode == 429 then
			return false, "Rate limited by FlowAuth. Wait a few seconds and try again."
		elseif res.StatusCode ~= 200 then
			return false, "Invalid or unrecognized FlowAuth key."
		end

		local data = safeJsonDecode(res.Body)
		if type(data) ~= "table" or not data.id then
			return false, "Invalid response from FlowAuth."
		end

		if data.blacklist_id ~= nil then
			return false, "This key has been blacklisted."
		end

		local effStatus = fToString(data.effective_status or data.status or "")
		if effStatus == "paused" then
			return false, "This key is currently paused."
		elseif effStatus == "expired" then
			return false, "This key has expired."
		elseif effStatus ~= "active" then
			return false, "Key is not active (" .. (effStatus ~= "" and effStatus or "inactive") .. ")."
		end

		local now = fOsTime()
		local dur = type(data.duration) == "table" and data.duration or {}
		local isLifetime = (dur.is_lifetime == true) or (dur.state == "lifetime")
		local expiresAt = nil
		local remainingSeconds = nil

		if isLifetime then
			expiresAt = nil
			remainingSeconds = math.huge
		else
			local remMs = tonumber(dur.remaining_ms)
			if remMs == nil and tonumber(data.expires_after_ms) then
				remMs = tonumber(data.expires_after_ms)
			end
			if remMs and remMs > 0 then
				remainingSeconds = fMathFloor(remMs / 1000)
				expiresAt = now + remainingSeconds
			elseif tonumber(data.expires_at) then
				local expVal = tonumber(data.expires_at)
				if expVal > 1e12 then
					local evalMs = tonumber(dur.evaluated_at) or (now * 1000)
					local diffSec = fMathFloor((expVal - evalMs) / 1000)
					if diffSec <= 0 then
						return false, "This key has expired."
					end
					remainingSeconds = diffSec
					expiresAt = now + diffSec
				else
					if expVal <= now then
						return false, "This key has expired."
					end
					remainingSeconds = expVal - now
					expiresAt = expVal
				end
			elseif remMs and remMs <= 0 then
				return false, "This key has expired."
			else
				remainingSeconds = DEFAULT_KEY_DURATION_SECONDS
				expiresAt = now + DEFAULT_KEY_DURATION_SECONDS
			end
		end

		lastVerifiedSession = {
			provider = "FlowAuth",
			projectId = CONFIG.ProjectId,
			loaderHash = CONFIG.LoaderHash,
			apiToken = CONFIG.ApiToken,
			key = cleanedKey,
			keyId = data.id,
			tier = fToString(data.tier or "free"),
			isLifetime = isLifetime,
			expiresAt = expiresAt,
			remainingSeconds = remainingSeconds,
			hasServerExpiry = true,
			activatedAt = now,
			verifiedAt = now,
			note = data.note,
			claimedBy = data.claimed_by,
		}

		return true, lastVerifiedSession
	end

	local function persistKeySession(verifiedKey)
		local now = fOsTime()
		local sessionData = lastVerifiedSession or {
			provider = "FlowAuth",
			projectId = CONFIG.ProjectId,
			loaderHash = CONFIG.LoaderHash,
			apiToken = CONFIG.ApiToken,
			key = verifiedKey,
			tier = "free",
			isLifetime = false,
			expiresAt = now + DEFAULT_KEY_DURATION_SECONDS,
			remainingSeconds = DEFAULT_KEY_DURATION_SECONDS,
			hasServerExpiry = true,
			activatedAt = now,
			verifiedAt = now,
		}

		safeWriteFile(KEY_META_FILE, safeJsonEncode({
			provider = "FlowAuth",
			projectId = sessionData.projectId,
			key = sessionData.key,
			keyId = sessionData.keyId,
			tier = sessionData.tier,
			isLifetime = sessionData.isLifetime == true,
			activatedAt = sessionData.activatedAt,
			expiresAt = sessionData.expiresAt,
			hasServerExpiry = true,
			verifiedAt = sessionData.verifiedAt,
		}))

		pcall(function()
			local envTbl = (type(getgenv) == "function" and getgenv()) or _G
			envTbl.__CoreXYZ_KeySession = sessionData
			envTbl.LRM_KeyTier = sessionData.tier or "free"
			envTbl.LRM_IsUserPremium = true
			envTbl.LRM_SecondsLeft = sessionData.isLifetime and math.huge or (sessionData.remainingSeconds or DEFAULT_KEY_DURATION_SECONDS)
			envTbl.LRM_UserNote = fToString(sessionData.note or "")
			envTbl.LRM_LinkedDiscordID = fToString(sessionData.claimedBy or "")
		end)
	end

	local function showUnsupportedBanner(messageText)
		local guiParent = getSafeGuiParent()
		if not guiParent then
			return
		end

		destroyExistingGui(guiParent, "CoreXYZ_Unsupported")

		local bannerGui = Instance.new("ScreenGui")
		bannerGui.Name = "CoreXYZ_Unsupported"
		bannerGui.ResetOnSpawn = false
		bannerGui.IgnoreGuiInset = true
		bannerGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
		bannerGui.DisplayOrder = 999999

		local bannerFrame = Instance.new("Frame")
		bannerFrame.Name = "UnsupportedBanner"
		bannerFrame.AnchorPoint = Vector2.new(0.5, 0)
		bannerFrame.Position = UDim2.new(0.5, 0, 0, -96)
		bannerFrame.Size = UDim2.new(0, 344, 0, 74)
		bannerFrame.BackgroundColor3 = Color3.fromRGB(8, 8, 11)
		bannerFrame.BorderSizePixel = 0
		bannerFrame.Parent = bannerGui

		local bCorner = Instance.new("UICorner")
		bCorner.CornerRadius = UDim.new(0, 10)
		bCorner.Parent = bannerFrame

		local bStroke = Instance.new("UIStroke")
		bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
		bStroke.Thickness = 1.2
		bStroke.Color = Color3.fromRGB(255, 255, 255)
		bStroke.Transparency = 0.35
		bStroke.Parent = bannerFrame

		local bDot = Instance.new("Frame")
		bDot.Position = UDim2.new(0, 14, 0, 16)
		bDot.Size = UDim2.new(0, 7, 0, 7)
		bDot.BackgroundColor3 = Color3.fromRGB(255, 85, 85)
		bDot.BorderSizePixel = 0
		bDot.Parent = bannerFrame
		local bDotCorner = Instance.new("UICorner")
		bDotCorner.CornerRadius = UDim.new(1, 0)
		bDotCorner.Parent = bDot

		local bannerHeader = Instance.new("TextLabel")
		bannerHeader.Name = "HeaderTitle"
		bannerHeader.Size = UDim2.new(1, -36, 0, 22)
		bannerHeader.Position = UDim2.new(0, 28, 0, 9)
		bannerHeader.BackgroundTransparency = 1
		bannerHeader.Font = Enum.Font.GothamBold
		bannerHeader.Text = "CORE.XYZ"
		bannerHeader.TextSize = 13
		bannerHeader.TextColor3 = Color3.fromRGB(250, 250, 255)
		bannerHeader.TextXAlignment = Enum.TextXAlignment.Left
		bannerHeader.Parent = bannerFrame

		local bannerMessage = Instance.new("TextLabel")
		bannerMessage.Name = "Message"
		bannerMessage.Size = UDim2.new(1, -28, 0, 22)
		bannerMessage.Position = UDim2.new(0, 14, 0, 38)
		bannerMessage.BackgroundTransparency = 1
		bannerMessage.Font = Enum.Font.GothamMedium
		bannerMessage.Text = messageText
		bannerMessage.TextSize = 13
		bannerMessage.TextColor3 = Color3.fromRGB(255, 100, 100)
		bannerMessage.TextXAlignment = Enum.TextXAlignment.Left
		bannerMessage.Parent = bannerFrame

		local parented = pcall(function()
			bannerGui.Parent = guiParent
		end)
		if not parented then
			bannerGui:Destroy()
			return
		end

		TweenService:Create(
			bannerFrame,
			TweenInfo.new(0.28, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0.5, 0, 0, 24) }
		):Play()

		task.delay(4.5, function()
			if bannerGui and bannerGui.Parent then
				local hideTween = TweenService:Create(
					bannerFrame,
					TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{ Position = UDim2.new(0.5, 0, 0, -96) }
				)
				hideTween:Play()
				hideTween.Completed:Wait()
				if bannerGui then
					bannerGui:Destroy()
				end
			end
		end)
	end

	if not game:IsLoaded() then
		game.Loaded:Wait()
	end
	repeat
		task.wait(0.1)
	until game:IsLoaded()

	local targetScriptUrl = CONFIG.SupportedGames[game.GameId] or (CONFIG.SupportedPlaces and CONFIG.SupportedPlaces[game.PlaceId])
	if not targetScriptUrl then
		sendNotification("Core.xyz", "Game is not Supported!", 5)
		showUnsupportedBanner("Game is not Supported!")
		return ""
	end

	local initialStatusText = "Enter your FlowAuth key to continue."
	local initialStatusColor = Color3.fromRGB(195, 198, 210)

	-- 1. If a key was passed directly to the loader argument, verify and return it
	local argKey = trim(fToString(currentKey or ""))
	if argKey ~= "" and argKey ~= "FLOW-REPLACE-WITH-YOUR-KEY" then
		local isValid, sessionOrErr = verifyFlowAuthKey(argKey)
		if isValid == true then
			safeWriteFile(KEY_FILE, argKey)
			persistKeySession(argKey)
			return argKey
		else
			initialStatusText = fToString(sessionOrErr or "Provided key is invalid or expired.")
			initialStatusColor = Color3.fromRGB(255, 100, 100)
		end
	end

	-- 2. Check saved key file on disk
	if safeIsFile(KEY_FILE) then
		local savedKey = trim(safeReadFile(KEY_FILE) or "")
		if savedKey ~= "" then
			sendNotification("Core.xyz", "Checking saved FlowAuth key...", 3)
			local isValid, sessionOrErr = verifyFlowAuthKey(savedKey)
			if isValid == true then
				persistKeySession(savedKey)
				local timeTag = "Active"
				if type(sessionOrErr) == "table" then
					if sessionOrErr.isLifetime then
						timeTag = "Lifetime"
					elseif tonumber(sessionOrErr.remainingSeconds) then
						timeTag = formatRemainingTime(sessionOrErr.remainingSeconds, false) .. " left"
					end
				end
				sendNotification("Core.xyz", "Key Valid (" .. timeTag .. ")! Loading script...", 4)
				return savedKey
			else
				safeDeleteFile(KEY_FILE)
				safeDeleteFile(KEY_META_FILE)
				sendNotification("Core.xyz", "Your Saved key is Invalid/Expired.", 5)
				initialStatusText = fToString(sessionOrErr or "Your Saved key is Invalid/Expired.")
				initialStatusColor = Color3.fromRGB(255, 100, 100)
			end
		end
	end

	-- 3. Open Black-Themed Animated White-Glow Key System UI and block until verified
	local verifiedKeyResult = nil
	local uiClosed = false

	local guiParent = getSafeGuiParent()
	if not guiParent then
		return ""
	end

	destroyExistingGui(guiParent, "CoreXYZ_KeySystem")

	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "CoreXYZ_KeySystem"
	screenGui.ResetOnSpawn = false
	screenGui.IgnoreGuiInset = true
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.DisplayOrder = 999999

	local rootHolder = Instance.new("Frame")
	rootHolder.Name = "RootHolder"
	rootHolder.AnchorPoint = Vector2.new(0.5, 0.5)
	rootHolder.Position = UDim2.new(0.5, 0, 0.5, 12)
	rootHolder.Size = UDim2.new(0, 420, 0, 224)
	rootHolder.BackgroundTransparency = 1
	rootHolder.BorderSizePixel = 0
	rootHolder.Parent = screenGui

	local mainScale = Instance.new("UIScale")
	mainScale.Scale = 0.86
	mainScale.Parent = rootHolder

	local shadowDeep = Instance.new("Frame")
	shadowDeep.Name = "ShadowDeep"
	shadowDeep.AnchorPoint = Vector2.new(0.5, 0.5)
	shadowDeep.Position = UDim2.new(0.5, 0, 0.5, 8)
	shadowDeep.Size = UDim2.new(1, 32, 1, 32)
	shadowDeep.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadowDeep.BackgroundTransparency = 0.45
	shadowDeep.BorderSizePixel = 0
	shadowDeep.ZIndex = 1
	shadowDeep.Parent = rootHolder
	local shadowDeepCorner = Instance.new("UICorner")
	shadowDeepCorner.CornerRadius = UDim.new(0, 20)
	shadowDeepCorner.Parent = shadowDeep

	local outerGlowFrame = Instance.new("Frame")
	outerGlowFrame.Name = "OuterWhiteGlow"
	outerGlowFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	outerGlowFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
	outerGlowFrame.Size = UDim2.new(1, 6, 1, 6)
	outerGlowFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	outerGlowFrame.BackgroundTransparency = 0.94
	outerGlowFrame.BorderSizePixel = 0
	outerGlowFrame.ZIndex = 1
	outerGlowFrame.Parent = rootHolder
	local outerGlowCorner = Instance.new("UICorner")
	outerGlowCorner.CornerRadius = UDim.new(0, 17)
	outerGlowCorner.Parent = outerGlowFrame

	local outerGlowStroke = Instance.new("UIStroke")
	outerGlowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	outerGlowStroke.Thickness = 2.4
	outerGlowStroke.Color = Color3.fromRGB(255, 255, 255)
	outerGlowStroke.Transparency = 0.72
	outerGlowStroke.Parent = outerGlowFrame

	local outerGlowGrad = Instance.new("UIGradient")
	outerGlowGrad.Rotation = 0
	outerGlowGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(110, 115, 130)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(110, 115, 130)),
	})
	outerGlowGrad.Parent = outerGlowStroke

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainContainer"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.Position = UDim2.new(0, 0, 0, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(6, 6, 8)
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.ZIndex = 2
	mainFrame.Parent = rootHolder

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 14)
	mainCorner.Parent = mainFrame

	local mainGrad = Instance.new("UIGradient")
	mainGrad.Rotation = 120
	mainGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(14, 14, 18)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(7, 7, 10)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(3, 3, 5)),
	})
	mainGrad.Parent = mainFrame

	local mainStroke = Instance.new("UIStroke")
	mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	mainStroke.Thickness = 1.45
	mainStroke.Color = Color3.fromRGB(255, 255, 255)
	mainStroke.Transparency = 0.15
	mainStroke.Parent = mainFrame

	local borderStrokeGrad = Instance.new("UIGradient")
	borderStrokeGrad.Rotation = 0
	borderStrokeGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(95, 100, 115)),
		ColorSequenceKeypoint.new(0.3, Color3.fromRGB(200, 205, 220)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.7, Color3.fromRGB(200, 205, 220)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(95, 100, 115)),
	})
	borderStrokeGrad.Parent = mainStroke

	local topAccent = Instance.new("Frame")
	topAccent.Name = "TopAccent"
	topAccent.Position = UDim2.new(0, 0, 0, 0)
	topAccent.Size = UDim2.new(1, 0, 0, 2)
	topAccent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	topAccent.BorderSizePixel = 0
	topAccent.ZIndex = 6
	topAccent.Parent = mainFrame

	local topAccentGrad = Instance.new("UIGradient")
	topAccentGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 45)),
		ColorSequenceKeypoint.new(0.32, Color3.fromRGB(165, 170, 185)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.68, Color3.fromRGB(165, 170, 185)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(35, 35, 45)),
	})
	topAccentGrad.Parent = topAccent

	local topGlow = Instance.new("Frame")
	topGlow.Name = "TopGlow"
	topGlow.Position = UDim2.new(0, 0, 0, 2)
	topGlow.Size = UDim2.new(1, 0, 0, 26)
	topGlow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	topGlow.BackgroundTransparency = 0.91
	topGlow.BorderSizePixel = 0
	topGlow.ZIndex = 2
	topGlow.Parent = mainFrame

	local topGlowGrad = Instance.new("UIGradient")
	topGlowGrad.Rotation = 90
	topGlowGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0),
		NumberSequenceKeypoint.new(1, 1),
	})
	topGlowGrad.Parent = topGlow

	local bottomProgress = Instance.new("Frame")
	bottomProgress.Name = "BottomProgress"
	bottomProgress.AnchorPoint = Vector2.new(0, 1)
	bottomProgress.Position = UDim2.new(0, 0, 1, 0)
	bottomProgress.Size = UDim2.new(0, 0, 0, 2)
	bottomProgress.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bottomProgress.BorderSizePixel = 0
	bottomProgress.ZIndex = 7
	bottomProgress.Parent = mainFrame

	local headerBar = Instance.new("Frame")
	headerBar.Name = "HeaderBar"
	headerBar.Position = UDim2.new(0, 0, 0, 2)
	headerBar.Size = UDim2.new(1, 0, 0, 48)
	headerBar.BackgroundTransparency = 1
	headerBar.BorderSizePixel = 0
	headerBar.Active = true
	headerBar.ZIndex = 3
	headerBar.Parent = mainFrame

	local statusDotRing = Instance.new("Frame")
	statusDotRing.Name = "StatusDotRing"
	statusDotRing.AnchorPoint = Vector2.new(0.5, 0.5)
	statusDotRing.Position = UDim2.new(0, 22, 0.5, 0)
	statusDotRing.Size = UDim2.new(0, 14, 0, 14)
	statusDotRing.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	statusDotRing.BackgroundTransparency = 0.78
	statusDotRing.BorderSizePixel = 0
	statusDotRing.ZIndex = 3
	statusDotRing.Parent = headerBar

	local ringCorner = Instance.new("UICorner")
	ringCorner.CornerRadius = UDim.new(1, 0)
	ringCorner.Parent = statusDotRing

	local statusDot = Instance.new("Frame")
	statusDot.Name = "StatusDot"
	statusDot.AnchorPoint = Vector2.new(0.5, 0.5)
	statusDot.Position = UDim2.new(0, 22, 0.5, 0)
	statusDot.Size = UDim2.new(0, 7, 0, 7)
	statusDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	statusDot.BorderSizePixel = 0
	statusDot.ZIndex = 4
	statusDot.Parent = headerBar

	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = statusDot

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "BrandTitle"
	titleLabel.Position = UDim2.new(0, 36, 0, 0)
	titleLabel.Size = UDim2.new(0, 140, 1, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBlack
	titleLabel.Text = "CORE.XYZ"
	titleLabel.TextSize = 15
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 4
	titleLabel.Parent = headerBar

	local authBadge = Instance.new("Frame")
	authBadge.Name = "FlowAuthBadge"
	authBadge.AnchorPoint = Vector2.new(1, 0.5)
	authBadge.Position = UDim2.new(1, -48, 0.5, 0)
	authBadge.Size = UDim2.new(0, 86, 0, 22)
	authBadge.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
	authBadge.BorderSizePixel = 0
	authBadge.ZIndex = 4
	authBadge.Parent = headerBar

	local authBadgeCorner = Instance.new("UICorner")
	authBadgeCorner.CornerRadius = UDim.new(0, 6)
	authBadgeCorner.Parent = authBadge

	local authBadgeStroke = Instance.new("UIStroke")
	authBadgeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	authBadgeStroke.Thickness = 1
	authBadgeStroke.Color = Color3.fromRGB(255, 255, 255)
	authBadgeStroke.Transparency = 0.55
	authBadgeStroke.Parent = authBadge

	local authBadgeText = Instance.new("TextLabel")
	authBadgeText.Size = UDim2.new(1, 0, 1, 0)
	authBadgeText.BackgroundTransparency = 1
	authBadgeText.Font = Enum.Font.GothamBold
	authBadgeText.Text = "FLOWAUTH"
	authBadgeText.TextSize = 10
	authBadgeText.TextColor3 = Color3.fromRGB(240, 242, 250)
	authBadgeText.ZIndex = 5
	authBadgeText.Parent = authBadge

	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -15, 0.5, 0)
	closeBtn.Size = UDim2.new(0, 26, 0, 26)
	closeBtn.BackgroundColor3 = Color3.fromRGB(14, 14, 18)
	closeBtn.BorderSizePixel = 0
	closeBtn.AutoButtonColor = false
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Text = "X"
	closeBtn.TextSize = 11
	closeBtn.TextColor3 = Color3.fromRGB(210, 214, 225)
	closeBtn.ZIndex = 4
	closeBtn.Parent = headerBar

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 7)
	closeCorner.Parent = closeBtn

	local closeStroke = Instance.new("UIStroke")
	closeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	closeStroke.Thickness = 1
	closeStroke.Color = Color3.fromRGB(255, 255, 255)
	closeStroke.Transparency = 0.6
	closeStroke.Parent = closeBtn

	local headerDivider = Instance.new("Frame")
	headerDivider.Name = "HeaderDivider"
	headerDivider.Position = UDim2.new(0, 18, 0, 50)
	headerDivider.Size = UDim2.new(1, -36, 0, 1)
	headerDivider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	headerDivider.BackgroundTransparency = 0.65
	headerDivider.BorderSizePixel = 0
	headerDivider.ZIndex = 3
	headerDivider.Parent = mainFrame

	local divGrad = Instance.new("UIGradient")
	divGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.15, 0.15),
		NumberSequenceKeypoint.new(0.85, 0.15),
		NumberSequenceKeypoint.new(1, 1),
	})
	divGrad.Parent = headerDivider

	local bodyFrame = Instance.new("Frame")
	bodyFrame.Name = "Body"
	bodyFrame.Position = UDim2.new(0, 0, 0, 51)
	bodyFrame.Size = UDim2.new(1, 0, 1, -51)
	bodyFrame.BackgroundTransparency = 1
	bodyFrame.BorderSizePixel = 0
	bodyFrame.ZIndex = 3
	bodyFrame.Parent = mainFrame

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Position = UDim2.new(0, 18, 0, 12)
	statusLabel.Size = UDim2.new(1, -36, 0, 30)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Font = Enum.Font.GothamMedium
	statusLabel.Text = initialStatusText
	statusLabel.TextSize = 13
	statusLabel.TextWrapped = true
	statusLabel.TextColor3 = initialStatusColor
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.TextYAlignment = Enum.TextYAlignment.Center
	statusLabel.ZIndex = 4
	statusLabel.Parent = bodyFrame

	local inputHolder = Instance.new("Frame")
	inputHolder.Name = "InputHolder"
	inputHolder.AnchorPoint = Vector2.new(0.5, 0)
	inputHolder.Position = UDim2.new(0.5, 0, 0, 50)
	inputHolder.Size = UDim2.new(1, -36, 0, 44)
	inputHolder.BackgroundTransparency = 1
	inputHolder.BorderSizePixel = 0
	inputHolder.ZIndex = 4
	inputHolder.Parent = bodyFrame

	local inputScale = Instance.new("UIScale")
	inputScale.Scale = 1
	inputScale.Parent = inputHolder

	local keyBox = Instance.new("TextBox")
	keyBox.Name = "KeyInput"
	keyBox.Position = UDim2.new(0, 0, 0, 0)
	keyBox.Size = UDim2.new(1, 0, 1, 0)
	keyBox.BackgroundColor3 = Color3.fromRGB(11, 11, 15)
	keyBox.BorderSizePixel = 0
	keyBox.Font = Enum.Font.Code
	keyBox.Text = ""
	keyBox.PlaceholderText = "Paste your FlowAuth key here..."
	keyBox.PlaceholderColor3 = Color3.fromRGB(120, 124, 138)
	keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyBox.TextSize = 14
	keyBox.TextXAlignment = Enum.TextXAlignment.Left
	keyBox.ClearTextOnFocus = false
	keyBox.ClipsDescendants = true
	keyBox.ZIndex = 5
	keyBox.Parent = inputHolder

	local keyBoxCorner = Instance.new("UICorner")
	keyBoxCorner.CornerRadius = UDim.new(0, 9)
	keyBoxCorner.Parent = keyBox

	local keyBoxPadding = Instance.new("UIPadding")
	keyBoxPadding.PaddingLeft = UDim.new(0, 14)
	keyBoxPadding.PaddingRight = UDim.new(0, 14)
	keyBoxPadding.Parent = keyBox

	local keyBoxStroke = Instance.new("UIStroke")
	keyBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	keyBoxStroke.Thickness = 1.2
	keyBoxStroke.Color = Color3.fromRGB(255, 255, 255)
	keyBoxStroke.Transparency = 0.62
	keyBoxStroke.Parent = keyBox

	local focusBar = Instance.new("Frame")
	focusBar.Name = "FocusBar"
	focusBar.AnchorPoint = Vector2.new(0.5, 1)
	focusBar.Position = UDim2.new(0.5, 0, 1, 0)
	focusBar.Size = UDim2.new(0, 0, 0, 2)
	focusBar.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	focusBar.BackgroundTransparency = 0.08
	focusBar.BorderSizePixel = 0
	focusBar.ZIndex = 6
	focusBar.Parent = inputHolder

	local focusBarCorner = Instance.new("UICorner")
	focusBarCorner.CornerRadius = UDim.new(1, 0)
	focusBarCorner.Parent = focusBar

	local focusInInfo = TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
	local focusOutInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	keyBox.Focused:Connect(function()
		TweenService:Create(keyBox, focusInInfo, { BackgroundColor3 = Color3.fromRGB(17, 17, 23) }):Play()
		TweenService:Create(keyBoxStroke, focusInInfo, { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.08, Thickness = 1.5 }):Play()
		TweenService:Create(inputScale, focusInInfo, { Scale = 1.012 }):Play()
		TweenService:Create(focusBar, focusInInfo, { Size = UDim2.new(1, -18, 0, 2) }):Play()
	end)

	keyBox.FocusLost:Connect(function()
		TweenService:Create(keyBox, focusOutInfo, { BackgroundColor3 = Color3.fromRGB(11, 11, 15) }):Play()
		TweenService:Create(keyBoxStroke, focusOutInfo, { Color = Color3.fromRGB(255, 255, 255), Transparency = 0.62, Thickness = 1.2 }):Play()
		TweenService:Create(inputScale, focusOutInfo, { Scale = 1 }):Play()
		TweenService:Create(focusBar, focusOutInfo, { Size = UDim2.new(0, 0, 0, 2) }):Play()
	end)

	local buttonRow = Instance.new("Frame")
	buttonRow.Name = "ButtonRow"
	buttonRow.Position = UDim2.new(0, 18, 0, 108)
	buttonRow.Size = UDim2.new(1, -36, 0, 44)
	buttonRow.BackgroundTransparency = 1
	buttonRow.BorderSizePixel = 0
	buttonRow.ZIndex = 4
	buttonRow.Parent = bodyFrame

	local submitBtn = Instance.new("TextButton")
	submitBtn.Name = "SubmitButton"
	submitBtn.AnchorPoint = Vector2.new(0.5, 0.5)
	submitBtn.Position = UDim2.new(0.25, -5, 0.5, 0)
	submitBtn.Size = UDim2.new(0.5, -10, 1, 0)
	submitBtn.BackgroundColor3 = Color3.fromRGB(250, 250, 255)
	submitBtn.BorderSizePixel = 0
	submitBtn.AutoButtonColor = false
	submitBtn.ClipsDescendants = true
	submitBtn.Font = Enum.Font.GothamBold
	submitBtn.Text = "Submit"
	submitBtn.TextSize = 13
	submitBtn.TextColor3 = Color3.fromRGB(8, 8, 12)
	submitBtn.ZIndex = 5
	submitBtn.Parent = buttonRow

	local submitCorner = Instance.new("UICorner")
	submitCorner.CornerRadius = UDim.new(0, 9)
	submitCorner.Parent = submitBtn

	local submitStroke = Instance.new("UIStroke")
	submitStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	submitStroke.Thickness = 1.25
	submitStroke.Color = Color3.fromRGB(255, 255, 255)
	submitStroke.Transparency = 0.1
	submitStroke.Parent = submitBtn

	local submitSheen = Instance.new("Frame")
	submitSheen.Name = "Sheen"
	submitSheen.Position = UDim2.new(-0.45, 0, 0, 0)
	submitSheen.Size = UDim2.new(0.35, 0, 1, 0)
	submitSheen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	submitSheen.BackgroundTransparency = 0.55
	submitSheen.BorderSizePixel = 0
	submitSheen.ZIndex = 6
	submitSheen.Parent = submitBtn

	local submitSheenGrad = Instance.new("UIGradient")
	submitSheenGrad.Rotation = 20
	submitSheenGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.12),
		NumberSequenceKeypoint.new(1, 1),
	})
	submitSheenGrad.Parent = submitSheen

	local getKeyBtn = Instance.new("TextButton")
	getKeyBtn.Name = "GetKeyButton"
	getKeyBtn.AnchorPoint = Vector2.new(0.5, 0.5)
	getKeyBtn.Position = UDim2.new(0.75, 5, 0.5, 0)
	getKeyBtn.Size = UDim2.new(0.5, -10, 1, 0)
	getKeyBtn.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
	getKeyBtn.BorderSizePixel = 0
	getKeyBtn.AutoButtonColor = false
	getKeyBtn.ClipsDescendants = true
	getKeyBtn.Font = Enum.Font.GothamBold
	getKeyBtn.Text = "Get Key"
	getKeyBtn.TextSize = 13
	getKeyBtn.TextColor3 = Color3.fromRGB(248, 248, 255)
	getKeyBtn.ZIndex = 5
	getKeyBtn.Parent = buttonRow

	local getKeyCorner = Instance.new("UICorner")
	getKeyCorner.CornerRadius = UDim.new(0, 9)
	getKeyCorner.Parent = getKeyBtn

	local getKeyStroke = Instance.new("UIStroke")
	getKeyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	getKeyStroke.Thickness = 1.25
	getKeyStroke.Color = Color3.fromRGB(255, 255, 255)
	getKeyStroke.Transparency = 0.45
	getKeyStroke.Parent = getKeyBtn

	local getKeySheen = Instance.new("Frame")
	getKeySheen.Name = "Sheen"
	getKeySheen.Position = UDim2.new(-0.45, 0, 0, 0)
	getKeySheen.Size = UDim2.new(0.35, 0, 1, 0)
	getKeySheen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	getKeySheen.BackgroundTransparency = 0.72
	getKeySheen.BorderSizePixel = 0
	getKeySheen.ZIndex = 6
	getKeySheen.Parent = getKeyBtn

	local getKeySheenGrad = Instance.new("UIGradient")
	getKeySheenGrad.Rotation = 20
	getKeySheenGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.5, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	getKeySheenGrad.Parent = getKeySheen

	local function sweepButtonSheen(sheenObj)
		if not sheenObj or not sheenObj.Parent then
			return
		end
		sheenObj.Position = UDim2.new(-0.45, 0, 0, 0)
		TweenService:Create(
			sheenObj,
			TweenInfo.new(0.38, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Position = UDim2.new(1.15, 0, 0, 0) }
		):Play()
	end

	local function attachStyledButton(button, strokeObj, sheenObj, styleCfg)
		local btnScale = Instance.new("UIScale")
		btnScale.Scale = 1
		btnScale.Parent = button

		local hoverInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
		local pressInfo = TweenInfo.new(0.09, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local releaseInfo = TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

		local isHovered = false
		local cTween, stTween, scTween, rotTween

		local function playColors(bg, txt, brd, brdTrans)
			if cTween then
				cTween:Cancel()
			end
			cTween = TweenService:Create(button, hoverInfo, {
				BackgroundColor3 = bg,
				TextColor3 = txt,
			})
			cTween:Play()
			if strokeObj and brd then
				if stTween then
					stTween:Cancel()
				end
				stTween = TweenService:Create(strokeObj, hoverInfo, {
					Color = brd,
					Transparency = brdTrans or 0.1,
				})
				stTween:Play()
			end
		end

		local function playScale(target, info)
			if scTween then
				scTween:Cancel()
			end
			scTween = TweenService:Create(btnScale, info or hoverInfo, { Scale = target })
			scTween:Play()
		end

		button.MouseEnter:Connect(function()
			isHovered = true
			playScale(styleCfg.HoverScale or 1.025, hoverInfo)
			playColors(styleCfg.HoverBg, styleCfg.HoverText, styleCfg.HoverBorder, styleCfg.HoverBorderTrans)
			if sheenObj then
				sweepButtonSheen(sheenObj)
			end
			if styleCfg.RotateOnHover then
				if rotTween then
					rotTween:Cancel()
				end
				rotTween = TweenService:Create(button, hoverInfo, { Rotation = 90 })
				rotTween:Play()
			end
		end)

		button.MouseLeave:Connect(function()
			isHovered = false
			playScale(1, hoverInfo)
			playColors(styleCfg.RestBg, styleCfg.RestText, styleCfg.RestBorder, styleCfg.RestBorderTrans)
			if styleCfg.RotateOnHover then
				if rotTween then
					rotTween:Cancel()
				end
				rotTween = TweenService:Create(button, hoverInfo, { Rotation = 0 })
				rotTween:Play()
			end
		end)

		button.MouseButton1Down:Connect(function()
			playScale(0.95, pressInfo)
			playColors(styleCfg.PressBg, styleCfg.PressText, styleCfg.HoverBorder, styleCfg.HoverBorderTrans)
		end)

		button.MouseButton1Up:Connect(function()
			playScale(isHovered and (styleCfg.HoverScale or 1.025) or 1, releaseInfo)
			if isHovered then
				playColors(styleCfg.HoverBg, styleCfg.HoverText, styleCfg.HoverBorder, styleCfg.HoverBorderTrans)
			else
				playColors(styleCfg.RestBg, styleCfg.RestText, styleCfg.RestBorder, styleCfg.RestBorderTrans)
			end
		end)
	end

	attachStyledButton(submitBtn, submitStroke, submitSheen, {
		RestBg = Color3.fromRGB(250, 250, 255),
		RestText = Color3.fromRGB(8, 8, 12),
		RestBorder = Color3.fromRGB(255, 255, 255),
		RestBorderTrans = 0.1,
		HoverBg = Color3.fromRGB(255, 255, 255),
		HoverText = Color3.fromRGB(0, 0, 0),
		HoverBorder = Color3.fromRGB(255, 255, 255),
		HoverBorderTrans = 0,
		PressBg = Color3.fromRGB(218, 220, 230),
		PressText = Color3.fromRGB(0, 0, 0),
		HoverScale = 1.025,
	})

	attachStyledButton(getKeyBtn, getKeyStroke, getKeySheen, {
		RestBg = Color3.fromRGB(13, 13, 18),
		RestText = Color3.fromRGB(248, 248, 255),
		RestBorder = Color3.fromRGB(255, 255, 255),
		RestBorderTrans = 0.45,
		HoverBg = Color3.fromRGB(255, 255, 255),
		HoverText = Color3.fromRGB(8, 8, 12),
		HoverBorder = Color3.fromRGB(255, 255, 255),
		HoverBorderTrans = 0.05,
		PressBg = Color3.fromRGB(218, 220, 230),
		PressText = Color3.fromRGB(0, 0, 0),
		HoverScale = 1.025,
	})

	attachStyledButton(closeBtn, closeStroke, nil, {
		RestBg = Color3.fromRGB(14, 14, 18),
		RestText = Color3.fromRGB(210, 214, 225),
		RestBorder = Color3.fromRGB(255, 255, 255),
		RestBorderTrans = 0.6,
		HoverBg = Color3.fromRGB(255, 86, 96),
		HoverText = Color3.fromRGB(255, 255, 255),
		HoverBorder = Color3.fromRGB(255, 130, 140),
		HoverBorderTrans = 0.1,
		PressBg = Color3.fromRGB(215, 65, 75),
		PressText = Color3.fromRGB(255, 255, 255),
		HoverScale = 1.06,
		RotateOnHover = true,
	})

	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil
	local dragTween = nil
	local dragTweenInfo = TweenInfo.new(0.075, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)

	local dragInputBeganConn = headerBar.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragInput = input
			dragStart = input.Position
			startPos = rootHolder.Position
		end
	end)

	local dragInputChangedConn = UserInputService.InputChanged:Connect(function(input)
		if dragging and (input == dragInput or input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			local delta = input.Position - dragStart
			local targetUDim = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
			if dragTween then
				dragTween:Cancel()
			end
			dragTween = TweenService:Create(rootHolder, dragTweenInfo, { Position = targetUDim })
			dragTween:Play()
		end
	end)

	local dragInputEndedConn = UserInputService.InputEnded:Connect(function(input)
		if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			dragInput = nil
		end
	end)

	local guiAlive = true
	local animClock = 0
	local sheenTimer = 0
	local animConn = RunService.Heartbeat:Connect(function(dt)
		if not guiAlive then
			return
		end
		animClock = animClock + dt
		sheenTimer = sheenTimer + dt
		topAccentGrad.Offset = Vector2.new(math.sin(animClock * 1.85) * 0.48, 0)
		borderStrokeGrad.Rotation = (animClock * 42) % 360
		outerGlowGrad.Rotation = -(animClock * 36) % 360

		local pulse = (math.sin(animClock * 3.2) + 1) * 0.5
		statusDotRing.Size = UDim2.new(0, 12 + pulse * 5, 0, 12 + pulse * 5)
		statusDotRing.BackgroundTransparency = 0.72 + pulse * 0.2
		outerGlowStroke.Transparency = 0.65 + pulse * 0.16

		if sheenTimer >= 4.2 then
			sheenTimer = 0
			sweepButtonSheen(submitSheen)
		end
	end)

	screenGui.Destroying:Connect(function()
		guiAlive = false
		uiClosed = true
		if animConn then
			animConn:Disconnect()
		end
		if dragInputBeganConn then
			dragInputBeganConn:Disconnect()
		end
		if dragInputChangedConn then
			dragInputChangedConn:Disconnect()
		end
		if dragInputEndedConn then
			dragInputEndedConn:Disconnect()
		end
	end)

	local shakeToken = 0
	local function shakeInputBox()
		shakeToken = shakeToken + 1
		local currentToken = shakeToken
		task.spawn(function()
			local offsets = { -9, 9, -6, 6, -3, 3, 0 }
			local shakeStepInfo = TweenInfo.new(0.035, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(keyBoxStroke, TweenInfo.new(0.08), { Color = Color3.fromRGB(255, 92, 92), Transparency = 0.1 }):Play()
			TweenService:Create(focusBar, TweenInfo.new(0.08), { BackgroundColor3 = Color3.fromRGB(255, 92, 92), Size = UDim2.new(1, -18, 0, 2) }):Play()
			for _, xOffset in ipairs(offsets) do
				if not guiAlive or shakeToken ~= currentToken then
					return
				end
				local twn = TweenService:Create(keyBox, shakeStepInfo, { Position = UDim2.new(0, xOffset, 0, 0) })
				twn:Play()
				twn.Completed:Wait()
			end
			if guiAlive and shakeToken == currentToken then
				keyBox.Position = UDim2.new(0, 0, 0, 0)
				local isFoc = keyBox:IsFocused()
				TweenService:Create(keyBoxStroke, TweenInfo.new(0.22), {
					Color = Color3.fromRGB(255, 255, 255),
					Transparency = isFoc and 0.08 or 0.62,
				}):Play()
				TweenService:Create(focusBar, TweenInfo.new(0.22), {
					BackgroundColor3 = Color3.fromRGB(255, 255, 255),
					Size = isFoc and UDim2.new(1, -18, 0, 2) or UDim2.new(0, 0, 0, 2),
				}):Play()
			end
		end)
	end

	local function setStatus(text, color)
		if guiAlive and statusLabel then
			local targetCol = color or Color3.fromRGB(245, 245, 255)
			statusLabel.Text = text
			statusLabel.Position = UDim2.new(0, 22, 0, 12)
			TweenService:Create(statusLabel, TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
				Position = UDim2.new(0, 18, 0, 12),
				TextColor3 = targetCol,
			}):Play()
			TweenService:Create(statusDot, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = targetCol,
			}):Play()
			TweenService:Create(statusDotRing, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				BackgroundColor3 = targetCol,
			}):Play()
		end
	end

	local function fadeOutAndDestroy(waitCompletion)
		if not guiAlive then
			return
		end
		guiAlive = false
		if animConn then
			animConn:Disconnect()
			animConn = nil
		end
		local outInfo = TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.In)
		local scaleTween = TweenService:Create(mainScale, outInfo, { Scale = 0.88 })
		TweenService:Create(rootHolder, outInfo, { Position = UDim2.new(rootHolder.Position.X.Scale, rootHolder.Position.X.Offset, rootHolder.Position.Y.Scale, rootHolder.Position.Y.Offset + 8) }):Play()
		scaleTween:Play()

		for _, desc in ipairs(rootHolder:GetDescendants()) do
			if desc:IsA("TextLabel") or desc:IsA("TextButton") or desc:IsA("TextBox") then
				TweenService:Create(desc, outInfo, { TextTransparency = 1, BackgroundTransparency = 1 }):Play()
			elseif desc:IsA("Frame") then
				TweenService:Create(desc, outInfo, { BackgroundTransparency = 1 }):Play()
			elseif desc:IsA("UIStroke") then
				TweenService:Create(desc, outInfo, { Transparency = 1 }):Play()
			end
		end

		if waitCompletion then
			scaleTween.Completed:Wait()
			if screenGui then
				screenGui:Destroy()
			end
			uiClosed = true
		else
			scaleTween.Completed:Connect(function()
				if screenGui then
					screenGui:Destroy()
				end
				uiClosed = true
			end)
		end
	end

	local isChecking = false
	local copyResetToken = 0

	closeBtn.MouseButton1Click:Connect(function()
		fadeOutAndDestroy(false)
	end)

	local function handleSubmit()
		if isChecking or not guiAlive then
			return
		end

		local enteredKey = trim(keyBox.Text)
		if enteredKey == "" then
			shakeInputBox()
			setStatus("Please enter a key first.", Color3.fromRGB(255, 100, 100))
			return
		end

		isChecking = true
		submitBtn.Text = "Checking..."
		setStatus("Verifying key with FlowAuth...", Color3.fromRGB(220, 224, 235))

		bottomProgress.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		bottomProgress.Size = UDim2.new(0, 0, 0, 2)
		TweenService:Create(bottomProgress, TweenInfo.new(0.35, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Size = UDim2.new(0.65, 0, 0, 2),
		}):Play()

		task.spawn(function()
			local isValid, sessionOrErr = verifyFlowAuthKey(enteredKey)
			if isValid == true then
				safeWriteFile(KEY_FILE, enteredKey)
				persistKeySession(enteredKey)
				local timeTag = "Active"
				if type(sessionOrErr) == "table" then
					if sessionOrErr.isLifetime then
						timeTag = "Lifetime"
					elseif tonumber(sessionOrErr.remainingSeconds) then
						timeTag = formatRemainingTime(sessionOrErr.remainingSeconds, false) .. " left"
					end
				end
				if guiAlive then
					setStatus("Key Valid (" .. timeTag .. ")! Loading script...", Color3.fromRGB(90, 255, 150))
					TweenService:Create(bottomProgress, TweenInfo.new(0.16, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
						Size = UDim2.new(1, 0, 0, 2),
						BackgroundColor3 = Color3.fromRGB(90, 255, 150),
					}):Play()
					task.wait(0.18)
					fadeOutAndDestroy(true)
				end
				verifiedKeyResult = enteredKey
			else
				if guiAlive then
					shakeInputBox()
					setStatus(fToString(sessionOrErr or "Invalid or expired FlowAuth key."), Color3.fromRGB(255, 100, 100))
					TweenService:Create(bottomProgress, TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
						Size = UDim2.new(0, 0, 0, 2),
						BackgroundColor3 = Color3.fromRGB(255, 100, 100),
					}):Play()
					submitBtn.Text = "Submit"
				end
				isChecking = false
			end
		end)
	end

	submitBtn.MouseButton1Click:Connect(handleSubmit)
	keyBox.FocusLost:Connect(function(enterPressed)
		if enterPressed then
			handleSubmit()
		end
	end)

	getKeyBtn.MouseButton1Click:Connect(function()
		if not guiAlive then
			return
		end
		copyResetToken = copyResetToken + 1
		local currentCopyToken = copyResetToken

		local rewardLink = CONFIG.RewardUrl
		local copied = false
		if type(fSetClipboard) == "function" then
			copied = pcall(fSetClipboard, rewardLink)
		end

		if copied then
			setStatus("FlowAuth key link copied to clipboard!", Color3.fromRGB(90, 255, 150))
			getKeyBtn.Text = "Copied!"
			sweepButtonSheen(getKeySheen)
			sendNotification("Core.xyz", "FlowAuth key link copied to clipboard!", 4)
			task.delay(2, function()
				if guiAlive and copyResetToken == currentCopyToken then
					getKeyBtn.Text = "Get Key"
				end
			end)
		else
			setStatus("Copy link: " .. rewardLink, Color3.fromRGB(255, 200, 90))
			getKeyBtn.Text = "Get Key"
		end
	end)

	local okParent = pcall(function()
		screenGui.Parent = guiParent
	end)
	if okParent then
		headerBar.Position = UDim2.new(0, 0, 0, -10)
		statusLabel.Position = UDim2.new(0, 18, 0, 20)
		inputHolder.Position = UDim2.new(0.5, 0, 0, 58)
		buttonRow.Position = UDim2.new(0, 18, 0, 118)

		TweenService:Create(
			mainScale,
			TweenInfo.new(0.22, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
		TweenService:Create(
			rootHolder,
			TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0.5, 0, 0.5, 0) }
		):Play()
		TweenService:Create(
			headerBar,
			TweenInfo.new(0.18, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0, 0, 0, 2) }
		):Play()
		TweenService:Create(
			statusLabel,
			TweenInfo.new(0.20, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0, 18, 0, 12) }
		):Play()
		TweenService:Create(
			inputHolder,
			TweenInfo.new(0.22, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0.5, 0, 0, 50) }
		):Play()
		TweenService:Create(
			buttonRow,
			TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0, 18, 0, 108) }
		):Play()

		task.delay(0.18, function()
			if guiAlive then
				sweepButtonSheen(submitSheen)
			end
		end)
	else
		screenGui:Destroy()
		return ""
	end

	repeat
		task.wait(0.1)
	until verifiedKeyResult ~= nil or uiClosed

	return verifiedKeyResult or ""
end)

-------------------------------------------------------------------------------
--! Post-Authentication Protected Game Loader (Executes after FlowAuth or Direct)
-------------------------------------------------------------------------------
local SUPPORTED_GAMES = {
	[9294074907] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/One-shot.lua",
	[10766620257] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/BikeForEgg.lua",
	[9641502068] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/Knife.Duels",
	[10770730129] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/Ragdoll-soccer",
}

local SUPPORTED_PLACES = {
	[90568084448279] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/One-shot.lua",
	[74023858073178] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/BikeForEgg.lua",
	[112731528776884] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/Knife.Duels",
	[106931373443671] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/Ragdoll-soccer",
}

local StarterGui = game:GetService("StarterGui")
local HttpService = game:GetService("HttpService")

local function sendNotification(title, text, duration)
	pcall(function()
		StarterGui:SetCore("SendNotification", {
			Title = title,
			Text = text,
			Duration = duration or 5,
		})
	end)
end

-- Sync FlowAuth injected runtime globals (LRM_*) into __CoreXYZ_KeySession & CoreXYZ_KeyMeta.json
pcall(function()
	local envTbl = (type(getgenv) == "function" and getgenv()) or _G
	local now = os.time()
	local existingSession = type(envTbl.__CoreXYZ_KeySession) == "table" and envTbl.__CoreXYZ_KeySession or {}

	local lrmTier = (type(LRM_KeyTier) == "string" and LRM_KeyTier ~= "" and LRM_KeyTier) or existingSession.tier or "free"
	local lrmSec = tonumber(LRM_SecondsLeft)
	local isLife = existingSession.isLifetime == true
	local expAt = existingSession.expiresAt

	if lrmSec ~= nil then
		if lrmSec == math.huge or lrmSec > 315360000 then
			isLife = true
			expAt = nil
		elseif lrmSec > 0 then
			isLife = false
			expAt = now + math.floor(lrmSec)
		end
	end

	local syncedSession = {
		provider = "FlowAuth",
		projectId = 10959,
		loaderHash = "5aadc1854f782322ada05d461c2cb0cd",
		apiToken = "adb858e40cf5dc946478beaa63d0693f51ad4b83ac4bef78",
		key = existingSession.key or (type(readfile) == "function" and pcall(readfile, "CoreXYZ_Key.txt") and select(2, pcall(readfile, "CoreXYZ_Key.txt"))) or "",
		keyId = existingSession.keyId,
		tier = lrmTier,
		isLifetime = isLife,
		expiresAt = expAt,
		remainingSeconds = isLife and math.huge or (expAt and math.max(0, expAt - now) or 86400),
		hasServerExpiry = true,
		activatedAt = existingSession.activatedAt or now,
		verifiedAt = now,
		note = (type(LRM_UserNote) == "string" and LRM_UserNote) or existingSession.note or "",
		claimedBy = (type(LRM_LinkedDiscordID) == "string" and LRM_LinkedDiscordID) or existingSession.claimedBy or "",
	}

	envTbl.__CoreXYZ_KeySession = syncedSession
	if type(writefile) == "function" then
		pcall(writefile, "CoreXYZ_KeyMeta.json", HttpService:JSONEncode({
			provider = "FlowAuth",
			projectId = 10959,
			key = syncedSession.key,
			keyId = syncedSession.keyId,
			tier = syncedSession.tier,
			isLifetime = syncedSession.isLifetime,
			activatedAt = syncedSession.activatedAt,
			expiresAt = syncedSession.expiresAt,
			hasServerExpiry = true,
			verifiedAt = now,
		}))
	end
end)

local targetUrl = SUPPORTED_GAMES[game.GameId] or SUPPORTED_PLACES[game.PlaceId]
if not targetUrl then
	return
end

local fRequest = request
	or http_request
	or syn_request
	or (type(syn) == "table" and syn.request)
	or (type(http) == "table" and http.request)
	or (type(fluxus) == "table" and fluxus.request)

local okFetch, source = pcall(function()
	return game:HttpGet(targetUrl)
end)

if (not okFetch or type(source) ~= "string" or source == "") and type(fRequest) == "function" then
	local okReq, res = pcall(fRequest, { Url = targetUrl, Method = "GET" })
	if okReq and type(res) == "table" and (res.StatusCode == 200 or res.status_code == 200) then
		local body = res.Body or res.body
		if type(body) == "string" and body ~= "" then
			okFetch = true
			source = body
		end
	end
end

if not okFetch or type(source) ~= "string" or source == "" then
	sendNotification("Core.xyz", "Failed to download script payload.", 5)
	return
end

local fn, compileErr = loadstring(source)
if type(fn) ~= "function" then
	sendNotification("Core.xyz", "Failed to compile script: " .. tostring(compileErr), 5)
	return
end

local okExec, execErr = pcall(fn)
if not okExec then
	sendNotification("Core.xyz", "Runtime error: " .. tostring(execErr), 5)
end
