--// Core.xyz Loader (Platoboost Auth + Universe ID Gate + Modern Key System UI)

local CONFIG = {
	ServiceId = 36271,
	Secret = "993b9964-e0c4-4c5d-878b-82cf17ddef9f",
	SupportedGames = {
		[9294074907] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/One-shot.lua",
		[10766620257] = "https://raw.githubusercontent.com/FeykHere/Core.xyz-Private/main/BikeForEgg.lua",
	},
}

local KEY_FILE = "CoreXYZ_Key.txt"
local KEY_META_FILE = "CoreXYZ_KeyMeta.json"
local DEFAULT_KEY_DURATION_SECONDS = 86400

-------------------------------------------------------------------------------
--! Embedded JSON & SHA-256 Cryptography Library (Scoped for 200-Local Safety)
-------------------------------------------------------------------------------
local lEncode, lDecode, lDigest
do
	local a = 2 ^ 32
	local b = a - 1
	local lshift

	local function c(d, e)
		local f, g = 0, 1
		while d ~= 0 or e ~= 0 do
			local h, i = d % 2, e % 2
			local j = (h + i) % 2
			f = f + j * g
			d = math.floor(d / 2)
			e = math.floor(e / 2)
			g = g * 2
		end
		return f % a
	end

	local function k(d, e, l, ...)
		local m
		if e then
			d = d % a
			e = e % a
			m = c(d, e)
			if l then
				m = k(m, l, ...)
			end
			return m
		elseif d then
			return d % a
		else
			return 0
		end
	end

	local function n(d, e, l, ...)
		local m
		if e then
			d = d % a
			e = e % a
			m = (d + e - c(d, e)) / 2
			if l then
				m = n(m, l, ...)
			end
			return m
		elseif d then
			return d % a
		else
			return b
		end
	end

	local function o(p)
		return b - p
	end

	local function q(d, r)
		if r < 0 then
			return lshift(d, -r)
		end
		return math.floor(d % (2 ^ 32) / (2 ^ r))
	end

	local function s(p, r)
		if r > 31 or r < -31 then
			return 0
		end
		return q(p % a, r)
	end

	lshift = function(d, r)
		if r < 0 then
			return s(d, -r)
		end
		return (d * (2 ^ r)) % (2 ^ 32)
	end

	local function t(p, r)
		p = p % a
		r = r % 32
		local u = n(p, 2 ^ r - 1)
		return s(p, r) + lshift(u, 32 - r)
	end

	local v = {
		0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
		0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
		0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
		0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
		0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
		0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
		0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
		0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
	}

	local function w(x)
		return (string.gsub(x, ".", function(l)
			return string.format("%02x", string.byte(l))
		end))
	end

	local function y(z, A)
		local x = ""
		for _ = 1, A do
			local C = z % 256
			x = string.char(C) .. x
			z = (z - C) / 256
		end
		return x
	end

	local function D(x, B)
		local A = 0
		for idx = B, B + 3 do
			A = A * 256 + string.byte(x, idx)
		end
		return A
	end

	local function E(F, G)
		local H = 64 - (G + 9) % 64
		G = y(8 * G, 8)
		F = F .. "\128" .. string.rep("\0", H) .. G
		assert(#F % 64 == 0)
		return F
	end

	local function I(J)
		J[1] = 0x6a09e667
		J[2] = 0xbb67ae85
		J[3] = 0x3c6ef372
		J[4] = 0xa54ff53a
		J[5] = 0x510e527f
		J[6] = 0x9b05688c
		J[7] = 0x1f83d9ab
		J[8] = 0x5be0cd19
		return J
	end

	local function K(F, B, J)
		local L = {}
		for M = 1, 16 do
			L[M] = D(F, B + (M - 1) * 4)
		end
		for M = 17, 64 do
			local N = L[M - 15]
			local O = k(t(N, 7), t(N, 18), s(N, 3))
			N = L[M - 2]
			L[M] = (L[M - 16] + O + L[M - 7] + k(t(N, 17), t(N, 19), s(N, 10))) % a
		end
		local d, e, l, P, Q, R, S, T = J[1], J[2], J[3], J[4], J[5], J[6], J[7], J[8]
		for idx = 1, 64 do
			local O = k(t(d, 2), t(d, 13), t(d, 22))
			local U = k(n(d, e), n(d, l), n(e, l))
			local V = (O + U) % a
			local W = k(t(Q, 6), t(Q, 11), t(Q, 25))
			local X = k(n(Q, R), n(o(Q), S))
			local Y = (T + W + X + v[idx] + L[idx]) % a
			T = S
			S = R
			R = Q
			Q = (P + Y) % a
			P = l
			l = e
			e = d
			d = (Y + V) % a
		end
		J[1] = (J[1] + d) % a
		J[2] = (J[2] + e) % a
		J[3] = (J[3] + l) % a
		J[4] = (J[4] + P) % a
		J[5] = (J[5] + Q) % a
		J[6] = (J[6] + R) % a
		J[7] = (J[7] + S) % a
		J[8] = (J[8] + T) % a
	end

	local function Z(F)
		F = E(F, #F)
		local J = I({})
		for B = 1, #F, 64 do
			K(F, B, J)
		end
		return w(y(J[1], 4) .. y(J[2], 4) .. y(J[3], 4) .. y(J[4], 4) .. y(J[5], 4) .. y(J[6], 4) .. y(J[7], 4) .. y(J[8], 4))
	end

	local encodeValue
	local escapeMap = { ["\\"] = "\\", ['"'] = '"', ["\b"] = "b", ["\f"] = "f", ["\n"] = "n", ["\r"] = "r", ["\t"] = "t" }
	local unescapeMap = { ["/"] = "/" }
	for kChar, vChar in pairs(escapeMap) do
		unescapeMap[vChar] = kChar
	end

	local function escapeChar(ch)
		return "\\" .. (escapeMap[ch] or string.format("u%04x", ch:byte()))
	end

	local function encodeNil()
		return "null"
	end

	local function encodeTable(val, stack)
		local res = {}
		stack = stack or {}
		if stack[val] then
			error("circular reference")
		end
		stack[val] = true
		if rawget(val, 1) ~= nil or next(val) == nil then
			local count = 0
			for key in pairs(val) do
				if type(key) ~= "number" then
					error("invalid table: mixed or invalid key types")
				end
				count = count + 1
			end
			if count ~= #val then
				error("invalid table: sparse array")
			end
			for _, elem in ipairs(val) do
				table.insert(res, encodeValue(elem, stack))
			end
			stack[val] = nil
			return "[" .. table.concat(res, ",") .. "]"
		else
			for key, elem in pairs(val) do
				if type(key) ~= "string" then
					error("invalid table: mixed or invalid key types")
				end
				table.insert(res, encodeValue(key, stack) .. ":" .. encodeValue(elem, stack))
			end
			stack[val] = nil
			return "{" .. table.concat(res, ",") .. "}"
		end
	end

	local function encodeString(val)
		return '"' .. val:gsub('[%z\1-\31\\"]', escapeChar) .. '"'
	end

	local function encodeNumber(val)
		if val ~= val or val <= -math.huge or val >= math.huge then
			error("unexpected number value '" .. tostring(val) .. "'")
		end
		return string.format("%.14g", val)
	end

	local typeMap = {
		["nil"] = encodeNil,
		["table"] = encodeTable,
		["string"] = encodeString,
		["number"] = encodeNumber,
		["boolean"] = tostring,
	}

	encodeValue = function(val, stack)
		local tName = type(val)
		local fn = typeMap[tName]
		if fn then
			return fn(val, stack)
		end
		error("unexpected type '" .. tName .. "'")
	end

	local decodeParse
	local function createSet(...)
		local res = {}
		for idx = 1, select("#", ...) do
			res[select(idx, ...)] = true
		end
		return res
	end

	local spaceChars = createSet(" ", "\t", "\r", "\n")
	local delimChars = createSet(" ", "\t", "\r", "\n", "]", "}", ",")
	local escapeChars = createSet("\\", "/", '"', "b", "f", "n", "r", "t", "u")
	local literals = createSet("true", "false", "null")
	local literalMap = { ["true"] = true, ["false"] = false, ["null"] = nil }

	local function nextChar(str, idx, set, negate)
		for i = idx, #str do
			if set[str:sub(i, i)] ~= negate then
				return i
			end
		end
		return #str + 1
	end

	local function decodeError(str, idx, msg)
		local lineCount = 1
		local colCount = 1
		for i = 1, idx - 1 do
			colCount = colCount + 1
			if str:sub(i, i) == "\n" then
				lineCount = lineCount + 1
				colCount = 1
			end
		end
		error(string.format("%s at line %d col %d", msg, lineCount, colCount))
	end

	local function codepointToUtf8(cp)
		local floor = math.floor
		if cp <= 0x7f then
			return string.char(cp)
		elseif cp <= 0x7ff then
			return string.char(floor(cp / 64) + 192, cp % 64 + 128)
		elseif cp <= 0xffff then
			return string.char(floor(cp / 4096) + 224, floor(cp % 4096 / 64) + 128, cp % 64 + 128)
		elseif cp <= 0x10ffff then
			return string.char(floor(cp / 262144) + 240, floor(cp % 262144 / 4096) + 128, floor(cp % 4096 / 64) + 128, cp % 64 + 128)
		end
		error(string.format("invalid unicode codepoint '%x'", cp))
	end

	local function parseUnicodeEscape(sEsc)
		local n1 = tonumber(sEsc:sub(1, 4), 16)
		local n2 = tonumber(sEsc:sub(7, 10), 16)
		if n2 then
			return codepointToUtf8((n1 - 0xd800) * 0x400 + n2 - 0xdc00 + 0x10000)
		else
			return codepointToUtf8(n1)
		end
	end

	local function parseString(str, i)
		local res = ""
		local j = i + 1
		local kIdx = j
		while j <= #str do
			local x = str:byte(j)
			if x < 32 then
				decodeError(str, j, "control character in string")
			elseif x == 92 then
				res = res .. str:sub(kIdx, j - 1)
				j = j + 1
				local ch = str:sub(j, j)
				if ch == "u" then
					local hex = str:match("^[dD][89aAbB]%x%x\\u%x%x%x%x", j + 1)
						or str:match("^%x%x%x%x", j + 1)
						or decodeError(str, j - 1, "invalid unicode escape in string")
					res = res .. parseUnicodeEscape(hex)
					j = j + #hex
				else
					if not escapeChars[ch] then
						decodeError(str, j - 1, "invalid escape char '" .. ch .. "' in string")
					end
					res = res .. unescapeMap[ch]
				end
				kIdx = j + 1
			elseif x == 34 then
				res = res .. str:sub(kIdx, j - 1)
				return res, j + 1
			end
			j = j + 1
		end
		decodeError(str, i, "expected closing quote for string")
	end

	local function parseNumber(str, i)
		local x = nextChar(str, i, delimChars)
		local sNum = str:sub(i, x - 1)
		local num = tonumber(sNum)
		if not num then
			decodeError(str, i, "invalid number '" .. sNum .. "'")
		end
		return num, x
	end

	local function parseLiteral(str, i)
		local x = nextChar(str, i, delimChars)
		local word = str:sub(i, x - 1)
		if not literals[word] then
			decodeError(str, i, "invalid literal '" .. word .. "'")
		end
		return literalMap[word], x
	end

	local function parseArray(str, i)
		local res = {}
		local idx = 1
		i = i + 1
		while true do
			local x
			i = nextChar(str, i, spaceChars, true)
			if str:sub(i, i) == "]" then
				i = i + 1
				break
			end
			x, i = decodeParse(str, i)
			res[idx] = x
			idx = idx + 1
			i = nextChar(str, i, spaceChars, true)
			local chr = str:sub(i, i)
			i = i + 1
			if chr == "]" then
				break
			end
			if chr ~= "," then
				decodeError(str, i, "expected ']' or ','")
			end
		end
		return res, i
	end

	local function parseObject(str, i)
		local res = {}
		i = i + 1
		while true do
			local key, val
			i = nextChar(str, i, spaceChars, true)
			if str:sub(i, i) == "}" then
				i = i + 1
				break
			end
			if str:sub(i, i) ~= '"' then
				decodeError(str, i, "expected string for key")
			end
			key, i = decodeParse(str, i)
			i = nextChar(str, i, spaceChars, true)
			if str:sub(i, i) ~= ":" then
				decodeError(str, i, "expected ':' after key")
			end
			i = nextChar(str, i + 1, spaceChars, true)
			val, i = decodeParse(str, i)
			res[key] = val
			i = nextChar(str, i, spaceChars, true)
			local chr = str:sub(i, i)
			i = i + 1
			if chr == "}" then
				break
			end
			if chr ~= "," then
				decodeError(str, i, "expected '}' or ','")
			end
		end
		return res, i
	end

	local charFuncMap = {
		['"'] = parseString,
		["0"] = parseNumber,
		["1"] = parseNumber,
		["2"] = parseNumber,
		["3"] = parseNumber,
		["4"] = parseNumber,
		["5"] = parseNumber,
		["6"] = parseNumber,
		["7"] = parseNumber,
		["8"] = parseNumber,
		["9"] = parseNumber,
		["-"] = parseNumber,
		["t"] = parseLiteral,
		["f"] = parseLiteral,
		["n"] = parseLiteral,
		["["] = parseArray,
		["{"] = parseObject,
	}

	decodeParse = function(str, idx)
		local chr = str:sub(idx, idx)
		local fn = charFuncMap[chr]
		if fn then
			return fn(str, idx)
		end
		decodeError(str, idx, "unexpected character '" .. chr .. "'")
	end

	local function decodeJson(str)
		if type(str) ~= "string" then
			error("expected argument of type string, got " .. type(str))
		end
		local res, idx = decodeParse(str, nextChar(str, 1, spaceChars, true))
		idx = nextChar(str, idx, spaceChars, true)
		if idx <= #str then
			decodeError(str, idx, "trailing garbage")
		end
		return res
	end

	lEncode = function(val)
		return encodeValue(val)
	end
	lDecode = decodeJson
	lDigest = Z
end

-------------------------------------------------------------------------------
--! Platoboost Library (Service ID: 36271, useNonce = true, Host Fallback)
-------------------------------------------------------------------------------
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local StarterGui = game:GetService("StarterGui")
local RunService = game:GetService("RunService")

local service = CONFIG.ServiceId
local secret = CONFIG.Secret
local useNonce = true

local onMessage = function(message) end

local requestSending = false
local fSetClipboard = setclipboard or toclipboard or set_clipboard or (type(Clipboard) == "table" and Clipboard.set)
local fRequest = request
	or http_request
	or syn_request
	or (type(syn) == "table" and syn.request)
	or (type(http) == "table" and http.request)
	or (type(fluxus) == "table" and fluxus.request)

local fStringChar = string.char
local fToString = tostring
local fStringSub = string.sub
local fOsTime = os.time
local fMathRandom = math.random
local fMathFloor = math.floor

local fGetHwid = function()
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

local function urlEncode(str)
	return (fToString(str):gsub("[^%w%-_%.~]", function(ch)
		return string.format("%%%02X", string.byte(ch))
	end))
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

local function parseTimestampValue(rawVal)
	if type(rawVal) == "number" then
		if rawVal > 1e12 then
			return fMathFloor(rawVal / 1000)
		end
		if rawVal > 1e9 then
			return fMathFloor(rawVal)
		end
	elseif type(rawVal) == "string" and rawVal ~= "" then
		local asNum = tonumber(rawVal)
		if asNum then
			return parseTimestampValue(asNum)
		end
		if type(DateTime) == "table" and type(DateTime.fromIsoDate) == "function" then
			local okDt, dtObj = pcall(DateTime.fromIsoDate, rawVal)
			if okDt and dtObj and dtObj.UnixTimestamp then
				return dtObj.UnixTimestamp
			end
		end
		local yr, mo, dy, hr, mn, sc = rawVal:match("^(%d%d%d%d)%-(%d%d)%-(%d%d)[T ](%d%d):(%d%d):(%d%d)")
		if yr then
			local okTime, unixTs = pcall(os.time, {
				year = tonumber(yr),
				month = tonumber(mo),
				day = tonumber(dy),
				hour = tonumber(hr),
				min = tonumber(mn),
				sec = tonumber(sc),
			})
			if okTime and unixTs then
				return unixTs
			end
		end
	end
	return nil
end

local function extractPlatoboostExpiry(decoded)
	if type(decoded) ~= "table" then
		return nil
	end
	local now = fOsTime()
	local sources = {}
	if type(decoded.data) == "table" then
		table.insert(sources, decoded.data)
	end
	table.insert(sources, decoded)

	for _, tbl in ipairs(sources) do
		for _, field in ipairs({
			"expiresAt", "expires_at", "expireAt", "expire_at",
			"expiration", "expiry", "validUntil", "valid_until", "resetAt", "reset_at",
		}) do
			local ts = parseTimestampValue(tbl[field])
			if ts and ts > (now - 60) then
				return ts
			end
		end
		for _, field in ipairs({ "secondsLeft", "seconds_left", "remainingSeconds", "ttl", "remaining", "timeLeft", "time_left" }) do
			local secVal = tonumber(tbl[field])
			if secVal and secVal > 0 then
				return now + fMathFloor(secVal)
			end
		end
		for _, field in ipairs({ "minutesLeft", "minutes_left", "remainingMinutes" }) do
			local minVal = tonumber(tbl[field])
			if minVal and minVal > 0 then
				return now + fMathFloor(minVal * 60)
			end
		end
		for _, field in ipairs({ "hoursLeft", "hours_left", "durationHours" }) do
			local hrVal = tonumber(tbl[field])
			if hrVal and hrVal > 0 then
				return now + fMathFloor(hrVal * 3600)
			end
		end
	end
	return nil
end

local generateNonce = function()
	local str = ""
	for _ = 1, 16 do
		str = str .. fStringChar(fMathFloor(fMathRandom() * (122 - 97 + 1)) + 97)
	end
	return str
end

local cachedLink, cachedTime = "", 0
local host = "https://api.platoboost.com"
local hostResolved = false
local lastVerifiedExpiry = nil

local function resolveHost()
	if hostResolved then
		return host
	end
	hostResolved = true

	local n1, n2, n3 = generateNonce(), generateNonce(), generateNonce()
	if n1 == n2 and n2 == n3 then
		onMessage("platoboost nonce error.")
	end

	local primaryRes = safeRequest({
		Url = "https://api.platoboost.com/public/connectivity",
		Method = "GET",
	})
	if primaryRes and (primaryRes.StatusCode == 200 or primaryRes.StatusCode == 429) then
		host = "https://api.platoboost.com"
		return host
	end

	local fallbackRes = safeRequest({
		Url = "https://api.platoboost.net/public/connectivity",
		Method = "GET",
	})
	if fallbackRes and (fallbackRes.StatusCode == 200 or fallbackRes.StatusCode == 429) then
		host = "https://api.platoboost.net"
		return host
	end

	host = "https://api.platoboost.net"
	return host
end

local function cacheLink()
	local activeHost = resolveHost()
	if cachedLink == "" or (cachedTime + (10 * 60)) < fOsTime() then
		local response, reqErr = safeRequest({
			Url = activeHost .. "/public/start",
			Method = "POST",
			Body = lEncode({
				service = service,
				identifier = lDigest(fGetHwid()),
			}),
			Headers = {
				["Content-Type"] = "application/json",
			},
		})

		if not response then
			local msg = reqErr or "Failed to connect to Platoboost."
			onMessage(msg)
			return false, msg
		end

		if response.StatusCode == 200 then
			local okDecode, decoded = pcall(lDecode, response.Body)
			if okDecode and type(decoded) == "table" then
				if decoded.success == true and type(decoded.data) == "table" and decoded.data.url then
					cachedLink = fToString(decoded.data.url)
					cachedTime = fOsTime()
					return true, cachedLink
				else
					local msg = fToString(decoded.message or "Failed to generate link.")
					onMessage(msg)
					return false, msg
				end
			end
		elseif response.StatusCode == 429 then
			local msg = "you are being rate limited, please wait 20 seconds and try again."
			onMessage(msg)
			return false, msg
		end

		local msg = "Failed to cache link."
		onMessage(msg)
		return false, msg
	else
		return true, cachedLink
	end
end

local copyLink = function()
	local success, result = cacheLink()
	if success and type(fSetClipboard) == "function" then
		local copied = pcall(fSetClipboard, result)
		if copied then
			return true, result
		end
		return false, "Clipboard function failed."
	end
	return false, result or "Clipboard function unavailable."
end

local redeemKey = function(key)
	local activeHost = resolveHost()
	local nonce = generateNonce()
	local endpoint = activeHost .. "/public/redeem/" .. fToString(service)

	local body = {
		identifier = lDigest(fGetHwid()),
		key = key,
	}

	if useNonce then
		body.nonce = nonce
	end

	local response, reqErr = safeRequest({
		Url = endpoint,
		Method = "POST",
		Body = lEncode(body),
		Headers = {
			["Content-Type"] = "application/json",
		},
	})

	if not response then
		local msg = reqErr or "Network request failed."
		onMessage(msg)
		return false, msg
	end

	if response.StatusCode == 200 then
		local okDecode, decoded = pcall(lDecode, response.Body)
		if okDecode and type(decoded) == "table" then
			if decoded.success == true then
				if type(decoded.data) == "table" and decoded.data.valid == true then
					if useNonce then
						if decoded.data.hash == lDigest("true-" .. nonce .. "-" .. secret) then
							lastVerifiedExpiry = extractPlatoboostExpiry(decoded)
							return true, "Key redeemed."
						else
							onMessage("failed to verify integrity.")
							return false, "failed to verify integrity."
						end
					else
						lastVerifiedExpiry = extractPlatoboostExpiry(decoded)
						return true, "Key redeemed."
					end
				else
					onMessage("key is invalid.")
					return false, "key is invalid."
				end
			else
				local rawMsg = fToString(decoded.message or "key is invalid.")
				if fStringSub(rawMsg, 1, 27) == "unique constraint violation" then
					local msg = "you already have an active key, please wait for it to expire before redeeming it."
					onMessage(msg)
					return false, msg
				else
					onMessage(rawMsg)
					return false, rawMsg
				end
			end
		end
		onMessage("invalid server response.")
		return false, "invalid server response."
	elseif response.StatusCode == 429 then
		local msg = "you are being rate limited, please wait 20 seconds and try again."
		onMessage(msg)
		return false, msg
	else
		local msg = "server returned an invalid status code, please try again later."
		onMessage(msg)
		return false, msg
	end
end

local verifyKey = function(key)
	if requestSending == true then
		local msg = "a request is already being sent, please slow down."
		onMessage(msg)
		return false, msg
	end
	requestSending = true
	lastVerifiedExpiry = nil

	local activeHost = resolveHost()
	local nonce = generateNonce()
	local endpoint = activeHost
		.. "/public/whitelist/"
		.. fToString(service)
		.. "?identifier="
		.. lDigest(fGetHwid())
		.. "&key="
		.. urlEncode(key)

	if useNonce then
		endpoint = endpoint .. "&nonce=" .. nonce
	end

	local response, reqErr = safeRequest({
		Url = endpoint,
		Method = "GET",
	})

	requestSending = false

	if not response then
		local msg = reqErr or "Network request failed."
		onMessage(msg)
		return false, msg
	end

	if response.StatusCode == 200 then
		local okDecode, decoded = pcall(lDecode, response.Body)
		if okDecode and type(decoded) == "table" then
			if decoded.success == true then
				if type(decoded.data) == "table" and decoded.data.valid == true then
					if useNonce then
						if decoded.data.hash == lDigest("true-" .. nonce .. "-" .. secret) then
							lastVerifiedExpiry = extractPlatoboostExpiry(decoded)
							return true, "Key verified."
						else
							onMessage("failed to verify integrity.")
							return false, "failed to verify integrity."
						end
					else
						lastVerifiedExpiry = extractPlatoboostExpiry(decoded)
						return true, "Key verified."
					end
				else
					if fStringSub(key, 1, 4) == "KEY_" then
						return redeemKey(key)
					else
						onMessage("key is invalid.")
						return false, "key is invalid."
					end
				end
			else
				local msg = fToString(decoded.message or "key is invalid.")
				onMessage(msg)
				return false, msg
			end
		end
		onMessage("invalid server response.")
		return false, "invalid server response."
	elseif response.StatusCode == 429 then
		local msg = "you are being rate limited, please wait 20 seconds and try again."
		onMessage(msg)
		return false, msg
	else
		local msg = "server returned an invalid status code, please try again later."
		onMessage(msg)
		return false, msg
	end
end

local getFlag = function(name)
	local activeHost = resolveHost()
	local nonce = generateNonce()
	local endpoint = activeHost .. "/public/flag/" .. fToString(service) .. "?name=" .. urlEncode(name)

	if useNonce then
		endpoint = endpoint .. "&nonce=" .. nonce
	end

	local response = safeRequest({
		Url = endpoint,
		Method = "GET",
	})

	if response and response.StatusCode == 200 then
		local okDecode, decoded = pcall(lDecode, response.Body)
		if okDecode and type(decoded) == "table" then
			if decoded.success == true and type(decoded.data) == "table" then
				if useNonce then
					if decoded.data.hash == lDigest(fToString(decoded.data.value) .. "-" .. nonce .. "-" .. secret) then
						return decoded.data.value
					else
						onMessage("failed to verify integrity.")
						return nil
					end
				else
					return decoded.data.value
				end
			else
				onMessage(decoded.message or "failed to fetch flag.")
				return nil
			end
		end
	end
	return nil
end

-------------------------------------------------------------------------------
--! Shared Utilities (Notifications, Safe GUI, Filesystem, Session Meta)
-------------------------------------------------------------------------------
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

local function persistKeySession(verifiedKey)
	local now = fOsTime()
	local existingMeta = nil
	if safeIsFile(KEY_META_FILE) then
		local rawMeta = safeReadFile(KEY_META_FILE)
		if rawMeta and rawMeta ~= "" then
			local okMeta, decodedMeta = pcall(lDecode, rawMeta)
			if okMeta and type(decodedMeta) == "table" and decodedMeta.key == verifiedKey then
				existingMeta = decodedMeta
			end
		end
	end

	local activatedAt = (existingMeta and tonumber(existingMeta.activatedAt)) or now
	local hasServerExpiry = lastVerifiedExpiry ~= nil
	local expiresAt = lastVerifiedExpiry

	if not expiresAt then
		if existingMeta and tonumber(existingMeta.expiresAt) and tonumber(existingMeta.expiresAt) > now then
			expiresAt = tonumber(existingMeta.expiresAt)
			hasServerExpiry = existingMeta.hasServerExpiry == true
		else
			expiresAt = activatedAt + DEFAULT_KEY_DURATION_SECONDS
		end
	end

	local sessionData = {
		key = verifiedKey,
		serviceId = CONFIG.ServiceId,
		secret = CONFIG.Secret,
		host = host,
		hwidHash = lDigest(fGetHwid()),
		activatedAt = activatedAt,
		expiresAt = expiresAt,
		hasServerExpiry = hasServerExpiry,
		verifiedAt = now,
	}

	safeWriteFile(KEY_META_FILE, lEncode({
		key = sessionData.key,
		serviceId = sessionData.serviceId,
		activatedAt = sessionData.activatedAt,
		expiresAt = sessionData.expiresAt,
		hasServerExpiry = sessionData.hasServerExpiry,
		verifiedAt = sessionData.verifiedAt,
	}))

	pcall(function()
		local envTbl = (type(getgenv) == "function" and getgenv()) or _G
		envTbl.__CoreXYZ_KeySession = sessionData
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
--! Step 2 — Universe ID Game Support Gate
-------------------------------------------------------------------------------
local targetScriptUrl = CONFIG.SupportedGames[game.GameId]
if not targetScriptUrl then
	sendNotification("Core.xyz", "Game is not Supported!", 5)
	showUnsupportedBanner("Game is not Supported!")
	return
end

-------------------------------------------------------------------------------
--! Step 3 — Saved Key Auto-Validation (ONLY if Game IS Supported)
-------------------------------------------------------------------------------
local initialStatusText = "Enter your key to continue."
local initialStatusColor = Color3.fromRGB(185, 188, 200)

if safeIsFile(KEY_FILE) then
	local rawSaved = safeReadFile(KEY_FILE)
	local savedKey = trim(rawSaved)
	if savedKey ~= "" then
		local isValidSaved = verifyKey(savedKey)
		if isValidSaved == true then
			persistKeySession(savedKey)
			sendNotification("Core.xyz", "Key verified! Loading script...", 4)
			executeTargetScript(targetScriptUrl)
			return
		else
			safeDeleteFile(KEY_FILE)
			safeDeleteFile(KEY_META_FILE)
			sendNotification("Core.xyz", "Your Saved key is Invalid/Expired.", 5)
			initialStatusText = "Your Saved key is Invalid/Expired."
			initialStatusColor = Color3.fromRGB(255, 100, 100)
		end
	end
end

-------------------------------------------------------------------------------
--! Step 4 — Modern Monochrome Key System UI
-------------------------------------------------------------------------------
local function openKeySystemUI()
	local guiParent = getSafeGuiParent()
	if not guiParent then
		return
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
	rootHolder.Position = UDim2.new(0.5, 0, 0.5, 0)
	rootHolder.Size = UDim2.new(0, 404, 0, 212)
	rootHolder.BackgroundTransparency = 1
	rootHolder.BorderSizePixel = 0
	rootHolder.Parent = screenGui

	local mainScale = Instance.new("UIScale")
	mainScale.Scale = 0.92
	mainScale.Parent = rootHolder

	-- Soft Layered Ambient Drop Shadow
	local shadowOuter = Instance.new("Frame")
	shadowOuter.Name = "ShadowOuter"
	shadowOuter.AnchorPoint = Vector2.new(0.5, 0.5)
	shadowOuter.Position = UDim2.new(0.5, 0, 0.5, 4)
	shadowOuter.Size = UDim2.new(1, 16, 1, 16)
	shadowOuter.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
	shadowOuter.BackgroundTransparency = 0.58
	shadowOuter.BorderSizePixel = 0
	shadowOuter.ZIndex = 1
	shadowOuter.Parent = rootHolder
	local shadowCorner = Instance.new("UICorner")
	shadowCorner.CornerRadius = UDim.new(0, 16)
	shadowCorner.Parent = shadowOuter

	local mainFrame = Instance.new("Frame")
	mainFrame.Name = "MainContainer"
	mainFrame.Size = UDim2.new(1, 0, 1, 0)
	mainFrame.Position = UDim2.new(0, 0, 0, 0)
	mainFrame.BackgroundColor3 = Color3.fromRGB(13, 13, 17)
	mainFrame.BorderSizePixel = 0
	mainFrame.ClipsDescendants = true
	mainFrame.ZIndex = 2
	mainFrame.Parent = rootHolder

	local mainCorner = Instance.new("UICorner")
	mainCorner.CornerRadius = UDim.new(0, 12)
	mainCorner.Parent = mainFrame

	local mainGrad = Instance.new("UIGradient")
	mainGrad.Rotation = 90
	mainGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(20, 20, 26)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 13)),
	})
	mainGrad.Parent = mainFrame

	local mainStroke = Instance.new("UIStroke")
	mainStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	mainStroke.Thickness = 1
	mainStroke.Color = Color3.fromRGB(255, 255, 255)
	mainStroke.Transparency = 0.72
	mainStroke.Parent = mainFrame

	-- Top Shimmer Accent Line
	local topAccent = Instance.new("Frame")
	topAccent.Name = "TopAccent"
	topAccent.Position = UDim2.new(0, 0, 0, 0)
	topAccent.Size = UDim2.new(1, 0, 0, 2)
	topAccent.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	topAccent.BorderSizePixel = 0
	topAccent.ZIndex = 5
	topAccent.Parent = mainFrame

	local topAccentGrad = Instance.new("UIGradient")
	topAccentGrad.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(45, 45, 56)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(45, 45, 56)),
	})
	topAccentGrad.Parent = topAccent

	-- 1. Clean Top Header Bar
	local headerBar = Instance.new("Frame")
	headerBar.Name = "HeaderBar"
	headerBar.Position = UDim2.new(0, 0, 0, 2)
	headerBar.Size = UDim2.new(1, 0, 0, 44)
	headerBar.BackgroundTransparency = 1
	headerBar.BorderSizePixel = 0
	headerBar.Active = true
	headerBar.ZIndex = 3
	headerBar.Parent = mainFrame

	local statusDot = Instance.new("Frame")
	statusDot.Name = "StatusDot"
	statusDot.AnchorPoint = Vector2.new(0, 0.5)
	statusDot.Position = UDim2.new(0, 18, 0.5, 0)
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
	titleLabel.Position = UDim2.new(0, 34, 0, 0)
	titleLabel.Size = UDim2.new(1, -86, 1, 0)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.Text = "CORE.XYZ"
	titleLabel.TextSize = 15
	titleLabel.TextColor3 = Color3.fromRGB(248, 248, 252)
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.ZIndex = 4
	titleLabel.Parent = headerBar

	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseButton"
	closeBtn.AnchorPoint = Vector2.new(1, 0.5)
	closeBtn.Position = UDim2.new(1, -14, 0.5, 0)
	closeBtn.Size = UDim2.new(0, 26, 0, 26)
	closeBtn.BackgroundColor3 = Color3.fromRGB(24, 24, 31)
	closeBtn.BorderSizePixel = 0
	closeBtn.AutoButtonColor = false
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Text = "X"
	closeBtn.TextSize = 11
	closeBtn.TextColor3 = Color3.fromRGB(190, 194, 206)
	closeBtn.ZIndex = 4
	closeBtn.Parent = headerBar

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(0, 6)
	closeCorner.Parent = closeBtn

	local closeStroke = Instance.new("UIStroke")
	closeStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	closeStroke.Thickness = 1
	closeStroke.Color = Color3.fromRGB(54, 54, 66)
	closeStroke.Parent = closeBtn

	local headerDivider = Instance.new("Frame")
	headerDivider.Name = "HeaderDivider"
	headerDivider.Position = UDim2.new(0, 18, 0, 46)
	headerDivider.Size = UDim2.new(1, -36, 0, 1)
	headerDivider.BackgroundColor3 = Color3.fromRGB(64, 64, 78)
	headerDivider.BorderSizePixel = 0
	headerDivider.ZIndex = 3
	headerDivider.Parent = mainFrame

	local divGrad = Instance.new("UIGradient")
	divGrad.Transparency = NumberSequence.new({
		NumberSequenceKeypoint.new(0, 1),
		NumberSequenceKeypoint.new(0.15, 0.2),
		NumberSequenceKeypoint.new(0.85, 0.2),
		NumberSequenceKeypoint.new(1, 1),
	})
	divGrad.Parent = headerDivider

	-- Body Container
	local bodyFrame = Instance.new("Frame")
	bodyFrame.Name = "Body"
	bodyFrame.Position = UDim2.new(0, 0, 0, 47)
	bodyFrame.Size = UDim2.new(1, 0, 1, -47)
	bodyFrame.BackgroundTransparency = 1
	bodyFrame.BorderSizePixel = 0
	bodyFrame.ZIndex = 3
	bodyFrame.Parent = mainFrame

	-- 2. Live Status Label
	local statusLabel = Instance.new("TextLabel")
	statusLabel.Name = "StatusLabel"
	statusLabel.Position = UDim2.new(0, 18, 0, 14)
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

	-- 3. Sleek Key Input Box
	local inputHolder = Instance.new("Frame")
	inputHolder.Name = "InputHolder"
	inputHolder.Position = UDim2.new(0, 18, 0, 52)
	inputHolder.Size = UDim2.new(1, -36, 0, 44)
	inputHolder.BackgroundTransparency = 1
	inputHolder.BorderSizePixel = 0
	inputHolder.ZIndex = 4
	inputHolder.Parent = bodyFrame

	local keyBox = Instance.new("TextBox")
	keyBox.Name = "KeyInput"
	keyBox.Position = UDim2.new(0, 0, 0, 0)
	keyBox.Size = UDim2.new(1, 0, 1, 0)
	keyBox.BackgroundColor3 = Color3.fromRGB(16, 16, 22)
	keyBox.BorderSizePixel = 0
	keyBox.Font = Enum.Font.Code
	keyBox.Text = ""
	keyBox.PlaceholderText = "Paste key here..."
	keyBox.PlaceholderColor3 = Color3.fromRGB(115, 118, 130)
	keyBox.TextColor3 = Color3.fromRGB(248, 248, 252)
	keyBox.TextSize = 14
	keyBox.TextXAlignment = Enum.TextXAlignment.Left
	keyBox.ClearTextOnFocus = false
	keyBox.ClipsDescendants = true
	keyBox.ZIndex = 5
	keyBox.Parent = inputHolder

	local keyBoxCorner = Instance.new("UICorner")
	keyBoxCorner.CornerRadius = UDim.new(0, 8)
	keyBoxCorner.Parent = keyBox

	local keyBoxPadding = Instance.new("UIPadding")
	keyBoxPadding.PaddingLeft = UDim.new(0, 12)
	keyBoxPadding.PaddingRight = UDim.new(0, 12)
	keyBoxPadding.Parent = keyBox

	local keyBoxStroke = Instance.new("UIStroke")
	keyBoxStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	keyBoxStroke.Thickness = 1
	keyBoxStroke.Color = Color3.fromRGB(56, 56, 70)
	keyBoxStroke.Parent = keyBox

	keyBox.Focused:Connect(function()
		TweenService:Create(keyBox, TweenInfo.new(0.16), { BackgroundColor3 = Color3.fromRGB(21, 21, 29) }):Play()
		TweenService:Create(keyBoxStroke, TweenInfo.new(0.16), { Color = Color3.fromRGB(255, 255, 255) }):Play()
	end)
	keyBox.FocusLost:Connect(function()
		TweenService:Create(keyBox, TweenInfo.new(0.18), { BackgroundColor3 = Color3.fromRGB(16, 16, 22) }):Play()
		TweenService:Create(keyBoxStroke, TweenInfo.new(0.18), { Color = Color3.fromRGB(56, 56, 70) }):Play()
	end)

	-- 4. Button Row with EXACTLY 2 Modern Animated Buttons ("Submit" & "Get Key")
	local buttonRow = Instance.new("Frame")
	buttonRow.Name = "ButtonRow"
	buttonRow.Position = UDim2.new(0, 18, 0, 110)
	buttonRow.Size = UDim2.new(1, -36, 0, 40)
	buttonRow.BackgroundTransparency = 1
	buttonRow.BorderSizePixel = 0
	buttonRow.ZIndex = 4
	buttonRow.Parent = bodyFrame

	local submitBtn = Instance.new("TextButton")
	submitBtn.Name = "SubmitButton"
	submitBtn.AnchorPoint = Vector2.new(0.5, 0.5)
	submitBtn.Position = UDim2.new(0.25, -5, 0.5, 0)
	submitBtn.Size = UDim2.new(0.5, -10, 1, 0)
	submitBtn.BackgroundColor3 = Color3.fromRGB(242, 242, 248)
	submitBtn.BorderSizePixel = 0
	submitBtn.AutoButtonColor = false
	submitBtn.Font = Enum.Font.GothamBold
	submitBtn.Text = "Submit"
	submitBtn.TextSize = 13
	submitBtn.TextColor3 = Color3.fromRGB(10, 10, 14)
	submitBtn.ZIndex = 5
	submitBtn.Parent = buttonRow

	local submitCorner = Instance.new("UICorner")
	submitCorner.CornerRadius = UDim.new(0, 8)
	submitCorner.Parent = submitBtn

	local submitStroke = Instance.new("UIStroke")
	submitStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	submitStroke.Thickness = 1
	submitStroke.Color = Color3.fromRGB(255, 255, 255)
	submitStroke.Transparency = 0.25
	submitStroke.Parent = submitBtn

	local getKeyBtn = Instance.new("TextButton")
	getKeyBtn.Name = "GetKeyButton"
	getKeyBtn.AnchorPoint = Vector2.new(0.5, 0.5)
	getKeyBtn.Position = UDim2.new(0.75, 5, 0.5, 0)
	getKeyBtn.Size = UDim2.new(0.5, -10, 1, 0)
	getKeyBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 29)
	getKeyBtn.BorderSizePixel = 0
	getKeyBtn.AutoButtonColor = false
	getKeyBtn.Font = Enum.Font.GothamBold
	getKeyBtn.Text = "Get Key"
	getKeyBtn.TextSize = 13
	getKeyBtn.TextColor3 = Color3.fromRGB(242, 242, 248)
	getKeyBtn.ZIndex = 5
	getKeyBtn.Parent = buttonRow

	local getKeyCorner = Instance.new("UICorner")
	getKeyCorner.CornerRadius = UDim.new(0, 8)
	getKeyCorner.Parent = getKeyBtn

	local getKeyStroke = Instance.new("UIStroke")
	getKeyStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	getKeyStroke.Thickness = 1
	getKeyStroke.Color = Color3.fromRGB(66, 66, 82)
	getKeyStroke.Parent = getKeyBtn

	-- Live Button Animations
	local function attachStyledButton(button, strokeObj, styleCfg)
		local btnScale = Instance.new("UIScale")
		btnScale.Scale = 1
		btnScale.Parent = button

		local hoverInfo = TweenInfo.new(0.16, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local clickInfo = TweenInfo.new(0.08, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
		local isHovered = false
		local cTween, stTween, scTween

		local function playColors(bg, txt, brd)
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
				stTween = TweenService:Create(strokeObj, hoverInfo, { Color = brd })
				stTween:Play()
			end
		end

		local function playScale(target)
			if scTween then
				scTween:Cancel()
			end
			scTween = TweenService:Create(btnScale, clickInfo, { Scale = target })
			scTween:Play()
		end

		button.MouseEnter:Connect(function()
			isHovered = true
			playColors(styleCfg.HoverBg, styleCfg.HoverText, styleCfg.HoverBorder)
		end)

		button.MouseLeave:Connect(function()
			isHovered = false
			playScale(1)
			playColors(styleCfg.RestBg, styleCfg.RestText, styleCfg.RestBorder)
		end)

		button.MouseButton1Down:Connect(function()
			playScale(0.95)
			playColors(styleCfg.PressBg, styleCfg.PressText, styleCfg.HoverBorder)
		end)

		button.MouseButton1Up:Connect(function()
			playScale(1)
			if isHovered then
				playColors(styleCfg.HoverBg, styleCfg.HoverText, styleCfg.HoverBorder)
			else
				playColors(styleCfg.RestBg, styleCfg.RestText, styleCfg.RestBorder)
			end
		end)
	end

	attachStyledButton(submitBtn, submitStroke, {
		RestBg = Color3.fromRGB(242, 242, 248),
		RestText = Color3.fromRGB(10, 10, 14),
		RestBorder = Color3.fromRGB(255, 255, 255),
		HoverBg = Color3.fromRGB(255, 255, 255),
		HoverText = Color3.fromRGB(0, 0, 0),
		HoverBorder = Color3.fromRGB(255, 255, 255),
		PressBg = Color3.fromRGB(210, 212, 222),
		PressText = Color3.fromRGB(0, 0, 0),
	})

	attachStyledButton(getKeyBtn, getKeyStroke, {
		RestBg = Color3.fromRGB(22, 22, 29),
		RestText = Color3.fromRGB(242, 242, 248),
		RestBorder = Color3.fromRGB(66, 66, 82),
		HoverBg = Color3.fromRGB(255, 255, 255),
		HoverText = Color3.fromRGB(0, 0, 0),
		HoverBorder = Color3.fromRGB(255, 255, 255),
		PressBg = Color3.fromRGB(210, 212, 222),
		PressText = Color3.fromRGB(0, 0, 0),
	})

	attachStyledButton(closeBtn, closeStroke, {
		RestBg = Color3.fromRGB(24, 24, 31),
		RestText = Color3.fromRGB(190, 194, 206),
		RestBorder = Color3.fromRGB(54, 54, 66),
		HoverBg = Color3.fromRGB(255, 255, 255),
		HoverText = Color3.fromRGB(0, 0, 0),
		HoverBorder = Color3.fromRGB(255, 255, 255),
		PressBg = Color3.fromRGB(210, 212, 222),
		PressText = Color3.fromRGB(0, 0, 0),
	})

	-- Draggable Top Header Bar (Mouse + Touch)
	local dragging = false
	local dragInput = nil
	local dragStart = nil
	local startPos = nil

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
			rootHolder.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + delta.X,
				startPos.Y.Scale,
				startPos.Y.Offset + delta.Y
			)
		end
	end)

	local dragInputEndedConn = UserInputService.InputEnded:Connect(function(input)
		if input == dragInput or input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
			dragInput = nil
		end
	end)

	-- Ambient Accent Shimmer + Status Dot Pulse
	local guiAlive = true
	local animClock = 0
	local animConn = RunService.Heartbeat:Connect(function(dt)
		if not guiAlive then
			return
		end
		animClock = animClock + dt
		topAccentGrad.Offset = Vector2.new(math.sin(animClock * 1.7) * 0.48, 0)
		statusDot.BackgroundTransparency = 0.25 + 0.25 * math.sin(animClock * 3.4)
	end)

	screenGui.Destroying:Connect(function()
		guiAlive = false
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

	-- Input Horizontal Shake + Status Helper
	local shakeToken = 0
	local function shakeInputBox()
		shakeToken = shakeToken + 1
		local currentToken = shakeToken
		task.spawn(function()
			local offsets = { -8, 8, -6, 6, -3, 3, 0 }
			local shakeStepInfo = TweenInfo.new(0.04, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
			TweenService:Create(keyBoxStroke, TweenInfo.new(0.08), { Color = Color3.fromRGB(255, 92, 92) }):Play()
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
				local restBorder = keyBox:IsFocused() and Color3.fromRGB(255, 255, 255) or Color3.fromRGB(56, 56, 70)
				TweenService:Create(keyBoxStroke, TweenInfo.new(0.25), { Color = restBorder }):Play()
			end
		end)
	end

	local function setStatus(text, color)
		if guiAlive and statusLabel then
			statusLabel.Text = text
			statusLabel.TextColor3 = color or Color3.fromRGB(240, 240, 246)
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
		local outInfo = TweenInfo.new(0.22, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
		local scaleTween = TweenService:Create(mainScale, outInfo, { Scale = 0.88 })
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
		else
			scaleTween.Completed:Connect(function()
				if screenGui then
					screenGui:Destroy()
				end
			end)
		end
	end

	-- State Locks
	local isChecking = false
	local isFetchingLink = false
	local copyResetToken = 0

	closeBtn.MouseButton1Click:Connect(function()
		fadeOutAndDestroy(false)
	end)

	-- Submit Button Logic
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
		setStatus("Verifying key...", Color3.fromRGB(190, 194, 206))

		task.spawn(function()
			local isValid = verifyKey(enteredKey)

			if isValid == true then
				safeWriteFile(KEY_FILE, enteredKey)
				persistKeySession(enteredKey)
				if guiAlive then
					setStatus("Key Valid! Loading script...", Color3.fromRGB(90, 255, 150))
					task.wait(0.25)
					fadeOutAndDestroy(true)
				end
				executeTargetScript(targetScriptUrl)
			else
				if guiAlive then
					shakeInputBox()
					setStatus("Invalid or wrong key. Key was not saved.", Color3.fromRGB(255, 100, 100))
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

	-- Get Key Button Logic
	getKeyBtn.MouseButton1Click:Connect(function()
		if isFetchingLink or not guiAlive then
			return
		end

		isFetchingLink = true
		copyResetToken = copyResetToken + 1
		local currentCopyToken = copyResetToken
		getKeyBtn.Text = "Fetching..."
		setStatus("Fetching Platoboost key link...", Color3.fromRGB(190, 194, 206))

		task.spawn(function()
			local ok, result = cacheLink()

			if ok and type(result) == "string" and result ~= "" then
				local copied = false
				if type(fSetClipboard) == "function" then
					copied = pcall(fSetClipboard, result)
				end

				if guiAlive then
					if copied then
						setStatus("Platoboost link copied to clipboard!", Color3.fromRGB(90, 255, 150))
						getKeyBtn.Text = "Copied!"
						task.delay(2, function()
							if guiAlive and copyResetToken == currentCopyToken and not isFetchingLink then
								getKeyBtn.Text = "Get Key"
							end
						end)
					else
						setStatus("Clipboard unsupported. Copy URL: " .. result, Color3.fromRGB(255, 100, 100))
						getKeyBtn.Text = "Get Key"
					end
				end
			else
				if guiAlive then
					setStatus(fToString(result or "Failed to fetch Platoboost link."), Color3.fromRGB(255, 100, 100))
					getKeyBtn.Text = "Get Key"
				end
			end

			isFetchingLink = false
		end)
	end)

	-- Parent safely and animate entrance
	local okParent = pcall(function()
		screenGui.Parent = guiParent
	end)
	if okParent then
		TweenService:Create(
			mainScale,
			TweenInfo.new(0.24, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
			{ Scale = 1 }
		):Play()
	else
		screenGui:Destroy()
	end
end

openKeySystemUI()
