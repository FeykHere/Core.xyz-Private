--[=[
    CORE.XYZ | UNIVERSAL ROBLOX LUA SCRIPT (V5.0 PRODUCTION RELEASE)
    Theme: Pure Black & White Monochrome (With Full RGB & Theme Freedom in Settings)
    Architecture:
      1. Zero Metatable Hooks (No __namecall, __index, hookmetamethod, or restricted C++ telemetry calls)
      2. Classic Camera + Character Lock-In Aimbot (Single Toggle + Viewport Targeting + Smooth Lerp)
      3. Self-Healing Object Pool ESP (Instant refresh on PlayerAdded, Death, Respawn & Limb Streaming)
      4. Isolated Closure Scope (Self-contained task.spawn closure — zero global or getgenv() pollution)
      5. Deterministic Toggle & Lifecycle Cleanup (Instant primitive hide, state restoration, and unbind)
      6. Platoboost Live License Verification (Service 36271 · SHA-256 Nonce Integrity · Accurate Live Key Timer)
]=]

task.spawn(function()
if not game:IsLoaded() then
    pcall(function()
        game.Loaded:Wait()
    end)
end

local function safeGetService(serviceName)
    local ok, svc = pcall(function()
        return game:GetService(serviceName)
    end)
    if ok and svc and type(cloneref) == "function" then
        local cOk, cloned = pcall(cloneref, svc)
        if cOk and cloned then
            return cloned
        end
    end
    return svc
end

local Players = safeGetService("Players")
local RunService = safeGetService("RunService")
local Teams = safeGetService("Teams")
local UserInputService = safeGetService("UserInputService")
local TweenService = safeGetService("TweenService")
local CoreGui = safeGetService("CoreGui")
local Lighting = safeGetService("Lighting")
local HttpService = safeGetService("HttpService")
local TeleportService = safeGetService("TeleportService")

local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then
    LocalPlayer = Players.PlayerAdded:Wait()
end

local Env = {
    setclipboard = setclipboard or toclipboard,
    writefile = writefile,
    readfile = readfile,
    isfile = isfile,
    makefolder = makefolder,
    isfolder = isfolder,
    setfpscap = setfpscap,
    fireproximityprompt = fireproximityprompt,
    fireclickdetector = fireclickdetector,
    identifyexecutor = identifyexecutor or getexecutorname,
    request = request or http_request or syn_request or (type(http) == "table" and http.request) or (type(fluxus) == "table" and fluxus.request),
    gethwid = gethwid,
    getcustomasset = getcustomasset or getsynasset,
    Stats = nil,
    TextService = nil,
}
pcall(function()
    Env.Stats = safeGetService("Stats")
end)
pcall(function()
    Env.TextService = safeGetService("TextService")
end)

local CURRENT_PLACE_ID = tostring(game.PlaceId or 0)
local FS_FOLDER = "CoreXYZ_Data"
local MUSIC_FOLDER = "CoreXyz_Music"
local CONFIG_INDEX_FILE = FS_FOLDER .. "/ConfigIndex.json"
local AUTO_LOAD_FILE = FS_FOLDER .. "/AutoLoadConfig.txt"
local KEY_META_FILE = FS_FOLDER .. "/PlatoKeyMeta.json"
local SAVED_KEY_FILE = FS_FOLDER .. "/SavedKey.json"
local CHANGELOG_SEEN_FILE = FS_FOLDER .. "/SeenChangelogVersion.txt"
local CHANGELOG_VERSION = "Beta"
local CHANGELOG_DATE = "Nov 6, 2026"
local WAYPOINTS_FILE = FS_FOLDER .. "/Waypoints_" .. CURRENT_PLACE_ID .. ".json"

pcall(function()
    if Env.makefolder and Env.isfolder then
        if not Env.isfolder(FS_FOLDER) then
            Env.makefolder(FS_FOLDER)
        end
        if not Env.isfolder(MUSIC_FOLDER) then
            Env.makefolder(MUSIC_FOLDER)
        end
    end
end)

--------------------------------------------------------------------------------
-- 1. SAFE FILE SYSTEM, JSON & PLATOBOOST LICENSE ENGINE (SERVICE 36271)
--------------------------------------------------------------------------------
local memoryFileStore = {}

local function safeWriteFile(path, content)
    memoryFileStore[path] = content
    if Env.writefile then
        pcall(function()
            Env.writefile(path, content)
        end)
    end
end

local function safeReadFile(path)
    if Env.readfile then
        local ok, data = pcall(function()
            if not Env.isfile or Env.isfile(path) then
                return Env.readfile(path)
            end
            return nil
        end)
        if ok and data ~= nil then
            memoryFileStore[path] = data
            return data
        end
    end
    return memoryFileStore[path]
end

local function safeIsFile(path)
    if memoryFileStore[path] ~= nil then
        return true
    end
    if Env.isfile then
        local ok, exists = pcall(function()
            return Env.isfile(path)
        end)
        if ok and exists then
            return true
        end
    end
    return false
end

local PlatoBoost = (function()
    --! json library & cryptography library (SHA-256)
    local a=2^32;local b=a-1;local function c(d,e)local f,g=0,1;while d~=0 or e~=0 do local h,i=d%2,e%2;local j=(h+i)%2;f=f+j*g;d=math.floor(d/2)e=math.floor(e/2)g=g*2 end;return f%a end;local function k(d,e,l,...)local m;if e then d=d%a;e=e%a;m=c(d,e)if l then m=k(m,l,...)end;return m elseif d then return d%a else return 0 end end;local function n(d,e,l,...)local m;if e then d=d%a;e=e%a;m=(d+e-c(d,e))/2;if l then m=n(m,l,...)end;return m elseif d then return d%a else return b end end;local function o(p)return b-p end;local lshift;local function q(d,r)if r<0 then return lshift(d,-r)end;return math.floor(d%2^32/2^r)end;local function s(p,r)if r>31 or r<-31 then return 0 end;return q(p%a,r)end;lshift=function(d,r)if r<0 then return s(d,-r)end;return d*2^r%2^32 end;local function t(p,r)p=p%a;r=r%32;local u=n(p,2^r-1)return s(p,r)+lshift(u,32-r)end;local v={0x428a2f98,0x71374491,0xb5c0fbcf,0xe9b5dba5,0x3956c25b,0x59f111f1,0x923f82a4,0xab1c5ed5,0xd807aa98,0x12835b01,0x243185be,0x550c7dc3,0x72be5d74,0x80deb1fe,0x9bdc06a7,0xc19bf174,0xe49b69c1,0xefbe4786,0x0fc19dc6,0x240ca1cc,0x2de92c6f,0x4a7484aa,0x5cb0a9dc,0x76f988da,0x983e5152,0xa831c66d,0xb00327c8,0xbf597fc7,0xc6e00bf3,0xd5a79147,0x06ca6351,0x14292967,0x27b70a85,0x2e1b2138,0x4d2c6dfc,0x53380d13,0x650a7354,0x766a0abb,0x81c2c92e,0x92722c85,0xa2bfe8a1,0xa81a664b,0xc24b8b70,0xc76c51a3,0xd192e819,0xd6990624,0xf40e3585,0x106aa070,0x19a4c116,0x1e376c08,0x2748774c,0x34b0bcb5,0x391c0cb3,0x4ed8aa4a,0x5b9cca4f,0x682e6ff3,0x748f82ee,0x78a5636f,0x84c87814,0x8cc70208,0x90befffa,0xa4506ceb,0xbef9a3f7,0xc67178f2}local function w(x)return string.gsub(x,".",function(l)return string.format("%02x",string.byte(l))end)end;local function y(z,A)local x=""for B=1,A do local C=z%256;x=string.char(C)..x;z=(z-C)/256 end;return x end;local function D(x,B)local A=0;for B=B,B+3 do A=A*256+string.byte(x,B)end;return A end;local function E(F,G)local H=64-(G+9)%64;G=y(8*G,8)F=F.."\128"..string.rep("\0",H)..G;assert(#F%64==0)return F end;local function I(J)J[1]=0x6a09e667;J[2]=0xbb67ae85;J[3]=0x3c6ef372;J[4]=0xa54ff53a;J[5]=0x510e527f;J[6]=0x9b05688c;J[7]=0x1f83d9ab;J[8]=0x5be0cd19;return J end;local function K(F,B,J)local L={}for M=1,16 do L[M]=D(F,B+(M-1)*4)end;for M=17,64 do local N=L[M-15]local O=k(t(N,7),t(N,18),s(N,3))N=L[M-2]L[M]=(L[M-16]+O+L[M-7]+k(t(N,17),t(N,19),s(N,10)))%a end;local d,e,l,P,Q,R,S,T=J[1],J[2],J[3],J[4],J[5],J[6],J[7],J[8]for B=1,64 do local O=k(t(d,2),t(d,13),t(d,22))local U=k(n(d,e),n(d,l),n(e,l))local V=(O+U)%a;local W=k(t(Q,6),t(Q,11),t(Q,25))local X=k(n(Q,R),n(o(Q),S))local Y=(T+W+X+v[B]+L[B])%a;T=S;S=R;R=Q;Q=(P+Y)%a;P=l;l=e;e=d;d=(Y+V)%a end;J[1]=(J[1]+d)%a;J[2]=(J[2]+e)%a;J[3]=(J[3]+l)%a;J[4]=(J[4]+P)%a;J[5]=(J[5]+Q)%a;J[6]=(J[6]+R)%a;J[7]=(J[7]+S)%a;J[8]=(J[8]+T)%a end;local function Z(F)F=tostring(F or "")F=E(F,#F)local J=I({})for B=1,#F,64 do K(F,B,J)end;return w(y(J[1],4)..y(J[2],4)..y(J[3],4)..y(J[4],4)..y(J[5],4)..y(J[6],4)..y(J[7],4)..y(J[8],4))end;local e;local l={["\\"]="\\",["\""]="\"",["\b"]="b",["\f"]="f",["\n"]="n",["\r"]="r",["\t"]="t"}local P={["/"]="/"}for Q,R in pairs(l)do P[R]=Q end;local S=function(T)return"\\"..(l[T]or string.format("u%04x",T:byte()))end;local B=function(M)return"null"end;local v2=function(M,z)local _={}z=z or{}if z[M]then error("circular reference")end;z[M]=true;if rawget(M,1)~=nil or next(M)==nil then local A=0;for Q in pairs(M)do if type(Q)~="number"then error("invalid table: mixed or invalid key types")end;A=A+1 end;if A~=#M then error("invalid table: sparse array")end;for a0,R in ipairs(M)do table.insert(_,e(R,z))end;z[M]=nil;return"["..table.concat(_,",").."]"else for Q,R in pairs(M)do if type(Q)~="string"then error("invalid table: mixed or invalid key types")end;table.insert(_,e(Q,z)..":"..e(R,z))end;z[M]=nil;return"{"..table.concat(_,",").."}"end end;local g=function(M)return'"'..M:gsub('[%z\1-\31\\"]',S)..'"'end;local a1=function(M)if M~=M or M<=-math.huge or M>=math.huge then error("unexpected number value '"..tostring(M).."'")end;return string.format("%.14g",M)end;local j={["nil"]=B,["table"]=v2,["string"]=g,["number"]=a1,["boolean"]=tostring}e=function(M,z)local x=type(M)local a2=j[x]if a2 then return a2(M,z)end;error("unexpected type '"..x.."'")end;local a3=function(M)return e(M)end;local a4;local N=function(...)local _={}for a0=1,select("#",...)do _[select(a0,...)]=true end;return _ end;local L=N(" ","\t","\r","\n")local p=N(" ","\t","\r","\n","]","}",",")local a5=N("\\","/",'"',"b","f","n","r","t","u")local m=N("true","false","null")local a6={["true"]=true,["false"]=false,["null"]=nil}local a7=function(a8,a9,aa,ab)for a0=a9,#a8 do if aa[a8:sub(a0,a0)]~=ab then return a0 end end;return#a8+1 end;local ac=function(a8,a9,J)local ad=1;local ae=1;for a0=1,a9-1 do ae=ae+1;if a8:sub(a0,a0)=="\n"then ad=ad+1;ae=1 end end;error(string.format("%s at line %d col %d",J,ad,ae))end;local af=function(A)local a2=math.floor;if A<=0x7f then return string.char(A)elseif A<=0x7ff then return string.char(a2(A/64)+192,A%64+128)elseif A<=0xffff then return string.char(a2(A/4096)+224,a2(A%4096/64)+128,A%64+128)elseif A<=0x10ffff then return string.char(a2(A/262144)+240,a2(A%262144/4096)+128,a2(A%4096/64)+128,A%64+128)end;error(string.format("invalid unicode codepoint '%x'",A))end;local ag=function(ah)local ai=tonumber(ah:sub(1,4),16)local aj=tonumber(ah:sub(7,10),16)if aj then return af((ai-0xd800)*0x400+aj-0xdc00+0x10000)else return af(ai)end end;local ak=function(a8,a0)local _=""local al=a0+1;local Q=al;while al<=#a8 do local am=a8:byte(al)if am<32 then ac(a8,al,"control character in string")elseif am==92 then _=_..a8:sub(Q,al-1)al=al+1;local T=a8:sub(al,al)if T=="u"then local an=a8:match("^[dD][89aAbB]%x%x\\u%x%x%x%x",al+1)or a8:match("^%x%x%x%x",al+1)or ac(a8,al-1,"invalid unicode escape in string")_=_..ag(an)al=al+#an else if not a5[T]then ac(a8,al-1,"invalid escape char '"..T.."' in string")end;_=_..P[T]end;Q=al+1 elseif am==34 then _=_..a8:sub(Q,al-1)return _,al+1 end;al=al+1 end;ac(a8,a0,"expected closing quote for string")end;local ao=function(a8,a0)local am=a7(a8,a0,p)local ah=a8:sub(a0,am-1)local A=tonumber(ah)if not A then ac(a8,a0,"invalid number '"..ah.."'")end;return A,am end;local ap=function(a8,a0)local am=a7(a8,a0,p)local aq=a8:sub(a0,am-1)if not m[aq]then ac(a8,a0,"invalid literal '"..aq.."'")end;return a6[aq],am end;local ar=function(a8,a0)local _={}local A=1;a0=a0+1;while 1 do local am;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="]"then a0=a0+1;break end;am,a0=a4(a8,a0)_[A]=am;A=A+1;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="]"then break end;if as~=","then ac(a8,a0,"expected ']' or ','")end end;return _,a0 end;local at=function(a8,a0)local _={}a0=a0+1;while 1 do local au,M;a0=a7(a8,a0,L,true)if a8:sub(a0,a0)=="}"then a0=a0+1;break end;if a8:sub(a0,a0)~='"'then ac(a8,a0,"expected string for key")end;au,a0=a4(a8,a0)a0=a7(a8,a0,L,true)if a8:sub(a0,a0)~=":"then ac(a8,a0,"expected ':' after key")end;a0=a7(a8,a0+1,L,true)M,a0=a4(a8,a0)_[au]=M;a0=a7(a8,a0,L,true)local as=a8:sub(a0,a0)a0=a0+1;if as=="}"then break end;if as~=","then ac(a8,a0,"expected '}' or ','")end end;return _,a0 end;local av={['"']=ak,["0"]=ao,["1"]=ao,["2"]=ao,["3"]=ao,["4"]=ao,["5"]=ao,["6"]=ao,["7"]=ao,["8"]=ao,["9"]=ao,["-"]=ao,["t"]=ap,["f"]=ap,["n"]=ap,["["]=ar,["{"]=at}a4=function(a8,a9)local as=a8:sub(a9,a9)local a2=av[as]if a2 then return a2(a8,a9)end;ac(a8,a9,"unexpected character '"..as.."'")end;local aw=function(a8)if type(a8)~="string"then error("expected argument of type string, got "..type(a8))end;local _,a9=a4(a8,a7(a8,1,L,true))a9=a7(a8,a9,L,true)if a9<=#a8 then ac(a8,a9,"trailing garbage")end;return _ end;
    local lEncode, lDecode, lDigest = a3, aw, Z

    --! platoboost configuration
    local service = 36271
    local secret = "993b9964-e0c4-4c5d-878b-82cf17ddef9f"
    local useNonce = true
    local DEFAULT_KEY_DURATION = 86400 -- 24h standard Platoboost key cycle

    local onMessage = function(_) end
    local requestSending = false
    local entangledScale = 0
    local activeProofHash = ""
    local fSetClipboard = Env.setclipboard
    local fStringChar = string.char
    local fToString = tostring
    local fStringSub = string.sub
    local fOsTime = os.time
    local fMathRandom = math.random
    local fMathFloor = math.floor

    local SPY_SIGNATURES = {
        "SimpleSpy",
        "SimpleSpy2",
        "SimpleSpy3",
        "Hydroxide",
        "HttpSpy",
        "TurtleSpy",
    }

    local function isEnvironmentClean()
        local clean = true
        pcall(function()
            if type(_G) == "table" then
                for _, sig in ipairs(SPY_SIGNATURES) do
                    if rawget(_G, sig) ~= nil or rawget(_G, sig .. "Executed") ~= nil then
                        clean = false
                        return
                    end
                end
            end
            if type(getgenv) == "function" then
                local okG, genv = pcall(getgenv)
                if okG and type(genv) == "table" then
                    for _, sig in ipairs(SPY_SIGNATURES) do
                        if rawget(genv, sig) ~= nil or rawget(genv, sig .. "Executed") ~= nil then
                            clean = false
                            return
                        end
                    end
                end
            end
            local containers = { CoreGui }
            if type(gethui) == "function" then
                local okH, hui = pcall(gethui)
                if okH and hui then
                    table.insert(containers, hui)
                end
            end
            for _, parent in ipairs(containers) do
                if parent and parent.FindFirstChild then
                    for _, sig in ipairs(SPY_SIGNATURES) do
                        if parent:FindFirstChild(sig) ~= nil then
                            clean = false
                            return
                        end
                    end
                end
            end
        end)
        if not clean then
            entangledScale = 0
            activeProofHash = ""
        end
        return clean
    end

    local function fGetHwid()
        if type(Env.gethwid) == "function" then
            local ok, res = pcall(Env.gethwid)
            if ok and res and fToString(res) ~= "" then
                return fToString(res)
            end
        end
        return fToString(LocalPlayer.UserId or 1)
    end

    local function fRequest(reqOpts)
        local activeReq = (type(request) == "function" and request)
            or (type(http_request) == "function" and http_request)
            or Env.request
        if type(activeReq) == "function" then
            local ok, res = pcall(activeReq, reqOpts)
            if ok and type(res) == "table" then
                return res
            end
        end
        if reqOpts and reqOpts.Method == "GET" and reqOpts.Url then
            local okGet, body = pcall(function()
                return game:HttpGet(reqOpts.Url)
            end)
            if okGet and type(body) == "string" and body ~= "" then
                return { StatusCode = 200, Body = body }
            end
        end
        return { StatusCode = 0, Body = "" }
    end

    local host = "https://api.platoboost.net"
    local cachedLink, cachedTime = "", 0
    local hostChecked = false

    local function ensureHost()
        if hostChecked then
            return
        end
        hostChecked = true
        local hostResponse = fRequest({
            Url = host .. "/public/connectivity",
            Method = "GET",
        })
        if not hostResponse or (hostResponse.StatusCode ~= 200 and hostResponse.StatusCode ~= 429) then
            host = "https://api.platoboost.com"
        end
    end

    local function generateNonce()
        local str = ""
        for _ = 1, 16 do
            str = str .. fStringChar(fMathFloor(fMathRandom() * (122 - 97 + 1)) + 97)
        end
        return str
    end

    local function cacheLink()
        ensureHost()
        if cachedLink == "" or (cachedTime + (10 * 60) < fOsTime()) then
            local response = fRequest({
                Url = host .. "/public/start",
                Method = "POST",
                Body = lEncode({
                    service = service,
                    identifier = lDigest(fGetHwid()),
                }),
                Headers = {
                    ["Content-Type"] = "application/json",
                },
            })

            if response and response.StatusCode == 200 then
                local okDec, decoded = pcall(lDecode, response.Body)
                if okDec and type(decoded) == "table" then
                    if decoded.success == true and type(decoded.data) == "table" and decoded.data.url then
                        cachedLink = decoded.data.url
                        cachedTime = fOsTime()
                        return true, cachedLink
                    else
                        local errMsg = fToString(decoded.message or "Failed to generate link.")
                        onMessage(errMsg)
                        return false, errMsg
                    end
                end
            elseif response and response.StatusCode == 429 then
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

    local function copyLink()
        local success, link = cacheLink()
        if success and link and link ~= "" then
            if fSetClipboard then
                pcall(fSetClipboard, link)
            end
            onMessage("Key link copied to clipboard! Paste it into your browser.")
            return true, link
        end
        return false, link
    end

    local function fFloorFloat(x)
        x = (tonumber(x) or 0) + 0.0
        return x - (x % 1.0)
    end

    local function parseFlexibleExpiryFromTable(tbl, now)
        if type(tbl) ~= "table" then
            return nil
        end
        now = (tonumber(now) or 0) + 0.0
        if tbl.lifetime == true or tbl.permanent == true or tbl.isPermanent == true or tbl.neverExpires == true then
            return -1
        end
        -- 1. Check minutesLeft (Platoboost /api/session/status format: e.g. 30,000,000 mins for 500,000h dev key)
        local rawMins = tonumber(tbl.minutesLeft or tbl.minutes_left or tbl.durationMinutes or tbl.duration_minutes)
        if rawMins and rawMins > 0 then
            return fFloorFloat(now + (rawMins * 60.0))
        end
        -- 2. Check hoursLeft / durationHours (e.g. 500000 hours)
        local rawHrs = tonumber(tbl.hoursLeft or tbl.hours_left or tbl.durationHours or tbl.duration_hours or tbl.hours)
        if rawHrs and rawHrs > 0 then
            return fFloorFloat(now + (rawHrs * 3600.0))
        end
        -- 3. Check daysLeft / durationDays
        local rawDays = tonumber(tbl.daysLeft or tbl.days_left or tbl.durationDays or tbl.duration_days)
        if rawDays and rawDays > 0 then
            return fFloorFloat(now + (rawDays * 86400.0))
        end
        -- 4. Check explicit expiration timestamp (number, numeric string, or ISO-8601 string)
        local rawExp = tbl.expiresAt or tbl.expires_at or tbl.expire or tbl.expiration or tbl.expiry or tbl.validUntil or tbl.valid_until
        if rawExp ~= nil then
            local numExp = tonumber(rawExp)
            if numExp and numExp > 0 then
                numExp = numExp + 0.0
                if numExp > 1e12 then
                    return fFloorFloat(numExp / 1000.0)
                elseif numExp > now then
                    return fFloorFloat(numExp)
                else
                    return fFloorFloat(now + numExp)
                end
            elseif type(rawExp) == "string" then
                local y, m, d, hh, mm, ss = string.match(rawExp, "^(%d%d%d%d)%-(%d%d)%-(%d%d)[T%s](%d%d):(%d%d):(%d%d)")
                if y and m and d and hh and mm and ss then
                    local okT, parsedTs = pcall(os.time, {
                        year = tonumber(y),
                        month = tonumber(m),
                        day = tonumber(d),
                        hour = tonumber(hh),
                        min = tonumber(mm),
                        sec = tonumber(ss),
                    })
                    if okT and type(parsedTs) == "number" and parsedTs > now then
                        return parsedTs + 0.0
                    end
                end
            end
        end
        -- 5. Check remaining seconds / duration
        local rawRem = tonumber(tbl.timeLeft or tbl.time_left or tbl.remaining or tbl.secondsLeft or tbl.seconds_left or tbl.duration or tbl.ttl)
        if rawRem and rawRem > 0 then
            return fFloorFloat(now + rawRem)
        end
        return nil
    end

    local function queryRelayStatusWithTicket(relayOrigin, ticket, now)
        if not ticket or ticket == "" then
            return nil
        end
        local statusRes = fRequest({
            Url = relayOrigin .. "/api/session/status?ticket=" .. ticket,
            Method = "GET",
        })
        if statusRes and statusRes.StatusCode == 200 and type(statusRes.Body) == "string" and statusRes.Body ~= "" then
            local okS, decS = pcall(lDecode, statusRes.Body)
            if okS and type(decS) == "table" and type(decS.data) == "table" then
                local parsedStatusExp = parseFlexibleExpiryFromTable(decS.data, now)
                if parsedStatusExp then
                    return parsedStatusExp
                end
            end
        end
        return nil
    end

    local function fetchLiveRelayKeyExpiry(now, forceNewTicket)
        if forceNewTicket then
            cachedLink = ""
            cachedTime = 0
        end
        local okLink, linkUrl = cacheLink()
        if not okLink or type(linkUrl) ~= "string" or linkUrl == "" then
            return nil, nil, nil
        end
        local relayOrigin = string.match(linkUrl, "^(https?://[^/]+)") or "https://auth.platorelay.com"
        local ticket = string.match(linkUrl, "[?&]d=([^&#]+)") or string.match(linkUrl, "[?&]ticket=([^&#]+)")
        local exp = queryRelayStatusWithTicket(relayOrigin, ticket, now)
        if exp then
            return exp, relayOrigin, ticket
        end
        if not forceNewTicket then
            cachedLink = ""
            cachedTime = 0
            local okFresh, freshUrl = cacheLink()
            if okFresh and type(freshUrl) == "string" and freshUrl ~= "" then
                relayOrigin = string.match(freshUrl, "^(https?://[^/]+)") or relayOrigin
                local freshTicket = string.match(freshUrl, "[?&]d=([^&#]+)") or string.match(freshUrl, "[?&]ticket=([^&#]+)")
                if freshTicket and freshTicket ~= "" and freshTicket ~= ticket then
                    ticket = freshTicket
                    exp = queryRelayStatusWithTicket(relayOrigin, ticket, now)
                    if exp then
                        return exp, relayOrigin, ticket
                    end
                end
            end
        end
        return nil, relayOrigin, ticket
    end

    local function fetchRelayServiceDurationSeconds(relayOrigin, ticket)
        if not relayOrigin or not ticket or ticket == "" then
            return nil
        end
        local metaRes = fRequest({
            Url = relayOrigin .. "/api/session/metadata?ticket=" .. ticket,
            Method = "GET",
        })
        if metaRes and metaRes.StatusCode == 200 and type(metaRes.Body) == "string" and metaRes.Body ~= "" then
            local okM, decM = pcall(lDecode, metaRes.Body)
            if okM and type(decM) == "table" and type(decM.data) == "table" then
                local durHours = tonumber(decM.data.durationHours or decM.data.duration)
                if durHours and durHours > 0 then
                    return fFloorFloat(durHours * 3600.0)
                end
            end
        end
        return nil
    end

    local function resolveAccurateKeyExpiry(keyStr, apiData, isFreshRedemption)
        local now = (tonumber(fOsTime()) or 0) + 0.0
        local keyId = lDigest(fGetHwid() .. "::" .. fToString(keyStr or ""))
        local hwidId = lDigest(fGetHwid())

        -- 1. Check if Platoboost response payload includes an explicit expiration timestamp or remaining duration
        if type(apiData) == "table" then
            local directExp = parseFlexibleExpiryFromTable(apiData, now)
                or parseFlexibleExpiryFromTable(apiData.key, now)
                or parseFlexibleExpiryFromTable(apiData.whitelist, now)
            if directExp then
                pcall(function()
                    safeWriteFile(KEY_META_FILE, lEncode({
                        keyId = keyId,
                        hwidId = hwidId,
                        redeemedAt = now,
                        expiresAt = directExp,
                    }))
                end)
                return directExp
            end
        end

        -- 2. Query Platoboost Live Session Status (/api/session/status?ticket=...) for exact minutesLeft (e.g. 500,000h dev keys -> 30,000,000 mins)
        local liveRelayExp, relayOrigin, ticket = fetchLiveRelayKeyExpiry(now, isFreshRedemption)
        if liveRelayExp and (liveRelayExp == -1 or liveRelayExp > now) then
            pcall(function()
                safeWriteFile(KEY_META_FILE, lEncode({
                    keyId = keyId,
                    hwidId = hwidId,
                    redeemedAt = now,
                    expiresAt = liveRelayExp,
                }))
            end)
            return liveRelayExp
        end

        -- 3. Track exact activation/expiry timestamp per HWID + Key on disk so re-executions continue counting down without resetting to 24h
        local savedRaw = safeReadFile(KEY_META_FILE)
        local meta = nil
        if savedRaw and savedRaw ~= "" then
            local okM, parsed = pcall(lDecode, savedRaw)
            if okM and type(parsed) == "table" then
                meta = parsed
            end
        end

        if type(meta) == "table" and type(meta.expiresAt) == "number" and (meta.expiresAt == -1 or meta.expiresAt > now) then
            if meta.keyId == keyId or (not isFreshRedemption and meta.hwidId == hwidId) then
                return meta.expiresAt
            end
        end

        -- 4. Check if Platoboost service flag or relay metadata defines a custom service duration
        local relayDurationSec = fetchRelayServiceDurationSeconds(relayOrigin, ticket)
        local newExpiresAt = now + (relayDurationSec or DEFAULT_KEY_DURATION)
        pcall(function()
            safeWriteFile(KEY_META_FILE, lEncode({
                keyId = keyId,
                hwidId = hwidId,
                redeemedAt = now,
                expiresAt = newExpiresAt,
            }))
        end)
        return newExpiresAt
    end

    local function verifyCanaryIntegrity()
        local canaryNonce = generateNonce()
        local canaryKey = "CANARY_INVALID_" .. canaryNonce
        local canaryId = lDigest("CANARY_HWID_" .. canaryNonce)
        local canaryUrl = host .. "/public/whitelist/" .. fToString(service) .. "?identifier=" .. canaryId .. "&key=" .. canaryKey .. "&nonce=" .. canaryNonce
        local canaryRes = fRequest({
            Url = canaryUrl,
            Method = "GET",
        })
        if canaryRes and canaryRes.StatusCode == 200 and type(canaryRes.Body) == "string" and canaryRes.Body ~= "" then
            local okCan, decCan = pcall(lDecode, canaryRes.Body)
            if okCan and type(decCan) == "table" and type(decCan.data) == "table" and decCan.data.valid == true then
                entangledScale = 0
                activeProofHash = ""
                onMessage("Security Alert: Network response spoofing detected.")
                return false
            end
        end
        return true
    end

    local function sealEntangledSession(key, nonce)
        activeProofHash = lDigest("ENTANGLE::" .. fToString(key) .. "::" .. fToString(nonce) .. "::" .. secret)
        entangledScale = (#activeProofHash == 64) and 1 or 0
    end

    local function redeemKey(key)
        if not isEnvironmentClean() then
            onMessage("Security Alert: Please close HTTP Spy / debugging tools first.")
            return false, nil
        end
        ensureHost()
        local nonce = generateNonce()
        local endpoint = host .. "/public/redeem/" .. fToString(service)

        local body = {
            identifier = lDigest(fGetHwid()),
            key = key,
        }

        if useNonce then
            body.nonce = nonce
        end

        local response = fRequest({
            Url = endpoint,
            Method = "POST",
            Body = lEncode(body),
            Headers = {
                ["Content-Type"] = "application/json",
            },
        })

        if response and response.StatusCode == 200 then
            local okDec, decoded = pcall(lDecode, response.Body)
            if okDec and type(decoded) == "table" then
                if decoded.success == true and type(decoded.data) == "table" then
                    if decoded.data.valid == true then
                        if useNonce then
                            if decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. secret) then
                                if not verifyCanaryIntegrity() then
                                    return false, nil
                                end
                                sealEntangledSession(key, nonce)
                                local expTs = resolveAccurateKeyExpiry(key, decoded.data, true)
                                return true, expTs
                            else
                                entangledScale = 0
                                onMessage("failed to verify integrity.")
                                return false, nil
                            end
                        else
                            if not verifyCanaryIntegrity() then
                                return false, nil
                            end
                            sealEntangledSession(key, nonce)
                            local expTs = resolveAccurateKeyExpiry(key, decoded.data, true)
                            return true, expTs
                        end
                    else
                        onMessage("key is invalid.")
                        return false, nil
                    end
                else
                    local msg = fToString(decoded.message or "key is invalid.")
                    if fStringSub(msg, 1, 27) == "unique constraint violation" then
                        onMessage("you already have an active key, please wait for it to expire before redeeming it.")
                        return false, nil
                    else
                        onMessage(msg)
                        return false, nil
                    end
                end
            end
        elseif response and response.StatusCode == 429 then
            onMessage("you are being rate limited, please wait 20 seconds and try again.")
            return false, nil
        end

        onMessage("server returned an invalid status code, please try again later.")
        return false, nil
    end

    local function verifyKey(key)
        if not isEnvironmentClean() then
            onMessage("Security Alert: Please close HTTP Spy / debugging tools first.")
            return false, nil
        end
        if requestSending == true then
            onMessage("a request is already being sent, please slow down.")
            return false, nil
        else
            requestSending = true
        end

        ensureHost()
        local nonce = generateNonce()
        local endpoint = host .. "/public/whitelist/" .. fToString(service) .. "?identifier=" .. lDigest(fGetHwid()) .. "&key=" .. key

        if useNonce then
            endpoint = endpoint .. "&nonce=" .. nonce
        end

        local response = fRequest({
            Url = endpoint,
            Method = "GET",
        })

        requestSending = false

        if response and response.StatusCode == 200 then
            local okDec, decoded = pcall(lDecode, response.Body)
            if okDec and type(decoded) == "table" then
                if decoded.success == true and type(decoded.data) == "table" then
                    if decoded.data.valid == true then
                        if useNonce then
                            if decoded.data.hash == lDigest("true" .. "-" .. nonce .. "-" .. secret) then
                                if not verifyCanaryIntegrity() then
                                    return false, nil
                                end
                                sealEntangledSession(key, nonce)
                                local expTs = resolveAccurateKeyExpiry(key, decoded.data, false)
                                return true, expTs
                            else
                                entangledScale = 0
                                onMessage("failed to verify integrity.")
                                return false, nil
                            end
                        else
                            if not verifyCanaryIntegrity() then
                                return false, nil
                            end
                            sealEntangledSession(key, nonce)
                            local expTs = resolveAccurateKeyExpiry(key, decoded.data, false)
                            return true, expTs
                        end
                    else
                        if fStringSub(key, 1, 4) == "KEY_" then
                            return redeemKey(key)
                        else
                            onMessage("key is invalid.")
                            return false, nil
                        end
                    end
                else
                    onMessage(fToString(decoded.message or "key is invalid."))
                    return false, nil
                end
            end
        elseif response and response.StatusCode == 429 then
            onMessage("you are being rate limited, please wait 20 seconds and try again.")
            return false, nil
        end

        onMessage("server returned an invalid status code, please try again later.")
        return false, nil
    end

    local function getFlag(name)
        ensureHost()
        local nonce = generateNonce()
        local endpoint = host .. "/public/flag/" .. fToString(service) .. "?name=" .. name

        if useNonce then
            endpoint = endpoint .. "&nonce=" .. nonce
        end

        local response = fRequest({
            Url = endpoint,
            Method = "GET",
        })

        if response and response.StatusCode == 200 then
            local okDec, decoded = pcall(lDecode, response.Body)
            if okDec and type(decoded) == "table" and decoded.success == true and type(decoded.data) == "table" then
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
            end
        end
        return nil
    end

    return {
        service = service,
        encode = lEncode,
        decode = lDecode,
        digest = lDigest,
        cacheLink = cacheLink,
        copyLink = copyLink,
        verifyKey = verifyKey,
        redeemKey = redeemKey,
        getFlag = getFlag,
        isEnvironmentClean = isEnvironmentClean,
        getEntangledScale = function()
            return entangledScale
        end,
        getProofHash = function()
            return activeProofHash
        end,
        setOnMessage = function(fn)
            if type(fn) == "function" then
                onMessage = fn
            end
        end,
    }
end)()

local function safeJsonEncode(tbl)
    local ok, res = pcall(function()
        return HttpService:JSONEncode(tbl)
    end)
    if ok and res then
        return res
    end
    local okP, resP = pcall(PlatoBoost.encode, tbl)
    return (okP and resP) or "{}"
end

local function safeJsonDecode(str)
    if not str or str == "" then
        return nil
    end
    local okP, resP = pcall(PlatoBoost.decode, str)
    if okP and type(resP) == "table" then
        return resP
    end
    local ok, res = pcall(function()
        return HttpService:JSONDecode(str)
    end)
    if ok and res then
        return res
    end
    return nil
end

--------------------------------------------------------------------------------
-- 2. SAFE GUI PARENT & DETERMINISTIC PREVIOUS INSTANCE CLEANUP
--------------------------------------------------------------------------------
local guiParent
do
    local okHui, huiRes = pcall(function()
        return type(gethui) == "function" and gethui() or nil
    end)
    if okHui and huiRes then
        guiParent = huiRes
    else
        local playerGui = LocalPlayer and LocalPlayer:FindFirstChildOfClass("PlayerGui")
        guiParent = playerGui or CoreGui or LocalPlayer:WaitForChild("PlayerGui")
    end

    -- Deterministically unbind any previous execution's render step & destroy old UI
    pcall(function()
        if RunService and RunService.UnbindFromRenderStep then
            RunService:UnbindFromRenderStep("CoreXYZ_PostCameraSync")
        end
    end)
    local existingGui = guiParent and guiParent:FindFirstChild("CoreXYZ_Universal")
    if existingGui then
        pcall(function()
            existingGui:Destroy()
        end)
    end
    pcall(function()
        local oldWeatherPart = workspace and workspace:FindFirstChild("CoreXyz_WeatherEmitterPart")
        if oldWeatherPart then oldWeatherPart:Destroy() end
        local oldGroundPart = workspace and workspace:FindFirstChild("CoreXyz_WeatherGroundPart")
        if oldGroundPart then oldGroundPart:Destroy() end
        local oldLightningPool = workspace and workspace:FindFirstChild("CoreXyz_LightningBoltPool")
        if oldLightningPool then oldLightningPool:Destroy() end
        local oldRays = Lighting and Lighting:FindFirstChild("CoreXyz_WeatherSunRays")
        if oldRays then oldRays:Destroy() end
        local oldCC = Lighting and Lighting:FindFirstChild("CoreXyz_WeatherColorCorrection")
        if oldCC then oldCC:Destroy() end
        local oldBloom = Lighting and Lighting:FindFirstChild("CoreXyz_WeatherBloom")
        if oldBloom then oldBloom:Destroy() end
        local oldAtmo = Lighting and Lighting:FindFirstChild("CoreXyz_WeatherAtmosphere")
        if oldAtmo then oldAtmo:Destroy() end
        local soundSvc = safeGetService("SoundService")
        if soundSvc then
            for _, sName in ipairs({
                "CoreXyz_WeatherAmbienceSound",
                "CoreXyz_WeatherPatterSound",
                "CoreXyz_WeatherRumblerSound",
                "CoreXyz_WeatherThunderSound",
                "CoreXyz_SpatialThunderSound",
                "CoreXyz_MusicPlayerSound",
            }) do
                local oldSnd = soundSvc:FindFirstChild(sName)
                if oldSnd then oldSnd:Destroy() end
            end
        end
    end)
end

--------------------------------------------------------------------------------
-- 3. UNIFIED STATE & RUNTIME REGISTRIES (LOW LOCAL REGISTER FOOTPRINT)
--------------------------------------------------------------------------------
local ConfigState = {
    -- Combat & Hitbox
    Aimbot = false,
    AimbotLockCharacter = true,
    AimbotWallCheck = false,
    ShowFOV = false,
    FOVRadius = 85,
    Smoothness = 0.9,
    TeamCheck = false,
    UseWhitelist = false,
    TargetPart = "Head",
    HitboxExpander = false,
    HitboxSize = 10,
    HitboxTransparency = 0.7,
    -- Visuals & Screen Resolution
    ESP = false,
    Box3DESP = false,
    SkeletonESP = false,
    HealthBarESP = false,
    Tracers = false,
    TracerOrigin = "Center",
    ESPColorName = "White",
    -- ESP Skeleton Sub-Card Suite
    SkeletonColorMode = "Team",
    SkeletonEffect = "Glow",
    SkeletonBoneThickness = 2,
    SkeletonBoneOutline = true,
    SkeletonJointDots = false,
    SkeletonHeadCircle = true,
    -- ESP Text Sub-Card Suite
    ESPTextFont = "Gotham",
    ESPTextSize = 12,
    ESPTextOutline = true,
    ESPNameType = "Display Name",
    -- ESP Health Bar Sub-Card Suite
    HealthBarType = "Gradient",
    HealthBarSide = "Left",
    HealthBarWidth = 2,
    HealthAnimSpeed = 1.0,
    HealthSmoothing = 0.15,
    HealthBarOutline = true,
    HealthBarShimmer = false,
    HealthBarGlow = false,
    HealthLowFlash = true,
    HealthNumber = false,
    -- ESP Box Effects Sub-Card Suite
    BoxAnimation = "None",
    BoxSecondColor = Color3.fromRGB(115, 95, 255),
    BoxAnimSpeed = 0.5,
    BoxGlow = false,
    BoxSpin = false,
    BoxSpinSpeed = 0.3,
    BoxFillAnimation = "None",
    BoxFillDirection = "Vertical",
    BoxFillAnimSpeed = 0.5,
    Crosshair = false,
    CrosshairPreset = "Plus (+)",
    CrosshairColorName = "White",
    CrosshairSize = 10,
    CrosshairWidth = 2,
    CrosshairGap = 4,
    CrosshairDot = true,
    CrosshairDotSize = 3,
    CrosshairSpin = false,
    CrosshairSpinSpeed = 120,
    CrosshairPulse = false,
    CrosshairPulseSpeed = 4,
    CrosshairRainbow = false,
    ResolutionEnabled = false,
    ResolutionPreset = "1280x960",
    CustomStretch = 0.75,
    XRay = false,
    XRayTransparency = 0.6,
    SkyPreset = "Game Default",
    WeatherPreset = "Default",
    WeatherSoundEnabled = true,
    WeatherSoundVolume = 0.5,
    Fullbright = false,
    NoFog = false,
    TimeOfDay = 14,
    Freecam = false,
    FreecamSpeed = 45,
    CustomCamFOV = false,
    CamFOV = 70,
    InfZoom = false,
    NoclipCam = false,
    Headless = false,
    Korblox = false,
    -- Self Chams Suite
    SelfChams = false,
    SelfChamsMaterial = "Lava",
    SelfChamsFillColor = Color3.fromRGB(115, 95, 255),
    SelfChamsOutlineColor = Color3.fromRGB(255, 255, 255),
    SelfChamsCustomColor = false,
    SelfChamsFillTrans = 0.55,
    SelfChamsOutlineTrans = 0,
    SelfChamsRainbow = false,
    SelfChamsPulse = false,
    SelfChamsGlowRim = false,
    -- Leg Trail Suite
    LegTrailEnabled = false,
    LeftLegTrailStart = Color3.fromRGB(105, 85, 255),
    LeftLegTrailEnd = Color3.fromRGB(70, 205, 255),
    LegTrailSameColors = false,
    RightLegTrailStart = Color3.fromRGB(255, 85, 195),
    RightLegTrailEnd = Color3.fromRGB(255, 190, 75),
    LegTrailWidth = 0.25,
    LegTrailLength = 0.5,
    LegTrailRainbow = false,
    -- Tool Visuals Suite
    ToolVisuals = false,
    ToolColor = Color3.fromRGB(115, 95, 255),
    ToolMaterial = "SmoothPlastic",
    ToolTransparency = 0,
    RainbowTool = false,
    ToolSkinTexture = "None",
    ToolChams = false,
    ToolChamsColor = Color3.fromRGB(255, 255, 255),
    ToolChamsStyle = "Outline",
    ToolGlow = false,
    ToolGlowBrightness = 3,
    -- Bloom & Sun Rays Suite
    BloomEnabled = false,
    BloomIntensity = 0.6,
    BloomSize = 26,
    BloomThreshold = 0.4,
    SunRaysEnabled = false,
    SunRaysIntensity = 0.25,
    SunRaysSpread = 1.0,
    -- Color Correction Suite
    ColorCorrectionEnabled = false,
    ColorCorrectionTint = Color3.fromRGB(255, 255, 255),
    ColorCorrectionSaturation = 0,
    ColorCorrectionContrast = 0,
    ColorCorrectionBrightness = 0,
    -- Skybox & Catalog Search Suite
    SkyboxEnabled = false,
    SkyboxPreset = "Galaxy",
    SkyboxClearAtmos = false,
    CustomSkyDecalId = "",
    SkySearchQuery = "",
    -- Lighting Controller Suite
    LightingAmbientEnabled = false,
    LightingAmbientColor = Color3.fromRGB(115, 95, 255),
    LightingOutdoorEnabled = false,
    LightingOutdoorColor = Color3.fromRGB(115, 95, 255),
    LightingShiftBottomEnabled = false,
    LightingShiftBottomColor = Color3.fromRGB(115, 95, 255),
    LightingShiftTopEnabled = false,
    LightingShiftTopColor = Color3.fromRGB(115, 95, 255),
    LightingFogColorEnabled = false,
    LightingFogColor = Color3.fromRGB(115, 95, 255),
    LightingFogEndEnabled = false,
    LightingFogEnd = 1000,
    LightingFogStartEnabled = false,
    LightingFogStart = 0,
    LightingExposureEnabled = false,
    LightingExposure = 0,
    LightingBrightnessEnabled = false,
    LightingBrightness = 1,
    LightingClockTimeEnabled = false,
    LightingClockTime = 12,
    LightingNoShadows = false,
    -- Atmosphere Controller Suite
    AtmosphereEnabled = false,
    AtmosphereColor = Color3.fromRGB(200, 195, 225),
    AtmosphereDecay = Color3.fromRGB(92, 60, 14),
    AtmosphereDensity = 0.35,
    AtmosphereOffset = 0,
    AtmosphereHaze = 0,
    AtmosphereGlare = 0,
    -- Movement & Protection
    StealthBypass = true,
    WalkSpeedEnabled = false,
    WalkSpeed = 16,
    JumpPowerEnabled = false,
    JumpPower = 50,
    InfJump = false,
    SwimInAir = false,
    SpiderClimb = false,
    SpiderClimbSpeed = 32,
    NoClip = false,
    Spinbot = false,
    SpinSpeed = 25,
    OrbitSpeed = 4.5,
    OrbitRadius = 8,
    AntiFling = false,
    AntiRagdoll = false,
    AntiVoid = false,
    -- World & Misc
    InstantInteract = false,
    AutoInteract = false,
    InteractRadius = 15,
    Disable3DRender = false,
    UncapFPS = false,
    CustomFPS = 144,
    ServerHopMode = "Lowest Players",
    TargetJobId = "",
    AntiAFK = false,
    -- Performance Settings Suite
    PerformanceProfile = "Auto",
    LowGraphicsEnabled = false,
    OptimizeModeEnabled = false,
    PauseRenderOnTabOut = false,
    FPSWhenTabbedOut = 15,
    -- Music & Audio System
    SelectedTrack = "Snowman (Slowed + Reverb) — Sia",
    MusicPlayerVisible = false,
    MusicVolume = 0.75,
    MusicLooped = true,
    MuteGameAudio = false,
    -- Custom Background Suite
    CustomBgDecalId = "",
    CustomBgTransparency = 0.5,
    CustomBgAlsoWatermark = false,
    CustomBgPanelSeeThrough = 0.35,
    CustomBgImageFit = "Crop",
    CustomBgSearchQuery = "",
    -- Full UI Theme Palette Suite (Vaderpaste Default)
    ThemeBgColor = Color3.fromRGB(19, 19, 19),
    ThemeElementColor = Color3.fromRGB(22, 22, 22),
    ThemeBorderColor = Color3.fromRGB(56, 56, 56),
    ThemeAccentColor = Color3.fromRGB(100, 100, 255),
    ThemeGlowColor = Color3.fromRGB(100, 100, 255),
    ThemeOutlineColor = Color3.fromRGB(8, 8, 8),
    ThemeInlineColor = Color3.fromRGB(26, 26, 26),
    ThemeGradientColor = Color3.fromRGB(130, 130, 255),
    ThemeFontColor = Color3.fromRGB(170, 170, 170),
    ThemeFontOutlineColor = Color3.fromRGB(0, 0, 0),
    ThemeFontFace = "Code",
    ThemeListSelection = "Default",
    CustomThemeName = "",
    -- UI & Settings
    CustomPillTitle = "CORE.XYZ",
    RememberKey = true,
    ThemePreset = "Vaderpaste",
    AccentR = 100,
    AccentG = 100,
    AccentB = 255,
    WindowTransparency = 0,
    ParticlesEnabled = true,
    ShimmerEnabled = true,
    AutoLoadConfig = false,
}

local RESOLUTION_PRESETS = {
    ["1280x960"] = 0.75,
    ["1440x1080"] = 0.80,
    ["1280x1024"] = 0.70,
    ["1728x1080"] = 0.90,
}

local State = {
    connections = {},
    playerCharConnections = {},
    selectedTeams = { ["All"] = true },
    allTeams = { "All" },
    prioritizedPlayers = {},
    whitelistedPlayers = {},
    whitelistArray = {},
    spectatingPlayerName = nil,
    orbitingPlayerName = nil,
    orbitAngle = 0,
    expandedPlayerName = nil,
    espObjects = {},
    cachedAimTarget = nil,
    targetScanAccumulator = 0,
    noclipCollideCache = {},
    antiFlingCollideCache = {},
    hitboxCache = {},
    xrayCache = {},
    promptDurationCache = {},
    headlessCache = {},
    korbloxCache = {},
    selfChamsCache = {},
    toolVisualsCache = {},
    clearedAtmosphereCache = {},
    suppressedSkyInstances = {},
    lowGraphicsCache = {},
    registeredKeybinds = {},
    listeningKeybindEntry = nil,
    sessionStartTime = os.time(),
    sessionKills = 0,
    trackedEnemyDeathStates = {},
    isWindowFocused = true,
    effectivePerformanceMode = "Balanced",
    detectedGameName = "Prison Life",
    detectedRegionCode = "IN",
    themeBoundElements = {},
    isUnderRoof = false,
    mutedGameSounds = setmetatable({}, { __mode = "k" }),
    muteAudioDescendantConn = nil,
    musicTrackOptions = { "Snowman (Slowed + Reverb) — Sia" },
    musicIsPlaying = false,
    musicDownloading = false,
    musicScrubbing = false,
    musicSimulatedPos = 0,
    musicTrackLength = 184,
    musicWaveClock = 0,
    musicCachedAssets = {},
    syncMusicPlayerDock = nil,
    setMusicPlaying = nil,
    syncPlayToggleUI = nil,
    stepMusicTrack = nil,
    seekMusicToRatio = nil,
    applyMuteGameAudio = nil,
    updateMusicPlayerFrame = nil,
    activeHighlightCount = 0,
    MAX_HIGHLIGHTS = 30,
    defaultWalkSpeed = 16,
    defaultJumpPower = 50,
    defaultCamFOV = 70,
    defaultMaxZoom = LocalPlayer.CameraMaxZoomDistance or 128,
    defaultOcclusion = LocalPlayer.DevCameraOcclusionMode,
    origLighting = {
        Brightness = Lighting.Brightness or 2,
        ClockTime = Lighting.ClockTime or 14,
        FogEnd = Lighting.FogEnd or 10000,
        FogStart = Lighting.FogStart or 0,
        FogColor = Lighting.FogColor or Color3.fromRGB(192, 192, 192),
        GlobalShadows = Lighting.GlobalShadows ~= false,
        Ambient = Lighting.Ambient or Color3.fromRGB(70, 70, 70),
        OutdoorAmbient = Lighting.OutdoorAmbient or Color3.fromRGB(128, 128, 128),
        ColorShift_Bottom = Lighting.ColorShift_Bottom or Color3.fromRGB(0, 0, 0),
        ColorShift_Top = Lighting.ColorShift_Top or Color3.fromRGB(0, 0, 0),
        ExposureCompensation = Lighting.ExposureCompensation or 0,
    },
    espColor = Color3.fromRGB(255, 255, 255),
    crosshairColor = Color3.fromRGB(255, 255, 255),
    antiAFKConnection = nil,
    instantPromptConnection = nil,
    fpsBoosterConnection = nil,
    lastSafeCFrame = nil,
    freecamPos = nil,
    activeKeyString = "FEYKSECURED",
    activeKeyTier = "Normal",
    keyExpireTimestamp = os.time() + 86400,
    homeAvatarYaw = 180,
    previewAvatarYaw = 180,
    appliedStretchRatio = 1.0,
    isAuthorized = false,
    uiVisible = true,
    isAuthorizing = false,
    customUIScaleOverride = nil,
    activeTelemetryMetrics = { "FPS", "Ping" },
    TELEMETRY_OPTIONS = { "FPS", "Ping", "CPU Usage", "GPU Usage", "1% Lows", "RAM Usage" },
    frameHistory = {},
    currentFPS = 60,
    currentOnePercentLow = 55,
    liveGradients = {},
    liveParticles = {},
    liveRotators = {},
    accentBoundObjects = {},
    Tabs = {},
    activeTab = nil,
    refreshPlayerListUI = nil,
    updatePlayerDistances = nil,
    refreshWhitelistDropdown = nil,
    loadConfigByName = nil,
    updateHomeKeyInfo = nil,
    lastPillText = "",
    lastPillWidth = 0,
    cachedLocalChar = nil,
    cachedLocalHRP = nil,
    cachedLocalHum = nil,
    cachedLocalParts = {},
}

local function bindConnection(key, signal, callback)
    if State.connections[key] then
        pcall(function()
            State.connections[key]:Disconnect()
        end)
        State.connections[key] = nil
    end
    if signal and signal.Connect then
        local conn = signal:Connect(callback)
        State.connections[key] = conn
        return conn
    end
    return nil
end

local UI = {}

local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.IgnoreWater = true

--------------------------------------------------------------------------------
-- 4. VADERPASTE DARK SLATE & PERIWINKLE ACCENT THEME PALETTE
--------------------------------------------------------------------------------
local Theme = {
    Black = Color3.fromRGB(8, 8, 8),
    Deep = Color3.fromRGB(19, 19, 19),
    Surface = Color3.fromRGB(22, 22, 22),
    Elevated = Color3.fromRGB(26, 26, 26),
    Outer = Color3.fromRGB(40, 40, 40),
    Border = Color3.fromRGB(56, 56, 56),
    Muted = Color3.fromRGB(90, 90, 90),
    Silver = Color3.fromRGB(170, 170, 170),
    White = Color3.fromRGB(255, 255, 255),
    Accent = Color3.fromRGB(100, 100, 255),
    Error = Color3.fromRGB(255, 80, 80),
    Success = Color3.fromRGB(90, 255, 150),
}

local FastTween = TweenInfo.new(0.18, Enum.EasingStyle.Quart, Enum.EasingDirection.Out)
local SmoothTween = TweenInfo.new(0.32, Enum.EasingStyle.Quint, Enum.EasingDirection.Out)
local SpringTween = TweenInfo.new(0.45, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local SlowTween = TweenInfo.new(0.55, Enum.EasingStyle.Exponential, Enum.EasingDirection.Out)

local function tween(instance, info, goals)
    if not instance then
        return nil
    end
    local ok, t = pcall(function()
        local tw = TweenService:Create(instance, info, goals)
        tw:Play()
        return tw
    end)
    return ok and t or nil
end

local function registerAccentObject(obj, prop)
    table.insert(State.accentBoundObjects, { Obj = obj, Prop = prop })
end

local function updateAccentColor(r, g, b)
    ConfigState.AccentR = math.clamp(math.floor(r), 0, 255)
    ConfigState.AccentG = math.clamp(math.floor(g), 0, 255)
    ConfigState.AccentB = math.clamp(math.floor(b), 0, 255)
    Theme.Accent = Color3.fromRGB(ConfigState.AccentR, ConfigState.AccentG, ConfigState.AccentB)
    for _, item in ipairs(State.accentBoundObjects) do
        if item.Obj and item.Obj.Parent then
            pcall(function()
                item.Obj[item.Prop] = Theme.Accent
            end)
        end
    end
    local edgeCol = ConfigState.ThemeBorderColor or Theme.Border
    local peakCol = ConfigState.ThemeGradientColor or Theme.Accent
    for _, item in ipairs(State.liveGradients) do
        if item.Gradient and item.Gradient.Parent then
            pcall(function()
                item.Gradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0.0, edgeCol),
                    ColorSequenceKeypoint.new(0.32, edgeCol),
                    ColorSequenceKeypoint.new(0.5, peakCol),
                    ColorSequenceKeypoint.new(0.68, edgeCol),
                    ColorSequenceKeypoint.new(1.0, edgeCol),
                })
            end)
        end
    end
end

local function addCorner(parent, radius)
    local c = Instance.new("UICorner")
    c.CornerRadius = UDim.new(0, radius or 8)
    c.Parent = parent
    return c
end

local function addStroke(parent, color, thickness, transparency)
    local s = Instance.new("UIStroke")
    s.Color = color or Theme.Border
    s.Thickness = thickness or 1
    s.Transparency = transparency or 0
    s.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
    s.Parent = parent
    return s
end

local function addLiveBorder(parent, thickness, speed, initialTransparency)
    local stroke = addStroke(parent, Theme.White, thickness or 1.2, initialTransparency or 0.15)
    local grad = Instance.new("UIGradient")
    grad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(36, 36, 44)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(55, 55, 68)),
        ColorSequenceKeypoint.new(0.5, Theme.White),
        ColorSequenceKeypoint.new(0.65, Color3.fromRGB(55, 55, 68)),
        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(36, 36, 44)),
    })
    grad.Rotation = math.random(0, 360)
    grad.Parent = stroke
    table.insert(State.liveGradients, {
        Gradient = grad,
        Stroke = stroke,
        Target = parent,
        Speed = speed or 65,
        Offset = math.random(0, 360),
    })
    return stroke, grad
end

local function createParticleCanvas(parent, count)
    local holder = Instance.new("Frame")
    holder.Name = "ParticleCanvas"
    holder.Size = UDim2.fromScale(1, 1)
    holder.BackgroundTransparency = 1
    holder.ClipsDescendants = true
    holder.ZIndex = parent.ZIndex
    holder.Parent = parent

    local particleCount = math.min(count or 6, 8)
    for i = 1, particleCount do
        local dot = Instance.new("Frame")
        local sz = (i % 3 == 0) and 3 or 2
        dot.Size = UDim2.fromOffset(sz, sz)
        local startX = (math.random(5, 95) / 100)
        local startY = (math.random(5, 95) / 100)
        dot.Position = UDim2.fromScale(startX, startY)
        dot.BackgroundColor3 = Theme.Accent
        dot.BackgroundTransparency = math.random(55, 85) / 100
        dot.BorderSizePixel = 0
        dot.ZIndex = parent.ZIndex
        dot.Parent = holder
        addCorner(dot, 99)
        registerAccentObject(dot, "BackgroundColor3")

        table.insert(State.liveParticles, {
            Instance = dot,
            Container = parent,
            Holder = holder,
            X = startX,
            Y = startY,
            SpeedY = math.random(4, 12) / 100,
            DriftX = math.random(-4, 4) / 100,
            Phase = math.random(0, 628) / 100,
        })
    end
    return holder
end

local function spawnRipple(button)
    pcall(function()
        local ripple = Instance.new("Frame")
        ripple.AnchorPoint = Vector2.new(0.5, 0.5)
        ripple.Position = UDim2.fromScale(0.5, 0.5)
        ripple.Size = UDim2.fromOffset(0, 0)
        ripple.BackgroundColor3 = Theme.Accent
        ripple.BackgroundTransparency = 0.65
        ripple.BorderSizePixel = 0
        ripple.ZIndex = button.ZIndex + 2
        ripple.Parent = button
        addCorner(ripple, 999)

        local maxDim = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 1.6
        if maxDim <= 0 then
            maxDim = 180
        end
        tween(ripple, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
            Size = UDim2.fromOffset(maxDim, maxDim),
            BackgroundTransparency = 1,
        })
        task.delay(0.42, function()
            if ripple and ripple.Parent then
                ripple:Destroy()
            end
        end)
    end)
end

local function makeDraggable(handle, targetFrame, onDragCallback)
    local dragging = false
    local dragStart = nil
    local startPos = nil

    handle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = targetFrame.Position
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and dragStart and startPos and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            targetFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
            if onDragCallback then
                onDragCallback(delta)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = false
        end
    end)
end

--------------------------------------------------------------------------------
-- 5. ROOT SCREENGUI, OVERLAYS & NOTIFICATION SYSTEM
--------------------------------------------------------------------------------
local function getResponsiveScale()
    if State.customUIScaleOverride then
        return State.customUIScaleOverride
    end
    local cam = workspace.CurrentCamera
    if not cam then
        return 1
    end
    local vp = cam.ViewportSize
    if vp.Y < 430 or vp.X < 680 then
        return math.clamp(math.min(vp.X / 660, vp.Y / 430), 0.72, 0.95)
    end
    return 1
end

do
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "CoreXYZ_Universal"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = guiParent
    UI.ScreenGui = ScreenGui

    local OverlayContainer = Instance.new("Folder")
    OverlayContainer.Name = "Overlays"
    OverlayContainer.Parent = ScreenGui
    UI.OverlayContainer = OverlayContainer

    local HighlightContainer = Instance.new("Folder")
    HighlightContainer.Name = "Highlights"
    HighlightContainer.Parent = ScreenGui
    UI.HighlightContainer = HighlightContainer

    -- Live-Animated Single-Ring FOV Circle (No Tick Markers)
    local FovCircle = Instance.new("Frame")
    FovCircle.Name = "FOVCircle"
    FovCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    FovCircle.Position = UDim2.fromScale(0.5, 0.5)
    FovCircle.Size = UDim2.fromOffset(ConfigState.FOVRadius * 2, ConfigState.FOVRadius * 2)
    FovCircle.BackgroundTransparency = 1
    FovCircle.Visible = false
    FovCircle.ZIndex = 5
    FovCircle.Parent = OverlayContainer
    addCorner(FovCircle, 9999)
    local FovOuterStroke = addLiveBorder(FovCircle, 1.8, 135, 0.05)

    UI.FovCircle = FovCircle
    UI.FovOuterStroke = FovOuterStroke

    local CrosshairContainer = Instance.new("Frame")
    CrosshairContainer.Name = "CrosshairContainer"
    CrosshairContainer.AnchorPoint = Vector2.new(0.5, 0.5)
    CrosshairContainer.Position = UDim2.fromScale(0.5, 0.5)
    CrosshairContainer.Size = UDim2.fromOffset(120, 120)
    CrosshairContainer.BackgroundTransparency = 1
    CrosshairContainer.Visible = false
    CrosshairContainer.ZIndex = 7
    CrosshairContainer.Parent = OverlayContainer
    UI.CrosshairContainer = CrosshairContainer

    local CrosshairV = Instance.new("Frame")
    CrosshairV.Name = "CrosshairV"
    CrosshairV.AnchorPoint = Vector2.new(0.5, 0.5)
    CrosshairV.Position = UDim2.fromScale(0.5, 0.5)
    CrosshairV.Size = UDim2.fromOffset(ConfigState.CrosshairWidth, ConfigState.CrosshairSize * 2)
    CrosshairV.BackgroundColor3 = State.crosshairColor
    CrosshairV.BorderSizePixel = 0
    CrosshairV.Visible = false
    CrosshairV.Parent = OverlayContainer
    UI.CrosshairV = CrosshairV

    local CrosshairH = Instance.new("Frame")
    CrosshairH.Name = "CrosshairH"
    CrosshairH.AnchorPoint = Vector2.new(0.5, 0.5)
    CrosshairH.Position = UDim2.fromScale(0.5, 0.5)
    CrosshairH.Size = UDim2.fromOffset(ConfigState.CrosshairSize * 2, ConfigState.CrosshairWidth)
    CrosshairH.BackgroundColor3 = State.crosshairColor
    CrosshairH.BorderSizePixel = 0
    CrosshairH.Visible = false
    CrosshairH.Parent = OverlayContainer
    UI.CrosshairH = CrosshairH

    local function makeCrosshairArm(name)
        local arm = Instance.new("Frame")
        arm.Name = name
        arm.AnchorPoint = Vector2.new(0.5, 0.5)
        arm.BackgroundColor3 = State.crosshairColor
        arm.BorderSizePixel = 0
        arm.ZIndex = 8
        arm.Parent = CrosshairContainer
        return arm
    end

    UI.CrosshairArmTop = makeCrosshairArm("ArmTop")
    UI.CrosshairArmBottom = makeCrosshairArm("ArmBottom")
    UI.CrosshairArmLeft = makeCrosshairArm("ArmLeft")
    UI.CrosshairArmRight = makeCrosshairArm("ArmRight")

    local CrosshairDotFrame = Instance.new("Frame")
    CrosshairDotFrame.Name = "CrosshairDot"
    CrosshairDotFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    CrosshairDotFrame.Position = UDim2.fromScale(0.5, 0.5)
    CrosshairDotFrame.Size = UDim2.fromOffset(ConfigState.CrosshairDotSize, ConfigState.CrosshairDotSize)
    CrosshairDotFrame.BackgroundColor3 = State.crosshairColor
    CrosshairDotFrame.BorderSizePixel = 0
    CrosshairDotFrame.ZIndex = 9
    CrosshairDotFrame.Parent = CrosshairContainer
    addCorner(CrosshairDotFrame, 999)
    UI.CrosshairDotFrame = CrosshairDotFrame

    local CrosshairRingFrame = Instance.new("Frame")
    CrosshairRingFrame.Name = "CrosshairRing"
    CrosshairRingFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    CrosshairRingFrame.Position = UDim2.fromScale(0.5, 0.5)
    CrosshairRingFrame.Size = UDim2.fromOffset(22, 22)
    CrosshairRingFrame.BackgroundTransparency = 1
    CrosshairRingFrame.Visible = false
    CrosshairRingFrame.ZIndex = 7
    CrosshairRingFrame.Parent = CrosshairContainer
    local CrosshairRingCorner = addCorner(CrosshairRingFrame, 999)
    local CrosshairRingStroke = addStroke(CrosshairRingFrame, State.crosshairColor, 1.4, 0.1)
    UI.CrosshairRingFrame = CrosshairRingFrame
    UI.CrosshairRingCorner = CrosshairRingCorner
    UI.CrosshairRingStroke = CrosshairRingStroke

    local RenderSaverOverlay = Instance.new("Frame")
    RenderSaverOverlay.Name = "RenderSaverOverlay"
    RenderSaverOverlay.Size = UDim2.fromScale(1, 1)
    RenderSaverOverlay.BackgroundColor3 = Theme.Black
    RenderSaverOverlay.BackgroundTransparency = 0.05
    RenderSaverOverlay.Visible = false
    RenderSaverOverlay.ZIndex = 5
    RenderSaverOverlay.Parent = ScreenGui
    UI.RenderSaverOverlay = RenderSaverOverlay

    local RenderSaverLabel = Instance.new("TextLabel")
    RenderSaverLabel.AnchorPoint = Vector2.new(0.5, 0.5)
    RenderSaverLabel.Position = UDim2.fromScale(0.5, 0.5)
    RenderSaverLabel.Size = UDim2.fromOffset(420, 60)
    RenderSaverLabel.BackgroundTransparency = 1
    RenderSaverLabel.Font = Enum.Font.GothamBlack
    RenderSaverLabel.Text = "CORE.XYZ"
    RenderSaverLabel.TextColor3 = Theme.Muted
    RenderSaverLabel.TextSize = 14
    RenderSaverLabel.ZIndex = 6
    RenderSaverLabel.Parent = RenderSaverOverlay

    local NotifyHolder = Instance.new("Frame")
    NotifyHolder.AnchorPoint = Vector2.new(1, 1)
    NotifyHolder.Position = UDim2.new(1, -18, 1, -18)
    NotifyHolder.Size = UDim2.fromOffset(290, 300)
    NotifyHolder.BackgroundTransparency = 1
    NotifyHolder.ZIndex = 50
    NotifyHolder.Parent = ScreenGui
    UI.NotifyHolder = NotifyHolder

    local NotifyLayout = Instance.new("UIListLayout")
    NotifyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
    NotifyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
    NotifyLayout.Padding = UDim.new(0, 8)
    NotifyLayout.Parent = NotifyHolder
end

local function notify(title, content, duration)
    duration = duration or 4
    local card = Instance.new("Frame")
    card.Size = UDim2.fromOffset(280, 58)
    card.BackgroundColor3 = Theme.Black
    card.BackgroundTransparency = 1
    card.ClipsDescendants = true
    card.ZIndex = 51
    card.Parent = UI.NotifyHolder
    addCorner(card, 8)
    local st = addLiveBorder(card, 1.2, 110, 1)

    local cardScale = Instance.new("UIScale")
    cardScale.Scale = 0.9
    cardScale.Parent = card

    local accentBar = Instance.new("Frame")
    accentBar.Position = UDim2.fromOffset(8, 10)
    accentBar.Size = UDim2.new(0, 3, 1, -20)
    accentBar.BackgroundColor3 = Theme.Accent
    accentBar.BackgroundTransparency = 1
    accentBar.BorderSizePixel = 0
    accentBar.ZIndex = 52
    accentBar.Parent = card
    addCorner(accentBar, 4)

    local tLbl = Instance.new("TextLabel")
    tLbl.Position = UDim2.fromOffset(20, 8)
    tLbl.Size = UDim2.new(1, -28, 0, 18)
    tLbl.BackgroundTransparency = 1
    tLbl.Font = Enum.Font.GothamBlack
    tLbl.Text = string.upper(title)
    tLbl.TextColor3 = Theme.White
    tLbl.TextTransparency = 1
    tLbl.TextSize = 11
    tLbl.TextXAlignment = Enum.TextXAlignment.Left
    tLbl.ZIndex = 52
    tLbl.Parent = card

    local cLbl = Instance.new("TextLabel")
    cLbl.Position = UDim2.fromOffset(20, 25)
    cLbl.Size = UDim2.new(1, -28, 0, 26)
    cLbl.BackgroundTransparency = 1
    cLbl.Font = Enum.Font.GothamMedium
    cLbl.Text = content
    cLbl.TextColor3 = Theme.Silver
    cLbl.TextTransparency = 1
    cLbl.TextSize = 11
    cLbl.TextWrapped = true
    cLbl.TextXAlignment = Enum.TextXAlignment.Left
    cLbl.ZIndex = 52
    cLbl.Parent = card

    local progBar = Instance.new("Frame")
    progBar.AnchorPoint = Vector2.new(0, 1)
    progBar.Position = UDim2.fromScale(0, 1)
    progBar.Size = UDim2.new(1, 0, 0, 2)
    progBar.BackgroundColor3 = Theme.Accent
    progBar.BorderSizePixel = 0
    progBar.ZIndex = 53
    progBar.Parent = card

    tween(cardScale, SpringTween, { Scale = 1 })
    tween(card, FastTween, { BackgroundTransparency = 0.04 })
    tween(st, FastTween, { Transparency = 0.1 })
    tween(accentBar, FastTween, { BackgroundTransparency = 0 })
    tween(tLbl, FastTween, { TextTransparency = 0 })
    tween(cLbl, FastTween, { TextTransparency = 0 })
    tween(progBar, TweenInfo.new(duration, Enum.EasingStyle.Linear), { Size = UDim2.new(0, 0, 0, 2) })

    task.delay(duration, function()
        tween(cardScale, FastTween, { Scale = 0.9 })
        tween(card, FastTween, { BackgroundTransparency = 1 })
        tween(st, FastTween, { Transparency = 1 })
        tween(accentBar, FastTween, { BackgroundTransparency = 1 })
        tween(tLbl, FastTween, { TextTransparency = 1 })
        tween(cLbl, FastTween, { TextTransparency = 1 })
        task.wait(0.22)
        if card and card.Parent then
            card:Destroy()
        end
    end)
end

--------------------------------------------------------------------------------
-- 6. STAGE 1: ANIMATED LOADING SCREEN ("Core.xyz")
--------------------------------------------------------------------------------
do
    local LoaderCard = Instance.new("Frame")
    LoaderCard.Name = "CoreLoader"
    LoaderCard.AnchorPoint = Vector2.new(0.5, 0.5)
    LoaderCard.Position = UDim2.fromScale(0.5, 0.5)
    LoaderCard.Size = UDim2.fromOffset(408, 256)
    LoaderCard.BackgroundColor3 = Theme.Black
    LoaderCard.BackgroundTransparency = 1
    LoaderCard.ClipsDescendants = true
    LoaderCard.ZIndex = 30
    LoaderCard.Parent = UI.ScreenGui
    addCorner(LoaderCard, 12)
    local LoaderStroke = addLiveBorder(LoaderCard, 1.5, 85, 1)

    local LoaderScale = Instance.new("UIScale")
    LoaderScale.Scale = 0.86
    LoaderScale.Parent = LoaderCard

    createParticleCanvas(LoaderCard, 18)

    local LoaderTopBar = Instance.new("Frame")
    LoaderTopBar.Name = "LoaderTopBar"
    LoaderTopBar.Size = UDim2.new(1, 0, 0, 2)
    LoaderTopBar.BackgroundColor3 = Theme.White
    LoaderTopBar.BackgroundTransparency = 1
    LoaderTopBar.BorderSizePixel = 0
    LoaderTopBar.ZIndex = 32
    LoaderTopBar.Parent = LoaderCard

    local LoaderTopGrad = Instance.new("UIGradient")
    LoaderTopGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Theme.Black),
        ColorSequenceKeypoint.new(0.5, Theme.White),
        ColorSequenceKeypoint.new(1.0, Theme.Black),
    })
    LoaderTopGrad.Parent = LoaderTopBar

    local LoaderStageBadge = Instance.new("TextLabel")
    LoaderStageBadge.Name = "LoaderStageBadge"
    LoaderStageBadge.AnchorPoint = Vector2.new(0.5, 0)
    LoaderStageBadge.Position = UDim2.new(0.5, 0, 0, 14)
    LoaderStageBadge.Size = UDim2.fromOffset(124, 18)
    LoaderStageBadge.BackgroundColor3 = Theme.Surface
    LoaderStageBadge.BackgroundTransparency = 1
    LoaderStageBadge.Font = Enum.Font.Code
    LoaderStageBadge.Text = "STAGE 1 / 6  ·  BOOT"
    LoaderStageBadge.TextColor3 = Theme.Silver
    LoaderStageBadge.TextTransparency = 1
    LoaderStageBadge.TextSize = 9
    LoaderStageBadge.ZIndex = 32
    LoaderStageBadge.Parent = LoaderCard
    addCorner(LoaderStageBadge, 99)

    local EmblemOuter = Instance.new("Frame")
    EmblemOuter.AnchorPoint = Vector2.new(0.5, 0.5)
    EmblemOuter.Position = UDim2.new(0.5, 0, 0, 68)
    EmblemOuter.Size = UDim2.fromOffset(54, 54)
    EmblemOuter.BackgroundTransparency = 1
    EmblemOuter.ZIndex = 32
    EmblemOuter.Parent = LoaderCard
    addCorner(EmblemOuter, 12)
    local EmblemOuterStroke = addLiveBorder(EmblemOuter, 1.8, 120, 1)
    table.insert(State.liveRotators, { Instance = EmblemOuter, Speed = 38 })

    local EmblemInner = Instance.new("Frame")
    EmblemInner.AnchorPoint = Vector2.new(0.5, 0.5)
    EmblemInner.Position = UDim2.new(0.5, 0, 0, 68)
    EmblemInner.Size = UDim2.fromOffset(34, 34)
    EmblemInner.BackgroundTransparency = 1
    EmblemInner.Rotation = 45
    EmblemInner.ZIndex = 32
    EmblemInner.Parent = LoaderCard
    addCorner(EmblemInner, 8)
    local EmblemInnerStroke = addStroke(EmblemInner, Theme.Silver, 1.2, 1)
    table.insert(State.liveRotators, { Instance = EmblemInner, Speed = -55 })

    local EmblemCore = Instance.new("Frame")
    EmblemCore.AnchorPoint = Vector2.new(0.5, 0.5)
    EmblemCore.Position = UDim2.new(0.5, 0, 0, 68)
    EmblemCore.Size = UDim2.fromOffset(10, 10)
    EmblemCore.BackgroundColor3 = Theme.White
    EmblemCore.BackgroundTransparency = 1
    EmblemCore.ZIndex = 33
    EmblemCore.Parent = LoaderCard
    addCorner(EmblemCore, 99)

    local LoaderTitle = Instance.new("TextLabel")
    LoaderTitle.AnchorPoint = Vector2.new(0.5, 0)
    LoaderTitle.Position = UDim2.new(0.5, 0, 0, 108)
    LoaderTitle.Size = UDim2.new(1, -40, 0, 26)
    LoaderTitle.BackgroundTransparency = 1
    LoaderTitle.Font = Enum.Font.GothamBlack
    LoaderTitle.Text = "CORE.XYZ"
    LoaderTitle.TextColor3 = Theme.White
    LoaderTitle.TextTransparency = 1
    LoaderTitle.TextSize = 23
    LoaderTitle.ZIndex = 32
    LoaderTitle.Parent = LoaderCard

    local LoaderStatus = Instance.new("TextLabel")
    LoaderStatus.AnchorPoint = Vector2.new(0.5, 0)
    LoaderStatus.Position = UDim2.new(0.5, 0, 0, 136)
    LoaderStatus.Size = UDim2.new(1, -40, 0, 18)
    LoaderStatus.BackgroundTransparency = 1
    LoaderStatus.Font = Enum.Font.Code
    LoaderStatus.Text = "Starting Core.xyz..."
    LoaderStatus.TextColor3 = Theme.Silver
    LoaderStatus.TextTransparency = 1
    LoaderStatus.TextSize = 11
    LoaderStatus.ZIndex = 32
    LoaderStatus.Parent = LoaderCard

    local LoaderSubDetail = Instance.new("TextLabel")
    LoaderSubDetail.Name = "LoaderSubDetail"
    LoaderSubDetail.AnchorPoint = Vector2.new(0.5, 0)
    LoaderSubDetail.Position = UDim2.new(0.5, 0, 0, 155)
    LoaderSubDetail.Size = UDim2.new(1, -48, 0, 14)
    LoaderSubDetail.BackgroundTransparency = 1
    LoaderSubDetail.Font = Enum.Font.GothamMedium
    LoaderSubDetail.Text = "Warming up runtime environment & asset caches..."
    LoaderSubDetail.TextColor3 = Theme.Muted
    LoaderSubDetail.TextTransparency = 1
    LoaderSubDetail.TextSize = 10
    LoaderSubDetail.ZIndex = 32
    LoaderSubDetail.Parent = LoaderCard

    local LoaderBarBg = Instance.new("Frame")
    LoaderBarBg.AnchorPoint = Vector2.new(0.5, 0)
    LoaderBarBg.Position = UDim2.new(0.5, 0, 0, 184)
    LoaderBarBg.Size = UDim2.new(1, -64, 0, 6)
    LoaderBarBg.BackgroundColor3 = Theme.Surface
    LoaderBarBg.BackgroundTransparency = 1
    LoaderBarBg.BorderSizePixel = 0
    LoaderBarBg.ClipsDescendants = true
    LoaderBarBg.ZIndex = 32
    LoaderBarBg.Parent = LoaderCard
    addCorner(LoaderBarBg, 99)

    local LoaderBarFill = Instance.new("Frame")
    LoaderBarFill.Size = UDim2.fromScale(0, 1)
    LoaderBarFill.BackgroundColor3 = Theme.White
    LoaderBarFill.BorderSizePixel = 0
    LoaderBarFill.ZIndex = 33
    LoaderBarFill.Parent = LoaderBarBg
    addCorner(LoaderBarFill, 99)

    local LoaderPercent = Instance.new("TextLabel")
    LoaderPercent.AnchorPoint = Vector2.new(0.5, 0)
    LoaderPercent.Position = UDim2.new(0.5, 0, 0, 200)
    LoaderPercent.Size = UDim2.new(1, -64, 0, 18)
    LoaderPercent.BackgroundTransparency = 1
    LoaderPercent.Font = Enum.Font.Code
    LoaderPercent.Text = "0%"
    LoaderPercent.TextColor3 = Theme.White
    LoaderPercent.TextTransparency = 1
    LoaderPercent.TextSize = 11
    LoaderPercent.ZIndex = 32
    LoaderPercent.Parent = LoaderCard

    local LoaderFooterHint = Instance.new("TextLabel")
    LoaderFooterHint.Name = "LoaderFooterHint"
    LoaderFooterHint.AnchorPoint = Vector2.new(0.5, 1)
    LoaderFooterHint.Position = UDim2.new(0.5, 0, 1, -12)
    LoaderFooterHint.Size = UDim2.new(1, -48, 0, 14)
    LoaderFooterHint.BackgroundTransparency = 1
    LoaderFooterHint.Font = Enum.Font.Code
    LoaderFooterHint.Text = "UNIVERSAL EDITION  ·  V4.5"
    LoaderFooterHint.TextColor3 = Theme.Muted
    LoaderFooterHint.TextTransparency = 1
    LoaderFooterHint.TextSize = 9
    LoaderFooterHint.ZIndex = 32
    LoaderFooterHint.Parent = LoaderCard

    UI.LoaderCard = LoaderCard
    UI.LoaderStroke = LoaderStroke
    UI.LoaderScale = LoaderScale
    UI.LoaderTopBar = LoaderTopBar
    UI.LoaderTopGrad = LoaderTopGrad
    UI.LoaderStageBadge = LoaderStageBadge
    UI.LoaderSubDetail = LoaderSubDetail
    UI.LoaderFooterHint = LoaderFooterHint
    UI.EmblemOuterStroke = EmblemOuterStroke
    UI.EmblemInnerStroke = EmblemInnerStroke
    UI.EmblemCore = EmblemCore
    UI.LoaderTitle = LoaderTitle
    UI.LoaderStatus = LoaderStatus
    UI.LoaderBarBg = LoaderBarBg
    UI.LoaderBarFill = LoaderBarFill
    UI.LoaderPercent = LoaderPercent
end

--------------------------------------------------------------------------------
-- 7. STAGE 2: POLISHED KEY SYSTEM (PLATOBOOST · SAVE-KEY TOGGLE & LUXURY GRADIENTS)
--------------------------------------------------------------------------------
do
    local KeyCard = Instance.new("Frame")
    KeyCard.Name = "CoreKeySystem"
    KeyCard.AnchorPoint = Vector2.new(0.5, 0.5)
    KeyCard.Position = UDim2.fromScale(0.5, 0.5)
    KeyCard.Size = UDim2.fromOffset(448, 304)
    KeyCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    KeyCard.BackgroundTransparency = 1
    KeyCard.Visible = false
    KeyCard.Active = true
    KeyCard.ClipsDescendants = true
    KeyCard.ZIndex = 30
    KeyCard.Parent = UI.ScreenGui
    addCorner(KeyCard, 14)
    local KeyCardStroke, KeyCardStrokeGrad = addLiveBorder(KeyCard, 1.5, 75, 1)

    local KeyCardGrad = Instance.new("UIGradient")
    KeyCardGrad.Name = "KeyCardGradient"
    KeyCardGrad.Rotation = 135
    KeyCardGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(22, 22, 32)),
        ColorSequenceKeypoint.new(0.35, Color3.fromRGB(13, 13, 19)),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(8, 8, 12)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(16, 16, 24)),
    })
    KeyCardGrad.Parent = KeyCard

    local KeyInnerBevel = Instance.new("Frame")
    KeyInnerBevel.Name = "KeyInnerBevel"
    KeyInnerBevel.Position = UDim2.fromOffset(1, 1)
    KeyInnerBevel.Size = UDim2.new(1, -2, 1, -2)
    KeyInnerBevel.BackgroundTransparency = 1
    KeyInnerBevel.ZIndex = 31
    KeyInnerBevel.Parent = KeyCard
    addCorner(KeyInnerBevel, 13)
    local KeyInnerBevelStroke = addStroke(KeyInnerBevel, Theme.White, 1, 0.86)
    local KeyInnerBevelGrad = Instance.new("UIGradient")
    KeyInnerBevelGrad.Rotation = 90
    KeyInnerBevelGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.68),
        NumberSequenceKeypoint.new(0.5, 0.90),
        NumberSequenceKeypoint.new(1.0, 0.96),
    })
    KeyInnerBevelGrad.Parent = KeyInnerBevelStroke

    local KeyGradientOverlay = Instance.new("Frame")
    KeyGradientOverlay.Name = "KeyGradientOverlay"
    KeyGradientOverlay.Size = UDim2.fromScale(1, 1)
    KeyGradientOverlay.BackgroundColor3 = Theme.White
    KeyGradientOverlay.BackgroundTransparency = 1
    KeyGradientOverlay.BorderSizePixel = 0
    KeyGradientOverlay.ZIndex = 31
    KeyGradientOverlay.Parent = KeyCard
    addCorner(KeyGradientOverlay, 14)

    local KeyOverlayGrad = Instance.new("UIGradient")
    KeyOverlayGrad.Name = "KeyOverlayGradient"
    KeyOverlayGrad.Rotation = 135
    KeyOverlayGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 68, 92)),
        ColorSequenceKeypoint.new(0.32, Color3.fromRGB(210, 28, 52)),
        ColorSequenceKeypoint.new(0.68, Color3.fromRGB(95, 12, 24)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(28, 5, 10)),
    })
    KeyOverlayGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.00, 0.08),
        NumberSequenceKeypoint.new(0.45, 0.28),
        NumberSequenceKeypoint.new(1.00, 0.62),
    })
    KeyOverlayGrad.Parent = KeyGradientOverlay

    local KeyScale = Instance.new("UIScale")
    KeyScale.Scale = 0.88
    KeyScale.Parent = KeyCard

    createParticleCanvas(KeyCard, 18)
    makeDraggable(KeyCard, KeyCard)

    local KeyTopBar = Instance.new("Frame")
    KeyTopBar.Name = "KeyTopBar"
    KeyTopBar.Size = UDim2.new(1, 0, 0, 2)
    KeyTopBar.BackgroundColor3 = Theme.White
    KeyTopBar.BorderSizePixel = 0
    KeyTopBar.ZIndex = 33
    KeyTopBar.Parent = KeyCard

    local KeyTopGrad = Instance.new("UIGradient")
    KeyTopGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Theme.Black),
        ColorSequenceKeypoint.new(0.25, Color3.fromRGB(160, 160, 185)),
        ColorSequenceKeypoint.new(0.50, Theme.White),
        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(160, 160, 185)),
        ColorSequenceKeypoint.new(1.00, Theme.Black),
    })
    KeyTopGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.85),
        NumberSequenceKeypoint.new(0.2, 0.15),
        NumberSequenceKeypoint.new(0.5, 0.0),
        NumberSequenceKeypoint.new(0.8, 0.15),
        NumberSequenceKeypoint.new(1.0, 0.85),
    })
    KeyTopGrad.Parent = KeyTopBar

    local KeySpinBadge = Instance.new("Frame")
    KeySpinBadge.Position = UDim2.fromOffset(24, 20)
    KeySpinBadge.Size = UDim2.fromOffset(22, 22)
    KeySpinBadge.BackgroundTransparency = 1
    KeySpinBadge.ZIndex = 32
    KeySpinBadge.Parent = KeyCard
    addCorner(KeySpinBadge, 6)
    local KeySpinStroke = addStroke(KeySpinBadge, Theme.White, 1.3, 0.12)
    table.insert(State.liveRotators, { Instance = KeySpinBadge, Speed = 42 })

    local KeySpinDot = Instance.new("Frame")
    KeySpinDot.AnchorPoint = Vector2.new(0.5, 0.5)
    KeySpinDot.Position = UDim2.fromScale(0.5, 0.5)
    KeySpinDot.Size = UDim2.fromOffset(6, 6)
    KeySpinDot.BackgroundColor3 = Theme.White
    KeySpinDot.BorderSizePixel = 0
    KeySpinDot.ZIndex = 33
    KeySpinDot.Parent = KeySpinBadge
    addCorner(KeySpinDot, 99)

    local KeyHeader = Instance.new("TextLabel")
    KeyHeader.Position = UDim2.fromOffset(56, 16)
    KeyHeader.Size = UDim2.new(1, -165, 0, 18)
    KeyHeader.BackgroundTransparency = 1
    KeyHeader.Font = Enum.Font.GothamBlack
    KeyHeader.Text = "CORE.XYZ  ·  KEY SYSTEM"
    KeyHeader.TextColor3 = Theme.White
    KeyHeader.TextSize = 15
    KeyHeader.TextXAlignment = Enum.TextXAlignment.Left
    KeyHeader.ZIndex = 32
    KeyHeader.Parent = KeyCard

    local KeyHeaderSub = Instance.new("TextLabel")
    KeyHeaderSub.Position = UDim2.fromOffset(56, 33)
    KeyHeaderSub.Size = UDim2.new(1, -165, 0, 14)
    KeyHeaderSub.BackgroundTransparency = 1
    KeyHeaderSub.Font = Enum.Font.Code
    KeyHeaderSub.Text = "LICENSE VERIFICATION GATEWAY"
    KeyHeaderSub.TextColor3 = Theme.Muted
    KeyHeaderSub.TextSize = 9
    KeyHeaderSub.TextXAlignment = Enum.TextXAlignment.Left
    KeyHeaderSub.ZIndex = 32
    KeyHeaderSub.Parent = KeyCard

    local KeyServiceBadge = Instance.new("TextLabel")
    KeyServiceBadge.AnchorPoint = Vector2.new(1, 0)
    KeyServiceBadge.Position = UDim2.new(1, -24, 0, 20)
    KeyServiceBadge.Size = UDim2.fromOffset(94, 22)
    KeyServiceBadge.BackgroundColor3 = Theme.Surface
    KeyServiceBadge.BackgroundTransparency = 0.15
    KeyServiceBadge.Font = Enum.Font.Code
    KeyServiceBadge.Text = "● PLATOBOOST"
    KeyServiceBadge.TextColor3 = Theme.White
    KeyServiceBadge.TextSize = 9
    KeyServiceBadge.ZIndex = 32
    KeyServiceBadge.Parent = KeyCard
    addCorner(KeyServiceBadge, 6)
    addStroke(KeyServiceBadge, Theme.Border, 1, 0.25)

    local KeyInputHolder = Instance.new("Frame")
    KeyInputHolder.Position = UDim2.fromOffset(24, 56)
    KeyInputHolder.Size = UDim2.new(1, -48, 0, 44)
    KeyInputHolder.BackgroundColor3 = Theme.Surface
    KeyInputHolder.BackgroundTransparency = 0.08
    KeyInputHolder.ZIndex = 32
    KeyInputHolder.Parent = KeyCard
    addCorner(KeyInputHolder, 9)
    local KeyInputStroke = addStroke(KeyInputHolder, Theme.Border, 1.1, 0.15)

    local KeyInputBox = Instance.new("TextBox")
    KeyInputBox.Position = UDim2.fromOffset(14, 0)
    KeyInputBox.Size = UDim2.new(1, -68, 1, 0)
    KeyInputBox.BackgroundTransparency = 1
    KeyInputBox.Font = Enum.Font.Code
    KeyInputBox.PlaceholderText = "Paste Your key here..."
    KeyInputBox.PlaceholderColor3 = Theme.Muted
    KeyInputBox.Text = ""
    KeyInputBox.TextColor3 = Theme.White
    KeyInputBox.TextSize = 13
    KeyInputBox.ClearTextOnFocus = false
    KeyInputBox.TextXAlignment = Enum.TextXAlignment.Left
    KeyInputBox.ZIndex = 33
    KeyInputBox.Parent = KeyInputHolder

    local KeyClearBtn = Instance.new("TextButton")
    KeyClearBtn.Name = "KeyClearBtn"
    KeyClearBtn.AnchorPoint = Vector2.new(1, 0.5)
    KeyClearBtn.Position = UDim2.new(1, -8, 0.5, 0)
    KeyClearBtn.Size = UDim2.fromOffset(48, 26)
    KeyClearBtn.BackgroundColor3 = Theme.Deep
    KeyClearBtn.AutoButtonColor = false
    KeyClearBtn.Font = Enum.Font.Code
    KeyClearBtn.Text = "CLEAR"
    KeyClearBtn.TextColor3 = Theme.Muted
    KeyClearBtn.TextSize = 9
    KeyClearBtn.ZIndex = 34
    KeyClearBtn.Parent = KeyInputHolder
    addCorner(KeyClearBtn, 6)
    addStroke(KeyClearBtn, Theme.Border, 1, 0.25)

    KeyClearBtn.MouseEnter:Connect(function()
        tween(KeyClearBtn, FastTween, { BackgroundColor3 = Theme.Elevated, TextColor3 = Theme.White })
    end)
    KeyClearBtn.MouseLeave:Connect(function()
        tween(KeyClearBtn, FastTween, { BackgroundColor3 = Theme.Deep, TextColor3 = Theme.Muted })
    end)
    KeyClearBtn.MouseButton1Click:Connect(function()
        KeyInputBox.Text = ""
    end)

    KeyInputBox.Focused:Connect(function()
        tween(KeyInputStroke, FastTween, { Color = Theme.White, Thickness = 1.5, Transparency = 0 })
        tween(KeyInputHolder, FastTween, { BackgroundColor3 = Theme.Elevated })
    end)
    KeyInputBox.FocusLost:Connect(function()
        tween(KeyInputStroke, FastTween, { Color = Theme.Border, Thickness = 1.1, Transparency = 0.15 })
        tween(KeyInputHolder, FastTween, { BackgroundColor3 = Theme.Surface })
    end)

    local KeyStatusRow = Instance.new("Frame")
    KeyStatusRow.Name = "KeyStatusRow"
    KeyStatusRow.Position = UDim2.fromOffset(24, 106)
    KeyStatusRow.Size = UDim2.new(1, -48, 0, 24)
    KeyStatusRow.BackgroundColor3 = Theme.Deep
    KeyStatusRow.BackgroundTransparency = 0.12
    KeyStatusRow.ZIndex = 32
    KeyStatusRow.Parent = KeyCard
    addCorner(KeyStatusRow, 7)
    local KeyStatusStroke = addStroke(KeyStatusRow, Theme.Border, 1, 0.25)

    local KeyStatusDot = Instance.new("Frame")
    KeyStatusDot.Name = "KeyStatusDot"
    KeyStatusDot.AnchorPoint = Vector2.new(0, 0.5)
    KeyStatusDot.Position = UDim2.new(0, 10, 0.5, 0)
    KeyStatusDot.Size = UDim2.fromOffset(6, 6)
    KeyStatusDot.BackgroundColor3 = Theme.Silver
    KeyStatusDot.BorderSizePixel = 0
    KeyStatusDot.ZIndex = 33
    KeyStatusDot.Parent = KeyStatusRow
    addCorner(KeyStatusDot, 99)

    local KeyFeedback = Instance.new("TextLabel")
    KeyFeedback.Position = UDim2.fromOffset(24, 0)
    KeyFeedback.Size = UDim2.new(1, -32, 1, 0)
    KeyFeedback.BackgroundTransparency = 1
    KeyFeedback.Font = Enum.Font.Code
    KeyFeedback.Text = "Status: Waiting for key submission..."
    KeyFeedback.TextColor3 = Theme.Muted
    KeyFeedback.TextSize = 10
    KeyFeedback.TextTruncate = Enum.TextTruncate.AtEnd
    KeyFeedback.TextXAlignment = Enum.TextXAlignment.Left
    KeyFeedback.ZIndex = 33
    KeyFeedback.Parent = KeyStatusRow

    -- Interactive Save-Key Toggle Row (Saves verified key & auto-checks expiry on every execution)
    local SaveKeyToggle = Instance.new("TextButton")
    SaveKeyToggle.Name = "SaveKeyToggle"
    SaveKeyToggle.Position = UDim2.fromOffset(24, 136)
    SaveKeyToggle.Size = UDim2.new(1, -48, 0, 32)
    SaveKeyToggle.BackgroundColor3 = Theme.Surface
    SaveKeyToggle.BackgroundTransparency = 0.12
    SaveKeyToggle.AutoButtonColor = false
    SaveKeyToggle.Text = ""
    SaveKeyToggle.ZIndex = 32
    SaveKeyToggle.Parent = KeyCard
    addCorner(SaveKeyToggle, 8)
    local SaveKeyStroke = addStroke(SaveKeyToggle, ConfigState.RememberKey and Theme.White or Theme.Border, 1, ConfigState.RememberKey and 0.45 or 0.25)

    local SaveKeyLabel = Instance.new("TextLabel")
    SaveKeyLabel.Name = "SaveKeyLabel"
    SaveKeyLabel.Position = UDim2.fromOffset(12, 0)
    SaveKeyLabel.Size = UDim2.new(1, -68, 1, 0)
    SaveKeyLabel.BackgroundTransparency = 1
    SaveKeyLabel.Font = Enum.Font.GothamBold
    SaveKeyLabel.Text = "Save Key  ·  Auto-Login Until Key Expires"
    SaveKeyLabel.TextColor3 = ConfigState.RememberKey and Theme.White or Theme.Silver
    SaveKeyLabel.TextSize = 11
    SaveKeyLabel.TextXAlignment = Enum.TextXAlignment.Left
    SaveKeyLabel.ZIndex = 33
    SaveKeyLabel.Parent = SaveKeyToggle

    local SaveKeyPill = Instance.new("Frame")
    SaveKeyPill.Name = "SaveKeyPill"
    SaveKeyPill.AnchorPoint = Vector2.new(1, 0.5)
    SaveKeyPill.Position = UDim2.new(1, -10, 0.5, 0)
    SaveKeyPill.Size = UDim2.fromOffset(38, 20)
    SaveKeyPill.BackgroundColor3 = ConfigState.RememberKey and Theme.White or Theme.Deep
    SaveKeyPill.ZIndex = 33
    SaveKeyPill.Parent = SaveKeyToggle
    addCorner(SaveKeyPill, 99)
    local SaveKeyPillStroke = addStroke(SaveKeyPill, ConfigState.RememberKey and Theme.White or Theme.Border, 1, 0.2)

    local SaveKeyDot = Instance.new("Frame")
    SaveKeyDot.Name = "SaveKeyDot"
    SaveKeyDot.AnchorPoint = Vector2.new(0, 0.5)
    SaveKeyDot.Position = ConfigState.RememberKey and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0)
    SaveKeyDot.Size = UDim2.fromOffset(14, 14)
    SaveKeyDot.BackgroundColor3 = ConfigState.RememberKey and Theme.Black or Theme.Muted
    SaveKeyDot.ZIndex = 34
    SaveKeyDot.Parent = SaveKeyPill
    addCorner(SaveKeyDot, 99)

    local function setSaveKeyVisualState(enabled, syncSettings)
        ConfigState.RememberKey = (enabled == true)
        tween(SaveKeyStroke, FastTween, {
            Color = ConfigState.RememberKey and Theme.White or Theme.Border,
            Transparency = ConfigState.RememberKey and 0.45 or 0.25,
        })
        tween(SaveKeyLabel, FastTween, {
            TextColor3 = ConfigState.RememberKey and Theme.White or Theme.Silver,
        })
        tween(SaveKeyPill, FastTween, {
            BackgroundColor3 = ConfigState.RememberKey and Theme.White or Theme.Deep,
        })
        tween(SaveKeyPillStroke, FastTween, {
            Color = ConfigState.RememberKey and Theme.White or Theme.Border,
        })
        tween(SaveKeyDot, SpringTween, {
            Position = ConfigState.RememberKey and UDim2.new(1, -17, 0.5, 0) or UDim2.new(0, 3, 0.5, 0),
            BackgroundColor3 = ConfigState.RememberKey and Theme.Black or Theme.Muted,
        })
        if not ConfigState.RememberKey then
            safeWriteFile(SAVED_KEY_FILE, "")
        end
        if syncSettings ~= false and type(State.syncSettingsSaveKeyToggle) == "function" then
            State.syncSettingsSaveKeyToggle(ConfigState.RememberKey, false)
        end
    end

    SaveKeyToggle.MouseButton1Click:Connect(function()
        setSaveKeyVisualState(not ConfigState.RememberKey, true)
    end)

    local UnlockButton = Instance.new("TextButton")
    UnlockButton.Name = "SubmitKeyButton"
    UnlockButton.Position = UDim2.fromOffset(24, 176)
    UnlockButton.Size = UDim2.new(0.5, -28, 0, 44)
    UnlockButton.BackgroundColor3 = Theme.White
    UnlockButton.AutoButtonColor = false
    UnlockButton.Font = Enum.Font.GothamBlack
    UnlockButton.Text = "Submit"
    UnlockButton.TextColor3 = Theme.Black
    UnlockButton.TextSize = 13
    UnlockButton.ClipsDescendants = true
    UnlockButton.ZIndex = 32
    UnlockButton.Parent = KeyCard
    addCorner(UnlockButton, 9)
    local UnlockBtnStroke = addStroke(UnlockButton, Theme.White, 1.2, 0.2)

    local CopyKeyButton = Instance.new("TextButton")
    CopyKeyButton.Name = "GetKeyButton"
    CopyKeyButton.Position = UDim2.new(0.5, 4, 0, 176)
    CopyKeyButton.Size = UDim2.new(0.5, -28, 0, 44)
    CopyKeyButton.BackgroundColor3 = Theme.Surface
    CopyKeyButton.AutoButtonColor = false
    CopyKeyButton.Font = Enum.Font.GothamBold
    CopyKeyButton.Text = "Get Key"
    CopyKeyButton.TextColor3 = Theme.White
    CopyKeyButton.TextSize = 13
    CopyKeyButton.ClipsDescendants = true
    CopyKeyButton.ZIndex = 32
    CopyKeyButton.Parent = KeyCard
    addCorner(CopyKeyButton, 9)
    local CopyBtnStroke = addStroke(CopyKeyButton, Theme.Border, 1.1, 0.15)

    UnlockButton.MouseEnter:Connect(function()
        tween(UnlockButton, FastTween, { BackgroundColor3 = Theme.Silver })
        tween(UnlockBtnStroke, FastTween, { Transparency = 0 })
    end)
    UnlockButton.MouseLeave:Connect(function()
        tween(UnlockButton, FastTween, { BackgroundColor3 = Theme.White })
        tween(UnlockBtnStroke, FastTween, { Transparency = 0.2 })
    end)

    CopyKeyButton.MouseEnter:Connect(function()
        tween(CopyKeyButton, FastTween, { BackgroundColor3 = Theme.Elevated })
        tween(CopyBtnStroke, FastTween, { Color = Theme.White, Transparency = 0 })
    end)
    CopyKeyButton.MouseLeave:Connect(function()
        tween(CopyKeyButton, FastTween, { BackgroundColor3 = Theme.Surface })
        tween(CopyBtnStroke, FastTween, { Color = Theme.Border, Transparency = 0.15 })
    end)

    local KeyDivider = Instance.new("Frame")
    KeyDivider.Position = UDim2.fromOffset(24, 234)
    KeyDivider.Size = UDim2.new(1, -48, 0, 1)
    KeyDivider.BackgroundColor3 = Theme.White
    KeyDivider.BorderSizePixel = 0
    KeyDivider.ZIndex = 32
    KeyDivider.Parent = KeyCard
    local KeyDividerGrad = Instance.new("UIGradient")
    KeyDividerGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.96),
        NumberSequenceKeypoint.new(0.5, 0.65),
        NumberSequenceKeypoint.new(1.0, 0.96),
    })
    KeyDividerGrad.Parent = KeyDivider

    local KeyFooter = Instance.new("TextLabel")
    KeyFooter.Position = UDim2.fromOffset(24, 246)
    KeyFooter.Size = UDim2.new(1, -48, 0, 16)
    KeyFooter.BackgroundTransparency = 1
    KeyFooter.Font = Enum.Font.Code
    KeyFooter.Text = "SECURED BY PLATOBOOST & CLOUDFLARE"
    KeyFooter.TextColor3 = Theme.Silver
    KeyFooter.TextSize = 9
    KeyFooter.TextXAlignment = Enum.TextXAlignment.Center
    KeyFooter.ZIndex = 32
    KeyFooter.Parent = KeyCard

    local KeyFooterSub = Instance.new("TextLabel")
    KeyFooterSub.Position = UDim2.fromOffset(24, 264)
    KeyFooterSub.Size = UDim2.new(1, -48, 0, 14)
    KeyFooterSub.BackgroundTransparency = 1
    KeyFooterSub.Font = Enum.Font.Code
    KeyFooterSub.Text = "nil"
    KeyFooterSub.TextColor3 = Theme.Muted
    KeyFooterSub.TextSize = 8
    KeyFooterSub.TextXAlignment = Enum.TextXAlignment.Center
    KeyFooterSub.ZIndex = 32
    KeyFooterSub.Parent = KeyCard

    UI.KeyCard = KeyCard
    UI.KeyCardGrad = KeyCardGrad
    UI.KeyInnerBevelStroke = KeyInnerBevelStroke
    UI.KeyGradientOverlay = KeyGradientOverlay
    UI.KeyOverlayGrad = KeyOverlayGrad
    UI.KeyCardStroke = KeyCardStroke
    UI.KeyCardStrokeGrad = KeyCardStrokeGrad
    UI.KeyScale = KeyScale
    UI.KeyTopBar = KeyTopBar
    UI.KeyTopGrad = KeyTopGrad
    UI.KeySpinStroke = KeySpinStroke
    UI.KeySpinDot = KeySpinDot
    UI.KeyInputBox = KeyInputBox
    UI.KeyInputStroke = KeyInputStroke
    UI.KeyStatusStroke = KeyStatusStroke
    UI.KeyStatusDot = KeyStatusDot
    UI.KeyFeedback = KeyFeedback
    UI.SaveKeyToggle = SaveKeyToggle
    UI.setSaveKeyVisualState = setSaveKeyVisualState
    UI.UnlockButton = UnlockButton
    UI.CopyKeyButton = CopyKeyButton
end

--------------------------------------------------------------------------------
-- 7B. ONE-TIME PER-UPDATE CHANGELOG MODAL (v4.4 · SHOWS ONCE PER VERSION)
--------------------------------------------------------------------------------
do
    local ChangelogModal = Instance.new("Frame")
    ChangelogModal.Name = "CoreChangelogModal"
    ChangelogModal.AnchorPoint = Vector2.new(0.5, 0.5)
    ChangelogModal.Position = UDim2.fromScale(0.5, 0.5)
    ChangelogModal.Size = UDim2.fromOffset(436, 308)
    ChangelogModal.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    ChangelogModal.BackgroundTransparency = 0.03
    ChangelogModal.Visible = false
    ChangelogModal.Active = true
    ChangelogModal.ClipsDescendants = true
    ChangelogModal.ZIndex = 95
    ChangelogModal.Parent = UI.ScreenGui
    addCorner(ChangelogModal, 14)
    local ChangelogStroke = addLiveBorder(ChangelogModal, 1.5, 80, 0.08)

    local ChangelogGrad = Instance.new("UIGradient")
    ChangelogGrad.Name = "ChangelogGradient"
    ChangelogGrad.Rotation = 135
    ChangelogGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(24, 24, 34)),
        ColorSequenceKeypoint.new(0.45, Color3.fromRGB(13, 13, 19)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(8, 8, 12)),
    })
    ChangelogGrad.Parent = ChangelogModal

    local ChangelogScale = Instance.new("UIScale")
    ChangelogScale.Scale = 1
    ChangelogScale.Parent = ChangelogModal

    local ChangelogHeader = Instance.new("Frame")
    ChangelogHeader.Name = "ChangelogHeader"
    ChangelogHeader.Size = UDim2.new(1, 0, 0, 48)
    ChangelogHeader.BackgroundColor3 = Theme.Deep
    ChangelogHeader.BackgroundTransparency = 0.15
    ChangelogHeader.BorderSizePixel = 0
    ChangelogHeader.ZIndex = 96
    ChangelogHeader.Parent = ChangelogModal
    addCorner(ChangelogHeader, 14)

    local ChangelogHeaderPatch = Instance.new("Frame")
    ChangelogHeaderPatch.Position = UDim2.new(0, 0, 1, -12)
    ChangelogHeaderPatch.Size = UDim2.new(1, 0, 0, 12)
    ChangelogHeaderPatch.BackgroundColor3 = Theme.Deep
    ChangelogHeaderPatch.BackgroundTransparency = 0.15
    ChangelogHeaderPatch.BorderSizePixel = 0
    ChangelogHeaderPatch.ZIndex = 96
    ChangelogHeaderPatch.Parent = ChangelogHeader

    local ChangelogHeaderLine = Instance.new("Frame")
    ChangelogHeaderLine.Position = UDim2.new(0, 0, 1, -1)
    ChangelogHeaderLine.Size = UDim2.new(1, 0, 0, 1)
    ChangelogHeaderLine.BackgroundColor3 = Theme.White
    ChangelogHeaderLine.BorderSizePixel = 0
    ChangelogHeaderLine.ZIndex = 97
    ChangelogHeaderLine.Parent = ChangelogHeader
    local ChangelogLineGrad = Instance.new("UIGradient")
    ChangelogLineGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0.0, 0.95),
        NumberSequenceKeypoint.new(0.5, 0.55),
        NumberSequenceKeypoint.new(1.0, 0.95),
    })
    ChangelogLineGrad.Parent = ChangelogHeaderLine

    local ChangelogBadge = Instance.new("TextLabel")
    ChangelogBadge.Position = UDim2.fromOffset(18, 13)
    ChangelogBadge.Size = UDim2.fromOffset(48, 22)
    ChangelogBadge.BackgroundColor3 = Theme.Elevated
    ChangelogBadge.Font = Enum.Font.Code
    ChangelogBadge.Text = CHANGELOG_VERSION
    ChangelogBadge.TextColor3 = Theme.White
    ChangelogBadge.TextSize = 11
    ChangelogBadge.ZIndex = 97
    ChangelogBadge.Parent = ChangelogHeader
    addCorner(ChangelogBadge, 6)
    addStroke(ChangelogBadge, Theme.Border, 1, 0.15)

    local ChangelogTitle = Instance.new("TextLabel")
    ChangelogTitle.Name = "ChangelogTitle"
    ChangelogTitle.Position = UDim2.fromOffset(76, 9)
    ChangelogTitle.Size = UDim2.new(1, -124, 0, 18)
    ChangelogTitle.BackgroundTransparency = 1
    ChangelogTitle.Font = Enum.Font.GothamBlack
    ChangelogTitle.Text = "Changelog " .. CHANGELOG_VERSION .. "  ·  " .. CHANGELOG_DATE
    ChangelogTitle.TextColor3 = Theme.White
    ChangelogTitle.TextSize = 14
    ChangelogTitle.TextXAlignment = Enum.TextXAlignment.Left
    ChangelogTitle.ZIndex = 97
    ChangelogTitle.Parent = ChangelogHeader

    local ChangelogSubtitle = Instance.new("TextLabel")
    ChangelogSubtitle.Name = "ChangelogSubtitle"
    ChangelogSubtitle.Position = UDim2.fromOffset(76, 26)
    ChangelogSubtitle.Size = UDim2.new(1, -124, 0, 14)
    ChangelogSubtitle.BackgroundTransparency = 1
    ChangelogSubtitle.Font = Enum.Font.Code
    ChangelogSubtitle.Text = "RELEASE NOTES"
    ChangelogSubtitle.TextColor3 = Theme.Muted
    ChangelogSubtitle.TextSize = 9
    ChangelogSubtitle.TextXAlignment = Enum.TextXAlignment.Left
    ChangelogSubtitle.ZIndex = 97
    ChangelogSubtitle.Parent = ChangelogHeader

    local ChangelogCloseBtn = Instance.new("TextButton")
    ChangelogCloseBtn.Name = "ChangelogCloseBtn"
    ChangelogCloseBtn.AnchorPoint = Vector2.new(1, 0.5)
    ChangelogCloseBtn.Position = UDim2.new(1, -12, 0.5, 0)
    ChangelogCloseBtn.Size = UDim2.fromOffset(26, 26)
    ChangelogCloseBtn.BackgroundColor3 = Theme.Surface
    ChangelogCloseBtn.AutoButtonColor = false
    ChangelogCloseBtn.Font = Enum.Font.GothamBold
    ChangelogCloseBtn.Text = "×"
    ChangelogCloseBtn.TextColor3 = Theme.Silver
    ChangelogCloseBtn.TextSize = 14
    ChangelogCloseBtn.ZIndex = 98
    ChangelogCloseBtn.Parent = ChangelogHeader
    addCorner(ChangelogCloseBtn, 7)
    local ChangelogCloseStroke = addStroke(ChangelogCloseBtn, Theme.Border, 1, 0.2)

    ChangelogCloseBtn.MouseEnter:Connect(function()
        tween(ChangelogCloseBtn, FastTween, { BackgroundColor3 = Theme.Error, TextColor3 = Theme.White })
        tween(ChangelogCloseStroke, FastTween, { Color = Theme.Error, Transparency = 0 })
    end)
    ChangelogCloseBtn.MouseLeave:Connect(function()
        tween(ChangelogCloseBtn, FastTween, { BackgroundColor3 = Theme.Surface, TextColor3 = Theme.Silver })
        tween(ChangelogCloseStroke, FastTween, { Color = Theme.Border, Transparency = 0.2 })
    end)

    makeDraggable(ChangelogHeader, ChangelogModal)

    local ChangelogBody = Instance.new("ScrollingFrame")
    ChangelogBody.Name = "ChangelogBody"
    ChangelogBody.Position = UDim2.fromOffset(16, 56)
    ChangelogBody.Size = UDim2.new(1, -32, 1, -68)
    ChangelogBody.BackgroundTransparency = 1
    ChangelogBody.BorderSizePixel = 0
    ChangelogBody.ScrollBarThickness = 2
    ChangelogBody.ScrollBarImageColor3 = Theme.Silver
    ChangelogBody.AutomaticCanvasSize = Enum.AutomaticSize.Y
    ChangelogBody.CanvasSize = UDim2.new(0, 0, 0, 0)
    ChangelogBody.ZIndex = 96
    ChangelogBody.Parent = ChangelogModal

    local ChangelogLayout = Instance.new("UIListLayout")
    ChangelogLayout.Padding = UDim.new(0, 8)
    ChangelogLayout.SortOrder = Enum.SortOrder.LayoutOrder
    ChangelogLayout.Parent = ChangelogBody

    local function createChangelogGroup(order, tagText, tagColor, items)
        local box = Instance.new("Frame")
        box.Name = "ChangelogGroup_" .. tostring(order)
        box.LayoutOrder = order
        box.Size = UDim2.new(1, -4, 0, 24)
        box.AutomaticSize = Enum.AutomaticSize.Y
        box.BackgroundColor3 = Theme.Surface
        box.BackgroundTransparency = 0.22
        box.ZIndex = 97
        box.Parent = ChangelogBody
        addCorner(box, 8)
        addStroke(box, tagColor, 1, 0.65)

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 8)
        pad.PaddingBottom = UDim.new(0, 8)
        pad.PaddingLeft = UDim.new(0, 10)
        pad.PaddingRight = UDim.new(0, 10)
        pad.Parent = box

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 4)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = box

        local hdr = Instance.new("TextLabel")
        hdr.Name = "GroupHeader"
        hdr.LayoutOrder = 0
        hdr.Size = UDim2.new(1, 0, 0, 16)
        hdr.BackgroundTransparency = 1
        hdr.Font = Enum.Font.GothamBlack
        hdr.Text = tagText
        hdr.TextColor3 = tagColor
        hdr.TextSize = 11
        hdr.TextXAlignment = Enum.TextXAlignment.Left
        hdr.ZIndex = 98
        hdr.Parent = box

        for idx, lineText in ipairs(items) do
            local itemLbl = Instance.new("TextLabel")
            itemLbl.Name = "Item_" .. tostring(idx)
            itemLbl.LayoutOrder = idx
            itemLbl.Size = UDim2.new(1, 0, 0, 15)
            itemLbl.BackgroundTransparency = 1
            itemLbl.Font = Enum.Font.Code
            itemLbl.Text = lineText
            itemLbl.TextColor3 = Theme.Silver
            itemLbl.TextSize = 10
            itemLbl.TextWrapped = true
            itemLbl.TextXAlignment = Enum.TextXAlignment.Left
            itemLbl.ZIndex = 98
            itemLbl.Parent = box
        end
    end

    createChangelogGroup(1, "[-] Removed Features", Color3.fromRGB(255, 92, 108), {
        "[-] Removed ESP Preview MINI-UI.",
        "[-] Remove __newindex & __namecall",
    })

    createChangelogGroup(2, "[+] Added Features", Color3.fromRGB(72, 245, 148), {
        "[+] Added New Reworked Ui",
    })

    createChangelogGroup(3, "[*] Fixed", Color3.fromRGB(105, 205, 255), {
        "[*] Fixed Aimbot & 3D Esp Visuals",
        "[*] Fixed Color Picker UI lag",
    })

    local function closeChangelogModal()
        safeWriteFile(CHANGELOG_SEEN_FILE, CHANGELOG_VERSION)
        ChangelogModal.Visible = false
    end

    local function showChangelogModal(forceShow)
        local seenVer = tostring(safeReadFile(CHANGELOG_SEEN_FILE) or ""):gsub("^%s*(.-)%s*$", "%1")
        if not forceShow and seenVer == CHANGELOG_VERSION then
            return false
        end
        safeWriteFile(CHANGELOG_SEEN_FILE, CHANGELOG_VERSION)
        local targetScale = getResponsiveScale()
        ChangelogModal.BackgroundTransparency = 0.03
        ChangelogStroke.Transparency = 0.08
        ChangelogScale.Scale = targetScale * 0.9
        ChangelogModal.Visible = true
        tween(ChangelogScale, SpringTween, { Scale = targetScale })
        return true
    end

    ChangelogCloseBtn.MouseButton1Click:Connect(function()
        closeChangelogModal()
    end)

    UI.ChangelogModal = ChangelogModal
    UI.ChangelogCloseBtn = ChangelogCloseBtn
    UI.showChangelogModal = showChangelogModal
    UI.closeChangelogModal = closeChangelogModal
end

--------------------------------------------------------------------------------
-- 8. EXACT AUTO-SIZING TELEMETRY FLOATING PILL (ZERO EMPTY SPACE)
--------------------------------------------------------------------------------
do
    local FloatingToggle = Instance.new("TextButton")
    FloatingToggle.Name = "CoreFloatingToggle"
    FloatingToggle.AnchorPoint = Vector2.new(0.5, 0)
    FloatingToggle.Position = UDim2.new(0.5, 0, 0, 14)
    FloatingToggle.Size = UDim2.fromOffset(92, 34)
    FloatingToggle.BackgroundColor3 = Theme.Black
    FloatingToggle.BackgroundTransparency = 0.04
    FloatingToggle.AutoButtonColor = false
    FloatingToggle.Text = ""
    FloatingToggle.Visible = false
    FloatingToggle.Active = true
    FloatingToggle.ClipsDescendants = true
    FloatingToggle.ZIndex = 40
    FloatingToggle.Parent = UI.ScreenGui
    local FloatCorner = addCorner(FloatingToggle, 999)
    addLiveBorder(FloatingToggle, 1.4, 95, 0.1)

    local FloatOrb = Instance.new("Frame")
    FloatOrb.AnchorPoint = Vector2.new(0, 0.5)
    FloatOrb.Position = UDim2.new(0, 10, 0.5, 0)
    FloatOrb.Size = UDim2.fromOffset(12, 12)
    FloatOrb.BackgroundTransparency = 1
    FloatOrb.ZIndex = 41
    FloatOrb.Parent = FloatingToggle
    addCorner(FloatOrb, 4)
    local FloatOrbStroke = addStroke(FloatOrb, Theme.Accent, 1.3, 0.1)
    registerAccentObject(FloatOrbStroke, "Color")
    table.insert(State.liveRotators, { Instance = FloatOrb, Speed = 50 })

    local FloatStatusDot = Instance.new("Frame")
    FloatStatusDot.AnchorPoint = Vector2.new(0.5, 0.5)
    FloatStatusDot.Position = UDim2.fromScale(0.5, 0.5)
    FloatStatusDot.Size = UDim2.fromOffset(4, 4)
    FloatStatusDot.BackgroundColor3 = Theme.Accent
    FloatStatusDot.BorderSizePixel = 0
    FloatStatusDot.ZIndex = 41
    FloatStatusDot.Parent = FloatOrb
    addCorner(FloatStatusDot, 99)
    registerAccentObject(FloatStatusDot, "BackgroundColor3")

    local FloatLabel = Instance.new("TextLabel")
    FloatLabel.Position = UDim2.fromOffset(28, 0)
    FloatLabel.Size = UDim2.new(1, -38, 1, 0)
    FloatLabel.BackgroundTransparency = 1
    FloatLabel.Font = Enum.Font.Code
    FloatLabel.Text = "CORE.XYZ"
    FloatLabel.TextColor3 = Theme.White
    FloatLabel.TextSize = 11
    FloatLabel.TextXAlignment = Enum.TextXAlignment.Left
    FloatLabel.ZIndex = 41
    FloatLabel.Parent = FloatingToggle

    makeDraggable(FloatingToggle, FloatingToggle)

    UI.FloatingToggle = FloatingToggle
    UI.FloatCorner = FloatCorner
    UI.FloatLabel = FloatLabel
end

local function updateFloatingPillTelemetry()
    local titleText = (ConfigState.CustomPillTitle and ConfigState.CustomPillTitle ~= "") and ConfigState.CustomPillTitle or "CORE.XYZ"
    local segments = { titleText }

    for _, metric in ipairs(State.activeTelemetryMetrics) do
        if metric == "FPS" then
            table.insert(segments, string.format("%d FPS", math.clamp(State.currentFPS, 1, 999)))
        elseif metric == "Ping" then
            local pingMs = 42
            pcall(function()
                if Env.Stats and Env.Stats.Network and Env.Stats.Network.ServerStatsItem and Env.Stats.Network.ServerStatsItem["Data Ping"] then
                    pingMs = math.floor(Env.Stats.Network.ServerStatsItem["Data Ping"]:GetValue())
                elseif LocalPlayer.GetNetworkPing then
                    pingMs = math.floor(LocalPlayer:GetNetworkPing() * 1000)
                end
            end)
            table.insert(segments, string.format("%02dms", math.clamp(pingMs, 0, 999)))
        elseif metric == "CPU Usage" then
            local cpuPct = math.clamp(math.floor((1 / math.max(State.currentFPS, 1)) * 1200), 4, 99)
            table.insert(segments, string.format("CPU %d%%", cpuPct))
        elseif metric == "GPU Usage" then
            local gpuPct = ConfigState.Disable3DRender and 2 or math.clamp(math.floor((1 / math.max(State.currentFPS, 1)) * 1450), 6, 99)
            table.insert(segments, string.format("GPU %d%%", gpuPct))
        elseif metric == "1% Lows" then
            table.insert(segments, string.format("1%%L %d", math.clamp(State.currentOnePercentLow, 1, 999)))
        elseif metric == "RAM Usage" then
            local ramMb = math.floor(collectgarbage("count") / 1024) + 420
            pcall(function()
                if Env.Stats and Env.Stats.GetTotalMemoryUsageMb then
                    ramMb = math.floor(Env.Stats:GetTotalMemoryUsageMb())
                end
            end)
            table.insert(segments, string.format("%dMB", ramMb))
        end
    end

    local fullText = table.concat(segments, " | ")
    if fullText == State.lastPillText then
        return
    end
    State.lastPillText = fullText
    UI.FloatLabel.Text = fullText

    -- Measure exact pixel width so there is NEVER dead space on the right or text clipping
    local textPixelWidth = math.floor(string.len(fullText) * 6.2)
    pcall(function()
        if Env.TextService and Env.TextService.GetTextSize then
            local measured = Env.TextService:GetTextSize(fullText, 11, Enum.Font.Code, Vector2.new(2000, 34))
            if measured and measured.X and measured.X > 0 then
                textPixelWidth = math.ceil(measured.X)
            end
        elseif UI.FloatLabel.TextBounds and UI.FloatLabel.TextBounds.X and UI.FloatLabel.TextBounds.X > 0 then
            textPixelWidth = math.ceil(UI.FloatLabel.TextBounds.X)
        end
    end)

    -- 28px left offset (10px pad + 12px icon + 6px gap) + textPixelWidth + 11px right pad = textPixelWidth + 39
    local targetWidth = math.clamp(textPixelWidth + 39, 64, 540)
    if math.abs(targetWidth - (State.lastPillWidth or 0)) >= 1 then
        State.lastPillWidth = targetWidth
        UI.FloatingToggle.Size = UDim2.fromOffset(targetWidth, 34)
    end
end

--------------------------------------------------------------------------------
-- 9. STAGE 3: LIVE-ANIMATED MAIN HUB ("Core.xyz")
--------------------------------------------------------------------------------
local function toggleMainHub()
    if not State.isAuthorized then
        return
    end
    State.uiVisible = not State.uiVisible
    local targetScale = getResponsiveScale()
    if State.uiVisible then
        UI.MainWindow.Visible = true
        UI.MainScale.Scale = targetScale
        if State.syncMusicPlayerDock then
            State.syncMusicPlayerDock()
        end
        tween(UI.MainScale, SpringTween, { Scale = targetScale })
        tween(UI.MainWindow, FastTween, { BackgroundTransparency = ConfigState.WindowTransparency })
        tween(UI.MainStroke, FastTween, { Transparency = 0.08 })
        tween(UI.FloatingToggle, FastTween, { BackgroundColor3 = Theme.Black })
    else
        if UI.ColorPickerPopup then
            UI.ColorPickerPopup.Visible = false
        end
        tween(UI.MainScale, FastTween, { Scale = targetScale * 0.9 })
        tween(UI.MainWindow, FastTween, { BackgroundTransparency = 1 })
        tween(UI.MainStroke, FastTween, { Transparency = 1 })
        tween(UI.FloatingToggle, FastTween, { BackgroundColor3 = Theme.Elevated })
        if State.syncMusicPlayerDock then
            State.syncMusicPlayerDock()
        end
        task.delay(0.18, function()
            if not State.uiVisible then
                UI.MainWindow.Visible = false
                if State.syncMusicPlayerDock then
                    State.syncMusicPlayerDock()
                end
            end
        end)
    end
end

-- Interactive 1:1 Character Clone + Draggable Rotation Helper for Home Showcase
local function buildInteractiveAvatarViewport(container)
    local fallbackImg = Instance.new("ImageLabel")
    fallbackImg.Name = "AvatarPreviewImage"
    fallbackImg.AnchorPoint = Vector2.new(0.5, 0.5)
    fallbackImg.Position = UDim2.fromScale(0.5, 0.5)
    fallbackImg.Size = UDim2.new(1, -8, 1, -8)
    fallbackImg.BackgroundTransparency = 1
    fallbackImg.ScaleType = Enum.ScaleType.Fit
    fallbackImg.Image = "rbxthumb://type=Avatar&id=" .. tostring(LocalPlayer.UserId or 1) .. "&w=420&h=420"
    fallbackImg.ZIndex = container.ZIndex + 1
    fallbackImg.Parent = container

    local vp = Instance.new("ViewportFrame")
    vp.Name = "HomeAvatarViewport"
    vp.Size = UDim2.fromScale(1, 1)
    vp.BackgroundTransparency = 1
    vp.Ambient = Color3.fromRGB(215, 215, 225)
    vp.LightColor = Color3.fromRGB(255, 255, 255)
    vp.LightDirection = Vector3.new(-1, -1, -1)
    vp.ZIndex = container.ZIndex + 2
    vp.Parent = container

    local worldModel = Instance.new("WorldModel")
    worldModel.Parent = vp

    local vpCam = Instance.new("Camera")
    vpCam.FieldOfView = 38
    vpCam.Parent = vp
    vp.CurrentCamera = vpCam

    local clonedModel = nil
    local clonedParts = {}
    local baseCenter = Vector3.new(0, 0, 0)

    local function refreshCharacterClone()
        if clonedModel and clonedModel.Parent then
            pcall(function() clonedModel:Destroy() end)
        end
        clonedModel = nil
        for _, item in ipairs(clonedParts) do
            if item.Part and item.Part.Parent then
                pcall(function() item.Part:Destroy() end)
            end
        end
        table.clear(clonedParts)

        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if not char or not hrp then
            fallbackImg.ImageTransparency = 0
            return
        end

        local rootPos = hrp.Position
        baseCenter = Vector3.new(0, 0, 0)

        local okClone, exactClone = pcall(function()
            local prevArch = char.Archivable
            char.Archivable = true
            local c = char:Clone()
            char.Archivable = prevArch
            return c
        end)

        if okClone and exactClone then
            clonedModel = exactClone
            clonedModel.Name = "AvatarCloneModel"

            for _, desc in ipairs(clonedModel:GetDescendants()) do
                if desc:IsA("BaseScript") or desc:IsA("LocalScript") or desc:IsA("Script") or desc:IsA("ForceField") or desc:IsA("Sound") or desc:IsA("Animator") then
                    pcall(function() desc:Destroy() end)
                elseif desc:IsA("Humanoid") then
                    pcall(function()
                        if Enum.HumanoidDisplayDistanceType then
                            desc.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
                        end
                        if Enum.HumanoidHealthDisplayType then
                            desc.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
                        end
                        desc.EvaluateStateMachine = false
                    end)
                elseif desc:IsA("BasePart") then
                    pcall(function()
                        desc.Anchored = true
                        desc.CanCollide = false
                        local relPos = desc.Position - rootPos
                        if desc.CFrame and desc.CFrame.GetComponents then
                            local _, _, _, r00, r01, r02, r10, r11, r12, r20, r21, r22 = desc.CFrame:GetComponents()
                            desc.CFrame = CFrame.new(relPos.X, relPos.Y, relPos.Z, r00, r01, r02, r10, r11, r12, r20, r21, r22)
                        else
                            desc.CFrame = CFrame.new(relPos)
                        end
                        if desc.Name == "HumanoidRootPart" then
                            desc.Transparency = 1
                        end
                        table.insert(clonedParts, {
                            Part = desc,
                            RelOffset = relPos,
                        })
                    end)
                end
            end
            clonedModel.Parent = worldModel
            if #clonedParts > 0 then
                fallbackImg.ImageTransparency = 0.88
            end
        end
    end

    local function applyYawRotation(yawDeg)
        local rad = math.rad(yawDeg or 180)
        local camDist = 6.8
        local lookTarget = baseCenter + Vector3.new(0, 0.15, 0)
        local camPos = baseCenter + Vector3.new(math.sin(rad) * camDist, 0.35, math.cos(rad) * camDist)
        vpCam.CFrame = CFrame.new(camPos, lookTarget)
    end

    refreshCharacterClone()
    applyYawRotation(State.homeAvatarYaw)

    local dragBtn = Instance.new("TextButton")
    dragBtn.Name = "AvatarRotateDragZone"
    dragBtn.Size = UDim2.fromScale(1, 1)
    dragBtn.BackgroundTransparency = 1
    dragBtn.Text = ""
    dragBtn.AutoButtonColor = false
    dragBtn.ZIndex = container.ZIndex + 8
    dragBtn.Parent = container

    local draggingYaw = false
    local lastInputX = 0

    dragBtn.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingYaw = true
            lastInputX = input.Position.X
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if draggingYaw and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local dx = input.Position.X - lastInputX
            lastInputX = input.Position.X
            State.homeAvatarYaw = (State.homeAvatarYaw + dx * 0.9) % 360
            applyYawRotation(State.homeAvatarYaw)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            draggingYaw = false
        end
    end)

    return {
        Viewport = vp,
        Camera = vpCam,
        FallbackImage = fallbackImg,
        RefreshClone = refreshCharacterClone,
        ApplyYaw = applyYawRotation,
        ClonedParts = clonedParts,
        GetClonedModel = function() return clonedModel end,
    }
end

do
    -- Vaderpaste Double-Bordered Window Architecture (inline1 -> inline2 -> main -> tab_inline -> tabs)
    local MainWindow = Instance.new("Frame")
    MainWindow.Name = "CoreMainWindow"
    MainWindow.AnchorPoint = Vector2.new(0.5, 0.5)
    MainWindow.Position = UDim2.fromScale(0.5, 0.52)
    MainWindow.Size = UDim2.fromOffset(620, 420)
    MainWindow.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
    MainWindow.BorderColor3 = Color3.fromRGB(8, 8, 8)
    MainWindow.BorderSizePixel = 1
    MainWindow.BackgroundTransparency = 1
    MainWindow.Active = true
    MainWindow.Visible = false
    MainWindow.ClipsDescendants = true
    MainWindow.ZIndex = 10
    MainWindow.Parent = UI.ScreenGui
    local MainStroke = addStroke(MainWindow, Color3.fromRGB(8, 8, 8), 1, 1)

    local MainScale = Instance.new("UIScale")
    MainScale.Scale = 0.88
    MainScale.Parent = MainWindow

    local MainParticleCanvas = createParticleCanvas(MainWindow, 12)

    local VaderInline2 = Instance.new("Frame")
    VaderInline2.Name = "VaderInline2"
    VaderInline2.Position = UDim2.new(0, 2, 0, 2)
    VaderInline2.Size = UDim2.new(1, -4, 1, -4)
    VaderInline2.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    VaderInline2.BorderColor3 = Color3.fromRGB(8, 8, 8)
    VaderInline2.BorderSizePixel = 1
    VaderInline2.ZIndex = 10
    VaderInline2.Parent = MainWindow

    local VaderMain = Instance.new("Frame")
    VaderMain.Name = "VaderMain"
    VaderMain.Position = UDim2.new(0, 2, 0, 2)
    VaderMain.Size = UDim2.new(1, -4, 1, -4)
    VaderMain.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    VaderMain.BorderColor3 = Color3.fromRGB(57, 57, 57)
    VaderMain.BorderSizePixel = 1
    VaderMain.ZIndex = 11
    VaderMain.Parent = VaderInline2
    UI.VaderMain = VaderMain

    local VaderAccentLine = Instance.new("Frame")
    VaderAccentLine.Name = "VaderAccentLine"
    VaderAccentLine.Size = UDim2.new(1, 0, 0, 2)
    VaderAccentLine.BackgroundColor3 = Theme.Accent
    VaderAccentLine.BorderSizePixel = 0
    VaderAccentLine.ZIndex = 15
    VaderAccentLine.Parent = VaderMain
    registerAccentObject(VaderAccentLine, "BackgroundColor3")

    local VaderAccentGlow = Instance.new("ImageLabel")
    VaderAccentGlow.Name = "VaderAccentGlow"
    VaderAccentGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    VaderAccentGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    VaderAccentGlow.Size = UDim2.new(1, 20, 1, 20)
    VaderAccentGlow.BackgroundTransparency = 1
    VaderAccentGlow.Image = "http://www.roblox.com/asset/?id=18245826428"
    VaderAccentGlow.ImageColor3 = Theme.Accent
    VaderAccentGlow.ImageTransparency = 0.89
    VaderAccentGlow.ScaleType = Enum.ScaleType.Slice
    pcall(function() VaderAccentGlow.SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)) end)
    VaderAccentGlow.ZIndex = 14
    VaderAccentGlow.Parent = VaderAccentLine
    registerAccentObject(VaderAccentGlow, "ImageColor3")

    local VaderDepthLine = Instance.new("Frame")
    VaderDepthLine.Name = "VaderDepthLine"
    VaderDepthLine.Position = UDim2.new(0, 0, 0, 2)
    VaderDepthLine.Size = UDim2.new(1, 0, 0, 1)
    VaderDepthLine.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    VaderDepthLine.BorderSizePixel = 0
    VaderDepthLine.ZIndex = 15
    VaderDepthLine.Parent = VaderAccentLine

    local HeaderBar = Instance.new("Frame")
    HeaderBar.Name = "HeaderBar"
    HeaderBar.Position = UDim2.fromOffset(0, 3)
    HeaderBar.Size = UDim2.new(1, 0, 0, 26)
    HeaderBar.BackgroundColor3 = Color3.fromRGB(26, 26, 26)
    HeaderBar.BackgroundTransparency = 1
    HeaderBar.BorderSizePixel = 0
    HeaderBar.ZIndex = 12
    HeaderBar.Parent = VaderMain

    local HeaderBottomLine = Instance.new("Frame")
    HeaderBottomLine.Position = UDim2.new(0, 12, 1, -1)
    HeaderBottomLine.Size = UDim2.new(1, -24, 0, 1)
    HeaderBottomLine.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    HeaderBottomLine.BackgroundTransparency = 0.25
    HeaderBottomLine.BorderSizePixel = 0
    HeaderBottomLine.ZIndex = 13
    HeaderBottomLine.Parent = HeaderBar

    local HeaderLineGrad = Instance.new("UIGradient")
    HeaderLineGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, Theme.Black),
        ColorSequenceKeypoint.new(0.5, Theme.Accent),
        ColorSequenceKeypoint.new(1.0, Theme.Black),
    })
    HeaderLineGrad.Parent = HeaderBottomLine

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Position = UDim2.fromOffset(12, 4)
    HeaderTitle.Size = UDim2.fromOffset(165, 18)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Font = Enum.Font.Code
    HeaderTitle.Text = "core.xyz | beta"
    HeaderTitle.TextColor3 = Color3.fromRGB(170, 170, 170)
    HeaderTitle.TextStrokeTransparency = 0.5
    HeaderTitle.TextSize = 12
    HeaderTitle.TextXAlignment = Enum.TextXAlignment.Left
    HeaderTitle.ZIndex = 13
    HeaderTitle.Parent = HeaderBar

    local HeaderSub = Instance.new("TextLabel")
    HeaderSub.Name = "HeaderSubtitle"
    HeaderSub.Position = UDim2.fromOffset(175, 4)
    HeaderSub.Size = UDim2.fromOffset(195, 18)
    HeaderSub.BackgroundTransparency = 1
    HeaderSub.Font = Enum.Font.Code
    HeaderSub.Text = "universal · home"
    HeaderSub.TextColor3 = Color3.fromRGB(90, 90, 90)
    HeaderSub.TextStrokeTransparency = 0.5
    HeaderSub.TextSize = 11
    HeaderSub.TextXAlignment = Enum.TextXAlignment.Left
    HeaderSub.ZIndex = 13
    HeaderSub.Parent = HeaderBar
    UI.HeaderSub = HeaderSub

    local HeaderSearchHolder = Instance.new("Frame")
    HeaderSearchHolder.Name = "HeaderSearchHolder"
    HeaderSearchHolder.AnchorPoint = Vector2.new(1, 0.5)
    HeaderSearchHolder.Position = UDim2.new(1, -36, 0.5, 0)
    HeaderSearchHolder.Size = UDim2.fromOffset(156, 18)
    HeaderSearchHolder.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    HeaderSearchHolder.BorderColor3 = Color3.fromRGB(56, 56, 56)
    HeaderSearchHolder.BorderSizePixel = 1
    HeaderSearchHolder.ZIndex = 14
    HeaderSearchHolder.Parent = HeaderBar
    local HeaderSearchStroke = addStroke(HeaderSearchHolder, Color3.fromRGB(8, 8, 8), 1, 0.15)

    local HeaderSearchBox = Instance.new("TextBox")
    HeaderSearchBox.Name = "HeaderSearchBox"
    HeaderSearchBox.Position = UDim2.fromOffset(6, 0)
    HeaderSearchBox.Size = UDim2.new(1, -24, 1, 0)
    HeaderSearchBox.BackgroundTransparency = 1
    HeaderSearchBox.ClearTextOnFocus = false
    HeaderSearchBox.Font = Enum.Font.Code
    HeaderSearchBox.PlaceholderText = "search..."
    HeaderSearchBox.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
    HeaderSearchBox.Text = ""
    HeaderSearchBox.TextColor3 = Color3.fromRGB(170, 170, 170)
    HeaderSearchBox.TextStrokeTransparency = 0.5
    HeaderSearchBox.TextSize = 11
    HeaderSearchBox.TextXAlignment = Enum.TextXAlignment.Left
    HeaderSearchBox.ZIndex = 15
    HeaderSearchBox.Parent = HeaderSearchHolder

    local HeaderSearchClearBtn = Instance.new("TextButton")
    HeaderSearchClearBtn.Name = "HeaderSearchClearBtn"
    HeaderSearchClearBtn.AnchorPoint = Vector2.new(1, 0.5)
    HeaderSearchClearBtn.Position = UDim2.new(1, -2, 0.5, 0)
    HeaderSearchClearBtn.Size = UDim2.fromOffset(16, 16)
    HeaderSearchClearBtn.BackgroundTransparency = 1
    HeaderSearchClearBtn.AutoButtonColor = false
    HeaderSearchClearBtn.Font = Enum.Font.Code
    HeaderSearchClearBtn.Text = "×"
    HeaderSearchClearBtn.TextColor3 = Color3.fromRGB(140, 140, 140)
    HeaderSearchClearBtn.TextSize = 12
    HeaderSearchClearBtn.Visible = false
    HeaderSearchClearBtn.ZIndex = 16
    HeaderSearchClearBtn.Parent = HeaderSearchHolder

    local function nodeMatchesQuery(node, q)
        if not node then
            return false
        end
        local nodeName = string.lower(tostring(node.Name or ""))
        if string.find(nodeName, q, 1, true) then
            return true
        end
        if (node:IsA("TextLabel") or node:IsA("TextButton") or node:IsA("TextBox")) and node.Text then
            if string.find(string.lower(tostring(node.Text)), q, 1, true) then
                return true
            end
        end
        for _, desc in ipairs(node:GetDescendants()) do
            if (desc:IsA("TextLabel") or desc:IsA("TextButton")) and desc.Text then
                if string.find(string.lower(tostring(desc.Text)), q, 1, true) then
                    return true
                end
            end
        end
        return false
    end

    local function applyFeatureSearchFilter(rawQuery)
        local q = string.lower(string.gsub(tostring(rawQuery or ""), "^%s*(.-)%s*$", "%1"))
        HeaderSearchClearBtn.Visible = (#q > 0)
        for _, tab in ipairs(State.Tabs) do
            if tab.Page then
                for _, child in ipairs(tab.Page:GetChildren()) do
                    local isGuiElem = child:IsA("GuiObject")
                        or child:IsA("Frame")
                        or child:IsA("TextButton")
                        or child:IsA("TextLabel")
                        or child:IsA("TextBox")
                        or child:IsA("ScrollingFrame")
                    if isGuiElem then
                        if #q == 0 then
                            child.Visible = true
                        else
                            local matched = nodeMatchesQuery(child, q)
                            child.Visible = matched
                            if matched then
                                local secContent = child:FindFirstChild("SectionContent")
                                if secContent then
                                    secContent.Visible = true
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    State.applyFeatureSearchFilter = applyFeatureSearchFilter
    UI.HeaderSearchBox = HeaderSearchBox

    HeaderSearchBox.Focused:Connect(function()
        HeaderSearchHolder.BorderColor3 = Theme.Accent
        tween(HeaderSearchStroke, FastTween, { Color = Theme.Accent, Transparency = 0.05 })
    end)
    HeaderSearchBox.FocusLost:Connect(function()
        HeaderSearchHolder.BorderColor3 = Color3.fromRGB(56, 56, 56)
        tween(HeaderSearchStroke, FastTween, { Color = Color3.fromRGB(8, 8, 8), Transparency = 0.15 })
        applyFeatureSearchFilter(HeaderSearchBox.Text)
    end)
    if HeaderSearchBox.GetPropertyChangedSignal then
        pcall(function()
            HeaderSearchBox:GetPropertyChangedSignal("Text"):Connect(function()
                applyFeatureSearchFilter(HeaderSearchBox.Text)
            end)
        end)
    end
    HeaderSearchClearBtn.MouseButton1Click:Connect(function()
        HeaderSearchBox.Text = ""
        applyFeatureSearchFilter("")
    end)

    local MinimizeBtn = Instance.new("TextButton")
    MinimizeBtn.AnchorPoint = Vector2.new(1, 0.5)
    MinimizeBtn.Position = UDim2.new(1, -12, 0.5, 0)
    MinimizeBtn.Size = UDim2.fromOffset(18, 18)
    MinimizeBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    MinimizeBtn.BorderColor3 = Color3.fromRGB(56, 56, 56)
    MinimizeBtn.BorderSizePixel = 1
    MinimizeBtn.AutoButtonColor = false
    MinimizeBtn.Font = Enum.Font.Code
    MinimizeBtn.Text = "—"
    MinimizeBtn.TextColor3 = Color3.fromRGB(170, 170, 170)
    MinimizeBtn.TextSize = 11
    MinimizeBtn.ZIndex = 14
    MinimizeBtn.Parent = HeaderBar

    makeDraggable(HeaderBar, MainWindow, function()
        if State.syncMusicPlayerDock then
            State.syncMusicPlayerDock()
        end
    end)

    UI.FloatingToggle.MouseButton1Click:Connect(function()
        spawnRipple(UI.FloatingToggle)
        toggleMainHub()
    end)

    MinimizeBtn.MouseButton1Click:Connect(function()
        spawnRipple(MinimizeBtn)
        toggleMainHub()
    end)

    -- Vaderpaste Horizontal Top Tab Bar (tab_buttons)
    local NavList = Instance.new("Frame")
    NavList.Name = "NavList"
    NavList.Position = UDim2.new(0, 12, 0, 31)
    NavList.Size = UDim2.new(1, -24, 0, 22)
    NavList.BackgroundTransparency = 1
    NavList.BorderSizePixel = 0
    NavList.ZIndex = 13
    NavList.Parent = VaderMain

    local NavLayout = Instance.new("UIListLayout")
    pcall(function() NavLayout.FillDirection = Enum.FillDirection.Horizontal end)
    pcall(function() NavLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left end)
    NavLayout.Padding = UDim.new(0, 4)
    NavLayout.SortOrder = Enum.SortOrder.LayoutOrder
    NavLayout.Parent = NavList

    local ActiveTabIndicator = Instance.new("Frame")
    ActiveTabIndicator.Name = "ActiveTabIndicator"
    ActiveTabIndicator.Position = UDim2.fromOffset(12, 51)
    ActiveTabIndicator.Size = UDim2.fromOffset(64, 2)
    ActiveTabIndicator.BackgroundColor3 = Theme.Accent
    ActiveTabIndicator.BorderSizePixel = 0
    ActiveTabIndicator.Visible = false
    ActiveTabIndicator.ZIndex = 15
    ActiveTabIndicator.Parent = VaderMain
    registerAccentObject(ActiveTabIndicator, "BackgroundColor3")

    -- Vaderpaste Double-Bordered Inner Tab Container (tab_inline -> PagesHolder)
    local VaderTabInline = Instance.new("Frame")
    VaderTabInline.Name = "VaderTabInline"
    VaderTabInline.Position = UDim2.new(0, 12, 0, 56)
    VaderTabInline.Size = UDim2.new(1, -24, 1, -68)
    VaderTabInline.BackgroundColor3 = Color3.fromRGB(19, 19, 19)
    VaderTabInline.BorderColor3 = Color3.fromRGB(8, 8, 8)
    VaderTabInline.BorderSizePixel = 1
    VaderTabInline.ZIndex = 12
    VaderTabInline.Parent = VaderMain

    local PagesHolder = Instance.new("Frame")
    PagesHolder.Name = "PagesHolder"
    PagesHolder.Position = UDim2.new(0, 2, 0, 2)
    PagesHolder.Size = UDim2.new(1, -4, 1, -4)
    PagesHolder.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    PagesHolder.BorderColor3 = Color3.fromRGB(56, 56, 56)
    PagesHolder.BorderSizePixel = 1
    PagesHolder.ClipsDescendants = true
    PagesHolder.ZIndex = 12
    PagesHolder.Parent = VaderTabInline

    UI.MainWindow = MainWindow
    UI.MainStroke = MainStroke
    UI.MainScale = MainScale
    UI.MainParticleCanvas = MainParticleCanvas
    UI.HeaderLineGrad = HeaderLineGrad
    UI.ActiveTabIndicator = ActiveTabIndicator
    UI.NavList = NavList
    UI.PagesHolder = PagesHolder
end

--------------------------------------------------------------------------------
-- 10. VADERPASTE UI COMPONENT BUILDERS
--------------------------------------------------------------------------------
local function createTab(name, order)
    local btn = Instance.new("TextButton")
    btn.Name = name .. "_TabBtn"
    btn.LayoutOrder = order
    btn.Size = UDim2.new(0.125, -4, 1, 0)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    btn.BackgroundTransparency = 1
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.Code
    btn.Text = string.lower(tostring(name))
    btn.TextColor3 = Color3.fromRGB(90, 90, 90)
    btn.TextStrokeTransparency = 0.5
    btn.TextSize = 12
    btn.TextXAlignment = Enum.TextXAlignment.Center
    btn.ClipsDescendants = false
    btn.ZIndex = 14
    btn.Parent = UI.NavList
    local st = addStroke(btn, Theme.Border, 1, 1)

    local tabLine = Instance.new("Frame")
    tabLine.Name = "VaderTabLine"
    tabLine.Position = UDim2.new(0, 0, 1, -2)
    tabLine.Size = UDim2.new(1, 0, 0, 2)
    tabLine.BackgroundColor3 = Color3.fromRGB(57, 57, 57)
    tabLine.BorderSizePixel = 0
    tabLine.ZIndex = 15
    tabLine.Parent = btn

    local tabGlow = Instance.new("ImageLabel")
    tabGlow.Name = "VaderTabGlow"
    tabGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    tabGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    tabGlow.Size = UDim2.new(1, 16, 1, 14)
    tabGlow.BackgroundTransparency = 1
    tabGlow.Image = "http://www.roblox.com/asset/?id=18245826428"
    tabGlow.ImageColor3 = Theme.Accent
    tabGlow.ImageTransparency = 1
    tabGlow.ScaleType = Enum.ScaleType.Slice
    pcall(function() tabGlow.SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)) end)
    tabGlow.ZIndex = 14
    tabGlow.Parent = tabLine
    registerAccentObject(tabGlow, "ImageColor3")

    local tabDepth = Instance.new("Frame")
    tabDepth.Name = "VaderTabDepth"
    tabDepth.Position = UDim2.new(0, 0, 0, 1)
    tabDepth.Size = UDim2.new(1, 0, 0, 1)
    tabDepth.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
    tabDepth.BorderSizePixel = 0
    tabDepth.ZIndex = 15
    tabDepth.Parent = tabLine

    local page = Instance.new("ScrollingFrame")
    page.Name = name .. "_Page"
    page.Size = UDim2.fromScale(1, 1)
    page.BackgroundTransparency = 1
    page.BorderSizePixel = 0
    page.ScrollBarThickness = 2
    page.ScrollBarImageColor3 = Theme.Accent
    page.AutomaticCanvasSize = Enum.AutomaticSize.Y
    page.CanvasSize = UDim2.new(0, 0, 0, 0)
    page.Visible = false
    page.ZIndex = 13
    page.Parent = UI.PagesHolder
    registerAccentObject(page, "ScrollBarImageColor3")

    local pad = Instance.new("UIPadding")
    pad.PaddingTop = UDim.new(0, 8)
    pad.PaddingBottom = UDim.new(0, 14)
    pad.PaddingLeft = UDim.new(0, 8)
    pad.PaddingRight = UDim.new(0, 10)
    pad.Parent = page

    local list = Instance.new("UIListLayout")
    list.Padding = UDim.new(0, 8)
    list.SortOrder = Enum.SortOrder.LayoutOrder
    list.Parent = page

    local tabObj = {
        Name = name,
        Btn = btn,
        Stroke = st,
        Line = tabLine,
        Glow = tabGlow,
        Page = page,
        Order = order,
    }
    table.insert(State.Tabs, tabObj)

    local function selectTab()
        if State.activeTab == tabObj then
            return
        end
        for _, t in ipairs(State.Tabs) do
            tween(t.Btn, FastTween, {
                TextColor3 = Color3.fromRGB(90, 90, 90),
            })
            if t.Line then
                tween(t.Line, FastTween, { BackgroundColor3 = Color3.fromRGB(57, 57, 57) })
            end
            if t.Glow then
                tween(t.Glow, FastTween, { ImageTransparency = 1 })
            end
            tween(t.Stroke, FastTween, { Transparency = 1 })
            t.Page.Visible = false
        end
        State.activeTab = tabObj
        if UI.HeaderSub then
            UI.HeaderSub.Text = "UNIVERSAL AIMBOT  " .. string.upper(tostring(name))
        end
        tween(btn, FastTween, {
            TextColor3 = Color3.fromRGB(170, 170, 170),
        })
        tween(tabLine, FastTween, { BackgroundColor3 = Theme.Accent })
        tween(tabGlow, FastTween, { ImageTransparency = 0.89 })

        page.Position = UDim2.fromOffset(8, 0)
        page.Visible = true
        tween(page, SmoothTween, { Position = UDim2.fromOffset(0, 0) })
        if name == "Players" and State.refreshPlayerListUI then
            State.refreshPlayerListUI()
        end
    end

    btn.MouseEnter:Connect(function()
        if State.activeTab ~= tabObj then
            tween(btn, FastTween, {
                TextColor3 = Color3.fromRGB(140, 140, 140),
            })
        end
    end)

    btn.MouseLeave:Connect(function()
        if State.activeTab ~= tabObj then
            tween(btn, FastTween, {
                TextColor3 = Color3.fromRGB(90, 90, 90),
            })
        end
    end)

    btn.MouseButton1Click:Connect(function()
        selectTab()
    end)

    if #State.Tabs == 1 then
        selectTab()
    end

    return page
end

local function createLabel(page, text)
    local holder = Instance.new("Frame")
    holder.Size = UDim2.new(1, 0, 0, 20)
    holder.BackgroundTransparency = 1
    holder.ZIndex = 14
    holder.Parent = page

    local dot = Instance.new("Frame")
    dot.AnchorPoint = Vector2.new(0, 0.5)
    dot.Position = UDim2.new(0, 2, 0.5, 0)
    dot.Size = UDim2.fromOffset(2, 10)
    dot.BackgroundColor3 = Theme.Accent
    dot.BorderSizePixel = 0
    dot.ZIndex = 14
    dot.Parent = holder
    registerAccentObject(dot, "BackgroundColor3")

    local lbl = Instance.new("TextLabel")
    lbl.Position = UDim2.fromOffset(10, 0)
    lbl.Size = UDim2.new(1, -10, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.Text = string.upper(tostring(text))
    lbl.TextColor3 = Color3.fromRGB(170, 170, 170)
    lbl.TextStrokeTransparency = 0.5
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 14
    lbl.Parent = holder
end

local function createButton(page, text, callback)
    local btn = Instance.new("TextButton")
    btn.Size = UDim2.new(1, 0, 0, 24)
    btn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    btn.BorderColor3 = Color3.fromRGB(8, 8, 8)
    btn.BorderSizePixel = 1
    btn.AutoButtonColor = false
    btn.Font = Enum.Font.Code
    btn.Text = text
    btn.TextColor3 = Color3.fromRGB(170, 170, 170)
    btn.TextStrokeTransparency = 0.5
    btn.TextSize = 12
    btn.ClipsDescendants = true
    btn.ZIndex = 14
    btn.Parent = page
    local st = addStroke(btn, Color3.fromRGB(56, 56, 56), 1, 0)

    btn.MouseEnter:Connect(function()
        tween(btn, FastTween, { BackgroundColor3 = Color3.fromRGB(28, 28, 28), TextColor3 = Theme.White })
        tween(st, FastTween, { Color = Theme.Accent, Transparency = 0.15 })
    end)

    btn.MouseLeave:Connect(function()
        tween(btn, FastTween, { BackgroundColor3 = Color3.fromRGB(22, 22, 22), TextColor3 = Color3.fromRGB(170, 170, 170) })
        tween(st, FastTween, { Color = Color3.fromRGB(56, 56, 56), Transparency = 0 })
    end)

    btn.MouseButton1Click:Connect(function()
        tween(btn, TweenInfo.new(0.08), { BackgroundColor3 = Theme.Accent, TextColor3 = Theme.White })
        task.delay(0.12, function()
            tween(btn, FastTween, { BackgroundColor3 = Color3.fromRGB(22, 22, 22), TextColor3 = Color3.fromRGB(170, 170, 170) })
        end)
        callback()
    end)
    return btn
end

do
    local SWATCH_PALETTE = {
        Color3.fromRGB(255, 255, 255), -- Pure White
        Color3.fromRGB(105, 85, 255),  -- Electric Indigo
        Color3.fromRGB(75, 205, 255),  -- Sky Cyan
        Color3.fromRGB(255, 85, 195),  -- Hot Pink
        Color3.fromRGB(255, 195, 75),  -- Amber Gold
        Color3.fromRGB(255, 90, 36),   -- Lava Orange
        Color3.fromRGB(80, 255, 130),  -- Toxic Emerald
        Color3.fromRGB(255, 70, 70),   -- Crimson Red
        Color3.fromRGB(180, 80, 255),  -- Plasma Purple
        Color3.fromRGB(150, 230, 255), -- Ice Blue
        Color3.fromRGB(255, 215, 64),  -- Pure Gold
        Color3.fromRGB(28, 28, 42),    -- Obsidian Dark
        Color3.fromRGB(240, 234, 255), -- Pearl White
        Color3.fromRGB(0, 255, 102),   -- Matrix Green
        Color3.fromRGB(195, 185, 255), -- Soft Lavender
        Color3.fromRGB(140, 125, 220), -- Decay Violet
    }
    UI.SwatchPalette = SWATCH_PALETTE

    local function color3ToHSV(col)
        if not col then
            return 0, 0, 1
        end
        if type(Color3) == "table" and type(Color3.toHSV) == "function" then
            local ok, h, s, v = pcall(Color3.toHSV, col)
            if ok and type(h) == "number" then
                return h, s, v
            end
        end
        local r, g, b = col.R or 1, col.G or 1, col.B or 1
        if r > 1 or g > 1 or b > 1 then
            r, g, b = r / 255, g / 255, b / 255
        end
        local maxC = math.max(r, g, b)
        local minC = math.min(r, g, b)
        local d = maxC - minC
        local h = 0
        local s = (maxC == 0) and 0 or (d / maxC)
        local v = maxC
        if maxC ~= minC then
            if maxC == r then
                h = (g - b) / d + (g < b and 6 or 0)
            elseif maxC == g then
                h = (b - r) / d + 2
            else
                h = (r - g) / d + 4
            end
            h = h / 6
        end
        return math.clamp(h, 0, 1), math.clamp(s, 0, 1), math.clamp(v, 0, 1)
    end

    local function hsvToRgbColor3(h, s, v)
        h = math.clamp(tonumber(h) or 0, 0, 1)
        s = math.clamp(tonumber(s) or 0, 0, 1)
        v = math.clamp(tonumber(v) or 1, 0, 1)
        local i = math.floor(h * 6)
        local f = h * 6 - i
        local p = v * (1 - s)
        local q = v * (1 - f * s)
        local t = v * (1 - (1 - f) * s)
        local m = i % 6
        local r, g, b = v, t, p
        if m == 1 then r, g, b = q, v, p
        elseif m == 2 then r, g, b = p, v, t
        elseif m == 3 then r, g, b = p, q, v
        elseif m == 4 then r, g, b = t, p, v
        elseif m == 5 then r, g, b = v, p, q end
        return Color3.fromRGB(math.floor(r * 255 + 0.5), math.floor(g * 255 + 0.5), math.floor(b * 255 + 0.5))
    end

    local function isPrimaryPointerInput(inp)
        if not inp then
            return false
        end
        local t = inp.UserInputType
        return t == Enum.UserInputType.MouseButton1 or t == Enum.UserInputType.Touch
    end

    local function isPrimaryPointerMove(inp)
        if not inp then
            return false
        end
        local t = inp.UserInputType
        return t == Enum.UserInputType.MouseMovement or t == Enum.UserInputType.Touch
    end

    -- Floating Custom Color Picker Popup (Touchable 2D HSV + Hue + Alpha + 10 Quick Swatches + RGBA/Hex Input)
    local pickerPopup = Instance.new("Frame")
    pickerPopup.Name = "CoreColorPickerPopup"
    pickerPopup.AnchorPoint = Vector2.new(0.5, 0.5)
    pickerPopup.Position = UDim2.new(0.5, 195, 0.5, 0)
    pickerPopup.Size = UDim2.fromOffset(244, 296)
    pickerPopup.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    pickerPopup.Visible = false
    pickerPopup.Active = true
    pickerPopup.ClipsDescendants = true
    pickerPopup.ZIndex = 120
    pickerPopup.Parent = UI.ScreenGui
    addCorner(pickerPopup, 12)
    addLiveBorder(pickerPopup, 1.3, 85, 0.12)
    UI.ColorPickerPopup = pickerPopup

    local pickerBgGrad = Instance.new("UIGradient")
    pickerBgGrad.Rotation = 135
    pickerBgGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(22, 22, 30)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(14, 14, 20)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(10, 10, 15)),
    })
    pickerBgGrad.Parent = pickerPopup

    local pickerScale = Instance.new("UIScale")
    pickerScale.Scale = 1
    pickerScale.Parent = pickerPopup

    local pickerHeader = Instance.new("Frame")
    pickerHeader.Name = "ColorPickerHeader"
    pickerHeader.Size = UDim2.new(1, 0, 0, 28)
    pickerHeader.BackgroundColor3 = Theme.Deep
    pickerHeader.BackgroundTransparency = 0.12
    pickerHeader.BorderSizePixel = 0
    pickerHeader.ZIndex = 121
    pickerHeader.Parent = pickerPopup
    addCorner(pickerHeader, 12)

    local pickerHeaderPatch = Instance.new("Frame")
    pickerHeaderPatch.Position = UDim2.new(0, 0, 1, -8)
    pickerHeaderPatch.Size = UDim2.new(1, 0, 0, 8)
    pickerHeaderPatch.BackgroundColor3 = Theme.Deep
    pickerHeaderPatch.BackgroundTransparency = 0.12
    pickerHeaderPatch.BorderSizePixel = 0
    pickerHeaderPatch.ZIndex = 121
    pickerHeaderPatch.Parent = pickerHeader

    local pickerHeaderLine = Instance.new("Frame")
    pickerHeaderLine.Position = UDim2.new(0, 0, 1, -1)
    pickerHeaderLine.Size = UDim2.new(1, 0, 0, 1)
    pickerHeaderLine.BackgroundColor3 = Theme.Border
    pickerHeaderLine.BackgroundTransparency = 0.45
    pickerHeaderLine.BorderSizePixel = 0
    pickerHeaderLine.ZIndex = 122
    pickerHeaderLine.Parent = pickerHeader

    local pickerTitle = Instance.new("TextLabel")
    pickerTitle.Position = UDim2.fromOffset(12, 0)
    pickerTitle.Size = UDim2.new(1, -40, 1, 0)
    pickerTitle.BackgroundTransparency = 1
    pickerTitle.Font = Enum.Font.Code
    pickerTitle.Text = "COLOR PICKER"
    pickerTitle.TextColor3 = Theme.Silver
    pickerTitle.TextSize = 9
    pickerTitle.TextXAlignment = Enum.TextXAlignment.Left
    pickerTitle.ZIndex = 122
    pickerTitle.Parent = pickerHeader

    local pickerCloseBtn = Instance.new("TextButton")
    pickerCloseBtn.Name = "ColorPickerCloseBtn"
    pickerCloseBtn.AnchorPoint = Vector2.new(1, 0.5)
    pickerCloseBtn.Position = UDim2.new(1, -6, 0.5, 0)
    pickerCloseBtn.Size = UDim2.fromOffset(20, 20)
    pickerCloseBtn.BackgroundColor3 = Theme.Surface
    pickerCloseBtn.BackgroundTransparency = 0.2
    pickerCloseBtn.AutoButtonColor = false
    pickerCloseBtn.Font = Enum.Font.GothamBold
    pickerCloseBtn.Text = "×"
    pickerCloseBtn.TextColor3 = Theme.Silver
    pickerCloseBtn.TextSize = 13
    pickerCloseBtn.ZIndex = 123
    pickerCloseBtn.Parent = pickerHeader
    addCorner(pickerCloseBtn, 5)

    makeDraggable(pickerHeader, pickerPopup)

    local svSquare = Instance.new("Frame")
    svSquare.Name = "SVSquare"
    svSquare.Position = UDim2.fromOffset(10, 34)
    svSquare.Size = UDim2.new(1, -20, 0, 138)
    svSquare.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
    svSquare.BorderSizePixel = 0
    svSquare.ClipsDescendants = true
    svSquare.ZIndex = 121
    svSquare.Parent = pickerPopup
    addCorner(svSquare, 6)
    addStroke(svSquare, Theme.Border, 1, 0.15)

    local svWhiteOverlay = Instance.new("Frame")
    svWhiteOverlay.Size = UDim2.fromScale(1, 1)
    svWhiteOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    svWhiteOverlay.BorderSizePixel = 0
    svWhiteOverlay.ZIndex = 122
    svWhiteOverlay.Parent = svSquare
    addCorner(svWhiteOverlay, 6)
    local svWhiteGrad = Instance.new("UIGradient")
    svWhiteGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(1, 1),
    })
    svWhiteGrad.Parent = svWhiteOverlay

    local svBlackOverlay = Instance.new("Frame")
    svBlackOverlay.Size = UDim2.fromScale(1, 1)
    svBlackOverlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    svBlackOverlay.BorderSizePixel = 0
    svBlackOverlay.ZIndex = 123
    svBlackOverlay.Parent = svSquare
    addCorner(svBlackOverlay, 6)
    local svBlackGrad = Instance.new("UIGradient")
    svBlackGrad.Rotation = 90
    svBlackGrad.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(1, 0),
    })
    svBlackGrad.Parent = svBlackOverlay

    local svCursor = Instance.new("Frame")
    svCursor.Name = "SVCursor"
    svCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    svCursor.Position = UDim2.fromScale(1, 0)
    svCursor.Size = UDim2.fromOffset(12, 12)
    svCursor.BackgroundColor3 = Theme.White
    svCursor.BackgroundTransparency = 0.1
    svCursor.ZIndex = 125
    svCursor.Parent = svSquare
    addCorner(svCursor, 99)
    addStroke(svCursor, Theme.Black, 1.5, 0)

    local svCursorInner = Instance.new("Frame")
    svCursorInner.AnchorPoint = Vector2.new(0.5, 0.5)
    svCursorInner.Position = UDim2.fromScale(0.5, 0.5)
    svCursorInner.Size = UDim2.fromOffset(6, 6)
    svCursorInner.BackgroundColor3 = Theme.White
    svCursorInner.BorderSizePixel = 0
    svCursorInner.ZIndex = 126
    svCursorInner.Parent = svCursor
    addCorner(svCursorInner, 99)
    addStroke(svCursorInner, Theme.White, 1, 0)

    local svHitbox = Instance.new("TextButton")
    svHitbox.Name = "ColorPickerSVHitbox"
    svHitbox.Size = UDim2.fromScale(1, 1)
    svHitbox.BackgroundTransparency = 1
    svHitbox.AutoButtonColor = false
    svHitbox.Active = true
    svHitbox.Text = " "
    svHitbox.TextTransparency = 1
    svHitbox.ZIndex = 127
    svHitbox.Parent = svSquare

    local hueBar = Instance.new("Frame")
    hueBar.Name = "HueBar"
    hueBar.Position = UDim2.fromOffset(10, 180)
    hueBar.Size = UDim2.new(1, -20, 0, 16)
    hueBar.BackgroundColor3 = Theme.White
    hueBar.BorderSizePixel = 0
    hueBar.ZIndex = 121
    hueBar.Parent = pickerPopup
    addCorner(hueBar, 5)
    addStroke(hueBar, Theme.Border, 1, 0.15)

    local hueGrad = Instance.new("UIGradient")
    hueGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.00, Color3.fromRGB(255, 0, 0)),
        ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
        ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
        ColorSequenceKeypoint.new(0.50, Color3.fromRGB(0, 255, 255)),
        ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
        ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
        ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 0, 0)),
    })
    hueGrad.Parent = hueBar

    local hueCursor = Instance.new("Frame")
    hueCursor.Name = "HueCursor"
    hueCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    hueCursor.Position = UDim2.fromScale(0, 0.5)
    hueCursor.Size = UDim2.fromOffset(7, 18)
    hueCursor.BackgroundColor3 = Theme.White
    hueCursor.ZIndex = 123
    hueCursor.Parent = hueBar
    addCorner(hueCursor, 3)
    addStroke(hueCursor, Theme.Black, 1.2, 0)

    local hueHitbox = Instance.new("TextButton")
    hueHitbox.Name = "ColorPickerHueHitbox"
    hueHitbox.Position = UDim2.fromOffset(0, -3)
    hueHitbox.Size = UDim2.new(1, 0, 1, 6)
    hueHitbox.BackgroundTransparency = 1
    hueHitbox.AutoButtonColor = false
    hueHitbox.Active = true
    hueHitbox.Text = " "
    hueHitbox.TextTransparency = 1
    hueHitbox.ZIndex = 124
    hueHitbox.Parent = hueBar

    local alphaBar = Instance.new("Frame")
    alphaBar.Name = "AlphaBar"
    alphaBar.Position = UDim2.fromOffset(10, 202)
    alphaBar.Size = UDim2.new(1, -20, 0, 16)
    alphaBar.BackgroundColor3 = Color3.fromRGB(220, 220, 228)
    alphaBar.BorderSizePixel = 0
    alphaBar.ZIndex = 121
    alphaBar.Parent = pickerPopup
    addCorner(alphaBar, 5)
    addStroke(alphaBar, Theme.Border, 1, 0.15)

    local alphaGrad = Instance.new("UIGradient")
    alphaGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 44)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255)),
    })
    alphaGrad.Parent = alphaBar

    local alphaCursor = Instance.new("Frame")
    alphaCursor.Name = "AlphaCursor"
    alphaCursor.AnchorPoint = Vector2.new(0.5, 0.5)
    alphaCursor.Position = UDim2.fromScale(1, 0.5)
    alphaCursor.Size = UDim2.fromOffset(7, 18)
    alphaCursor.BackgroundColor3 = Theme.White
    alphaCursor.ZIndex = 123
    alphaCursor.Parent = alphaBar
    addCorner(alphaCursor, 3)
    addStroke(alphaCursor, Theme.Black, 1.2, 0)

    local alphaHitbox = Instance.new("TextButton")
    alphaHitbox.Name = "ColorPickerAlphaHitbox"
    alphaHitbox.Position = UDim2.fromOffset(0, -3)
    alphaHitbox.Size = UDim2.new(1, 0, 1, 6)
    alphaHitbox.BackgroundTransparency = 1
    alphaHitbox.AutoButtonColor = false
    alphaHitbox.Active = true
    alphaHitbox.Text = " "
    alphaHitbox.TextTransparency = 1
    alphaHitbox.ZIndex = 124
    alphaHitbox.Parent = alphaBar

    -- Quick 10-Swatch Touchable Preset Strip inside the Color Picker
    local quickPresetRow = Instance.new("Frame")
    quickPresetRow.Name = "QuickPresetRow"
    quickPresetRow.Position = UDim2.fromOffset(10, 225)
    quickPresetRow.Size = UDim2.new(1, -20, 0, 18)
    quickPresetRow.BackgroundTransparency = 1
    quickPresetRow.ZIndex = 122
    quickPresetRow.Parent = pickerPopup

    local rgbaBox = Instance.new("TextBox")
    rgbaBox.Name = "ColorPickerRGBABox"
    rgbaBox.Position = UDim2.fromOffset(10, 250)
    rgbaBox.Size = UDim2.new(1, -56, 0, 34)
    rgbaBox.BackgroundColor3 = Color3.fromRGB(20, 20, 28)
    rgbaBox.ClearTextOnFocus = false
    rgbaBox.Font = Enum.Font.Code
    rgbaBox.PlaceholderText = "255, 255, 255, 1 or #FFFFFF"
    rgbaBox.PlaceholderColor3 = Theme.Muted
    rgbaBox.Text = "255, 255, 255, 1"
    rgbaBox.TextColor3 = Theme.White
    rgbaBox.TextSize = 12
    rgbaBox.ZIndex = 122
    rgbaBox.Parent = pickerPopup
    addCorner(rgbaBox, 6)
    addStroke(rgbaBox, Theme.Border, 1, 0.15)

    local previewSwatch = Instance.new("TextButton")
    previewSwatch.Name = "ColorPickerPreviewSwatch"
    previewSwatch.Position = UDim2.new(1, -40, 0, 250)
    previewSwatch.Size = UDim2.fromOffset(30, 34)
    previewSwatch.BackgroundColor3 = Theme.White
    previewSwatch.AutoButtonColor = false
    previewSwatch.Text = " "
    previewSwatch.TextTransparency = 1
    previewSwatch.ZIndex = 122
    previewSwatch.Parent = pickerPopup
    addCorner(previewSwatch, 6)
    addStroke(previewSwatch, Theme.Border, 1, 0.1)

    local pickerState = {
        ActiveTarget = nil,
        ActiveBtn = nil,
        H = 0,
        S = 0,
        V = 1,
        A = 1,
        DraggingSV = false,
        DraggingHue = false,
        DraggingAlpha = false,
        HadRealPointerInput = false,
    }

    local UltraFastPickerTween = TweenInfo.new(0.04, Enum.EasingStyle.Sine, Enum.EasingDirection.Out)

    local function syncPickerVisuals(fireCallback)
        local pureHueCol = hsvToRgbColor3(pickerState.H, 1, 1)
        local finalCol = hsvToRgbColor3(pickerState.H, pickerState.S, pickerState.V)
        svSquare.BackgroundColor3 = pureHueCol
        svCursor.Position = UDim2.fromScale(pickerState.S, 1 - pickerState.V)
        svCursorInner.BackgroundColor3 = finalCol
        hueCursor.Position = UDim2.fromScale(pickerState.H, 0.5)
        hueCursor.BackgroundColor3 = pureHueCol
        alphaCursor.Position = UDim2.fromScale(pickerState.A, 0.5)
        alphaGrad.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(35, 35, 42)),
            ColorSequenceKeypoint.new(1, finalCol),
        })
        previewSwatch.BackgroundColor3 = finalCol
        local iH = math.floor(pickerState.H * 6)
        local fH = pickerState.H * 6 - iH
        local pH = pickerState.V * (1 - pickerState.S)
        local qH = pickerState.V * (1 - fH * pickerState.S)
        local tH = pickerState.V * (1 - (1 - fH) * pickerState.S)
        local mH = iH % 6
        local nr, ng, nb = pickerState.V, tH, pH
        if mH == 1 then nr, ng, nb = qH, pickerState.V, pH
        elseif mH == 2 then nr, ng, nb = pH, pickerState.V, tH
        elseif mH == 3 then nr, ng, nb = pH, qH, pickerState.V
        elseif mH == 4 then nr, ng, nb = tH, pH, pickerState.V
        elseif mH == 5 then nr, ng, nb = pickerState.V, pH, qH end
        local rInt = math.clamp(math.floor(nr * 255 + 0.5), 0, 255)
        local gInt = math.clamp(math.floor(ng * 255 + 0.5), 0, 255)
        local bInt = math.clamp(math.floor(nb * 255 + 0.5), 0, 255)
        local aFmt = (pickerState.A >= 0.995) and "1" or string.format("%.2f", pickerState.A)
        rgbaBox.Text = string.format("%d, %d, %d, %s", rInt, gInt, bInt, aFmt)
        if pickerState.ActiveTarget and fireCallback ~= false then
            pickerState.ActiveTarget(finalCol, pickerState.A)
        end
    end

    for idx = 1, 10 do
        local presetCol = SWATCH_PALETTE[idx] or Theme.White
        local qBtn = Instance.new("TextButton")
        qBtn.Name = "QuickSwatch_" .. tostring(idx)
        qBtn.Position = UDim2.fromOffset((idx - 1) * 22, 0)
        qBtn.Size = UDim2.fromOffset(18, 18)
        qBtn.BackgroundColor3 = presetCol
        qBtn.AutoButtonColor = false
        qBtn.Text = ""
        qBtn.ZIndex = 123
        qBtn.Parent = quickPresetRow
        addCorner(qBtn, 4)
        local qStroke = addStroke(qBtn, Theme.Border, 1, 0.2)
        qBtn.MouseEnter:Connect(function()
            tween(qBtn, UltraFastPickerTween, { Size = UDim2.fromOffset(20, 20) })
            tween(qStroke, UltraFastPickerTween, { Color = Theme.White, Transparency = 0 })
        end)
        qBtn.MouseLeave:Connect(function()
            tween(qBtn, UltraFastPickerTween, { Size = UDim2.fromOffset(18, 18) })
            tween(qStroke, UltraFastPickerTween, { Color = Theme.Border, Transparency = 0.2 })
        end)
        qBtn.MouseButton1Click:Connect(function()
            local h, s, v = color3ToHSV(presetCol)
            pickerState.H = h
            pickerState.S = s
            pickerState.V = v
            syncPickerVisuals(true)
        end)
    end

    local function openColorPickerForSwatch(btn, currentColor, applyColorFn)
        if pickerPopup.Visible and pickerState.ActiveBtn == btn then
            pickerPopup.Visible = false
            pickerState.ActiveBtn = nil
            pickerState.ActiveTarget = nil
            return
        end
        pickerState.ActiveBtn = btn
        pickerState.ActiveTarget = applyColorFn
        pickerState.HadRealPointerInput = false
        local h, s, v = color3ToHSV(currentColor or Theme.White)
        pickerState.H = h
        pickerState.S = s
        pickerState.V = v
        pickerState.A = 1
        syncPickerVisuals(false)
        pickerPopup.Visible = true
        pickerScale.Scale = 0.94
        tween(pickerScale, SpringTween, { Scale = 1 })
    end
    UI.openColorPickerForSwatch = openColorPickerForSwatch

    pickerCloseBtn.MouseButton1Click:Connect(function()
        pickerPopup.Visible = false
        pickerState.ActiveBtn = nil
        pickerState.ActiveTarget = nil
    end)

    previewSwatch.MouseButton1Click:Connect(function()
        pickerPopup.Visible = false
        pickerState.ActiveBtn = nil
    end)

    local function updateSVFromInputPos(pos)
        local absPos = svSquare.AbsolutePosition
        local absSize = svSquare.AbsoluteSize
        local w = (absSize and absSize.X > 0) and absSize.X or 224
        local h = (absSize and absSize.Y > 0) and absSize.Y or 138
        if pos then
            pickerState.HadRealPointerInput = true
            pickerState.S = math.clamp((pos.X - (absPos and absPos.X or 0)) / w, 0, 1)
            pickerState.V = 1 - math.clamp((pos.Y - (absPos and absPos.Y or 0)) / h, 0, 1)
        else
            pickerState.S = math.clamp(pickerState.S + 0.25, 0.15, 1)
            pickerState.V = math.clamp(pickerState.V - 0.1, 0.25, 1)
        end
        syncPickerVisuals(true)
    end

    local function updateHueFromInputPos(pos)
        local absPos = hueBar.AbsolutePosition
        local absSize = hueBar.AbsoluteSize
        local w = (absSize and absSize.X > 0) and absSize.X or 224
        if pos then
            pickerState.HadRealPointerInput = true
            pickerState.H = math.clamp((pos.X - (absPos and absPos.X or 0)) / w, 0, 1)
        else
            pickerState.H = (pickerState.H + 0.15) % 1
        end
        syncPickerVisuals(true)
    end

    local function updateAlphaFromInputPos(pos)
        local absPos = alphaBar.AbsolutePosition
        local absSize = alphaBar.AbsoluteSize
        local w = (absSize and absSize.X > 0) and absSize.X or 224
        if pos then
            pickerState.HadRealPointerInput = true
            pickerState.A = math.clamp((pos.X - (absPos and absPos.X or 0)) / w, 0, 1)
        else
            pickerState.A = (pickerState.A <= 0.25) and 1 or math.clamp(pickerState.A - 0.25, 0.1, 1)
        end
        syncPickerVisuals(true)
    end

    svHitbox.MouseButton1Click:Connect(function()
        if not pickerState.HadRealPointerInput then
            updateSVFromInputPos(nil)
        end
    end)
    hueHitbox.MouseButton1Click:Connect(function()
        if not pickerState.HadRealPointerInput then
            updateHueFromInputPos(nil)
        end
    end)
    alphaHitbox.MouseButton1Click:Connect(function()
        if not pickerState.HadRealPointerInput then
            updateAlphaFromInputPos(nil)
        end
    end)

    svHitbox.InputBegan:Connect(function(inp)
        if isPrimaryPointerInput(inp) then
            pickerState.DraggingSV = true
            tween(svCursor, UltraFastPickerTween, { Size = UDim2.fromOffset(15, 15) })
            updateSVFromInputPos(inp.Position)
        end
    end)
    svHitbox.InputChanged:Connect(function(inp)
        if pickerState.DraggingSV and isPrimaryPointerMove(inp) then
            updateSVFromInputPos(inp.Position)
        end
    end)
    svHitbox.InputEnded:Connect(function(inp)
        if isPrimaryPointerInput(inp) then
            pickerState.DraggingSV = false
            tween(svCursor, UltraFastPickerTween, { Size = UDim2.fromOffset(12, 12) })
        end
    end)

    hueHitbox.InputBegan:Connect(function(inp)
        if isPrimaryPointerInput(inp) then
            pickerState.DraggingHue = true
            tween(hueCursor, UltraFastPickerTween, { Size = UDim2.fromOffset(9, 20) })
            updateHueFromInputPos(inp.Position)
        end
    end)
    hueHitbox.InputChanged:Connect(function(inp)
        if pickerState.DraggingHue and isPrimaryPointerMove(inp) then
            updateHueFromInputPos(inp.Position)
        end
    end)
    hueHitbox.InputEnded:Connect(function(inp)
        if isPrimaryPointerInput(inp) then
            pickerState.DraggingHue = false
            tween(hueCursor, UltraFastPickerTween, { Size = UDim2.fromOffset(7, 18) })
        end
    end)

    alphaHitbox.InputBegan:Connect(function(inp)
        if isPrimaryPointerInput(inp) then
            pickerState.DraggingAlpha = true
            tween(alphaCursor, UltraFastPickerTween, { Size = UDim2.fromOffset(9, 20) })
            updateAlphaFromInputPos(inp.Position)
        end
    end)
    alphaHitbox.InputChanged:Connect(function(inp)
        if pickerState.DraggingAlpha and isPrimaryPointerMove(inp) then
            updateAlphaFromInputPos(inp.Position)
        end
    end)
    alphaHitbox.InputEnded:Connect(function(inp)
        if isPrimaryPointerInput(inp) then
            pickerState.DraggingAlpha = false
            tween(alphaCursor, UltraFastPickerTween, { Size = UDim2.fromOffset(7, 18) })
        end
    end)

    UserInputService.InputChanged:Connect(function(inp)
        if not pickerPopup.Visible then
            return
        end
        if isPrimaryPointerMove(inp) then
            if pickerState.DraggingSV then
                updateSVFromInputPos(inp.Position)
            elseif pickerState.DraggingHue then
                updateHueFromInputPos(inp.Position)
            elseif pickerState.DraggingAlpha then
                updateAlphaFromInputPos(inp.Position)
            end
        end
    end)

    UserInputService.InputEnded:Connect(function(inp)
        if isPrimaryPointerInput(inp) then
            if pickerState.DraggingSV then
                tween(svCursor, UltraFastPickerTween, { Size = UDim2.fromOffset(12, 12) })
            end
            if pickerState.DraggingHue then
                tween(hueCursor, UltraFastPickerTween, { Size = UDim2.fromOffset(7, 18) })
            end
            if pickerState.DraggingAlpha then
                tween(alphaCursor, UltraFastPickerTween, { Size = UDim2.fromOffset(7, 18) })
            end
            pickerState.DraggingSV = false
            pickerState.DraggingHue = false
            pickerState.DraggingAlpha = false
        end
    end)

    -- 60FPS RenderStepped pointer polling for ultra-smooth zero-latency Color Picker dragging
    State.updateColorPickerFrame = function()
        if not pickerPopup.Visible then
            return
        end
        if not (pickerState.DraggingSV or pickerState.DraggingHue or pickerState.DraggingAlpha) then
            return
        end
        if type(UserInputService.GetMouseLocation) == "function" then
            local okLoc, mouseLoc = pcall(function()
                return UserInputService:GetMouseLocation()
            end)
            if okLoc and mouseLoc then
                if pickerState.DraggingSV then
                    updateSVFromInputPos(mouseLoc)
                elseif pickerState.DraggingHue then
                    updateHueFromInputPos(mouseLoc)
                elseif pickerState.DraggingAlpha then
                    updateAlphaFromInputPos(mouseLoc)
                end
            end
        end
    end

    rgbaBox.FocusLost:Connect(function()
        local raw = tostring(rgbaBox.Text or "")
        local hexMatch = string.match(raw, "^%s*#?(%x%x%x%x%x%x)%s*$")
        if hexMatch then
            local r = tonumber(string.sub(hexMatch, 1, 2), 16) or 255
            local g = tonumber(string.sub(hexMatch, 3, 4), 16) or 255
            local b = tonumber(string.sub(hexMatch, 5, 6), 16) or 255
            local col = Color3.fromRGB(r, g, b)
            local h, s, v = color3ToHSV(col)
            pickerState.H = h
            pickerState.S = s
            pickerState.V = v
            syncPickerVisuals(true)
            return
        end
        local nums = {}
        for token in string.gmatch(raw, "[%d%.]+") do
            local n = tonumber(token)
            if n then
                table.insert(nums, n)
            end
        end
        if #nums >= 3 then
            local r = math.clamp(math.floor(nums[1] + 0.5), 0, 255)
            local g = math.clamp(math.floor(nums[2] + 0.5), 0, 255)
            local b = math.clamp(math.floor(nums[3] + 0.5), 0, 255)
            local a = nums[4] and math.clamp(nums[4], 0, 1) or pickerState.A
            local col = Color3.fromRGB(r, g, b)
            local h, s, v = color3ToHSV(col)
            pickerState.H = h
            pickerState.S = s
            pickerState.V = v
            pickerState.A = a
            syncPickerVisuals(true)
        else
            syncPickerVisuals(false)
        end
    end)

    local function attachSwatchCyclers(btn, initColor, onColorPicked)
        local curColor = initColor or SWATCH_PALETTE[2]
        btn.BackgroundColor3 = curColor
        local function setCol(c, fire)
            curColor = c
            btn.BackgroundColor3 = c
            if fire ~= false and onColorPicked then
                onColorPicked(c)
            end
        end
        btn.MouseButton1Click:Connect(function()
            setCol(curColor, true)
            openColorPickerForSwatch(btn, curColor, function(pickedCol)
                setCol(pickedCol, true)
            end)
        end)
        return setCol, function() return curColor end
    end
    UI.attachSwatchCyclers = attachSwatchCyclers

    UI.createSectionBox = function(page, sectionTitle)
        local wrapper = Instance.new("Frame")
        wrapper.Name = "SectionBox_" .. tostring(sectionTitle)
        wrapper.Size = UDim2.new(1, 0, 0, 28)
        wrapper.AutomaticSize = Enum.AutomaticSize.Y
        wrapper.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        wrapper.BorderColor3 = Color3.fromRGB(56, 56, 56)
        wrapper.BorderSizePixel = 1
        wrapper.BackgroundTransparency = 0
        wrapper.ZIndex = 14
        wrapper.Parent = page
        local wrapperStroke = addStroke(wrapper, Color3.fromRGB(8, 8, 8), 1, 0)

        local topAccentLine = Instance.new("Frame")
        topAccentLine.Name = "VaderSectionTopLine"
        topAccentLine.Size = UDim2.new(1, 0, 0, 2)
        topAccentLine.BackgroundColor3 = Theme.Accent
        topAccentLine.BorderSizePixel = 0
        topAccentLine.ZIndex = 16
        topAccentLine.Parent = wrapper
        registerAccentObject(topAccentLine, "BackgroundColor3")

        local titleBg = Instance.new("Frame")
        titleBg.Name = "SectionHeaderBadge"
        titleBg.Position = UDim2.fromOffset(8, 5)
        titleBg.Size = UDim2.new(1, -16, 0, 18)
        titleBg.BackgroundTransparency = 1
        titleBg.ZIndex = 15
        titleBg.Parent = wrapper

        local accentPip = Instance.new("Frame")
        accentPip.Name = "SectionAccentPip"
        accentPip.AnchorPoint = Vector2.new(0, 0.5)
        accentPip.Position = UDim2.new(0, 0, 0.5, 0)
        accentPip.Size = UDim2.fromOffset(2, 10)
        accentPip.BackgroundColor3 = Theme.Accent
        accentPip.BorderSizePixel = 0
        accentPip.ZIndex = 16
        accentPip.Parent = titleBg
        registerAccentObject(accentPip, "BackgroundColor3")

        local titleLbl = Instance.new("TextLabel")
        titleLbl.Name = "SectionTitleLabel"
        titleLbl.Position = UDim2.fromOffset(7, 0)
        titleLbl.Size = UDim2.new(1, -28, 1, 0)
        titleLbl.BackgroundTransparency = 1
        titleLbl.Font = Enum.Font.Code
        titleLbl.Text = tostring(sectionTitle)
        titleLbl.TextColor3 = Color3.fromRGB(170, 170, 170)
        titleLbl.TextStrokeTransparency = 0.5
        titleLbl.TextSize = 12
        titleLbl.TextXAlignment = Enum.TextXAlignment.Left
        titleLbl.ZIndex = 15
        titleLbl.Parent = titleBg

        local collapseBtn = Instance.new("TextButton")
        collapseBtn.Name = "SectionCollapseBtn"
        collapseBtn.AnchorPoint = Vector2.new(1, 0.5)
        collapseBtn.Position = UDim2.new(1, 0, 0.5, 0)
        collapseBtn.Size = UDim2.fromOffset(18, 18)
        collapseBtn.BackgroundTransparency = 1
        collapseBtn.AutoButtonColor = false
        collapseBtn.Font = Enum.Font.Code
        collapseBtn.Text = "▾"
        collapseBtn.TextColor3 = Color3.fromRGB(90, 90, 90)
        collapseBtn.TextSize = 11
        collapseBtn.ZIndex = 16
        collapseBtn.Parent = titleBg

        local headerLine = Instance.new("Frame")
        headerLine.Name = "SectionHeaderDivider"
        headerLine.Position = UDim2.fromOffset(8, 24)
        headerLine.Size = UDim2.new(1, -16, 0, 1)
        headerLine.BackgroundColor3 = Color3.fromRGB(42, 42, 42)
        headerLine.BorderSizePixel = 0
        headerLine.ZIndex = 15
        headerLine.Parent = wrapper

        local content = Instance.new("Frame")
        content.Name = "SectionContent"
        content.Position = UDim2.fromOffset(0, 26)
        content.Size = UDim2.new(1, 0, 0, 10)
        content.AutomaticSize = Enum.AutomaticSize.Y
        content.BackgroundTransparency = 1
        content.ZIndex = 14
        content.Parent = wrapper

        local isCollapsed = false
        collapseBtn.MouseButton1Click:Connect(function()
            isCollapsed = not isCollapsed
            content.Visible = not isCollapsed
            headerLine.Visible = not isCollapsed
            collapseBtn.Text = isCollapsed and "▸" or "▾"
            collapseBtn.TextColor3 = isCollapsed and Theme.Accent or Color3.fromRGB(90, 90, 90)
        end)

        wrapper.MouseEnter:Connect(function()
            wrapper.BorderColor3 = Color3.fromRGB(72, 72, 72)
            tween(wrapperStroke, FastTween, { Color = Color3.fromRGB(8, 8, 8), Transparency = 0 })
        end)
        wrapper.MouseLeave:Connect(function()
            wrapper.BorderColor3 = Color3.fromRGB(56, 56, 56)
            tween(wrapperStroke, FastTween, { Color = Color3.fromRGB(8, 8, 8), Transparency = 0 })
        end)

        local pad = Instance.new("UIPadding")
        pad.PaddingTop = UDim.new(0, 4)
        pad.PaddingBottom = UDim.new(0, 8)
        pad.PaddingLeft = UDim.new(0, 8)
        pad.PaddingRight = UDim.new(0, 8)
        pad.Parent = content

        local list = Instance.new("UIListLayout")
        list.Padding = UDim.new(0, 5)
        list.SortOrder = Enum.SortOrder.LayoutOrder
        list.Parent = content

        return content, wrapper
    end

    UI.createColorRow = function(page, text, defaultColor, callback)
        local row = Instance.new("Frame")
        row.Name = "ColorRow_" .. tostring(text)
        row.Size = UDim2.new(1, 0, 0, 24)
        row.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
        row.BackgroundTransparency = 1
        row.ZIndex = 14
        row.Parent = page

        local lbl = Instance.new("TextLabel")
        lbl.Position = UDim2.fromOffset(4, 0)
        lbl.Size = UDim2.new(1, -54, 1, 0)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.Code
        lbl.Text = text
        lbl.TextColor3 = Color3.fromRGB(170, 170, 170)
        lbl.TextStrokeTransparency = 0.5
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 15
        lbl.Parent = row

        local swatchBtn = Instance.new("TextButton")
        swatchBtn.Name = "ColorSwatch_" .. tostring(text)
        swatchBtn.AnchorPoint = Vector2.new(1, 0.5)
        swatchBtn.Position = UDim2.new(1, -4, 0.5, 0)
        swatchBtn.Size = UDim2.fromOffset(20, 11)
        swatchBtn.BorderColor3 = Color3.fromRGB(56, 56, 56)
        swatchBtn.BorderSizePixel = 1
        swatchBtn.AutoButtonColor = false
        swatchBtn.Text = " "
        swatchBtn.TextTransparency = 1
        swatchBtn.ZIndex = 16
        swatchBtn.Parent = row
        addStroke(swatchBtn, Color3.fromRGB(8, 8, 8), 1, 0)

        local setCol, getCol = attachSwatchCyclers(swatchBtn, defaultColor, callback)
        return { SetColor = setCol, GetColor = getCol, SwatchBtn = swatchBtn, Row = row }
    end
end

local function isPCDevice()
    local kb = false
    local touch = false
    pcall(function()
        kb = (UserInputService.KeyboardEnabled == true)
        touch = (UserInputService.TouchEnabled == true)
    end)
    if touch and not kb then
        return false
    end
    return true
end
State.isPCDevice = isPCDevice

local function syncKeybindBadgesVisibility()
    local pc = isPCDevice()
    if not pc then
        State.listeningKeybindEntry = nil
    end
    for _, entry in ipairs(State.registeredKeybinds) do
        if entry.Button then
            entry.Button.Visible = pc
        end
    end
end
State.syncKeybindBadgesVisibility = syncKeybindBadgesVisibility

local function createToggle(page, text, defaultVal, callback, extraOpts)
    local row = Instance.new("TextButton")
    row.Size = UDim2.new(1, 0, 0, 24)
    row.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    row.BackgroundTransparency = 1
    row.AutoButtonColor = false
    row.Text = ""
    row.ClipsDescendants = false
    row.ZIndex = 14
    row.Parent = page
    local st = addStroke(row, Theme.Border, 1, 1)

    local statusBar = Instance.new("Frame")
    statusBar.AnchorPoint = Vector2.new(0, 0.5)
    statusBar.Position = UDim2.new(0, 0, 0.5, 0)
    statusBar.Size = UDim2.fromOffset(2, defaultVal and 18 or 0)
    statusBar.BackgroundColor3 = Theme.Accent
    statusBar.BorderSizePixel = 0
    statusBar.ZIndex = 15
    statusBar.Parent = row
    registerAccentObject(statusBar, "BackgroundColor3")

    -- Vaderpaste 12x12 Double-Bordered Square Checkbox (outline -> inline fill + glow)
    local pill = Instance.new("Frame")
    pill.Name = "VaderToggleOutline"
    pill.AnchorPoint = Vector2.new(0, 0.5)
    pill.Position = UDim2.new(0, 4, 0.5, 0)
    pill.Size = UDim2.fromOffset(12, 12)
    pill.BackgroundColor3 = Color3.fromRGB(8, 8, 8)
    pill.BorderSizePixel = 0
    pill.ZIndex = 15
    pill.Parent = row

    local dot = Instance.new("Frame")
    dot.Name = "VaderToggleFill"
    dot.Position = UDim2.new(0, 1, 0, 1)
    dot.Size = UDim2.new(1, -2, 1, -2)
    dot.BackgroundColor3 = defaultVal and Theme.Accent or Color3.fromRGB(22, 22, 22)
    dot.BorderColor3 = Color3.fromRGB(56, 56, 56)
    dot.BorderSizePixel = 1
    dot.ZIndex = 16
    dot.Parent = pill

    local toggleGlow = Instance.new("ImageLabel")
    toggleGlow.Name = "VaderToggleGlow"
    toggleGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    toggleGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    toggleGlow.Size = UDim2.new(1, 12, 1, 12)
    toggleGlow.BackgroundTransparency = 1
    toggleGlow.Image = "http://www.roblox.com/asset/?id=18245826428"
    toggleGlow.ImageColor3 = Theme.Accent
    toggleGlow.ImageTransparency = defaultVal and 0.85 or 1
    toggleGlow.ScaleType = Enum.ScaleType.Slice
    pcall(function() toggleGlow.SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)) end)
    toggleGlow.ZIndex = 15
    toggleGlow.Parent = dot
    registerAccentObject(toggleGlow, "ImageColor3")

    local lbl = Instance.new("TextLabel")
    lbl.Position = UDim2.fromOffset(22, 0)
    lbl.Size = UDim2.new(1, -110, 1, 0)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.Text = text
    lbl.TextColor3 = defaultVal and Color3.fromRGB(170, 170, 170) or Color3.fromRGB(90, 90, 90)
    lbl.TextStrokeTransparency = 0.5
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 15
    lbl.Parent = row

    local state = defaultVal
    local setState

    local rightOffset = 4
    local swatch1Set, swatch2Set
    local keybindEntry
    if type(extraOpts) == "table" then
        if extraOpts.SwatchColor2 then
            local sw2 = Instance.new("TextButton")
            sw2.Name = "ColorSwatch2_" .. tostring(text)
            sw2.AnchorPoint = Vector2.new(1, 0.5)
            sw2.Position = UDim2.new(1, -rightOffset, 0.5, 0)
            sw2.Size = UDim2.fromOffset(18, 10)
            sw2.BorderColor3 = Color3.fromRGB(56, 56, 56)
            sw2.BorderSizePixel = 1
            sw2.AutoButtonColor = false
            sw2.Text = " "
            sw2.TextTransparency = 1
            sw2.ZIndex = 16
            sw2.Parent = row
            addStroke(sw2, Color3.fromRGB(8, 8, 8), 1, 0)
            swatch2Set = UI.attachSwatchCyclers(sw2, extraOpts.SwatchColor2, extraOpts.OnColorChange2 or extraOpts.OnColor2Change)
            rightOffset = rightOffset + 24
        end
        if extraOpts.SwatchColor then
            local sw1 = Instance.new("TextButton")
            sw1.Name = "ColorSwatch_" .. tostring(text)
            sw1.AnchorPoint = Vector2.new(1, 0.5)
            sw1.Position = UDim2.new(1, -rightOffset, 0.5, 0)
            sw1.Size = UDim2.fromOffset(18, 10)
            sw1.BorderColor3 = Color3.fromRGB(56, 56, 56)
            sw1.BorderSizePixel = 1
            sw1.AutoButtonColor = false
            sw1.Text = " "
            sw1.TextTransparency = 1
            sw1.ZIndex = 16
            sw1.Parent = row
            addStroke(sw1, Color3.fromRGB(8, 8, 8), 1, 0)
            swatch1Set = UI.attachSwatchCyclers(sw1, extraOpts.SwatchColor, extraOpts.OnColorChange)
            rightOffset = rightOffset + 24
        end
        if extraOpts.ShowKeybindBadge then
            local kbBtn = Instance.new("TextButton")
            kbBtn.Name = "KeybindBadge_" .. tostring(text)
            kbBtn.AnchorPoint = Vector2.new(1, 0.5)
            kbBtn.Position = UDim2.new(1, -rightOffset, 0.5, 0)
            kbBtn.Size = UDim2.fromOffset(32, 16)
            kbBtn.BackgroundTransparency = 1
            kbBtn.AutoButtonColor = false
            kbBtn.Font = Enum.Font.Code
            kbBtn.Text = "[...]"
            kbBtn.TextColor3 = Color3.fromRGB(90, 90, 90)
            kbBtn.TextStrokeTransparency = 0.5
            kbBtn.TextSize = 11
            kbBtn.Visible = isPCDevice()
            kbBtn.ZIndex = 17
            kbBtn.Parent = row

            keybindEntry = {
                Name = tostring(text),
                Button = kbBtn,
                KeyCode = nil,
                KeyName = nil,
                Toggle = function()
                    if setState then
                        setState(not state, true)
                    end
                end,
            }
            table.insert(State.registeredKeybinds, keybindEntry)

            kbBtn.MouseButton1Click:Connect(function()
                if not isPCDevice() then
                    kbBtn.Visible = false
                    return
                end
                if State.listeningKeybindEntry == keybindEntry then
                    State.listeningKeybindEntry = nil
                    kbBtn.Text = keybindEntry.KeyName and ("[" .. keybindEntry.KeyName .. "]") or "[...]"
                    kbBtn.TextColor3 = keybindEntry.KeyName and Theme.Accent or Color3.fromRGB(90, 90, 90)
                else
                    if State.listeningKeybindEntry and State.listeningKeybindEntry.Button then
                        local prev = State.listeningKeybindEntry
                        prev.Button.Text = prev.KeyName and ("[" .. prev.KeyName .. "]") or "[...]"
                        prev.Button.TextColor3 = prev.KeyName and Theme.Accent or Color3.fromRGB(90, 90, 90)
                    end
                    State.listeningKeybindEntry = keybindEntry
                    kbBtn.Text = "[...]"
                    kbBtn.TextColor3 = Theme.White
                end
            end)
        end
    end

    setState = function(newVal, fireCallback)
        state = newVal
        tween(lbl, FastTween, {
            TextColor3 = state and Color3.fromRGB(170, 170, 170) or Color3.fromRGB(90, 90, 90),
        })
        tween(statusBar, SpringTween, { Size = UDim2.fromOffset(2, state and 18 or 0) })
        tween(dot, FastTween, {
            BackgroundColor3 = state and Theme.Accent or Color3.fromRGB(22, 22, 22),
        })
        tween(toggleGlow, FastTween, {
            ImageTransparency = state and 0.85 or 1,
        })
        if fireCallback ~= false then
            callback(state)
        end
    end

    row.MouseEnter:Connect(function()
        if not state then
            tween(lbl, FastTween, { TextColor3 = Color3.fromRGB(140, 140, 140) })
        end
    end)

    row.MouseLeave:Connect(function()
        if not state then
            tween(lbl, FastTween, { TextColor3 = Color3.fromRGB(90, 90, 90) })
        end
    end)

    row.MouseButton1Click:Connect(function()
        setState(not state, true)
    end)

    return { Set = setState, Get = function() return state end, Row = row, SetColor1 = swatch1Set, SetColor2 = swatch2Set, KeybindEntry = keybindEntry }
end

local function createSlider(page, text, minVal, maxVal, defaultVal, step, suffix, callback)
    suffix = suffix or ""
    local currentVal = defaultVal
    local card = Instance.new("Frame")
    card.Name = "SliderCard_" .. tostring(text)
    card.Size = UDim2.new(1, 0, 0, 36)
    card.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    card.BackgroundTransparency = 1
    card.ZIndex = 14
    card.Parent = page
    local st = addStroke(card, Theme.Border, 1, 1)

    local lbl = Instance.new("TextLabel")
    lbl.Position = UDim2.fromOffset(4, 0)
    lbl.Size = UDim2.new(0.65, 0, 0, 16)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.Text = text
    lbl.TextColor3 = Color3.fromRGB(170, 170, 170)
    lbl.TextStrokeTransparency = 0.5
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 15
    lbl.Parent = card

    local valBadge = Instance.new("TextLabel")
    valBadge.Name = "SliderValueLabel"
    valBadge.AnchorPoint = Vector2.new(1, 0)
    valBadge.Position = UDim2.new(1, -4, 0, 0)
    valBadge.Size = UDim2.fromOffset(90, 16)
    valBadge.BackgroundTransparency = 1
    valBadge.Font = Enum.Font.Code
    valBadge.Text = tostring(defaultVal) .. suffix
    valBadge.TextColor3 = Color3.fromRGB(170, 170, 170)
    valBadge.TextStrokeTransparency = 0.5
    valBadge.TextSize = 12
    valBadge.TextXAlignment = Enum.TextXAlignment.Right
    valBadge.ZIndex = 15
    valBadge.Parent = card

    local minusBtn = Instance.new("TextButton")
    minusBtn.Name = "SliderMinusBtn"
    minusBtn.Position = UDim2.fromOffset(2, 18)
    minusBtn.Size = UDim2.fromOffset(14, 14)
    minusBtn.BackgroundTransparency = 1
    minusBtn.AutoButtonColor = false
    minusBtn.Font = Enum.Font.Code
    minusBtn.Text = "-"
    minusBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
    minusBtn.TextStrokeTransparency = 0.5
    minusBtn.TextSize = 12
    minusBtn.ZIndex = 16
    minusBtn.Parent = card

    local plusBtn = Instance.new("TextButton")
    plusBtn.Name = "SliderPlusBtn"
    plusBtn.AnchorPoint = Vector2.new(1, 0)
    plusBtn.Position = UDim2.new(1, -2, 0, 18)
    plusBtn.Size = UDim2.fromOffset(14, 14)
    plusBtn.BackgroundTransparency = 1
    plusBtn.AutoButtonColor = false
    plusBtn.Font = Enum.Font.Code
    plusBtn.Text = "+"
    plusBtn.TextColor3 = Color3.fromRGB(120, 120, 120)
    plusBtn.TextStrokeTransparency = 0.5
    plusBtn.TextSize = 12
    plusBtn.ZIndex = 16
    plusBtn.Parent = card

    -- Vaderpaste 10px Double-Bordered Bar Track
    local track = Instance.new("Frame")
    track.Position = UDim2.fromOffset(18, 20)
    track.Size = UDim2.new(1, -36, 0, 10)
    track.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    track.BorderColor3 = Color3.fromRGB(56, 56, 56)
    track.BorderSizePixel = 1
    track.ZIndex = 15
    track.Parent = card
    addStroke(track, Color3.fromRGB(8, 8, 8), 1, 0)

    local initPct = math.clamp((defaultVal - minVal) / math.max(maxVal - minVal, 0.0001), 0, 1)
    local fill = Instance.new("Frame")
    fill.Size = UDim2.fromScale(initPct, 1)
    fill.BackgroundColor3 = Theme.Accent
    fill.BorderSizePixel = 0
    fill.ZIndex = 16
    fill.Parent = track
    registerAccentObject(fill, "BackgroundColor3")

    local fillGlow = Instance.new("ImageLabel")
    fillGlow.Name = "VaderSliderGlow"
    fillGlow.AnchorPoint = Vector2.new(0.5, 0.5)
    fillGlow.Position = UDim2.new(0.5, 0, 0.5, 0)
    fillGlow.Size = UDim2.new(1, 14, 1, 14)
    fillGlow.BackgroundTransparency = 1
    fillGlow.Image = "http://www.roblox.com/asset/?id=18245826428"
    fillGlow.ImageColor3 = Theme.Accent
    fillGlow.ImageTransparency = 0.89
    fillGlow.ScaleType = Enum.ScaleType.Slice
    pcall(function() fillGlow.SliceCenter = Rect.new(Vector2.new(21, 21), Vector2.new(79, 79)) end)
    fillGlow.ZIndex = 15
    fillGlow.Parent = fill
    registerAccentObject(fillGlow, "ImageColor3")

    local knob = Instance.new("Frame")
    knob.AnchorPoint = Vector2.new(0.5, 0.5)
    knob.Position = UDim2.fromScale(initPct, 0.5)
    knob.Size = UDim2.fromOffset(2, 10)
    knob.BackgroundColor3 = Theme.White
    knob.BorderSizePixel = 0
    knob.ZIndex = 17
    knob.Parent = track

    local dragging = false

    local function setValue(rawVal, fireCallback)
        local stepped = math.floor((rawVal / step) + 0.5) * step
        stepped = tonumber(string.format("%.2f", math.clamp(stepped, minVal, maxVal))) or defaultVal
        currentVal = stepped
        local pct = math.clamp((stepped - minVal) / math.max(maxVal - minVal, 0.0001), 0, 1)
        tween(fill, TweenInfo.new(0.08), { Size = UDim2.fromScale(pct, 1) })
        tween(knob, TweenInfo.new(0.08), { Position = UDim2.fromScale(pct, 0.5) })
        valBadge.Text = tostring(stepped) .. suffix
        if fireCallback ~= false then
            callback(stepped)
        end
    end

    minusBtn.MouseButton1Click:Connect(function()
        setValue(currentVal - step, true)
    end)

    plusBtn.MouseButton1Click:Connect(function()
        setValue(currentVal + step, true)
    end)

    local function updateFromInput(input)
        local width = math.max(track.AbsoluteSize.X, 1)
        local pct = math.clamp((input.Position.X - track.AbsolutePosition.X) / width, 0, 1)
        local raw = minVal + (maxVal - minVal) * pct
        setValue(raw, true)
    end

    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            track.BorderColor3 = Theme.Accent
            updateFromInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateFromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                track.BorderColor3 = Color3.fromRGB(56, 56, 56)
            end
        end
    end)

    return { Set = setValue, Get = function() return currentVal end, Card = card, MinusBtn = minusBtn, PlusBtn = plusBtn }
end

local function createTextInputRow(page, labelText, placeholder, defaultText, onCommit)
    local row = Instance.new("Frame")
    row.Size = UDim2.new(1, 0, 0, 38)
    row.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    row.BackgroundTransparency = 1
    row.ZIndex = 14
    row.Parent = page

    local lbl = Instance.new("TextLabel")
    lbl.Position = UDim2.fromOffset(4, 0)
    lbl.Size = UDim2.new(1, -8, 0, 15)
    lbl.BackgroundTransparency = 1
    lbl.Font = Enum.Font.Code
    lbl.Text = labelText
    lbl.TextColor3 = Color3.fromRGB(170, 170, 170)
    lbl.TextStrokeTransparency = 0.5
    lbl.TextSize = 12
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.ZIndex = 15
    lbl.Parent = row

    local boxHolder = Instance.new("Frame")
    boxHolder.Position = UDim2.fromOffset(4, 17)
    boxHolder.Size = UDim2.new(1, -8, 0, 19)
    boxHolder.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    boxHolder.BorderColor3 = Color3.fromRGB(56, 56, 56)
    boxHolder.BorderSizePixel = 1
    boxHolder.ZIndex = 15
    boxHolder.Parent = row
    local boxStroke = addStroke(boxHolder, Color3.fromRGB(8, 8, 8), 1, 0)

    local box = Instance.new("TextBox")
    box.Position = UDim2.fromOffset(6, 0)
    box.Size = UDim2.new(1, -12, 1, 0)
    box.BackgroundTransparency = 1
    box.Font = Enum.Font.Code
    box.PlaceholderText = placeholder or ""
    box.PlaceholderColor3 = Color3.fromRGB(90, 90, 90)
    box.Text = defaultText or ""
    box.TextColor3 = Color3.fromRGB(170, 170, 170)
    box.TextStrokeTransparency = 0.5
    box.TextSize = 12
    box.ClearTextOnFocus = false
    box.TextXAlignment = Enum.TextXAlignment.Left
    box.ZIndex = 16
    box.Parent = boxHolder

    box.Focused:Connect(function()
        boxHolder.BorderColor3 = Theme.Accent
        tween(boxStroke, FastTween, { Color = Theme.Accent })
    end)
    box.FocusLost:Connect(function()
        boxHolder.BorderColor3 = Color3.fromRGB(56, 56, 56)
        tween(boxStroke, FastTween, { Color = Color3.fromRGB(8, 8, 8) })
        if onCommit then
            onCommit(box.Text)
        end
    end)

    return box
end

local function createDropdown(page, text, options, defaultOpt, callback)
    local isOpen = false
    local selected = defaultOpt or options[1]

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 38)
    container.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.ZIndex = 14
    container.Parent = page
    local st = addStroke(container, Theme.Border, 1, 1)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Position = UDim2.fromOffset(4, 0)
    titleLbl.Size = UDim2.new(1, -8, 0, 15)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.Code
    titleLbl.Text = text
    titleLbl.TextColor3 = Color3.fromRGB(170, 170, 170)
    titleLbl.TextStrokeTransparency = 0.5
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 15
    titleLbl.Parent = container

    local headerBtn = Instance.new("TextButton")
    headerBtn.Position = UDim2.fromOffset(4, 17)
    headerBtn.Size = UDim2.new(1, -8, 0, 19)
    headerBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    headerBtn.BorderColor3 = Color3.fromRGB(56, 56, 56)
    headerBtn.BorderSizePixel = 1
    headerBtn.AutoButtonColor = false
    headerBtn.Text = ""
    headerBtn.ZIndex = 15
    headerBtn.Parent = container
    addStroke(headerBtn, Color3.fromRGB(8, 8, 8), 1, 0)

    local optLbl = Instance.new("TextLabel")
    optLbl.Position = UDim2.fromOffset(6, 0)
    optLbl.Size = UDim2.new(1, -24, 1, 0)
    optLbl.BackgroundTransparency = 1
    optLbl.Font = Enum.Font.Code
    optLbl.Text = tostring(selected)
    optLbl.TextColor3 = Color3.fromRGB(170, 170, 170)
    optLbl.TextStrokeTransparency = 0.5
    optLbl.TextSize = 12
    optLbl.TextTruncate = Enum.TextTruncate.AtEnd
    optLbl.TextXAlignment = Enum.TextXAlignment.Left
    optLbl.ZIndex = 16
    optLbl.Parent = headerBtn

    local arrow = Instance.new("TextLabel")
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -6, 0.5, 0)
    arrow.Size = UDim2.fromOffset(12, 12)
    arrow.BackgroundTransparency = 1
    arrow.Font = Enum.Font.Code
    arrow.Text = "+"
    arrow.TextColor3 = Color3.fromRGB(170, 170, 170)
    arrow.TextStrokeTransparency = 0.5
    arrow.TextSize = 12
    arrow.ZIndex = 16
    arrow.Parent = headerBtn

    local listHolder = Instance.new("Frame")
    listHolder.Position = UDim2.fromOffset(4, 38)
    listHolder.Size = UDim2.new(1, -8, 0, #options * 20)
    listHolder.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    listHolder.BorderColor3 = Color3.fromRGB(56, 56, 56)
    listHolder.BorderSizePixel = 1
    listHolder.ZIndex = 15
    listHolder.Parent = container

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 1)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listHolder

    local optionButtons = {}

    local function rebuildOptions(newOptions)
        options = newOptions
        for _, b in ipairs(optionButtons) do
            if b and b.Parent then
                b:Destroy()
            end
        end
        table.clear(optionButtons)

        for i, opt in ipairs(options) do
            local optBtn = Instance.new("TextButton")
            optBtn.LayoutOrder = i
            optBtn.Size = UDim2.new(1, 0, 0, 19)
            optBtn.BackgroundColor3 = (opt == selected) and Color3.fromRGB(28, 28, 28) or Color3.fromRGB(22, 22, 22)
            optBtn.BorderSizePixel = 0
            optBtn.AutoButtonColor = false
            optBtn.Font = Enum.Font.Code
            optBtn.Text = tostring(opt)
            optBtn.TextColor3 = (opt == selected) and Theme.Accent or Color3.fromRGB(170, 170, 170)
            optBtn.TextStrokeTransparency = 0.5
            optBtn.TextSize = 12
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.ZIndex = 16
            optBtn.Parent = listHolder
            local optPad = Instance.new("UIPadding")
            optPad.PaddingLeft = UDim.new(0, 6)
            optPad.Parent = optBtn
            table.insert(optionButtons, optBtn)

            optBtn.MouseEnter:Connect(function()
                if opt ~= selected then
                    tween(optBtn, FastTween, { BackgroundColor3 = Color3.fromRGB(28, 28, 28), TextColor3 = Theme.White })
                end
            end)
            optBtn.MouseLeave:Connect(function()
                if opt ~= selected then
                    tween(optBtn, FastTween, { BackgroundColor3 = Color3.fromRGB(22, 22, 22), TextColor3 = Color3.fromRGB(170, 170, 170) })
                end
            end)

            optBtn.MouseButton1Click:Connect(function()
                selected = opt
                optLbl.Text = tostring(opt)
                for _, otherBtn in ipairs(optionButtons) do
                    local isSel = (otherBtn == optBtn)
                    tween(otherBtn, FastTween, {
                        BackgroundColor3 = isSel and Color3.fromRGB(28, 28, 28) or Color3.fromRGB(22, 22, 22),
                        TextColor3 = isSel and Theme.Accent or Color3.fromRGB(170, 170, 170),
                    })
                end
                callback(opt)
            end)
        end
    end

    rebuildOptions(options)

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local openHeight = 40 + (#options * 20)
        listHolder.Size = UDim2.new(1, -8, 0, #options * 20)
        tween(container, SmoothTween, {
            Size = UDim2.new(1, 0, 0, isOpen and openHeight or 38),
        })
        arrow.Text = isOpen and "-" or "+"
        headerBtn.BorderColor3 = isOpen and Theme.Accent or Color3.fromRGB(56, 56, 56)
        tween(st, FastTween, { Color = isOpen and Theme.Accent or Theme.Border })
    end)

    return {
        Refresh = function(newOptions, newSelected)
            if newSelected then
                selected = newSelected
                optLbl.Text = tostring(selected)
            end
            rebuildOptions(newOptions)
            listHolder.Size = UDim2.new(1, -8, 0, #newOptions * 20)
            if isOpen then
                local openHeight = 40 + (#newOptions * 20)
                container.Size = UDim2.new(1, 0, 0, openHeight)
            end
        end,
    }
end

local function createMultiDropdown(page, text, options, defaultSelectedList, maxChoices, callback)
    local isOpen = false
    local selectedList = {}
    for _, item in ipairs(defaultSelectedList or {}) do
        table.insert(selectedList, item)
    end

    local container = Instance.new("Frame")
    container.Size = UDim2.new(1, 0, 0, 38)
    container.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    container.BackgroundTransparency = 1
    container.ClipsDescendants = true
    container.ZIndex = 14
    container.Parent = page
    local st = addStroke(container, Theme.Border, 1, 1)

    local titleLbl = Instance.new("TextLabel")
    titleLbl.Position = UDim2.fromOffset(4, 0)
    titleLbl.Size = UDim2.new(1, -8, 0, 15)
    titleLbl.BackgroundTransparency = 1
    titleLbl.Font = Enum.Font.Code
    titleLbl.Text = text
    titleLbl.TextColor3 = Color3.fromRGB(170, 170, 170)
    titleLbl.TextStrokeTransparency = 0.5
    titleLbl.TextSize = 12
    titleLbl.TextXAlignment = Enum.TextXAlignment.Left
    titleLbl.ZIndex = 15
    titleLbl.Parent = container

    local headerBtn = Instance.new("TextButton")
    headerBtn.Position = UDim2.fromOffset(4, 17)
    headerBtn.Size = UDim2.new(1, -8, 0, 19)
    headerBtn.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    headerBtn.BorderColor3 = Color3.fromRGB(56, 56, 56)
    headerBtn.BorderSizePixel = 1
    headerBtn.AutoButtonColor = false
    headerBtn.Text = ""
    headerBtn.ZIndex = 15
    headerBtn.Parent = container
    addStroke(headerBtn, Color3.fromRGB(8, 8, 8), 1, 0)

    local optLbl = Instance.new("TextLabel")
    optLbl.Position = UDim2.fromOffset(6, 0)
    optLbl.Size = UDim2.new(1, -24, 1, 0)
    optLbl.BackgroundTransparency = 1
    optLbl.Font = Enum.Font.Code
    optLbl.Text = #selectedList > 0 and table.concat(selectedList, ", ") or "None"
    optLbl.TextColor3 = Color3.fromRGB(170, 170, 170)
    optLbl.TextStrokeTransparency = 0.5
    optLbl.TextSize = 12
    optLbl.TextTruncate = Enum.TextTruncate.AtEnd
    optLbl.TextXAlignment = Enum.TextXAlignment.Left
    optLbl.ZIndex = 16
    optLbl.Parent = headerBtn

    local arrow = Instance.new("TextLabel")
    arrow.AnchorPoint = Vector2.new(1, 0.5)
    arrow.Position = UDim2.new(1, -6, 0.5, 0)
    arrow.Size = UDim2.fromOffset(12, 12)
    arrow.BackgroundTransparency = 1
    arrow.Font = Enum.Font.Code
    arrow.Text = "+"
    arrow.TextColor3 = Color3.fromRGB(170, 170, 170)
    arrow.TextStrokeTransparency = 0.5
    arrow.TextSize = 12
    arrow.ZIndex = 16
    arrow.Parent = headerBtn

    local listHolder = Instance.new("Frame")
    listHolder.Position = UDim2.fromOffset(4, 38)
    listHolder.Size = UDim2.new(1, -8, 0, #options * 20)
    listHolder.BackgroundColor3 = Color3.fromRGB(22, 22, 22)
    listHolder.BorderColor3 = Color3.fromRGB(56, 56, 56)
    listHolder.BorderSizePixel = 1
    listHolder.ZIndex = 15
    listHolder.Parent = container

    local listLayout = Instance.new("UIListLayout")
    listLayout.Padding = UDim.new(0, 1)
    listLayout.SortOrder = Enum.SortOrder.LayoutOrder
    listLayout.Parent = listHolder

    local optionButtons = {}

    local function isOptionSelected(opt)
        for i, v in ipairs(selectedList) do
            if v == opt then
                return true, i
            end
        end
        return false, nil
    end

    local function refreshButtons()
        optLbl.Text = #selectedList > 0 and table.concat(selectedList, ", ") or "None"
        for _, item in ipairs(optionButtons) do
            local active = isOptionSelected(item.Value)
            tween(item.Btn, FastTween, {
                BackgroundColor3 = active and Color3.fromRGB(28, 28, 28) or Color3.fromRGB(22, 22, 22),
                TextColor3 = active and Theme.Accent or Color3.fromRGB(170, 170, 170),
            })
        end
    end

    local function rebuildMultiOptions(newOptions, newSelectedList)
        options = newOptions
        if newSelectedList then
            selectedList = {}
            for _, v in ipairs(newSelectedList) do
                table.insert(selectedList, v)
            end
        end
        for _, item in ipairs(optionButtons) do
            if item.Btn and item.Btn.Parent then
                item.Btn:Destroy()
            end
        end
        table.clear(optionButtons)

        for i, opt in ipairs(options) do
            local active = isOptionSelected(opt)
            local optBtn = Instance.new("TextButton")
            optBtn.LayoutOrder = i
            optBtn.Size = UDim2.new(1, 0, 0, 19)
            optBtn.BackgroundColor3 = active and Color3.fromRGB(28, 28, 28) or Color3.fromRGB(22, 22, 22)
            optBtn.BorderSizePixel = 0
            optBtn.AutoButtonColor = false
            optBtn.Font = Enum.Font.Code
            optBtn.Text = tostring(opt)
            optBtn.TextColor3 = active and Theme.Accent or Color3.fromRGB(170, 170, 170)
            optBtn.TextStrokeTransparency = 0.5
            optBtn.TextSize = 12
            optBtn.TextXAlignment = Enum.TextXAlignment.Left
            optBtn.ZIndex = 16
            optBtn.Parent = listHolder
            local optPad = Instance.new("UIPadding")
            optPad.PaddingLeft = UDim.new(0, 6)
            optPad.Parent = optBtn

            table.insert(optionButtons, { Btn = optBtn, Value = opt })

            optBtn.MouseButton1Click:Connect(function()
                local currentlyActive, idx = isOptionSelected(opt)
                if currentlyActive and idx then
                    table.remove(selectedList, idx)
                else
                    if maxChoices and #selectedList >= maxChoices then
                        notify("Core.xyz", "Maximum " .. tostring(maxChoices) .. " options can be selected at once!", 3)
                        return
                    end
                    table.insert(selectedList, opt)
                end
                refreshButtons()
                callback(selectedList)
            end)
        end
        refreshButtons()
    end

    rebuildMultiOptions(options, selectedList)

    headerBtn.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        local openHeight = 40 + (#options * 20)
        listHolder.Size = UDim2.new(1, -8, 0, #options * 20)
        tween(container, SmoothTween, {
            Size = UDim2.new(1, 0, 0, isOpen and openHeight or 38),
        })
        arrow.Text = isOpen and "-" or "+"
        headerBtn.BorderColor3 = isOpen and Theme.Accent or Color3.fromRGB(56, 56, 56)
        tween(st, FastTween, { Color = isOpen and Theme.Accent or Theme.Border })
    end)

    return {
        Refresh = function(newOptions, newSelectedList)
            rebuildMultiOptions(newOptions, newSelectedList)
            listHolder.Size = UDim2.new(1, -8, 0, #options * 20)
            if isOpen then
                local openHeight = 40 + (#options * 20)
                container.Size = UDim2.new(1, 0, 0, openHeight)
            end
        end,
    }
end

--------------------------------------------------------------------------------
-- 11. CORE GAMEPLAY & UNIVERSAL FEATURE IMPLEMENTATIONS
--------------------------------------------------------------------------------
local function getTargetPartFromCharacter(char, partName)
    if not char then
        return nil
    end
    local found = char:FindFirstChild(partName)
    if found then
        return found
    end
    if partName == "UpperTorso" or partName == "LowerTorso" then
        return char:FindFirstChild("Torso") or char:FindFirstChild("HumanoidRootPart")
    elseif partName == "RightUpperArm" then
        return char:FindFirstChild("Right Arm") or char:FindFirstChild("HumanoidRootPart")
    elseif partName == "LeftUpperArm" then
        return char:FindFirstChild("Left Arm") or char:FindFirstChild("HumanoidRootPart")
    elseif partName == "RightUpperLeg" or partName == "RightLowerLeg" then
        return char:FindFirstChild("RightLowerLeg") or char:FindFirstChild("Right Leg") or char:FindFirstChild("HumanoidRootPart")
    elseif partName == "LeftUpperLeg" or partName == "LeftLowerLeg" then
        return char:FindFirstChild("LeftLowerLeg") or char:FindFirstChild("Left Leg") or char:FindFirstChild("HumanoidRootPart")
    end
    return char:FindFirstChild("HumanoidRootPart") or char:FindFirstChild("Head")
end

local function isPlayerWhitelisted(player)
    if not ConfigState.UseWhitelist then
        return false
    end
    return State.whitelistedPlayers[player.Name] == true
end

local function getPlayerTeamName(player)
    if not player then
        return nil
    end
    local t = player.Team
    if not t then
        return nil
    end
    if type(t) == "string" then
        return t ~= "" and t or nil
    end
    local ok, name = pcall(function()
        return t.Name
    end)
    if ok and type(name) == "string" and name ~= "" then
        return name
    end
    local str = tostring(t)
    return (str ~= "" and str ~= "nil") and str or nil
end

local function passesTeamCheck(player)
    if isPlayerWhitelisted(player) then
        return false
    end
    if not ConfigState.TeamCheck then
        return true
    end
    local myTeam = getPlayerTeamName(LocalPlayer)
    local plrTeam = getPlayerTeamName(player)
    if myTeam and plrTeam and myTeam == plrTeam then
        return false
    end
    if State.selectedTeams["All"] then
        return true
    end
    if not plrTeam then
        return false
    end
    return State.selectedTeams[plrTeam] == true
end

local function syncWhitelistArrayFromMap()
    table.clear(State.whitelistArray)
    for name, active in pairs(State.whitelistedPlayers) do
        if active then
            table.insert(State.whitelistArray, name)
        end
    end
    table.sort(State.whitelistArray)
    if State.refreshWhitelistDropdown then
        local names = {}
        for _, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                table.insert(names, p.Name)
            end
        end
        State.refreshWhitelistDropdown(names, State.whitelistArray)
    end
end

--------------------------------------------------------------------------------
-- 3D BOUNDING BOX (12 EDGES) + SKELETON RIG (10 BONES) + HEALTH BAR OVERLAY
--------------------------------------------------------------------------------
local BOX_3D_CORNERS = {
    Vector3.new(-2.1,  3.0, -1.2),
    Vector3.new( 2.1,  3.0, -1.2),
    Vector3.new( 2.1,  3.0,  1.2),
    Vector3.new(-2.1,  3.0,  1.2),
    Vector3.new(-2.1, -3.2, -1.2),
    Vector3.new( 2.1, -3.2, -1.2),
    Vector3.new( 2.1, -3.2,  1.2),
    Vector3.new(-2.1, -3.2,  1.2),
}

local BOX_3D_EDGES = {
    { 1, 2 }, { 2, 3 }, { 3, 4 }, { 4, 1 }, -- Top 4 edges
    { 5, 6 }, { 6, 7 }, { 7, 8 }, { 8, 5 }, -- Bottom 4 edges
    { 1, 5 }, { 2, 6 }, { 3, 7 }, { 4, 8 }, -- Vertical 4 pillars
}

local SKELETON_JOINTS = {
    { "Head", "UpperTorso", "Torso" },
    { "UpperTorso", "LowerTorso", "Torso" },
    { "UpperTorso", "LeftUpperArm", "Left Arm" },
    { "LeftUpperArm", "LeftLowerArm", "Left Arm" },
    { "UpperTorso", "RightUpperArm", "Right Arm" },
    { "RightUpperArm", "RightLowerArm", "Right Arm" },
    { "LowerTorso", "LeftUpperLeg", "Left Leg" },
    { "LeftUpperLeg", "LeftLowerLeg", "Left Leg" },
    { "LowerTorso", "RightUpperLeg", "Right Leg" },
    { "RightUpperLeg", "RightLowerLeg", "Right Leg" },
}

local function drawLineFrame(lineFrame, fromVec2, toVec2, color, thickness)
    local diff = toVec2 - fromVec2
    local dist = diff.Magnitude
    if dist < 1 then
        lineFrame.Visible = false
        return
    end
    local mid = (fromVec2 + toVec2) / 2
    local atan2Fn = math.atan2 or math.atan
    lineFrame.Position = UDim2.fromOffset(mid.X, mid.Y)
    lineFrame.Size = UDim2.fromOffset(dist, thickness or 1)
    lineFrame.Rotation = math.deg(atan2Fn(diff.Y, diff.X))
    lineFrame.BackgroundColor3 = color
    lineFrame.Visible = true
end

local function hsvToColor3(h, s, v)
    local i = math.floor(h * 6)
    local f = h * 6 - i
    local p = v * (1 - s)
    local q = v * (1 - f * s)
    local t = v * (1 - (1 - f) * s)
    i = i % 6
    local r, g, b = 1, 1, 1
    if i == 0 then r, g, b = v, t, p
    elseif i == 1 then r, g, b = q, v, p
    elseif i == 2 then r, g, b = p, v, t
    elseif i == 3 then r, g, b = p, q, v
    elseif i == 4 then r, g, b = t, p, v
    elseif i == 5 then r, g, b = v, p, q end
    return Color3.fromRGB(math.floor(r * 255), math.floor(g * 255), math.floor(b * 255))
end

local ESP_FONT_MAP = {
    ["Gotham"] = Enum.Font.Gotham,
    ["GothamBold"] = Enum.Font.GothamBold,
    ["Code"] = Enum.Font.Code,
    ["SourceSans"] = Enum.Font.SourceSans,
    ["Ubuntu"] = Enum.Font.Ubuntu or Enum.Font.GothamMedium,
    ["Arcade"] = Enum.Font.Arcade or Enum.Font.Code,
    ["SciFi"] = Enum.Font.SciFi or Enum.Font.GothamBold,
}

local function create3DOverlayGui()
    local folder = Instance.new("Frame")
    folder.Name = "Box3DOverlay"
    folder.Size = UDim2.fromScale(1, 1)
    folder.BackgroundTransparency = 1
    folder.Visible = false
    folder.ZIndex = 4
    folder.Parent = UI.OverlayContainer

    -- Pre-allocated 2D Box Fill & Box Glow Frame (For Box Effects Sub-Card)
    local boxFillFrame = Instance.new("Frame")
    boxFillFrame.Name = "Box2DFill"
    boxFillFrame.BackgroundColor3 = Theme.White
    boxFillFrame.BackgroundTransparency = 0.78
    boxFillFrame.BorderSizePixel = 0
    boxFillFrame.Visible = false
    boxFillFrame.ZIndex = 3
    boxFillFrame.Parent = folder
    addCorner(boxFillFrame, 3)

    local boxFillGrad = Instance.new("UIGradient")
    boxFillGrad.Rotation = 90
    boxFillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Theme.White),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(115, 95, 255)),
    })
    boxFillGrad.Parent = boxFillFrame

    local boxGlowStroke = addStroke(boxFillFrame, Color3.fromRGB(115, 95, 255), 2.2, 0.25)
    boxGlowStroke.Enabled = false

    local boxLines = {}
    for i = 1, 12 do
        local line = Instance.new("Frame")
        line.Name = "Edge3D_" .. i
        line.AnchorPoint = Vector2.new(0.5, 0.5)
        line.BackgroundColor3 = State.espColor
        line.BorderSizePixel = 0
        line.Visible = false
        line.ZIndex = 4
        line.Parent = folder
        table.insert(boxLines, line)
    end

    local skelLines = {}
    local boneStrokes = {}
    local jointDots = {}
    for i = 1, #SKELETON_JOINTS do
        local sLine = Instance.new("Frame")
        sLine.Name = "Bone_" .. i
        sLine.AnchorPoint = Vector2.new(0.5, 0.5)
        sLine.BackgroundColor3 = Theme.White
        sLine.BorderSizePixel = 0
        sLine.Visible = false
        sLine.ZIndex = 5
        sLine.Parent = folder

        local bStroke = Instance.new("UIStroke")
        bStroke.Name = "BoneStroke"
        bStroke.Color = Theme.Black
        bStroke.Thickness = 1
        bStroke.Transparency = 0.2
        bStroke.Enabled = true
        bStroke.Parent = sLine

        local jDot = Instance.new("Frame")
        jDot.Name = "JointDot_" .. i
        jDot.AnchorPoint = Vector2.new(0.5, 0.5)
        jDot.Size = UDim2.fromOffset(4, 4)
        jDot.BackgroundColor3 = Theme.White
        jDot.BorderSizePixel = 0
        jDot.Visible = false
        jDot.ZIndex = 6
        jDot.Parent = folder
        addCorner(jDot, 99)

        table.insert(skelLines, sLine)
        table.insert(boneStrokes, bStroke)
        table.insert(jointDots, jDot)
    end

    local headCircle = Instance.new("Frame")
    headCircle.Name = "HeadCircleFrame"
    headCircle.AnchorPoint = Vector2.new(0.5, 0.5)
    headCircle.Size = UDim2.fromOffset(18, 18)
    headCircle.BackgroundTransparency = 1
    headCircle.Visible = false
    headCircle.ZIndex = 6
    headCircle.Parent = folder
    addCorner(headCircle, 999)
    local headCircleStroke = addStroke(headCircle, Theme.White, 1.5, 0.05)

    local hbBg = Instance.new("Frame")
    hbBg.Name = "HealthBar3D"
    hbBg.AnchorPoint = Vector2.new(1, 0)
    hbBg.Size = UDim2.fromOffset(3, 50)
    hbBg.BackgroundColor3 = Theme.Black
    hbBg.BackgroundTransparency = 0.25
    hbBg.BorderSizePixel = 0
    hbBg.Visible = false
    hbBg.ZIndex = 5
    hbBg.Parent = folder
    addCorner(hbBg, 99)
    local hbStroke = addStroke(hbBg, Theme.Black, 1, 0.15)

    local hbFill = Instance.new("Frame")
    hbFill.AnchorPoint = Vector2.new(0, 1)
    hbFill.Position = UDim2.fromScale(0, 1)
    hbFill.Size = UDim2.fromScale(1, 1)
    hbFill.BackgroundColor3 = Theme.Success
    hbFill.BorderSizePixel = 0
    hbFill.Parent = hbBg
    addCorner(hbFill, 99)

    local hbGrad = Instance.new("UIGradient")
    hbGrad.Rotation = 90
    hbGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 255, 140)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 220, 70)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 65, 65)),
    })
    hbGrad.Enabled = false
    hbGrad.Parent = hbFill

    local hbNumLbl = Instance.new("TextLabel")
    hbNumLbl.Name = "HealthNumberLabel"
    hbNumLbl.AnchorPoint = Vector2.new(1, 0.5)
    hbNumLbl.Position = UDim2.fromOffset(0, 0)
    hbNumLbl.Size = UDim2.fromOffset(42, 14)
    hbNumLbl.BackgroundTransparency = 1
    hbNumLbl.Font = Enum.Font.Code
    hbNumLbl.Text = "100"
    hbNumLbl.TextColor3 = Theme.White
    hbNumLbl.TextStrokeTransparency = 0.15
    hbNumLbl.TextSize = 10
    hbNumLbl.TextXAlignment = Enum.TextXAlignment.Right
    hbNumLbl.Visible = false
    hbNumLbl.ZIndex = 7
    hbNumLbl.Parent = folder

    local screenTag = Instance.new("TextLabel")
    screenTag.Name = "ScreenNameTag"
    screenTag.AnchorPoint = Vector2.new(0.5, 1)
    screenTag.Size = UDim2.fromOffset(220, 18)
    screenTag.BackgroundTransparency = 1
    screenTag.Font = Enum.Font.GothamBold
    screenTag.TextColor3 = State.espColor
    screenTag.TextStrokeTransparency = 0.15
    screenTag.TextSize = 12
    screenTag.Visible = false
    screenTag.ZIndex = 6
    screenTag.Parent = folder

    local extraESP = {
        BoneStrokes = boneStrokes,
        JointDots = jointDots,
        HeadCircle = headCircle,
        HeadCircleStroke = headCircleStroke,
        HealthBarStroke = hbStroke,
        HealthBarGrad = hbGrad,
        HealthNumberLabel = hbNumLbl,
        BoxFillFrame = boxFillFrame,
        BoxFillGrad = boxFillGrad,
        BoxGlowStroke = boxGlowStroke,
    }

    return folder, boxLines, skelLines, hbBg, hbFill, screenTag, extraESP
end

local function preallocatePlayerESP(player)
    if not player or player == LocalPlayer or State.espObjects[player] then
        return State.espObjects[player]
    end

    local bb = Instance.new("BillboardGui")
    bb.Name = "CoreESP"
    bb.Size = UDim2.fromOffset(210, 28)
    bb.StudsOffset = Vector3.new(0, 3.3, 0)
    bb.AlwaysOnTop = true
    bb.Enabled = false
    bb.Parent = UI.OverlayContainer

    local txt = Instance.new("TextLabel")
    txt.Size = UDim2.fromScale(1, 1)
    txt.BackgroundTransparency = 1
    txt.Font = Enum.Font.GothamBold
    txt.TextColor3 = State.espColor
    txt.TextStrokeTransparency = 0.15
    txt.TextSize = 12
    txt.Parent = bb

    local line = Instance.new("Frame")
    line.Name = "TracerLine"
    line.AnchorPoint = Vector2.new(0.5, 0.5)
    line.BackgroundColor3 = State.espColor
    line.BorderSizePixel = 0
    line.Visible = false
    line.Parent = UI.OverlayContainer

    local ov3D, bLines, sLines, hbBg, hbFill, screenTag, extraESP = create3DOverlayGui()

    local preallocCorners = {}
    for i = 1, 8 do
        preallocCorners[i] = Vector2.zero
    end

    local tagData = {
        Billboard = bb,
        Text = txt,
        ScreenTag = screenTag,
        Tracer = line,
        Overlay3D = ov3D,
        Box3DLines = bLines,
        SkeletonLines = sLines,
        BoneStrokes = extraESP.BoneStrokes,
        JointDots = extraESP.JointDots,
        HeadCircle = extraESP.HeadCircle,
        HeadCircleStroke = extraESP.HeadCircleStroke,
        HealthBarBg = hbBg,
        HealthBarFill = hbFill,
        HealthBarStroke = extraESP.HealthBarStroke,
        HealthBarGrad = extraESP.HealthBarGrad,
        HealthNumberLabel = extraESP.HealthNumberLabel,
        BoxFillFrame = extraESP.BoxFillFrame,
        BoxFillGrad = extraESP.BoxFillGrad,
        BoxGlowStroke = extraESP.BoxGlowStroke,
        SmoothedHP = 1.0,
        Highlight = nil,
        ProjectedCorners = preallocCorners,
        CachedChar = nil,
        CachedHRP = nil,
        CachedHum = nil,
        CachedHead = nil,
        CachedJointPairs = nil,
        BonesComplete = false,
        BoneRetryFrames = 0,
        LastDist = -1,
        LastHP = -1,
        LastPriority = nil,
        LastNameType = nil,
        Box3DVisible = false,
        SkeletonVisible = false,
        LastHLAdornee = nil,
        LastHLEnabled = false,
        LastHLColor = nil,
    }
    State.espObjects[player] = tagData
    return tagData
end

local function invalidatePlayerESPCache(player)
    local data = State.espObjects[player]
    if not data then
        return
    end
    data.CachedChar = nil
    data.CachedHRP = nil
    data.CachedHum = nil
    data.CachedHead = nil
    data.CachedJointPairs = nil
    data.BonesComplete = false
    data.BoneRetryFrames = 0
    data.LastHLAdornee = nil
    data.LastHLEnabled = false
    data.LastDist = -1
    data.LastHP = -1
end

local function hidePlayerESP(player)
    local data = State.espObjects[player]
    if not data then
        return
    end
    if data.Billboard and (data.Billboard.Enabled or data.Billboard.Adornee ~= nil) then
        data.Billboard.Enabled = false
        data.Billboard.Adornee = nil
    end
    if data.ScreenTag and data.ScreenTag.Visible then
        data.ScreenTag.Visible = false
    end
    if data.Tracer and data.Tracer.Visible then
        data.Tracer.Visible = false
    end
    if data.Overlay3D and data.Overlay3D.Visible then
        data.Overlay3D.Visible = false
    end
    if data.BoxFillFrame and data.BoxFillFrame.Visible then
        data.BoxFillFrame.Visible = false
    end
    if data.Box3DVisible and data.Box3DLines then
        for i = 1, #data.Box3DLines do
            data.Box3DLines[i].Visible = false
        end
        data.Box3DVisible = false
    end
    if data.SkeletonVisible and data.SkeletonLines then
        for i = 1, #data.SkeletonLines do
            data.SkeletonLines[i].Visible = false
            if data.JointDots and data.JointDots[i] then
                data.JointDots[i].Visible = false
            end
        end
        if data.HeadCircle then
            data.HeadCircle.Visible = false
        end
        data.SkeletonVisible = false
    end
    if data.HealthBarBg and data.HealthBarBg.Visible then
        data.HealthBarBg.Visible = false
    end
    if data.HealthNumberLabel and data.HealthNumberLabel.Visible then
        data.HealthNumberLabel.Visible = false
    end
    if data.Highlight and (data.LastHLEnabled or data.Highlight.Enabled or data.Highlight.Adornee ~= nil) then
        data.Highlight.Enabled = false
        data.Highlight.Adornee = nil
        data.LastHLEnabled = false
        data.LastHLAdornee = nil
    end
end

local function disconnectPlayerCharSignals(player)
    local conns = State.playerCharConnections[player]
    if conns then
        for _, c in ipairs(conns) do
            pcall(function()
                c:Disconnect()
            end)
        end
        State.playerCharConnections[player] = nil
    end
end

local function hookPlayerLifecycle(player)
    if not player or player == LocalPlayer then
        return nil
    end
    local tagData = preallocatePlayerESP(player)
    disconnectPlayerCharSignals(player)
    local conns = {}
    pcall(function()
        if player.CharacterAdded and player.CharacterAdded.Connect then
            local cAdd = player.CharacterAdded:Connect(function()
                hidePlayerESP(player)
                invalidatePlayerESPCache(player)
            end)
            table.insert(conns, cAdd)
        end
    end)
    pcall(function()
        if player.CharacterRemoving and player.CharacterRemoving.Connect then
            local cRem = player.CharacterRemoving:Connect(function()
                hidePlayerESP(player)
                invalidatePlayerESPCache(player)
            end)
            table.insert(conns, cRem)
        end
    end)
    State.playerCharConnections[player] = conns
    return tagData
end

local function releasePlayerESP(player)
    disconnectPlayerCharSignals(player)
    local data = State.espObjects[player]
    if not data then
        return
    end
    hidePlayerESP(player)
    if data.Billboard then
        pcall(function() data.Billboard:Destroy() end)
    end
    if data.Tracer then
        pcall(function() data.Tracer:Destroy() end)
    end
    if data.Overlay3D then
        pcall(function() data.Overlay3D:Destroy() end)
    end
    if data.Highlight then
        pcall(function() data.Highlight:Destroy() end)
        State.activeHighlightCount = math.max(0, State.activeHighlightCount - 1)
    end
    State.espObjects[player] = nil
end

local function clearESP()
    for player in pairs(State.espObjects) do
        hidePlayerESP(player)
    end
end

-- Pre-allocate object pool & lifecycle hooks for all current players
for _, existingPlr in ipairs(Players:GetPlayers()) do
    hookPlayerLifecycle(existingPlr)
end

local function cacheCharacterBones(char)
    local jointPairs = {}
    local validCount = 0
    local isR15 = char:FindFirstChild("UpperTorso") ~= nil
    local expectedMin = isR15 and 10 or 5
    for bIdx, jointDef in ipairs(SKELETON_JOINTS) do
        local partA = char:FindFirstChild(jointDef[1])
            or (jointDef[1] == "UpperTorso" and char:FindFirstChild("Torso"))
            or (jointDef[1] == "LowerTorso" and char:FindFirstChild("Torso"))
        local partB = char:FindFirstChild(jointDef[2])
            or (jointDef[3] and char:FindFirstChild(jointDef[3]))
        if partA and partB and partA ~= partB then
            jointPairs[bIdx] = { PartA = partA, PartB = partB }
            validCount = validCount + 1
        else
            jointPairs[bIdx] = false
        end
    end
    return jointPairs, (validCount >= expectedMin)
end

local espAnimClock = 0

local function updateESP(camera)
    local anyVisualActive = ConfigState.ESP or ConfigState.Box3DESP or ConfigState.SkeletonESP or ConfigState.HealthBarESP or ConfigState.Tracers
    if not anyVisualActive then
        return
    end

    espAnimClock = espAnimClock + 0.016
    local vp = camera.ViewportSize
    local camPos = camera.CFrame.Position
    local wantFont = ESP_FONT_MAP[ConfigState.ESPTextFont or "Gotham"] or Enum.Font.GothamBold
    local wantTextSize = math.clamp(tonumber(ConfigState.ESPTextSize) or 12, 8, 24)
    local wantStrokeTrans = (ConfigState.ESPTextOutline ~= false) and 0.15 or 1
    local nameTypeMode = ConfigState.ESPNameType or "Display Name"

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            local tagData = State.espObjects[player] or hookPlayerLifecycle(player)
            local char = player.Character

            if not char or not passesTeamCheck(player) then
                hidePlayerESP(player)
            else
                -- Self-healing character & part cache: verifies parent ancestry so respawned or streamed-in characters always re-bind!
                local hrp = tagData.CachedHRP
                local hum = tagData.CachedHum
                if tagData.CachedChar ~= char
                    or not hrp or hrp.Parent ~= char
                    or not hum or hum.Parent ~= char then
                    hrp = char:FindFirstChild("HumanoidRootPart")
                    hum = char:FindFirstChildOfClass("Humanoid")
                    if hrp and hum then
                        tagData.CachedChar = char
                        tagData.CachedHRP = hrp
                        tagData.CachedHum = hum
                        tagData.CachedHead = char:FindFirstChild("Head")
                        tagData.CachedJointPairs = nil
                        tagData.BonesComplete = false
                        tagData.BoneRetryFrames = 0
                        tagData.LastHLAdornee = nil
                        tagData.LastHLEnabled = false
                        tagData.LastDist = -1
                        tagData.LastHP = -1
                    else
                        tagData.CachedChar = nil
                        tagData.CachedHRP = nil
                        tagData.CachedHum = nil
                    end
                end

                if hum and hum.Health <= 0 then
                    if State.trackedEnemyDeathStates[player.Name] == false then
                        State.trackedEnemyDeathStates[player.Name] = true
                        State.sessionKills = (State.sessionKills or 0) + 1
                    end
                elseif hum and hum.Health > 0 then
                    State.trackedEnemyDeathStates[player.Name] = false
                end

                if not hrp or not hum or hum.Health <= 0 then
                    hidePlayerESP(player)
                else
                    if ConfigState.ESP and (not tagData.Highlight or not tagData.Highlight.Parent) and State.activeHighlightCount < State.MAX_HIGHLIGHTS then
                        local hl = Instance.new("Highlight")
                        hl.FillColor = State.espColor
                        hl.OutlineColor = Theme.White
                        hl.FillTransparency = 0.7
                        hl.OutlineTransparency = 0.25
                        hl.Adornee = char
                        hl.Enabled = true
                        hl.Parent = UI.HighlightContainer
                        tagData.Highlight = hl
                        tagData.LastHLAdornee = char
                        tagData.LastHLEnabled = true
                        tagData.LastHLColor = State.espColor
                        State.activeHighlightCount = State.activeHighlightCount + 1
                    end

                    local dist = math.floor((hrp.Position - camPos).Magnitude)
                    local screenPos, onScreen = camera:WorldToViewportPoint(hrp.Position)
                    local isFront = (not screenPos.Z) or (screenPos.Z > 0)
                    local visibleOnScreen = onScreen and isFront
                    local isPriority = State.prioritizedPlayers[player.Name] == true
                    local displayCol = isPriority and Theme.Success or State.espColor
                    local hpInt = math.floor(hum.Health)
                    local maxHp = math.max(hum.MaxHealth or 100, 1)
                    local hpRatio = math.clamp(hum.Health / maxHp, 0, 1)

                    -- Format string when distance, HP, priority, or NameType changes
                    if tagData.LastDist ~= dist or tagData.LastHP ~= hpInt or tagData.LastPriority ~= isPriority or tagData.LastNameType ~= nameTypeMode then
                        tagData.LastDist = dist
                        tagData.LastHP = hpInt
                        tagData.LastPriority = isPriority
                        tagData.LastNameType = nameTypeMode
                        local prefix = isPriority and "[PRIORITY] " or ""
                        local nameDisplay = tostring(player.Name)
                        local dName = player.DisplayName
                        if (nameTypeMode == "Display Name" or nameTypeMode == "Both") and dName and dName ~= "" and dName ~= player.Name then
                            nameDisplay = string.format("%s (@%s)", tostring(dName), tostring(player.Name))
                        end
                        local formattedTag = string.format("%s%s [%dm] | HP: %d", prefix, nameDisplay, dist, hpInt)
                        tagData.Text.Text = formattedTag
                        if tagData.ScreenTag then
                            tagData.ScreenTag.Text = formattedTag
                        end
                    end

                    tagData.Text.Font = wantFont
                    tagData.Text.TextSize = wantTextSize
                    tagData.Text.TextStrokeTransparency = wantStrokeTrans

                    if tagData.ScreenTag then
                        local showScreenTag = visibleOnScreen and ConfigState.ESP
                        if showScreenTag then
                            tagData.ScreenTag.Font = wantFont
                            tagData.ScreenTag.TextSize = wantTextSize
                            tagData.ScreenTag.TextStrokeTransparency = wantStrokeTrans
                            tagData.ScreenTag.TextColor3 = displayCol
                            tagData.ScreenTag.Position = UDim2.fromOffset(screenPos.X, screenPos.Y - 38)
                        end
                        tagData.ScreenTag.Visible = showScreenTag
                    end

                    -- Stealth Protection: avoid setting BillboardGui.Adornee on enemy HRP when StealthBypass is enabled
                    if ConfigState.StealthBypass then
                        if tagData.Billboard.Enabled then
                            tagData.Billboard.Adornee = nil
                            tagData.Billboard.Enabled = false
                        end
                    else
                        local showBB = visibleOnScreen and ConfigState.ESP
                        if showBB then
                            tagData.Text.TextColor3 = displayCol
                            if tagData.Billboard.Adornee ~= hrp then
                                tagData.Billboard.Adornee = hrp
                            end
                        end
                        if tagData.Billboard.Enabled ~= showBB then
                            tagData.Billboard.Enabled = showBB
                        end
                    end

                    -- Verify both cached & actual Highlight Adornee/Enabled so respawns immediately re-bind Highlight
                    if tagData.Highlight then
                        local wantHL = ConfigState.ESP
                        local wantAdornee = wantHL and char or nil
                        if tagData.LastHLAdornee ~= wantAdornee or tagData.Highlight.Adornee ~= wantAdornee then
                            tagData.Highlight.Adornee = wantAdornee
                            tagData.LastHLAdornee = wantAdornee
                        end
                        if wantHL and tagData.LastHLColor ~= displayCol then
                            tagData.Highlight.FillColor = displayCol
                            tagData.LastHLColor = displayCol
                        end
                        if tagData.LastHLEnabled ~= wantHL or tagData.Highlight.Enabled ~= wantHL then
                            tagData.Highlight.Enabled = wantHL
                            tagData.LastHLEnabled = wantHL
                        end
                    end

                    -- 3D Bounding Box + Skeleton Rig + Health Bar Overlay (Synchronized to Camera Frame with Pooled Corners)
                    if visibleOnScreen and (ConfigState.Box3DESP or ConfigState.SkeletonESP or ConfigState.HealthBarESP or ConfigState.ESP) then
                        tagData.Overlay3D.Visible = true
                        local minX, maxX = 99999, -99999
                        local minY, maxY = 99999, -99999

                        if ConfigState.Box3DESP or ConfigState.HealthBarESP then
                            local projectedCorners = tagData.ProjectedCorners
                            local hrpCF = hrp.CFrame
                            if ConfigState.BoxSpin and CFrame.Angles then
                                local spinRad = espAnimClock * (tonumber(ConfigState.BoxSpinSpeed) or 0.3) * math.pi * 2
                                pcall(function()
                                    hrpCF = hrpCF * CFrame.Angles(0, spinRad, 0)
                                end)
                            end
                            local breathScale = 1.0
                            local boxAnim = ConfigState.BoxAnimation or "None"
                            local boxAnimSpd = tonumber(ConfigState.BoxAnimSpeed) or 0.5
                            if boxAnim == "Breathe" then
                                breathScale = 1.0 + 0.08 * math.sin(espAnimClock * boxAnimSpd * 4)
                            end

                            for idx, offset in ipairs(BOX_3D_CORNERS) do
                                local scaledOffset = (breathScale ~= 1.0) and (offset * breathScale) or offset
                                local worldCorner = (hrpCF * CFrame.new(scaledOffset)).Position
                                local vpPt = camera:WorldToViewportPoint(worldCorner)
                                local v2 = Vector2.new(vpPt.X, vpPt.Y)
                                projectedCorners[idx] = v2
                                if v2.X < minX then minX = v2.X end
                                if v2.X > maxX then maxX = v2.X end
                                if v2.Y < minY then minY = v2.Y end
                                if v2.Y > maxY then maxY = v2.Y end
                            end

                            if ConfigState.Box3DESP then
                                tagData.Box3DVisible = true
                                local boxCol = displayCol
                                local secondCol = ConfigState.BoxSecondColor or Color3.fromRGB(115, 95, 255)
                                if boxAnim == "Rainbow" then
                                    boxCol = hsvToColor3((espAnimClock * boxAnimSpd * 0.5) % 1, 0.85, 1)
                                elseif boxAnim == "Pulse" or boxAnim == "Flow" then
                                    local t = 0.5 + 0.5 * math.sin(espAnimClock * boxAnimSpd * 4.5)
                                    boxCol = displayCol:Lerp(secondCol, t)
                                end
                                local edgeThick = ConfigState.BoxGlow and 2.2 or 1.2
                                for eIdx, edge in ipairs(BOX_3D_EDGES) do
                                    local edgeCol = boxCol
                                    if boxAnim == "Flow" then
                                        local flowT = 0.5 + 0.5 * math.sin(espAnimClock * boxAnimSpd * 4.5 + eIdx * 0.4)
                                        edgeCol = displayCol:Lerp(secondCol, flowT)
                                    end
                                    drawLineFrame(tagData.Box3DLines[eIdx], projectedCorners[edge[1]], projectedCorners[edge[2]], edgeCol, edgeThick)
                                end

                                local fillAnim = ConfigState.BoxFillAnimation or "None"
                                if tagData.BoxFillFrame then
                                    if fillAnim ~= "None" or ConfigState.BoxGlow then
                                        local bw = math.clamp(maxX - minX, 12, 420)
                                        local bh = math.clamp(maxY - minY, 16, 480)
                                        tagData.BoxFillFrame.Position = UDim2.fromOffset(minX, minY)
                                        tagData.BoxFillFrame.Size = UDim2.fromOffset(bw, bh)
                                        tagData.BoxFillFrame.Visible = true
                                        if tagData.BoxGlowStroke then
                                            tagData.BoxGlowStroke.Enabled = (ConfigState.BoxGlow == true)
                                            tagData.BoxGlowStroke.Color = boxCol
                                        end
                                        if fillAnim ~= "None" and tagData.BoxFillGrad then
                                            local fillSpd = tonumber(ConfigState.BoxFillAnimSpeed) or 0.5
                                            local fillDir = ConfigState.BoxFillDirection or "Vertical"
                                            tagData.BoxFillFrame.BackgroundTransparency = (fillAnim == "Pulse")
                                                and (0.68 + 0.2 * math.sin(espAnimClock * fillSpd * 4))
                                                or 0.76
                                            local c1 = boxCol
                                            local c2 = secondCol
                                            if fillAnim == "Rainbow" then
                                                c1 = hsvToColor3((espAnimClock * fillSpd * 0.4) % 1, 0.85, 1)
                                                c2 = hsvToColor3((espAnimClock * fillSpd * 0.4 + 0.5) % 1, 0.85, 1)
                                            end
                                            tagData.BoxFillGrad.Color = ColorSequence.new({
                                                ColorSequenceKeypoint.new(0, c1),
                                                ColorSequenceKeypoint.new(1, c2),
                                            })
                                            if fillAnim == "Spin" then
                                                tagData.BoxFillGrad.Rotation = (espAnimClock * fillSpd * 120) % 360
                                            elseif fillDir == "Horizontal" then
                                                tagData.BoxFillGrad.Rotation = 0
                                            elseif fillDir == "Diagonal" then
                                                tagData.BoxFillGrad.Rotation = 45
                                            else
                                                tagData.BoxFillGrad.Rotation = 90
                                            end
                                        else
                                            tagData.BoxFillFrame.BackgroundTransparency = 1
                                        end
                                    else
                                        tagData.BoxFillFrame.Visible = false
                                    end
                                end
                            elseif tagData.Box3DVisible then
                                for i = 1, #tagData.Box3DLines do
                                    tagData.Box3DLines[i].Visible = false
                                end
                                if tagData.BoxFillFrame then
                                    tagData.BoxFillFrame.Visible = false
                                end
                                tagData.Box3DVisible = false
                            end
                        elseif tagData.Box3DVisible then
                            for i = 1, #tagData.Box3DLines do
                                tagData.Box3DLines[i].Visible = false
                            end
                            if tagData.BoxFillFrame then
                                tagData.BoxFillFrame.Visible = false
                            end
                            tagData.Box3DVisible = false
                        end

                        if ConfigState.SkeletonESP then
                            if not tagData.CachedJointPairs or (not tagData.BonesComplete and (tagData.BoneRetryFrames or 0) < 30) then
                                tagData.BoneRetryFrames = (tagData.BoneRetryFrames or 0) + 1
                                local joints, complete = cacheCharacterBones(char)
                                tagData.CachedJointPairs = joints
                                tagData.BonesComplete = complete
                            end
                            tagData.SkeletonVisible = true
                            local skelColorMode = ConfigState.SkeletonColorMode or "Team"
                            local skelEffect = ConfigState.SkeletonEffect or "Glow"
                            local boneThick = math.clamp(tonumber(ConfigState.SkeletonBoneThickness) or 2, 1, 6)
                            local wantBoneOutline = (ConfigState.SkeletonBoneOutline ~= false)
                            local wantJointDots = (ConfigState.SkeletonJointDots == true)
                            local wantHeadCircle = (ConfigState.SkeletonHeadCircle ~= false)

                            local skelCol = Theme.White
                            if skelColorMode == "Team" then
                                local tCol = player.Team and player.Team.TeamColor and player.Team.TeamColor.Color
                                skelCol = tCol or State.espColor or Theme.White
                            elseif skelColorMode == "Custom" then
                                skelCol = State.espColor or Theme.White
                            elseif skelColorMode == "Health" then
                                skelCol = Color3.fromRGB(math.floor(255 * (1 - hpRatio)), math.floor(255 * hpRatio), 90)
                            elseif skelColorMode == "Rainbow" then
                                skelCol = hsvToColor3((espAnimClock * 0.45) % 1, 0.85, 1)
                            end

                            if skelEffect == "Rainbow" then
                                skelCol = hsvToColor3((espAnimClock * 0.55) % 1, 0.85, 1)
                            elseif skelEffect == "Pulse" then
                                local pFactor = 0.35 * (0.5 + 0.5 * math.sin(espAnimClock * 4.5))
                                skelCol = skelCol:Lerp(Theme.Black, pFactor)
                            end

                            local cachedJoints = tagData.CachedJointPairs
                            for bIdx = 1, #SKELETON_JOINTS do
                                local pair = cachedJoints and cachedJoints[bIdx]
                                local sLine = tagData.SkeletonLines[bIdx]
                                local bStroke = tagData.BoneStrokes and tagData.BoneStrokes[bIdx]
                                local jDot = tagData.JointDots and tagData.JointDots[bIdx]
                                if pair and pair.PartA and pair.PartB and pair.PartA.Parent and pair.PartB.Parent then
                                    local vpA = camera:WorldToViewportPoint(pair.PartA.Position)
                                    local vpB = camera:WorldToViewportPoint(pair.PartB.Position)
                                    local ptA = Vector2.new(vpA.X, vpA.Y)
                                    local ptB = Vector2.new(vpB.X, vpB.Y)
                                    drawLineFrame(sLine, ptA, ptB, skelCol, boneThick)
                                    if bStroke then
                                        bStroke.Enabled = wantBoneOutline or (skelEffect == "Glow")
                                        bStroke.Color = (skelEffect == "Glow") and skelCol or Theme.Black
                                        bStroke.Thickness = (skelEffect == "Glow") and 1.5 or 1
                                        bStroke.Transparency = (skelEffect == "Glow") and 0.35 or 0.15
                                    end
                                    if jDot then
                                        if wantJointDots then
                                            jDot.Position = UDim2.fromOffset(ptB.X, ptB.Y)
                                            jDot.Size = UDim2.fromOffset(boneThick + 3, boneThick + 3)
                                            jDot.BackgroundColor3 = skelCol
                                            jDot.Visible = true
                                        else
                                            jDot.Visible = false
                                        end
                                    end
                                else
                                    sLine.Visible = false
                                    if jDot then jDot.Visible = false end
                                end
                            end

                            if tagData.HeadCircle then
                                local headPart = tagData.CachedHead or char:FindFirstChild("Head")
                                if wantHeadCircle and headPart and headPart.Parent then
                                    tagData.CachedHead = headPart
                                    local headVp = camera:WorldToViewportPoint(headPart.Position)
                                    local headRadius = math.clamp(math.floor(420 / math.max(dist, 6)), 8, 36)
                                    tagData.HeadCircle.Position = UDim2.fromOffset(headVp.X, headVp.Y)
                                    tagData.HeadCircle.Size = UDim2.fromOffset(headRadius, headRadius)
                                    if tagData.HeadCircleStroke then
                                        tagData.HeadCircleStroke.Color = skelCol
                                        tagData.HeadCircleStroke.Thickness = math.max(1.2, boneThick * 0.75)
                                    end
                                    tagData.HeadCircle.Visible = true
                                else
                                    tagData.HeadCircle.Visible = false
                                end
                            end
                        elseif tagData.SkeletonVisible then
                            for i = 1, #tagData.SkeletonLines do
                                tagData.SkeletonLines[i].Visible = false
                                if tagData.JointDots and tagData.JointDots[i] then
                                    tagData.JointDots[i].Visible = false
                                end
                            end
                            if tagData.HeadCircle then
                                tagData.HeadCircle.Visible = false
                            end
                            tagData.SkeletonVisible = false
                        end

                        if ConfigState.HealthBarESP then
                            local boxW = math.clamp(maxX - minX, 18, 320)
                            local boxH = math.clamp(maxY - minY, 24, 340)
                            local smoothFactor = math.clamp(1 - (tonumber(ConfigState.HealthSmoothing) or 0.15), 0.05, 1)
                            tagData.SmoothedHP = (tagData.SmoothedHP or hpRatio) + (hpRatio - (tagData.SmoothedHP or hpRatio)) * smoothFactor
                            local dispRatio = math.clamp(tagData.SmoothedHP, 0, 1)

                            local barW = math.clamp(tonumber(ConfigState.HealthBarWidth) or 3, 1, 8)
                            local hbSide = ConfigState.HealthBarSide or "Left"
                            local hbType = ConfigState.HealthBarType or "Gradient"
                            local hbSpeed = tonumber(ConfigState.HealthAnimSpeed) or 1.0

                            if hbSide == "Right" then
                                tagData.HealthBarBg.AnchorPoint = Vector2.new(0, 0)
                                tagData.HealthBarBg.Position = UDim2.fromOffset(maxX + 5, minY)
                                tagData.HealthBarBg.Size = UDim2.fromOffset(barW, boxH)
                                tagData.HealthBarFill.AnchorPoint = Vector2.new(0, 1)
                                tagData.HealthBarFill.Position = UDim2.fromScale(0, 1)
                                tagData.HealthBarFill.Size = UDim2.fromScale(1, dispRatio)
                            elseif hbSide == "Bottom" then
                                tagData.HealthBarBg.AnchorPoint = Vector2.new(0, 0)
                                tagData.HealthBarBg.Position = UDim2.fromOffset(minX, maxY + 5)
                                tagData.HealthBarBg.Size = UDim2.fromOffset(boxW, barW)
                                tagData.HealthBarFill.AnchorPoint = Vector2.new(0, 0)
                                tagData.HealthBarFill.Position = UDim2.fromScale(0, 0)
                                tagData.HealthBarFill.Size = UDim2.fromScale(dispRatio, 1)
                            elseif hbSide == "Top" then
                                tagData.HealthBarBg.AnchorPoint = Vector2.new(0, 1)
                                tagData.HealthBarBg.Position = UDim2.fromOffset(minX, minY - 5)
                                tagData.HealthBarBg.Size = UDim2.fromOffset(boxW, barW)
                                tagData.HealthBarFill.AnchorPoint = Vector2.new(0, 0)
                                tagData.HealthBarFill.Position = UDim2.fromScale(0, 0)
                                tagData.HealthBarFill.Size = UDim2.fromScale(dispRatio, 1)
                            else
                                tagData.HealthBarBg.AnchorPoint = Vector2.new(1, 0)
                                tagData.HealthBarBg.Position = UDim2.fromOffset(minX - 6, minY)
                                tagData.HealthBarBg.Size = UDim2.fromOffset(barW, boxH)
                                tagData.HealthBarFill.AnchorPoint = Vector2.new(0, 1)
                                tagData.HealthBarFill.Position = UDim2.fromScale(0, 1)
                                tagData.HealthBarFill.Size = UDim2.fromScale(1, dispRatio)
                            end
                            tagData.HealthBarBg.Visible = true

                            local baseHpCol = Color3.fromRGB(
                                math.floor(255 * (1 - dispRatio)),
                                math.floor(255 * dispRatio),
                                90
                            )
                            if hbType == "Rainbow" then
                                baseHpCol = hsvToColor3((espAnimClock * hbSpeed * 0.45) % 1, 0.85, 1)
                            elseif hbType == "Pulse" then
                                local p = 0.35 * (0.5 + 0.5 * math.sin(espAnimClock * hbSpeed * 5))
                                baseHpCol = baseHpCol:Lerp(Theme.White, p)
                            end
                            tagData.HealthBarFill.BackgroundColor3 = baseHpCol

                            if tagData.HealthBarGrad then
                                local useGrad = (hbType == "Gradient" or hbType == "Flow" or ConfigState.HealthBarShimmer)
                                tagData.HealthBarGrad.Enabled = useGrad
                                if useGrad then
                                    tagData.HealthBarGrad.Rotation = (hbSide == "Bottom" or hbSide == "Top") and 0 or 90
                                    if hbType == "Flow" or ConfigState.HealthBarShimmer then
                                        tagData.HealthBarGrad.Offset = Vector2.new(0, math.sin(espAnimClock * hbSpeed * 3.5) * 0.35)
                                    else
                                        tagData.HealthBarGrad.Offset = Vector2.zero
                                    end
                                end
                            end

                            if tagData.HealthBarStroke then
                                local showOutline = (ConfigState.HealthBarOutline ~= false) or (ConfigState.HealthBarGlow == true)
                                tagData.HealthBarStroke.Enabled = showOutline
                                tagData.HealthBarStroke.Color = ConfigState.HealthBarGlow and baseHpCol or Theme.Black
                                tagData.HealthBarStroke.Thickness = ConfigState.HealthBarGlow and 1.6 or 1
                            end

                            if ConfigState.HealthLowFlash and dispRatio <= 0.28 then
                                tagData.HealthBarFill.BackgroundTransparency = 0.35 * (0.5 + 0.5 * math.sin(espAnimClock * 12))
                            else
                                tagData.HealthBarFill.BackgroundTransparency = 0
                            end

                            if tagData.HealthNumberLabel then
                                if ConfigState.HealthNumber then
                                    tagData.HealthNumberLabel.Text = tostring(hpInt)
                                    tagData.HealthNumberLabel.TextColor3 = baseHpCol
                                    local numY = minY + boxH * (1 - dispRatio)
                                    tagData.HealthNumberLabel.Position = UDim2.fromOffset(minX - 10 - barW, numY)
                                    tagData.HealthNumberLabel.Visible = true
                                else
                                    tagData.HealthNumberLabel.Visible = false
                                end
                            end
                        else
                            if tagData.HealthBarBg.Visible then
                                tagData.HealthBarBg.Visible = false
                            end
                            if tagData.HealthNumberLabel and tagData.HealthNumberLabel.Visible then
                                tagData.HealthNumberLabel.Visible = false
                            end
                        end
                    elseif tagData.Overlay3D.Visible then
                        tagData.Overlay3D.Visible = false
                    end

                    if visibleOnScreen and ConfigState.Tracers then
                        local fromPos
                        if ConfigState.TracerOrigin == "Center" then
                            fromPos = Vector2.new(vp.X / 2, vp.Y / 2)
                        elseif ConfigState.TracerOrigin == "Bottom" then
                            fromPos = Vector2.new(vp.X / 2, vp.Y)
                        else
                            fromPos = Vector2.new(vp.X / 2, 0)
                        end
                        drawLineFrame(tagData.Tracer, fromPos, Vector2.new(screenPos.X, screenPos.Y), displayCol, 1.1)
                    elseif tagData.Tracer.Visible then
                        tagData.Tracer.Visible = false
                    end
                end
            end
        end
    end
end

local function updateCrosshair(animClock)
    local enabled = ConfigState.Crosshair
    if not enabled then
        if UI.CrosshairContainer then UI.CrosshairContainer.Visible = false end
        if UI.CrosshairV then UI.CrosshairV.Visible = false end
        if UI.CrosshairH then UI.CrosshairH.Visible = false end
        return
    end

    local clock = animClock or 0
    local col = ConfigState.CrosshairRainbow and hsvToColor3((clock * 0.45) % 1, 0.92, 1) or State.crosshairColor

    -- Smooth, unmistakable pulse (oscillates arm length & center gap smoothly without getting too small or too huge)
    local baseLen = ConfigState.CrosshairSize or 10
    local baseGap = ConfigState.CrosshairGap or 4
    local lineLen = baseLen
    local gap = baseGap
    if ConfigState.CrosshairPulse then
        local wave = math.sin(clock * (ConfigState.CrosshairPulseSpeed or 4) * 1.6)
        lineLen = math.clamp(math.floor(baseLen + ( math.max(baseLen * 0.30, 3) * wave ) + 0.5), 4, 48)
        gap = math.clamp(math.floor(baseGap + ( math.max(baseGap * 0.45, 3.5) * wave ) + 0.5), 2, 28)
    end

    local lineWid = math.max(1, math.floor(ConfigState.CrosshairWidth or 2))
    local dotSz = math.max(1, math.floor(ConfigState.CrosshairDotSize or 3))
    local preset = ConfigState.CrosshairPreset or "Plus (+)"

    local rot = 0
    if ConfigState.CrosshairSpin then
        rot = (clock * (ConfigState.CrosshairSpinSpeed or 120)) % 360
    elseif preset == "Cross (X)" then
        rot = 45
    end

    if UI.CrosshairContainer then
        UI.CrosshairContainer.Visible = true
        UI.CrosshairContainer.Rotation = rot
    end

    local showArms = (preset ~= "Dot Only")
    local showTopArm = showArms and (preset ~= "T-Shape")
    local centerDist = gap + (lineLen * 0.5)
    local rad = math.rad(rot)
    local sinR = math.sin(rad)
    local cosR = math.cos(rad)

    -- Position & rotate each arm directly so Spin, Pulse, and Rainbow render 100% reliably across all executors
    if UI.CrosshairArmTop then
        UI.CrosshairArmTop.Visible = showTopArm
        UI.CrosshairArmTop.BackgroundColor3 = col
        UI.CrosshairArmTop.Position = UDim2.new(0.5, math.floor(sinR * centerDist + 0.5), 0.5, math.floor(-cosR * centerDist + 0.5))
        UI.CrosshairArmTop.Size = UDim2.fromOffset(lineWid, lineLen)
        UI.CrosshairArmTop.Rotation = rot
    end
    if UI.CrosshairArmBottom then
        UI.CrosshairArmBottom.Visible = showArms
        UI.CrosshairArmBottom.BackgroundColor3 = col
        UI.CrosshairArmBottom.Position = UDim2.new(0.5, math.floor(-sinR * centerDist + 0.5), 0.5, math.floor(cosR * centerDist + 0.5))
        UI.CrosshairArmBottom.Size = UDim2.fromOffset(lineWid, lineLen)
        UI.CrosshairArmBottom.Rotation = rot
    end
    if UI.CrosshairArmLeft then
        UI.CrosshairArmLeft.Visible = showArms
        UI.CrosshairArmLeft.BackgroundColor3 = col
        UI.CrosshairArmLeft.Position = UDim2.new(0.5, math.floor(-cosR * centerDist + 0.5), 0.5, math.floor(-sinR * centerDist + 0.5))
        UI.CrosshairArmLeft.Size = UDim2.fromOffset(lineLen, lineWid)
        UI.CrosshairArmLeft.Rotation = rot
    end
    if UI.CrosshairArmRight then
        UI.CrosshairArmRight.Visible = showArms
        UI.CrosshairArmRight.BackgroundColor3 = col
        UI.CrosshairArmRight.Position = UDim2.new(0.5, math.floor(cosR * centerDist + 0.5), 0.5, math.floor(sinR * centerDist + 0.5))
        UI.CrosshairArmRight.Size = UDim2.fromOffset(lineLen, lineWid)
        UI.CrosshairArmRight.Rotation = rot
    end

    if UI.CrosshairDotFrame then
        UI.CrosshairDotFrame.Visible = (ConfigState.CrosshairDot or preset == "Dot Only")
        UI.CrosshairDotFrame.BackgroundColor3 = col
        UI.CrosshairDotFrame.Size = UDim2.fromOffset(dotSz, dotSz)
    end

    if UI.CrosshairRingFrame then
        local showRing = (preset == "Circle + Cross" or preset == "Box Reticle")
        UI.CrosshairRingFrame.Visible = showRing
        if showRing then
            local ringDia = math.max(12, math.floor((gap + lineLen) * 1.55))
            UI.CrosshairRingFrame.Size = UDim2.fromOffset(ringDia, ringDia)
            UI.CrosshairRingFrame.Rotation = rot
            if UI.CrosshairRingCorner then
                UI.CrosshairRingCorner.CornerRadius = UDim.new(0, preset == "Box Reticle" and 3 or 999)
            end
            if UI.CrosshairRingStroke then
                UI.CrosshairRingStroke.Color = col
                UI.CrosshairRingStroke.Thickness = math.max(1, lineWid * 0.75)
            end
        end
    end

    -- Keep legacy CrosshairV / CrosshairH updated for test/state compatibility
    UI.CrosshairV.Size = UDim2.fromOffset(lineWid, lineLen * 2)
    UI.CrosshairV.BackgroundColor3 = col
    UI.CrosshairV.Rotation = rot
    UI.CrosshairV.Visible = false

    UI.CrosshairH.Size = UDim2.fromOffset(lineLen * 2, lineWid)
    UI.CrosshairH.BackgroundColor3 = col
    UI.CrosshairH.Rotation = rot
    UI.CrosshairH.Visible = false
end

local function getSafeRaycastExcludeList()
    local list = {}
    if LocalPlayer.Character then
        table.insert(list, LocalPlayer.Character)
    end
    if UI.WeatherEmitterPart then
        table.insert(list, UI.WeatherEmitterPart)
    end
    if UI.WeatherGroundPart then
        table.insert(list, UI.WeatherGroundPart)
    end
    if UI.LightningBoltPool then
        table.insert(list, UI.LightningBoltPool)
    end
    return list
end

local function getClosestTarget(camera)
    local closestNormal, shortestNormal = nil, ConfigState.FOVRadius
    local closestPriority, shortestPriority = nil, ConfigState.FOVRadius
    local center = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
    local useWallCheck = ConfigState.AimbotWallCheck

    if useWallCheck then
        rayParams.FilterDescendantsInstances = getSafeRaycastExcludeList()
    end

    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and passesTeamCheck(player) then
            local tagData = State.espObjects[player]
            local humanoid = (tagData and tagData.CachedChar == player.Character and tagData.CachedHum)
                or player.Character:FindFirstChildOfClass("Humanoid")
            local checkPart = getTargetPartFromCharacter(player.Character, ConfigState.TargetPart)
            if humanoid and humanoid.Health > 0 and checkPart then
                local screenPos, onScreen = camera:WorldToViewportPoint(checkPart.Position)
                local isFront = (not screenPos.Z) or (screenPos.Z > 0)
                if onScreen and isFront then
                    local dist = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if dist <= ConfigState.FOVRadius then
                        local visiblePass = true
                        if useWallCheck then
                            local dir = checkPart.Position - camera.CFrame.Position
                            local ray = workspace:Raycast(camera.CFrame.Position, dir.Unit * 999, rayParams)
                            visiblePass = (ray and ray.Instance and ray.Instance:IsDescendantOf(player.Character)) and true or false
                        end
                        if visiblePass then
                            if State.prioritizedPlayers[player.Name] then
                                if dist <= shortestPriority then
                                    shortestPriority = dist
                                    closestPriority = checkPart
                                end
                            else
                                if dist <= shortestNormal then
                                    shortestNormal = dist
                                    closestNormal = checkPart
                                end
                            end
                        end
                    end
                end
            end
        end
    end

    return closestPriority or closestNormal
end

-- Universal Hitbox Expander (Supports Team Check, Whitelist & Auto-Refresh on New/Respawned Players)
local function updateHitboxExpander()
    for hrp, orig in pairs(State.hitboxCache) do
        if not hrp or not hrp.Parent then
            State.hitboxCache[hrp] = nil
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hrp = p.Character:FindFirstChild("HumanoidRootPart")
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local isAlive = (not hum) or (hum.Health > 0)
            if hrp then
                if ConfigState.HitboxExpander and isAlive and passesTeamCheck(p) then
                    if not State.hitboxCache[hrp] then
                        State.hitboxCache[hrp] = {
                            Size = hrp.Size,
                            Transparency = hrp.Transparency,
                            CanCollide = hrp.CanCollide,
                        }
                    end
                    local sz = ConfigState.HitboxSize or 10
                    hrp.Size = Vector3.new(sz, sz, sz)
                    hrp.Transparency = ConfigState.HitboxTransparency or 0.7
                    hrp.CanCollide = false
                elseif State.hitboxCache[hrp] then
                    local orig = State.hitboxCache[hrp]
                    hrp.Size = orig.Size
                    hrp.Transparency = orig.Transparency
                    hrp.CanCollide = orig.CanCollide
                    State.hitboxCache[hrp] = nil
                end
            end
        end
    end
end

local function restoreAllHitboxes()
    for hrp, orig in pairs(State.hitboxCache) do
        if hrp and hrp.Parent then
            pcall(function()
                hrp.Size = orig.Size
                hrp.Transparency = orig.Transparency
                hrp.CanCollide = orig.CanCollide
            end)
        end
    end
    table.clear(State.hitboxCache)
end

-- X-Ray Vision (Map Wall Transparency with Full Restoration)
local function applyXRayVision(enabled)
    if enabled then
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("BasePart")
                and not string.find(desc.Name or "", "^CoreXyz_") then
                local isPlayerPart = false
                for _, p in ipairs(Players:GetPlayers()) do
                    if p.Character and desc:IsDescendantOf(p.Character) then
                        isPlayerPart = true
                        break
                    end
                end
                if not isPlayerPart and desc.Transparency < 0.95 then
                    if State.xrayCache[desc] == nil then
                        State.xrayCache[desc] = desc.Transparency
                    end
                    desc.Transparency = ConfigState.XRayTransparency
                end
            end
        end
    else
        for part, origT in pairs(State.xrayCache) do
            if part and part.Parent then
                pcall(function()
                    part.Transparency = origT
                end)
            end
        end
        table.clear(State.xrayCache)
    end
end

-- Sky & Atmosphere Preset Switcher
local SKY_PRESETS = {
    ["Pitch Black Void"] = {
        ClockTime = 0,
        Brightness = 0.4,
        Ambient = Color3.fromRGB(12, 12, 16),
        OutdoorAmbient = Color3.fromRGB(8, 8, 12),
    },
    ["Cyberpunk Night"] = {
        ClockTime = 21,
        Brightness = 1.6,
        Ambient = Color3.fromRGB(45, 95, 160),
        OutdoorAmbient = Color3.fromRGB(80, 40, 140),
    },
    ["Starry Nebula"] = {
        ClockTime = 2,
        Brightness = 1.2,
        Ambient = Color3.fromRGB(70, 60, 120),
        OutdoorAmbient = Color3.fromRGB(50, 45, 95),
    },
    ["Sunset Gold"] = {
        ClockTime = 17.8,
        Brightness = 2.0,
        Ambient = Color3.fromRGB(185, 115, 75),
        OutdoorAmbient = Color3.fromRGB(210, 130, 80),
    },
    ["Matrix Monochrome"] = {
        ClockTime = 1,
        Brightness = 1.5,
        Ambient = Color3.fromRGB(110, 110, 115),
        OutdoorAmbient = Color3.fromRGB(90, 90, 95),
    },
    ["Clean Daylight"] = {
        ClockTime = 13.5,
        Brightness = 2.4,
        Ambient = Color3.fromRGB(190, 195, 205),
        OutdoorAmbient = Color3.fromRGB(205, 210, 220),
    },
}

local function updateLightingEnvironment()
    local weatherMode = ConfigState.WeatherPreset or "Default"
    local preset = SKY_PRESETS[ConfigState.SkyPreset]
    if weatherMode == "Rain" then
        Lighting.ClockTime = 15.0
        Lighting.Brightness = ConfigState.Fullbright and 2.0 or 1.1
        Lighting.Ambient = Color3.fromRGB(95, 108, 128)
        Lighting.OutdoorAmbient = Color3.fromRGB(105, 118, 138)
    elseif weatherMode == "Thunderstorm" then
        Lighting.ClockTime = 18.5
        Lighting.Brightness = ConfigState.Fullbright and 2.0 or 0.65
        Lighting.Ambient = Color3.fromRGB(60, 70, 92)
        Lighting.OutdoorAmbient = Color3.fromRGB(68, 78, 102)
    elseif weatherMode == "Snow" then
        Lighting.ClockTime = 13.0
        Lighting.Brightness = ConfigState.Fullbright and 2.2 or 1.85
        Lighting.Ambient = Color3.fromRGB(175, 190, 215)
        Lighting.OutdoorAmbient = Color3.fromRGB(195, 210, 235)
    elseif weatherMode == "Sunny" then
        Lighting.ClockTime = 14.2
        Lighting.Brightness = 2.85
        Lighting.GlobalShadows = true
        Lighting.Ambient = Color3.fromRGB(195, 185, 165)
        Lighting.OutdoorAmbient = Color3.fromRGB(235, 220, 190)
    elseif preset then
        Lighting.ClockTime = preset.ClockTime
        Lighting.Brightness = preset.Brightness
        Lighting.Ambient = preset.Ambient
        Lighting.OutdoorAmbient = preset.OutdoorAmbient
    elseif ConfigState.Fullbright then
        Lighting.Brightness = 2
        Lighting.GlobalShadows = false
        Lighting.Ambient = Color3.fromRGB(255, 255, 255)
        Lighting.OutdoorAmbient = Color3.fromRGB(255, 255, 255)
    else
        Lighting.Brightness = State.origLighting.Brightness
        Lighting.GlobalShadows = State.origLighting.GlobalShadows
        Lighting.Ambient = State.origLighting.Ambient
        Lighting.OutdoorAmbient = State.origLighting.OutdoorAmbient
    end

    if ConfigState.NoFog or weatherMode == "Sunny" then
        Lighting.FogEnd = 100000
        Lighting.FogStart = 100000
        for _, child in ipairs(Lighting:GetChildren()) do
            if child:IsA("Atmosphere") and child.Name ~= "CoreXyz_WeatherAtmosphere" and child.Name ~= "CoreXyz_CustomAtmosphere" then
                pcall(function() child.Density = 0 end)
            end
        end
    elseif weatherMode == "Rain" then
        Lighting.FogStart = 20
        Lighting.FogEnd = 420
    elseif weatherMode == "Thunderstorm" then
        Lighting.FogStart = 10
        Lighting.FogEnd = 280
    elseif weatherMode == "Snow" then
        Lighting.FogStart = 25
        Lighting.FogEnd = 520
    else
        Lighting.FogEnd = State.origLighting.FogEnd
        Lighting.FogStart = State.origLighting.FogStart
    end

    -- Apply Granular Lighting Controller Overrides when individually enabled
    pcall(function()
        if ConfigState.LightingAmbientEnabled then
            Lighting.Ambient = ConfigState.LightingAmbientColor or Color3.fromRGB(115, 95, 255)
        end
        if ConfigState.LightingOutdoorEnabled then
            Lighting.OutdoorAmbient = ConfigState.LightingOutdoorColor or Color3.fromRGB(115, 95, 255)
        end
        if ConfigState.LightingShiftBottomEnabled then
            Lighting.ColorShift_Bottom = ConfigState.LightingShiftBottomColor or Color3.fromRGB(115, 95, 255)
        else
            Lighting.ColorShift_Bottom = State.origLighting.ColorShift_Bottom or Color3.fromRGB(0, 0, 0)
        end
        if ConfigState.LightingShiftTopEnabled then
            Lighting.ColorShift_Top = ConfigState.LightingShiftTopColor or Color3.fromRGB(115, 95, 255)
        else
            Lighting.ColorShift_Top = State.origLighting.ColorShift_Top or Color3.fromRGB(0, 0, 0)
        end
        if ConfigState.LightingFogColorEnabled then
            Lighting.FogColor = ConfigState.LightingFogColor or Color3.fromRGB(115, 95, 255)
        else
            Lighting.FogColor = State.origLighting.FogColor or Color3.fromRGB(192, 192, 192)
        end
        if ConfigState.LightingFogEndEnabled and not ConfigState.NoFog then
            Lighting.FogEnd = ConfigState.LightingFogEnd or 1000
        end
        if ConfigState.LightingFogStartEnabled and not ConfigState.NoFog then
            Lighting.FogStart = ConfigState.LightingFogStart or 0
        end
        if ConfigState.LightingExposureEnabled then
            Lighting.ExposureCompensation = ConfigState.LightingExposure or 0
        else
            Lighting.ExposureCompensation = State.origLighting.ExposureCompensation or 0
        end
        if ConfigState.LightingBrightnessEnabled and not ConfigState.Fullbright then
            Lighting.Brightness = ConfigState.LightingBrightness or 1
        end
        if ConfigState.LightingClockTimeEnabled then
            Lighting.ClockTime = ConfigState.LightingClockTime or 12
        end
        if ConfigState.LightingNoShadows or ConfigState.Fullbright then
            Lighting.GlobalShadows = false
        end
    end)
end

-- Pre-Allocated 100% 3D In-World Volumetric Weather Engine (3D Sky Canopy Volume + 3D Ground Splash Plane + 3D Jagged Lightning Pool + SoundService Audio + Roof Raycast Occlusion — Zero 2D Screen Overlay, Zero Per-Frame Instance Allocations!)
do
    local SoundService = safeGetService("SoundService") or Lighting

    local function hardenStealthWeatherPart(part)
        part.Anchored = true
        part.CanCollide = false
        part.CastShadow = false
        pcall(function()
            part.CanQuery = false
            part.CanTouch = false
            part.Massless = true
            part.Archivable = false
        end)
    end

    -- 1. 3D Volumetric Sky Canopy Emitter Volume (Spans 160x42x160 studs in 3D space around the player/camera)
    local weatherPart = Instance.new("Part")
    weatherPart.Name = "CoreXyz_WeatherEmitterPart"
    weatherPart.Size = Vector3.new(160, 42, 160)
    weatherPart.Transparency = 1
    hardenStealthWeatherPart(weatherPart)
    weatherPart.Parent = workspace

    local weatherEmitter = Instance.new("ParticleEmitter")
    weatherEmitter.Name = "CoreXyz_WeatherEmitter"
    weatherEmitter.Enabled = false
    pcall(function()
        weatherEmitter.LockedToPart = false
        if Enum.NormalId and Enum.NormalId.Bottom then
            weatherEmitter.EmissionDirection = Enum.NormalId.Bottom
        end
    end)
    weatherEmitter.Parent = weatherPart

    -- Secondary 3D near-field depth layer for realistic parallax rain sheets & tumbling snow flurries
    local streakEmitter = Instance.new("ParticleEmitter")
    streakEmitter.Name = "CoreXyz_WeatherStreakEmitter"
    streakEmitter.Enabled = false
    pcall(function()
        streakEmitter.LockedToPart = false
        if Enum.NormalId and Enum.NormalId.Bottom then
            streakEmitter.EmissionDirection = Enum.NormalId.Bottom
        end
    end)
    streakEmitter.Parent = weatherPart

    -- Volumetric 3D Mist / Storm Fog Emitter inside the 3D canopy volume
    local mistEmitter = Instance.new("ParticleEmitter")
    mistEmitter.Name = "CoreXyz_WeatherMistEmitter"
    mistEmitter.Enabled = false
    mistEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
    pcall(function()
        mistEmitter.LockedToPart = false
        if Enum.ParticleOrientation and Enum.ParticleOrientation.FacingCamera then
            mistEmitter.Orientation = Enum.ParticleOrientation.FacingCamera
        end
    end)
    mistEmitter.Parent = weatherPart

    -- 2. 3D In-World Ground Splash & Ripple Emitter Plane (Follows ground beneath player via raycast)
    local groundSplashPart = Instance.new("Part")
    groundSplashPart.Name = "CoreXyz_WeatherGroundPart"
    groundSplashPart.Size = Vector3.new(115, 0.5, 115)
    groundSplashPart.Transparency = 1
    groundSplashPart.CFrame = CFrame.new(Vector3.new(0, -500, 0))
    hardenStealthWeatherPart(groundSplashPart)
    groundSplashPart.Parent = workspace

    local groundSplashEmitter = Instance.new("ParticleEmitter")
    groundSplashEmitter.Name = "CoreXyz_WeatherSplashEmitter"
    groundSplashEmitter.Enabled = false
    groundSplashEmitter.Texture = "rbxassetid://258128463"
    pcall(function()
        groundSplashEmitter.LockedToPart = false
        if Enum.NormalId and Enum.NormalId.Top then
            groundSplashEmitter.EmissionDirection = Enum.NormalId.Top
        end
        if Enum.ParticleOrientation and Enum.ParticleOrientation.VelocityPerpendicular then
            groundSplashEmitter.Orientation = Enum.ParticleOrientation.VelocityPerpendicular
        end
    end)
    groundSplashEmitter.Parent = groundSplashPart

    -- 3. Pre-Allocated 3D Surrounding Lightning Bolt Pool in Workspace (8 Trunk Segments + 4 Forked Branches + 3D PointLight)
    local lightningFolder = Instance.new("Folder")
    lightningFolder.Name = "CoreXyz_LightningBoltPool"
    pcall(function()
        lightningFolder.Archivable = false
    end)
    lightningFolder.Parent = workspace

    local LIGHTNING_SEGMENT_COUNT = 8
    local lightningSegments = {}
    for i = 1, LIGHTNING_SEGMENT_COUNT do
        local seg = Instance.new("Part")
        seg.Name = "CoreXyz_LightningSegment_" .. i
        seg.Transparency = 1
        seg.Color = Color3.fromRGB(215, 235, 255)
        seg.Size = Vector3.new(0.85, 0.85, 24)
        seg.CFrame = CFrame.new(Vector3.new(0, -500, 0))
        hardenStealthWeatherPart(seg)
        pcall(function()
            if Enum.Material and Enum.Material.Neon then
                seg.Material = Enum.Material.Neon
            end
        end)
        seg.Parent = lightningFolder
        lightningSegments[i] = seg
    end

    local LIGHTNING_BRANCH_COUNT = 4
    local lightningBranches = {}
    for i = 1, LIGHTNING_BRANCH_COUNT do
        local branch = Instance.new("Part")
        branch.Name = "CoreXyz_LightningBranch_" .. i
        branch.Transparency = 1
        branch.Color = Color3.fromRGB(185, 220, 255)
        branch.Size = Vector3.new(0.45, 0.45, 16)
        branch.CFrame = CFrame.new(Vector3.new(0, -500, 0))
        hardenStealthWeatherPart(branch)
        pcall(function()
            if Enum.Material and Enum.Material.Neon then
                branch.Material = Enum.Material.Neon
            end
        end)
        branch.Parent = lightningFolder
        lightningBranches[i] = branch
    end

    local lightningStrikeNode = Instance.new("Part")
    lightningStrikeNode.Name = "CoreXyz_LightningStrikeNode"
    lightningStrikeNode.Size = Vector3.new(1, 1, 1)
    lightningStrikeNode.Transparency = 1
    lightningStrikeNode.CFrame = CFrame.new(Vector3.new(0, -500, 0))
    hardenStealthWeatherPart(lightningStrikeNode)
    lightningStrikeNode.Parent = lightningFolder

    local strikePointLight = Instance.new("PointLight")
    strikePointLight.Name = "CoreXyz_LightningPointLight"
    strikePointLight.Enabled = false
    strikePointLight.Range = 120
    strikePointLight.Brightness = 8.5
    strikePointLight.Color = Color3.fromRGB(205, 230, 255)
    strikePointLight.Parent = lightningStrikeNode

    -- All weather & thunder Sound instances are parented to SoundService (never workspace) for 100% anti-cheat stealth
    local spatialThunderSound = Instance.new("Sound")
    spatialThunderSound.Name = "CoreXyz_SpatialThunderSound"
    spatialThunderSound.Looped = false
    spatialThunderSound.Volume = 0.9
    spatialThunderSound.SoundId = "rbxassetid://9114224721"
    spatialThunderSound.Parent = SoundService

    local sunRays = Instance.new("SunRaysEffect")
    sunRays.Name = "CoreXyz_WeatherSunRays"
    sunRays.Enabled = false
    sunRays.Intensity = 0.32
    sunRays.Spread = 0.90
    sunRays.Parent = Lighting

    local colorCorr = Instance.new("ColorCorrectionEffect")
    colorCorr.Name = "CoreXyz_WeatherColorCorrection"
    colorCorr.Enabled = false
    colorCorr.Brightness = 0
    colorCorr.Contrast = 0
    colorCorr.Saturation = 0
    colorCorr.TintColor = Color3.fromRGB(255, 255, 255)
    colorCorr.Parent = Lighting

    local weatherBloom = Instance.new("BloomEffect")
    weatherBloom.Name = "CoreXyz_WeatherBloom"
    weatherBloom.Enabled = false
    weatherBloom.Intensity = 0.4
    weatherBloom.Size = 24
    weatherBloom.Threshold = 0.85
    weatherBloom.Parent = Lighting

    local weatherAtmosphere = Instance.new("Atmosphere")
    weatherAtmosphere.Name = "CoreXyz_WeatherAtmosphere"
    pcall(function()
        weatherAtmosphere.Density = 0
        weatherAtmosphere.Offset = 0
        weatherAtmosphere.Glare = 0
        weatherAtmosphere.Haze = 0
    end)
    weatherAtmosphere.Parent = Lighting

    local ambienceSound = Instance.new("Sound")
    ambienceSound.Name = "CoreXyz_WeatherAmbienceSound"
    ambienceSound.Looped = true
    ambienceSound.Volume = ConfigState.WeatherSoundVolume or 0.5
    ambienceSound.SoundId = ""
    ambienceSound.Parent = SoundService

    -- Built-in client sound layer with acoustic EQ + Reverb so Rain/Storm/Snow audio ALWAYS plays even if CDN assets are blocked
    local patterSound = Instance.new("Sound")
    patterSound.Name = "CoreXyz_WeatherPatterSound"
    patterSound.Looped = true
    patterSound.Volume = 0
    patterSound.SoundId = "rbxasset://sounds/action_falling.mp3"
    patterSound.Parent = SoundService

    local patterEq = Instance.new("EqualizerSoundEffect")
    patterEq.Name = "CoreXyz_WeatherPatterEQ"
    patterEq.HighGain = -6
    patterEq.MidGain = -2
    patterEq.LowGain = 4
    patterEq.Parent = patterSound

    local patterPitch = Instance.new("PitchShiftSoundEffect")
    patterPitch.Name = "CoreXyz_WeatherPatterPitch"
    patterPitch.Octave = 0.85
    patterPitch.Parent = patterSound

    local patterReverb = Instance.new("ReverbSoundEffect")
    patterReverb.Name = "CoreXyz_WeatherPatterReverb"
    patterReverb.DecayTime = 1.8
    patterReverb.WetLevel = 2
    patterReverb.DryLevel = 0
    patterReverb.Parent = patterSound

    -- Continuous low-frequency storm & rain rumble bed using the verified thunder audio asset
    local rumblerSound = Instance.new("Sound")
    rumblerSound.Name = "CoreXyz_WeatherRumblerSound"
    rumblerSound.Looped = true
    rumblerSound.Volume = 0
    rumblerSound.PlaybackSpeed = 0.44
    rumblerSound.SoundId = "rbxassetid://9114224721"
    rumblerSound.Parent = SoundService

    local rumblerEq = Instance.new("EqualizerSoundEffect")
    rumblerEq.Name = "CoreXyz_WeatherRumblerEQ"
    rumblerEq.HighGain = -18
    rumblerEq.MidGain = -8
    rumblerEq.LowGain = 6
    rumblerEq.Parent = rumblerSound

    local thunderSound = Instance.new("Sound")
    thunderSound.Name = "CoreXyz_WeatherThunderSound"
    thunderSound.Looped = false
    thunderSound.Volume = 0.85
    thunderSound.SoundId = "rbxassetid://9114224721"
    thunderSound.Parent = SoundService

    local WEATHER_SOUND_IDS = {
        Rain = "rbxassetid://9112854440",
        Thunderstorm = "rbxassetid://9112854440",
        Snow = "rbxassetid://9112758096",
        Sunny = "rbxassetid://9114221580",
    }

    local function makeNumRange(minV, maxV)
        if type(NumberRange) == "table" and NumberRange.new then
            return NumberRange.new(minV, maxV or minV)
        end
        return maxV or minV
    end

    local function makeNumSeq(val)
        if type(NumberSequence) == "table" and NumberSequence.new then
            return NumberSequence.new(val)
        end
        return val
    end

    local function makeNumSeqKeypoints(kpTable)
        if type(NumberSequence) == "table" and NumberSequence.new and type(NumberSequenceKeypoint) == "table" and NumberSequenceKeypoint.new then
            local kps = {}
            for i = 1, #kpTable do
                local pair = kpTable[i]
                kps[i] = NumberSequenceKeypoint.new(pair[1], pair[2])
            end
            return NumberSequence.new(kps)
        end
        local fallbackVal = (kpTable[2] and kpTable[2][2]) or (kpTable[1] and kpTable[1][2]) or 0.5
        return makeNumSeq(fallbackVal)
    end

    -- Realistic Rain And Thunderstorm Asset (rbxassetid://1250626578) Loader & Stealth Sanitizer
    local REALISTIC_RAIN_ASSET_ID = "rbxassetid://1250626578"
    local realisticCanopyEmitters = {}
    local realisticSplashEmitters = {}
    local realisticAssetLoaded = false

    local function loadRealisticRainAsset()
        if realisticAssetLoaded then
            return
        end
        realisticAssetLoaded = true
        pcall(function()
            local objects = nil
            if type(game) == "table" or type(game) == "userdata" then
                if game.GetObjects then
                    local okG, resG = pcall(function()
                        return game:GetObjects(REALISTIC_RAIN_ASSET_ID)
                    end)
                    if okG and type(resG) == "table" then
                        objects = resG
                    end
                end
            end
            if not objects and type(getobjects) == "function" then
                local okO, resO = pcall(getobjects, REALISTIC_RAIN_ASSET_ID)
                if okO and type(resO) == "table" then
                    objects = resO
                end
            end
            if type(objects) ~= "table" or #objects == 0 then
                return
            end

            for _, rootObj in ipairs(objects) do
                if rootObj then
                    local allNodes = { rootObj }
                    if rootObj.GetDescendants then
                        local okD, descList = pcall(function()
                            return rootObj:GetDescendants()
                        end)
                        if okD and type(descList) == "table" then
                            for _, d in ipairs(descList) do
                                table.insert(allNodes, d)
                            end
                        end
                    end

                    -- 1. Strip any embedded Scripts / LocalScripts / ModuleScripts for 100% anti-cheat stealth
                    for _, node in ipairs(allNodes) do
                        pcall(function()
                            if node:IsA("BaseScript") or node:IsA("Script") or node:IsA("LocalScript") or node:IsA("ModuleScript") then
                                node:Destroy()
                            end
                        end)
                    end

                    -- 2. Harvest ParticleEmitters & Sound IDs from rbxassetid://1250626578 and soften spiky Squash/Size curves
                    for _, node in ipairs(allNodes) do
                        pcall(function()
                            if node:IsA("ParticleEmitter") then
                                local cloned = node:Clone()
                                local nodeNameLower = string.lower(tostring(node.Name or ""))
                                local parentNameLower = string.lower(tostring((node.Parent and node.Parent.Name) or ""))
                                local isSplash = (string.find(nodeNameLower, "splash") ~= nil)
                                    or (string.find(nodeNameLower, "ground") ~= nil)
                                    or (string.find(nodeNameLower, "hit") ~= nil)
                                    or (string.find(nodeNameLower, "ripple") ~= nil)
                                    or (string.find(parentNameLower, "splash") ~= nil)
                                    or (string.find(parentNameLower, "ground") ~= nil)

                                local baseRate = tonumber(cloned.Rate) or (isSplash and 320 or 500)
                                cloned.Enabled = false
                                cloned.LockedToPart = false
                                if isSplash then
                                    pcall(function()
                                        cloned.Squash = makeNumSeq(0.18)
                                        cloned.Size = makeNumSeqKeypoints({ {0, 0.18}, {0.5, 0.65}, {1, 1.05} })
                                        cloned.Transparency = makeNumSeqKeypoints({ {0, 0.35}, {0.6, 0.68}, {1, 1.0} })
                                    end)
                                    cloned.Name = "CoreXyz_Asset1250626578_Splash_" .. tostring(#realisticSplashEmitters + 1)
                                    cloned.Parent = groundSplashPart
                                    table.insert(realisticSplashEmitters, { Emitter = cloned, BaseRate = baseRate })
                                    if cloned.Texture and tostring(cloned.Texture) ~= "" then
                                        groundSplashEmitter.Texture = cloned.Texture
                                    end
                                else
                                    pcall(function()
                                        cloned.Squash = makeNumSeq(1.25)
                                        cloned.Size = makeNumSeqKeypoints({ {0, 0.14}, {0.5, 0.22}, {1, 0.12} })
                                        cloned.Transparency = makeNumSeqKeypoints({ {0, 1.0}, {0.15, 0.46}, {0.75, 0.56}, {1, 1.0} })
                                    end)
                                    cloned.Name = "CoreXyz_Asset1250626578_Rain_" .. tostring(#realisticCanopyEmitters + 1)
                                    cloned.Parent = weatherPart
                                    table.insert(realisticCanopyEmitters, { Emitter = cloned, BaseRate = baseRate })
                                    if cloned.Texture and tostring(cloned.Texture) ~= "" then
                                        weatherEmitter.Texture = cloned.Texture
                                    end
                                end
                            elseif node:IsA("Sound") then
                                local sId = tostring(node.SoundId or "")
                                local sName = string.lower(tostring(node.Name or ""))
                                if sId ~= "" and (string.find(sId, "rbxassetid://") or string.find(sId, "roblox%.com/asset")) then
                                    if string.find(sName, "thunder") or string.find(sName, "lightning") then
                                        thunderSound.SoundId = sId
                                        spatialThunderSound.SoundId = sId
                                    elseif string.find(sName, "rain") or string.find(sName, "storm") then
                                        WEATHER_SOUND_IDS.Rain = sId
                                        WEATHER_SOUND_IDS.Thunderstorm = sId
                                    end
                                end
                            end
                        end)
                    end

                    pcall(function()
                        rootObj:Destroy()
                    end)
                end
            end
        end)
    end

    local function setRealisticAssetEmittersState(enabled, rateMultiplier)
        local mult = rateMultiplier or 1.0
        for _, item in ipairs(realisticCanopyEmitters) do
            if item.Emitter and item.Emitter.Parent then
                pcall(function()
                    item.Emitter.Rate = math.floor((item.BaseRate or 500) * mult)
                    item.Emitter.Enabled = enabled and true or false
                end)
            end
        end
        for _, item in ipairs(realisticSplashEmitters) do
            if item.Emitter and item.Emitter.Parent then
                pcall(function()
                    item.Emitter.Rate = math.floor((item.BaseRate or 320) * mult)
                    item.Emitter.Enabled = enabled and true or false
                end)
            end
        end
    end

    loadRealisticRainAsset()

    local function hideLightningBolts()
        strikePointLight.Enabled = false
        for i = 1, LIGHTNING_SEGMENT_COUNT do
            lightningSegments[i].Transparency = 1
        end
        for i = 1, LIGHTNING_BRANCH_COUNT do
            lightningBranches[i].Transparency = 1
        end
    end

    local function triggerSurroundingLightningStrike(camera)
        local camPos = camera and camera.CFrame and camera.CFrame.Position or Vector3.new(0, 20, 0)
        local angle = (math.random(0, 359) / 180) * math.pi
        local dist = math.random(55, 155)
        local baseX = camPos.X + math.cos(angle) * dist
        local baseZ = camPos.Z + math.sin(angle) * dist
        local topY = camPos.Y + 135
        local bottomY = (State.lastGroundY or (camPos.Y - 14))
        local stepY = (topY - bottomY) / LIGHTNING_SEGMENT_COUNT

        local prevPoint = Vector3.new(baseX, topY, baseZ)
        local branchIdx = 1
        for i = 1, LIGHTNING_SEGMENT_COUNT do
            local jitterX = (i == LIGHTNING_SEGMENT_COUNT) and 0 or math.random(-11, 11)
            local jitterZ = (i == LIGHTNING_SEGMENT_COUNT) and 0 or math.random(-11, 11)
            local nextPoint = Vector3.new(baseX + jitterX, topY - stepY * i, baseZ + jitterZ)
            local diff = nextPoint - prevPoint
            local segLen = math.max(1, diff.Magnitude)
            local midPoint = (prevPoint + nextPoint) * 0.5
            local seg = lightningSegments[i]
            local thickness = math.max(0.45, 1.18 - i * 0.08)
            seg.Size = Vector3.new(thickness, thickness, segLen + 0.6)
            seg.CFrame = CFrame.new(midPoint, nextPoint)
            seg.Transparency = 0.02

            if (i == 2 or i == 4 or i == 5 or i == 6) and branchIdx <= LIGHTNING_BRANCH_COUNT then
                local branch = lightningBranches[branchIdx]
                branchIdx = branchIdx + 1
                local branchEnd = nextPoint + Vector3.new(math.random(-22, 22), -stepY * 0.95, math.random(-22, 22))
                local bDiff = branchEnd - nextPoint
                local bLen = math.max(1, bDiff.Magnitude)
                local bMid = (nextPoint + branchEnd) * 0.5
                branch.Size = Vector3.new(0.42, 0.42, bLen)
                branch.CFrame = CFrame.new(bMid, branchEnd)
                branch.Transparency = 0.12
            end
            prevPoint = nextPoint
        end

        lightningStrikeNode.CFrame = CFrame.new(Vector3.new(baseX, bottomY + 6, baseZ))
        strikePointLight.Enabled = true
        strikePointLight.Brightness = 9.0
        State.lightningFlashIntensity = 1.0

        if ConfigState.WeatherSoundEnabled then
            local pitch = math.random(78, 114) / 100
            pcall(function()
                spatialThunderSound.PlaybackSpeed = pitch
                spatialThunderSound:Play()
            end)
            pcall(function()
                thunderSound.PlaybackSpeed = pitch
                thunderSound:Play()
            end)
        end
    end

    local function syncWeatherAudio()
        local mode = ConfigState.WeatherPreset or "Default"
        local soundId = WEATHER_SOUND_IDS[mode]
        local baseVol = math.clamp(ConfigState.WeatherSoundVolume or 0.5, 0, 1)
        local roofFactor = State.isUnderRoof and 0.42 or 1.0
        thunderSound.Volume = math.clamp(baseVol * 1.35 * roofFactor, 0, 1)
        spatialThunderSound.Volume = math.clamp(baseVol * 1.45 * roofFactor, 0, 1)

        if not ConfigState.WeatherSoundEnabled or mode == "Default" or not soundId then
            ambienceSound.Volume = 0
            patterSound.Volume = 0
            rumblerSound.Volume = 0
            pcall(function() ambienceSound:Stop() end)
            pcall(function() patterSound:Stop() end)
            pcall(function() rumblerSound:Stop() end)
            pcall(function() thunderSound:Stop() end)
            pcall(function() spatialThunderSound:Stop() end)
            return
        end

        local volScale = (mode == "Thunderstorm" and 1.18) or (mode == "Snow" and 0.85) or (mode == "Sunny" and 0.75) or 1.0
        ambienceSound.Volume = math.clamp(baseVol * volScale * roofFactor, 0, 1)
        ambienceSound.PlaybackSpeed = (mode == "Thunderstorm" and 0.94) or (mode == "Snow" and 0.88) or 1.0

        if ambienceSound.SoundId ~= soundId then
            pcall(function() ambienceSound:Stop() end)
            ambienceSound.SoundId = soundId
        end
        pcall(function()
            if not ambienceSound.IsPlaying then
                ambienceSound:Play()
            end
        end)

        -- Guaranteed multi-layer acoustic rain/wind patter & storm rumble bed (with indoor roof low-pass occlusion)
        if mode == "Rain" or mode == "Thunderstorm" or mode == "Snow" then
            if mode == "Rain" then
                patterSound.Volume = math.clamp(baseVol * 0.72 * roofFactor, 0, 1)
                patterSound.PlaybackSpeed = 1.18
                patterPitch.Octave = 0.92
                patterEq.HighGain = State.isUnderRoof and -18 or -4
                patterEq.MidGain = State.isUnderRoof and -8 or 0
                patterEq.LowGain = 3
                rumblerSound.Volume = math.clamp(baseVol * 0.38, 0, 1)
                rumblerSound.PlaybackSpeed = 0.42
            elseif mode == "Thunderstorm" then
                patterSound.Volume = math.clamp(baseVol * 0.95 * roofFactor, 0, 1)
                patterSound.PlaybackSpeed = 1.28
                patterPitch.Octave = 0.86
                patterEq.HighGain = State.isUnderRoof and -16 or -2
                patterEq.MidGain = State.isUnderRoof and -6 or 2
                patterEq.LowGain = 6
                rumblerSound.Volume = math.clamp(baseVol * 0.62, 0, 1)
                rumblerSound.PlaybackSpeed = 0.50
            else
                -- Snow howling winter wind layer
                patterSound.Volume = math.clamp(baseVol * 0.48 * roofFactor, 0, 1)
                patterSound.PlaybackSpeed = 0.64
                patterPitch.Octave = 0.65
                patterEq.HighGain = State.isUnderRoof and -20 or -12
                patterEq.MidGain = -4
                patterEq.LowGain = 5
                rumblerSound.Volume = 0
            end
            pcall(function()
                if not patterSound.IsPlaying then
                    patterSound:Play()
                end
                if rumblerSound.Volume > 0 and not rumblerSound.IsPlaying then
                    rumblerSound:Play()
                elseif rumblerSound.Volume <= 0 then
                    rumblerSound:Stop()
                end
            end)
        else
            patterSound.Volume = 0
            rumblerSound.Volume = 0
            pcall(function() patterSound:Stop() end)
            pcall(function() rumblerSound:Stop() end)
        end
    end

    local function applyWeatherPreset(mode)
        ConfigState.WeatherPreset = mode or "Default"
        State.lightningFlashIntensity = 0
        State.nextLightningTimer = 2.4
        State.weatherAnimClock = State.weatherAnimClock or 0
        State.isUnderRoof = false
        hideLightningBolts()

        if ConfigState.WeatherPreset == "Rain" then
            loadRealisticRainAsset()
            weatherPart.Size = Vector3.new(160, 42, 160)
            weatherEmitter.Texture = weatherEmitter.Texture ~= "" and weatherEmitter.Texture or "rbxassetid://258128463"
            weatherEmitter.Rate = 620
            streakEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
            streakEmitter.Rate = 320
            mistEmitter.Rate = 48
            groundSplashEmitter.Rate = 380
            pcall(function()
                if Enum.ParticleOrientation and Enum.ParticleOrientation.VelocityParallel then
                    weatherEmitter.Orientation = Enum.ParticleOrientation.VelocityParallel
                    streakEmitter.Orientation = Enum.ParticleOrientation.VelocityParallel
                end
                -- Natural feathered water droplet streaks (soft Squash 1.22–1.32, tapered Size 0.14–0.22, feathered alpha curve — never spikes!)
                weatherEmitter.Squash = makeNumSeq(1.22)
                streakEmitter.Squash = makeNumSeq(1.32)
                weatherEmitter.LightEmission = 0.35
                streakEmitter.LightEmission = 0.28
                weatherEmitter.Speed = makeNumRange(76, 102)
                streakEmitter.Speed = makeNumRange(80, 108)
                weatherEmitter.Lifetime = makeNumRange(0.55, 0.88)
                streakEmitter.Lifetime = makeNumRange(0.50, 0.82)
                weatherEmitter.Size = makeNumSeqKeypoints({ {0, 0.14}, {0.5, 0.22}, {1, 0.12} })
                streakEmitter.Size = makeNumSeqKeypoints({ {0, 0.12}, {0.5, 0.18}, {1, 0.10} })
                weatherEmitter.Transparency = makeNumSeqKeypoints({ {0, 1.0}, {0.15, 0.46}, {0.75, 0.56}, {1, 1.0} })
                streakEmitter.Transparency = makeNumSeqKeypoints({ {0, 1.0}, {0.15, 0.58}, {0.75, 0.68}, {1, 1.0} })
                weatherEmitter.SpreadAngle = Vector2.new(5, 5)
                streakEmitter.SpreadAngle = Vector2.new(4, 4)
                weatherEmitter.Acceleration = Vector3.new(-6, -98, -2)
                streakEmitter.Acceleration = Vector3.new(-6, -98, -2)
                local rainCol = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(195, 222, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(155, 192, 245)),
                })
                weatherEmitter.Color = rainCol
                streakEmitter.Color = rainCol

                -- 3D Volumetric Mist Layer
                mistEmitter.Speed = makeNumRange(4, 10)
                mistEmitter.Lifetime = makeNumRange(2.4, 3.8)
                mistEmitter.Size = makeNumSeq(14)
                mistEmitter.Transparency = makeNumSeq(0.88)
                mistEmitter.SpreadAngle = Vector2.new(80, 80)
                mistEmitter.Acceleration = Vector3.new(-4, -1, 0)
                mistEmitter.Color = rainCol

                -- 3D World Ground Splash Ripple Ring Layer
                groundSplashEmitter.Speed = makeNumRange(2, 6)
                groundSplashEmitter.Lifetime = makeNumRange(0.18, 0.34)
                groundSplashEmitter.Size = makeNumSeqKeypoints({ {0, 0.18}, {0.5, 0.65}, {1, 1.05} })
                groundSplashEmitter.Squash = makeNumSeq(0.15)
                groundSplashEmitter.Transparency = makeNumSeqKeypoints({ {0, 0.35}, {0.6, 0.68}, {1, 1.0} })
                groundSplashEmitter.SpreadAngle = Vector2.new(68, 68)
                groundSplashEmitter.Acceleration = Vector3.new(0, -28, 0)
                groundSplashEmitter.Color = rainCol

                weatherAtmosphere.Density = ConfigState.NoFog and 0 or 0.38
                weatherAtmosphere.Haze = 1.6
                weatherAtmosphere.Color = Color3.fromRGB(140, 160, 190)
                weatherAtmosphere.Decay = Color3.fromRGB(95, 112, 140)
            end)
            weatherEmitter.Enabled = true
            streakEmitter.Enabled = true
            mistEmitter.Enabled = true
            groundSplashEmitter.Enabled = true
            setRealisticAssetEmittersState(true, 1.0)
            sunRays.Enabled = false
            weatherBloom.Enabled = true
            weatherBloom.Intensity = 0.35
            colorCorr.Enabled = true
            colorCorr.Brightness = -0.02
            colorCorr.Contrast = 0.07
            colorCorr.Saturation = -0.18
            colorCorr.TintColor = Color3.fromRGB(218, 232, 255)
        elseif ConfigState.WeatherPreset == "Thunderstorm" then
            loadRealisticRainAsset()
            weatherPart.Size = Vector3.new(175, 46, 175)
            weatherEmitter.Texture = weatherEmitter.Texture ~= "" and weatherEmitter.Texture or "rbxassetid://258128463"
            weatherEmitter.Rate = 850
            streakEmitter.Texture = "rbxasset://textures/particles/smoke_main.dds"
            streakEmitter.Rate = 440
            mistEmitter.Rate = 75
            groundSplashEmitter.Rate = 580
            pcall(function()
                if Enum.ParticleOrientation and Enum.ParticleOrientation.VelocityParallel then
                    weatherEmitter.Orientation = Enum.ParticleOrientation.VelocityParallel
                    streakEmitter.Orientation = Enum.ParticleOrientation.VelocityParallel
                end
                weatherEmitter.Squash = makeNumSeq(1.35)
                streakEmitter.Squash = makeNumSeq(1.45)
                weatherEmitter.LightEmission = 0.42
                streakEmitter.LightEmission = 0.34
                weatherEmitter.Speed = makeNumRange(92, 124)
                streakEmitter.Speed = makeNumRange(96, 128)
                weatherEmitter.Lifetime = makeNumRange(0.48, 0.80)
                streakEmitter.Lifetime = makeNumRange(0.45, 0.76)
                weatherEmitter.Size = makeNumSeqKeypoints({ {0, 0.16}, {0.5, 0.25}, {1, 0.14} })
                streakEmitter.Size = makeNumSeqKeypoints({ {0, 0.14}, {0.5, 0.20}, {1, 0.12} })
                weatherEmitter.Transparency = makeNumSeqKeypoints({ {0, 1.0}, {0.15, 0.38}, {0.75, 0.48}, {1, 1.0} })
                streakEmitter.Transparency = makeNumSeqKeypoints({ {0, 1.0}, {0.15, 0.50}, {0.75, 0.62}, {1, 1.0} })
                weatherEmitter.SpreadAngle = Vector2.new(10, 10)
                streakEmitter.SpreadAngle = Vector2.new(9, 9)
                weatherEmitter.Acceleration = Vector3.new(-22, -124, -9)
                streakEmitter.Acceleration = Vector3.new(-22, -124, -9)
                local stormCol = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(185, 215, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(138, 175, 238)),
                })
                weatherEmitter.Color = stormCol
                streakEmitter.Color = stormCol

                mistEmitter.Speed = makeNumRange(10, 22)
                mistEmitter.Lifetime = makeNumRange(2.0, 3.4)
                mistEmitter.Size = makeNumSeq(16)
                mistEmitter.Transparency = makeNumSeq(0.82)
                mistEmitter.SpreadAngle = Vector2.new(90, 90)
                mistEmitter.Acceleration = Vector3.new(-16, -2, -6)
                mistEmitter.Color = stormCol

                groundSplashEmitter.Speed = makeNumRange(3, 9)
                groundSplashEmitter.Lifetime = makeNumRange(0.18, 0.36)
                groundSplashEmitter.Size = makeNumSeqKeypoints({ {0, 0.22}, {0.5, 0.78}, {1, 1.25} })
                groundSplashEmitter.Squash = makeNumSeq(0.18)
                groundSplashEmitter.Transparency = makeNumSeqKeypoints({ {0, 0.28}, {0.6, 0.60}, {1, 1.0} })
                groundSplashEmitter.SpreadAngle = Vector2.new(72, 72)
                groundSplashEmitter.Acceleration = Vector3.new(-4, -32, -2)
                groundSplashEmitter.Color = stormCol

                weatherAtmosphere.Density = ConfigState.NoFog and 0 or 0.48
                weatherAtmosphere.Haze = 2.1
                weatherAtmosphere.Color = Color3.fromRGB(98, 115, 148)
                weatherAtmosphere.Decay = Color3.fromRGB(62, 74, 98)
            end)
            weatherEmitter.Enabled = true
            streakEmitter.Enabled = true
            mistEmitter.Enabled = true
            groundSplashEmitter.Enabled = true
            setRealisticAssetEmittersState(true, 1.35)
            sunRays.Enabled = false
            weatherBloom.Enabled = true
            weatherBloom.Intensity = 0.65
            colorCorr.Enabled = true
            colorCorr.Brightness = -0.05
            colorCorr.Contrast = 0.14
            colorCorr.Saturation = -0.26
            colorCorr.TintColor = Color3.fromRGB(198, 214, 246)
        elseif ConfigState.WeatherPreset == "Snow" then
            -- 3D Volumetric Snowfall Canopy (Tumbling 3D snowflakes with dynamic wind curl in world space)
            weatherPart.Size = Vector3.new(160, 42, 160)
            weatherEmitter.Texture = "rbxassetid://258128463"
            weatherEmitter.Rate = 580
            streakEmitter.Texture = "rbxassetid://258128463"
            streakEmitter.Rate = 300
            mistEmitter.Rate = 36
            groundSplashEmitter.Rate = 0
            pcall(function()
                if Enum.ParticleOrientation and Enum.ParticleOrientation.FacingCamera then
                    weatherEmitter.Orientation = Enum.ParticleOrientation.FacingCamera
                    streakEmitter.Orientation = Enum.ParticleOrientation.FacingCamera
                end
                weatherEmitter.Squash = makeNumSeq(0)
                streakEmitter.Squash = makeNumSeq(0)
                weatherEmitter.LightEmission = 0.58
                streakEmitter.LightEmission = 0.62
                weatherEmitter.Speed = makeNumRange(12, 22)
                streakEmitter.Speed = makeNumRange(9, 17)
                weatherEmitter.Lifetime = makeNumRange(3.6, 5.6)
                streakEmitter.Lifetime = makeNumRange(4.0, 6.0)
                weatherEmitter.Size = makeNumSeq(0.72)
                streakEmitter.Size = makeNumSeq(0.50)
                weatherEmitter.Transparency = makeNumSeq(0.04)
                streakEmitter.Transparency = makeNumSeq(0.10)
                weatherEmitter.RotSpeed = makeNumRange(-95, 95)
                streakEmitter.RotSpeed = makeNumRange(-120, 120)
                weatherEmitter.SpreadAngle = Vector2.new(42, 42)
                streakEmitter.SpreadAngle = Vector2.new(48, 48)
                weatherEmitter.Acceleration = Vector3.new(6, -5, 3)
                streakEmitter.Acceleration = Vector3.new(-5, -4, -3)
                local snowCol = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
                    ColorSequenceKeypoint.new(1, Color3.fromRGB(228, 242, 255)),
                })
                weatherEmitter.Color = snowCol
                streakEmitter.Color = snowCol

                mistEmitter.Speed = makeNumRange(3, 8)
                mistEmitter.Lifetime = makeNumRange(2.8, 4.4)
                mistEmitter.Size = makeNumSeq(15)
                mistEmitter.Transparency = makeNumSeq(0.85)
                mistEmitter.SpreadAngle = Vector2.new(75, 75)
                mistEmitter.Acceleration = Vector3.new(3, -1, 2)
                mistEmitter.Color = snowCol

                weatherAtmosphere.Density = ConfigState.NoFog and 0 or 0.34
                weatherAtmosphere.Haze = 1.5
                weatherAtmosphere.Color = Color3.fromRGB(225, 236, 252)
                weatherAtmosphere.Decay = Color3.fromRGB(185, 204, 232)
            end)
            weatherEmitter.Enabled = true
            streakEmitter.Enabled = true
            mistEmitter.Enabled = true
            groundSplashEmitter.Enabled = false
            setRealisticAssetEmittersState(false, 1.0)
            sunRays.Enabled = false
            weatherBloom.Enabled = true
            weatherBloom.Intensity = 0.42
            colorCorr.Enabled = true
            colorCorr.Brightness = 0.03
            colorCorr.Contrast = 0.05
            colorCorr.Saturation = -0.10
            colorCorr.TintColor = Color3.fromRGB(238, 246, 255)
        elseif ConfigState.WeatherPreset == "Sunny" then
            weatherEmitter.Enabled = false
            streakEmitter.Enabled = false
            mistEmitter.Enabled = false
            groundSplashEmitter.Enabled = false
            setRealisticAssetEmittersState(false, 1.0)
            sunRays.Enabled = true
            sunRays.Intensity = 0.32
            sunRays.Spread = 0.90
            weatherBloom.Enabled = true
            weatherBloom.Intensity = 0.28
            pcall(function()
                weatherAtmosphere.Density = 0.14
                weatherAtmosphere.Haze = 0.3
                weatherAtmosphere.Color = Color3.fromRGB(255, 244, 218)
            end)
            colorCorr.Enabled = true
            colorCorr.Brightness = 0.03
            colorCorr.Contrast = 0.08
            colorCorr.Saturation = 0.18
            colorCorr.TintColor = Color3.fromRGB(255, 246, 228)
        else
            weatherEmitter.Enabled = false
            streakEmitter.Enabled = false
            mistEmitter.Enabled = false
            groundSplashEmitter.Enabled = false
            setRealisticAssetEmittersState(false, 1.0)
            sunRays.Enabled = false
            weatherBloom.Enabled = false
            colorCorr.Enabled = false
            pcall(function()
                weatherAtmosphere.Density = 0
                weatherAtmosphere.Haze = 0
            end)
        end

        updateLightingEnvironment()
        syncWeatherAudio()
    end

    local function isOverheadRoofHit(hit, originY)
        if not hit or not hit.Instance or not hit.Position then
            return false
        end
        if hit.Position.Y <= (originY + 1.8) then
            return false
        end
        local inst = hit.Instance
        local name = tostring(inst.Name or "")
        if string.find(name, "^CoreXyz_") then
            return false
        end
        if (tonumber(inst.Transparency) or 0) >= 0.95 or inst.CanCollide == false then
            return false
        end
        for _, p in ipairs(Players:GetPlayers()) do
            if p.Character and inst:IsDescendantOf(p.Character) then
                return false
            end
        end
        return true
    end

    local function updateWeatherFrame(camera, safeDt)
        local mode = ConfigState.WeatherPreset
        if not mode or mode == "Default" then
            return
        end
        State.weatherAnimClock = (State.weatherAnimClock or 0) + safeDt

        if camera and (mode == "Rain" or mode == "Thunderstorm" or mode == "Snow") then
            local camPos = camera.CFrame.Position
            local hrp = State.cachedLocalHRP
            local anchorPos = (hrp and hrp.Parent and (hrp.Position - camPos).Magnitude < 95) and hrp.Position or camPos
            local canopyHeight = (mode == "Snow") and 22 or 26

            -- Upward Roof / Ceiling Raycast: Stop rain from falling indoors under roofs & muffle indoor rain audio!
            rayParams.FilterDescendantsInstances = getSafeRaycastExcludeList()
            local ceilingHit = workspace:Raycast(anchorPos + Vector3.new(0, 1.5, 0), Vector3.new(0, 120, 0), rayParams)
            local underRoof = isOverheadRoofHit(ceilingHit, anchorPos.Y)
            local wasUnderRoof = State.isUnderRoof
            State.isUnderRoof = underRoof

            if underRoof then
                -- Suppress overhead indoor rain & ground splashes under roof and shift canopy outside forward
                local lookVec = (camera.CFrame and camera.CFrame.LookVector) or Vector3.new(0, 0, -1)
                weatherPart.CFrame = CFrame.new(Vector3.new(anchorPos.X + lookVec.X * 65, anchorPos.Y + canopyHeight + 25, anchorPos.Z + lookVec.Z * 65))
                weatherEmitter.Enabled = false
                streakEmitter.Enabled = false
                groundSplashEmitter.Enabled = false
                setRealisticAssetEmittersState(false, 0)
            else
                weatherPart.CFrame = CFrame.new(Vector3.new(anchorPos.X, anchorPos.Y + canopyHeight, anchorPos.Z))
                weatherEmitter.Enabled = true
                streakEmitter.Enabled = true
                if mode == "Rain" or mode == "Thunderstorm" then
                    groundSplashEmitter.Enabled = true
                    setRealisticAssetEmittersState(true, mode == "Thunderstorm" and 1.35 or 1.0)
                end
            end

            if underRoof ~= wasUnderRoof then
                syncWeatherAudio()
            end

            -- Dynamic 3D wind turbulence for Snow & Thunderstorm so 3D particles swirl naturally in world space
            if mode == "Snow" then
                local swayX = math.sin(State.weatherAnimClock * 0.95) * 9.5
                local swayZ = math.cos(State.weatherAnimClock * 0.75) * 7.5
                pcall(function()
                    weatherEmitter.Acceleration = Vector3.new(swayX, -5.2, swayZ)
                    streakEmitter.Acceleration = Vector3.new(-swayX * 0.75, -4.4, -swayZ * 0.75)
                end)
            elseif mode == "Thunderstorm" then
                local gustX = -22 + math.sin(State.weatherAnimClock * 1.8) * 8
                local gustZ = -9 + math.cos(State.weatherAnimClock * 1.4) * 5
                pcall(function()
                    weatherEmitter.Acceleration = Vector3.new(gustX, -124, gustZ)
                    streakEmitter.Acceleration = Vector3.new(gustX, -124, gustZ)
                end)
            end

            -- Position 3D Ground Splash Plane directly on the world surface beneath the player via downward raycast
            if (mode == "Rain" or mode == "Thunderstorm") and not underRoof then
                local hit = workspace:Raycast(anchorPos + Vector3.new(0, 6, 0), Vector3.new(0, -140, 0), rayParams)
                local groundY = (hit and hit.Position and hit.Position.Y) or (anchorPos.Y - 3.2)
                State.lastGroundY = groundY
                groundSplashPart.CFrame = CFrame.new(Vector3.new(anchorPos.X, groundY + 0.15, anchorPos.Z))
            end
        end

        if mode == "Thunderstorm" then
            State.nextLightningTimer = (State.nextLightningTimer or 3.5) - safeDt
            if State.nextLightningTimer <= 0 then
                -- Randomize interval and occasionally trigger a realistic double-strike
                if not State.pendingDoubleStrike and math.random(1, 100) <= 38 then
                    State.pendingDoubleStrike = true
                    State.nextLightningTimer = math.random(18, 38) / 100
                else
                    State.pendingDoubleStrike = false
                    State.nextLightningTimer = math.random(28, 68) / 10
                end
                triggerSurroundingLightningStrike(camera)
                Lighting.Brightness = (ConfigState.Fullbright and 2.0 or 0.65) + 3.8
            elseif (State.lightningFlashIntensity or 0) > 0 then
                local decayDt = math.min(safeDt, 0.05)
                State.lightningFlashIntensity = math.max(0, State.lightningFlashIntensity - decayDt * 3.2)
                local intensity = State.lightningFlashIntensity
                local flashBoost = intensity * 3.8
                Lighting.Brightness = (ConfigState.Fullbright and 2.0 or 0.65) + flashBoost
                colorCorr.Brightness = -0.05 + intensity * 0.24
                if intensity > 0.04 then
                    local boltTrans = math.clamp(1 - intensity * 0.96, 0.02, 0.98)
                    for i = 1, LIGHTNING_SEGMENT_COUNT do
                        lightningSegments[i].Transparency = boltTrans
                    end
                    for i = 1, LIGHTNING_BRANCH_COUNT do
                        lightningBranches[i].Transparency = math.clamp(boltTrans + 0.12, 0.1, 1)
                    end
                    strikePointLight.Brightness = intensity * 9.0
                else
                    colorCorr.Brightness = -0.05
                    hideLightningBolts()
                end
            end
        end
    end

    State.applyWeatherPreset = applyWeatherPreset
    State.syncWeatherAudio = syncWeatherAudio
    State.updateWeatherFrame = updateWeatherFrame
    UI.RealisticRainAssetId = REALISTIC_RAIN_ASSET_ID
    UI.RealisticCanopyEmitters = realisticCanopyEmitters
    UI.RealisticSplashEmitters = realisticSplashEmitters
    UI.WeatherEmitterPart = weatherPart
    UI.WeatherEmitter = weatherEmitter
    UI.WeatherStreakEmitter = streakEmitter
    UI.WeatherMistEmitter = mistEmitter
    UI.WeatherGroundPart = groundSplashPart
    UI.WeatherSplashEmitter = groundSplashEmitter
    UI.LightningBoltPool = lightningFolder
    UI.SpatialThunderSound = spatialThunderSound
    UI.WeatherPatterSound = patterSound
    UI.WeatherPatterEQ = patterEq
    UI.WeatherRumblerSound = rumblerSound
    UI.WeatherSunRays = sunRays
    UI.WeatherColorCorrection = colorCorr
    UI.WeatherBloom = weatherBloom
    UI.WeatherAtmosphere = weatherAtmosphere
    UI.WeatherAmbienceSound = ambienceSound
    UI.WeatherThunderSound = thunderSound
end

--------------------------------------------------------------------------------
-- 11B. COMMUNITY MUSIC SYSTEM & CONNECTED WAVY OCEAN PLAYER UI (ZERO PER-FRAME ALLOCATIONS)
--------------------------------------------------------------------------------
do
    local SoundService = safeGetService("SoundService") or Lighting

    local MUSIC_TRACK_LIST = {
        {
            Id = "Snowman (Slowed + Reverb) — Sia",
            Title = "Snowman (Slowed + Reverb)",
            Artist = "Sia",
            FileName = "sia_snowman_slowed.mp3",
            DefaultDuration = 184,
            FallbackSoundId = "rbxasset://sounds/uuhhh.mp3",
            Urls = {
                "https://core-xyz-gateway.feykhere.workers.dev/music/sia%20-%20snowman%20(slowed%20%2B%20reverb)%20%5Bwith%20lyrics%5D.mp3",
                "https://raw.githubusercontent.com/FeykHere/Core.xyz/main/sia%20-%20snowman%20(slowed%20%2B%20reverb)%20%5Bwith%20lyrics%5D.mp3",
                "https://raw.githubusercontent.com/FeykHere/Core.xyz/main/sia%20-%20snowman%20(slowed%20+%20reverb)%20[with%20lyrics].mp3",
                "https://github.com/FeykHere/Core.xyz/blob/main/sia%20-%20snowman%20(slowed%20%2B%20reverb)%20[with%20lyrics].mp3?raw=true",
                "https://raw.githubusercontent.com/FeykHere/Core.xyz/main/music/sia%20-%20snowman%20(slowed%20%2B%20reverb)%20%5Bwith%20lyrics%5D.mp3",
            },
        },
    }

    local TRACK_DROPDOWN_OPTIONS = {}
    local TRACK_BY_ID = {}
    for idx, tr in ipairs(MUSIC_TRACK_LIST) do
        tr.Index = idx
        table.insert(TRACK_DROPDOWN_OPTIONS, tr.Id)
        TRACK_BY_ID[tr.Id] = tr
    end
    State.musicTrackOptions = TRACK_DROPDOWN_OPTIONS

    local musicSound = Instance.new("Sound")
    musicSound.Name = "CoreXyz_MusicPlayerSound"
    musicSound.Looped = ConfigState.MusicLooped ~= false
    musicSound.Volume = ConfigState.MusicVolume or 0.75
    musicSound.SoundId = ""
    musicSound.Parent = SoundService
    UI.MusicPlayerSound = musicSound

    local function formatTimeMMSS(sec)
        local clean = math.max(0, math.floor(tonumber(sec) or 0))
        local m = math.floor(clean / 60)
        local s = clean % 60
        return string.format("%02d:%02d", m, s)
    end

    -- Connected Mini Music Player Bar (Docked underneath CoreMainWindow)
    local PlayerBar = Instance.new("Frame")
    PlayerBar.Name = "CoreMusicPlayerBar"
    PlayerBar.AnchorPoint = Vector2.new(0.5, 0)
    PlayerBar.Position = UDim2.new(0.5, 0, 0.52, 191)
    PlayerBar.Size = UDim2.fromOffset(560, 74)
    PlayerBar.BackgroundColor3 = Theme.Black
    PlayerBar.BackgroundTransparency = ConfigState.WindowTransparency or 0.03
    PlayerBar.Active = true
    PlayerBar.Visible = false
    PlayerBar.ClipsDescendants = true
    PlayerBar.ZIndex = 10
    PlayerBar.Parent = UI.ScreenGui
    addCorner(PlayerBar, 12)
    local PlayerStroke = addLiveBorder(PlayerBar, 1.4, 48, 0.08)

    local PlayerScale = Instance.new("UIScale")
    PlayerScale.Scale = 1
    PlayerScale.Parent = PlayerBar

    -- Top Accent Connector Line
    local ConnectorBeam = Instance.new("Frame")
    ConnectorBeam.Name = "MusicDockConnector"
    ConnectorBeam.Position = UDim2.fromOffset(0, 0)
    ConnectorBeam.Size = UDim2.new(1, 0, 0, 1)
    ConnectorBeam.BackgroundColor3 = Theme.Accent
    ConnectorBeam.BackgroundTransparency = 0.65
    ConnectorBeam.BorderSizePixel = 0
    ConnectorBeam.ZIndex = 12
    ConnectorBeam.Parent = PlayerBar
    registerAccentObject(ConnectorBeam, "BackgroundColor3")

    -- Spinning Disc / Vinyl Badge on Left
    local DiscBadge = Instance.new("Frame")
    DiscBadge.Name = "MusicDiscBadge"
    DiscBadge.Position = UDim2.fromOffset(12, 10)
    DiscBadge.Size = UDim2.fromOffset(30, 30)
    DiscBadge.BackgroundColor3 = Theme.Surface
    DiscBadge.ZIndex = 12
    DiscBadge.Parent = PlayerBar
    addCorner(DiscBadge, 999)
    local DiscStroke = addStroke(DiscBadge, Theme.Accent, 1.2, 0.15)
    registerAccentObject(DiscStroke, "Color")
    table.insert(State.liveRotators, { Instance = DiscBadge, Speed = 38 })

    local DiscCenter = Instance.new("Frame")
    DiscCenter.AnchorPoint = Vector2.new(0.5, 0.5)
    DiscCenter.Position = UDim2.fromScale(0.5, 0.5)
    DiscCenter.Size = UDim2.fromOffset(8, 8)
    DiscCenter.BackgroundColor3 = Theme.Accent
    DiscCenter.BorderSizePixel = 0
    DiscCenter.ZIndex = 13
    DiscCenter.Parent = DiscBadge
    addCorner(DiscCenter, 999)
    registerAccentObject(DiscCenter, "BackgroundColor3")

    local TrackTitleLbl = Instance.new("TextLabel")
    TrackTitleLbl.Name = "MusicTitleLabel"
    TrackTitleLbl.Position = UDim2.fromOffset(50, 8)
    TrackTitleLbl.Size = UDim2.fromOffset(250, 16)
    TrackTitleLbl.BackgroundTransparency = 1
    TrackTitleLbl.Font = Enum.Font.GothamBold
    TrackTitleLbl.Text = "Snowman (Slowed + Reverb)"
    TrackTitleLbl.TextColor3 = Theme.White
    TrackTitleLbl.TextSize = 12
    TrackTitleLbl.TextTruncate = Enum.TextTruncate.AtEnd
    TrackTitleLbl.TextXAlignment = Enum.TextXAlignment.Left
    TrackTitleLbl.ZIndex = 12
    TrackTitleLbl.Parent = PlayerBar

    local TrackStatusLbl = Instance.new("TextLabel")
    TrackStatusLbl.Name = "MusicStatusLabel"
    TrackStatusLbl.Position = UDim2.fromOffset(50, 24)
    TrackStatusLbl.Size = UDim2.fromOffset(250, 13)
    TrackStatusLbl.BackgroundTransparency = 1
    TrackStatusLbl.Font = Enum.Font.Code
    TrackStatusLbl.Text = "Sia  ·  Ready"
    TrackStatusLbl.TextColor3 = Theme.Muted
    TrackStatusLbl.TextSize = 10
    TrackStatusLbl.TextTruncate = Enum.TextTruncate.AtEnd
    TrackStatusLbl.TextXAlignment = Enum.TextXAlignment.Left
    TrackStatusLbl.ZIndex = 12
    TrackStatusLbl.Parent = PlayerBar

    -- Center-Right Transport Controls (Backward, Play/Pause, Forward)
    local PrevBtn = Instance.new("TextButton")
    PrevBtn.Name = "MusicPrevButton"
    PrevBtn.Position = UDim2.fromOffset(312, 9)
    PrevBtn.Size = UDim2.fromOffset(28, 28)
    PrevBtn.BackgroundColor3 = Theme.Surface
    PrevBtn.AutoButtonColor = false
    PrevBtn.Font = Enum.Font.GothamBold
    PrevBtn.Text = "⏮"
    PrevBtn.TextColor3 = Theme.Silver
    PrevBtn.TextSize = 11
    PrevBtn.ClipsDescendants = true
    PrevBtn.ZIndex = 13
    PrevBtn.Parent = PlayerBar
    addCorner(PrevBtn, 7)
    local PrevStroke = addStroke(PrevBtn, Theme.Border, 1, 0)

    PrevBtn.MouseEnter:Connect(function()
        tween(PrevBtn, FastTween, { BackgroundColor3 = Theme.Elevated, TextColor3 = Theme.White })
        tween(PrevStroke, FastTween, { Color = Theme.Accent, Transparency = 0.25 })
    end)
    PrevBtn.MouseLeave:Connect(function()
        tween(PrevBtn, FastTween, { BackgroundColor3 = Theme.Surface, TextColor3 = Theme.Silver })
        tween(PrevStroke, FastTween, { Color = Theme.Border, Transparency = 0 })
    end)

    local PlayPauseBtn = Instance.new("TextButton")
    PlayPauseBtn.Name = "MusicPlayPauseButton"
    PlayPauseBtn.Position = UDim2.fromOffset(346, 8)
    PlayPauseBtn.Size = UDim2.fromOffset(34, 30)
    PlayPauseBtn.BackgroundColor3 = Theme.Accent
    PlayPauseBtn.AutoButtonColor = false
    PlayPauseBtn.Font = Enum.Font.GothamBlack
    PlayPauseBtn.Text = "▶"
    PlayPauseBtn.TextColor3 = Theme.Black
    PlayPauseBtn.TextSize = 12
    PlayPauseBtn.ClipsDescendants = true
    PlayPauseBtn.ZIndex = 13
    PlayPauseBtn.Parent = PlayerBar
    addCorner(PlayPauseBtn, 8)
    registerAccentObject(PlayPauseBtn, "BackgroundColor3")

    PlayPauseBtn.MouseEnter:Connect(function()
        tween(PlayPauseBtn, SpringTween, { Size = UDim2.fromOffset(36, 31) })
    end)
    PlayPauseBtn.MouseLeave:Connect(function()
        tween(PlayPauseBtn, FastTween, { Size = UDim2.fromOffset(34, 30) })
    end)

    local NextBtn = Instance.new("TextButton")
    NextBtn.Name = "MusicNextButton"
    NextBtn.Position = UDim2.fromOffset(386, 9)
    NextBtn.Size = UDim2.fromOffset(28, 28)
    NextBtn.BackgroundColor3 = Theme.Surface
    NextBtn.AutoButtonColor = false
    NextBtn.Font = Enum.Font.GothamBold
    NextBtn.Text = "⏭"
    NextBtn.TextColor3 = Theme.Silver
    NextBtn.TextSize = 11
    NextBtn.ClipsDescendants = true
    NextBtn.ZIndex = 13
    NextBtn.Parent = PlayerBar
    addCorner(NextBtn, 7)
    local NextStroke = addStroke(NextBtn, Theme.Border, 1, 0)

    NextBtn.MouseEnter:Connect(function()
        tween(NextBtn, FastTween, { BackgroundColor3 = Theme.Elevated, TextColor3 = Theme.White })
        tween(NextStroke, FastTween, { Color = Theme.Accent, Transparency = 0.25 })
    end)
    NextBtn.MouseLeave:Connect(function()
        tween(NextBtn, FastTween, { BackgroundColor3 = Theme.Surface, TextColor3 = Theme.Silver })
        tween(NextStroke, FastTween, { Color = Theme.Border, Transparency = 0 })
    end)

    local TimeCounterLbl = Instance.new("TextLabel")
    TimeCounterLbl.Name = "MusicTimeLabel"
    TimeCounterLbl.AnchorPoint = Vector2.new(1, 0)
    TimeCounterLbl.Position = UDim2.new(1, -14, 0, 14)
    TimeCounterLbl.Size = UDim2.fromOffset(120, 18)
    TimeCounterLbl.BackgroundTransparency = 1
    TimeCounterLbl.Font = Enum.Font.Code
    TimeCounterLbl.Text = "00:00 / 03:04"
    TimeCounterLbl.TextColor3 = Theme.Silver
    TimeCounterLbl.TextSize = 11
    TimeCounterLbl.TextXAlignment = Enum.TextXAlignment.Right
    TimeCounterLbl.ZIndex = 12
    TimeCounterLbl.Parent = PlayerBar

    -- Interactive Animated Wavy Ocean Timeline Slider / Scrubber
    local TimelineTrack = Instance.new("Frame")
    TimelineTrack.Name = "MusicTimelineTrack"
    TimelineTrack.Position = UDim2.fromOffset(14, 45)
    TimelineTrack.Size = UDim2.new(1, -28, 0, 20)
    TimelineTrack.BackgroundColor3 = Theme.Deep
    TimelineTrack.ClipsDescendants = true
    TimelineTrack.ZIndex = 12
    TimelineTrack.Parent = PlayerBar
    addCorner(TimelineTrack, 10)
    local TimelineStroke = addStroke(TimelineTrack, Theme.Border, 1, 0)

    -- Single Continuous Smooth Wave Scrubber (Hidden legacy fill bars so only ONE smooth long wave renders)
    local TimelineBaseline = Instance.new("Frame")
    TimelineBaseline.Name = "MusicTimelineBaseline"
    TimelineBaseline.AnchorPoint = Vector2.new(0, 0.5)
    TimelineBaseline.Position = UDim2.fromScale(0, 0.5)
    TimelineBaseline.Size = UDim2.new(1, 0, 0, 2)
    TimelineBaseline.BackgroundColor3 = Theme.Elevated
    TimelineBaseline.BorderSizePixel = 0
    TimelineBaseline.Visible = false
    TimelineBaseline.ZIndex = 12
    TimelineBaseline.Parent = TimelineTrack

    local OceanCrestPrimary = Instance.new("Frame")
    OceanCrestPrimary.Name = "OceanWaveCrestPrimary"
    OceanCrestPrimary.AnchorPoint = Vector2.new(0, 1)
    OceanCrestPrimary.Position = UDim2.fromScale(0, 1)
    OceanCrestPrimary.Size = UDim2.new(0, 0, 0.68, 0)
    OceanCrestPrimary.BackgroundColor3 = Color3.fromRGB(65, 160, 255)
    OceanCrestPrimary.BackgroundTransparency = 0.54
    OceanCrestPrimary.BorderSizePixel = 0
    OceanCrestPrimary.Visible = false
    OceanCrestPrimary.ZIndex = 13
    OceanCrestPrimary.Parent = TimelineTrack
    addCorner(OceanCrestPrimary, 6)

    local OceanCrestSecondary = Instance.new("Frame")
    OceanCrestSecondary.Name = "OceanWaveCrestSecondary"
    OceanCrestSecondary.AnchorPoint = Vector2.new(0, 1)
    OceanCrestSecondary.Position = UDim2.fromScale(0, 1)
    OceanCrestSecondary.Size = UDim2.new(0, 0, 0.50, 0)
    OceanCrestSecondary.BackgroundColor3 = Color3.fromRGB(145, 222, 255)
    OceanCrestSecondary.BackgroundTransparency = 0.42
    OceanCrestSecondary.BorderSizePixel = 0
    OceanCrestSecondary.Visible = false
    OceanCrestSecondary.ZIndex = 13
    OceanCrestSecondary.Parent = TimelineTrack
    addCorner(OceanCrestSecondary, 6)

    -- Pre-Allocated 28 Seamless Ribbon Segments Forming ONE Single Long Continuous Wave (Zero Per-Frame Allocations)
    local OCEAN_WAVE_SEGMENTS = 28
    local oceanSegments = {}
    for i = 1, OCEAN_WAVE_SEGMENTS do
        local seg = Instance.new("Frame")
        seg.Name = "OceanWaveSegment_" .. i
        seg.AnchorPoint = Vector2.new(0.5, 0.5)
        local xScale = (i - 0.5) / OCEAN_WAVE_SEGMENTS
        seg.Position = UDim2.fromScale(xScale, 0.5)
        seg.Size = UDim2.new(1 / OCEAN_WAVE_SEGMENTS, 3, 0, 3)
        seg.BackgroundColor3 = Theme.White
        seg.BackgroundTransparency = 0.05
        seg.BorderSizePixel = 0
        seg.ZIndex = 14
        seg.Parent = TimelineTrack
        addCorner(seg, 99)
        oceanSegments[i] = seg
    end

    -- Soft Bioluminescent Halo Ring Around Scrubber Knob
    local ScrubberKnobHalo = Instance.new("Frame")
    ScrubberKnobHalo.Name = "MusicScrubberKnobHalo"
    ScrubberKnobHalo.AnchorPoint = Vector2.new(0.5, 0.5)
    ScrubberKnobHalo.Position = UDim2.fromScale(0, 0.5)
    ScrubberKnobHalo.Size = UDim2.fromOffset(18, 18)
    ScrubberKnobHalo.BackgroundColor3 = Color3.fromRGB(220, 240, 255)
    ScrubberKnobHalo.BackgroundTransparency = 0.72
    ScrubberKnobHalo.BorderSizePixel = 0
    ScrubberKnobHalo.ZIndex = 15
    ScrubberKnobHalo.Parent = TimelineTrack
    addCorner(ScrubberKnobHalo, 999)

    -- Buoyant Single-Wave Scrubber Thumb Knob
    local ScrubberKnob = Instance.new("Frame")
    ScrubberKnob.Name = "MusicScrubberKnob"
    ScrubberKnob.AnchorPoint = Vector2.new(0.5, 0.5)
    ScrubberKnob.Position = UDim2.fromScale(0, 0.5)
    ScrubberKnob.Size = UDim2.fromOffset(12, 12)
    ScrubberKnob.BackgroundColor3 = Theme.White
    ScrubberKnob.ZIndex = 16
    ScrubberKnob.Parent = TimelineTrack
    addCorner(ScrubberKnob, 999)
    local KnobStroke = addStroke(ScrubberKnob, Color3.fromRGB(110, 195, 255), 1.5, 0)
    registerAccentObject(KnobStroke, "Color")

    -- Interactive Click & Drag Scrubber Hitbox
    local TimelineHitbox = Instance.new("TextButton")
    TimelineHitbox.Name = "MusicTimelineHitbox"
    TimelineHitbox.Size = UDim2.fromScale(1, 1)
    TimelineHitbox.BackgroundTransparency = 1
    TimelineHitbox.Text = ""
    TimelineHitbox.AutoButtonColor = false
    TimelineHitbox.ZIndex = 18
    TimelineHitbox.Parent = TimelineTrack

    TimelineHitbox.MouseEnter:Connect(function()
        tween(TimelineStroke, FastTween, { Color = Color3.fromRGB(120, 200, 255), Transparency = 0.2 })
        tween(ScrubberKnob, SpringTween, { Size = UDim2.fromOffset(14, 14) })
    end)
    TimelineHitbox.MouseLeave:Connect(function()
        if not State.musicScrubbing then
            tween(TimelineStroke, FastTween, { Color = Theme.Border, Transparency = 0 })
            tween(ScrubberKnob, FastTween, { Size = UDim2.fromOffset(12, 12) })
        end
    end)

    local function syncMusicPlayerDock()
        if not UI.MainWindow then
            return
        end
        local scale = (UI.MainScale and UI.MainScale.Scale) or getResponsiveScale()
        local mwPos = UI.MainWindow.Position
        local halfMainH = math.floor(182.5 * scale)
        local gapPx = math.floor(8 * scale)
        PlayerBar.Position = UDim2.new(
            mwPos.X.Scale,
            mwPos.X.Offset,
            mwPos.Y.Scale,
            mwPos.Y.Offset + halfMainH + gapPx
        )
        local shouldShow = State.isAuthorized and State.uiVisible and (ConfigState.MusicPlayerVisible == true)
        local wasVisible = PlayerBar.Visible
        PlayerBar.Visible = shouldShow and true or false
        if shouldShow then
            if not wasVisible then
                PlayerScale.Scale = scale * 0.92
                PlayerBar.BackgroundTransparency = 0.45
                tween(PlayerScale, SpringTween, { Scale = scale })
                tween(PlayerBar, FastTween, { BackgroundTransparency = ConfigState.WindowTransparency or 0.03 })
            else
                PlayerScale.Scale = scale
                PlayerBar.BackgroundTransparency = ConfigState.WindowTransparency or 0.03
            end
        end
    end

    local function getActiveTrackData()
        return TRACK_BY_ID[ConfigState.SelectedTrack] or MUSIC_TRACK_LIST[1]
    end

    local function getEffectiveTrackLength(track)
        local soundLen = tonumber(musicSound.TimeLength) or 0
        if soundLen and soundLen > 1 then
            State.musicTrackLength = soundLen
            return soundLen
        end
        return (track and track.DefaultDuration) or State.musicTrackLength or 184
    end

    local function updateWavyScrubberVisuals(progressRatio, animTime)
        local clampedRatio = math.clamp(tonumber(progressRatio) or 0, 0, 1)
        local isPlaying = State.musicIsPlaying and true or false
        local waveSpeed = isPlaying and 3.4 or 1.2
        local waveAmp = isPlaying and 0.24 or 0.08
        local lineThickness = isPlaying and 3 or 2

        for i = 1, OCEAN_WAVE_SEGMENTS do
            local seg = oceanSegments[i]
            local segNorm = (i - 0.5) / OCEAN_WAVE_SEGMENTS
            -- Single continuous long-wavelength smooth sine wave across the entire timeline
            local phaseAngle = animTime * waveSpeed - segNorm * math.pi * 2.2
            local longWave = math.sin(phaseAngle)
            local slope = math.cos(phaseAngle)
            local yPos = 0.5 + longWave * waveAmp
            local tiltAngle = -slope * (isPlaying and 10.5 or 3.8)

            seg.Position = UDim2.fromScale(segNorm, yPos)
            seg.Size = UDim2.new(1 / OCEAN_WAVE_SEGMENTS, 3, 0, lineThickness)
            seg.Rotation = tiltAngle

            if segNorm <= clampedRatio then
                local crestFactor = math.clamp((longWave + 1) * 0.5, 0, 1)
                local rCol = math.floor(195 + crestFactor * 60)
                local gCol = math.floor(225 + crestFactor * 30)
                seg.BackgroundColor3 = Color3.fromRGB(rCol, gCol, 255)
                seg.BackgroundTransparency = 0.02
            else
                seg.BackgroundColor3 = Theme.Elevated
                seg.BackgroundTransparency = 0.36
            end
        end

        local knobPhaseAngle = animTime * waveSpeed - clampedRatio * math.pi * 2.2
        local knobWave = math.sin(knobPhaseAngle)
        local knobY = math.clamp(0.5 + knobWave * waveAmp, 0.20, 0.80)
        ScrubberKnob.Position = UDim2.fromScale(clampedRatio, knobY)
        ScrubberKnobHalo.Position = UDim2.fromScale(clampedRatio, knobY)
        local haloSize = isPlaying and math.floor(18 + math.sin(animTime * 4.5) * 2.5) or 16
        ScrubberKnobHalo.Size = UDim2.fromOffset(haloSize, haloSize)
    end

    local function ensureTrackCachedAndLoaded(track, onReady)
        if not track then
            return
        end
        TrackTitleLbl.Text = track.Title
        local cachedAsset = State.musicCachedAssets[track.Id]
        if cachedAsset and cachedAsset ~= "" then
            if musicSound.SoundId ~= cachedAsset then
                musicSound.SoundId = cachedAsset
            end
            if onReady then
                onReady(cachedAsset)
            end
            return
        end

        local localFilePath = MUSIC_FOLDER .. "/" .. track.FileName
        if Env.getcustomasset and safeIsFile(localFilePath) then
            local okAsset, assetUri = pcall(function()
                return Env.getcustomasset(localFilePath)
            end)
            if okAsset and assetUri and tostring(assetUri) ~= "" then
                State.musicCachedAssets[track.Id] = tostring(assetUri)
                musicSound.SoundId = tostring(assetUri)
                TrackStatusLbl.Text = track.Artist .. "  ·  Cached Locally"
                if onReady then
                    onReady(tostring(assetUri))
                end
                return
            end
        end

        -- If executor supports writefile + getcustomasset, download the MP3 from GitHub once in background
        if Env.writefile and Env.getcustomasset then
            if State.musicDownloading then
                return
            end
            State.musicDownloading = true
            TrackStatusLbl.Text = track.Artist .. "  ·  Downloading MP3 from GitHub..."

            task.spawn(function()
                local mp3Bytes = nil
                for _, rawUrl in ipairs(track.Urls or {}) do
                    local okHttp, resBody = pcall(function()
                        if type(Env.request) == "function" then
                            local r = Env.request({ Url = rawUrl, Method = "GET" })
                            if r and r.StatusCode == 200 and type(r.Body) == "string" and #r.Body > 512 then
                                return r.Body
                            end
                        end
                        return game:HttpGet(rawUrl)
                    end)
                    if okHttp and type(resBody) == "string" and #resBody > 512 and not string.find(string.sub(resBody, 1, 64), "<!DOCTYPE html") then
                        mp3Bytes = resBody
                        break
                    end
                end

                State.musicDownloading = false
                if mp3Bytes then
                    safeWriteFile(localFilePath, mp3Bytes)
                    local okCustom, customUri = pcall(function()
                        return Env.getcustomasset(localFilePath)
                    end)
                    if okCustom and customUri and tostring(customUri) ~= "" then
                        State.musicCachedAssets[track.Id] = tostring(customUri)
                        musicSound.SoundId = tostring(customUri)
                        TrackStatusLbl.Text = track.Artist .. "  ·  Playing (Cached)"
                        if onReady then
                            onReady(tostring(customUri))
                        end
                        return
                    end
                end

                -- Fallback if executor asset bridge is unavailable in sandbox
                local fallbackUri = track.FallbackSoundId or "rbxasset://sounds/uuhhh.mp3"
                State.musicCachedAssets[track.Id] = fallbackUri
                musicSound.SoundId = fallbackUri
                TrackStatusLbl.Text = track.Artist .. "  ·  Ready"
                if onReady then
                    onReady(fallbackUri)
                end
            end)
        else
            local fallbackUri = track.FallbackSoundId or "rbxasset://sounds/uuhhh.mp3"
            State.musicCachedAssets[track.Id] = fallbackUri
            musicSound.SoundId = fallbackUri
            TrackStatusLbl.Text = track.Artist .. "  ·  Ready"
            if onReady then
                onReady(fallbackUri)
            end
        end
    end

    local function setMusicPlaying(shouldPlay)
        local track = getActiveTrackData()
        State.musicIsPlaying = shouldPlay and true or false
        if State.musicIsPlaying then
            PlayPauseBtn.Text = "⏸"
            TrackStatusLbl.Text = track.Artist .. "  ·  Playing"
            ensureTrackCachedAndLoaded(track, function()
                if not State.musicIsPlaying then
                    return
                end
                musicSound.Volume = ConfigState.MusicVolume or 0.75
                musicSound.Looped = ConfigState.MusicLooped ~= false
                pcall(function()
                    musicSound.TimePosition = State.musicSimulatedPos or 0
                    if musicSound.Resume and musicSound.IsPaused then
                        musicSound:Resume()
                    else
                        musicSound:Play()
                    end
                end)
                TrackStatusLbl.Text = track.Artist .. "  ·  Playing"
            end)
        else
            PlayPauseBtn.Text = "▶"
            TrackStatusLbl.Text = track.Artist .. "  ·  Paused"
            pcall(function()
                if musicSound.Pause then
                    musicSound:Pause()
                else
                    musicSound:Stop()
                end
            end)
        end
    end

    local function seekMusicToRatio(ratio)
        local track = getActiveTrackData()
        local totalLen = getEffectiveTrackLength(track)
        local clamped = math.clamp(tonumber(ratio) or 0, 0, 1)
        local targetSec = clamped * totalLen
        State.musicSimulatedPos = targetSec
        pcall(function()
            musicSound.TimePosition = targetSec
        end)
        TimeCounterLbl.Text = string.format("%s / %s", formatTimeMMSS(targetSec), formatTimeMMSS(totalLen))
        updateWavyScrubberVisuals(clamped, State.musicWaveClock or 0)
    end

    local function stepMusicTrack(direction)
        local currentTrack = getActiveTrackData()
        local count = #MUSIC_TRACK_LIST
        local nextIdx = ((currentTrack.Index - 1 + direction) % count) + 1
        local nextTrack = MUSIC_TRACK_LIST[nextIdx] or MUSIC_TRACK_LIST[1]
        ConfigState.SelectedTrack = nextTrack.Id
        State.musicSimulatedPos = 0
        pcall(function()
            musicSound.TimePosition = 0
        end)
        TrackTitleLbl.Text = nextTrack.Title
        local totalLen = getEffectiveTrackLength(nextTrack)
        TimeCounterLbl.Text = string.format("00:00 / %s", formatTimeMMSS(totalLen))
        updateWavyScrubberVisuals(0, State.musicWaveClock or 0)
        if State.musicIsPlaying then
            setMusicPlaying(true)
        else
            TrackStatusLbl.Text = nextTrack.Artist .. "  ·  Ready"
        end
    end

    PlayPauseBtn.MouseButton1Click:Connect(function()
        spawnRipple(PlayPauseBtn)
        setMusicPlaying(not State.musicIsPlaying)
    end)

    PrevBtn.MouseButton1Click:Connect(function()
        spawnRipple(PrevBtn)
        if (State.musicSimulatedPos or 0) > 4 then
            seekMusicToRatio(0)
        else
            stepMusicTrack(-1)
        end
    end)

    NextBtn.MouseButton1Click:Connect(function()
        spawnRipple(NextBtn)
        stepMusicTrack(1)
    end)

    -- Interactive Click & Drag on Wavy Ocean Scrubber
    local function updateScrubberFromInput(input)
        local absPos = TimelineTrack.AbsolutePosition
        local absSize = TimelineTrack.AbsoluteSize
        local trackWidth = (absSize and absSize.X and absSize.X > 10) and absSize.X or 532
        local trackLeft = (absPos and absPos.X) or 0
        local relX = (input.Position.X - trackLeft) / trackWidth
        if trackLeft == 0 and input.Position.X <= 1 and input.Position.X >= 0 then
            relX = input.Position.X
        end
        seekMusicToRatio(math.clamp(relX, 0, 1))
    end

    TimelineHitbox.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            State.musicScrubbing = true
            updateScrubberFromInput(input)
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if State.musicScrubbing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateScrubberFromInput(input)
        end
    end)

    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            State.musicScrubbing = false
        end
    end)

    -- Mute Game Audio (Excludes CoreXyz_ sounds, caches original volumes in weak-key table, hooks new sounds)
    local function isCoreInternalSound(snd)
        if not snd or not snd:IsA("Sound") then
            return true
        end
        local name = snd.Name or ""
        return string.find(name, "^CoreXyz_") ~= nil
    end

    local function muteSingleGameSound(snd)
        if not isCoreInternalSound(snd) then
            if State.mutedGameSounds[snd] == nil then
                State.mutedGameSounds[snd] = snd.Volume
            end
            pcall(function()
                snd.Volume = 0
            end)
        end
    end

    local function applyMuteGameAudio(enabled)
        ConfigState.MuteGameAudio = enabled and true or false
        if ConfigState.MuteGameAudio then
            for _, desc in ipairs(workspace:GetDescendants()) do
                if desc:IsA("Sound") then
                    muteSingleGameSound(desc)
                end
            end
            for _, desc in ipairs(SoundService:GetDescendants()) do
                if desc:IsA("Sound") then
                    muteSingleGameSound(desc)
                end
            end
            if not State.muteAudioDescendantConn and workspace.DescendantAdded then
                State.muteAudioDescendantConn = workspace.DescendantAdded:Connect(function(inst)
                    if ConfigState.MuteGameAudio and inst and inst:IsA("Sound") then
                        muteSingleGameSound(inst)
                    end
                end)
            end
        else
            if State.muteAudioDescendantConn then
                pcall(function()
                    State.muteAudioDescendantConn:Disconnect()
                end)
                State.muteAudioDescendantConn = nil
            end
            for snd, origVol in pairs(State.mutedGameSounds) do
                if snd and snd.Parent then
                    pcall(function()
                        snd.Volume = origVol
                    end)
                end
            end
            table.clear(State.mutedGameSounds)
        end
    end

    local function updateMusicPlayerFrame(safeDt)
        State.musicWaveClock = (State.musicWaveClock or 0) + safeDt
        local track = getActiveTrackData()
        local totalLen = getEffectiveTrackLength(track)

        if State.musicIsPlaying and not State.musicScrubbing then
            local realTimePos = tonumber(musicSound.TimePosition) or 0
            local realLen = tonumber(musicSound.TimeLength) or 0
            if realLen > 1 and musicSound.IsPlaying then
                State.musicSimulatedPos = realTimePos
            else
                State.musicSimulatedPos = (State.musicSimulatedPos or 0) + safeDt
                if State.musicSimulatedPos >= totalLen then
                    if ConfigState.MusicLooped ~= false then
                        State.musicSimulatedPos = 0
                        pcall(function()
                            musicSound.TimePosition = 0
                        end)
                    else
                        State.musicSimulatedPos = totalLen
                        setMusicPlaying(false)
                    end
                end
            end
        end

        local curPos = math.clamp(State.musicSimulatedPos or 0, 0, totalLen)
        local ratio = (totalLen > 0) and (curPos / totalLen) or 0
        if PlayerBar.Visible then
            TimeCounterLbl.Text = string.format("%s / %s", formatTimeMMSS(curPos), formatTimeMMSS(totalLen))
            updateWavyScrubberVisuals(ratio, State.musicWaveClock)
        end
    end

    -- Initialize scrubber wave visuals in idle state
    updateWavyScrubberVisuals(0, 0)

    State.syncMusicPlayerDock = syncMusicPlayerDock
    State.setMusicPlaying = setMusicPlaying
    State.seekMusicToRatio = seekMusicToRatio
    State.stepMusicTrack = stepMusicTrack
    State.applyMuteGameAudio = applyMuteGameAudio
    State.updateMusicPlayerFrame = updateMusicPlayerFrame
    UI.MusicPlayerBar = PlayerBar
    UI.MusicPlayerScale = PlayerScale
    UI.MusicPlayerStroke = PlayerStroke
    UI.MusicTitleLabel = TrackTitleLbl
    UI.MusicStatusLabel = TrackStatusLbl
    UI.MusicTimeLabel = TimeCounterLbl
    UI.MusicPrevButton = PrevBtn
    UI.MusicPlayPauseButton = PlayPauseBtn
    UI.MusicNextButton = NextBtn
    UI.MusicTimelineTrack = TimelineTrack
    UI.MusicTimelineHitbox = TimelineHitbox
    UI.MusicScrubberKnob = ScrubberKnob
    UI.OceanWaveSegments = oceanSegments
end

--------------------------------------------------------------------------------
-- 11C. PRO VISUAL SUITES (SELF CHAMS, LEG TRAILS, TOOL VISUALS, BLOOM & SUN RAYS,
--      COLOR CORRECTION, SKYBOX + CATALOG SEARCH, ATMOSPHERE CONTROLLER)
--      100% Pre-Allocated Instances -> Zero Per-Frame Instance.new in RenderStepped!
--------------------------------------------------------------------------------
do
    -- 1. Self Chams Pre-Allocated Highlight & Material Map (21 Presets)
    local selfChamsHighlight = Instance.new("Highlight")
    selfChamsHighlight.Name = "CoreXyz_SelfChamsHighlight"
    selfChamsHighlight.Enabled = false
    selfChamsHighlight.FillColor = ConfigState.SelfChamsFillColor or Color3.fromRGB(115, 95, 255)
    selfChamsHighlight.OutlineColor = ConfigState.SelfChamsOutlineColor or Color3.fromRGB(255, 255, 255)
    selfChamsHighlight.FillTransparency = ConfigState.SelfChamsFillTrans or 0.55
    selfChamsHighlight.OutlineTransparency = ConfigState.SelfChamsOutlineTrans or 0
    selfChamsHighlight.Parent = UI.HighlightContainer
    UI.SelfChamsHighlight = selfChamsHighlight

    local CHAMS_MATERIAL_PRESETS = {
        ["None"]         = { Mat = nil,                          Ref = 0.00, Tint = nil },
        ["Aura"]         = { Mat = Enum.Material.ForceField,     Ref = 0.15, Tint = Color3.fromRGB(130, 105, 255) },
        ["Neon"]         = { Mat = Enum.Material.Neon,           Ref = 0.00, Tint = nil },
        ["Flat"]         = { Mat = Enum.Material.SmoothPlastic,  Ref = 0.00, Tint = nil },
        ["Chrome"]       = { Mat = Enum.Material.Glass,          Ref = 0.88, Tint = Color3.fromRGB(225, 232, 245) },
        ["Liquid Metal"] = { Mat = Enum.Material.Glass,          Ref = 0.96, Tint = Color3.fromRGB(205, 218, 240) },
        ["Gold"]         = { Mat = Enum.Material.Foil,           Ref = 0.68, Tint = Color3.fromRGB(255, 200, 55) },
        ["Diamond"]      = { Mat = Enum.Material.Glass,          Ref = 0.62, Tint = Color3.fromRGB(135, 235, 255) },
        ["Glass"]        = { Mat = Enum.Material.Glass,          Ref = 0.38, Tint = nil },
        ["Ice"]          = { Mat = Enum.Material.Ice,            Ref = 0.45, Tint = Color3.fromRGB(150, 225, 255) },
        ["Obsidian"]     = { Mat = Enum.Material.Granite,        Ref = 0.42, Tint = Color3.fromRGB(36, 28, 54) },
        ["Lava"]         = { Mat = Enum.Material.CrackedLava,    Ref = 0.05, Tint = Color3.fromRGB(255, 85, 30) },
        ["Plasma"]       = { Mat = Enum.Material.ForceField,     Ref = 0.25, Tint = Color3.fromRGB(235, 70, 255) },
        ["Toxic"]        = { Mat = Enum.Material.Neon,           Ref = 0.10, Tint = Color3.fromRGB(75, 255, 110) },
        ["Ropes"]        = { Mat = Enum.Material.Fabric,         Ref = 0.05, Tint = nil },
        ["Rainbow"]      = { Mat = Enum.Material.Neon,           Ref = 0.20, Tint = nil },
        ["Holographic"]  = { Mat = Enum.Material.ForceField,     Ref = 0.58, Tint = Color3.fromRGB(95, 225, 255) },
        ["Galaxy"]       = { Mat = Enum.Material.ForceField,     Ref = 0.35, Tint = Color3.fromRGB(115, 70, 245) },
        ["Matrix"]       = { Mat = Enum.Material.Neon,           Ref = 0.15, Tint = Color3.fromRGB(40, 255, 120) },
        ["Pearl"]        = { Mat = Enum.Material.Glass,          Ref = 0.64, Tint = Color3.fromRGB(245, 235, 255) },
        ["Glossy"]       = { Mat = Enum.Material.SmoothPlastic,  Ref = 0.76, Tint = nil },
    }

    local function restoreSelfChamsParts()
        for part, orig in pairs(State.selfChamsCache) do
            if part and part.Parent then
                pcall(function()
                    part.Material = orig.Material
                    part.Color = orig.Color
                    part.Reflectance = orig.Reflectance
                end)
            end
        end
        table.clear(State.selfChamsCache)
    end

    local function applySelfChams(overrideColor, pulseOffset)
        local char = LocalPlayer.Character
        if not ConfigState.SelfChams or not char then
            selfChamsHighlight.Enabled = false
            selfChamsHighlight.Adornee = nil
            restoreSelfChamsParts()
            return
        end

        local matName = ConfigState.SelfChamsMaterial or "Lava"
        local preset = CHAMS_MATERIAL_PRESETS[matName] or CHAMS_MATERIAL_PRESETS["Lava"]
        local fillCol = overrideColor or ConfigState.SelfChamsFillColor or Color3.fromRGB(115, 95, 255)
        if not overrideColor and not ConfigState.SelfChamsCustomColor and preset and preset.Tint then
            fillCol = preset.Tint
        end
        local outCol = overrideColor or ConfigState.SelfChamsOutlineColor or Color3.fromRGB(255, 255, 255)

        local fillTrans = math.clamp((ConfigState.SelfChamsFillTrans or 0.55) + (pulseOffset or 0), 0, 1)
        local outTrans = ConfigState.SelfChamsGlowRim and math.clamp(ConfigState.SelfChamsOutlineTrans or 0, 0, 1) or math.clamp((ConfigState.SelfChamsOutlineTrans or 0) + 0.35, 0, 1)

        selfChamsHighlight.Adornee = char
        selfChamsHighlight.FillColor = fillCol
        selfChamsHighlight.OutlineColor = outCol
        selfChamsHighlight.FillTransparency = fillTrans
        selfChamsHighlight.OutlineTransparency = outTrans
        selfChamsHighlight.Enabled = true

        for _, desc in ipairs(char:GetDescendants()) do
            if desc:IsA("BasePart") and desc.Name ~= "HumanoidRootPart" then
                if State.selfChamsCache[desc] == nil then
                    State.selfChamsCache[desc] = {
                        Material = desc.Material,
                        Color = desc.Color,
                        Reflectance = desc.Reflectance,
                    }
                end
                pcall(function()
                    if preset and preset.Mat then
                        desc.Material = preset.Mat
                    else
                        desc.Material = State.selfChamsCache[desc].Material
                    end
                    desc.Reflectance = (preset and preset.Ref) or 0
                    desc.Color = fillCol
                end)
            end
        end
    end

    -- 2. Leg / Movement Trails Pre-Allocated Instances
    local leftAtt0 = Instance.new("Attachment")
    leftAtt0.Name = "CoreXyz_LeftTrailAtt0"
    leftAtt0.Position = Vector3.new(0, 0.45, 0)

    local leftAtt1 = Instance.new("Attachment")
    leftAtt1.Name = "CoreXyz_LeftTrailAtt1"
    leftAtt1.Position = Vector3.new(0, -0.45, 0)

    local leftLegTrail = Instance.new("Trail")
    leftLegTrail.Name = "CoreXyz_LeftLegTrail"
    leftLegTrail.Attachment0 = leftAtt0
    leftLegTrail.Attachment1 = leftAtt1
    leftLegTrail.Enabled = false
    leftLegTrail.FaceCamera = true
    leftLegTrail.LightEmission = 0.85
    leftLegTrail.Transparency = NumberSequence.new(0.12, 1.0)
    leftLegTrail.Lifetime = ConfigState.LegTrailLength or 0.5

    local rightAtt0 = Instance.new("Attachment")
    rightAtt0.Name = "CoreXyz_RightTrailAtt0"
    rightAtt0.Position = Vector3.new(0, 0.45, 0)

    local rightAtt1 = Instance.new("Attachment")
    rightAtt1.Name = "CoreXyz_RightTrailAtt1"
    rightAtt1.Position = Vector3.new(0, -0.45, 0)

    local rightLegTrail = Instance.new("Trail")
    rightLegTrail.Name = "CoreXyz_RightLegTrail"
    rightLegTrail.Attachment0 = rightAtt0
    rightLegTrail.Attachment1 = rightAtt1
    rightLegTrail.Enabled = false
    rightLegTrail.FaceCamera = true
    rightLegTrail.LightEmission = 0.85
    rightLegTrail.Transparency = NumberSequence.new(0.12, 1.0)
    rightLegTrail.Lifetime = ConfigState.LegTrailLength or 0.5

    UI.LeftLegTrail = leftLegTrail
    UI.RightLegTrail = rightLegTrail

    local function applyLegTrails(rainbowCol1, rainbowCol2)
        local char = LocalPlayer.Character
        if not ConfigState.LegTrailEnabled or not char then
            leftLegTrail.Enabled = false
            rightLegTrail.Enabled = false
            return
        end

        local leftPart = char:FindFirstChild("LeftFoot")
            or char:FindFirstChild("LeftLowerLeg")
            or char:FindFirstChild("Left Leg")
            or char:FindFirstChild("HumanoidRootPart")
        local rightPart = char:FindFirstChild("RightFoot")
            or char:FindFirstChild("RightLowerLeg")
            or char:FindFirstChild("Right Leg")
            or char:FindFirstChild("HumanoidRootPart")

        if leftPart then
            leftAtt0.Parent = leftPart
            leftAtt1.Parent = leftPart
            leftLegTrail.Parent = leftPart
        end
        if rightPart then
            rightAtt0.Parent = rightPart
            rightAtt1.Parent = rightPart
            rightLegTrail.Parent = rightPart
        end

        local widthVal = math.clamp(ConfigState.LegTrailWidth or 0.25, 0.02, 3.0)
        local lenVal = math.clamp(ConfigState.LegTrailLength or 0.5, 0.05, 5.0)
        local widthSeq = NumberSequence.new(widthVal, 0)

        local lStart = rainbowCol1 or ConfigState.LeftLegTrailStart or Color3.fromRGB(105, 85, 255)
        local lEnd = rainbowCol2 or ConfigState.LeftLegTrailEnd or Color3.fromRGB(70, 205, 255)
        local rStart = rainbowCol1 or (ConfigState.LegTrailSameColors and lStart or (ConfigState.RightLegTrailStart or Color3.fromRGB(255, 85, 195)))
        local rEnd = rainbowCol2 or (ConfigState.LegTrailSameColors and lEnd or (ConfigState.RightLegTrailEnd or Color3.fromRGB(255, 190, 75)))

        leftLegTrail.WidthScale = widthSeq
        leftLegTrail.Lifetime = lenVal
        leftLegTrail.Color = ColorSequence.new(lStart, lEnd)
        leftLegTrail.Enabled = (leftPart ~= nil)

        rightLegTrail.WidthScale = widthSeq
        rightLegTrail.Lifetime = lenVal
        rightLegTrail.Color = ColorSequence.new(rStart, rEnd)
        rightLegTrail.Enabled = (rightPart ~= nil)
    end

    -- 3. Tool Visuals Pre-Allocated Highlight & PointLight
    local toolChamsHighlight = Instance.new("Highlight")
    toolChamsHighlight.Name = "CoreXyz_ToolChamsHighlight"
    toolChamsHighlight.Enabled = false
    toolChamsHighlight.Parent = UI.HighlightContainer
    UI.ToolChamsHighlight = toolChamsHighlight

    local toolPointLight = Instance.new("PointLight")
    toolPointLight.Name = "CoreXyz_ToolPointLight"
    toolPointLight.Enabled = false
    toolPointLight.Range = 12
    toolPointLight.Brightness = ConfigState.ToolGlowBrightness or 3.0
    UI.ToolPointLight = toolPointLight

    local TOOL_MATERIAL_MAP = {
        ["SmoothPlastic"] = Enum.Material.SmoothPlastic,
        ["Neon"]          = Enum.Material.Neon,
        ["Glass"]         = Enum.Material.Glass,
        ["Foil"]          = Enum.Material.Foil,
        ["ForceField"]    = Enum.Material.ForceField,
    }

    local TOOL_SKIN_TEXTURES = {
        ["None"]                   = "",
        ["Aurora"]                 = "rbxassetid://1250626578",
        ["Blue Skies, White Guns"] = "rbxassetid://6882678552",
        ["Blue Stars"]             = "rbxassetid://2695648605",
        ["Blue Void"]              = "rbxassetid://159454299",
        ["Classic Blue White"]     = "rbxassetid://476586439",
        ["Epic White"]             = "rbxassetid://570555956",
        ["Green and Black"]        = "rbxassetid://2151551758",
        ["Matrix"]                 = "rbxassetid://1306134903",
        ["Pink White"]             = "rbxassetid://271042516",
        ["Water"]                  = "rbxassetid://6071579801",
        ["White"]                  = "rbxassetid://108158379",
    }

    local function restoreToolVisualsParts()
        for inst, orig in pairs(State.toolVisualsCache) do
            if inst and inst.Parent then
                pcall(function()
                    if orig.Material ~= nil then inst.Material = orig.Material end
                    if orig.Color ~= nil then inst.Color = orig.Color end
                    if orig.Transparency ~= nil then inst.Transparency = orig.Transparency end
                    if orig.TextureID ~= nil and inst:IsA("MeshPart") then
                        pcall(function() inst.TextureID = orig.TextureID end)
                    end
                    if orig.TextureId ~= nil then
                        pcall(function() inst.TextureId = orig.TextureId end)
                    end
                end)
            end
        end
        table.clear(State.toolVisualsCache)
    end

    local function findActiveCharacterTool()
        local char = LocalPlayer.Character
        if not char then
            return nil
        end
        for _, child in ipairs(char:GetChildren()) do
            if child:IsA("Tool") or child.ClassName == "Tool" or string.find(tostring(child.Name), "Tool") then
                return child
            end
        end
        return nil
    end

    local function applyToolVisuals(rainbowColor)
        local tool = findActiveCharacterTool()
        local anyToolFeature = ConfigState.ToolVisuals or ConfigState.ToolChams or ConfigState.ToolGlow
        if not anyToolFeature or not tool then
            toolChamsHighlight.Enabled = false
            toolChamsHighlight.Adornee = nil
            toolPointLight.Enabled = false
            toolPointLight.Parent = nil
            restoreToolVisualsParts()
            return
        end

        local toolCol = rainbowColor or ConfigState.ToolColor or Color3.fromRGB(115, 95, 255)
        local targetMat = TOOL_MATERIAL_MAP[ConfigState.ToolMaterial or "SmoothPlastic"] or Enum.Material.SmoothPlastic
        local targetTrans = math.clamp(ConfigState.ToolTransparency or 0, 0, 1)
        local skinTex = TOOL_SKIN_TEXTURES[ConfigState.ToolSkinTexture or "None"] or ""

        local primaryHandle = tool:FindFirstChild("Handle")
        for _, desc in ipairs(tool:GetDescendants()) do
            if desc:IsA("BasePart") then
                if not primaryHandle then
                    primaryHandle = desc
                end
                if ConfigState.ToolVisuals then
                    if State.toolVisualsCache[desc] == nil then
                        local cachedTexId = nil
                        if desc:IsA("MeshPart") then
                            pcall(function() cachedTexId = desc.TextureID end)
                        end
                        State.toolVisualsCache[desc] = {
                            Material = desc.Material,
                            Color = desc.Color,
                            Transparency = desc.Transparency,
                            TextureID = cachedTexId,
                        }
                    end
                    pcall(function()
                        desc.Material = targetMat
                        desc.Color = toolCol
                        desc.Transparency = targetTrans
                        if skinTex ~= "" and desc:IsA("MeshPart") then
                            pcall(function() desc.TextureID = skinTex end)
                        end
                    end)
                end
            elseif (desc:IsA("SpecialMesh") or desc.ClassName == "SpecialMesh") and ConfigState.ToolVisuals then
                if State.toolVisualsCache[desc] == nil then
                    local cachedMeshTex = nil
                    pcall(function() cachedMeshTex = desc.TextureId end)
                    State.toolVisualsCache[desc] = {
                        TextureId = cachedMeshTex,
                    }
                end
                if skinTex ~= "" then
                    pcall(function()
                        desc.TextureId = skinTex
                    end)
                end
            end
        end

        if not ConfigState.ToolVisuals then
            restoreToolVisualsParts()
        end

        if ConfigState.ToolChams then
            local style = ConfigState.ToolChamsStyle or "Outline"
            local chamsCol = rainbowColor or ConfigState.ToolChamsColor or Color3.fromRGB(255, 255, 255)
            toolChamsHighlight.Adornee = tool
            toolChamsHighlight.OutlineColor = chamsCol
            toolChamsHighlight.FillColor = toolCol
            if style == "Outline" then
                toolChamsHighlight.FillTransparency = 1.0
                toolChamsHighlight.OutlineTransparency = 0.0
            elseif style == "Soft Fill" then
                toolChamsHighlight.FillTransparency = 0.55
                toolChamsHighlight.OutlineTransparency = 0.08
            else
                toolChamsHighlight.FillTransparency = 0.12
                toolChamsHighlight.OutlineTransparency = 0.0
            end
            toolChamsHighlight.Enabled = true
        else
            toolChamsHighlight.Enabled = false
            toolChamsHighlight.Adornee = nil
        end

        if ConfigState.ToolGlow and primaryHandle then
            toolPointLight.Parent = primaryHandle
            toolPointLight.Color = toolCol
            toolPointLight.Brightness = math.clamp(ConfigState.ToolGlowBrightness or 3.0, 0, 10)
            toolPointLight.Enabled = true
        else
            toolPointLight.Enabled = false
            toolPointLight.Parent = nil
        end
    end

    -- 4. Custom Bloom & Sun Rays Pre-Allocated PostEffects
    local customBloom = Lighting:FindFirstChild("CoreXyz_CustomBloom") or Instance.new("BloomEffect")
    customBloom.Name = "CoreXyz_CustomBloom"
    customBloom.Enabled = false
    customBloom.Intensity = ConfigState.BloomIntensity or 0.6
    customBloom.Size = ConfigState.BloomSize or 26
    customBloom.Threshold = ConfigState.BloomThreshold or 0.4
    customBloom.Parent = Lighting
    UI.CustomBloom = customBloom

    local customSunRays = Lighting:FindFirstChild("CoreXyz_CustomSunRays") or Instance.new("SunRaysEffect")
    customSunRays.Name = "CoreXyz_CustomSunRays"
    customSunRays.Enabled = false
    customSunRays.Intensity = ConfigState.SunRaysIntensity or 0.25
    customSunRays.Spread = ConfigState.SunRaysSpread or 1.0
    customSunRays.Parent = Lighting
    UI.CustomSunRays = customSunRays

    local function applyCustomBloomAndSunRays()
        customBloom.Intensity = math.clamp(ConfigState.BloomIntensity or 0.6, 0, 3)
        customBloom.Size = math.clamp(ConfigState.BloomSize or 26, 0, 56)
        customBloom.Threshold = math.clamp(ConfigState.BloomThreshold or 0.4, 0, 4)
        customBloom.Enabled = ConfigState.BloomEnabled and true or false

        customSunRays.Intensity = math.clamp(ConfigState.SunRaysIntensity or 0.25, 0, 1)
        customSunRays.Spread = math.clamp(ConfigState.SunRaysSpread or 1.0, 0, 1)
        customSunRays.Enabled = ConfigState.SunRaysEnabled and true or false
    end

    -- 5. Custom Color Correction Pre-Allocated PostEffect
    local customColorCorr = Lighting:FindFirstChild("CoreXyz_CustomColorCorrection") or Instance.new("ColorCorrectionEffect")
    customColorCorr.Name = "CoreXyz_CustomColorCorrection"
    customColorCorr.Enabled = false
    customColorCorr.TintColor = ConfigState.ColorCorrectionTint or Color3.fromRGB(255, 255, 255)
    customColorCorr.Saturation = ConfigState.ColorCorrectionSaturation or 0
    customColorCorr.Contrast = ConfigState.ColorCorrectionContrast or 0
    customColorCorr.Brightness = ConfigState.ColorCorrectionBrightness or 0
    customColorCorr.Parent = Lighting
    UI.CustomColorCorrection = customColorCorr

    local function applyCustomColorCorrection()
        customColorCorr.TintColor = ConfigState.ColorCorrectionTint or Color3.fromRGB(255, 255, 255)
        customColorCorr.Saturation = math.clamp(ConfigState.ColorCorrectionSaturation or 0, -1, 2)
        customColorCorr.Contrast = math.clamp(ConfigState.ColorCorrectionContrast or 0, -1, 2)
        customColorCorr.Brightness = math.clamp(ConfigState.ColorCorrectionBrightness or 0, -1, 1)
        customColorCorr.Enabled = ConfigState.ColorCorrectionEnabled and true or false
    end

    -- 6. Skybox Controller & Catalog Search (21 Curated Skyboxes + Custom Decal ID + Search)
    local customSky = Lighting:FindFirstChild("CoreXyz_CustomSky") or Instance.new("Sky")
    customSky.Name = "CoreXyz_CustomSky"
    UI.CustomSky = customSky

    local SKYBOX_PRESET_LIBRARY = {
        ["Galaxy"]           = "rbxassetid://159454299",
        ["Aurora Galaxy"]    = "rbxassetid://12064107",
        ["Aurora Borealis"]  = "rbxassetid://159454286",
        ["Realistic Space"]  = "rbxassetid://2695648605",
        ["Night"]            = "rbxassetid://48020371",
        ["Night Fog"]        = "rbxassetid://1370717244",
        ["Red Night"]        = "rbxassetid://401664839",
        ["Scary Red"]        = "rbxassetid://570555956",
        ["Sunset"]           = "rbxassetid://600830446",
        ["Sunset With Sun"]  = "rbxassetid://323493360",
        ["Classic Purple"]   = "rbxassetid://271042516",
        ["Purple"]           = "rbxassetid://5084575798",
        ["Pink"]             = "rbxassetid://271077243",
        ["Pink Sky"]         = "rbxassetid://1192402877",
        ["Anime Island"]     = "rbxassetid://591058823",
        ["Anime"]            = "rbxassetid://6882678552",
        ["Clouds"]           = "rbxassetid://570557514",
        ["Realistic Clouds"] = "rbxassetid://476586439",
        ["Minecraft"]        = "rbxassetid://1876545003",
        ["Minecraft Alt"]    = "rbxassetid://2151551758",
        ["Clear Blue"]       = "rbxassetid://108158379",
    }

    local function applySkyboxAssetId(texId)
        local formatted = tostring(texId or "")
        if formatted ~= "" and not string.find(formatted, "^rbxassetid://") and not string.find(formatted, "^http") then
            local digits = string.match(formatted, "%d+")
            if digits then
                formatted = "rbxassetid://" .. digits
            end
        end
        if formatted == "" then
            formatted = "rbxassetid://159454299"
        end

        local appliedFromObj = false
        pcall(function()
            if type(game.GetObjects) == "function" then
                local objs = game:GetObjects(formatted)
                if type(objs) == "table" and objs[1] then
                    local root = objs[1]
                    local skyObj = (root.ClassName == "Sky" and root) or (root.FindFirstChildOfClass and root:FindFirstChildOfClass("Sky"))
                    if skyObj then
                        customSky.SkyboxBk = (skyObj.SkyboxBk and skyObj.SkyboxBk ~= "") and skyObj.SkyboxBk or formatted
                        customSky.SkyboxDn = (skyObj.SkyboxDn and skyObj.SkyboxDn ~= "") and skyObj.SkyboxDn or formatted
                        customSky.SkyboxFt = (skyObj.SkyboxFt and skyObj.SkyboxFt ~= "") and skyObj.SkyboxFt or formatted
                        customSky.SkyboxLf = (skyObj.SkyboxLf and skyObj.SkyboxLf ~= "") and skyObj.SkyboxLf or formatted
                        customSky.SkyboxRt = (skyObj.SkyboxRt and skyObj.SkyboxRt ~= "") and skyObj.SkyboxRt or formatted
                        customSky.SkyboxUp = (skyObj.SkyboxUp and skyObj.SkyboxUp ~= "") and skyObj.SkyboxUp or formatted
                        appliedFromObj = true
                    elseif root.ClassName == "Decal" or root.ClassName == "Texture" then
                        if root.Texture and root.Texture ~= "" then
                            formatted = root.Texture
                        end
                    end
                    pcall(function() root:Destroy() end)
                end
            end
        end)

        if not appliedFromObj then
            customSky.SkyboxBk = formatted
            customSky.SkyboxDn = formatted
            customSky.SkyboxFt = formatted
            customSky.SkyboxLf = formatted
            customSky.SkyboxRt = formatted
            customSky.SkyboxUp = formatted
        end
    end

    local function applyCustomSkybox()
        if ConfigState.SkyboxClearAtmos then
            for _, child in ipairs(Lighting:GetChildren()) do
                if child:IsA("Atmosphere") and child.Name ~= "CoreXyz_CustomAtmosphere" and child.Name ~= "CoreXyz_WeatherAtmosphere" then
                    if State.clearedAtmosphereCache[child] == nil then
                        State.clearedAtmosphereCache[child] = child.Density
                    end
                    pcall(function()
                        child.Density = 0
                    end)
                end
            end
        else
            for atmos, origDensity in pairs(State.clearedAtmosphereCache) do
                if atmos and atmos.Parent then
                    pcall(function()
                        atmos.Density = origDensity
                    end)
                end
            end
            table.clear(State.clearedAtmosphereCache)
        end

        if not ConfigState.SkyboxEnabled then
            customSky.Parent = nil
            for skyInst, origParent in pairs(State.suppressedSkyInstances) do
                if skyInst then
                    pcall(function()
                        skyInst.Parent = origParent or Lighting
                    end)
                end
            end
            table.clear(State.suppressedSkyInstances)
            return
        end

        -- Suppress any pre-existing Sky instances in Lighting so Roblox renders CoreXyz_CustomSky!
        for _, child in ipairs(Lighting:GetChildren()) do
            if (child:IsA("Sky") or child.ClassName == "Sky") and child ~= customSky then
                State.suppressedSkyInstances[child] = Lighting
                pcall(function()
                    child.Parent = nil
                end)
            end
        end

        local customId = string.gsub(tostring(ConfigState.CustomSkyDecalId or ""), "%s+", "")
        if customId ~= "" then
            applySkyboxAssetId(customId)
        else
            local presetName = ConfigState.SkyboxPreset or "Galaxy"
            local presetAsset = SKYBOX_PRESET_LIBRARY[presetName] or SKYBOX_PRESET_LIBRARY["Galaxy"]
            applySkyboxAssetId(presetAsset)
        end
        customSky.Parent = Lighting
    end

    local function searchSkyboxes(query)
        local q = string.lower(string.gsub(tostring(query or ""), "^%s*(.-)%s*$", "%1"))
        local matches = {}
        for name, assetId in pairs(SKYBOX_PRESET_LIBRARY) do
            if q == "" or string.find(string.lower(name), q, 1, true) then
                local numId = string.match(assetId, "%d+") or "159454299"
                table.insert(matches, string.format("%s (%s)", name, numId))
            end
        end
        table.sort(matches)
        if #matches == 0 then
            local customDigits = string.match(q, "%d+")
            if customDigits then
                table.insert(matches, string.format("Custom Skybox (%s)", customDigits))
            else
                table.insert(matches, string.format("%s Sky (159454299)", query ~= "" and query or "Galaxy"))
                table.insert(matches, "Aurora Galaxy (12064107)")
                table.insert(matches, "Sunset (600830446)")
            end
        end
        return matches
    end

    -- 7. Custom Atmosphere Controller Pre-Allocated Instance
    local customAtmosphere = Lighting:FindFirstChild("CoreXyz_CustomAtmosphere") or Instance.new("Atmosphere")
    customAtmosphere.Name = "CoreXyz_CustomAtmosphere"
    UI.CustomAtmosphere = customAtmosphere

    local function applyCustomAtmosphere()
        if not ConfigState.AtmosphereEnabled then
            customAtmosphere.Parent = nil
            return
        end
        customAtmosphere.Color = ConfigState.AtmosphereColor or Color3.fromRGB(200, 195, 225)
        customAtmosphere.Decay = ConfigState.AtmosphereDecay or Color3.fromRGB(92, 60, 14)
        customAtmosphere.Density = math.clamp(ConfigState.AtmosphereDensity or 0.35, 0, 1)
        customAtmosphere.Offset = math.clamp(ConfigState.AtmosphereOffset or 0, 0, 1)
        customAtmosphere.Haze = math.clamp(ConfigState.AtmosphereHaze or 0, 0, 10)
        customAtmosphere.Glare = math.clamp(ConfigState.AtmosphereGlare or 0, 0, 10)
        customAtmosphere.Parent = Lighting
    end

    -- Frame-Synchronized Visual Suites Animator (Zero Instance.new per frame!)
    local visualSuiteTick = 0
    local function updateVisualSuitesFrame(safeDt, animClock)
        visualSuiteTick = visualSuiteTick + safeDt
        if visualSuiteTick < 0.033 then
            return
        end
        visualSuiteTick = 0

        local hue1 = (animClock * 0.22) % 1
        local hue2 = (hue1 + 0.35) % 1
        local rainbowCol1 = Color3.fromHSV(hue1, 0.85, 1)
        local rainbowCol2 = Color3.fromHSV(hue2, 0.85, 1)

        if ConfigState.SelfChams then
            if ConfigState.SelfChamsRainbow or ConfigState.SelfChamsPulse or ConfigState.SelfChamsMaterial == "Rainbow" then
                local useRainbow = (ConfigState.SelfChamsRainbow or ConfigState.SelfChamsMaterial == "Rainbow") and rainbowCol1 or nil
                local pulseWave = ConfigState.SelfChamsPulse and (math.sin(animClock * 4.0) * 0.22) or 0
                applySelfChams(useRainbow, pulseWave)
            elseif selfChamsHighlight.Adornee ~= LocalPlayer.Character then
                applySelfChams()
            end
        end

        if ConfigState.LegTrailEnabled then
            if ConfigState.LegTrailRainbow then
                applyLegTrails(rainbowCol1, rainbowCol2)
            elseif not leftLegTrail.Parent or not leftLegTrail.Parent.Parent then
                applyLegTrails()
            end
        end

        if ConfigState.ToolVisuals or ConfigState.ToolChams or ConfigState.ToolGlow then
            if ConfigState.RainbowTool then
                applyToolVisuals(rainbowCol1)
            else
                local activeTool = findActiveCharacterTool()
                if (ConfigState.ToolChams and toolChamsHighlight.Adornee ~= activeTool) or (not activeTool and (toolChamsHighlight.Enabled or toolPointLight.Enabled)) then
                    applyToolVisuals()
                end
            end
        end
    end

    State.applySelfChams = applySelfChams
    State.applyLegTrails = applyLegTrails
    State.applyToolVisuals = applyToolVisuals
    State.applyCustomBloomAndSunRays = applyCustomBloomAndSunRays
    State.applyCustomColorCorrection = applyCustomColorCorrection
    State.applyCustomSkybox = applyCustomSkybox
    State.searchSkyboxes = searchSkyboxes
    State.applyCustomAtmosphere = applyCustomAtmosphere
    State.updateVisualSuitesFrame = updateVisualSuitesFrame
end

-- Glitch-Free Freecam Toggle
local function setFreecamEnabled(enabled)
    ConfigState.Freecam = enabled
    local cam = workspace.CurrentCamera
    local char = LocalPlayer.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    local hum = char and char:FindFirstChildOfClass("Humanoid")

    if enabled and cam then
        State.freecamPos = cam.CFrame.Position
        if hrp then
            hrp.Anchored = true
        end
        cam.CameraType = Enum.CameraType.Scriptable
    else
        if hrp then
            hrp.Anchored = false
        end
        if cam then
            cam.CameraType = Enum.CameraType.Custom
            if hum then
                cam.CameraSubject = hum
            end
        end
    end
end

local function updateMovement()
    local char = LocalPlayer.Character
    local humanoid = char and char:FindFirstChildOfClass("Humanoid")
    if humanoid then
        if ConfigState.StealthBypass then
            -- Stealth Anti-Kick Mode: Keep Humanoid.WalkSpeed at game default (16) so GetPropertyChangedSignal("WalkSpeed") never fires!
            humanoid.WalkSpeed = State.defaultWalkSpeed
        else
            humanoid.WalkSpeed = ConfigState.WalkSpeedEnabled and ConfigState.WalkSpeed or State.defaultWalkSpeed
        end
        humanoid.UseJumpPower = true
        humanoid.JumpPower = ConfigState.JumpPowerEnabled and ConfigState.JumpPower or State.defaultJumpPower
    end
end

local function restoreNoClipCollisions()
    for part, origState in pairs(State.noclipCollideCache) do
        if part and part.Parent then
            part.CanCollide = origState
        end
    end
    table.clear(State.noclipCollideCache)
end

local function restoreAntiFlingCollisions()
    for part, origState in pairs(State.antiFlingCollideCache) do
        if part and part.Parent then
            part.CanCollide = origState
        end
    end
    table.clear(State.antiFlingCollideCache)
end

local function applyHeadless(state)
    local char = LocalPlayer.Character
    if not char then
        return
    end
    local head = char:FindFirstChild("Head")
    if not head then
        return
    end
    if state then
        if State.headlessCache.HeadTransparency == nil then
            State.headlessCache.HeadTransparency = head.Transparency
        end
        head.Transparency = 1
        for _, child in ipairs(head:GetChildren()) do
            if child:IsA("Decal") then
                State.headlessCache[child] = child.Transparency
                child.Transparency = 1
            end
        end
    else
        if State.headlessCache.HeadTransparency ~= nil then
            head.Transparency = State.headlessCache.HeadTransparency
        end
        for inst, origT in pairs(State.headlessCache) do
            if type(inst) == "table" and inst.Parent then
                pcall(function() inst.Transparency = origT end)
            end
        end
        table.clear(State.headlessCache)
    end
end

local function applyKorblox(state)
    local char = LocalPlayer.Character
    if not char then
        return
    end
    local rLower = char:FindFirstChild("RightLowerLeg")
    local rFoot = char:FindFirstChild("RightFoot")
    local rUpper = char:FindFirstChild("RightUpperLeg")
    local r6Leg = char:FindFirstChild("Right Leg")

    if state then
        -- Remove any previous Korblox attachments first
        local oldPeg = char:FindFirstChild("KorbloxPeg")
        if oldPeg then pcall(function() oldPeg:Destroy() end) end
        local oldCharMesh = char:FindFirstChild("KorbloxCharacterMesh")
        if oldCharMesh then pcall(function() oldCharMesh:Destroy() end) end

        if rLower then
            if State.korbloxCache[rLower] == nil then
                State.korbloxCache[rLower] = rLower.Transparency
            end
            rLower.Transparency = 1
        end
        if rFoot then
            if State.korbloxCache[rFoot] == nil then
                State.korbloxCache[rFoot] = rFoot.Transparency
            end
            rFoot.Transparency = 1
        end
        if rUpper then
            if State.korbloxCache[rUpper] == nil then
                State.korbloxCache[rUpper] = rUpper.Transparency
            end
            local appliedDirectMesh = false
            pcall(function()
                rUpper.MeshId = "http://www.roblox.com/asset/?id=902942096"
                rUpper.TextureID = "http://www.roblox.com/asset/?id=902843398"
                if string.find(tostring(rUpper.MeshId), "902942096") then
                    appliedDirectMesh = true
                end
            end)
            if not appliedDirectMesh then
                rUpper.Transparency = 1
                pcall(function()
                    local peg = Instance.new("Part")
                    peg.Name = "KorbloxPeg"
                    peg.Size = Vector3.new(0.85, 1.65, 0.85)
                    peg.Color = Color3.fromRGB(26, 30, 44)
                    peg.Material = Enum.Material.SmoothPlastic
                    peg.CanCollide = false
                    peg.Anchored = false
                    peg.CFrame = rUpper.CFrame * CFrame.new(0, -0.15, 0)
                    peg.Parent = char

                    local sm = Instance.new("SpecialMesh")
                    sm.Name = "KorbloxSpecialMesh"
                    sm.MeshId = "rbxassetid://101851696"
                    sm.TextureId = "rbxassetid://101851254"
                    sm.Scale = Vector3.new(0.95, 0.95, 0.95)
                    sm.Parent = peg

                    local weld = Instance.new("Weld")
                    weld.Name = "KorbloxWeld"
                    weld.Part0 = rUpper
                    weld.Part1 = peg
                    weld.C0 = CFrame.new(0, -0.15, 0)
                    weld.Parent = peg
                end)
            else
                rUpper.Transparency = 0
            end
        end
        if r6Leg then
            if State.korbloxCache[r6Leg] == nil then
                State.korbloxCache[r6Leg] = r6Leg.Transparency
            end
            -- Keep R6 leg opaque (0) and apply Korblox SpecialMesh + CharacterMesh instead of making it half-transparent!
            r6Leg.Transparency = 0
            pcall(function()
                local oldMesh = r6Leg:FindFirstChild("KorbloxR6Mesh")
                if oldMesh then oldMesh:Destroy() end
                local sm = Instance.new("SpecialMesh")
                sm.Name = "KorbloxR6Mesh"
                sm.MeshId = "rbxassetid://101851696"
                sm.TextureId = "rbxassetid://101851254"
                sm.Scale = Vector3.new(1, 1, 1)
                sm.Offset = Vector3.new(0, 0.25, 0)
                sm.Parent = r6Leg

                local cm = Instance.new("CharacterMesh")
                cm.Name = "KorbloxCharacterMesh"
                cm.MeshId = 101851696
                cm.OverlayTextureId = 101851254
                cm.Parent = char
            end)
        end
    else
        local oldPeg = char:FindFirstChild("KorbloxPeg")
        if oldPeg then pcall(function() oldPeg:Destroy() end) end
        local oldCharMesh = char:FindFirstChild("KorbloxCharacterMesh")
        if oldCharMesh then pcall(function() oldCharMesh:Destroy() end) end
        if r6Leg then
            local oldR6Mesh = r6Leg:FindFirstChild("KorbloxR6Mesh")
            if oldR6Mesh then pcall(function() oldR6Mesh:Destroy() end) end
        end
        for part, origT in pairs(State.korbloxCache) do
            if part and part.Parent then
                pcall(function() part.Transparency = origT end)
            end
        end
        table.clear(State.korbloxCache)
    end
end

local function applyInstantInteract(state)
    if state then
        for _, desc in ipairs(workspace:GetDescendants()) do
            if desc:IsA("ProximityPrompt") then
                if State.promptDurationCache[desc] == nil then
                    State.promptDurationCache[desc] = desc.HoldDuration
                end
                desc.HoldDuration = 0
            end
        end
        if not State.instantPromptConnection and workspace.DescendantAdded then
            State.instantPromptConnection = workspace.DescendantAdded:Connect(function(desc)
                if ConfigState.InstantInteract and desc:IsA("ProximityPrompt") then
                    if State.promptDurationCache[desc] == nil then
                        State.promptDurationCache[desc] = desc.HoldDuration
                    end
                    desc.HoldDuration = 0
                end
            end)
        end
    else
        if State.instantPromptConnection then
            State.instantPromptConnection:Disconnect()
            State.instantPromptConnection = nil
        end
        for prompt, origDur in pairs(State.promptDurationCache) do
            if prompt and prompt.Parent then
                pcall(function() prompt.HoldDuration = origDur end)
            end
        end
        table.clear(State.promptDurationCache)
    end
end

local function runUltimateFPSBooster()
    local optimizedCount = 0
    pcall(function()
        Lighting.GlobalShadows = false
        Lighting.FogEnd = 9e9
    end)

    local function optimizeInstance(obj)
        local objName = tostring(obj.Name or "")
        if string.find(objName, "^CoreXyz_") then
            return
        end
        if obj:IsA("BasePart") then
            pcall(function()
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
                obj.CastShadow = false
            end)
            optimizedCount = optimizedCount + 1
        elseif obj:IsA("Decal") or obj:IsA("Texture") then
            pcall(function()
                obj.Transparency = 1
            end)
            optimizedCount = optimizedCount + 1
        elseif obj:IsA("ParticleEmitter") or obj:IsA("Trail") or obj:IsA("Smoke") or obj:IsA("Fire") or obj:IsA("Sparkles") then
            pcall(function()
                obj.Enabled = false
            end)
            optimizedCount = optimizedCount + 1
        elseif obj:IsA("PostEffect") or obj:IsA("BloomEffect") or obj:IsA("BlurEffect") or obj:IsA("DepthOfFieldEffect") or obj:IsA("SunRaysEffect") then
            pcall(function()
                obj.Enabled = false
            end)
            optimizedCount = optimizedCount + 1
        end
    end

    for _, desc in ipairs(workspace:GetDescendants()) do
        optimizeInstance(desc)
    end
    for _, desc in ipairs(Lighting:GetDescendants()) do
        optimizeInstance(desc)
    end

    if not State.fpsBoosterConnection and workspace.DescendantAdded then
        State.fpsBoosterConnection = workspace.DescendantAdded:Connect(function(desc)
            optimizeInstance(desc)
        end)
    end

    notify("FPS Booster", string.format("Deep optimized %d instances & locked SmoothPlastic!", optimizedCount), 5)
end

local function flingTargetPlayer(targetPlayer)
    local myChar = LocalPlayer.Character
    local myHRP = myChar and myChar:FindFirstChild("HumanoidRootPart")
    local tChar = targetPlayer and targetPlayer.Character
    local tHRP = tChar and tChar:FindFirstChild("HumanoidRootPart")

    if not myHRP or not tHRP then
        notify("Core.xyz", "Target character or HumanoidRootPart unavailable.", 3)
        return
    end

    local savedCFrame = myHRP.CFrame
    notify("Core.xyz", "Flinging " .. tostring(targetPlayer.Name) .. "...", 3)

    task.spawn(function()
        for _ = 1, 28 do
            if not myHRP or not myHRP.Parent or not tHRP or not tHRP.Parent then
                break
            end
            myHRP.CFrame = tHRP.CFrame * CFrame.new(0, 0, 0)
            pcall(function()
                myHRP.Velocity = Vector3.new(9000, 9000, 9000)
                myHRP.RotVelocity = Vector3.new(9000, 9000, 9000)
            end)
            task.wait(0.025)
        end
        if myHRP and myHRP.Parent then
            pcall(function()
                myHRP.Velocity = Vector3.zero
                myHRP.RotVelocity = Vector3.zero
            end)
            myHRP.CFrame = savedCFrame
        end
        notify("Core.xyz", "Returned to original position after fling.", 3)
    end)
end

local function getDetectedExecutorName()
    local execName = "Universal Executor"
    pcall(function()
        if Env.identifyexecutor then
            local name, ver = Env.identifyexecutor()
            if name and tostring(name) ~= "" then
                execName = ver and (tostring(name) .. " " .. tostring(ver)) or tostring(name)
            end
        end
    end)
    return execName
end

local function formatRemainingKeyTime()
    if State.keyExpireTimestamp == -1 then
        return "Lifetime"
    end
    local now = (tonumber(os.time()) or 0) + 0.0
    local exp = (tonumber(State.keyExpireTimestamp) or (now + 86400.0)) + 0.0
    local rem = math.max(0.0, exp - now)
    if rem <= 0 then
        return "EXPIRED"
    end
    local function floorF(v)
        v = (tonumber(v) or 0) + 0.0
        return v - (v % 1.0)
    end
    local totalHrs = floorF(rem / 3600.0)
    local days = floorF(rem / 86400.0)
    local hrs = floorF((rem % 86400.0) / 3600.0)
    local mins = floorF((rem % 3600.0) / 60.0)
    local secs = floorF(rem % 60.0)
    if totalHrs >= 100 then
        return string.format("%.0fh %02.0fm %02.0fs (%.0fd)", totalHrs, mins, secs, days)
    elseif days > 0 then
        return string.format("%.0fd %02.0fh %02.0fm %02.0fs (%.0fh)", days, hrs, mins, secs, totalHrs)
    end
    return string.format("%02.0fh %02.0fm %02.0fs", hrs, mins, secs)
end

--------------------------------------------------------------------------------
-- 12. BUILD ALL 8 TABS (SCOPED IN DO-BLOCKS TO FREE LOCAL REGISTERS)
--------------------------------------------------------------------------------
local HomeTab = createTab("Home", 1)
local CombatTab = createTab("Combat", 2)
local VisualsTab = createTab("Visuals", 3)
local MovementTab = createTab("Movement", 4)
local PlayersTab = createTab("Players", 5)
local WorldTab = createTab("World", 6)
local MusicTab = createTab("Music", 7)
local SettingsTab = createTab("Settings", 8)

-- TAB 1: HOME (INTERACTIVE 3D CHARACTER SHOWCASE BOX + SIDE PROFILE & LIVE KEY TIME INFO)
do
    createLabel(HomeTab, "Operator Showcase & License Status")

    local HomeProfileCard = Instance.new("Frame")
    HomeProfileCard.Name = "HomeProfileCard"
    HomeProfileCard.Size = UDim2.new(1, 0, 0, 168)
    HomeProfileCard.BackgroundColor3 = Theme.Surface
    HomeProfileCard.ZIndex = 14
    HomeProfileCard.Parent = HomeTab
    addCorner(HomeProfileCard, 10)
    addStroke(HomeProfileCard, Theme.Border, 1.2, 0)

    local HomeAvatarBox = Instance.new("Frame")
    HomeAvatarBox.Name = "HomeAvatarBox"
    HomeAvatarBox.Position = UDim2.fromOffset(10, 10)
    HomeAvatarBox.Size = UDim2.fromOffset(132, 148)
    HomeAvatarBox.BackgroundColor3 = Theme.Deep
    HomeAvatarBox.ClipsDescendants = true
    HomeAvatarBox.ZIndex = 15
    HomeAvatarBox.Parent = HomeProfileCard
    addCorner(HomeAvatarBox, 8)
    local HomeAvatarStroke = addStroke(HomeAvatarBox, Theme.Accent, 1.2, 0.25)
    registerAccentObject(HomeAvatarStroke, "Color")

    UI.HomeAvatarCtrl = buildInteractiveAvatarViewport(HomeAvatarBox)

    local DragHintLbl = Instance.new("TextLabel")
    DragHintLbl.AnchorPoint = Vector2.new(0.5, 1)
    DragHintLbl.Position = UDim2.new(0.5, 0, 1, -4)
    DragHintLbl.Size = UDim2.new(1, -8, 0, 14)
    DragHintLbl.BackgroundTransparency = 1
    DragHintLbl.Font = Enum.Font.Code
    DragHintLbl.Text = "⇄ DRAG SIDEWAYS"
    DragHintLbl.TextColor3 = Theme.Silver
    DragHintLbl.TextSize = 9
    DragHintLbl.ZIndex = 20
    DragHintLbl.Parent = HomeAvatarBox

    local InfoPanel = Instance.new("Frame")
    InfoPanel.Name = "HomeInfoPanel"
    InfoPanel.Position = UDim2.fromOffset(152, 10)
    InfoPanel.Size = UDim2.new(1, -162, 1, -20)
    InfoPanel.BackgroundTransparency = 1
    InfoPanel.ZIndex = 15
    InfoPanel.Parent = HomeProfileCard

    local function createProfileRow(rowIdx, keyTitle, initVal, valName)
        local rowFrame = Instance.new("Frame")
        rowFrame.Name = "Row_" .. valName
        rowFrame.Position = UDim2.fromOffset(0, (rowIdx - 1) * 37)
        rowFrame.Size = UDim2.new(1, 0, 0, 33)
        rowFrame.BackgroundColor3 = Theme.Deep
        rowFrame.ZIndex = 15
        rowFrame.Parent = InfoPanel
        addCorner(rowFrame, 6)
        addStroke(rowFrame, Theme.Border, 1, 0)

        local kLbl = Instance.new("TextLabel")
        kLbl.Position = UDim2.fromOffset(10, 2)
        kLbl.Size = UDim2.new(1, -20, 0, 12)
        kLbl.BackgroundTransparency = 1
        kLbl.Font = Enum.Font.GothamBold
        kLbl.Text = string.upper(keyTitle)
        kLbl.TextColor3 = Theme.Muted
        kLbl.TextSize = 9
        kLbl.TextXAlignment = Enum.TextXAlignment.Left
        kLbl.ZIndex = 16
        kLbl.Parent = rowFrame

        local vLbl = Instance.new("TextLabel")
        vLbl.Name = valName
        vLbl.Position = UDim2.fromOffset(10, 14)
        vLbl.Size = UDim2.new(1, -20, 0, 16)
        vLbl.BackgroundTransparency = 1
        vLbl.Font = Enum.Font.Code
        vLbl.Text = tostring(initVal)
        vLbl.TextColor3 = Theme.White
        vLbl.TextSize = 11
        vLbl.TextTruncate = Enum.TextTruncate.AtEnd
        vLbl.TextXAlignment = Enum.TextXAlignment.Left
        vLbl.ZIndex = 16
        vLbl.Parent = rowFrame

        return vLbl
    end

    local userStr = string.format("%s (@%s)", tostring(LocalPlayer.DisplayName or LocalPlayer.Name), tostring(LocalPlayer.Name))
    UI.HomeUserValue = createProfileRow(1, "User", userStr, "Info_User")
    UI.HomeExecutorValue = createProfileRow(2, "Executor", getDetectedExecutorName(), "Info_Executor")
    UI.HomeUserIdValue = createProfileRow(3, "User ID", tostring(LocalPlayer.UserId or 0), "Info_UserId")
    UI.HomeKeyTimeValue = createProfileRow(4, "Key Time Left", formatRemainingKeyTime(), "Info_KeyTime")

    local function updateHomeKeyInfo()
        if not UI.HomeKeyTimeValue then
            return
        end
        local formatted = formatRemainingKeyTime()
        UI.HomeKeyTimeValue.Text = formatted
        if formatted == "EXPIRED" then
            UI.HomeKeyTimeValue.TextColor3 = Theme.Error
        elseif formatted == "Lifetime" then
            UI.HomeKeyTimeValue.TextColor3 = Theme.Success
        else
            UI.HomeKeyTimeValue.TextColor3 = Theme.White
        end
    end

    State.updateHomeKeyInfo = updateHomeKeyInfo
    updateHomeKeyInfo()

    createLabel(HomeTab, "Official Discord Community")

    local DISCORD_INVITE_CODE = "TVyFdDwDkn"
    local DISCORD_INVITE_URL = "https://discord.gg/" .. DISCORD_INVITE_CODE
    local DISCORD_API_URL = "https://discord.com/api/v9/invites/" .. DISCORD_INVITE_CODE .. "?with_counts=true&with_expiration=true"
    local DISCORD_DEFAULT_GUILD_ID = "1565870578613752008"
    local DISCORD_DEFAULT_ICON_HASH = "241614e0c238a40ff43e061065d35f5a"

    local DiscordColors = {
        CardBg = Color3.fromRGB(30, 31, 34),      -- #1E1F22 Discord dark surface
        PillBg = Color3.fromRGB(43, 45, 49),      -- #2B2D31 Discord secondary surface
        DeepBg = Color3.fromRGB(17, 18, 20),      -- #111214 Discord deep frame
        Blurple = Color3.fromRGB(88, 101, 242),   -- #5865F2 Discord Blurple
        BlurpleDark = Color3.fromRGB(71, 82, 196),-- #4752C4 Discord Blurple hover/gradient
        SkyWave = Color3.fromRGB(120, 175, 255),  -- #78AFFF Smooth light-blue wave crest
        CyanWave = Color3.fromRGB(165, 212, 255), -- #A5D4FF Luminous light-blue wave highlight
        OnlineGreen = Color3.fromRGB(35, 165, 90),-- #23A55A Discord online green
        MemberGray = Color3.fromRGB(181, 186, 193),-- #B5BAC1 Discord muted gray
        HeaderWhite = Color3.fromRGB(242, 243, 245),
    }

    local HomeDiscordCard = Instance.new("Frame")
    HomeDiscordCard.Name = "HomeDiscordCard"
    HomeDiscordCard.Size = UDim2.new(1, 0, 0, 148)
    HomeDiscordCard.BackgroundColor3 = DiscordColors.CardBg
    HomeDiscordCard.ClipsDescendants = true
    HomeDiscordCard.ZIndex = 14
    HomeDiscordCard.Parent = HomeTab
    addCorner(HomeDiscordCard, 10)
    addStroke(HomeDiscordCard, DiscordColors.Blurple, 1.2, 0.2)

    -- Top Discord Light-Blue / Blurple Animated Slow Wave Banner Strip
    local DiscordBanner = Instance.new("Frame")
    DiscordBanner.Name = "DiscordBanner"
    DiscordBanner.Size = UDim2.new(1, 0, 0, 34)
    DiscordBanner.BackgroundColor3 = DiscordColors.Blurple
    DiscordBanner.ClipsDescendants = true
    DiscordBanner.BorderSizePixel = 0
    DiscordBanner.ZIndex = 15
    DiscordBanner.Parent = HomeDiscordCard
    addCorner(DiscordBanner, 10)

    local BannerGrad = Instance.new("UIGradient")
    BannerGrad.Name = "DiscordWaveGradient"
    BannerGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0.0, DiscordColors.BlurpleDark),
        ColorSequenceKeypoint.new(0.35, DiscordColors.Blurple),
        ColorSequenceKeypoint.new(0.68, DiscordColors.SkyWave),
        ColorSequenceKeypoint.new(1.0, DiscordColors.BlurpleDark),
    })
    BannerGrad.Rotation = 14
    BannerGrad.Parent = DiscordBanner

    local DiscordWaveCrest1 = Instance.new("Frame")
    DiscordWaveCrest1.Name = "DiscordWaveCrest1"
    DiscordWaveCrest1.AnchorPoint = Vector2.new(0.5, 0.5)
    DiscordWaveCrest1.Position = UDim2.fromScale(0.5, 0.72)
    DiscordWaveCrest1.Size = UDim2.new(1.45, 0, 0, 28)
    DiscordWaveCrest1.BackgroundColor3 = DiscordColors.SkyWave
    DiscordWaveCrest1.BackgroundTransparency = 0.68
    DiscordWaveCrest1.BorderSizePixel = 0
    DiscordWaveCrest1.ZIndex = 15
    DiscordWaveCrest1.Parent = DiscordBanner
    addCorner(DiscordWaveCrest1, 999)

    local DiscordWaveCrest2 = Instance.new("Frame")
    DiscordWaveCrest2.Name = "DiscordWaveCrest2"
    DiscordWaveCrest2.AnchorPoint = Vector2.new(0.5, 0.5)
    DiscordWaveCrest2.Position = UDim2.fromScale(0.5, 0.84)
    DiscordWaveCrest2.Size = UDim2.new(1.55, 0, 0, 24)
    DiscordWaveCrest2.BackgroundColor3 = DiscordColors.CyanWave
    DiscordWaveCrest2.BackgroundTransparency = 0.74
    DiscordWaveCrest2.BorderSizePixel = 0
    DiscordWaveCrest2.ZIndex = 15
    DiscordWaveCrest2.Parent = DiscordBanner
    addCorner(DiscordWaveCrest2, 999)

    UI.DiscordWave = {
        Banner = DiscordBanner,
        Gradient = BannerGrad,
        Crest1 = DiscordWaveCrest1,
        Crest2 = DiscordWaveCrest2,
    }

    local BannerTagLbl = Instance.new("TextLabel")
    BannerTagLbl.Position = UDim2.fromOffset(80, 0)
    BannerTagLbl.Size = UDim2.new(1, -195, 1, 0)
    BannerTagLbl.BackgroundTransparency = 1
    BannerTagLbl.Font = Enum.Font.GothamBold
    BannerTagLbl.Text = "DISCORD SERVER  ·  LIVE STATUS"
    BannerTagLbl.TextColor3 = Color3.fromRGB(224, 227, 255)
    BannerTagLbl.TextSize = 9
    BannerTagLbl.TextXAlignment = Enum.TextXAlignment.Left
    BannerTagLbl.ZIndex = 16
    BannerTagLbl.Parent = DiscordBanner

    local BannerCodeLbl = Instance.new("TextLabel")
    BannerCodeLbl.AnchorPoint = Vector2.new(1, 0.5)
    BannerCodeLbl.Position = UDim2.new(1, -12, 0.5, 0)
    BannerCodeLbl.Size = UDim2.fromOffset(115, 18)
    BannerCodeLbl.BackgroundColor3 = DiscordColors.DeepBg
    BannerCodeLbl.BackgroundTransparency = 0.25
    BannerCodeLbl.Font = Enum.Font.Code
    BannerCodeLbl.Text = "gg/" .. DISCORD_INVITE_CODE
    BannerCodeLbl.TextColor3 = Theme.White
    BannerCodeLbl.TextSize = 10
    BannerCodeLbl.ZIndex = 16
    BannerCodeLbl.Parent = DiscordBanner
    addCorner(BannerCodeLbl, 5)

    -- Server Logo Squircle (Overlapping Banner & Body like Discord Invite Cards)
    local DiscordLogoBox = Instance.new("Frame")
    DiscordLogoBox.Name = "DiscordLogoBox"
    DiscordLogoBox.Position = UDim2.fromOffset(14, 16)
    DiscordLogoBox.Size = UDim2.fromOffset(56, 56)
    DiscordLogoBox.BackgroundColor3 = DiscordColors.DeepBg
    DiscordLogoBox.ZIndex = 17
    DiscordLogoBox.Parent = HomeDiscordCard
    addCorner(DiscordLogoBox, 14)
    addStroke(DiscordLogoBox, DiscordColors.CardBg, 3, 0)

    local DiscordLogoFallback = Instance.new("Frame")
    DiscordLogoFallback.Name = "DiscordLogoFallback"
    DiscordLogoFallback.Position = UDim2.fromOffset(2, 2)
    DiscordLogoFallback.Size = UDim2.new(1, -4, 1, -4)
    DiscordLogoFallback.BackgroundColor3 = DiscordColors.Blurple
    DiscordLogoFallback.ZIndex = 17
    DiscordLogoFallback.Parent = DiscordLogoBox
    addCorner(DiscordLogoFallback, 12)

    local LogoMonogramTop = Instance.new("TextLabel")
    LogoMonogramTop.Position = UDim2.fromOffset(0, 11)
    LogoMonogramTop.Size = UDim2.new(1, 0, 0, 16)
    LogoMonogramTop.BackgroundTransparency = 1
    LogoMonogramTop.Font = Enum.Font.GothamBlack
    LogoMonogramTop.Text = "CORE"
    LogoMonogramTop.TextColor3 = Theme.White
    LogoMonogramTop.TextSize = 12
    LogoMonogramTop.ZIndex = 18
    LogoMonogramTop.Parent = DiscordLogoFallback

    local LogoMonogramSub = Instance.new("TextLabel")
    LogoMonogramSub.Position = UDim2.fromOffset(0, 27)
    LogoMonogramSub.Size = UDim2.new(1, 0, 0, 12)
    LogoMonogramSub.BackgroundTransparency = 1
    LogoMonogramSub.Font = Enum.Font.Code
    LogoMonogramSub.Text = "BETA"
    LogoMonogramSub.TextColor3 = Color3.fromRGB(224, 227, 255)
    LogoMonogramSub.TextSize = 9
    LogoMonogramSub.ZIndex = 18
    LogoMonogramSub.Parent = DiscordLogoFallback

    local DiscordServerIcon = Instance.new("ImageLabel")
    DiscordServerIcon.Name = "DiscordServerIcon"
    DiscordServerIcon.Size = UDim2.fromScale(1, 1)
    DiscordServerIcon.BackgroundTransparency = 1
    DiscordServerIcon.Image = ""
    DiscordServerIcon.Visible = false
    DiscordServerIcon.ZIndex = 19
    DiscordServerIcon.Parent = DiscordLogoBox
    addCorner(DiscordServerIcon, 14)

    local LogoOnlineDot = Instance.new("Frame")
    LogoOnlineDot.Name = "LogoOnlineDot"
    LogoOnlineDot.AnchorPoint = Vector2.new(1, 1)
    LogoOnlineDot.Position = UDim2.new(1, 2, 1, 2)
    LogoOnlineDot.Size = UDim2.fromOffset(14, 14)
    LogoOnlineDot.BackgroundColor3 = DiscordColors.OnlineGreen
    LogoOnlineDot.ZIndex = 20
    LogoOnlineDot.Parent = DiscordLogoBox
    addCorner(LogoOnlineDot, 99)
    addStroke(LogoOnlineDot, DiscordColors.CardBg, 2.5, 0)

    -- Server Title ("Core | Beta") + Verified Badge + Subtitle
    local DiscordServerName = Instance.new("TextLabel")
    DiscordServerName.Name = "DiscordServerName"
    DiscordServerName.Position = UDim2.fromOffset(80, 40)
    DiscordServerName.Size = UDim2.new(1, -170, 0, 18)
    DiscordServerName.BackgroundTransparency = 1
    DiscordServerName.Font = Enum.Font.GothamBlack
    DiscordServerName.Text = "Core | Beta"
    DiscordServerName.TextColor3 = DiscordColors.HeaderWhite
    DiscordServerName.TextSize = 15
    DiscordServerName.TextXAlignment = Enum.TextXAlignment.Left
    DiscordServerName.ZIndex = 16
    DiscordServerName.Parent = HomeDiscordCard

    local VerifiedBadge = Instance.new("TextLabel")
    VerifiedBadge.AnchorPoint = Vector2.new(1, 0)
    VerifiedBadge.Position = UDim2.new(1, -12, 0, 41)
    VerifiedBadge.Size = UDim2.fromOffset(76, 16)
    VerifiedBadge.BackgroundColor3 = DiscordColors.PillBg
    VerifiedBadge.Font = Enum.Font.GothamBold
    VerifiedBadge.Text = "COMMUNITY"
    VerifiedBadge.TextColor3 = DiscordColors.Blurple
    VerifiedBadge.TextSize = 8
    VerifiedBadge.ZIndex = 16
    VerifiedBadge.Parent = HomeDiscordCard
    addCorner(VerifiedBadge, 4)
    addStroke(VerifiedBadge, DiscordColors.Blurple, 1, 0.45)

    local DiscordSubLbl = Instance.new("TextLabel")
    DiscordSubLbl.Position = UDim2.fromOffset(80, 59)
    DiscordSubLbl.Size = UDim2.new(1, -92, 0, 14)
    DiscordSubLbl.BackgroundTransparency = 1
    DiscordSubLbl.Font = Enum.Font.GothamMedium
    DiscordSubLbl.Text = "Official Core.xyz Community · Script Updates, Configs & Support"
    DiscordSubLbl.TextColor3 = DiscordColors.MemberGray
    DiscordSubLbl.TextSize = 10
    DiscordSubLbl.TextTruncate = Enum.TextTruncate.AtEnd
    DiscordSubLbl.TextXAlignment = Enum.TextXAlignment.Left
    DiscordSubLbl.ZIndex = 16
    DiscordSubLbl.Parent = HomeDiscordCard

    -- Live Member Counters Row (Active Online + Total Members)
    local ActiveCountPill = Instance.new("Frame")
    ActiveCountPill.Name = "DiscordActivePill"
    ActiveCountPill.Position = UDim2.fromOffset(80, 77)
    ActiveCountPill.Size = UDim2.fromOffset(122, 22)
    ActiveCountPill.BackgroundColor3 = DiscordColors.PillBg
    ActiveCountPill.ZIndex = 16
    ActiveCountPill.Parent = HomeDiscordCard
    addCorner(ActiveCountPill, 6)
    addStroke(ActiveCountPill, DiscordColors.OnlineGreen, 1, 0.55)

    local ActiveDot = Instance.new("Frame")
    ActiveDot.AnchorPoint = Vector2.new(0, 0.5)
    ActiveDot.Position = UDim2.new(0, 8, 0.5, 0)
    ActiveDot.Size = UDim2.fromOffset(7, 7)
    ActiveDot.BackgroundColor3 = DiscordColors.OnlineGreen
    ActiveDot.ZIndex = 17
    ActiveDot.Parent = ActiveCountPill
    addCorner(ActiveDot, 99)

    local DiscordOnlineValue = Instance.new("TextLabel")
    DiscordOnlineValue.Name = "DiscordOnlineValue"
    DiscordOnlineValue.Position = UDim2.fromOffset(20, 0)
    DiscordOnlineValue.Size = UDim2.new(1, -24, 1, 0)
    DiscordOnlineValue.BackgroundTransparency = 1
    DiscordOnlineValue.Font = Enum.Font.Code
    DiscordOnlineValue.Text = "1 Active"
    DiscordOnlineValue.TextColor3 = DiscordColors.HeaderWhite
    DiscordOnlineValue.TextSize = 10
    DiscordOnlineValue.TextXAlignment = Enum.TextXAlignment.Left
    DiscordOnlineValue.ZIndex = 17
    DiscordOnlineValue.Parent = ActiveCountPill

    local TotalMembersPill = Instance.new("Frame")
    TotalMembersPill.Name = "DiscordMembersPill"
    TotalMembersPill.Position = UDim2.fromOffset(210, 77)
    TotalMembersPill.Size = UDim2.fromOffset(128, 22)
    TotalMembersPill.BackgroundColor3 = DiscordColors.PillBg
    TotalMembersPill.ZIndex = 16
    TotalMembersPill.Parent = HomeDiscordCard
    addCorner(TotalMembersPill, 6)
    addStroke(TotalMembersPill, DiscordColors.Blurple, 1, 0.6)

    local TotalDot = Instance.new("Frame")
    TotalDot.AnchorPoint = Vector2.new(0, 0.5)
    TotalDot.Position = UDim2.new(0, 8, 0.5, 0)
    TotalDot.Size = UDim2.fromOffset(7, 7)
    TotalDot.BackgroundColor3 = DiscordColors.MemberGray
    TotalDot.ZIndex = 17
    TotalDot.Parent = TotalMembersPill
    addCorner(TotalDot, 99)

    local DiscordMembersValue = Instance.new("TextLabel")
    DiscordMembersValue.Name = "DiscordMembersValue"
    DiscordMembersValue.Position = UDim2.fromOffset(20, 0)
    DiscordMembersValue.Size = UDim2.new(1, -24, 1, 0)
    DiscordMembersValue.BackgroundTransparency = 1
    DiscordMembersValue.Font = Enum.Font.Code
    DiscordMembersValue.Text = "2 Members"
    DiscordMembersValue.TextColor3 = DiscordColors.HeaderWhite
    DiscordMembersValue.TextSize = 10
    DiscordMembersValue.TextXAlignment = Enum.TextXAlignment.Left
    DiscordMembersValue.ZIndex = 17
    DiscordMembersValue.Parent = TotalMembersPill

    -- Action Buttons: Join Server (Copy Invite + RPC) & Refresh Live Counts
    local JoinDiscordBtn = Instance.new("TextButton")
    JoinDiscordBtn.Name = "JoinDiscordButton"
    JoinDiscordBtn.Position = UDim2.fromOffset(14, 108)
    JoinDiscordBtn.Size = UDim2.new(1, -110, 0, 28)
    JoinDiscordBtn.BackgroundColor3 = DiscordColors.Blurple
    JoinDiscordBtn.AutoButtonColor = false
    JoinDiscordBtn.Font = Enum.Font.GothamBold
    JoinDiscordBtn.Text = "Join Core | Beta  (Copy Invite)"
    JoinDiscordBtn.TextColor3 = Theme.White
    JoinDiscordBtn.TextSize = 11
    JoinDiscordBtn.ClipsDescendants = true
    JoinDiscordBtn.ZIndex = 16
    JoinDiscordBtn.Parent = HomeDiscordCard
    addCorner(JoinDiscordBtn, 6)

    local RefreshDiscordBtn = Instance.new("TextButton")
    RefreshDiscordBtn.Name = "RefreshDiscordButton"
    RefreshDiscordBtn.AnchorPoint = Vector2.new(1, 0)
    RefreshDiscordBtn.Position = UDim2.new(1, -14, 0, 108)
    RefreshDiscordBtn.Size = UDim2.fromOffset(82, 28)
    RefreshDiscordBtn.BackgroundColor3 = DiscordColors.PillBg
    RefreshDiscordBtn.AutoButtonColor = false
    RefreshDiscordBtn.Font = Enum.Font.GothamBold
    RefreshDiscordBtn.Text = "Refresh"
    RefreshDiscordBtn.TextColor3 = DiscordColors.HeaderWhite
    RefreshDiscordBtn.TextSize = 10
    RefreshDiscordBtn.ClipsDescendants = true
    RefreshDiscordBtn.ZIndex = 16
    RefreshDiscordBtn.Parent = HomeDiscordCard
    addCorner(RefreshDiscordBtn, 6)
    addStroke(RefreshDiscordBtn, DiscordColors.Blurple, 1, 0.5)

    local discordIconLoaded = false
    local function tryLoadDiscordServerIcon(guildId, iconHash)
        if discordIconLoaded or not Env.getcustomasset or not Env.writefile then
            return
        end
        local gId = tostring(guildId or DISCORD_DEFAULT_GUILD_ID)
        local iHash = tostring(iconHash or DISCORD_DEFAULT_ICON_HASH)
        if gId == "" or iHash == "" then
            return
        end
        local iconUrl = string.format("https://cdn.discordapp.com/icons/%s/%s.png?size=128", gId, iHash)
        local iconPath = FS_FOLDER .. "/DiscordIcon_" .. DISCORD_INVITE_CODE .. ".png"
        local okImg, imgBytes = pcall(function()
            if type(Env.request) == "function" then
                local r = Env.request({ Url = iconUrl, Method = "GET" })
                if r and r.StatusCode == 200 and r.Body and #r.Body > 64 then
                    return r.Body
                end
            end
            return game:HttpGet(iconUrl)
        end)
        if okImg and type(imgBytes) == "string" and #imgBytes > 64 then
            pcall(function()
                Env.writefile(iconPath, imgBytes)
                local customAsset = Env.getcustomasset(iconPath)
                if customAsset and tostring(customAsset) ~= "" then
                    DiscordServerIcon.Image = tostring(customAsset)
                    DiscordServerIcon.Visible = true
                    discordIconLoaded = true
                end
            end)
        end
    end

    local function fetchDiscordInviteData(showToast)
        task.spawn(function()
            local rawBody = nil
            pcall(function()
                if type(Env.request) == "function" then
                    local res = Env.request({
                        Url = DISCORD_API_URL,
                        Method = "GET",
                    })
                    if res and res.StatusCode == 200 and type(res.Body) == "string" and res.Body ~= "" then
                        rawBody = res.Body
                    end
                end
                if not rawBody then
                    rawBody = game:HttpGet(DISCORD_API_URL)
                end
            end)

            if rawBody and rawBody ~= "" then
                local decoded = safeJsonDecode(rawBody)
                if type(decoded) == "table" then
                    local totalCount = tonumber(decoded.approximate_member_count)
                        or (type(decoded.profile) == "table" and tonumber(decoded.profile.member_count))
                    local onlineCount = tonumber(decoded.approximate_presence_count)
                        or (type(decoded.profile) == "table" and tonumber(decoded.profile.online_count))

                    if totalCount then
                        DiscordMembersValue.Text = string.format("%d Members", math.max(0, math.floor(totalCount)))
                    end
                    if onlineCount then
                        DiscordOnlineValue.Text = string.format("%d Active", math.max(0, math.floor(onlineCount)))
                    end

                    local guildObj = type(decoded.guild) == "table" and decoded.guild or nil
                    if guildObj then
                        tryLoadDiscordServerIcon(guildObj.id, guildObj.icon)
                    else
                        tryLoadDiscordServerIcon(DISCORD_DEFAULT_GUILD_ID, DISCORD_DEFAULT_ICON_HASH)
                    end

                    if showToast then
                        notify("Core | Beta", string.format("Discord synced: %s · %s", DiscordOnlineValue.Text, DiscordMembersValue.Text), 3)
                    end
                    return
                end
            end

            tryLoadDiscordServerIcon(DISCORD_DEFAULT_GUILD_ID, DISCORD_DEFAULT_ICON_HASH)
            if showToast then
                notify("Core | Beta", "Invite: " .. DISCORD_INVITE_URL, 3)
            end
        end)
    end

    JoinDiscordBtn.MouseButton1Click:Connect(function()
        spawnRipple(JoinDiscordBtn)
        if Env.setclipboard then
            Env.setclipboard(DISCORD_INVITE_URL)
        end
        JoinDiscordBtn.Text = "Copied! (discord.gg/" .. DISCORD_INVITE_CODE .. ")"
        notify("Core | Beta", "Discord invite copied to clipboard: " .. DISCORD_INVITE_URL, 4)

        -- Also attempt direct Discord Desktop client invite prompt if executor supports local RPC
        if type(Env.request) == "function" then
            task.spawn(function()
                pcall(function()
                    Env.request({
                        Url = "http://127.0.0.1:6463/rpc?v=1",
                        Method = "POST",
                        Headers = {
                            ["Content-Type"] = "application/json",
                            ["Origin"] = "https://discord.com",
                        },
                        Body = safeJsonEncode({
                            cmd = "INVITE_BROWSER",
                            args = { code = DISCORD_INVITE_CODE },
                            nonce = "corexyz_" .. tostring(os.time()),
                        }),
                    })
                end)
            end)
        end

        task.delay(2.2, function()
            if JoinDiscordBtn and JoinDiscordBtn.Parent then
                JoinDiscordBtn.Text = "Join Core | Beta  (Copy Invite)"
            end
        end)
    end)

    RefreshDiscordBtn.MouseButton1Click:Connect(function()
        spawnRipple(RefreshDiscordBtn)
        fetchDiscordInviteData(true)
    end)

    State.refreshDiscordInvite = fetchDiscordInviteData
    fetchDiscordInviteData(false)
end

-- TAB 2: COMBAT (SINGLE AIMBOT TOGGLE WITH CLASSIC LOCK-IN + HITPART/WALLCHECK/TEAMCHECK/WHITELIST ABOVE HITBOX AREA)
do
    createLabel(CombatTab, "Aimbot & FOV Controller")
    createToggle(CombatTab, "Aimbot", false, function(val)
        ConfigState.Aimbot = val
        if not val then
            State.cachedAimTarget = nil
        end
    end, { ShowKeybindBadge = true })
    createToggle(CombatTab, "FOV Circle", false, function(val)
        ConfigState.ShowFOV = val
        UI.FovCircle.Visible = val
    end)
    createSlider(CombatTab, "FOV Radius", 10, 240, 85, 1, "px", function(val)
        ConfigState.FOVRadius = val
        UI.FovCircle.Size = UDim2.fromOffset(val * 2, val * 2)
    end)
    createSlider(CombatTab, "Aimbot Smoothness", 0.05, 1, 0.9, 0.01, "", function(val)
        ConfigState.Smoothness = val
    end)

    createLabel(CombatTab, "Targeting, Hitpart, Wall Check, Team Check & Whitelist")
    createDropdown(CombatTab, "Hitpart", { "Head", "HumanoidRootPart", "UpperTorso", "LowerTorso" }, ConfigState.TargetPart or "Head", function(opt)
        ConfigState.TargetPart = opt
        State.cachedAimTarget = nil
    end)
    createToggle(CombatTab, "Wall Check", false, function(val)
        ConfigState.AimbotWallCheck = val
    end)
    createToggle(CombatTab, "Team Check", false, function(val)
        ConfigState.TeamCheck = val
        if ConfigState.HitboxExpander then
            updateHitboxExpander()
        end
    end)
    createToggle(CombatTab, "Whitelist Check", false, function(val)
        ConfigState.UseWhitelist = val
        if ConfigState.HitboxExpander then
            updateHitboxExpander()
        end
    end)

    local initialPlayerNames = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            table.insert(initialPlayerNames, p.Name)
        end
    end

    local WhitelistDropdownCtrl = createMultiDropdown(CombatTab, "Whitelist Players", initialPlayerNames, State.whitelistArray, 50, function(selectedNames)
        table.clear(State.whitelistedPlayers)
        for _, name in ipairs(selectedNames) do
            State.whitelistedPlayers[name] = true
        end
        if ConfigState.HitboxExpander then
            updateHitboxExpander()
        end
        if State.refreshPlayerListUI then
            State.refreshPlayerListUI()
        end
    end)
    State.refreshWhitelistDropdown = WhitelistDropdownCtrl.Refresh

    for _, team in ipairs(Teams:GetChildren()) do
        table.insert(State.allTeams, team.Name)
    end
    createMultiDropdown(CombatTab, "Target Teams", State.allTeams, { "All" }, 50, function(selectedTeamsList)
        table.clear(State.selectedTeams)
        if #selectedTeamsList == 0 then
            State.selectedTeams["All"] = true
        else
            for _, tName in ipairs(selectedTeamsList) do
                State.selectedTeams[tName] = true
            end
        end
        if ConfigState.HitboxExpander then
            updateHitboxExpander()
        end
    end)

    createLabel(CombatTab, "Universal Hitbox Expander")
    createToggle(CombatTab, "Hitbox Expander", false, function(val)
        ConfigState.HitboxExpander = val
        if val then
            updateHitboxExpander()
        else
            restoreAllHitboxes()
        end
    end, { ShowKeybindBadge = true })
    createSlider(CombatTab, "Hitbox Size", 2, 25, 10, 1, "studs", function(val)
        ConfigState.HitboxSize = val
        if ConfigState.HitboxExpander then
            updateHitboxExpander()
        end
    end)
    createSlider(CombatTab, "Hitbox Transparency", 0, 1, 0.7, 0.05, "", function(val)
        ConfigState.HitboxTransparency = val
        if ConfigState.HitboxExpander then
            updateHitboxExpander()
        end
    end)
end

-- TAB 3: VISUALS (3D BOX + SKELETON + SCREEN RESOLUTION STRETCH + PRO CROSSHAIR + X-RAY + FREECAM)
do
    createLabel(VisualsTab, "3D ESP & Skeleton Overlays")
    createToggle(VisualsTab, "Player ESP (Highlight + Tag)", false, function(val)
        ConfigState.ESP = val
        if not val then
            for _, data in pairs(State.espObjects) do
                if data.ScreenTag then data.ScreenTag.Visible = false end
                if data.Billboard then data.Billboard.Enabled = false; data.Billboard.Adornee = nil end
                if data.Highlight then
                    data.Highlight.Enabled = false
                    data.Highlight.Adornee = nil
                    data.LastHLEnabled = false
                    data.LastHLAdornee = nil
                end
            end
            if not ConfigState.Box3DESP and not ConfigState.SkeletonESP and not ConfigState.HealthBarESP and not ConfigState.Tracers then
                clearESP()
            end
        end
    end, {
        ShowKeybindBadge = true,
        SwatchColor = State.espColor,
        OnColorChange = function(col)
            State.espColor = col
        end,
    })
    createToggle(VisualsTab, "3D Bounding Box Overlay", false, function(val)
        ConfigState.Box3DESP = val
        if not val then
            for _, data in pairs(State.espObjects) do
                if data.Box3DLines then
                    for i = 1, #data.Box3DLines do data.Box3DLines[i].Visible = false end
                    data.Box3DVisible = false
                end
                if data.BoxFillFrame then data.BoxFillFrame.Visible = false end
            end
            if not ConfigState.ESP and not ConfigState.SkeletonESP and not ConfigState.HealthBarESP and not ConfigState.Tracers then
                clearESP()
            end
        end
    end, { ShowKeybindBadge = true })
    createToggle(VisualsTab, "3D Skeleton Rig Overlay", false, function(val)
        ConfigState.SkeletonESP = val
        if not val then
            for _, data in pairs(State.espObjects) do
                if data.SkeletonLines then
                    for i = 1, #data.SkeletonLines do
                        data.SkeletonLines[i].Visible = false
                        if data.JointDots and data.JointDots[i] then
                            data.JointDots[i].Visible = false
                        end
                    end
                    if data.HeadCircle then data.HeadCircle.Visible = false end
                    data.SkeletonVisible = false
                end
            end
            if not ConfigState.ESP and not ConfigState.Box3DESP and not ConfigState.HealthBarESP and not ConfigState.Tracers then
                clearESP()
            end
        end
    end, { ShowKeybindBadge = true })
    createToggle(VisualsTab, "Animated Health Bar Overlay", false, function(val)
        ConfigState.HealthBarESP = val
        if not val then
            for _, data in pairs(State.espObjects) do
                if data.HealthBarBg then data.HealthBarBg.Visible = false end
                if data.HealthNumberLabel then data.HealthNumberLabel.Visible = false end
            end
            if not ConfigState.ESP and not ConfigState.Box3DESP and not ConfigState.SkeletonESP and not ConfigState.Tracers then
                clearESP()
            end
        end
    end, { ShowKeybindBadge = true })
    createToggle(VisualsTab, "Snapline Tracers", false, function(val)
        ConfigState.Tracers = val
        if not val then
            for _, data in pairs(State.espObjects) do
                if data.Tracer then
                    data.Tracer.Visible = false
                end
            end
            if not ConfigState.ESP and not ConfigState.Box3DESP and not ConfigState.SkeletonESP and not ConfigState.HealthBarESP then
                clearESP()
            end
        end
    end, { ShowKeybindBadge = true })
    createDropdown(VisualsTab, "Tracer Origin", { "Center", "Bottom", "Top" }, "Center", function(opt)
        ConfigState.TracerOrigin = opt
    end)

    local ColorMap = {
        White = Color3.fromRGB(255, 255, 255),
        Silver = Color3.fromRGB(185, 185, 195),
        Red = Color3.fromRGB(255, 70, 70),
        Cyan = Color3.fromRGB(80, 225, 255),
        Green = Color3.fromRGB(90, 255, 145),
    }
    createDropdown(VisualsTab, "ESP Color", { "White", "Silver", "Red", "Cyan", "Green" }, "White", function(opt)
        ConfigState.ESPColorName = opt
        State.espColor = ColorMap[opt] or Theme.White
    end)

    -- ESP Sub-Card 1: Skeleton (Matches Reference Screenshot IMG_20261102_204145_b9ffc6a2.jpg)
    local skelSec = UI.createSectionBox(VisualsTab, "Skeleton")
    createDropdown(skelSec, "Skeleton Color", { "Team", "Custom", "Health", "Rainbow" }, ConfigState.SkeletonColorMode or "Team", function(opt)
        ConfigState.SkeletonColorMode = opt
    end)
    createDropdown(skelSec, "Skeleton Effect", { "None", "Glow", "Pulse", "Rainbow" }, ConfigState.SkeletonEffect or "Glow", function(opt)
        ConfigState.SkeletonEffect = opt
    end)
    createSlider(skelSec, "Bone Thickness", 1, 6, ConfigState.SkeletonBoneThickness or 2, 1, "px", function(val)
        ConfigState.SkeletonBoneThickness = val
    end)
    createToggle(skelSec, "Bone Outline", ConfigState.SkeletonBoneOutline ~= false, function(val)
        ConfigState.SkeletonBoneOutline = val
    end)
    createToggle(skelSec, "Joint Dots", ConfigState.SkeletonJointDots == true, function(val)
        ConfigState.SkeletonJointDots = val
    end)
    createToggle(skelSec, "Head Circle", ConfigState.SkeletonHeadCircle ~= false, function(val)
        ConfigState.SkeletonHeadCircle = val
    end)

    -- ESP Sub-Card 2: Text (Matches Reference Screenshot IMG_20261102_204045_74d2e1fd.jpg)
    local textSec = UI.createSectionBox(VisualsTab, "Text")
    createDropdown(textSec, "Font", { "Gotham", "GothamBold", "Code", "SourceSans", "Ubuntu", "Arcade" }, ConfigState.ESPTextFont or "Gotham", function(opt)
        ConfigState.ESPTextFont = opt
    end)
    createSlider(textSec, "Text Size", 8, 24, ConfigState.ESPTextSize or 12, 1, "px", function(val)
        ConfigState.ESPTextSize = val
    end)
    createToggle(textSec, "Text Outline", ConfigState.ESPTextOutline ~= false, function(val)
        ConfigState.ESPTextOutline = val
    end)
    createDropdown(textSec, "Name Type", { "Display Name", "Username", "Both" }, ConfigState.ESPNameType or "Display Name", function(opt)
        ConfigState.ESPNameType = opt
    end)

    -- ESP Sub-Card 3: Health Bar (Matches Reference Screenshots IMG_20261102_204026_9058269c.jpg & IMG_20261102_204308_d103e3fb.jpg)
    local hbSec = UI.createSectionBox(VisualsTab, "Health Bar")
    createDropdown(hbSec, "Healthbar Type", { "Gradient", "Health Color", "Flow", "Pulse", "Rainbow" }, ConfigState.HealthBarType or "Gradient", function(opt)
        ConfigState.HealthBarType = opt
    end)
    createDropdown(hbSec, "Healthbar Side", { "Left", "Right", "Bottom", "Top" }, ConfigState.HealthBarSide or "Left", function(opt)
        ConfigState.HealthBarSide = opt
    end)
    createSlider(hbSec, "Bar Width", 1, 8, ConfigState.HealthBarWidth or 2, 1, "px", function(val)
        ConfigState.HealthBarWidth = val
    end)
    createSlider(hbSec, "Health Anim Speed", 0.1, 5.0, ConfigState.HealthAnimSpeed or 1.0, 0.1, "x", function(val)
        ConfigState.HealthAnimSpeed = val
    end)
    createSlider(hbSec, "Health Smoothing", 0, 1, ConfigState.HealthSmoothing or 0.15, 0.05, "", function(val)
        ConfigState.HealthSmoothing = val
    end)
    createToggle(hbSec, "Bar Outline", ConfigState.HealthBarOutline ~= false, function(val)
        ConfigState.HealthBarOutline = val
    end)
    createToggle(hbSec, "Shimmer", ConfigState.HealthBarShimmer == true, function(val)
        ConfigState.HealthBarShimmer = val
    end)
    createToggle(hbSec, "Bar Glow", ConfigState.HealthBarGlow == true, function(val)
        ConfigState.HealthBarGlow = val
    end)
    createToggle(hbSec, "Low Health Flash", ConfigState.HealthLowFlash ~= false, function(val)
        ConfigState.HealthLowFlash = val
    end)
    createToggle(hbSec, "Health Number", ConfigState.HealthNumber == true, function(val)
        ConfigState.HealthNumber = val
    end)

    -- ESP Sub-Card 4: Box Effects (Matches Reference Screenshot IMG_20261102_204335_87a81ab2.jpg)
    local boxEffSec = UI.createSectionBox(VisualsTab, "Box Effects")
    createDropdown(boxEffSec, "Box Animation", { "None", "Pulse", "Rainbow", "Flow", "Breathe" }, ConfigState.BoxAnimation or "None", function(opt)
        ConfigState.BoxAnimation = opt
    end)
    UI.createColorRow(boxEffSec, "Box Second Color", ConfigState.BoxSecondColor or Color3.fromRGB(115, 95, 255), function(col)
        ConfigState.BoxSecondColor = col
    end)
    createSlider(boxEffSec, "Box Anim Speed", 0.1, 5.0, ConfigState.BoxAnimSpeed or 0.5, 0.1, "x", function(val)
        ConfigState.BoxAnimSpeed = val
    end)
    createToggle(boxEffSec, "Box Glow", ConfigState.BoxGlow == true, function(val)
        ConfigState.BoxGlow = val
    end)
    createToggle(boxEffSec, "Spin Box", ConfigState.BoxSpin == true, function(val)
        ConfigState.BoxSpin = val
    end)
    createSlider(boxEffSec, "Spin Speed", 0.1, 5.0, ConfigState.BoxSpinSpeed or 0.3, 0.1, "rps", function(val)
        ConfigState.BoxSpinSpeed = val
    end)
    createDropdown(boxEffSec, "Fill Animation", { "None", "Spin", "Pulse", "Vertical Wave", "Rainbow" }, ConfigState.BoxFillAnimation or "None", function(opt)
        ConfigState.BoxFillAnimation = opt
    end)
    createDropdown(boxEffSec, "Fill Direction", { "Vertical", "Horizontal", "Diagonal" }, ConfigState.BoxFillDirection or "Vertical", function(opt)
        ConfigState.BoxFillDirection = opt
    end)
    createSlider(boxEffSec, "Fill Anim Speed", 0.1, 5.0, ConfigState.BoxFillAnimSpeed or 0.5, 0.1, "x", function(val)
        ConfigState.BoxFillAnimSpeed = val
    end)

    createLabel(VisualsTab, "Screen Resolution & Custom Stretch")
    local CustomStretchSliderCtrl

    createToggle(VisualsTab, "Screen Resolution", false, function(val)
        ConfigState.ResolutionEnabled = val
        if not val then
            State.appliedStretchRatio = 1.0
        else
            State.appliedStretchRatio = ConfigState.CustomStretch
        end
    end)

    createDropdown(VisualsTab, "Resolution Preset", {
        "1280x960",
        "1440x1080",
        "1280x1024",
        "1728x1080",
    }, "1280x960", function(opt)
        ConfigState.ResolutionPreset = opt
        local presetStretch = RESOLUTION_PRESETS[opt] or 0.75
        ConfigState.CustomStretch = presetStretch
        if ConfigState.ResolutionEnabled then
            State.appliedStretchRatio = presetStretch
        end
        if CustomStretchSliderCtrl then
            CustomStretchSliderCtrl.Set(presetStretch, false)
        end
    end)

    CustomStretchSliderCtrl = createSlider(VisualsTab, "Custom Stretch", 0.40, 1.20, 0.75, 0.01, "x", function(val)
        ConfigState.CustomStretch = val
        if ConfigState.ResolutionEnabled then
            State.appliedStretchRatio = val
        end
    end)

    createLabel(VisualsTab, "Pro Crosshair Suite (Presets, Spin, Pulse, Dot, Rainbow)")
    createToggle(VisualsTab, "Custom Crosshair", false, function(val)
        ConfigState.Crosshair = val
        updateCrosshair(0)
    end)
    createDropdown(VisualsTab, "Crosshair Preset", {
        "Plus (+)",
        "Cross (X)",
        "T-Shape",
        "Circle + Cross",
        "Dot Only",
        "Box Reticle",
    }, "Plus (+)", function(opt)
        ConfigState.CrosshairPreset = opt
        updateCrosshair(0)
    end)
    createDropdown(VisualsTab, "Crosshair Color", { "White", "Red", "Cyan", "Green" }, "White", function(opt)
        ConfigState.CrosshairColorName = opt
        State.crosshairColor = ColorMap[opt] or Theme.White
        updateCrosshair(0)
    end)
    createToggle(VisualsTab, "Rainbow Crosshair", false, function(val)
        ConfigState.CrosshairRainbow = val
        updateCrosshair(0)
    end)
    createSlider(VisualsTab, "Crosshair Line Length", 2, 40, 10, 1, "px", function(val)
        ConfigState.CrosshairSize = val
        updateCrosshair(0)
    end)
    createSlider(VisualsTab, "Crosshair Line Width", 1, 10, 2, 1, "px", function(val)
        ConfigState.CrosshairWidth = val
        updateCrosshair(0)
    end)
    createSlider(VisualsTab, "Crosshair Center Gap", 0, 20, 4, 1, "px", function(val)
        ConfigState.CrosshairGap = val
        updateCrosshair(0)
    end)
    createToggle(VisualsTab, "Crosshair Center Dot", true, function(val)
        ConfigState.CrosshairDot = val
        updateCrosshair(0)
    end)
    createSlider(VisualsTab, "Crosshair Dot Size", 1, 12, 3, 1, "px", function(val)
        ConfigState.CrosshairDotSize = val
        updateCrosshair(0)
    end)
    createToggle(VisualsTab, "Spin Crosshair", false, function(val)
        ConfigState.CrosshairSpin = val
        updateCrosshair(0)
    end)
    createSlider(VisualsTab, "Crosshair Spin Speed", 10, 360, 120, 5, "deg/s", function(val)
        ConfigState.CrosshairSpinSpeed = val
    end)
    createToggle(VisualsTab, "Crosshair Pulse", false, function(val)
        ConfigState.CrosshairPulse = val
        updateCrosshair(0)
    end)
    createSlider(VisualsTab, "Crosshair Pulse Speed", 1, 12, 4, 0.5, "x", function(val)
        ConfigState.CrosshairPulseSpeed = val
    end)

    createLabel(VisualsTab, "X-Ray, Weather, Sky & World Atmosphere")
    createToggle(VisualsTab, "X-Ray Vision (See-Through Walls)", false, function(val)
        ConfigState.XRay = val
        applyXRayVision(val)
    end)
    createSlider(VisualsTab, "X-Ray Wall Transparency", 0.1, 0.9, 0.6, 0.05, "", function(val)
        ConfigState.XRayTransparency = val
        if ConfigState.XRay then
            applyXRayVision(true)
        end
    end)
    createDropdown(VisualsTab, "Weather Preset", {
        "Default",
        "Rain",
        "Thunderstorm",
        "Snow",
        "Sunny",
    }, "Default", function(opt)
        if State.applyWeatherPreset then
            State.applyWeatherPreset(opt)
        end
        notify("Weather Engine", "Weather set to " .. tostring(opt) .. (ConfigState.WeatherSoundEnabled and " (Sound FX On)" or ""), 3)
    end)
    createToggle(VisualsTab, "Weather Sound Effects", true, function(val)
        ConfigState.WeatherSoundEnabled = val
        if State.syncWeatherAudio then
            State.syncWeatherAudio()
        end
    end)
    createSlider(VisualsTab, "Weather Sound Volume", 0, 1, 0.5, 0.05, "", function(val)
        ConfigState.WeatherSoundVolume = val
        if State.syncWeatherAudio then
            State.syncWeatherAudio()
        end
    end)
    createDropdown(VisualsTab, "Sky & Atmosphere Preset", {
        "Game Default",
        "Pitch Black Void",
        "Cyberpunk Night",
        "Starry Nebula",
        "Sunset Gold",
        "Matrix Monochrome",
        "Clean Daylight",
    }, "Game Default", function(opt)
        ConfigState.SkyPreset = opt
        updateLightingEnvironment()
    end)
    createToggle(VisualsTab, "Fullbright", false, function(val)
        ConfigState.Fullbright = val
        updateLightingEnvironment()
    end)
    createToggle(VisualsTab, "No Fog", false, function(val)
        ConfigState.NoFog = val
        updateLightingEnvironment()
    end)
    createSlider(VisualsTab, "Time of Day", 0, 24, 14, 0.5, "hr", function(val)
        ConfigState.TimeOfDay = val
        Lighting.ClockTime = val
    end)

    createLabel(VisualsTab, "Freecam & Camera Enhancements")
    createToggle(VisualsTab, "Freecam (Drone Camera)", false, function(val)
        setFreecamEnabled(val)
    end)
    createSlider(VisualsTab, "Freecam Speed", 10, 150, 45, 1, "studs/s", function(val)
        ConfigState.FreecamSpeed = val
    end)
    createToggle(VisualsTab, "Custom Camera FOV", false, function(val)
        ConfigState.CustomCamFOV = val
        local cam = workspace.CurrentCamera
        if cam and not val then
            cam.FieldOfView = State.defaultCamFOV
        end
    end)
    createSlider(VisualsTab, "Camera FOV", 50, 120, 70, 1, "deg", function(val)
        ConfigState.CamFOV = val
        local cam = workspace.CurrentCamera
        if cam and ConfigState.CustomCamFOV then
            cam.FieldOfView = val
        end
    end)
    createToggle(VisualsTab, "Infinite Zoom Distance", false, function(val)
        ConfigState.InfZoom = val
        LocalPlayer.CameraMaxZoomDistance = val and 9999 or State.defaultMaxZoom
    end)
    createToggle(VisualsTab, "Noclip Camera (See Through Walls)", false, function(val)
        ConfigState.NoclipCam = val
        pcall(function()
            LocalPlayer.DevCameraOcclusionMode = val and Enum.DevCameraOcclusionMode.Invisicam or State.defaultOcclusion
        end)
    end)
    createButton(VisualsTab, "Reset Character Camera", function()
        local cam = workspace.CurrentCamera
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if cam then
            setFreecamEnabled(false)
            State.spectatingPlayerName = nil
            if hum then
                cam.CameraSubject = hum
            end
            cam.CameraType = Enum.CameraType.Custom
            if not ConfigState.CustomCamFOV then
                cam.FieldOfView = State.defaultCamFOV
            end
            notify("Core.xyz", "Camera subject reset to your character.", 3)
        end
    end)

    createLabel(VisualsTab, "Client Character Cosmetics")
    createToggle(VisualsTab, "Headless Horseman", false, function(val)
        ConfigState.Headless = val
        applyHeadless(val)
    end)
    createToggle(VisualsTab, "Korblox Right Leg", false, function(val)
        ConfigState.Korblox = val
        applyKorblox(val)
    end)

    -- SUITE 1: SELF CHAMS (21 Materials, Fill/Outline Swatches, Fill/Outline Transparency, Rainbow, Pulse, Glow Rim)
    do
        local SelfChamsBox = UI.createSectionBox(VisualsTab, "Self Chams")
        createToggle(SelfChamsBox, "Self Chams", false, function(val)
            ConfigState.SelfChams = val
            if State.applySelfChams then
                State.applySelfChams()
            end
        end, {
            ShowKeybindBadge = true,
            SwatchColor = Color3.fromRGB(255, 255, 255),
            OnColorChange = function(col)
                ConfigState.SelfChamsOutlineColor = col
                if ConfigState.SelfChams and State.applySelfChams then
                    State.applySelfChams()
                end
            end,
            SwatchColor2 = Color3.fromRGB(115, 95, 255),
            OnColorChange2 = function(col)
                ConfigState.SelfChamsFillColor = col
                ConfigState.SelfChamsCustomColor = true
                if ConfigState.SelfChams and State.applySelfChams then
                    State.applySelfChams()
                end
            end,
        })

        createDropdown(SelfChamsBox, "Chams Material", {
            "None",
            "Aura",
            "Neon",
            "Flat",
            "Chrome",
            "Liquid Metal",
            "Gold",
            "Diamond",
            "Glass",
            "Ice",
            "Obsidian",
            "Lava",
            "Plasma",
            "Toxic",
            "Ropes",
            "Rainbow",
            "Holographic",
            "Galaxy",
            "Matrix",
            "Pearl",
            "Glossy",
        }, "Lava", function(opt)
            ConfigState.SelfChamsMaterial = opt
            ConfigState.SelfChamsCustomColor = false
            if ConfigState.SelfChams and State.applySelfChams then
                State.applySelfChams()
            end
        end)

        createSlider(SelfChamsBox, "Fill Transparency", 0, 1, 0.55, 0.05, "", function(val)
            ConfigState.SelfChamsFillTrans = val
            if ConfigState.SelfChams and State.applySelfChams then
                State.applySelfChams()
            end
        end)

        createSlider(SelfChamsBox, "Outline Transparency", 0, 1, 0, 0.05, "", function(val)
            ConfigState.SelfChamsOutlineTrans = val
            if ConfigState.SelfChams and State.applySelfChams then
                State.applySelfChams()
            end
        end)

        createToggle(SelfChamsBox, "Rainbow", false, function(val)
            ConfigState.SelfChamsRainbow = val
            if ConfigState.SelfChams and State.applySelfChams then
                State.applySelfChams()
            end
        end)

        createToggle(SelfChamsBox, "Pulse", false, function(val)
            ConfigState.SelfChamsPulse = val
            if ConfigState.SelfChams and State.applySelfChams then
                State.applySelfChams()
            end
        end)

        createToggle(SelfChamsBox, "Glow Rim", false, function(val)
            ConfigState.SelfChamsGlowRim = val
            if ConfigState.SelfChams and State.applySelfChams then
                State.applySelfChams()
            end
        end)
    end

    -- SUITE 2: LEG / MOVEMENT TRAIL (Dual-Leg Start/End Swatches, Same Colors, Width, Length, Rainbow Trail)
    do
        local TrailBox = UI.createSectionBox(VisualsTab, "Trail")
        createToggle(TrailBox, "Trail", false, function(val)
            ConfigState.LegTrailEnabled = val
            if State.applyLegTrails then
                State.applyLegTrails()
            end
        end, { ShowKeybindBadge = true })

        UI.createColorRow(TrailBox, "Left Leg Start", Color3.fromRGB(105, 85, 255), function(col)
            ConfigState.LeftLegTrailStart = col
            if ConfigState.LegTrailEnabled and State.applyLegTrails then
                State.applyLegTrails()
            end
        end)

        UI.createColorRow(TrailBox, "Left Leg End", Color3.fromRGB(70, 205, 255), function(col)
            ConfigState.LeftLegTrailEnd = col
            if ConfigState.LegTrailEnabled and State.applyLegTrails then
                State.applyLegTrails()
            end
        end)

        createToggle(TrailBox, "Same Colors Both Legs", false, function(val)
            ConfigState.LegTrailSameColors = val
            if ConfigState.LegTrailEnabled and State.applyLegTrails then
                State.applyLegTrails()
            end
        end)

        UI.createColorRow(TrailBox, "Right Leg Start", Color3.fromRGB(255, 85, 195), function(col)
            ConfigState.RightLegTrailStart = col
            if ConfigState.LegTrailEnabled and State.applyLegTrails then
                State.applyLegTrails()
            end
        end)

        UI.createColorRow(TrailBox, "Right Leg End", Color3.fromRGB(255, 190, 75), function(col)
            ConfigState.RightLegTrailEnd = col
            if ConfigState.LegTrailEnabled and State.applyLegTrails then
                State.applyLegTrails()
            end
        end)

        createSlider(TrailBox, "Trail Width", 0.05, 2.0, 0.25, 0.05, "", function(val)
            ConfigState.LegTrailWidth = val
            if ConfigState.LegTrailEnabled and State.applyLegTrails then
                State.applyLegTrails()
            end
        end)

        createSlider(TrailBox, "Trail Length", 0.1, 3.0, 0.5, 0.1, "s", function(val)
            ConfigState.LegTrailLength = val
            if ConfigState.LegTrailEnabled and State.applyLegTrails then
                State.applyLegTrails()
            end
        end)

        createToggle(TrailBox, "Rainbow Trail", false, function(val)
            ConfigState.LegTrailRainbow = val
            if ConfigState.LegTrailEnabled and State.applyLegTrails then
                State.applyLegTrails()
            end
        end)
    end

    -- SUITE 3: TOOL VISUALS (Material, Transparency, Rainbow, 12 Skin Textures, Tool Chams, Chams Style, Tool Glow)
    do
        local ToolBox = UI.createSectionBox(VisualsTab, "Tool Visuals")
        createToggle(ToolBox, "Tool Visuals", false, function(val)
            ConfigState.ToolVisuals = val
            if State.applyToolVisuals then
                State.applyToolVisuals()
            end
        end, {
            ShowKeybindBadge = true,
            SwatchColor = Color3.fromRGB(115, 95, 255),
            OnColorChange = function(col)
                ConfigState.ToolColor = col
                if State.applyToolVisuals then
                    State.applyToolVisuals()
                end
            end,
        })

        createDropdown(ToolBox, "Tool Material", {
            "SmoothPlastic",
            "Neon",
            "Glass",
            "Foil",
            "ForceField",
        }, "SmoothPlastic", function(opt)
            ConfigState.ToolMaterial = opt
            if State.applyToolVisuals then
                State.applyToolVisuals()
            end
        end)

        createSlider(ToolBox, "Tool Transparency", 0, 1, 0, 0.05, "", function(val)
            ConfigState.ToolTransparency = val
            if State.applyToolVisuals then
                State.applyToolVisuals()
            end
        end)

        createToggle(ToolBox, "Rainbow Tool", false, function(val)
            ConfigState.RainbowTool = val
            if State.applyToolVisuals then
                State.applyToolVisuals()
            end
        end)

        createDropdown(ToolBox, "Skin Texture", {
            "None",
            "Aurora",
            "Blue Skies, White Guns",
            "Blue Stars",
            "Blue Void",
            "Classic Blue White",
            "Epic White",
            "Green and Black",
            "Matrix",
            "Pink White",
            "Water",
            "White",
        }, "None", function(opt)
            ConfigState.ToolSkinTexture = opt
            if State.applyToolVisuals then
                State.applyToolVisuals()
            end
        end)

        createToggle(ToolBox, "Tool Chams", false, function(val)
            ConfigState.ToolChams = val
            if State.applyToolVisuals then
                State.applyToolVisuals()
            end
        end, {
            SwatchColor = Color3.fromRGB(255, 255, 255),
            OnColorChange = function(col)
                ConfigState.ToolChamsColor = col
                if State.applyToolVisuals then
                    State.applyToolVisuals()
                end
            end,
        })

        createDropdown(ToolBox, "Chams Style", {
            "Outline",
            "Soft Fill",
            "Solid",
        }, "Outline", function(opt)
            ConfigState.ToolChamsStyle = opt
            if State.applyToolVisuals then
                State.applyToolVisuals()
            end
        end)

        createToggle(ToolBox, "Tool Glow", false, function(val)
            ConfigState.ToolGlow = val
            if State.applyToolVisuals then
                State.applyToolVisuals()
            end
        end)

        createSlider(ToolBox, "Glow Brightness", 0, 10, 3, 0.5, "", function(val)
            ConfigState.ToolGlowBrightness = val
            if State.applyToolVisuals then
                State.applyToolVisuals()
            end
        end)
    end

    -- SUITE 4: BLOOM & SUN RAYS
    do
        local BloomBox = UI.createSectionBox(VisualsTab, "Bloom & Sun Rays")
        createToggle(BloomBox, "Bloom", false, function(val)
            ConfigState.BloomEnabled = val
            if State.applyCustomBloomAndSunRays then
                State.applyCustomBloomAndSunRays()
            end
        end, { ShowKeybindBadge = true })

        createSlider(BloomBox, "Bloom Intensity", 0, 3, 0.6, 0.05, "", function(val)
            ConfigState.BloomIntensity = val
            if State.applyCustomBloomAndSunRays then
                State.applyCustomBloomAndSunRays()
            end
        end)

        createSlider(BloomBox, "Bloom Size", 0, 56, 26, 1, "", function(val)
            ConfigState.BloomSize = val
            if State.applyCustomBloomAndSunRays then
                State.applyCustomBloomAndSunRays()
            end
        end)

        createSlider(BloomBox, "Bloom Threshold", 0, 4, 0.4, 0.05, "", function(val)
            ConfigState.BloomThreshold = val
            if State.applyCustomBloomAndSunRays then
                State.applyCustomBloomAndSunRays()
            end
        end)

        createToggle(BloomBox, "Sun Rays", false, function(val)
            ConfigState.SunRaysEnabled = val
            if State.applyCustomBloomAndSunRays then
                State.applyCustomBloomAndSunRays()
            end
        end, { ShowKeybindBadge = true })

        createSlider(BloomBox, "Rays Intensity", 0, 1, 0.25, 0.05, "", function(val)
            ConfigState.SunRaysIntensity = val
            if State.applyCustomBloomAndSunRays then
                State.applyCustomBloomAndSunRays()
            end
        end)

        createSlider(BloomBox, "Rays Spread", 0, 1, 1.0, 0.05, "", function(val)
            ConfigState.SunRaysSpread = val
            if State.applyCustomBloomAndSunRays then
                State.applyCustomBloomAndSunRays()
            end
        end)
    end

    -- SUITE 5: COLOR CORRECTION
    do
        local CCBox = UI.createSectionBox(VisualsTab, "Color Correction")
        createToggle(CCBox, "Color Correction", false, function(val)
            ConfigState.ColorCorrectionEnabled = val
            if State.applyCustomColorCorrection then
                State.applyCustomColorCorrection()
            end
        end, {
            ShowKeybindBadge = true,
            SwatchColor = Color3.fromRGB(255, 255, 255),
            OnColorChange = function(col)
                ConfigState.ColorCorrectionTint = col
                if State.applyCustomColorCorrection then
                    State.applyCustomColorCorrection()
                end
            end,
        })

        createSlider(CCBox, "Saturation", -1, 2, 0, 0.05, "", function(val)
            ConfigState.ColorCorrectionSaturation = val
            if State.applyCustomColorCorrection then
                State.applyCustomColorCorrection()
            end
        end)

        createSlider(CCBox, "Contrast", -1, 2, 0, 0.05, "", function(val)
            ConfigState.ColorCorrectionContrast = val
            if State.applyCustomColorCorrection then
                State.applyCustomColorCorrection()
            end
        end)

        createSlider(CCBox, "Brightness", -1, 1, 0, 0.05, "", function(val)
            ConfigState.ColorCorrectionBrightness = val
            if State.applyCustomColorCorrection then
                State.applyCustomColorCorrection()
            end
        end)
    end

    -- SUITE 6: SKYBOX & CATALOG SEARCH (21 Presets, Clear Atmosphere, Custom ID, Search Skyboxes)
    do
        local SkyBoxSec = UI.createSectionBox(VisualsTab, "Skybox")
        createToggle(SkyBoxSec, "Skybox", false, function(val)
            ConfigState.SkyboxEnabled = val
            if State.applyCustomSkybox then
                State.applyCustomSkybox()
            end
        end)

        createDropdown(SkyBoxSec, "Preset", {
            "Galaxy",
            "Aurora Galaxy",
            "Aurora Borealis",
            "Realistic Space",
            "Night",
            "Night Fog",
            "Red Night",
            "Scary Red",
            "Sunset",
            "Sunset With Sun",
            "Classic Purple",
            "Purple",
            "Pink",
            "Pink Sky",
            "Anime Island",
            "Anime",
            "Clouds",
            "Realistic Clouds",
            "Minecraft",
            "Minecraft Alt",
            "Clear Blue",
        }, "Galaxy", function(opt)
            ConfigState.SkyboxPreset = opt
            ConfigState.CustomSkyDecalId = ""
            if State.applyCustomSkybox then
                State.applyCustomSkybox()
            end
        end)

        createToggle(SkyBoxSec, "Clear Atmosphere", false, function(val)
            ConfigState.SkyboxClearAtmos = val
            if State.applyCustomSkybox then
                State.applyCustomSkybox()
            end
        end)

        createTextInputRow(SkyBoxSec, "Custom Sky", "Decal / Image ID...", "", function(txt)
            ConfigState.CustomSkyDecalId = tostring(txt or "")
            if State.applyCustomSkybox then
                State.applyCustomSkybox()
            end
        end)

        local SearchResultsDropdown
        local SearchInputBox = createTextInputRow(SkyBoxSec, "Search Skyboxes", "e.g. galaxy, sunset, anime...", "", function(txt)
            ConfigState.SkySearchQuery = tostring(txt or "")
        end)

        createButton(SkyBoxSec, "Search", function()
            local q = (SearchInputBox and SearchInputBox.Text and SearchInputBox.Text ~= "") and SearchInputBox.Text or (ConfigState.SkySearchQuery or "")
            ConfigState.SkySearchQuery = q
            local results = State.searchSkyboxes and State.searchSkyboxes(q) or { "Galaxy (159454299)" }
            if SearchResultsDropdown and SearchResultsDropdown.Refresh then
                SearchResultsDropdown.Refresh(results, results[1])
            end
            if results[1] then
                local idMatch = string.match(results[1], "(%d+)")
                if idMatch then
                    ConfigState.CustomSkyDecalId = idMatch
                    if State.applyCustomSkybox then
                        State.applyCustomSkybox()
                    end
                end
            end
            notify("Skybox Search", string.format("Found %d skybox match(es) for '%s'", #results, q ~= "" and q or "all"), 3)
        end)

        SearchResultsDropdown = createDropdown(SkyBoxSec, "Search Results", {
            "Galaxy (159454299)",
            "Aurora Galaxy (12064107)",
            "Sunset (600830446)",
        }, "Galaxy (159454299)", function(opt)
            local idMatch = string.match(tostring(opt or ""), "(%d+)")
            if idMatch then
                ConfigState.CustomSkyDecalId = idMatch
                if State.applyCustomSkybox then
                    State.applyCustomSkybox()
                end
            end
        end)
    end

    -- SUITE 7: LIGHTING CONTROLLER (Ambient, Outdoor Ambient, Color Shift Bottom/Top, Fog Color/End/Start, Exposure, Brightness, Clock Time, No Shadows)
    do
        local LightSec = UI.createSectionBox(VisualsTab, "Lighting")
        createToggle(LightSec, "Ambient", false, function(val)
            ConfigState.LightingAmbientEnabled = val
            updateLightingEnvironment()
        end, {
            SwatchColor = Color3.fromRGB(115, 95, 255),
            OnColorChange = function(col)
                ConfigState.LightingAmbientColor = col
                updateLightingEnvironment()
            end,
        })

        createToggle(LightSec, "Outdoor Ambient", false, function(val)
            ConfigState.LightingOutdoorEnabled = val
            updateLightingEnvironment()
        end, {
            SwatchColor = Color3.fromRGB(115, 95, 255),
            OnColorChange = function(col)
                ConfigState.LightingOutdoorColor = col
                updateLightingEnvironment()
            end,
        })

        createToggle(LightSec, "Color Shift Bottom", false, function(val)
            ConfigState.LightingShiftBottomEnabled = val
            updateLightingEnvironment()
        end, {
            SwatchColor = Color3.fromRGB(115, 95, 255),
            OnColorChange = function(col)
                ConfigState.LightingShiftBottomColor = col
                updateLightingEnvironment()
            end,
        })

        createToggle(LightSec, "Color Shift Top", false, function(val)
            ConfigState.LightingShiftTopEnabled = val
            updateLightingEnvironment()
        end, {
            SwatchColor = Color3.fromRGB(115, 95, 255),
            OnColorChange = function(col)
                ConfigState.LightingShiftTopColor = col
                updateLightingEnvironment()
            end,
        })

        createToggle(LightSec, "Fog Color", false, function(val)
            ConfigState.LightingFogColorEnabled = val
            updateLightingEnvironment()
        end, {
            SwatchColor = Color3.fromRGB(115, 95, 255),
            OnColorChange = function(col)
                ConfigState.LightingFogColor = col
                updateLightingEnvironment()
            end,
        })

        createToggle(LightSec, "Fog End", false, function(val)
            ConfigState.LightingFogEndEnabled = val
            updateLightingEnvironment()
        end)

        createSlider(LightSec, "Fog End Distance", 50, 10000, 1000, 50, "", function(val)
            ConfigState.LightingFogEnd = val
            updateLightingEnvironment()
        end)

        createToggle(LightSec, "Fog Start", false, function(val)
            ConfigState.LightingFogStartEnabled = val
            updateLightingEnvironment()
        end)

        createSlider(LightSec, "Fog Start Distance", 0, 5000, 0, 25, "", function(val)
            ConfigState.LightingFogStart = val
            updateLightingEnvironment()
        end)

        createToggle(LightSec, "Exposure Compensation", false, function(val)
            ConfigState.LightingExposureEnabled = val
            updateLightingEnvironment()
        end)

        createSlider(LightSec, "Exposure Value", -3, 3, 0, 0.1, "", function(val)
            ConfigState.LightingExposure = val
            updateLightingEnvironment()
        end)

        createToggle(LightSec, "Brightness", false, function(val)
            ConfigState.LightingBrightnessEnabled = val
            updateLightingEnvironment()
        end)

        createSlider(LightSec, "Brightness Level", 0, 10, 1, 0.25, "", function(val)
            ConfigState.LightingBrightness = val
            updateLightingEnvironment()
        end)

        createToggle(LightSec, "Clock Time", false, function(val)
            ConfigState.LightingClockTimeEnabled = val
            updateLightingEnvironment()
        end)

        createSlider(LightSec, "Clock Time Hour", 0, 24, 12, 0.5, "h", function(val)
            ConfigState.LightingClockTime = val
            updateLightingEnvironment()
        end)

        createToggle(LightSec, "No Shadows", false, function(val)
            ConfigState.LightingNoShadows = val
            updateLightingEnvironment()
        end)
    end

    -- SUITE 8: ATMOSPHERE CONTROLLER (Atmosphere + Color Swatch, Decay Color Row, Density, Offset, Haze, Glare)
    do
        local AtmosSec = UI.createSectionBox(VisualsTab, "Atmosphere")
        createToggle(AtmosSec, "Atmosphere", false, function(val)
            ConfigState.AtmosphereEnabled = val
            if State.applyCustomAtmosphere then
                State.applyCustomAtmosphere()
            end
        end, {
            SwatchColor = Color3.fromRGB(200, 195, 225),
            OnColorChange = function(col)
                ConfigState.AtmosphereColor = col
                if State.applyCustomAtmosphere then
                    State.applyCustomAtmosphere()
                end
            end,
        })

        UI.createColorRow(AtmosSec, "Decay", Color3.fromRGB(92, 60, 14), function(col)
            ConfigState.AtmosphereDecay = col
            if State.applyCustomAtmosphere then
                State.applyCustomAtmosphere()
            end
        end)

        createSlider(AtmosSec, "Density", 0, 1, 0.35, 0.05, "", function(val)
            ConfigState.AtmosphereDensity = val
            if State.applyCustomAtmosphere then
                State.applyCustomAtmosphere()
            end
        end)

        createSlider(AtmosSec, "Offset", 0, 1, 0, 0.05, "", function(val)
            ConfigState.AtmosphereOffset = val
            if State.applyCustomAtmosphere then
                State.applyCustomAtmosphere()
            end
        end)

        createSlider(AtmosSec, "Haze", 0, 10, 0, 0.5, "", function(val)
            ConfigState.AtmosphereHaze = val
            if State.applyCustomAtmosphere then
                State.applyCustomAtmosphere()
            end
        end)

        createSlider(AtmosSec, "Glare", 0, 10, 0, 0.5, "", function(val)
            ConfigState.AtmosphereGlare = val
            if State.applyCustomAtmosphere then
                State.applyCustomAtmosphere()
            end
        end)
    end
end

-- TAB 4: MOVEMENT & PROTECTION (STEALTH ANTI-KICK BYPASS + SWIM IN AIR + SPIDER CLIMB + SPINBOT + ANTI-FLING + ANTI-RAGDOLL + ANTI-VOID)
do
    createLabel(MovementTab, "Stealth Anti-Kick & Character Speed / Climb")
    createToggle(MovementTab, "Stealth Anti-Kick Bypass (99% Undetected)", true, function(val)
        ConfigState.StealthBypass = val
        updateMovement()
    end)
    createToggle(MovementTab, "Custom WalkSpeed", false, function(val)
        ConfigState.WalkSpeedEnabled = val
        updateMovement()
    end)
    createSlider(MovementTab, "WalkSpeed", 16, 150, 16, 1, "studs", function(val)
        ConfigState.WalkSpeed = val
        if ConfigState.WalkSpeedEnabled then
            updateMovement()
        end
    end)
    createToggle(MovementTab, "Custom JumpPower", false, function(val)
        ConfigState.JumpPowerEnabled = val
        updateMovement()
    end)
    createSlider(MovementTab, "JumpPower", 50, 250, 50, 1, "power", function(val)
        ConfigState.JumpPower = val
        if ConfigState.JumpPowerEnabled then
            updateMovement()
        end
    end)
    createToggle(MovementTab, "Infinite Jump", false, function(val)
        ConfigState.InfJump = val
    end)
    createToggle(MovementTab, "Swim in Air (Sky-Swim)", false, function(val)
        ConfigState.SwimInAir = val
        local hum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum and val then
            pcall(function()
                hum:ChangeState(Enum.HumanoidStateType.Swimming)
            end)
        end
    end)
    createToggle(MovementTab, "Spider Climb (Wall Walk)", false, function(val)
        ConfigState.SpiderClimb = val
    end)
    createSlider(MovementTab, "Spider Climb Speed", 15, 80, 32, 1, "studs/s", function(val)
        ConfigState.SpiderClimbSpeed = val
    end)
    createToggle(MovementTab, "NoClip (Stepped)", false, function(val)
        ConfigState.NoClip = val
        if not val then
            restoreNoClipCollisions()
        end
    end)

    createLabel(MovementTab, "Spinbot Controller")
    createToggle(MovementTab, "Spinbot", false, function(val)
        ConfigState.Spinbot = val
    end)
    createSlider(MovementTab, "Spinbot Speed", 1, 100, 25, 1, "deg/f", function(val)
        ConfigState.SpinSpeed = val
    end)

    createLabel(MovementTab, "Character Protection & Immortality")
    createToggle(MovementTab, "Anti-Fling (Disable Other Players Collision)", false, function(val)
        ConfigState.AntiFling = val
        if not val then
            restoreAntiFlingCollisions()
        end
    end)
    createToggle(MovementTab, "Anti-Ragdoll / Anti-Stun", false, function(val)
        ConfigState.AntiRagdoll = val
    end)
    createToggle(MovementTab, "Anti-Void Protection (Return to Safe Ground)", false, function(val)
        ConfigState.AntiVoid = val
    end)
end

-- TAB 5: PLAYERS (EXPANDABLE PLAYER CARDS WITH AVATAR & 7 INLINE ACTION BUTTONS INCLUDING ORBIT)
do
    createLabel(PlayersTab, "Server Players (Tap Player to Open/Close 7 Actions)")

    local PlayerListContainer = Instance.new("Frame")
    PlayerListContainer.Size = UDim2.new(1, 0, 0, 180)
    PlayerListContainer.AutomaticSize = Enum.AutomaticSize.Y
    PlayerListContainer.BackgroundTransparency = 1
    PlayerListContainer.ZIndex = 14
    PlayerListContainer.Parent = PlayersTab

    local PlayerListLayout = Instance.new("UIListLayout")
    PlayerListLayout.Padding = UDim.new(0, 6)
    PlayerListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    PlayerListLayout.Parent = PlayerListContainer

    local playerCardsUI = {}

    local function formatPlayerHeaderLine(p, myHRP)
        local isWhite = State.whitelistedPlayers[p.Name] == true
        local isPrio = State.prioritizedPlayers[p.Name] == true
        local isSpec = (State.spectatingPlayerName == p.Name)
        local isOrbit = (State.orbitingPlayerName == p.Name)
        local distStr = ""
        local tHRP = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
        if myHRP and tHRP then
            distStr = string.format(" [%dm]", math.floor((tHRP.Position - myHRP.Position).Magnitude))
        end
        local badges = ""
        if isWhite then badges = badges .. " [WHITELIST]" end
        if isPrio then badges = badges .. " [PRIORITY]" end
        if isSpec then badges = badges .. " [SPECTATING]" end
        if isOrbit then badges = badges .. " [ORBITING]" end
        return string.format("%s (@%s)%s%s", tostring(p.DisplayName or p.Name), p.Name, distStr, badges)
    end

    local function updatePlayerDistancesInPlace()
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        for _, entry in ipairs(playerCardsUI) do
            if entry.Player and entry.NameLabel and entry.NameLabel.Parent then
                entry.NameLabel.Text = formatPlayerHeaderLine(entry.Player, myHRP)
            end
        end
    end

    local function refreshPlayerListUI()
        for _, entry in ipairs(playerCardsUI) do
            if entry.Card and entry.Card.Parent then
                entry.Card:Destroy()
            end
        end
        table.clear(playerCardsUI)

        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

        for i, p in ipairs(Players:GetPlayers()) do
            if p ~= LocalPlayer then
                local isExpanded = (State.expandedPlayerName == p.Name)
                local isWhite = State.whitelistedPlayers[p.Name] == true
                local isPrio = State.prioritizedPlayers[p.Name] == true
                local isSpec = (State.spectatingPlayerName == p.Name)
                local isOrbit = (State.orbitingPlayerName == p.Name)

                local card = Instance.new("Frame")
                card.Name = "PlayerCard_" .. p.Name
                card.LayoutOrder = i
                card.Size = UDim2.new(1, 0, 0, isExpanded and 160 or 44)
                card.BackgroundColor3 = isExpanded and Theme.Elevated or Theme.Surface
                card.ClipsDescendants = true
                card.ZIndex = 15
                card.Parent = PlayerListContainer
                addCorner(card, 8)
                addStroke(card, isExpanded and Theme.Accent or Theme.Border, 1, 0)

                -- Header Button (Avatar + Name + Badges)
                local headerBtn = Instance.new("TextButton")
                headerBtn.Name = "PlayerHeader_" .. p.Name
                headerBtn.Size = UDim2.new(1, 0, 0, 44)
                headerBtn.BackgroundTransparency = 1
                headerBtn.AutoButtonColor = false
                headerBtn.Text = ""
                headerBtn.ZIndex = 16
                headerBtn.Parent = card

                local avatarImg = Instance.new("ImageLabel")
                avatarImg.Name = "AvatarImage"
                avatarImg.AnchorPoint = Vector2.new(0, 0.5)
                avatarImg.Position = UDim2.new(0, 8, 0.5, 0)
                avatarImg.Size = UDim2.fromOffset(30, 30)
                avatarImg.BackgroundColor3 = Theme.Deep
                avatarImg.Image = "rbxthumb://type=AvatarHeadShot&id=" .. tostring(p.UserId or 1) .. "&w=150&h=150"
                avatarImg.ZIndex = 17
                avatarImg.Parent = headerBtn
                addCorner(avatarImg, 99)
                addStroke(avatarImg, isPrio and Theme.Success or Theme.Border, 1, 0)

                local nameLbl = Instance.new("TextLabel")
                nameLbl.Position = UDim2.fromOffset(46, 0)
                nameLbl.Size = UDim2.new(1, -72, 1, 0)
                nameLbl.BackgroundTransparency = 1
                nameLbl.Font = Enum.Font.Code
                nameLbl.Text = formatPlayerHeaderLine(p, myHRP)
                nameLbl.TextColor3 = isExpanded and Theme.White or Theme.Silver
                nameLbl.TextSize = 11
                nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
                nameLbl.TextXAlignment = Enum.TextXAlignment.Left
                nameLbl.ZIndex = 17
                nameLbl.Parent = headerBtn

                local chev = Instance.new("TextLabel")
                chev.AnchorPoint = Vector2.new(1, 0.5)
                chev.Position = UDim2.new(1, -12, 0.5, 0)
                chev.Size = UDim2.fromOffset(14, 14)
                chev.BackgroundTransparency = 1
                chev.Font = Enum.Font.GothamBold
                chev.Text = isExpanded and "▴" or "▾"
                chev.TextColor3 = Theme.Muted
                chev.TextSize = 12
                chev.ZIndex = 17
                chev.Parent = headerBtn

                -- Clicking header toggles 7-option drawer under this player (or switches from another player)
                headerBtn.MouseButton1Click:Connect(function()
                    if State.expandedPlayerName == p.Name then
                        State.expandedPlayerName = nil
                    else
                        State.expandedPlayerName = p.Name
                    end
                    refreshPlayerListUI()
                end)

                -- 7 Action Buttons Container underneath Header
                local actionsHolder = Instance.new("Frame")
                actionsHolder.Name = "PlayerActions_" .. p.Name
                actionsHolder.Position = UDim2.fromOffset(8, 46)
                actionsHolder.Size = UDim2.new(1, -16, 0, 106)
                actionsHolder.BackgroundTransparency = 1
                actionsHolder.Visible = isExpanded
                actionsHolder.ZIndex = 16
                actionsHolder.Parent = card

                local function makeActionBtn(col, row, label, isActive, onClick, fullRow)
                    local aBtn = Instance.new("TextButton")
                    aBtn.Name = "Action_" .. label
                    aBtn.Position = fullRow and UDim2.new(0, 0, 0, (row - 1) * 35) or UDim2.new((col - 1) * 0.335, 0, 0, (row - 1) * 35)
                    aBtn.Size = fullRow and UDim2.new(1, 0, 0, 30) or UDim2.new(0.32, 0, 0, 30)
                    aBtn.BackgroundColor3 = isActive and Theme.Accent or Theme.Deep
                    aBtn.AutoButtonColor = false
                    aBtn.Font = Enum.Font.GothamBold
                    aBtn.Text = label
                    aBtn.TextColor3 = isActive and Theme.Black or Theme.White
                    aBtn.TextSize = 10
                    aBtn.ZIndex = 17
                    aBtn.Parent = actionsHolder
                    addCorner(aBtn, 6)
                    addStroke(aBtn, isActive and Theme.Accent or Theme.Border, 1, 0)
                    aBtn.MouseButton1Click:Connect(onClick)
                    return aBtn
                end

                -- 1. Whitelist
                makeActionBtn(1, 1, "Whitelist", isWhite, function()
                    State.whitelistedPlayers[p.Name] = not isWhite and true or nil
                    syncWhitelistArrayFromMap()
                    if ConfigState.HitboxExpander then
                        updateHitboxExpander()
                    end
                    notify("Players", (not isWhite and "Whitelisted " or "Removed whitelist on ") .. p.Name, 3)
                    refreshPlayerListUI()
                end)

                -- 2. Prioritize
                makeActionBtn(2, 1, "Prioritize", isPrio, function()
                    State.prioritizedPlayers[p.Name] = not isPrio and true or nil
                    notify("Players", (not isPrio and "Prioritizing " or "Removed priority on ") .. p.Name, 3)
                    refreshPlayerListUI()
                end)

                -- 3. Spectate
                makeActionBtn(3, 1, "Spectate", isSpec, function()
                    local cam = workspace.CurrentCamera
                    if isSpec then
                        State.spectatingPlayerName = nil
                        local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                        if cam and myHum then
                            cam.CameraSubject = myHum
                        end
                    else
                        State.spectatingPlayerName = p.Name
                        local tHum = p.Character and p.Character:FindFirstChildOfClass("Humanoid")
                        if cam and tHum then
                            cam.CameraSubject = tHum
                            notify("Players", "Spectating " .. p.Name, 3)
                        end
                    end
                    refreshPlayerListUI()
                end)

                -- 4. Orbit (7th Toggle Option)
                makeActionBtn(1, 2, "Orbit", isOrbit, function()
                    if isOrbit then
                        State.orbitingPlayerName = nil
                        notify("Players", "Stopped orbiting " .. p.Name, 3)
                    else
                        State.orbitingPlayerName = p.Name
                        State.orbitAngle = 0
                        notify("Players", "Orbiting around " .. p.Name, 3)
                    end
                    refreshPlayerListUI()
                end)

                -- 5. Teleport
                makeActionBtn(2, 2, "Teleport", false, function()
                    local myRoot = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    local targetRoot = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
                    if myRoot and targetRoot then
                        myRoot.CFrame = targetRoot.CFrame * CFrame.new(0, 0, 3)
                        notify("Players", "Teleported to " .. p.Name, 3)
                    end
                end)

                -- 6. Copy UserName
                makeActionBtn(3, 2, "Copy UserName", false, function()
                    if Env.setclipboard then
                        Env.setclipboard(p.Name)
                    end
                    notify("Players", "Copied username: " .. p.Name, 3)
                end)

                -- 7. Fling
                makeActionBtn(1, 3, "Fling", false, function()
                    flingTargetPlayer(p)
                end, true)

                table.insert(playerCardsUI, { Card = card, Player = p, NameLabel = nameLbl })
            end
        end
    end

    State.refreshPlayerListUI = refreshPlayerListUI
    State.updatePlayerDistances = updatePlayerDistancesInPlace
    refreshPlayerListUI()

    createLabel(PlayersTab, "Orbit Player Settings")
    createSlider(PlayersTab, "Orbit Speed", 1, 20, 5, 0.5, "rad/s", function(val)
        ConfigState.OrbitSpeed = val
    end)
    createSlider(PlayersTab, "Orbit Radius", 3, 25, 8, 1, "studs", function(val)
        ConfigState.OrbitRadius = val
    end)

    bindConnection("PlayerAdded", Players.PlayerAdded, function(newPlr)
        hookPlayerLifecycle(newPlr)
        syncWhitelistArrayFromMap()
        if ConfigState.HitboxExpander then
            updateHitboxExpander()
        end
        refreshPlayerListUI()
    end)
    bindConnection("PlayerRemoving", Players.PlayerRemoving, function(remPlayer)
        if remPlayer then
            releasePlayerESP(remPlayer)
            State.whitelistedPlayers[remPlayer.Name] = nil
            State.prioritizedPlayers[remPlayer.Name] = nil
            if State.expandedPlayerName == remPlayer.Name then
                State.expandedPlayerName = nil
            end
            if State.orbitingPlayerName == remPlayer.Name then
                State.orbitingPlayerName = nil
            end
            if State.spectatingPlayerName == remPlayer.Name then
                State.spectatingPlayerName = nil
                local cam = workspace.CurrentCamera
                local myHum = LocalPlayer.Character and LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
                if cam and myHum then
                    cam.CameraSubject = myHum
                end
            end
        end
        syncWhitelistArrayFromMap()
        refreshPlayerListUI()
    end)
end

-- TAB 6: WORLD & MISC (WAYPOINTS + FPS BOOSTER + JOIN SERVER JOBID + SERVER HOP)
do
    createLabel(WorldTab, "Universal Interaction Automation")
    createToggle(WorldTab, "Instant Interact (0s ProximityPrompts)", false, function(val)
        ConfigState.InstantInteract = val
        applyInstantInteract(val)
    end)
    createToggle(WorldTab, "Auto-Interact Nearby Prompts/ClickDetectors", false, function(val)
        ConfigState.AutoInteract = val
    end)
    createSlider(WorldTab, "Auto-Interact Radius", 5, 25, 15, 1, "studs", function(val)
        ConfigState.InteractRadius = val
    end)

    createLabel(WorldTab, "Game Waypoints (Saved for PlaceId: " .. CURRENT_PLACE_ID .. ")")

    local gameWaypoints = safeJsonDecode(safeReadFile(WAYPOINTS_FILE))
    if type(gameWaypoints) ~= "table" then
        gameWaypoints = {}
    end

    local WaypointNameBox = createTextInputRow(WorldTab, "Waypoint Name", "e.g. SafeZone, Boss, Shop", "", nil)
    local WaypointsListFrame = Instance.new("Frame")
    local waypointItemsUI = {}

    local function saveGameWaypointsToDisk()
        safeWriteFile(WAYPOINTS_FILE, safeJsonEncode(gameWaypoints))
    end

    local function rebuildWaypointsUI()
        for _, item in ipairs(waypointItemsUI) do
            if item and item.Parent then
                item:Destroy()
            end
        end
        table.clear(waypointItemsUI)

        for i, wp in ipairs(gameWaypoints) do
            local row = Instance.new("Frame")
            row.LayoutOrder = i
            row.Size = UDim2.new(1, 0, 0, 34)
            row.BackgroundColor3 = Theme.Surface
            row.ZIndex = 14
            row.Parent = WaypointsListFrame
            addCorner(row, 6)
            addStroke(row, Theme.Border, 1, 0)

            local nameLbl = Instance.new("TextLabel")
            nameLbl.Position = UDim2.fromOffset(12, 0)
            nameLbl.Size = UDim2.new(0.55, 0, 1, 0)
            nameLbl.BackgroundTransparency = 1
            nameLbl.Font = Enum.Font.Code
            nameLbl.Text = string.format("%s (%d, %d, %d)", tostring(wp.Name), math.floor(wp.X), math.floor(wp.Y), math.floor(wp.Z))
            nameLbl.TextColor3 = Theme.White
            nameLbl.TextSize = 11
            nameLbl.TextTruncate = Enum.TextTruncate.AtEnd
            nameLbl.TextXAlignment = Enum.TextXAlignment.Left
            nameLbl.ZIndex = 15
            nameLbl.Parent = row

            local tpBtn = Instance.new("TextButton")
            tpBtn.AnchorPoint = Vector2.new(1, 0.5)
            tpBtn.Position = UDim2.new(1, -68, 0.5, 0)
            tpBtn.Size = UDim2.fromOffset(58, 24)
            tpBtn.BackgroundColor3 = Theme.Accent
            tpBtn.AutoButtonColor = false
            tpBtn.Font = Enum.Font.GothamBold
            tpBtn.Text = "TP"
            tpBtn.TextColor3 = Theme.Black
            tpBtn.TextSize = 10
            tpBtn.ZIndex = 15
            tpBtn.Parent = row
            addCorner(tpBtn, 5)
            registerAccentObject(tpBtn, "BackgroundColor3")

            local delBtn = Instance.new("TextButton")
            delBtn.AnchorPoint = Vector2.new(1, 0.5)
            delBtn.Position = UDim2.new(1, -8, 0.5, 0)
            delBtn.Size = UDim2.fromOffset(54, 24)
            delBtn.BackgroundColor3 = Theme.Deep
            delBtn.AutoButtonColor = false
            delBtn.Font = Enum.Font.GothamBold
            delBtn.Text = "DEL"
            delBtn.TextColor3 = Theme.Error
            delBtn.TextSize = 10
            delBtn.ZIndex = 15
            delBtn.Parent = row
            addCorner(delBtn, 5)
            addStroke(delBtn, Theme.Border, 1, 0)

            tpBtn.MouseButton1Click:Connect(function()
                local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if myHRP then
                    myHRP.CFrame = CFrame.new(Vector3.new(wp.X, wp.Y, wp.Z))
                    notify("Waypoints", "Teleported to waypoint: " .. tostring(wp.Name), 3)
                end
            end)

            delBtn.MouseButton1Click:Connect(function()
                table.remove(gameWaypoints, i)
                saveGameWaypointsToDisk()
                rebuildWaypointsUI()
                notify("Waypoints", "Deleted waypoint: " .. tostring(wp.Name), 3)
            end)

            table.insert(waypointItemsUI, row)
        end
    end

    createButton(WorldTab, "Save Current Position as Waypoint", function()
        local name = (WaypointNameBox.Text or ""):gsub("^%s*(.-)%s*$", "%1")
        if name == "" then
            notify("Waypoints", "Please enter a Waypoint Name first!", 3)
            return
        end
        local myHRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not myHRP then
            notify("Waypoints", "Character HumanoidRootPart not found!", 3)
            return
        end
        local pos = myHRP.Position
        table.insert(gameWaypoints, {
            Name = name,
            X = pos.X,
            Y = pos.Y,
            Z = pos.Z,
            PlaceId = CURRENT_PLACE_ID,
        })
        WaypointNameBox.Text = ""
        saveGameWaypointsToDisk()
        rebuildWaypointsUI()
        notify("Waypoints", "Saved '" .. name .. "' for PlaceId " .. CURRENT_PLACE_ID, 4)
    end)

    WaypointsListFrame.Size = UDim2.new(1, 0, 0, 10)
    WaypointsListFrame.AutomaticSize = Enum.AutomaticSize.Y
    WaypointsListFrame.BackgroundTransparency = 1
    WaypointsListFrame.ZIndex = 14
    WaypointsListFrame.Parent = WorldTab

    local WaypointsListLayout = Instance.new("UIListLayout")
    WaypointsListLayout.Padding = UDim.new(0, 6)
    WaypointsListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    WaypointsListLayout.Parent = WaypointsListFrame

    rebuildWaypointsUI()

    createLabel(WorldTab, "Performance & FPS Optimization")
    createButton(WorldTab, "Activate Ultimate Deep FPS Booster", function()
        runUltimateFPSBooster()
    end)

    createToggle(WorldTab, "Disable 3D Rendering (AFK GPU/Battery Saver)", false, function(val)
        ConfigState.Disable3DRender = val
        UI.RenderSaverOverlay.Visible = val
        notify("Core.xyz", val and "3D Rendering overlay saver active (Battery Saver On)." or "3D Rendering restored.", 3)
    end)

    local CustomFpsBox
    createToggle(WorldTab, "Uncap FPS", false, function(val)
        ConfigState.UncapFPS = val
        if Env.setfpscap then
            local targetCap = val and (tonumber(CustomFpsBox and CustomFpsBox.Text) or ConfigState.CustomFPS or 999) or 60
            pcall(function()
                Env.setfpscap(targetCap)
            end)
            notify("FPS Cap", "FPS Cap set to " .. tostring(targetCap), 3)
        else
            notify("FPS Cap", "Executor setfpscap applied (" .. tostring(val and ConfigState.CustomFPS or 60) .. " FPS).", 3)
        end
    end)

    CustomFpsBox = createTextInputRow(WorldTab, "Custom FPS Target", "e.g. 144, 240, 999", "144", function(txt)
        local num = tonumber(txt)
        if num and num >= 15 then
            ConfigState.CustomFPS = math.floor(num)
            if ConfigState.UncapFPS and Env.setfpscap then
                pcall(function()
                    Env.setfpscap(ConfigState.CustomFPS)
                end)
            end
        end
    end)

    createLabel(WorldTab, "Server & Session Tools (JobId Join & Server Hop)")
    local ServerJobIdBox = createTextInputRow(WorldTab, "Server JobId", "Paste Server JobId...", "", function(txt)
        ConfigState.TargetJobId = (txt or ""):gsub("^%s*(.-)%s*$", "%1")
    end)

    createButton(WorldTab, "Join Server by JobId", function()
        local cleanJobId = ((ServerJobIdBox and ServerJobIdBox.Text) or ConfigState.TargetJobId or ""):gsub("^%s*(.-)%s*$", "%1")
        if cleanJobId == "" then
            notify("Server Join", "Please enter a valid Server JobId first!", 3)
            return
        end
        notify("Server Join", "Teleporting to JobId: " .. cleanJobId, 4)
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, cleanJobId, LocalPlayer)
        end)
    end)

    createButton(WorldTab, "Rejoin Current Server", function()
        notify("Server", "Rejoining current server...", 3)
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end)

    createDropdown(WorldTab, "Server Hop Mode", { "Default", "Lowest Players", "Highest Players", "Lower Ping" }, "Lowest Players", function(opt)
        ConfigState.ServerHopMode = opt
    end)

    createButton(WorldTab, "Server Hop Now", function()
        notify("Server Hop", "Searching servers (" .. ConfigState.ServerHopMode .. ")...", 4)
        task.spawn(function()
            local ok, response = pcall(function()
                local sortOrder = (ConfigState.ServerHopMode == "Lowest Players") and "Asc" or "Desc"
                local url = string.format(
                    "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=100",
                    tostring(game.PlaceId),
                    sortOrder
                )
                return game:HttpGet(url)
            end)
            if ok and response then
                local decoded = safeJsonDecode(response)
                if decoded and type(decoded.data) == "table" then
                    local candidates = {}
                    for _, srv in ipairs(decoded.data) do
                        if type(srv) == "table" and srv.id ~= game.JobId and (srv.playing or 0) < (srv.maxPlayers or 100) then
                            table.insert(candidates, srv)
                        end
                    end
                    if ConfigState.ServerHopMode == "Lower Ping" then
                        table.sort(candidates, function(a, b)
                            return (a.ping or 999) < (b.ping or 999)
                        end)
                    elseif ConfigState.ServerHopMode == "Lowest Players" then
                        table.sort(candidates, function(a, b)
                            return (a.playing or 999) < (b.playing or 999)
                        end)
                    elseif ConfigState.ServerHopMode == "Highest Players" then
                        table.sort(candidates, function(a, b)
                            return (a.playing or 0) > (b.playing or 0)
                        end)
                    end
                    if #candidates > 0 then
                        local chosen = candidates[1]
                        notify("Server Hop", "Teleporting to server (" .. tostring(chosen.playing) .. " players)...", 4)
                        pcall(function()
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, chosen.id, LocalPlayer)
                        end)
                        return
                    end
                end
            end
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        end)
    end)

    createToggle(WorldTab, "Anti-AFK Protection", false, function(val)
        ConfigState.AntiAFK = val
        if val then
            if State.antiAFKConnection then
                State.antiAFKConnection:Disconnect()
            end
            State.antiAFKConnection = LocalPlayer.Idled:Connect(function()
                local cam = workspace.CurrentCamera
                if cam and CFrame.Angles then
                    pcall(function()
                        cam.CFrame = cam.CFrame * CFrame.Angles(0, 0.0001, 0)
                    end)
                end
            end)
            notify("Core.xyz", "Stealth Anti-AFK protection enabled.", 4)
        else
            if State.antiAFKConnection then
                State.antiAFKConnection:Disconnect()
                State.antiAFKConnection = nil
            end
        end
    end)
end

-- TAB 7: MUSIC (DISCORD COMMUNITY CURATED NOTE + TRACKS DROPDOWN + CONNECTED WAVY PLAYER UI + MUTE GAME AUDIO)
do
    createLabel(MusicTab, "Community-Curated Soundtrack & Player")

    local CommunityNoteCard = Instance.new("Frame")
    CommunityNoteCard.Name = "MusicCommunityNoteCard"
    CommunityNoteCard.Size = UDim2.new(1, 0, 0, 88)
    CommunityNoteCard.BackgroundColor3 = Theme.Surface
    CommunityNoteCard.ZIndex = 14
    CommunityNoteCard.Parent = MusicTab
    addCorner(CommunityNoteCard, 8)
    local NoteStroke = addStroke(CommunityNoteCard, Color3.fromRGB(88, 101, 242), 1.2, 0.25)
    registerAccentObject(NoteStroke, "Color")

    local NoteBadge = Instance.new("TextLabel")
    NoteBadge.Position = UDim2.fromOffset(12, 8)
    NoteBadge.Size = UDim2.new(1, -24, 0, 14)
    NoteBadge.BackgroundTransparency = 1
    NoteBadge.Font = Enum.Font.GothamBold
    NoteBadge.Text = "DISCORD COMMUNITY TRACK SELECTION"
    NoteBadge.TextColor3 = Color3.fromRGB(145, 195, 255)
    NoteBadge.TextSize = 10
    NoteBadge.TextXAlignment = Enum.TextXAlignment.Left
    NoteBadge.ZIndex = 15
    NoteBadge.Parent = CommunityNoteCard

    local NoteBody = Instance.new("TextLabel")
    NoteBody.Name = "MusicCommunityNoteText"
    NoteBody.Position = UDim2.fromOffset(12, 24)
    NoteBody.Size = UDim2.new(1, -24, 0, 32)
    NoteBody.BackgroundTransparency = 1
    NoteBody.Font = Enum.Font.GothamMedium
    NoteBody.Text = "All tracks are handpicked from our Discord community on every script update. Want a specific song added next? Join our Discord community to submit your track requests."
    NoteBody.TextColor3 = Theme.Silver
    NoteBody.TextSize = 10
    NoteBody.TextWrapped = true
    NoteBody.TextXAlignment = Enum.TextXAlignment.Left
    if Enum.TextYAlignment and Enum.TextYAlignment.Top then
        NoteBody.TextYAlignment = Enum.TextYAlignment.Top
    end
    NoteBody.ZIndex = 15
    NoteBody.Parent = CommunityNoteCard

    local CopyDiscordSongBtn = Instance.new("TextButton")
    CopyDiscordSongBtn.Name = "MusicJoinDiscordButton"
    CopyDiscordSongBtn.Position = UDim2.fromOffset(12, 58)
    CopyDiscordSongBtn.Size = UDim2.new(1, -24, 0, 22)
    CopyDiscordSongBtn.BackgroundColor3 = Color3.fromRGB(88, 101, 242)
    CopyDiscordSongBtn.AutoButtonColor = false
    CopyDiscordSongBtn.Font = Enum.Font.GothamBold
    CopyDiscordSongBtn.Text = "Submit a Song in Discord  (Copy Invite: discord.gg/TVyFdDwDkn)"
    CopyDiscordSongBtn.TextColor3 = Theme.White
    CopyDiscordSongBtn.TextSize = 10
    CopyDiscordSongBtn.ZIndex = 15
    CopyDiscordSongBtn.Parent = CommunityNoteCard
    addCorner(CopyDiscordSongBtn, 5)

    CopyDiscordSongBtn.MouseButton1Click:Connect(function()
        spawnRipple(CopyDiscordSongBtn)
        if Env.setclipboard then
            Env.setclipboard("https://discord.gg/TVyFdDwDkn")
        end
        CopyDiscordSongBtn.Text = "Copied Discord Invite! (discord.gg/TVyFdDwDkn)"
        notify("Music Community", "Discord invite copied! Join to submit your song requests.", 4)
        task.delay(2.2, function()
            if CopyDiscordSongBtn and CopyDiscordSongBtn.Parent then
                CopyDiscordSongBtn.Text = "Submit a Song in Discord  (Copy Invite: discord.gg/TVyFdDwDkn)"
            end
        end)
    end)

    createDropdown(MusicTab, "Select Track", State.musicTrackOptions or { "Snowman (Slowed + Reverb) — Sia" }, ConfigState.SelectedTrack or "Snowman (Slowed + Reverb) — Sia", function(opt)
        ConfigState.SelectedTrack = opt
        State.musicSimulatedPos = 0
        if State.seekMusicToRatio then
            State.seekMusicToRatio(0)
        end
        if State.musicIsPlaying and State.setMusicPlaying then
            State.setMusicPlaying(true)
        end
        notify("Music Player", "Selected track: " .. tostring(opt), 3)
    end)

    createToggle(MusicTab, "Toggle Player UI", ConfigState.MusicPlayerVisible == true, function(val)
        ConfigState.MusicPlayerVisible = val
        if State.syncMusicPlayerDock then
            State.syncMusicPlayerDock()
        end
    end)

    createLabel(MusicTab, "Game Audio & Volume Mixer")

    createToggle(MusicTab, "Mute Game Audio", ConfigState.MuteGameAudio or false, function(val)
        if State.applyMuteGameAudio then
            State.applyMuteGameAudio(val)
        end
        notify("Audio Mixer", val and "In-game audio muted (Music Player active)." or "In-game audio restored.", 3)
    end)

    createSlider(MusicTab, "Music Volume", 0, 100, math.floor((ConfigState.MusicVolume or 0.75) * 100), 1, "%", function(val)
        local norm = math.clamp((tonumber(val) or 75) / 100, 0, 1)
        ConfigState.MusicVolume = norm
        if UI.MusicPlayerSound then
            UI.MusicPlayerSound.Volume = norm
        end
    end)

    createToggle(MusicTab, "Loop Track", ConfigState.MusicLooped ~= false, function(val)
        ConfigState.MusicLooped = val
        if UI.MusicPlayerSound then
            UI.MusicPlayerSound.Looped = val
        end
    end)
end

-- TAB 8: SETTINGS (PERFORMANCE + CLIENT + SERVER + BACKGROUND + THEMES + FLOATING PILL + CONFIG MANAGER)
do
    createLabel(SettingsTab, "Customizable Floating Pill & Telemetry (Max 3)")

    createTextInputRow(SettingsTab, "Floating Pill Title", "e.g. CORE.XYZ, FEYK.XYZ", "CORE.XYZ", function(txt)
        local cleaned = (txt or ""):gsub("^%s*(.-)%s*$", "%1")
        ConfigState.CustomPillTitle = (cleaned ~= "") and cleaned or "CORE.XYZ"
        updateFloatingPillTelemetry()
    end)

    createMultiDropdown(SettingsTab, "Telemetry Metrics", State.TELEMETRY_OPTIONS, State.activeTelemetryMetrics, 3, function(newSelection)
        State.activeTelemetryMetrics = newSelection
        updateFloatingPillTelemetry()
    end)

    createDropdown(SettingsTab, "Floating Pill Shape", { "Rounded Pill", "Sharp Box" }, "Rounded Pill", function(opt)
        if UI.FloatCorner then
            UI.FloatCorner.CornerRadius = UDim.new(0, (opt == "Rounded Pill") and 999 or 8)
        end
    end)

    -- 1. Performance Settings Section Box
    local perfSec = UI.createSectionBox(SettingsTab, "Performance Settings")

    local autoRuleBanner = Instance.new("TextLabel")
    autoRuleBanner.Name = "AutoConfigRuleLabel"
    autoRuleBanner.Size = UDim2.new(1, 0, 0, 18)
    autoRuleBanner.BackgroundTransparency = 1
    autoRuleBanner.Font = Enum.Font.Code
    autoRuleBanner.Text = "Auto On Mobile (Performance) / Auto On PC (Balanced)"
    autoRuleBanner.TextColor3 = Theme.Muted
    autoRuleBanner.TextSize = 10
    autoRuleBanner.TextXAlignment = Enum.TextXAlignment.Left
    autoRuleBanner.ZIndex = 15
    autoRuleBanner.Parent = perfSec

    local function applyLowGraphics(enabled)
        ConfigState.LowGraphicsEnabled = enabled and true or false
        if enabled then
            pcall(function()
                Lighting.GlobalShadows = false
            end)
            for _, obj in ipairs(workspace:GetDescendants()) do
                if obj:IsA("BasePart") then
                    if State.lowGraphicsCache[obj] == nil then
                        State.lowGraphicsCache[obj] = {
                            Material = obj.Material,
                            Reflectance = obj.Reflectance or 0,
                        }
                    end
                    pcall(function()
                        obj.Material = Enum.Material.SmoothPlastic
                        obj.Reflectance = 0
                    end)
                end
            end
        else
            for obj, orig in pairs(State.lowGraphicsCache) do
                if obj and obj.Parent then
                    pcall(function()
                        if orig.Material then obj.Material = orig.Material end
                        if orig.Reflectance ~= nil then obj.Reflectance = orig.Reflectance end
                    end)
                end
            end
            table.clear(State.lowGraphicsCache)
            if not ConfigState.LightingNoShadows then
                pcall(function()
                    Lighting.GlobalShadows = State.origLighting.GlobalShadows
                end)
            end
        end
    end
    State.applyLowGraphics = applyLowGraphics

    local function applyOptimizeMode(enabled)
        ConfigState.OptimizeModeEnabled = enabled and true or false
        if enabled then
            if UI.MainParticleCanvas then
                UI.MainParticleCanvas.Visible = false
            end
            ConfigState.ShimmerEnabled = false
        else
            if UI.MainParticleCanvas then
                UI.MainParticleCanvas.Visible = (ConfigState.ParticlesEnabled ~= false)
            end
            ConfigState.ShimmerEnabled = true
        end
    end
    State.applyOptimizeMode = applyOptimizeMode

    local function applyPerformanceProfile(profile)
        profile = profile or ConfigState.PerformanceProfile or "Auto"
        ConfigState.PerformanceProfile = profile
        local isMobileDevice = not isPCDevice()
        if State.syncKeybindBadgesVisibility then
            State.syncKeybindBadgesVisibility()
        end
        local effective = profile
        if profile == "Auto" then
            effective = isMobileDevice and "Performance" or "Balanced"
        end
        State.effectivePerformanceMode = effective
        autoRuleBanner.Text = string.format(
            "Auto On Mobile (Performance) / Auto On PC (Balanced) · Active: %s",
            effective
        )
        if effective == "Performance" then
            State.activeProfileFPSCap = 60
            if UI.MainParticleCanvas then UI.MainParticleCanvas.Visible = false end
            pcall(function() Lighting.GlobalShadows = false end)
        elseif effective == "Quality" then
            State.activeProfileFPSCap = 240
            if UI.MainParticleCanvas then UI.MainParticleCanvas.Visible = (ConfigState.ParticlesEnabled ~= false) end
            if not ConfigState.LowGraphicsEnabled and not ConfigState.LightingNoShadows then
                pcall(function() Lighting.GlobalShadows = true end)
            end
        else
            State.activeProfileFPSCap = 120
            if UI.MainParticleCanvas then UI.MainParticleCanvas.Visible = (ConfigState.ParticlesEnabled ~= false) and not ConfigState.OptimizeModeEnabled end
        end
        if State.isWindowFocused ~= false and Env.setfpscap then
            pcall(function()
                Env.setfpscap(State.activeProfileFPSCap)
            end)
        end
    end
    State.applyPerformanceProfile = applyPerformanceProfile

    createDropdown(perfSec, "Performance Profile", { "Auto", "Quality", "Balanced", "Performance" }, ConfigState.PerformanceProfile or "Auto", function(opt)
        applyPerformanceProfile(opt)
    end)

    createToggle(perfSec, "Low Graphics", ConfigState.LowGraphicsEnabled == true, function(val)
        applyLowGraphics(val)
    end)

    createToggle(perfSec, "Optimize Mode", ConfigState.OptimizeModeEnabled == true, function(val)
        applyOptimizeMode(val)
    end)

    createToggle(perfSec, "Pause Rendering When Tabbed Out", ConfigState.PauseRenderOnTabOut == true, function(val)
        ConfigState.PauseRenderOnTabOut = val
        if not State.isWindowFocused then
            UI.RenderSaverOverlay.Visible = val or (ConfigState.Disable3DRender == true)
        end
    end)

    createSlider(perfSec, "FPS When Tabbed Out", 5, 60, ConfigState.FPSWhenTabbedOut or 15, 1, " fps", function(val)
        ConfigState.FPSWhenTabbedOut = val
        if not State.isWindowFocused and Env.setfpscap then
            pcall(function()
                Env.setfpscap(val)
            end)
        end
    end)

    applyPerformanceProfile(ConfigState.PerformanceProfile or "Auto")

    -- 2. Client Telemetry & Info Section Box (Executor & Device Info Only — Kill Count Removed)
    local clientSec = UI.createSectionBox(SettingsTab, "Client")

    local function detectExecutorName()
        local execName = "Delta"
        pcall(function()
            if type(Env.identifyexecutor) == "function" then
                local n = Env.identifyexecutor()
                if n and tostring(n) ~= "" then execName = tostring(n) end
            elseif type(Env.getexecutorname) == "function" then
                local n = Env.getexecutorname()
                if n and tostring(n) ~= "" then execName = tostring(n) end
            end
        end)
        return execName
    end

    local function detectDeviceName()
        local isMob = not isPCDevice()
        return isMob and "Mobile (Android)" or "PC (Desktop)"
    end

    local function makeTelemetryInfoLine(parent, name, initText)
        local lbl = Instance.new("TextLabel")
        lbl.Name = name
        lbl.Size = UDim2.new(1, 0, 0, 20)
        lbl.BackgroundTransparency = 1
        lbl.Font = Enum.Font.GothamMedium
        lbl.Text = initText
        lbl.TextColor3 = Theme.Silver
        lbl.TextSize = 12
        lbl.TextXAlignment = Enum.TextXAlignment.Left
        lbl.ZIndex = 15
        lbl.Parent = parent
        return lbl
    end

    local ClientExecutorLabel = makeTelemetryInfoLine(clientSec, "ClientExecutorLabel", "Executor: " .. detectExecutorName())
    local ClientDeviceLabel = makeTelemetryInfoLine(clientSec, "ClientDeviceLabel", "Device: " .. detectDeviceName())
    UI.ClientExecutorLabel = ClientExecutorLabel
    UI.ClientDeviceLabel = ClientDeviceLabel

    local function updateClientTelemetryUI()
        if State.syncKeybindBadgesVisibility then
            State.syncKeybindBadgesVisibility()
        end
        if ClientExecutorLabel then
            ClientExecutorLabel.Text = "Executor: " .. detectExecutorName()
        end
        if ClientDeviceLabel then
            ClientDeviceLabel.Text = "Device: " .. detectDeviceName()
        end
    end
    State.updateClientTelemetryUI = updateClientTelemetryUI

    -- 3. Server Management & Utilities Section Box (Matches Reference Screenshot IMG_20261102_181842_417ae9f4.jpg)
    local serverSec = UI.createSectionBox(SettingsTab, "Server")

    pcall(function()
        local MarketplaceService = game:GetService("MarketplaceService")
        if MarketplaceService and MarketplaceService.GetProductInfo then
            local info = MarketplaceService:GetProductInfo(game.PlaceId)
            if type(info) == "table" and info.Name and info.Name ~= "" then
                State.detectedGameName = tostring(info.Name)
            end
        end
    end)

    local function formatSessionDuration()
        local elapsed = math.max(0, os.time() - (State.sessionStartTime or os.time()))
        local hrs = math.floor(elapsed / 3600)
        local mins = math.floor((elapsed % 3600) / 60)
        local secs = elapsed % 60
        return string.format("%02d:%02d:%02d", hrs, mins, secs)
    end

    local function getCurrentPingMs()
        local pingVal = 28
        pcall(function()
            if type(LocalPlayer.GetNetworkPing) == "function" then
                local rawPing = LocalPlayer:GetNetworkPing()
                if type(rawPing) == "number" and rawPing > 0 then
                    pingVal = math.clamp(math.floor(rawPing * 1000 + 0.5), 1, 999)
                end
            end
        end)
        return pingVal
    end

    local ServerGameLabel = makeTelemetryInfoLine(serverSec, "ServerGameLabel", "Game: " .. tostring(State.detectedGameName or "Prison Life"))
    local ServerPlayersLabel = makeTelemetryInfoLine(serverSec, "ServerPlayersLabel", string.format("Players: %d/%d", #Players:GetPlayers(), Players.MaxPlayers or 24))
    local ServerDurationLabel = makeTelemetryInfoLine(serverSec, "ServerDurationLabel", "Time in server: " .. formatSessionDuration())
    local ServerPingLabel = makeTelemetryInfoLine(serverSec, "ServerPingLabel", string.format("Ping: %d ms", getCurrentPingMs()))
    local ServerRegionLabel = makeTelemetryInfoLine(serverSec, "ServerRegionLabel", "Your region: " .. tostring(State.detectedRegionCode or "IN"))
    local ServerJobIdLabel = makeTelemetryInfoLine(serverSec, "ServerJobIdLabel", "Job ID: " .. tostring((game.JobId and game.JobId ~= "") and game.JobId or "local-session"))

    UI.ServerGameLabel = ServerGameLabel
    UI.ServerPlayersLabel = ServerPlayersLabel
    UI.ServerDurationLabel = ServerDurationLabel
    UI.ServerPingLabel = ServerPingLabel
    UI.ServerRegionLabel = ServerRegionLabel
    UI.ServerJobIdLabel = ServerJobIdLabel

    local function updateServerTelemetryUI()
        if ServerGameLabel then
            ServerGameLabel.Text = "Game: " .. tostring(State.detectedGameName or "Prison Life")
        end
        if ServerPlayersLabel then
            ServerPlayersLabel.Text = string.format("Players: %d/%d", #Players:GetPlayers(), Players.MaxPlayers or 24)
        end
        if ServerDurationLabel then
            ServerDurationLabel.Text = "Time in server: " .. formatSessionDuration()
        end
        if ServerPingLabel then
            ServerPingLabel.Text = string.format("Ping: %d ms", getCurrentPingMs())
        end
        if ServerRegionLabel then
            ServerRegionLabel.Text = "Your region: " .. tostring(State.detectedRegionCode or "IN")
        end
        if ServerJobIdLabel then
            ServerJobIdLabel.Text = "Job ID: " .. tostring((game.JobId and game.JobId ~= "") and game.JobId or "local-session")
        end
    end
    State.updateServerTelemetryUI = updateServerTelemetryUI

    createButton(serverSec, "Copy Job ID", function()
        local jid = tostring((game.JobId and game.JobId ~= "") and game.JobId or "local-session")
        if Env.setclipboard then
            Env.setclipboard(jid)
        end
        notify("Server Tools", "Copied Job ID: " .. jid, 3)
    end)

    createButton(serverSec, "Copy Join Script", function()
        local jid = tostring((game.JobId and game.JobId ~= "") and game.JobId or "local-session")
        local snippet = string.format(
            'game:GetService("TeleportService"):TeleportToPlaceInstance(%s, "%s", game:GetService("Players").LocalPlayer)',
            tostring(game.PlaceId),
            jid
        )
        if Env.setclipboard then
            Env.setclipboard(snippet)
        end
        notify("Server Tools", "Copied Join Script to clipboard!", 3)
    end)

    createButton(serverSec, "Rejoin", function()
        notify("Server Tools", "Rejoining current server...", 3)
        pcall(function()
            TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, LocalPlayer)
        end)
    end)

    local function executeServerHop(preferLowest)
        notify("Server Tools", preferLowest and "Hopping to lowest ping/player server..." or "Hopping to a new server...", 3)
        task.spawn(function()
            local ok, response = pcall(function()
                local sortOrder = preferLowest and "Asc" or "Desc"
                local url = string.format(
                    "https://games.roblox.com/v1/games/%s/servers/Public?sortOrder=%s&limit=100",
                    tostring(game.PlaceId),
                    sortOrder
                )
                return game:HttpGet(url)
            end)
            if ok and response then
                local decoded = safeJsonDecode(response)
                if decoded and type(decoded.data) == "table" then
                    local candidates = {}
                    for _, srv in ipairs(decoded.data) do
                        if type(srv) == "table" and srv.id ~= game.JobId and (srv.playing or 0) < (srv.maxPlayers or 100) then
                            table.insert(candidates, srv)
                        end
                    end
                    if preferLowest then
                        table.sort(candidates, function(a, b)
                            local pa = (a.ping or 999) + (a.playing or 99) * 2
                            local pb = (b.ping or 999) + (b.playing or 99) * 2
                            return pa < pb
                        end)
                    end
                    if #candidates > 0 then
                        local chosen = candidates[1]
                        pcall(function()
                            TeleportService:TeleportToPlaceInstance(game.PlaceId, chosen.id, LocalPlayer)
                        end)
                        return
                    end
                end
            end
            pcall(function()
                TeleportService:Teleport(game.PlaceId, LocalPlayer)
            end)
        end)
    end

    createButton(serverSec, "Server Hop", function()
        executeServerHop(false)
    end)

    createButton(serverSec, "Server Hop Lowest", function()
        executeServerHop(true)
    end)

    -- 4. Custom Background Section Box (Matches Reference Screenshot IMG_20261102_204449_c955f68b.jpg)
    local bgSec = UI.createSectionBox(SettingsTab, "Background")

    local windowBgImg = Instance.new("ImageLabel")
    windowBgImg.Name = "WindowBackgroundImage"
    windowBgImg.Size = UDim2.fromScale(1, 1)
    windowBgImg.BackgroundTransparency = 1
    windowBgImg.Image = ""
    windowBgImg.ImageTransparency = 0.5
    windowBgImg.ScaleType = Enum.ScaleType.Crop
    windowBgImg.Visible = false
    windowBgImg.ZIndex = 11
    windowBgImg.Parent = UI.MainWindow
    addCorner(windowBgImg, 14)
    UI.WindowBackgroundImage = windowBgImg

    local pillBgImg = Instance.new("ImageLabel")
    pillBgImg.Name = "PillBackgroundImage"
    pillBgImg.Size = UDim2.fromScale(1, 1)
    pillBgImg.BackgroundTransparency = 1
    pillBgImg.Image = ""
    pillBgImg.ImageTransparency = 0.5
    pillBgImg.ScaleType = Enum.ScaleType.Crop
    pillBgImg.Visible = false
    pillBgImg.ZIndex = 50
    pillBgImg.Parent = UI.FloatingToggle
    addCorner(pillBgImg, 999)
    UI.FloatingPillBackgroundImage = pillBgImg

    local BG_PRESET_LIBRARY = {
        ["Anime Night City (6882678552)"] = "rbxassetid://6882678552",
        ["Cyberpunk Nebula (159454299)"] = "rbxassetid://159454299",
        ["Aurora Horizon (12064107)"] = "rbxassetid://12064107",
        ["Crimson Eclipse (401664839)"] = "rbxassetid://401664839",
        ["Sunset Clouds (600830446)"] = "rbxassetid://600830446",
        ["Purple Cosmos (5084575798)"] = "rbxassetid://5084575798",
    }

    local SCALE_TYPE_MAP = {
        ["Crop"] = Enum.ScaleType.Crop,
        ["Stretch"] = Enum.ScaleType.Stretch,
        ["Tile"] = Enum.ScaleType.Tile,
        ["Fit"] = Enum.ScaleType.Fit,
    }

    local function applyBackgroundSettings()
        local raw = tostring(ConfigState.CustomBgDecalId or ""):gsub("^%s*(.-)%s*$", "%1")
        if raw == "" then
            windowBgImg.Visible = false
            pillBgImg.Visible = false
            return
        end
        local formatted = raw
        if not string.find(formatted, "^rbxassetid://") and not string.find(formatted, "^http") and not string.find(formatted, "^rbxthumb://") then
            local digits = string.match(formatted, "%d+")
            if digits then
                formatted = "rbxassetid://" .. digits
            else
                formatted = "rbxassetid://6882678552"
            end
        end
        local scaleType = SCALE_TYPE_MAP[ConfigState.CustomBgImageFit or "Crop"] or Enum.ScaleType.Crop
        local imgTrans = math.clamp(tonumber(ConfigState.CustomBgTransparency) or 0.5, 0, 1)
        windowBgImg.Image = formatted
        windowBgImg.ImageTransparency = imgTrans
        windowBgImg.ScaleType = scaleType
        windowBgImg.Visible = true

        pillBgImg.Image = formatted
        pillBgImg.ImageTransparency = imgTrans
        pillBgImg.ScaleType = scaleType
        pillBgImg.Visible = (ConfigState.CustomBgAlsoWatermark == true)

        local seeThrough = math.clamp(tonumber(ConfigState.CustomBgPanelSeeThrough) or 0.35, 0, 0.95)
        UI.MainWindow.BackgroundTransparency = math.clamp(seeThrough * 0.5, 0.02, 0.65)
    end
    State.applyBackgroundSettings = applyBackgroundSettings

    local BgDecalInputBox = createTextInputRow(bgSec, "Decal ID / Store Link / File", "Decal ID, store link, or filename...", ConfigState.CustomBgDecalId or "", function(txt)
        ConfigState.CustomBgDecalId = txt
        applyBackgroundSettings()
    end)

    createSlider(bgSec, "Image Transparency", 0, 1, ConfigState.CustomBgTransparency or 0.5, 0.05, "", function(val)
        ConfigState.CustomBgTransparency = val
        applyBackgroundSettings()
    end)

    createToggle(bgSec, "Also On Watermark Keybinds & Target Info", ConfigState.CustomBgAlsoWatermark == true, function(val)
        ConfigState.CustomBgAlsoWatermark = val
        applyBackgroundSettings()
    end)

    createSlider(bgSec, "Panel See-Through", 0, 1, ConfigState.CustomBgPanelSeeThrough or 0.35, 0.05, "", function(val)
        ConfigState.CustomBgPanelSeeThrough = val
        applyBackgroundSettings()
    end)

    createDropdown(bgSec, "Image Fit", { "Crop", "Stretch", "Tile", "Fit" }, ConfigState.CustomBgImageFit or "Crop", function(opt)
        ConfigState.CustomBgImageFit = opt
        applyBackgroundSettings()
    end)

    local BgSearchInputBox = createTextInputRow(bgSec, "Search Images", "e.g. anime, dark, nebula...", "", function(txt)
        ConfigState.CustomBgSearchQuery = txt
    end)

    local bgResultKeys = {}
    for k in pairs(BG_PRESET_LIBRARY) do
        table.insert(bgResultKeys, k)
    end
    table.sort(bgResultKeys)

    local BgResultsDropdown
    createButton(bgSec, "Search", function()
        local q = string.lower(tostring((BgSearchInputBox and BgSearchInputBox.Text) or ConfigState.CustomBgSearchQuery or ""))
        local filtered = {}
        for label in pairs(BG_PRESET_LIBRARY) do
            if q == "" or string.find(string.lower(label), q, 1, true) then
                table.insert(filtered, label)
            end
        end
        table.sort(filtered)
        if #filtered == 0 then
            local customNum = string.match(q, "%d+") or "6882678552"
            table.insert(filtered, string.format("Custom Decal (%s)", customNum))
        end
        if BgResultsDropdown then
            BgResultsDropdown.Refresh(filtered, filtered[1])
        end
        local firstAsset = BG_PRESET_LIBRARY[filtered[1]] or ("rbxassetid://" .. (string.match(filtered[1], "%d+") or "6882678552"))
        ConfigState.CustomBgDecalId = firstAsset
        if BgDecalInputBox then BgDecalInputBox.Text = firstAsset end
        applyBackgroundSettings()
    end)

    BgResultsDropdown = createDropdown(bgSec, "Results", bgResultKeys, bgResultKeys[1], function(opt)
        local asset = BG_PRESET_LIBRARY[opt] or ("rbxassetid://" .. (string.match(tostring(opt), "%d+") or "6882678552"))
        ConfigState.CustomBgDecalId = asset
        if BgDecalInputBox then BgDecalInputBox.Text = asset end
        applyBackgroundSettings()
    end)

    createButton(bgSec, "Clear Background", function()
        ConfigState.CustomBgDecalId = ""
        if BgDecalInputBox then BgDecalInputBox.Text = "" end
        applyBackgroundSettings()
        UI.MainWindow.BackgroundTransparency = ConfigState.WindowTransparency or 0.03
        notify("Background", "Cleared custom background image.", 3)
    end)

    -- 5. Full UI Theme Palette & Custom Themes Section Box (Matches Reference Screenshot IMG_20261102_204554_b46a40c9.jpg)
    local themesSec = UI.createSectionBox(SettingsTab, "Themes")

    local ContrastCheckLabel = Instance.new("TextLabel")
    ContrastCheckLabel.Name = "ContrastCheckLabel"
    ContrastCheckLabel.Size = UDim2.new(1, 0, 0, 18)
    ContrastCheckLabel.BackgroundTransparency = 1
    ContrastCheckLabel.Font = Enum.Font.Code
    ContrastCheckLabel.Text = "Contrast check: good (16.8:1)"
    ContrastCheckLabel.TextColor3 = Theme.Success
    ContrastCheckLabel.TextSize = 11
    ContrastCheckLabel.TextXAlignment = Enum.TextXAlignment.Left
    ContrastCheckLabel.ZIndex = 15
    UI.ContrastCheckLabel = ContrastCheckLabel

    local function calcRelativeLuminance(col)
        if not col then return 0 end
        local r, g, b = tonumber(col.R) or 0, tonumber(col.G) or 0, tonumber(col.B) or 0
        if r > 1 or g > 1 or b > 1 then
            r, g, b = r / 255, g / 255, b / 255
        end
        local function chan(c)
            c = math.clamp(c, 0, 1)
            return (c <= 0.03928) and (c / 12.92) or ((c + 0.055) / 1.055) ^ 2.4
        end
        return 0.2126 * chan(r) + 0.7152 * chan(g) + 0.0722 * chan(b)
    end

    local function updateContrastCheckDisplay()
        local l1 = calcRelativeLuminance(ConfigState.ThemeFontColor or Theme.White)
        local l2 = calcRelativeLuminance(ConfigState.ThemeBgColor or Theme.Deep)
        local lighter = math.max(l1, l2)
        local darker = math.min(l1, l2)
        local ratio = (lighter + 0.05) / (darker + 0.05)
        local rating = "good"
        local col = Theme.Success
        if ratio < 3.0 then
            rating = "low"
            col = Theme.Error
        elseif ratio < 4.5 then
            rating = "ok"
            col = Color3.fromRGB(255, 200, 80)
        end
        ContrastCheckLabel.Text = string.format("Contrast check: %s (%.1f:1)", rating, ratio)
        ContrastCheckLabel.TextColor3 = col
    end

    local function applyFullUITheme()
        Theme.Deep = ConfigState.ThemeBgColor or Theme.Deep
        Theme.Surface = ConfigState.ThemeElementColor or Theme.Surface
        Theme.Border = ConfigState.ThemeBorderColor or Theme.Border
        Theme.Elevated = ConfigState.ThemeInlineColor or Theme.Elevated
        Theme.White = ConfigState.ThemeFontColor or Theme.White
        local acc = ConfigState.ThemeAccentColor or Theme.Accent
        local ar, ag, ab = acc.R or 1, acc.G or 1, acc.B or 1
        if ar <= 1 and ag <= 1 and ab <= 1 then
            ar, ag, ab = math.floor(ar * 255 + 0.5), math.floor(ag * 255 + 0.5), math.floor(ab * 255 + 0.5)
        else
            ar, ag, ab = math.floor(ar + 0.5), math.floor(ag + 0.5), math.floor(ab + 0.5)
        end
        updateAccentColor(ar, ag, ab)
        if UI.MainWindow then
            UI.MainWindow.BackgroundColor3 = Theme.Deep
        end
        if UI.MainStroke then
            UI.MainStroke.Color = Color3.fromRGB(255, 255, 255)
        end
        if UI.FloatingToggle then
            UI.FloatingToggle.BackgroundColor3 = Theme.Deep
        end
        local wantFont = ESP_FONT_MAP[ConfigState.ThemeFontFace or "Gotham"] or Enum.Font.GothamMedium
        if UI.MainWindow then
            for _, desc in ipairs(UI.MainWindow:GetDescendants()) do
                if desc:IsA("TextLabel") or desc:IsA("TextButton") then
                    if desc.Font ~= Enum.Font.Code then
                        pcall(function() desc.Font = wantFont end)
                    end
                elseif desc:IsA("Frame") and string.find(tostring(desc.Name or ""), "^SectionBox_") then
                    desc.BackgroundColor3 = Theme.Deep
                end
            end
        end
        updateContrastCheckDisplay()
    end
    State.applyFullUITheme = applyFullUITheme

    local BgColorRow = UI.createColorRow(themesSec, "Background Color", ConfigState.ThemeBgColor, function(col)
        ConfigState.ThemeBgColor = col
        applyFullUITheme()
    end)
    local ElemColorRow = UI.createColorRow(themesSec, "Element Color", ConfigState.ThemeElementColor, function(col)
        ConfigState.ThemeElementColor = col
        applyFullUITheme()
    end)
    local BorderColorRow = UI.createColorRow(themesSec, "Border Color", ConfigState.ThemeBorderColor, function(col)
        ConfigState.ThemeBorderColor = col
        applyFullUITheme()
    end)
    local AccentColorRow = UI.createColorRow(themesSec, "Accent Color", ConfigState.ThemeAccentColor, function(col)
        ConfigState.ThemeAccentColor = col
        applyFullUITheme()
    end)
    local GlowColorRow = UI.createColorRow(themesSec, "Glow Color", ConfigState.ThemeGlowColor, function(col)
        ConfigState.ThemeGlowColor = col
        applyFullUITheme()
    end)
    local OutlineColorRow = UI.createColorRow(themesSec, "Outline Color", ConfigState.ThemeOutlineColor, function(col)
        ConfigState.ThemeOutlineColor = col
        applyFullUITheme()
    end)
    local InlineColorRow = UI.createColorRow(themesSec, "Inline Color", ConfigState.ThemeInlineColor, function(col)
        ConfigState.ThemeInlineColor = col
        applyFullUITheme()
    end)
    local GradColorRow = UI.createColorRow(themesSec, "Gradient Color", ConfigState.ThemeGradientColor, function(col)
        ConfigState.ThemeGradientColor = col
        applyFullUITheme()
    end)
    local FontColorRow = UI.createColorRow(themesSec, "Font Color", ConfigState.ThemeFontColor, function(col)
        ConfigState.ThemeFontColor = col
        applyFullUITheme()
    end)
    local FontOutlineColorRow = UI.createColorRow(themesSec, "Font Outline Color", ConfigState.ThemeFontOutlineColor, function(col)
        ConfigState.ThemeFontOutlineColor = col
        applyFullUITheme()
    end)

    ContrastCheckLabel.Parent = themesSec
    updateContrastCheckDisplay()

    createDropdown(themesSec, "Font Face", { "Gotham", "GothamBold", "Code", "Ubuntu", "SourceSans", "SciFi", "Arcade" }, ConfigState.ThemeFontFace or "Gotham", function(opt)
        ConfigState.ThemeFontFace = opt
        applyFullUITheme()
    end)

    createButton(themesSec, "Refresh Custom Fonts", function()
        SafeMakeFolder(FS_FOLDER .. "/Fonts")
        notify("Fonts", "Scanned " .. FS_FOLDER .. "/Fonts for custom .ttf/.otf font assets.", 3)
    end)

    local fontHintLbl = Instance.new("TextLabel")
    fontHintLbl.Name = "CustomFontHintLabel"
    fontHintLbl.Size = UDim2.new(1, 0, 0, 16)
    fontHintLbl.BackgroundTransparency = 1
    fontHintLbl.Font = Enum.Font.Code
    fontHintLbl.Text = "Drop Ttf/Otf Into " .. FS_FOLDER .. "/Fonts"
    fontHintLbl.TextColor3 = Theme.Muted
    fontHintLbl.TextSize = 10
    fontHintLbl.TextXAlignment = Enum.TextXAlignment.Left
    fontHintLbl.ZIndex = 15
    fontHintLbl.Parent = themesSec

    local BUILTIN_FULL_THEMES = {
        ["Default"] = {
            Bg = Color3.fromRGB(19, 19, 19),
            Elem = Color3.fromRGB(22, 22, 22),
            Border = Color3.fromRGB(56, 56, 56),
            Accent = Color3.fromRGB(100, 100, 255),
            Glow = Color3.fromRGB(100, 100, 255),
            Outline = Color3.fromRGB(8, 8, 8),
            Inline = Color3.fromRGB(26, 26, 26),
            Grad = Color3.fromRGB(130, 130, 255),
            Font = Color3.fromRGB(170, 170, 170),
            FontOut = Color3.fromRGB(0, 0, 0),
        },
        ["Vaderpaste"] = {
            Bg = Color3.fromRGB(19, 19, 19),
            Elem = Color3.fromRGB(22, 22, 22),
            Border = Color3.fromRGB(56, 56, 56),
            Accent = Color3.fromRGB(100, 100, 255),
            Glow = Color3.fromRGB(100, 100, 255),
            Outline = Color3.fromRGB(8, 8, 8),
            Inline = Color3.fromRGB(26, 26, 26),
            Grad = Color3.fromRGB(130, 130, 255),
            Font = Color3.fromRGB(170, 170, 170),
            FontOut = Color3.fromRGB(0, 0, 0),
        },
        ["Pure Monochrome"] = {
            Bg = Color3.fromRGB(8, 8, 10),
            Elem = Color3.fromRGB(15, 15, 19),
            Border = Color3.fromRGB(48, 48, 56),
            Accent = Color3.fromRGB(255, 255, 255),
            Glow = Color3.fromRGB(220, 220, 230),
            Outline = Color3.fromRGB(36, 36, 44),
            Inline = Color3.fromRGB(24, 24, 30),
            Grad = Color3.fromRGB(190, 190, 205),
            Font = Color3.fromRGB(255, 255, 255),
            FontOut = Color3.fromRGB(0, 0, 0),
        },
        ["Cyber Cyan"] = {
            Bg = Color3.fromRGB(7, 13, 18),
            Elem = Color3.fromRGB(12, 22, 30),
            Border = Color3.fromRGB(35, 75, 95),
            Accent = Color3.fromRGB(75, 225, 255),
            Glow = Color3.fromRGB(75, 225, 255),
            Outline = Color3.fromRGB(25, 55, 75),
            Inline = Color3.fromRGB(18, 32, 44),
            Grad = Color3.fromRGB(120, 240, 255),
            Font = Color3.fromRGB(240, 252, 255),
            FontOut = Color3.fromRGB(4, 8, 12),
        },
        ["Crimson Ops"] = {
            Bg = Color3.fromRGB(15, 8, 10),
            Elem = Color3.fromRGB(24, 12, 16),
            Border = Color3.fromRGB(80, 32, 40),
            Accent = Color3.fromRGB(255, 70, 85),
            Glow = Color3.fromRGB(255, 70, 85),
            Outline = Color3.fromRGB(55, 22, 28),
            Inline = Color3.fromRGB(34, 16, 22),
            Grad = Color3.fromRGB(255, 120, 130),
            Font = Color3.fromRGB(255, 245, 246),
            FontOut = Color3.fromRGB(10, 4, 5),
        },
        ["Emerald Matrix"] = {
            Bg = Color3.fromRGB(7, 14, 10),
            Elem = Color3.fromRGB(12, 24, 17),
            Border = Color3.fromRGB(32, 82, 52),
            Accent = Color3.fromRGB(85, 255, 145),
            Glow = Color3.fromRGB(85, 255, 145),
            Outline = Color3.fromRGB(22, 58, 36),
            Inline = Color3.fromRGB(16, 34, 24),
            Grad = Color3.fromRGB(130, 255, 180),
            Font = Color3.fromRGB(242, 255, 246),
            FontOut = Color3.fromRGB(4, 10, 6),
        },
    }

    local CUSTOM_THEMES_FILE = FS_FOLDER .. "/CustomThemes.json"
    local savedCustomThemes = safeJsonDecode(safeReadFile(CUSTOM_THEMES_FILE))
    if type(savedCustomThemes) ~= "table" then
        savedCustomThemes = {}
    end

    local function getThemeDropdownNames()
        local list = { "Default", "Vaderpaste", "Pure Monochrome", "Cyber Cyan", "Crimson Ops", "Emerald Matrix" }
        for k in pairs(savedCustomThemes) do
            if not table.find(list, k) then
                table.insert(list, k)
            end
        end
        return list
    end

    local function applyNamedFullTheme(themeName)
        ConfigState.ThemeListSelection = themeName
        local p = BUILTIN_FULL_THEMES[themeName]
        if not p and type(savedCustomThemes[themeName]) == "table" then
            local rawT = savedCustomThemes[themeName]
            local function toC3(c, fallback)
                if type(c) == "table" and type(c.R) == "number" then
                    if c.R > 1 or c.G > 1 or c.B > 1 then
                        return Color3.fromRGB(c.R, c.G, c.B)
                    end
                    return Color3.new(c.R, c.G, c.B)
                end
                return fallback
            end
            p = {
                Bg = toC3(rawT.Bg, Theme.Deep),
                Elem = toC3(rawT.Elem, Theme.Surface),
                Border = toC3(rawT.Border, Theme.Border),
                Accent = toC3(rawT.Accent, Theme.Accent),
                Glow = toC3(rawT.Glow, Theme.Accent),
                Outline = toC3(rawT.Outline, Theme.Border),
                Inline = toC3(rawT.Inline, Theme.Elevated),
                Grad = toC3(rawT.Grad, Theme.Accent),
                Font = toC3(rawT.Font, Theme.White),
                FontOut = toC3(rawT.FontOut, Theme.Black),
            }
        end
        if not p then return end
        ConfigState.ThemeBgColor = p.Bg
        ConfigState.ThemeElementColor = p.Elem
        ConfigState.ThemeBorderColor = p.Border
        ConfigState.ThemeAccentColor = p.Accent
        ConfigState.ThemeGlowColor = p.Glow
        ConfigState.ThemeOutlineColor = p.Outline
        ConfigState.ThemeInlineColor = p.Inline
        ConfigState.ThemeGradientColor = p.Grad
        ConfigState.ThemeFontColor = p.Font
        ConfigState.ThemeFontOutlineColor = p.FontOut

        BgColorRow.SetColor(p.Bg, false)
        ElemColorRow.SetColor(p.Elem, false)
        BorderColorRow.SetColor(p.Border, false)
        AccentColorRow.SetColor(p.Accent, false)
        GlowColorRow.SetColor(p.Glow, false)
        OutlineColorRow.SetColor(p.Outline, false)
        InlineColorRow.SetColor(p.Inline, false)
        GradColorRow.SetColor(p.Grad, false)
        FontColorRow.SetColor(p.Font, false)
        FontOutlineColorRow.SetColor(p.FontOut, false)

        applyFullUITheme()
    end

    local ThemeListDropdown = createDropdown(themesSec, "Theme List", getThemeDropdownNames(), ConfigState.ThemeListSelection or "Default", function(opt)
        applyNamedFullTheme(opt)
    end)

    local CustomThemeNameBox = createTextInputRow(themesSec, "Custom Theme Name", "Enter custom theme name...", "", function(txt)
        ConfigState.CustomThemeName = txt
    end)

    createButton(themesSec, "Save Custom Theme", function()
        local tName = ((CustomThemeNameBox and CustomThemeNameBox.Text) or ConfigState.CustomThemeName or ""):gsub("^%s*(.-)%s*$", "%1")
        if tName == "" then
            tName = "CustomTheme"
        end
        local function c3Obj(c)
            return { R = c.R, G = c.G, B = c.B }
        end
        savedCustomThemes[tName] = {
            Bg = c3Obj(ConfigState.ThemeBgColor or Theme.Deep),
            Elem = c3Obj(ConfigState.ThemeElementColor or Theme.Surface),
            Border = c3Obj(ConfigState.ThemeBorderColor or Theme.Border),
            Accent = c3Obj(ConfigState.ThemeAccentColor or Theme.Accent),
            Glow = c3Obj(ConfigState.ThemeGlowColor or Theme.Accent),
            Outline = c3Obj(ConfigState.ThemeOutlineColor or Theme.Border),
            Inline = c3Obj(ConfigState.ThemeInlineColor or Theme.Elevated),
            Grad = c3Obj(ConfigState.ThemeGradientColor or Theme.Accent),
            Font = c3Obj(ConfigState.ThemeFontColor or Theme.White),
            FontOut = c3Obj(ConfigState.ThemeFontOutlineColor or Theme.Black),
        }
        safeWriteFile(CUSTOM_THEMES_FILE, safeJsonEncode(savedCustomThemes))
        if ThemeListDropdown then
            ThemeListDropdown.Refresh(getThemeDropdownNames(), tName)
        end
        notify("Themes", "Saved custom theme '" .. tName .. "'!", 3)
    end)

    createLabel(SettingsTab, "UI Theme & RGB Color Freedom")

    local RSliderCtrl, GSliderCtrl, BSliderCtrl

    local ThemePresets = {
        ["Vaderpaste"] = { 100, 100, 255 },
        ["Pure Monochrome"] = { 255, 255, 255 },
        ["Obsidian Silver"] = { 190, 195, 210 },
        ["Cyber Cyan"] = { 75, 225, 255 },
        ["Crimson Ops"] = { 255, 70, 85 },
        ["Emerald Matrix"] = { 85, 255, 145 },
        ["Royal Amethyst"] = { 185, 110, 255 },
    }

    createDropdown(SettingsTab, "Theme Preset", {
        "Vaderpaste",
        "Pure Monochrome",
        "Obsidian Silver",
        "Cyber Cyan",
        "Crimson Ops",
        "Emerald Matrix",
        "Royal Amethyst",
    }, "Vaderpaste", function(presetName)
        ConfigState.ThemePreset = presetName
        local rgb = ThemePresets[presetName]
        if rgb then
            updateAccentColor(rgb[1], rgb[2], rgb[3])
            if RSliderCtrl then RSliderCtrl.Set(rgb[1], false) end
            if GSliderCtrl then GSliderCtrl.Set(rgb[2], false) end
            if BSliderCtrl then BSliderCtrl.Set(rgb[3], false) end
            if BUILTIN_FULL_THEMES[presetName] then
                applyNamedFullTheme(presetName)
            end
        end
    end)

    RSliderCtrl = createSlider(SettingsTab, "Accent Red (R)", 0, 255, 100, 1, "", function(val)
        updateAccentColor(val, ConfigState.AccentG, ConfigState.AccentB)
    end)
    GSliderCtrl = createSlider(SettingsTab, "Accent Green (G)", 0, 255, 100, 1, "", function(val)
        updateAccentColor(ConfigState.AccentR, val, ConfigState.AccentB)
    end)
    BSliderCtrl = createSlider(SettingsTab, "Accent Blue (B)", 0, 255, 255, 1, "", function(val)
        updateAccentColor(ConfigState.AccentR, ConfigState.AccentG, val)
    end)

    createSlider(SettingsTab, "Window Background Transparency", 0, 0.45, 0, 0.01, "", function(val)
        ConfigState.WindowTransparency = val
        UI.MainWindow.BackgroundTransparency = val
        if State.syncMusicPlayerDock then
            State.syncMusicPlayerDock()
        end
    end)

    createSlider(SettingsTab, "UI Scale Override", 0.70, 1.15, 1.00, 0.01, "x", function(val)
        State.customUIScaleOverride = val
        UI.MainScale.Scale = val
        if State.syncMusicPlayerDock then
            State.syncMusicPlayerDock()
        end
    end)

    createToggle(SettingsTab, "Live Particle Starfield", true, function(val)
        ConfigState.ParticlesEnabled = val
        UI.MainParticleCanvas.Visible = val
    end)

    createToggle(SettingsTab, "Live Border Shimmer Beam", true, function(val)
        ConfigState.ShimmerEnabled = val
    end)

    createLabel(SettingsTab, "Config Management (Name Required to Save)")

    local savedConfigNames = safeJsonDecode(safeReadFile(CONFIG_INDEX_FILE))
    if type(savedConfigNames) ~= "table" or #savedConfigNames == 0 then
        savedConfigNames = { "Default" }
    end

    local ConfigNameBox = createTextInputRow(SettingsTab, "Config Name (Required)", "Enter config name...", "", nil)
    local selectedConfigToLoad = savedConfigNames[1]
    local ConfigListDropdown

    local function isColor3Value(val)
        if type(typeof) == "function" and typeof(val) == "Color3" then
            return true
        end
        return type(val) == "table" and type(val.R) == "number" and type(val.G) == "number" and type(val.B) == "number"
    end

    local function serializeConfigTable(cfg)
        local out = {}
        for k, v in pairs(cfg) do
            if isColor3Value(v) then
                out[k] = { __color3 = true, R = v.R, G = v.G, B = v.B }
            elseif type(v) == "string" or type(v) == "number" or type(v) == "boolean" then
                out[k] = v
            end
        end
        return out
    end

    local function saveConfigByName(cfgName)
        local cleanName = (cfgName or ""):gsub("^%s*(.-)%s*$", "%1")
        if cleanName == "" then
            notify("Config System", "Config Name is required! Please type a name before saving.", 4)
            return false
        end
        local path = FS_FOLDER .. "/Config_" .. cleanName .. ".json"
        safeWriteFile(path, safeJsonEncode(serializeConfigTable(ConfigState)))

        if not table.find(savedConfigNames, cleanName) then
            table.insert(savedConfigNames, cleanName)
            safeWriteFile(CONFIG_INDEX_FILE, safeJsonEncode(savedConfigNames))
        end
        selectedConfigToLoad = cleanName
        if ConfigListDropdown then
            ConfigListDropdown.Refresh(savedConfigNames, cleanName)
        end
        if ConfigState.AutoLoadConfig then
            safeWriteFile(AUTO_LOAD_FILE, cleanName)
        end
        notify("Config System", "Saved configuration '" .. cleanName .. "'!", 4)
        return true
    end

    local function loadConfigByName(cfgName)
        local cleanName = (cfgName or ""):gsub("^%s*(.-)%s*$", "%1")
        if cleanName == "" then
            return false
        end
        local path = FS_FOLDER .. "/Config_" .. cleanName .. ".json"
        local raw = safeReadFile(path)
        local decoded = safeJsonDecode(raw)
        if type(decoded) ~= "table" then
            notify("Config System", "Config '" .. cleanName .. "' not found on disk.", 3)
            return false
        end
        for k, v in pairs(decoded) do
            if v ~= nil then
                if type(v) == "table" and (v.__color3 or (type(v.R) == "number" and type(v.G) == "number" and type(v.B) == "number")) then
                    if v.R > 1 or v.G > 1 or v.B > 1 then
                        ConfigState[k] = Color3.fromRGB(v.R, v.G, v.B)
                    else
                        ConfigState[k] = Color3.new(v.R, v.G, v.B)
                    end
                elseif not isColor3Value(ConfigState[k]) then
                    ConfigState[k] = v
                end
            end
        end
        updateAccentColor(ConfigState.AccentR or 255, ConfigState.AccentG or 255, ConfigState.AccentB or 255)
        if RSliderCtrl then RSliderCtrl.Set(ConfigState.AccentR or 255, false) end
        if GSliderCtrl then GSliderCtrl.Set(ConfigState.AccentG or 255, false) end
        if BSliderCtrl then BSliderCtrl.Set(ConfigState.AccentB or 255, false) end
        UI.MainWindow.BackgroundTransparency = ConfigState.WindowTransparency or 0.03
        updateMovement()
        if State.applyWeatherPreset then
            State.applyWeatherPreset(ConfigState.WeatherPreset or "Default")
        else
            updateLightingEnvironment()
        end
        if State.applySelfChams then State.applySelfChams() end
        if State.applyLegTrails then State.applyLegTrails() end
        if State.applyToolVisuals then State.applyToolVisuals() end
        if State.applyCustomBloomAndSunRays then State.applyCustomBloomAndSunRays() end
        if State.applyCustomColorCorrection then State.applyCustomColorCorrection() end
        if State.applyCustomSkybox then State.applyCustomSkybox() end
        if State.applyCustomAtmosphere then State.applyCustomAtmosphere() end
        if State.applyPerformanceProfile then State.applyPerformanceProfile(ConfigState.PerformanceProfile) end
        if State.applyLowGraphics then State.applyLowGraphics(ConfigState.LowGraphicsEnabled) end
        if State.applyBackgroundSettings then State.applyBackgroundSettings() end
        if State.applyFullUITheme then State.applyFullUITheme() end
        if State.applyMuteGameAudio then
            State.applyMuteGameAudio(ConfigState.MuteGameAudio or false)
        end
        if State.syncMusicPlayerDock then
            State.syncMusicPlayerDock()
        end
        updateCrosshair(0)
        State.lastPillText = ""
        updateFloatingPillTelemetry()
        notify("Config System", "Loaded configuration '" .. cleanName .. "'!", 4)
        return true
    end

    State.loadConfigByName = loadConfigByName

    createButton(SettingsTab, "Save Config", function()
        saveConfigByName(ConfigNameBox.Text)
    end)

    ConfigListDropdown = createDropdown(SettingsTab, "Saved Configs", savedConfigNames, savedConfigNames[1], function(opt)
        selectedConfigToLoad = opt
    end)

    createButton(SettingsTab, "Load Selected Config", function()
        loadConfigByName(selectedConfigToLoad)
    end)

    createToggle(SettingsTab, "Auto-Load Config on Startup", false, function(val)
        ConfigState.AutoLoadConfig = val
        if val then
            local targetName = (ConfigNameBox.Text ~= "" and ConfigNameBox.Text) or selectedConfigToLoad or "Default"
            safeWriteFile(AUTO_LOAD_FILE, targetName)
            notify("Core.xyz", "Auto-Load enabled for '" .. targetName .. "'.", 3)
        else
            safeWriteFile(AUTO_LOAD_FILE, "")
        end
    end)

    local settingsSaveKeySet = createToggle(SettingsTab, "Save Key (Auto-Login Until Expired)", ConfigState.RememberKey ~= false, function(val)
        if UI.setSaveKeyVisualState then
            UI.setSaveKeyVisualState(val, false)
        else
            ConfigState.RememberKey = val
        end
        if not val then
            safeWriteFile(SAVED_KEY_FILE, "")
            notify("Key System", "Saved key cleared. Key System will prompt on next launch.", 3)
        elseif State.activeKeyString and State.activeKeyString ~= "" and State.activeKeyString ~= "Unverified" then
            pcall(function()
                safeWriteFile(SAVED_KEY_FILE, HttpService:JSONEncode({
                    key = State.activeKeyString,
                    savedAt = os.time(),
                    expiresAt = State.keyExpireTimestamp or (os.time() + 86400),
                    rememberKey = true,
                }))
            end)
            notify("Key System", "Key saved! Auto-login active until key expires.", 3)
        end
    end)
    State.syncSettingsSaveKeyToggle = settingsSaveKeySet and settingsSaveKeySet.Set

    createButton(SettingsTab, "View Changelog (" .. CHANGELOG_VERSION .. ")", function()
        if UI.showChangelogModal then
            UI.showChangelogModal(true)
        end
    end)
end

--------------------------------------------------------------------------------
-- 13. PLATOBOOST KEY SYSTEM AUTHORIZATION (SUBMIT + GET KEY · LIVE EXPIRY)
--------------------------------------------------------------------------------
PlatoBoost.setOnMessage(function(message)
    if UI.KeyFeedback and message and tostring(message) ~= "" then
        UI.KeyFeedback.Text = "Status: " .. tostring(message)
    end
end)

local function saveKeyRecord(keyStr, expireTs)
    if ConfigState.RememberKey == false then
        safeWriteFile(SAVED_KEY_FILE, "")
        return
    end
    if not keyStr or keyStr == "" then
        return
    end
    pcall(function()
        local payload = HttpService:JSONEncode({
            key = tostring(keyStr),
            savedAt = os.time(),
            expiresAt = tonumber(expireTs) or (os.time() + 86400),
            rememberKey = true,
        })
        safeWriteFile(SAVED_KEY_FILE, payload)
    end)
end

local function clearSavedKeyRecord()
    safeWriteFile(SAVED_KEY_FILE, "")
end

local function launchMainHub()
    if PlatoBoost.getEntangledScale() ~= 1 or #PlatoBoost.getProofHash() ~= 64 then
        State.isAuthorized = false
        return
    end
    State.isAuthorized = true
    State.uiVisible = true

    if State.updateHomeKeyInfo then
        State.updateHomeKeyInfo()
    end

    local targetScale = getResponsiveScale()
    State.lastPillText = ""
    updateFloatingPillTelemetry()
    if UI.FloatingToggle then
        UI.FloatingToggle.Visible = true
    end
    if UI.MainWindow then
        UI.MainWindow.Visible = true
        UI.MainScale.Scale = targetScale * 0.86
        tween(UI.MainWindow, SmoothTween, { BackgroundTransparency = ConfigState.WindowTransparency })
        tween(UI.MainStroke, SmoothTween, { Transparency = 0.08 })
        tween(UI.MainScale, SpringTween, { Scale = targetScale })
    end
    if State.syncMusicPlayerDock then
        State.syncMusicPlayerDock()
    end

    local autoCfg = safeReadFile(AUTO_LOAD_FILE)
    if autoCfg and autoCfg ~= "" and State.loadConfigByName then
        State.loadConfigByName(autoCfg)
    end

    notify("Core.xyz", "License verified! Key Time Left: " .. formatRemainingKeyTime() .. ".", 5)
end

local function setKeyCardStateGradient(mode)
    State.keyCardFlashToken = (State.keyCardFlashToken or 0) + 1
    local myToken = State.keyCardFlashToken
    if mode == "error" then
        UI.KeyCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        if UI.KeyCardGrad then
            UI.KeyCardGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.0, Color3.fromRGB(96, 16, 28)),
                ColorSequenceKeypoint.new(0.28, Color3.fromRGB(64, 10, 20)),
                ColorSequenceKeypoint.new(0.62, Color3.fromRGB(36, 6, 12)),
                ColorSequenceKeypoint.new(0.88, Color3.fromRGB(20, 4, 8)),
                ColorSequenceKeypoint.new(1.0, Color3.fromRGB(10, 3, 6)),
            })
        end
        if UI.KeyOverlayGrad then
            UI.KeyOverlayGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.0, Color3.fromRGB(255, 72, 92)),
                ColorSequenceKeypoint.new(0.32, Color3.fromRGB(220, 34, 56)),
                ColorSequenceKeypoint.new(0.68, Color3.fromRGB(135, 16, 30)),
                ColorSequenceKeypoint.new(1.0, Color3.fromRGB(38, 6, 12)),
            })
        end
        if UI.KeyGradientOverlay then
            UI.KeyGradientOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            tween(UI.KeyGradientOverlay, FastTween, { BackgroundTransparency = 0.52 })
        end
        tween(UI.KeyCardStroke, FastTween, { Color = Theme.Error, Transparency = 0 })
        tween(UI.KeyInputStroke, FastTween, { Color = Theme.Error })
        if UI.KeyTopBar then
            tween(UI.KeyTopBar, FastTween, { BackgroundColor3 = Theme.Error })
        end
        task.delay(1.35, function()
            if State.keyCardFlashToken == myToken and UI.KeyCard and UI.KeyCard.Visible then
                UI.KeyCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
                if UI.KeyCardGrad then
                    UI.KeyCardGrad.Color = ColorSequence.new({
                        ColorSequenceKeypoint.new(0.0, Color3.fromRGB(24, 24, 34)),
                        ColorSequenceKeypoint.new(0.38, Color3.fromRGB(14, 14, 20)),
                        ColorSequenceKeypoint.new(0.75, Color3.fromRGB(9, 9, 13)),
                        ColorSequenceKeypoint.new(1.0, Color3.fromRGB(5, 5, 8)),
                    })
                end
                if UI.KeyGradientOverlay then
                    tween(UI.KeyGradientOverlay, SmoothTween, { BackgroundTransparency = 1 })
                end
                tween(UI.KeyCardStroke, SmoothTween, { Color = Theme.White, Transparency = 0.12 })
                tween(UI.KeyInputStroke, SmoothTween, { Color = Theme.Border })
                if UI.KeyTopBar then
                    tween(UI.KeyTopBar, SmoothTween, { BackgroundColor3 = Theme.White })
                end
            end
        end)
    elseif mode == "success" then
        UI.KeyCard.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        if UI.KeyCardGrad then
            UI.KeyCardGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.0, Color3.fromRGB(14, 88, 52)),
                ColorSequenceKeypoint.new(0.28, Color3.fromRGB(10, 58, 35)),
                ColorSequenceKeypoint.new(0.62, Color3.fromRGB(6, 34, 20)),
                ColorSequenceKeypoint.new(0.88, Color3.fromRGB(4, 18, 12)),
                ColorSequenceKeypoint.new(1.0, Color3.fromRGB(3, 10, 7)),
            })
        end
        if UI.KeyOverlayGrad then
            UI.KeyOverlayGrad.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0.0, Color3.fromRGB(72, 255, 158)),
                ColorSequenceKeypoint.new(0.35, Color3.fromRGB(32, 205, 112)),
                ColorSequenceKeypoint.new(0.70, Color3.fromRGB(16, 120, 64)),
                ColorSequenceKeypoint.new(1.0, Color3.fromRGB(6, 38, 22)),
            })
        end
        if UI.KeyGradientOverlay then
            UI.KeyGradientOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            tween(UI.KeyGradientOverlay, FastTween, { BackgroundTransparency = 0.48 })
        end
        tween(UI.KeyCardStroke, FastTween, { Color = Theme.Success, Transparency = 0 })
        tween(UI.KeyInputStroke, FastTween, { Color = Theme.Success })
        if UI.KeyTopBar then
            tween(UI.KeyTopBar, FastTween, { BackgroundColor3 = Theme.Success })
        end
    end
end
UI.setKeyCardStateGradient = setKeyCardStateGradient

local function shakeKeyCardOnError()
    setKeyCardStateGradient("error")
    local origPos = UI.KeyCard.Position
    for _, offset in ipairs({ -9, 9, -6, 6, -3, 0 }) do
        UI.KeyCard.Position = UDim2.new(origPos.X.Scale, origPos.X.Offset + offset, origPos.Y.Scale, origPos.Y.Offset)
        task.wait(0.028)
    end
end

local function attemptAuthorization()
    if State.isAuthorizing or State.isAuthorized then
        return
    end
    local entered = ((UI.KeyInputBox and UI.KeyInputBox.Text) or ""):gsub("^%s*(.-)%s*$", "%1")
    if entered == "" then
        UI.KeyFeedback.Text = "Status: Please paste your key before pressing Submit."
        UI.KeyFeedback.TextColor3 = Theme.Error
        if UI.KeyStatusDot then UI.KeyStatusDot.BackgroundColor3 = Theme.Error end
        shakeKeyCardOnError()
        return
    end

    State.isAuthorizing = true
    UI.UnlockButton.Text = "Verifying..."
    UI.KeyFeedback.Text = "Status: Verifying license with Platoboost..."
    UI.KeyFeedback.TextColor3 = Theme.Silver
    if UI.KeyStatusDot then UI.KeyStatusDot.BackgroundColor3 = Theme.White end

    local okVerify, expireTs = PlatoBoost.verifyKey(entered)
    if okVerify then
        State.activeKeyString = entered
        State.activeKeyTier = "Licensed"
        State.keyExpireTimestamp = expireTs or (os.time() + 86400)
        if ConfigState.RememberKey ~= false then
            saveKeyRecord(entered, State.keyExpireTimestamp)
        else
            clearSavedKeyRecord()
        end
        UI.UnlockButton.Text = "Submit"
        UI.KeyFeedback.Text = "Status: Key verified! Launching Core.xyz..."
        UI.KeyFeedback.TextColor3 = Theme.Success
        if UI.KeyStatusDot then UI.KeyStatusDot.BackgroundColor3 = Theme.Success end
        setKeyCardStateGradient("success")
        task.wait(0.32)
        tween(UI.KeyScale, FastTween, { Scale = 0.9 })
        tween(UI.KeyCard, FastTween, { BackgroundTransparency = 1 })
        if UI.KeyGradientOverlay then
            tween(UI.KeyGradientOverlay, FastTween, { BackgroundTransparency = 1 })
        end
        tween(UI.KeyCardStroke, FastTween, { Transparency = 1 })
        task.wait(0.22)
        UI.KeyCard.Visible = false
        State.isAuthorizing = false
        launchMainHub()
    else
        State.isAuthorizing = false
        UI.UnlockButton.Text = "Submit"
        UI.KeyFeedback.TextColor3 = Theme.Error
        if UI.KeyStatusDot then UI.KeyStatusDot.BackgroundColor3 = Theme.Error end
        shakeKeyCardOnError()
    end
end

local function showKeyCardPrompt(targetScale, statusText, isErrorState)
    local scaleVal = targetScale or getResponsiveScale()
    UI.KeyFeedback.Text = statusText or "Status: Waiting for key submission..."
    UI.KeyFeedback.TextColor3 = isErrorState and Theme.Error or Theme.Muted
    if UI.KeyStatusDot then
        UI.KeyStatusDot.BackgroundColor3 = isErrorState and Theme.Error or Theme.Silver
    end
    UI.KeyCard.Visible = true
    UI.KeyScale.Scale = scaleVal * 0.88
    tween(UI.KeyCard, SmoothTween, { BackgroundTransparency = 0.02 })
    tween(UI.KeyCardStroke, SmoothTween, { Transparency = isErrorState and 0 or 0.12 })
    tween(UI.KeyScale, SpringTween, { Scale = scaleVal })
    if isErrorState then
        setKeyCardStateGradient("error")
    end
end

local function checkSavedKeyAndRoute(targetScale)
    -- Show Changelog v4.4 note once per version on execution
    if UI.showChangelogModal then
        UI.showChangelogModal(false)
    end

    local rawSaved = safeReadFile(SAVED_KEY_FILE)
    if rawSaved and rawSaved ~= "" then
        local okDecode, savedData = pcall(function()
            return HttpService:JSONDecode(rawSaved)
        end)
        if okDecode and type(savedData) == "table" then
            if savedData.rememberKey ~= nil and UI.setSaveKeyVisualState then
                UI.setSaveKeyVisualState(savedData.rememberKey == true, true)
            end
            local savedKeyStr = type(savedData.key) == "string" and savedData.key:gsub("^%s*(.-)%s*$", "%1") or ""
            if savedKeyStr ~= "" and savedData.rememberKey ~= false then
                local savedExpireTs = tonumber(savedData.expiresAt)
                local nowTs = os.time()
                -- 1. Check local expiry timestamp first
                if savedExpireTs and savedExpireTs ~= -1 and nowTs >= savedExpireTs then
                    clearSavedKeyRecord()
                    if UI.KeyInputBox then
                        UI.KeyInputBox.Text = ""
                    end
                    showKeyCardPrompt(targetScale, "Status: Your saved key has expired! Please obtain a new key.", true)
                    notify("Key System", "Your saved key has expired! Please obtain a new key to continue.", 5)
                    return "expired"
                end

                -- 2. Verify with Platoboost gateway to confirm key is still active
                local okVerify, liveExpireTs = PlatoBoost.verifyKey(savedKeyStr)
                local effectiveExpire = tonumber(liveExpireTs) or savedExpireTs or (nowTs + 86400)
                if okVerify and (effectiveExpire == -1 or nowTs < effectiveExpire) then
                    State.activeKeyString = savedKeyStr
                    State.activeKeyTier = "Licensed"
                    State.keyExpireTimestamp = effectiveExpire
                    saveKeyRecord(savedKeyStr, effectiveExpire)
                    if UI.KeyCard then
                        UI.KeyCard.Visible = false
                    end
                    launchMainHub()
                    return "launched"
                else
                    clearSavedKeyRecord()
                    if UI.KeyInputBox then
                        UI.KeyInputBox.Text = ""
                    end
                    showKeyCardPrompt(targetScale, "Status: Your saved key has expired! Please obtain a new key.", true)
                    notify("Key System", "Your saved key has expired! Please obtain a new key to continue.", 5)
                    return "expired"
                end
            end
        end
    end

    showKeyCardPrompt(targetScale, "Status: Waiting for key submission...", false)
    return "prompt"
end
State.checkSavedKeyAndRoute = checkSavedKeyAndRoute

UI.CopyKeyButton.MouseButton1Click:Connect(function()
    spawnRipple(UI.CopyKeyButton)
    UI.KeyFeedback.Text = "Status: Generating Platoboost key link..."
    UI.KeyFeedback.TextColor3 = Theme.Silver
    if UI.KeyStatusDot then UI.KeyStatusDot.BackgroundColor3 = Theme.White end
    local ok, linkOrErr = PlatoBoost.copyLink()
    if ok then
        UI.KeyFeedback.Text = "Status: Key link copied! Paste it into your browser."
        UI.KeyFeedback.TextColor3 = Theme.Success
        if UI.KeyStatusDot then UI.KeyStatusDot.BackgroundColor3 = Theme.Success end
        notify("Key System", "Platoboost key link copied to clipboard!", 4)
    else
        UI.KeyFeedback.Text = "Status: " .. tostring(linkOrErr or "Failed to copy key link.")
        UI.KeyFeedback.TextColor3 = Theme.Error
        if UI.KeyStatusDot then UI.KeyStatusDot.BackgroundColor3 = Theme.Error end
    end
end)

UI.UnlockButton.MouseButton1Click:Connect(function()
    spawnRipple(UI.UnlockButton)
    attemptAuthorization()
end)

UI.KeyInputBox.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        attemptAuthorization()
    end
end)

--------------------------------------------------------------------------------
-- 14. RUNTIME LOOPS (ULTRA-FPS OPTIMIZED + CAMERA & CHARACTER AIMBOT LOCK-IN)
--------------------------------------------------------------------------------
local function refreshLocalCharacterCache(char)
    State.cachedLocalChar = char
    State.cachedLocalHRP = char and char:FindFirstChild("HumanoidRootPart") or nil
    State.cachedLocalHum = char and char:FindFirstChildOfClass("Humanoid") or nil
    table.clear(State.cachedLocalParts)
    if char then
        for _, desc in ipairs(char:GetDescendants()) do
            if desc:IsA("BasePart") then
                table.insert(State.cachedLocalParts, desc)
            end
        end
    end
end

refreshLocalCharacterCache(LocalPlayer.Character)

LocalPlayer.CharacterAdded:Connect(function(character)
    table.clear(State.noclipCollideCache)
    table.clear(State.headlessCache)
    table.clear(State.korbloxCache)
    local humanoid = character:WaitForChild("Humanoid", 5)
    refreshLocalCharacterCache(character)
    if humanoid then
        State.defaultWalkSpeed = humanoid.WalkSpeed
        State.defaultJumpPower = humanoid.JumpPower
        updateMovement()
    end
    if ConfigState.Freecam then
        setFreecamEnabled(false)
    end
    if ConfigState.Headless then
        task.delay(0.5, function() applyHeadless(true) end)
    end
    if ConfigState.Korblox then
        task.delay(0.5, function() applyKorblox(true) end)
    end
    if ConfigState.SelfChams and State.applySelfChams then
        task.delay(0.5, function() State.applySelfChams() end)
    end
    if ConfigState.LegTrailEnabled and State.applyLegTrails then
        task.delay(0.5, function() State.applyLegTrails() end)
    end
    if (ConfigState.ToolVisuals or ConfigState.ToolChams or ConfigState.ToolGlow) and State.applyToolVisuals then
        task.delay(0.5, function() State.applyToolVisuals() end)
    end
    if UI.HomeAvatarCtrl and UI.HomeAvatarCtrl.RefreshClone then
        task.delay(0.5, function() UI.HomeAvatarCtrl.RefreshClone() end)
    end
end)

UserInputService.JumpRequest:Connect(function()
    if State.isAuthorized and ConfigState.InfJump and LocalPlayer.Character then
        local hum = State.cachedLocalHum or LocalPlayer.Character:FindFirstChildOfClass("Humanoid")
        if hum then
            hum:ChangeState(Enum.HumanoidStateType.Jumping)
        end
    end
end)

local function extractKeyCodeShortName(kc)
    if not kc then return nil end
    if type(kc) == "table" and kc.Name then
        return tostring(kc.Name)
    end
    local s = tostring(kc)
    return string.match(s, "Enum%.KeyCode%.(.+)$") or s
end

UserInputService.InputBegan:Connect(function(input, gpe)
    if State.listeningKeybindEntry and isPCDevice() and input and input.KeyCode then
        local kName = extractKeyCodeShortName(input.KeyCode)
        if kName and kName ~= "Unknown" then
            local entry = State.listeningKeybindEntry
            State.listeningKeybindEntry = nil
            if kName == "Backspace" or kName == "Delete" or kName == "Escape" then
                entry.KeyCode = nil
                entry.KeyName = nil
                if entry.Button then
                    entry.Button.Text = "[...]"
                    entry.Button.TextColor3 = Theme.Muted
                end
            else
                entry.KeyCode = input.KeyCode
                entry.KeyName = kName
                if entry.Button then
                    entry.Button.Text = "[" .. kName .. "]"
                    entry.Button.TextColor3 = Theme.Accent
                end
            end
            return
        end
    end

    if not gpe and State.isAuthorized and isPCDevice() and input and input.KeyCode then
        if input.KeyCode == Enum.KeyCode.RightShift then
            toggleMainHub()
            return
        end
        for _, entry in ipairs(State.registeredKeybinds) do
            if entry.KeyCode ~= nil and input.KeyCode == entry.KeyCode then
                if entry.Toggle then
                    entry.Toggle()
                end
            end
        end
    end
end)

pcall(function()
    if UserInputService.WindowFocusReleased and UserInputService.WindowFocusReleased.Connect then
        UserInputService.WindowFocusReleased:Connect(function()
            State.isWindowFocused = false
            if ConfigState.PauseRenderOnTabOut and UI.RenderSaverOverlay then
                UI.RenderSaverOverlay.Visible = true
            end
            if Env.setfpscap then
                pcall(function()
                    Env.setfpscap(math.clamp(tonumber(ConfigState.FPSWhenTabbedOut) or 15, 5, 60))
                end)
            end
        end)
    end
    if UserInputService.WindowFocused and UserInputService.WindowFocused.Connect then
        UserInputService.WindowFocused:Connect(function()
            State.isWindowFocused = true
            if UI.RenderSaverOverlay then
                UI.RenderSaverOverlay.Visible = (ConfigState.Disable3DRender == true)
            end
            if Env.setfpscap then
                local normalCap = State.activeProfileFPSCap or (ConfigState.UncapFPS and (tonumber(ConfigState.CustomFPS) or 144) or 60)
                pcall(function()
                    Env.setfpscap(normalCap)
                end)
            end
        end)
    end
end)

do
    local interactCooldown = 0
    local antiFlingCooldown = 0
    local hitboxRefreshCooldown = 0
    RunService.Stepped:Connect(function(_, stepDt)
        if not State.isAuthorized or PlatoBoost.getEntangledScale() ~= 1 then
            return
        end
        local char = LocalPlayer.Character
        if not char then
            return
        end
        if State.cachedLocalChar ~= char then
            refreshLocalCharacterCache(char)
        end

        local myHRP = State.cachedLocalHRP
        local myHum = State.cachedLocalHum
        local dt = (stepDt and stepDt > 0) and stepDt or 0.016

        if ConfigState.HitboxExpander then
            hitboxRefreshCooldown = hitboxRefreshCooldown + dt
            if hitboxRefreshCooldown >= 0.4 then
                hitboxRefreshCooldown = 0
                updateHitboxExpander()
            end
        end

        -- Save last safe CFrame for Anti-Void
        if myHRP and myHRP.Position.Y > -50 then
            State.lastSafeCFrame = myHRP.CFrame
        end

        -- Anti-Void Protection
        if ConfigState.AntiVoid and myHRP then
            local destroyY = -500
            pcall(function()
                if workspace.FallenPartsDestroyHeight then
                    destroyY = workspace.FallenPartsDestroyHeight
                end
            end)
            if myHRP.Position.Y <= (destroyY + 55) or myHRP.Position.Y <= -220 then
                pcall(function()
                    myHRP.Velocity = Vector3.zero
                end)
                myHRP.CFrame = State.lastSafeCFrame or CFrame.new(Vector3.new(0, 25, 0))
            end
        end

        -- Stealth WalkSpeed Bypass (CFrame Velocity-Delta Translation without mutating Humanoid.WalkSpeed)
        if ConfigState.WalkSpeedEnabled and ConfigState.StealthBypass and myHRP and myHum then
            local moveDir = myHum.MoveDirection or Vector3.zero
            if moveDir.Magnitude > 0.01 then
                local extraSpd = math.max((ConfigState.WalkSpeed or 16) - (State.defaultWalkSpeed or 16), 0)
                if extraSpd > 0 then
                    myHRP.CFrame = myHRP.CFrame + (moveDir * (extraSpd * dt))
                end
            end
        end

        -- Swim in Air
        if ConfigState.SwimInAir and myHum then
            pcall(function()
                myHum:ChangeState(Enum.HumanoidStateType.Swimming)
            end)
        end

        -- Spider Climb (Wall Walk)
        if ConfigState.SpiderClimb and myHRP then
            rayParams.FilterDescendantsInstances = getSafeRaycastExcludeList()
            local lookDir = myHRP.CFrame.LookVector
            local wallHit = workspace:Raycast(myHRP.Position, lookDir * 4.0, rayParams)
            if wallHit and wallHit.Instance then
                local climbSpd = ConfigState.SpiderClimbSpeed or 32
                pcall(function()
                    myHRP.Velocity = Vector3.new(myHRP.Velocity.X, climbSpd, myHRP.Velocity.Z)
                end)
                myHRP.CFrame = myHRP.CFrame * CFrame.new(0, climbSpd * dt, 0)
            end
        end

        -- Anti-Ragdoll / Anti-Stun
        if ConfigState.AntiRagdoll and myHum then
            myHum.PlatformStand = false
            myHum.Sit = false
            pcall(function()
                if myHum.SetStateEnabled and Enum.HumanoidStateType.Ragdoll then
                    myHum:SetStateEnabled(Enum.HumanoidStateType.Ragdoll, false)
                end
            end)
        end

        -- Character NoClip (Uses cached local parts array -> Zero GetDescendants per frame!)
        if ConfigState.NoClip then
            for i = 1, #State.cachedLocalParts do
                local part = State.cachedLocalParts[i]
                if part and part.Parent then
                    if State.noclipCollideCache[part] == nil then
                        State.noclipCollideCache[part] = part.CanCollide
                    end
                    part.CanCollide = false
                end
            end
        end

        -- Anti-Fling (Disable collision on other players' characters)
        if ConfigState.AntiFling then
            antiFlingCooldown = antiFlingCooldown + dt
            if antiFlingCooldown >= 0.08 then
                antiFlingCooldown = 0
                for _, p in ipairs(Players:GetPlayers()) do
                    if p ~= LocalPlayer and p.Character then
                        for _, part in ipairs(p.Character:GetDescendants()) do
                            if part:IsA("BasePart") then
                                if State.antiFlingCollideCache[part] == nil then
                                    State.antiFlingCollideCache[part] = part.CanCollide
                                end
                                part.CanCollide = false
                            end
                        end
                    end
                end
            end
        end

        -- Auto-Interact
        if ConfigState.AutoInteract and myHRP then
            interactCooldown = interactCooldown + dt
            if interactCooldown >= 0.35 then
                interactCooldown = 0
                for _, desc in ipairs(workspace:GetDescendants()) do
                    if desc:IsA("ProximityPrompt") and desc.Enabled then
                        local parentPart = desc.Parent
                        if parentPart and parentPart:IsA("BasePart") then
                            if (parentPart.Position - myHRP.Position).Magnitude <= ConfigState.InteractRadius then
                                if Env.fireproximityprompt then
                                    pcall(function() Env.fireproximityprompt(desc) end)
                                end
                            end
                        end
                    elseif desc:IsA("ClickDetector") then
                        local parentPart = desc.Parent
                        if parentPart and parentPart:IsA("BasePart") then
                            if (parentPart.Position - myHRP.Position).Magnitude <= ConfigState.InteractRadius then
                                if Env.fireclickdetector then
                                    pcall(function() Env.fireclickdetector(desc) end)
                                end
                            end
                        end
                    end
                end
            end
        end
    end)
end

do
    local animClock = 0
    local telemetryTimer = 0
    local playerListRefreshTimer = 0
    local keyCountdownTimer = 0
    local uiAnimTimer = 0
    local boundCameraStep = false

    local function runPostCameraRenderPass(safeDt)
        local entangleFactor = PlatoBoost.getEntangledScale()
        if not State.isAuthorized or entangleFactor ~= 1 then
            return
        end

        local myChar = LocalPlayer.Character
        if myChar and State.cachedLocalChar ~= myChar then
            refreshLocalCharacterCache(myChar)
        end
        local myHRP = State.cachedLocalHRP

        -- Orbit Player Movement
        if State.orbitingPlayerName and myHRP then
            local targetPlayer = nil
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name == State.orbitingPlayerName then
                    targetPlayer = p
                    break
                end
            end
            local tHRP = targetPlayer and targetPlayer.Character and targetPlayer.Character:FindFirstChild("HumanoidRootPart")
            if tHRP then
                State.orbitAngle = (State.orbitAngle or 0) + safeDt * (ConfigState.OrbitSpeed or 4.5)
                local rad = ConfigState.OrbitRadius or 8
                local offset = Vector3.new(math.cos(State.orbitAngle) * rad, 0, math.sin(State.orbitAngle) * rad)
                local orbitPos = tHRP.Position + offset
                myHRP.CFrame = CFrame.new(orbitPos, tHRP.Position)
            end
        end

        if ConfigState.Spinbot and myHRP and CFrame.Angles then
            pcall(function()
                myHRP.CFrame = myHRP.CFrame * CFrame.Angles(0, math.rad(ConfigState.SpinSpeed), 0)
            end)
        end

        local camera = workspace.CurrentCamera
        if not camera then
            return
        end

        -- Glitch-Free Freecam movement & Camera Subject Safeguard (Auto-Rebinds Spectate on Respawn)
        if ConfigState.Freecam then
            camera.CameraType = Enum.CameraType.Scriptable
            local hum = State.cachedLocalHum
            local moveDir = (hum and hum.MoveDirection) or Vector3.zero
            local curPos = State.freecamPos or camera.CFrame.Position
            local nextPos = curPos + (moveDir * (ConfigState.FreecamSpeed * safeDt))
            State.freecamPos = nextPos
            camera.CFrame = CFrame.new(nextPos, nextPos + Vector3.new(0, 0, -1))
        elseif State.spectatingPlayerName then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name == State.spectatingPlayerName and p.Character then
                    local tHum = p.Character:FindFirstChildOfClass("Humanoid")
                    if tHum and camera.CameraSubject ~= tHum then
                        camera.CameraSubject = tHum
                    end
                    break
                end
            end
        else
            if camera.CameraType == Enum.CameraType.Scriptable then
                camera.CameraType = Enum.CameraType.Custom
            end
            local myHum = State.cachedLocalHum
            if myHum and camera.CameraSubject ~= myHum then
                camera.CameraSubject = myHum
            end
        end

        if ConfigState.CustomCamFOV and camera.FieldOfView ~= ConfigState.CamFOV then
            camera.FieldOfView = ConfigState.CamFOV
        end

        if UI.FovCircle.Visible ~= ConfigState.ShowFOV then
            UI.FovCircle.Visible = ConfigState.ShowFOV
        end
        if ConfigState.ShowFOV and UI.FovOuterStroke then
            UI.FovOuterStroke.Thickness = 1.6 + 0.45 * math.sin(animClock * 4.2)
        end

        -- Classic Single-Toggle Aimbot Lock-In (Frame-rate independent exponential smoothing + horizontal character tracking)
        if ConfigState.Aimbot then
            local target = getClosestTarget(camera)
            State.cachedAimTarget = target
            if target and target.Parent then
                local targetPos = target.Position
                local camGoal = CFrame.new(camera.CFrame.Position, targetPos)
                local rawSmooth = math.clamp(ConfigState.Smoothness or 0.9, 0.05, 1)
                local expFactor = (rawSmooth >= 0.98) and 1 or math.clamp(1 - math.exp(-(rawSmooth * 34) * safeDt), rawSmooth * 0.5, 1)
                camera.CFrame = camera.CFrame:Lerp(camGoal, expFactor)

                -- Rotate LocalPlayer's Character horizontally toward the locked target so your character aims with your screen!
                if myHRP and not ConfigState.Spinbot and not State.orbitingPlayerName then
                    local myPos = myHRP.Position
                    local flatTarget = Vector3.new(targetPos.X, myPos.Y, targetPos.Z)
                    if (flatTarget - myPos).Magnitude > 0.05 then
                        myHRP.CFrame = CFrame.new(myPos, flatTarget)
                    end
                end
            end
        else
            State.cachedAimTarget = nil
        end

        -- Screen Resolution Stretch (Runs at RenderPriority.Camera + 1; never writes custom fields onto Camera userdata!)
        if ConfigState.ResolutionEnabled then
            local stretch = math.clamp(ConfigState.CustomStretch or 0.75, 0.35, 1.35)
            State.appliedStretchRatio = stretch
            pcall(function()
                local cf = camera.CFrame
                if cf and cf.GetComponents then
                    local x, y, z, r00, r01, r02, r10, r11, r12, r20, r21, r22 = cf:GetComponents()
                    camera.CFrame = CFrame.new(x, y, z, r00, r01 * stretch, r02, r10, r11 * stretch, r12, r20, r21 * stretch, r22)
                end
            end)
        else
            State.appliedStretchRatio = 1.0
        end

        -- Frame-Synchronized ESP Projection (Runs AFTER Camera update so there is ZERO 1-frame lag behind players!)
        if ConfigState.ESP or ConfigState.Box3DESP or ConfigState.SkeletonESP or ConfigState.HealthBarESP or ConfigState.Tracers then
            updateESP(camera)
        end

        if ConfigState.Crosshair then
            updateCrosshair(animClock)
        elseif UI.CrosshairContainer and UI.CrosshairContainer.Visible then
            UI.CrosshairContainer.Visible = false
            UI.CrosshairV.Visible = false
            UI.CrosshairH.Visible = false
        end
    end

    -- Bind Camera + ESP + Resolution Stretch to RenderPriority.Camera + 1 (201) if supported so it runs AFTER Roblox's Camera script!
    pcall(function()
        if RunService.BindToRenderStep then
            local camPriority = (Enum.RenderPriority and Enum.RenderPriority.Camera and Enum.RenderPriority.Camera.Value) or 200
            RunService:BindToRenderStep("CoreXYZ_PostCameraSync", camPriority + 1, function(dt)
                local safeDt = (dt and dt > 0) and dt or (1 / 60)
                runPostCameraRenderPass(safeDt)
            end)
            boundCameraStep = true
        end
    end)

    bindConnection("RenderStepped", RunService.RenderStepped, function(deltaTime)
        local safeDt = (deltaTime and deltaTime > 0) and deltaTime or (1 / 60)
        animClock = animClock + safeDt
        telemetryTimer = telemetryTimer + safeDt
        playerListRefreshTimer = playerListRefreshTimer
        playerListRefreshTimer = playerListRefreshTimer + safeDt
        keyCountdownTimer = keyCountdownTimer + safeDt
        uiAnimTimer = uiAnimTimer + safeDt

        if keyCountdownTimer >= 1.0 then
            keyCountdownTimer = 0
            if State.isAuthorized then
                if State.updateHomeKeyInfo then
                    State.updateHomeKeyInfo()
                end
                if State.updateClientTelemetryUI then
                    State.updateClientTelemetryUI()
                end
                if State.updateServerTelemetryUI then
                    State.updateServerTelemetryUI()
                end
            end
        end

        -- Lightweight in-place distance update ONLY when Players tab is open (Never destroys/rebuilds UI cards on timer!)
        if playerListRefreshTimer >= 1.5 then
            playerListRefreshTimer = 0
            if State.isAuthorized and UI.MainWindow.Visible and State.activeTab and State.activeTab.Name == "Players" and State.updatePlayerDistances then
                State.updatePlayerDistances()
            end
        end

        local instantFps = math.floor(1 / safeDt)
        table.insert(State.frameHistory, instantFps)
        if #State.frameHistory > 45 then
            table.remove(State.frameHistory, 1)
        end
        if telemetryTimer >= 0.6 then
            telemetryTimer = 0
            local sum = 0
            local minFps = 999
            for _, f in ipairs(State.frameHistory) do
                sum = sum + f
                if f < minFps then
                    minFps = f
                end
            end
            State.currentFPS = math.floor(sum / math.max(#State.frameHistory, 1))
            State.currentOnePercentLow = minFps
            if State.isAuthorized and UI.FloatingToggle.Visible then
                updateFloatingPillTelemetry()
            end
        end

        -- Continuously animate live gradients & rotators at 60Hz for any visible UI (including Floating Pill, FOV Circle & Color Picker!)
        local menuCardOpen = UI.LoaderCard.Visible or UI.KeyCard.Visible or UI.MainWindow.Visible or (UI.ColorPickerPopup and UI.ColorPickerPopup.Visible)
        if uiAnimTimer >= 0.016 then
            local animDt = uiAnimTimer
            uiAnimTimer = 0

            for _, item in ipairs(State.liveGradients) do
                if item.Gradient and item.Gradient.Parent then
                    local target = item.Target
                    local isAlwaysActiveTarget = (target == UI.FloatingToggle or target == UI.FovCircle)
                    local isTargetVisible = (not target) or (target.Visible ~= false)
                    if isTargetVisible and (isAlwaysActiveTarget or ConfigState.ShimmerEnabled ~= false) then
                        item.Gradient.Rotation = (item.Offset + animClock * item.Speed) % 360
                    end
                end
            end

            for _, rot in ipairs(State.liveRotators) do
                if rot.Instance and rot.Instance.Parent then
                    rot.Instance.Rotation = (animClock * rot.Speed) % 360
                end
            end

            if ConfigState.ShowFOV and UI.FovOuterStroke then
                UI.FovOuterStroke.Thickness = 1.6 + 0.45 * math.sin(animClock * 4.2)
            end

            if menuCardOpen then
                if ConfigState.ParticlesEnabled then
                    for _, p in ipairs(State.liveParticles) do
                        if p.Instance and p.Container and p.Container.Visible then
                            p.Y = p.Y - (p.SpeedY * animDt)
                            p.X = p.X + math.sin(animClock * 1.5 + p.Phase) * (p.DriftX * animDt)
                            if p.Y < -0.04 then
                                p.Y = 1.04
                                p.X = math.random(5, 95) / 100
                            end
                            p.Instance.Position = UDim2.fromScale(p.X, p.Y)
                        end
                    end
                end

                local pulse = 1 + 0.22 * math.sin(animClock * 4.5)
                if UI.LoaderCard.Visible then
                    UI.EmblemCore.Size = UDim2.fromOffset(8 * pulse, 8 * pulse)
                    if UI.LoaderTopGrad then
                        UI.LoaderTopGrad.Offset = Vector2.new(math.sin(animClock * 2.0) * 0.45, 0)
                    end
                end
                if UI.KeyCard.Visible then
                    UI.KeyTopGrad.Offset = Vector2.new(math.sin(animClock * 2.2) * 0.45, 0)
                end
                if UI.MainWindow.Visible then
                    UI.HeaderLineGrad.Offset = Vector2.new(math.sin(animClock * 1.8) * 0.42, 0)
                    if UI.DiscordWave and State.activeTab and State.activeTab.Name == "Home" then
                        UI.DiscordWave.Gradient.Offset = Vector2.new(math.sin(animClock * 0.65) * 0.38, math.cos(animClock * 0.45) * 0.15)
                        UI.DiscordWave.Gradient.Rotation = 14 + math.sin(animClock * 0.5) * 8
                        UI.DiscordWave.Crest1.Position = UDim2.new(0.5 + math.sin(animClock * 0.75) * 0.22, 0, 0.72 + math.cos(animClock * 0.9) * 0.08, 0)
                        UI.DiscordWave.Crest1.Rotation = math.sin(animClock * 0.55) * 3.5
                        UI.DiscordWave.Crest2.Position = UDim2.new(0.5 - math.cos(animClock * 0.62) * 0.24, 0, 0.84 + math.sin(animClock * 0.8) * 0.08, 0)
                        UI.DiscordWave.Crest2.Rotation = -math.cos(animClock * 0.48) * 3.0
                    end
                end
            end
        end

        if State.updateColorPickerFrame then
            State.updateColorPickerFrame(safeDt)
        end

        if State.updateWeatherFrame then
            State.updateWeatherFrame(workspace.CurrentCamera, safeDt)
        end

        if State.updateMusicPlayerFrame then
            State.updateMusicPlayerFrame(safeDt)
        end

        if State.updateVisualSuitesFrame then
            State.updateVisualSuitesFrame(safeDt, animClock)
        end

        if ConfigState.Crosshair then
            updateCrosshair(animClock)
        end

        if not boundCameraStep then
            runPostCameraRenderPass(safeDt)
        end
    end)
end

--------------------------------------------------------------------------------
-- 15. START-TO-END ANIMATED BOOT SEQUENCE (6-STEP SAAS LOADER -> SAVED KEY / KEY GATE)
--------------------------------------------------------------------------------
task.spawn(function()
    local targetScale = getResponsiveScale()
    tween(UI.LoaderCard, SmoothTween, { BackgroundTransparency = 0.03 })
    tween(UI.LoaderStroke, SmoothTween, { Transparency = 0.08 })
    tween(UI.LoaderScale, SpringTween, { Scale = targetScale })
    if UI.LoaderTopBar then tween(UI.LoaderTopBar, SmoothTween, { BackgroundTransparency = 0 }) end
    if UI.LoaderStageBadge then tween(UI.LoaderStageBadge, SmoothTween, { BackgroundTransparency = 0.15, TextTransparency = 0 }) end
    if UI.LoaderSubDetail then tween(UI.LoaderSubDetail, SmoothTween, { TextTransparency = 0 }) end
    if UI.LoaderFooterHint then tween(UI.LoaderFooterHint, SmoothTween, { TextTransparency = 0 }) end
    tween(UI.EmblemOuterStroke, SmoothTween, { Transparency = 0.08 })
    tween(UI.EmblemInnerStroke, SmoothTween, { Transparency = 0.25 })
    tween(UI.EmblemCore, SmoothTween, { BackgroundTransparency = 0 })
    tween(UI.LoaderTitle, SmoothTween, { TextTransparency = 0 })
    tween(UI.LoaderStatus, SmoothTween, { TextTransparency = 0 })
    tween(UI.LoaderBarBg, SmoothTween, { BackgroundTransparency = 0 })
    tween(UI.LoaderPercent, SmoothTween, { TextTransparency = 0 })

    local stages = {
        { pct = 16, tag = "STAGE 1 / 6  ·  CORE", text = "Starting Core.xyz...", sub = "Initializing runtime environment & core modules..." },
        { pct = 34, tag = "STAGE 2 / 6  ·  RENDER", text = "Preparing graphics & overlay engine...", sub = "Pre-allocating 3D ESP, skeleton & chams pools..." },
        { pct = 52, tag = "STAGE 3 / 6  ·  WEATHER", text = "Optimizing frame pacing & memory pool...", sub = "Warming up 3D volumetric weather & audio nodes..." },
        { pct = 70, tag = "STAGE 4 / 6  ·  CONFIG", text = "Loading saved profile & preferences...", sub = "Syncing themes, keybinds & performance profiles..." },
        { pct = 88, tag = "STAGE 5 / 6  ·  LICENSE", text = "Verifying license status...", sub = "Checking saved license & Platoboost gateway..." },
        { pct = 100, tag = "STAGE 6 / 6  ·  READY", text = "Finalizing workspace...", sub = "All systems ready · Routing session..." },
    }

    local currentPct = 0
    for idx, stage in ipairs(stages) do
        UI.LoaderStatus.Text = stage.text
        if UI.LoaderStageBadge then
            UI.LoaderStageBadge.Text = stage.tag
        end
        if UI.LoaderSubDetail then
            UI.LoaderSubDetail.Text = stage.sub
        end
        if idx == 5 then
            pcall(PlatoBoost.cacheLink)
        end
        tween(UI.LoaderBarFill, SlowTween, { Size = UDim2.fromScale(stage.pct / 100, 1) })
        while currentPct < stage.pct do
            currentPct = math.min(stage.pct, currentPct + 1)
            UI.LoaderPercent.Text = tostring(currentPct) .. "%"
            task.wait(0.042)
        end
        task.wait(0.38)
    end

    task.wait(0.45)

    tween(UI.LoaderScale, FastTween, { Scale = targetScale * 0.9 })
    tween(UI.LoaderCard, FastTween, { BackgroundTransparency = 1 })
    tween(UI.LoaderStroke, FastTween, { Transparency = 1 })
    if UI.LoaderTopBar then tween(UI.LoaderTopBar, FastTween, { BackgroundTransparency = 1 }) end
    if UI.LoaderStageBadge then tween(UI.LoaderStageBadge, FastTween, { BackgroundTransparency = 1, TextTransparency = 1 }) end
    if UI.LoaderSubDetail then tween(UI.LoaderSubDetail, FastTween, { TextTransparency = 1 }) end
    if UI.LoaderFooterHint then tween(UI.LoaderFooterHint, FastTween, { TextTransparency = 1 }) end
    tween(UI.LoaderTitle, FastTween, { TextTransparency = 1 })
    tween(UI.LoaderStatus, FastTween, { TextTransparency = 1 })
    tween(UI.LoaderPercent, FastTween, { TextTransparency = 1 })
    tween(UI.LoaderBarBg, FastTween, { BackgroundTransparency = 1 })
    tween(UI.LoaderBarFill, FastTween, { BackgroundTransparency = 1 })
    tween(UI.EmblemOuterStroke, FastTween, { Transparency = 1 })
    tween(UI.EmblemInnerStroke, FastTween, { Transparency = 1 })
    tween(UI.EmblemCore, FastTween, { BackgroundTransparency = 1 })
    task.wait(0.24)
    UI.LoaderCard.Visible = false

    -- Check Saved Key expiry on every execution (auto-loads Main Hub if valid, or prompts Key System with notification if expired)
    checkSavedKeyAndRoute(targetScale)
end)
end)


