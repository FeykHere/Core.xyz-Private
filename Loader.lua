--// Core.xyz Loader (Universe ID & Place ID Game Support Gate)

local CONFIG = {
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

-------------------------------------------------------------------------------
--! Services & HTTP Helpers
-------------------------------------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local StarterGui = game:GetService("StarterGui")

local fToString = tostring
local fRequest = request
	or http_request
	or syn_request
	or (type(syn) == "table" and syn.request)
	or (type(http) == "table" and http.request)
	or (type(fluxus) == "table" and fluxus.request)

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

local function toRawGitHubUrl(url)
	if type(url) ~= "string" then
		return url
	end
	local owner, repo, path = url:match("^https?://github%.com/([^/]+)/([^/]+)/blob/(.+)$")
	if owner and repo and path then
		return string.format("https://raw.githubusercontent.com/%s/%s/%s", owner, repo, path)
	end
	return url
end

local function executeTargetScript(targetUrl)
	local rawUrl = toRawGitHubUrl(targetUrl)
	local okFetch, source = pcall(function()
		return game:HttpGet(rawUrl)
	end)

	if (not okFetch or type(source) ~= "string" or source == "") and type(fRequest) == "function" then
		local res = safeRequest({
			Url = rawUrl,
			Method = "GET",
		})
		if res and res.StatusCode == 200 and type(res.Body) == "string" and res.Body ~= "" then
			okFetch = true
			source = res.Body
		end
	end

	if not okFetch or type(source) ~= "string" or source == "" then
		sendNotification("Core.xyz", "Failed to download script payload.", 5)
		return false
	end

	local fn, compileErr = loadstring(source)
	if type(fn) ~= "function" then
		sendNotification("Core.xyz", "Failed to compile script: " .. fToString(compileErr), 5)
		return false
	end

	local okExec, execErr = pcall(fn)
	if not okExec then
		sendNotification("Core.xyz", "Runtime error: " .. fToString(execErr), 5)
		return false
	end

	return true
end

-------------------------------------------------------------------------------
--! Modern Glassmorphic Toast Banner (Unsupported Game Notification)
-------------------------------------------------------------------------------
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
	bannerFrame.BackgroundColor3 = Color3.fromRGB(12, 12, 16)
	bannerFrame.BorderSizePixel = 0
	bannerFrame.Parent = bannerGui

	local bCorner = Instance.new("UICorner")
	bCorner.CornerRadius = UDim.new(0, 10)
	bCorner.Parent = bannerFrame

	local bStroke = Instance.new("UIStroke")
	bStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	bStroke.Thickness = 1
	bStroke.Color = Color3.fromRGB(64, 64, 78)
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
	bannerHeader.TextColor3 = Color3.fromRGB(245, 245, 250)
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

-------------------------------------------------------------------------------
--! Step 1 — Wait for Game Load
-------------------------------------------------------------------------------
if not game:IsLoaded() then
	game.Loaded:Wait()
end
repeat
	task.wait(0.1)
until game:IsLoaded()

-------------------------------------------------------------------------------
--! Step 2 — Universe ID & Place ID Game Support Gate
-------------------------------------------------------------------------------
local targetScriptUrl = CONFIG.SupportedGames[game.GameId] or (CONFIG.SupportedPlaces and CONFIG.SupportedPlaces[game.PlaceId])
if not targetScriptUrl then
	sendNotification("Core.xyz", "Game is not Supported!", 5)
	showUnsupportedBanner("Game is not Supported!")
	return
end

-------------------------------------------------------------------------------
--! Step 3 — Load Supported Game Script Directly
-------------------------------------------------------------------------------
destroyExistingGui(getSafeGuiParent(), "CoreXYZ_KeySystem")
sendNotification("Core.xyz", "Game supported! Loading script...", 4)
executeTargetScript(targetScriptUrl)
