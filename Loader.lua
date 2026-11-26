--// Core.xyz Loader (FlowAuth Auth + Universe ID Gate + Black-Themed Animated White-Glow Key System UI)
if type(flow_preinit) ~= "function" then
	local envTbl = (type(getgenv) == "function" and getgenv()) or _G
	envTbl.flow_preinit = function(cb)
		return cb()
	end
end

flow_preinit(function()

	local CONFIG = {
		ProjectId = 10959,
		LoaderHash = "5aadc1854f782322ada05d461c2cb0cd",
		ScriptLoaderHash = "940f8bacfe9c5b2cda8fa3d058fad0f4",
		ApiToken = "adb858e40cf5dc946478beaa63d0693f51ad4b83ac4bef78",
		RewardUrl = "https://flowauth.net/reward/5aadc1854f782322ada05d461c2cb0cd",
		SupportedGames = {
			[9294074907] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/One-shot.lua",
			[10770730129] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/Ragdoll-soccer",
		},
		SupportedPlaces = {
			[90568084448279] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/One-shot.lua",
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

	local function safeRequest(opts)
		if type(fRequest) == "function" then
			local ok, res = pcall(fRequest, opts)
			if ok and type(res) == "table" then
				return {
					StatusCode = tonumber(res.StatusCode or res.status_code or res.Status or res.status) or 0,
					Body = fToString(res.Body or res.body or ""),
				}
			end
		end
		local okHttp, resHttp = pcall(function()
			return HttpService:RequestAsync({
				Url = opts.Url,
				Method = opts.Method or "GET",
				Headers = opts.Headers or {},
				Body = opts.Body,
			})
		end)
		if okHttp and type(resHttp) == "table" then
			return {
				StatusCode = tonumber(resHttp.StatusCode) or 0,
				Body = fToString(resHttp.Body or ""),
			}
		end
		return nil, "HTTP request function unavailable in this executor."
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

	local function publishVerifiedKey(verifiedKey)
		pcall(function()
			if type(getgenv) == "function" then
				getgenv().script_key = verifiedKey
			end
		end)
		pcall(function()
			_G.script_key = verifiedKey
		end)
		for lv = 1, 6 do
			pcall(function()
				local env = getfenv(lv)
				if type(env) == "table" then
					rawset(env, "script_key", verifiedKey)
				end
			end)
		end
	end

	local function registerGameLauncher(targetUrl)
		local envTbl = (type(getgenv) == "function" and getgenv()) or _G
		envTbl.__CoreXYZ_GameLaunched = false
		envTbl.__CoreXYZ_LaunchGame = function()
			if envTbl.__CoreXYZ_GameLaunched then
				return
			end
			envTbl.__CoreXYZ_GameLaunched = true

			pcall(function()
				local now = fOsTime()
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
						expAt = now + fMathFloor(lrmSec)
					end
				end

				local syncedSession = {
					provider = "FlowAuth",
					projectId = CONFIG.ProjectId,
					loaderHash = CONFIG.LoaderHash,
					apiToken = CONFIG.ApiToken,
					key = existingSession.key or safeReadFile(KEY_FILE) or "",
					keyId = existingSession.keyId,
					tier = lrmTier,
					isLifetime = isLife,
					expiresAt = expAt,
					remainingSeconds = isLife and math.huge or (expAt and math.max(0, expAt - now) or DEFAULT_KEY_DURATION_SECONDS),
					hasServerExpiry = true,
					activatedAt = existingSession.activatedAt or now,
					verifiedAt = now,
					note = (type(LRM_UserNote) == "string" and LRM_UserNote) or existingSession.note or "",
					claimedBy = (type(LRM_LinkedDiscordID) == "string" and LRM_LinkedDiscordID) or existingSession.claimedBy or "",
				}
				envTbl.__CoreXYZ_KeySession = syncedSession

				safeWriteFile(KEY_META_FILE, safeJsonEncode({
					provider = "FlowAuth",
					projectId = CONFIG.ProjectId,
					key = syncedSession.key,
					keyId = syncedSession.keyId,
					tier = syncedSession.tier,
					isLifetime = syncedSession.isLifetime,
					activatedAt = syncedSession.activatedAt,
					expiresAt = syncedSession.expiresAt,
					hasServerExpiry = true,
					verifiedAt = now,
				}))
			end)

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
				sendNotification("Core.xyz", "Failed to compile script: " .. fToString(compileErr), 5)
				return
			end

			local okExec, execErr = pcall(fn)
			if not okExec then
				sendNotification("Core.xyz", "Runtime error: " .. fToString(execErr), 5)
			end
		end

		-- Watchdog fallback: if FlowAuthRuntime takes >4s or is bypassed, still launch the game cleanly
		task.spawn(function()
			task.wait(4)
			if not envTbl.__CoreXYZ_GameLaunched and type(envTbl.__CoreXYZ_LaunchGame) == "function" then
				envTbl.__CoreXYZ_LaunchGame()
			end
		end)
	end

	local function persistKeySession(verifiedKey, targetUrl)
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

		publishVerifiedKey(verifiedKey)
		registerGameLauncher(targetUrl)
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
		bannerHeader.Text = "Core.xyz  •  Unsupported Game"
		bannerHeader.TextColor3 = Color3.fromRGB(255, 255, 255)
		bannerHeader.TextSize = 13
		bannerHeader.Font = Enum.Font.GothamBold
		bannerHeader.TextXAlignment = Enum.TextXAlignment.Left
		bannerHeader.Parent = bannerFrame

		local bannerDesc = Instance.new("TextLabel")
		bannerDesc.Name = "Description"
		bannerDesc.Size = UDim2.new(1, -28, 0, 32)
		bannerDesc.Position = UDim2.new(0, 14, 0, 32)
		bannerDesc.BackgroundTransparency = 1
		bannerDesc.Text = messageText
		bannerDesc.TextColor3 = Color3.fromRGB(175, 175, 185)
		bannerDesc.TextSize = 12
		bannerDesc.Font = Enum.Font.GothamMedium
		bannerDesc.TextXAlignment = Enum.TextXAlignment.Left
		bannerDesc.TextYAlignment = Enum.TextYAlignment.Top
		bannerDesc.TextWrapped = true
		bannerDesc.Parent = bannerFrame

		local okParent = pcall(function()
			bannerGui.Parent = guiParent
		end)
		if not okParent then
			bannerGui:Destroy()
			return
		end

		TweenService:Create(
			bannerFrame,
			TweenInfo.new(0.24, Enum.EasingStyle.Quint, Enum.EasingDirection.Out),
			{ Position = UDim2.new(0.5, 0, 0, 20) }
		):Play()

		task.delay(3.8, function()
			if bannerGui and bannerGui.Parent then
				local outTween = TweenService:Create(
					bannerFrame,
					TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
					{ Position = UDim2.new(0.5, 0, 0, -96) }
				)
				outTween:Play()
				outTween.Completed:Wait()
				pcall(function()
					bannerGui:Destroy()
				end)
			end
		end)
	end

	local targetScriptUrl = CONFIG.SupportedGames[game.GameId] or CONFIG.SupportedPlaces[game.PlaceId]
	if not targetScriptUrl then
		local msg = string.format("This game (GameId: %s) is not supported by Core.xyz.", fToString(game.GameId))
		sendNotification("Core.xyz", msg, 5)
		showUnsupportedBanner(msg)
		error("Core.xyz: Unsupported game.", 0)
	end

	local initialCandidate = ""
	pcall(function()
		local envTbl = (type(getgenv) == "function" and getgenv()) or _G
		if type(envTbl.script_key) == "string" and envTbl.script_key ~= "" then
			initialCandidate = envTbl.script_key
		elseif type(_G.script_key) == "string" and _G.script_key ~= "" then
			initialCandidate = _G.script_key
		end
	end)
	if initialCandidate == "" and type(script_key) == "string" and script_key ~= "" then
		initialCandidate = script_key
	end

	local candidateKey = trim(initialCandidate)
	if candidateKey == "" and safeIsFile(KEY_FILE) then
		candidateKey = trim(safeReadFile(KEY_FILE) or "")
	end

	if candidateKey ~= "" then
		local isValid, _ = verifyFlowAuthKey(candidateKey)
		if isValid then
			safeWriteFile(KEY_FILE, candidateKey)
			persistKeySession(candidateKey, targetScriptUrl)
			return
		else
			safeDeleteFile(KEY_FILE)
			safeDeleteFile(KEY_META_FILE)
		end
	end

	local guiParent = getSafeGuiParent()
	if not guiParent then
		error("Core.xyz: Could not initialize UI container.", 0)
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
	rootHolder.Position = UDim2.new(0.5, 0, 0.5, 16)
	rootHolder.Size = UDim2.new(0, 392, 0, 216)
	rootHolder.BackgroundTransparency = 1
	rootHolder.BorderSizePixel = 0
	rootHolder.Parent = screenGui

	local mainScale = Instance.new("UIScale")
	mainScale.Scale = 0.88
	mainScale.Parent = rootHolder

	local outerGlow = Instance.new("Frame")
	outerGlow.Name = "OuterGlowFrame"
	outerGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	outerGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
	outerGlow.Size = UDim2.new(1, 10, 1, 10)
	outerGlow.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	outerGlow.BackgroundTransparency = 0.72
	outerGlow.BorderSizePixel = 0
	outerGlow.ZIndex = 1
	outerGlow.Parent = rootHolder

	local outerGlowCorner = Instance.new("UICorner")
	outerGlowCorner.CornerRadius = UDim.new(0, 18)
	outerGlowCorner.Parent = outerGlow

	local outerGlowStroke = Instance.new("UIStroke")
	outerGlowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	outerGlowStroke.Thickness = 3.2
	outerGlowStroke.Color = Color3.fromRGB(255, 255, 255)
	outerGlowStroke.Transparency = 0.78
	outerGlowStroke.Parent = outerGlow

	local outerGlowGradient = Instance.new("UIGradient")
	outerGlowGradient.Rotation = 0
	outerGlowGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(120, 120, 130)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 120, 130)),
	})
	outerGlowGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.55),
		NumberSequenceKeypoint.new(0.5, 0.02),
		NumberSequenceKeypoint.new(1, 0.55),
	})
	outerGlowGradient.Parent = outerGlowStroke

	local midGlow = Instance.new("Frame")
	midGlow.Name = "MidGlowFrame"
	midGlow.AnchorPoint = Vector2.new(0.5, 0.5)
	midGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
	midGlow.Size = UDim2.new(1, 4, 1, 4)
	midGlow.BackgroundTransparency = 1
	midGlow.BorderSizePixel = 0
	midGlow.ZIndex = 2
	midGlow.Parent = rootHolder

	local midGlowCorner = Instance.new("UICorner")
	midGlowCorner.CornerRadius = UDim.new(0, 15)
	midGlowCorner.Parent = midGlow

	local midGlowStroke = Instance.new("UIStroke")
	midGlowStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	midGlowStroke.Thickness = 1.6
	midGlowStroke.Color = Color3.fromRGB(255, 255, 255)
	midGlowStroke.Transparency = 0.52
	midGlowStroke.Parent = midGlow

	local mainCard = Instance.new("Frame")
	mainCard.Name = "MainCard"
	mainCard.AnchorPoint = Vector2.new(0.5, 0.5)
	mainCard.Position = UDim2.new(0.5, 0, 0.5, 0)
	mainCard.Size = UDim2.new(1, 0, 1, 0)
	mainCard.BackgroundColor3 = Color3.fromRGB(7, 7, 9)
	mainCard.BorderSizePixel = 0
	mainCard.ClipsDescendants = true
	mainCard.ZIndex = 3
	mainCard.Parent = rootHolder

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 13)
	mainCorner.Parent = mainCard

	local bgGradient = Instance.new("UIGradient")
	bgGradient.Rotation = 135
	bgGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(16, 16, 21)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(8, 8, 11)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(4, 4, 6)),
	})
	bgGradient.Parent = mainCard

	local mainStroke = Instance.new("UIStroke")
	mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	mainStroke.Thickness = 1.5
	mainStroke.Color = Color3.fromRGB(255, 255, 255)
	mainStroke.Transparency = 0.14
	mainStroke.Parent = mainCard

	local strokeGradient = Instance.new("UIGradient")
	strokeGradient.Rotation = 0
	strokeGradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(115, 115, 125)),
		ColorSequenceKeypoint.new(0.25, Color3.fromRGB(190, 190, 205)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.75, Color3.fromRGB(190, 190, 205)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(115, 115, 125)),
	})
	strokeGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.42),
		NumberSequenceKeypoint.new(0.5, 0.0),
		NumberSequenceKeypoint.new(1, 0.42),
	})
	strokeGradient.Parent = mainStroke

	local topAccentLine = Instance.new("Frame")
	topAccentLine.Name = "TopAccentLine"
	topAccentLine.AnchorPoint = Vector2.new(0.5, 0)
	topAccentLine.Position = UDim2.new(0.5, 0, 0, 0)
	topAccentLine.Size = UDim2.new(0.75, 0, 0, 2)
	topAccentLine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	topAccentLine.BackgroundTransparency = 0.25
	topAccentLine.BorderSizePixel = 0
	topAccentLine.ZIndex = 5
	topAccentLine.Parent = mainCard

	local topAccentGrad = Instance.new("UIGradient")
	topAccentGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.2, 0.35),
		NumberSequenceKeypoint.new(0.5, 0),
		NumberSequenceKeypoint.new(0.8, 0.35),
		NumberSequenceKeypoint.new(1, 1),
	})
	topAccentGrad.Parent = topAccentLine

	local headerBar = Instance.new("Frame")
	headerBar.Name = "HeaderBar"
	headerBar.Size = UDim2.new(1, 0, 0, 46)
	headerBar.Position = UDim2.new(0, 0, 0, 2)
	headerBar.BackgroundTransparency = 1
	headerBar.ZIndex = 4
	headerBar.Parent = mainCard

	local statusDot = Instance.new("Frame")
	statusDot.Name = "StatusDot"
	statusDot.AnchorPoint = Vector2.new(0, 0.5)
	statusDot.Position = UDim2.new(0, 18, 0.5, 0)
	statusDot.Size = UDim2.new(0, 8, 0, 8)
	statusDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	statusDot.BorderSizePixel = 0
	statusDot.ZIndex = 5
	statusDot.Parent = headerBar

	local statusDotCorner = Instance.new("UICorner")
	statusDotCorner.CornerRadius = UDim.new(1, 0)
	statusDotCorner.Parent = statusDot

	local statusDotStroke = Instance.new("UIStroke")
	statusDotStroke.Thickness = 2
	statusDotStroke.Color = Color3.fromRGB(255, 255, 255)
	statusDotStroke.Transparency = 0.6
	statusDotStroke.Parent = statusDot

	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "TitleLabel"
	titleLabel.Size = UDim2.new(1, -100, 0, 20)
	titleLabel.Position = UDim2.new(0, 34, 0, 7)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "CORE.XYZ"
	titleLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	titleLabel.TextSize = 15
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 5
	titleLabel.Parent = headerBar

	local subtitleLabel = Instance.new("TextLabel")
	subtitleLabel.Name = "SubtitleLabel"
	subtitleLabel.Size = UDim2.new(1, -100, 0, 14)
	subtitleLabel.Position = UDim2.new(0, 34, 0, 25)
	subtitleLabel.BackgroundTransparency = 1
	subtitleLabel.Text = "FlowAuth Security Gateway"
	subtitleLabel.TextColor3 = Color3.fromRGB(155, 155, 168)
	subtitleLabel.TextSize = 11
	subtitleLabel.Font = Enum.Font.GothamMedium
	subtitleLabel.TextXAlignment = Enum.TextXAlignment.Left
	subtitleLabel.ZIndex = 5
	subtitleLabel.Parent = headerBar

	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -14, 0.5, 0)
	closeBtn.Size = UDim2.new(0, 28, 0, 28)
	closeBtn.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
	closeBtn.BorderSizePixel = 0
	closeBtn.Text = "×"
	closeBtn.TextColor3 = Color3.fromRGB(185, 185, 195)
	closeBtn.TextSize = 18
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.AutoButtonColor = false
	closeBtn.ZIndex = 5
	closeBtn.Parent = headerBar

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 8)
	closeCorner.Parent = closeBtn

	local closeStroke = Instance.new("UIStroke")
	closeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	closeStroke.Thickness = 1
	closeStroke.Color = Color3.fromRGB(255, 255, 255)
	closeStroke.Transparency = 0.84
	closeStroke.Parent = closeBtn

	local divider = Instance.new("Frame")
	divider.Name = "HeaderDivider"
	divider.Size = UDim2.new(1, -36, 0, 1)
	divider.Position = UDim2.new(0, 18, 0, 48)
	divider.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	divider.BackgroundTransparency = 0.88
	divider.BorderSizePixel = 0
	divider.ZIndex = 4
	divider.Parent = mainCard

	local dividerGradient = Instance.new("UIGradient")
	dividerGradient.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 0.8),
		NumberSequenceKeypoint.new(0.5, 0.1),
		NumberSequenceKeypoint.new(1, 0.8),
	})
	dividerGradient.Parent = divider

	local contentArea = Instance.new("Frame")
	contentArea.Name = "ContentArea"
	contentArea.Size = UDim2.new(1, 0, 1, -50)
	contentArea.Position = UDim2.new(0, 0, 0, 50)
	contentArea.BackgroundTransparency = 1
	contentArea.ZIndex = 4
	contentArea.Parent = mainCard

	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Size = UDim2.new(1, -36, 0, 28)
	statusLabel.Position = UDim2.new(0, 18, 0, 12)
	statusLabel.BackgroundTransparency = 1
	statusLabel.Text = "Enter your FlowAuth key below or click Get Key to claim a 24h key."
	statusLabel.TextColor3 = Color3.fromRGB(190, 190, 202)
	statusLabel.TextSize = 12
	statusLabel.Font = Enum.Font.GothamMedium
	statusLabel.TextXAlignment = Enum.TextXAlignment.Left
	statusLabel.TextYAlignment = Enum.TextYAlignment.Center
	statusLabel.TextWrapped = true
	statusLabel.ZIndex = 5
	statusLabel.Parent = contentArea

	local inputHolder = Instance.new("Frame")
	inputHolder.Name = "InputHolder"
	inputHolder.AnchorPoint = Vector2.new(0.5, 0)
	inputHolder.Position = UDim2.new(0.5, 0, 0, 50)
	inputHolder.Size = UDim2.new(1, -36, 0, 42)
	inputHolder.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
	inputHolder.BorderSizePixel = 0
	inputHolder.ZIndex = 5
	inputHolder.Parent = contentArea

	local inputCorner = Instance.new("UICorner")
	inputCorner.CornerRadius = UDim.new(0, 9)
	inputCorner.Parent = inputHolder

	local inputStroke = Instance.new("UIStroke")
	inputStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	inputStroke.Thickness = 1.2
	inputStroke.Color = Color3.fromRGB(255, 255, 255)
	inputStroke.Transparency = 0.76
	inputStroke.Parent = inputHolder

	local keyBox = Instance.new("TextBox")
	keyBox.Name = "KeyInputBox"
	keyBox.Size = UDim2.new(1, -24, 1, 0)
	keyBox.Position = UDim2.new(0, 12, 0, 0)
	keyBox.BackgroundTransparency = 1
	keyBox.Text = ""
	keyBox.PlaceholderText = "Paste your FlowAuth key here..."
	keyBox.PlaceholderColor3 = Color3.fromRGB(105, 105, 118)
	keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
	keyBox.TextSize = 13
	keyBox.Font = Enum.Font.GothamMedium
	keyBox.TextXAlignment = Enum.TextXAlignment.Left
	keyBox.ClearTextOnFocus = false
	keyBox.ZIndex = 6
	keyBox.Parent = inputHolder

	local buttonRow = Instance.new("Frame")
	buttonRow.Name = "ButtonRow"
	buttonRow.Size = UDim2.new(1, -36, 0, 40)
	buttonRow.Position = UDim2.new(0, 18, 0, 108)
	buttonRow.BackgroundTransparency = 1
	buttonRow.ZIndex = 5
	buttonRow.Parent = contentArea

	local submitBtn = Instance.new("TextButton")
	submitBtn.Name = "SubmitButton"
	submitBtn.Size = UDim2.new(0.5, -6, 1, 0)
	submitBtn.Position = UDim2.new(0, 0, 0, 0)
	submitBtn.BackgroundColor3 = Color3.fromRGB(20, 20, 26)
	submitBtn.BorderSizePixel = 0
	submitBtn.Text = "Submit"
	submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	submitBtn.TextSize = 13
	submitBtn.Font = Enum.Font.GothamBold
	submitBtn.AutoButtonColor = false
	submitBtn.ClipsDescendants = true
	submitBtn.ZIndex = 6
	submitBtn.Parent = buttonRow

	local submitCorner = Instance.new("UICorner")
	submitCorner.CornerRadius = UDim.new(0, 9)
	submitCorner.Parent = submitBtn

	local submitStroke = Instance.new("UIStroke")
	submitStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	submitStroke.Thickness = 1.3
	submitStroke.Color = Color3.fromRGB(255, 255, 255)
	submitStroke.Transparency = 0.25
	submitStroke.Parent = submitBtn

	local submitScale = Instance.new("UIScale")
	submitScale.Scale = 1
	submitScale.Parent = submitBtn

	local submitSheen = Instance.new("Frame")
	submitSheen.Name = "Sheen"
	submitSheen.AnchorPoint = Vector2.new(0.5, 0.5)
	submitSheen.Position = UDim2.new(-0.35, 0, 0.5, 0)
	submitSheen.Size = UDim2.new(0, 26, 2.2, 0)
	submitSheen.Rotation = 25
	submitSheen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	submitSheen.BackgroundTransparency = 0.86
	submitSheen.BorderSizePixel = 0
	submitSheen.ZIndex = 7
	submitSheen.Parent = submitBtn

	local getKeyBtn = Instance.new("TextButton")
	getKeyBtn.Name = "GetKeyButton"
	getKeyBtn.Size = UDim2.new(0.5, -6, 1, 0)
	getKeyBtn.Position = UDim2.new(0.5, 6, 0, 0)
	getKeyBtn.BackgroundColor3 = Color3.fromRGB(13, 13, 18)
	getKeyBtn.BorderSizePixel = 0
	getKeyBtn.Text = "Get Key"
	getKeyBtn.TextColor3 = Color3.fromRGB(230, 230, 240)
	getKeyBtn.TextSize = 13
	getKeyBtn.Font = Enum.Font.GothamBold
	getKeyBtn.AutoButtonColor = false
	getKeyBtn.ClipsDescendants = true
	getKeyBtn.ZIndex = 6
	getKeyBtn.Parent = buttonRow

	local getKeyCorner = Instance.new("UICorner")
	getKeyCorner.CornerRadius = UDim.new(0, 9)
	getKeyCorner.Parent = getKeyBtn

	local getKeyStroke = Instance.new("UIStroke")
	getKeyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	getKeyStroke.Thickness = 1.2
	getKeyStroke.Color = Color3.fromRGB(255, 255, 255)
	getKeyStroke.Transparency = 0.62
	getKeyStroke.Parent = getKeyBtn

	local getKeyScale = Instance.new("UIScale")
	getKeyScale.Scale = 1
	getKeyScale.Parent = getKeyBtn

	local getKeySheen = Instance.new("Frame")
	getKeySheen.Name = "Sheen"
	getKeySheen.AnchorPoint = Vector2.new(0.5, 0.5)
	getKeySheen.Position = UDim2.new(-0.35, 0, 0.5, 0)
	getKeySheen.Size = UDim2.new(0, 26, 2.2, 0)
	getKeySheen.Rotation = 25
	getKeySheen.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	getKeySheen.BackgroundTransparency = 0.88
	getKeySheen.BorderSizePixel = 0
	getKeySheen.ZIndex = 7
	getKeySheen.Parent = getKeyBtn

	local bottomProgress = Instance.new("Frame")
	bottomProgress.Name = "BottomProgress"
	bottomProgress.AnchorPoint = Vector2.new(0, 1)
	bottomProgress.Position = UDim2.new(0, 0, 1, 0)
	bottomProgress.Size = UDim2.new(0, 0, 0, 2)
	bottomProgress.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	bottomProgress.BackgroundTransparency = 0.15
	bottomProgress.BorderSizePixel = 0
	bottomProgress.ZIndex = 8
	bottomProgress.Parent = mainCard

	local connections = {}
	local guiAlive = true
	local isChecking = false
	local verifiedKeyResult = nil
	local uiClosed = false
	local copyResetToken = 0

	local function trackConnection(conn)
		if conn then
			connections[#connections + 1] = conn
		end
		return conn
	end

	local function cleanupAllConnections()
		for i = #connections, 1, -1 do
			local c = connections[i]
			connections[i] = nil
			pcall(function()
				c:Disconnect()
			end)
		end
	end

	local function sweepButtonSheen(sheenFrame)
		if not guiAlive or not sheenFrame then
			return
		end
		sheenFrame.Position = UDim2.new(-0.35, 0, 0.5, 0)
		TweenService:Create(
			sheenFrame,
			TweenInfo.new(0.32, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
			{ Position = UDim2.new(1.35, 0, 0.5, 0) }
		):Play()
	end

	local glowAngle = 0
	local pulseClock = 0
	trackConnection(RunService.RenderStepped:Connect(function(dt)
		if not guiAlive then
			return
		end
		glowAngle = (glowAngle + dt * 95) % 360
		pulseClock = pulseClock + dt * 3.2
		local wave = (math.sin(pulseClock) + 1) * 0.5

		strokeGradient.Rotation = glowAngle
		outerGlowGradient.Rotation = (glowAngle + 180) % 360

		outerGlowStroke.Transparency = 0.65 + (wave * 0.20)
		midGlowStroke.Transparency = 0.40 + (wave * 0.22)
		statusDotStroke.Transparency = 0.35 + (wave * 0.45)
	end))

	do
		local dragging = false
		local dragInput = nil
		local dragStart = nil
		local startPos = nil

		trackConnection(headerBar.InputBegan:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
				dragging = true
				dragStart = input.Position
				startPos = rootHolder.Position

				local endedConn
				endedConn = input.Changed:Connect(function()
					if input.UserInputState == Enum.UserInputState.End then
						dragging = false
						if endedConn then
							endedConn:Disconnect()
						end
					end
				end)
				trackConnection(endedConn)
			end
		end))

		trackConnection(headerBar.InputChanged:Connect(function(input)
			if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
				dragInput = input
			end
		end))

		trackConnection(UserInputService.InputChanged:Connect(function(input)
			if input == dragInput and dragging and dragStart and startPos then
				local delta = input.Position - dragStart
				TweenService:Create(
					rootHolder,
					TweenInfo.new(0.06, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
					{
						Position = UDim2.new(
							startPos.X.Scale,
							startPos.X.Offset + delta.X,
							startPos.Y.Scale,
							startPos.Y.Offset + delta.Y
						),
					}
				):Play()
			end
		end))
	end

	local fastHoverInfo = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	local pressInfo = TweenInfo.new(0.07, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	keyBox.Focused:Connect(function()
		if not guiAlive then
			return
		end
		TweenService:Create(inputStroke, fastHoverInfo, {
			Transparency = 0.12,
			Thickness = 1.6,
		}):Play()
		TweenService:Create(inputHolder, fastHoverInfo, {
			BackgroundColor3 = Color3.fromRGB(16, 16, 22),
		}):Play()
	end)

	keyBox.FocusLost:Connect(function()
		if not guiAlive then
			return
		end
		TweenService:Create(inputStroke, fastHoverInfo, {
			Transparency = 0.76,
			Thickness = 1.2,
		}):Play()
		TweenService:Create(inputHolder, fastHoverInfo, {
			BackgroundColor3 = Color3.fromRGB(12, 12, 16),
		}):Play()
	end)

	local function bindButtonAnimations(btn, strokeObj, scaleObj, defaultBg, hoverBg, defaultStrokeTrans, hoverStrokeTrans, sheenObj)
		btn.MouseEnter:Connect(function()
			if not guiAlive then
				return
			end
			TweenService:Create(btn, fastHoverInfo, { BackgroundColor3 = hoverBg }):Play()
			TweenService:Create(strokeObj, fastHoverInfo, { Transparency = hoverStrokeTrans }):Play()
			TweenService:Create(scaleObj, fastHoverInfo, { Scale = 1.02 }):Play()
			if sheenObj then
				sweepButtonSheen(sheenObj)
			end
		end)

		btn.MouseLeave:Connect(function()
			if not guiAlive then
				return
			end
			TweenService:Create(btn, fastHoverInfo, { BackgroundColor3 = defaultBg }):Play()
			TweenService:Create(strokeObj, fastHoverInfo, { Transparency = defaultStrokeTrans }):Play()
			TweenService:Create(scaleObj, fastHoverInfo, { Scale = 1 }):Play()
		end)

		btn.MouseButton1Down:Connect(function()
			if not guiAlive then
				return
			end
			TweenService:Create(scaleObj, pressInfo, { Scale = 0.96 }):Play()
		end)

		btn.MouseButton1Up:Connect(function()
			if not guiAlive then
				return
			end
			TweenService:Create(scaleObj, fastHoverInfo, { Scale = 1.02 }):Play()
		end)
	end

	bindButtonAnimations(
		submitBtn,
		submitStroke,
		submitScale,
		Color3.fromRGB(20, 20, 26),
		Color3.fromRGB(30, 30, 40),
		0.25,
		0.0,
		submitSheen
	)

	bindButtonAnimations(
		getKeyBtn,
		getKeyStroke,
		getKeyScale,
		Color3.fromRGB(13, 13, 18),
		Color3.fromRGB(22, 22, 30),
		0.62,
		0.18,
		getKeySheen
	)

	closeBtn.MouseEnter:Connect(function()
		if not guiAlive then
			return
		end
		TweenService:Create(closeBtn, fastHoverInfo, {
			BackgroundColor3 = Color3.fromRGB(28, 28, 36),
			TextColor3 = Color3.fromRGB(255, 255, 255),
		}):Play()
		TweenService:Create(closeStroke, fastHoverInfo, { Transparency = 0.25 }):Play()
	end)

	closeBtn.MouseLeave:Connect(function()
		if not guiAlive then
			return
		end
		TweenService:Create(closeBtn, fastHoverInfo, {
			BackgroundColor3 = Color3.fromRGB(16, 16, 22),
			TextColor3 = Color3.fromRGB(185, 185, 195),
		}):Play()
		TweenService:Create(closeStroke, fastHoverInfo, { Transparency = 0.84 }):Play()
	end)

	local function setStatus(text, color)
		if not guiAlive then
			return
		end
		statusLabel.Text = text
		TweenService:Create(statusLabel, TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			TextColor3 = color or Color3.fromRGB(190, 190, 202),
		}):Play()
	end

	local function shakeInputBox()
		if not guiAlive then
			return
		end
		local basePos = UDim2.new(0.5, 0, 0, 50)
		TweenService:Create(inputStroke, TweenInfo.new(0.08), {
			Color = Color3.fromRGB(255, 90, 90),
			Transparency = 0.1,
		}):Play()

		local offsets = { -8, 8, -6, 6, -3, 3, 0 }
		for _, offset in ipairs(offsets) do
			if not guiAlive then
				break
			end
			inputHolder.Position = UDim2.new(0.5, offset, 0, 50)
			task.wait(0.025)
		end
		if guiAlive then
			inputHolder.Position = basePos
			TweenService:Create(inputStroke, TweenInfo.new(0.25), {
				Color = Color3.fromRGB(255, 255, 255),
				Transparency = 0.76,
			}):Play()
		end
	end

	local function fadeOutAndDestroy(onDone)
		if not guiAlive then
			return
		end
		guiAlive = false
		cleanupAllConnections()

		local exitTween = TweenService:Create(
			mainScale,
			TweenInfo.new(0.18, Enum.EasingStyle.Back, Enum.EasingDirection.In),
			{ Scale = 0.86 }
		)
		TweenService:Create(
			rootHolder,
			TweenInfo.new(0.18, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
			{ Position = UDim2.new(0.5, 0, 0.5, 16) }
		):Play()
		TweenService:Create(mainCard, TweenInfo.new(0.16), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(mainStroke, TweenInfo.new(0.16), { Transparency = 1 }):Play()
		TweenService:Create(outerGlow, TweenInfo.new(0.16), { BackgroundTransparency = 1 }):Play()
		TweenService:Create(outerGlowStroke, TweenInfo.new(0.16), { Transparency = 1 }):Play()
		TweenService:Create(midGlowStroke, TweenInfo.new(0.16), { Transparency = 1 }):Play()

		exitTween:Play()
		if onDone then
			exitTween.Completed:Wait()
		end
		pcall(function()
			screenGui:Destroy()
		end)
	end

	closeBtn.MouseButton1Click:Connect(function()
		fadeOutAndDestroy(false)
		uiClosed = true
	end)

	local function handleSubmit()
		if isChecking or not guiAlive then
			return
		end

		local enteredKey = trim(keyBox.Text)
		if enteredKey == "" then
			setStatus("Please paste your key before clicking Submit.", Color3.fromRGB(255, 110, 110))
			shakeInputBox()
			return
		end

		isChecking = true
		submitBtn.Text = "Verifying..."
		setStatus("Verifying key with FlowAuth...", Color3.fromRGB(235, 235, 245))
		sweepButtonSheen(submitSheen)

		bottomProgress.Size = UDim2.new(0, 0, 0, 2)
		bottomProgress.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
		TweenService:Create(bottomProgress, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = UDim2.new(0.65, 0, 0, 2),
		}):Play()

		task.spawn(function()
			local valid, sessionOrErr = verifyFlowAuthKey(enteredKey)
			if valid then
				safeWriteFile(KEY_FILE, enteredKey)
				persistKeySession(enteredKey, targetScriptUrl)

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
		error("Core.xyz: Could not display Key System UI.", 0)
	end

	repeat
		task.wait(0.08)
	until verifiedKeyResult ~= nil or uiClosed

	if type(verifiedKeyResult) ~= "string" or verifiedKeyResult == "" then
		error("Core.xyz: Key verification cancelled.", 0)
	end

end)

-------------------------------------------------------------------------------
--! Post-Authentication Protected Game Loader (Executes after FlowAuth or Direct)
-------------------------------------------------------------------------------
local envTbl = (type(getgenv) == "function" and getgenv()) or _G
if type(envTbl.__CoreXYZ_LaunchGame) == "function" then
	envTbl.__CoreXYZ_LaunchGame()
end
