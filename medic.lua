script_name('Medic')
script_authors("Galileo_Galilei, Serhiy_Rubin")
script_version("1.6.7")
local inicfg, ffi = require 'inicfg', require("ffi")
local sampev = require "lib.samp.events"
local wm = require('windows.message')
local vkeys = require 'lib.vkeys'
local encoding = require "encoding"
require "lib.moonloader"
encoding.default = 'CP1251'
u8 = encoding.UTF8

local r = { mouse = false, ShowClients = false, ShowCMD = false, id = 0, nick = "", dir = "", dialog = 0 }
local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'РћР±РЅР°СЂСѓР¶РµРЅРѕ РѕР±РЅРѕРІР»РµРЅРёРµ. РџС‹С‚Р°СЋСЃСЊ РѕР±РЅРѕРІРёС‚СЊСЃСЏ c '..thisScript().version..' РЅР° '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Р—Р°РіСЂСѓР¶РµРЅРѕ %d РёР· %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Р—Р°РіСЂСѓР·РєР° РѕР±РЅРѕРІР»РµРЅРёСЏ Р·Р°РІРµСЂС€РµРЅР°.')sampAddChatMessage(b..'РћР±РЅРѕРІР»РµРЅРёРµ Р·Р°РІРµСЂС€РµРЅРѕ!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'РћР±РЅРѕРІР»РµРЅРёРµ РїСЂРѕС€Р»Рѕ РЅРµСѓРґР°С‡РЅРѕ. Р—Р°РїСѓСЃРєР°СЋ СѓСЃС‚Р°СЂРµРІС€СѓСЋ РІРµСЂСЃРёСЋ..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': РћР±РЅРѕРІР»РµРЅРёРµ РЅРµ С‚СЂРµР±СѓРµС‚СЃСЏ.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': РќРµ РјРѕРіСѓ РїСЂРѕРІРµСЂРёС‚СЊ РѕР±РЅРѕРІР»РµРЅРёРµ. РЎРјРёСЂРёС‚РµСЃСЊ РёР»Рё РїСЂРѕРІРµСЂСЊС‚Рµ СЃР°РјРѕСЃС‚РѕСЏС‚РµР»СЊРЅРѕ РЅР° '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, РІС‹С…РѕРґРёРј РёР· РѕР¶РёРґР°РЅРёСЏ РїСЂРѕРІРµСЂРєРё РѕР±РЅРѕРІР»РµРЅРёСЏ. РЎРјРёСЂРёС‚РµСЃСЊ РёР»Рё РїСЂРѕРІРµСЂСЊС‚Рµ СЃР°РјРѕСЃС‚РѕСЏС‚РµР»СЊРЅРѕ РЅР° '..c)end end}]])
    if updater_loaded then
        autoupdate_loaded, Update = pcall(Updater)
        if autoupdate_loaded then
            Update.json_url = "https://raw.githubusercontent.com/EX4MPLE-Fiery/medic_helper/main/version.json?" .. tostring(os.clock())
            Update.prefix = "[" .. string.upper(thisScript().name) .. "]: "
            Update.url = "https://github.com/EX4MPLE-Fiery/medic_helper"
        end
    end
end
ffi.cdef [[ bool SetCursorPos(int X, int Y); ]]
local ini = inicfg.load({
Settings = {
	SkinButton = true,
	FontName = 'Arial',
	FontSize = 11,
	FontFlag = 13,
	Color1 = "FFFFFF",
	Color2 = "e89f00",
	Key = 0x02,
	hud_x = 1.0,
	hud_y = 1.0,
	hudtoggle = true,
	zptoggle = true,
	ChatPosX = 1.0,
	ChatPosY = 1.0,
	ChatFontSize = 11,
	ChatToggle = true,
},
Info = {
	rank = "РњРµРґ.СЂР°Р±РѕС‚РЅРёРє",
	clist = "18",
	tag = "Student MoH",
	reg = "SFMC",
	sex = true
}
})
if inicfg.load(nil, "Medic") == nil then inicfg.save(ini, "Medic") end
local ini = inicfg.load(nil, "Medic")

skins = { 308, 70, 219, 274, 275, 276 }
function check_skin_local_player()
	local result = false
	for k,v in pairs(skins) do
		if isCharModel(PLAYER_PED, v) then
			result = true
			break
		end
	end
	return result
end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end	

	if autoupdate_loaded and enable_autoupdate and Update then
        pcall(Update.check, Update.json_url, Update.prefix, Update.url)
    end

	sampAddChatMessage("{ff263c}[Medic] {ffffff}РЎРєСЂРёРїС‚ СѓСЃРїРµС€РЅРѕ Р·Р°РіСЂСѓР¶РµРЅ. {fc0303}Р’РµСЂСЃРёСЏ: 1.6.7", -1)

	chatfont = renderCreateFont(ini.Settings.FontName, ini.Settings.ChatFontSize, ini.Settings.FontFlag)
	font = renderCreateFont(ini.Settings.FontName, ini.Settings.FontSize, ini.Settings.FontFlag)
	fontPosButton = renderCreateFont(ini.Settings.FontName, ini.Settings.FontSize - 2, ini.Settings.FontFlag)
	fontpmbuttons = renderCreateFont(ini.Settings.FontName, ini.Settings.FontSize + 4, ini.Settings.FontFlag)

	sampRegisterChatCommand("medic_hud_pos",function()
		medic_hud_pos = true	
	end)

	sampRegisterChatCommand("medic_chat_pos",function()
		medic_chat_pos = true	
	end)

	while true do
		wait(0)
		timer(toggle)
		if ini.Settings.ChatToggle then
			ChatToggleText = "{33bf00}Р’РєР»"
			render_chat()
		else 
			ChatToggleText = "{ff0000}Р’С‹РєР»"
		end
		if ini.Settings.zptoggle then
			ZpToggleText = "{33bf00}Р’РєР»"
			zp()
		else
			ZpToggleText = "{ff0000}Р’С‹РєР»"
		end
		if ini.Settings.hudtoggle then
			hudtoggletext = "{33bf00}Р’РєР»"
			render_hud()
			counter()
			partner()
			locations()
		else
			hudtoggletext = "{ff0000}Р’С‹РєР»"
		end
		if (isKeyDown(ini.Settings.Key) and check_skin_local_player()) then
			local X, Y = getScreenResolution()
			Y = Y / 3
			X = X - renderGetFontDrawTextLength(font, " ")
			if not r.mouse then
				r.mouse = true
				r.ShowCMD = false
				menu_1 = {}
				menu_2 = {}
				menu_1o = {}
				menu_1no = {}
				menu_heal = {}
				menu_healdisease = {}
				menu_healwoundper = {}
				menu_healwoundran = {}
				menu_mc = {}
				menu_setsex = {}
				menu_binds = false
				menu_myinfo = false
				menu_doklad = false
				menu_settings = false
			end
			sampSetCursorMode(2)
			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "РћРЅР»Р°Р№РЅ РјРµРґРёРєРё"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				sampSendChat("/members 1")
			end
			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "РЎРїРёСЃРѕРє РІС‹Р·РѕРІРѕРІ"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				sampSendChat("/service")
			end
			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "Р‘С‹СЃС‚СЂС‹Рµ РєРѕРјР°РЅРґС‹"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				sampSendChat("/fmenu")
			end
			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "РЎРјРµРЅРёС‚СЊ Р±РѕР»СЊРЅРёС†Сѓ"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				sampSendChat("/spawnchange")
			end
			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "РњРѕРё РґР°РЅРЅС‹Рµ"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				menu_myinfo = not menu_myinfo
				menu_binds = false
				menu_doklad = false
			end
			if menu_myinfo then
				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "РџРѕР»: {FFFFFF}"..sex
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y, 0xFF858585, 0xFFFFFFFF) then
					ini.Settings.sex = not ini.Settings.sex
					inicfg.save(ini, "Medic")
					thisScript():reload()
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Р”РѕР»Р¶РЅРѕСЃС‚СЊ: {FFFFFF}"..ini.Info.rank
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y, 0xFF858585, 0xFFFFFFFF) then
					sampShowDialog(6406, "РЈРєР°Р¶РёС‚Рµ РІР°С€Сѓ РґРѕР»Р¶РЅРѕСЃС‚СЊ", "Р’Р°С€Р° РґРѕР»Р¶РЅРѕСЃС‚СЊ:", "РћРљ", "РћС‚РјРµРЅР°", DIALOG_STYLE_INPUT)
				end
				result1, button1, _, rank = sampHasDialogRespond(6406)
				if result1 then
					if button1 == 1 then
						if string.find(rank, "(.+)") then
							ini.Info.rank = rank
							inicfg.save(ini, "Medic")
							thisScript():reload()
						end
						if #rank > 0 then
							ini.Info.rank = rank
							inicfg.save(ini, "Medic")
						end
					end
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "РўСЌРі: {FFFFFF}"..ini.Info.tag
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y, 0xFF858585, 0xFFFFFFFF) then
					sampShowDialog(6410, "РЈРєР°Р¶РёС‚Рµ РІР°С€ С‚СЌРі", "Р’Р°С€ С‚СЌРі:", "РћРљ", "РћС‚РјРµРЅР°", DIALOG_STYLE_INPUT)
				end
				result2, button2, _, tag = sampHasDialogRespond(6410)
				if result2 then
					if button2 == 1 then
						if string.find(tag, "(.+)") then
							ini.Info.tag = tag
							inicfg.save(ini, "Medic")
							thisScript():reload()
						end
						if #tag > 0 then
							ini.Info.tag = tag
							inicfg.save(ini, "Medic")
						end
					end
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Р‘РµР№РґР¶: {FFFFFF}"..ini.Info.clist
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y, 0xFF858585, 0xFFFFFFFF) then
					sampShowDialog(6411, "РЈРєР°Р¶РёС‚Рµ РІР°С€ Р±РµР№РґР¶", "Р’Р°С€ Р±РµР№РґР¶:", "РћРљ", "РћС‚РјРµРЅР°", DIALOG_STYLE_INPUT)
				end
				result3, button3, _, clist = sampHasDialogRespond(6411)
				if result3 then
					if button3 == 1 then
						if string.find(clist, "(.+)") then
							ini.Info.clist = clist
							inicfg.save(ini, "Medic")
							thisScript():reload()
						end
						if #clist > 0 then
							ini.Info.clist = clist
							inicfg.save(ini, "Medic")
						end
					end
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Р‘РѕР»СЊРЅРёС†Р°: {FFFFFF}"..ini.Info.reg
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y, 0xFF858585, 0xFFFFFFFF) then
					sampShowDialog(6412, "РЈРєР°Р¶РёС‚Рµ РІР°С€Сѓ СЂРµРіРёСЃС‚СЂР°С‚СѓСЂСѓ", "Р’Р°С€Р° СЂРµРіРёСЃС‚СЂР°С‚СѓСЂР°:", "РћРљ", "РћС‚РјРµРЅР°", DIALOG_STYLE_INPUT)
				end
				result4, button4, _, reg = sampHasDialogRespond(6412)
				if result4 then
					if button4 == 1 then
						if string.find(reg, "(.+)") then
							ini.Info.reg = reg
							inicfg.save(ini, "Medic")
							thisScript():reload()
						end
						if #reg > 0 then
							ini.Info.reg = reg
							inicfg.save(ini, "Medic")
						end
					end
				end
			end

			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "РќР°СЃС‚СЂРѕР№РєРё"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				menu_settings = not menu_settings
			end
			if menu_settings then
				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "РђРІС‚РѕРґРѕРєР»Р°РґС‹ "..toggletext
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
					toggle = not toggle
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Р—Р°СЂРїР»Р°С‚Р° "..ZpToggleText
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
					ini.Settings.zptoggle = not ini.Settings.zptoggle
					inicfg.save(ini, "Medic")
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "HUD "..hudtoggletext
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
					ini.Settings.hudtoggle = not ini.Settings.hudtoggle
					inicfg.save(ini, "Medic")
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Chat "..ChatToggleText
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
					ini.Settings.ChatToggle = not ini.Settings.ChatToggle
					inicfg.save(ini, "Medic")
				end
			end

			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "РћР±С‰РёРµ Р±РёРЅРґС‹"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y + 20, 0xFFFFFFFF, 0xFFFFFFFF) then
				menu_binds = not menu_binds
				menu_myinfo = false
				menu_doklad = false
			end

			if menu_binds then
				lua_thread.create(function()
					local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
					local nickname = string.gsub(sampGetPlayerNickname(myid), '_',' ')
					local name, surname = string.match(nickname, "(.+) (.+)")
					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "РџСЂРёРІРµС‚СЃС‚РІРёРµ"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/todo Р—РґСЂР°РІСЃС‚РІСѓР№С‚Рµ! РЇ РґРѕРєС‚РѕСЂ "..surname.."! *СѓР»С‹Р±Р°СЏСЃСЊ")
						wait(1000)
						sampSendChat("/do РќР° Р±РµР№РґР¶РёРєРµ: "..ini.Info.tag.." | Р”РѕРєС‚РѕСЂ "..surname.." | "..ini.Info.rank.."")
						wait(1000)
						sampSendChat("Р§С‚Рѕ Р’Р°СЃ Р±РµСЃРїРѕРєРѕРёС‚?")
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "РџРѕРїСЂРѕСЃРёС‚СЊ СЃР»РµРґРѕРІР°С‚СЊ"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("РџСЂРѕР№РґС‘РјС‚Рµ Р·Р° РјРЅРѕР№")
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "РџСЂРѕС‰Р°РЅРёРµ"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("Р’СЃРµРіРѕ РґРѕР±СЂРѕРіРѕ Рё РЅРµ Р±РѕР»РµР№С‚Рµ.")
						wait(1000)
						sampSendChat("Р‘РµСЂРµРіРёС‚Рµ СЃРµР±СЏ Рё СЃРІРѕРёС… Р±Р»РёР·РєРёС….")
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "РќР°РґРµС‚СЊ Р±РµР№РґР¶РёРє"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РёР· РєР°СЂРјР°РЅР° Р±РµР№РґР¶РёРє")
						wait(1000)
						sampSendChat("/me РЅР°РґРµР»"..a.." Р±РµР№РґР¶РёРє")
						wait(1000)
						sampSendChat("/do РќР° Р±РµР№РґР¶РёРєРµ: "..ini.Info.tag.." | Р”РѕРєС‚РѕСЂ "..surname.." | "..ini.Info.rank.."")
						wait(1000)
						sampSendChat("/clist "..ini.Info.clist.."")
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "РџРѕРїСЂР°РІРёС‚СЊ Р±РµР№РґР¶РёРє"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/me РїРѕРїСЂР°РІРёР»"..a.." Р±РµР№РґР¶РёРє")
						wait(1000)
						sampSendChat("/do РќР° Р±РµР№РґР¶РёРєРµ: "..ini.Info.tag.." | Р”РѕРєС‚РѕСЂ "..surname.." | "..ini.Info.rank.."")
						wait(1000)
						sampSendChat("/clist "..ini.Info.clist.."")
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "Р—Р°РЅСЏС‚СЊ СЂРµРіРёСЃС‚СЂР°С‚СѓСЂСѓ"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme РіРѕРІРѕСЂРёС‚ РІ СЂР°С†РёСЋ")
						wait(0)
						sampSetChatInputText("/r "..ini.Info.tag.." | Р—Р°РЅРёРјР°СЋ СЂРµРіРёСЃС‚СЂР°С‚СѓСЂСѓ "..ini.Info.reg.."")
						sampSetChatInputEnabled(true)
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "РџРѕРєРёРЅСѓС‚СЊ СЂРµРіРёСЃС‚СЂР°С‚СѓСЂСѓ"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme РіРѕРІРѕСЂРёС‚ РІ СЂР°С†РёСЋ")
						wait(0)
						sampSetChatInputText("/r "..ini.Info.tag.." | РџРѕРєРёРґР°СЋ СЂРµРіРёСЃС‚СЂР°С‚СѓСЂСѓ "..ini.Info.reg.."")
						sampSetChatInputEnabled(true)
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "РўСЂР°РЅРєРІРёР»РёР·Р°С‚РѕСЂ (Deagle)[5+ СЂР°РЅРі]"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/do РќР° РїРѕСЏСЃРµ РґРѕРєС‚РѕСЂР° Р·Р°РєСЂРµРїР»РµРЅР° РєРѕР±СѓСЂР°.")
						wait(1000)
						sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РёР· РєРѕР±СѓСЂС‹ РїРёСЃС‚РѕР»РµС‚ СЃ С‚СЂР°РЅРєРІРёР»РёР·Р°С‚РѕСЂРѕРј MP-53M")
						wait(1000)
						sampSendChat("/do РџРёСЃС‚РѕР»РµС‚ Р·Р°СЂСЏР¶РµРЅ, РїРѕСЃС‚Р°РІР»РµРЅ РЅР° РїСЂРµРґРѕС…СЂР°РЅРёС‚РµР»СЊ.")
						wait(1000)
						sampSendChat("/do Р”СЂРѕС‚РёРєРё РѕСЃРЅР°С‰РµРЅС‹ СЃРЅРѕС‚РІРѕСЂРЅС‹Рј СЃСЂРµРґСЃС‚РІРѕРј.")
						wait(1000)
						sampSendChat("/me СЃРЅСЏР»"..a.." СЃ РїСЂРµРґРѕС…СЂР°РЅРёС‚РµР»СЏ Рё РѕС‚РІС‘Р»"..a.." Р·Р°С‚РІРѕСЂ")
					end
				end)
			end

			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "Р”РѕРєР»Р°РґС‹"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y + 20, 0xFFFFFFFF, 0xFFFFFFFF) then
				menu_doklad = not menu_doklad
				menu_binds = false
				menu_myinfo = false
			end

			if menu_doklad then
				lua_thread.create(function()
					local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
					local nickname = string.gsub(sampGetPlayerNickname(myid), '_',' ')
					local name, surname = string.match(nickname, "(.+) (.+)")
					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "РЎ СЂРµРіРёСЃС‚СЂР°С‚СѓСЂС‹"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme РґРµР»Р°РµС‚ РґРѕРєР»Р°Рґ РІ СЂР°С†РёСЋ")
						wait(1500)
						sampSetChatInputText("/r "..ini.Info.tag.." | Р РµРіРёСЃС‚СЂР°С‚СѓСЂР°: "..ini.Info.reg.." | РћСЃРјРѕС‚СЂРµРЅРѕ: "..osmot.." | РњРµРґ.РєР°СЂС‚: "..medc.." | РќР°РїР°СЂРЅРёРє: "..partners.."")
						sampSetChatInputEnabled(true)
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "РЎ РїРѕСЃС‚Р° / СЃ РїР°С‚СЂСѓР»СЏ"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme РґРµР»Р°РµС‚ РґРѕРєР»Р°Рґ РІ СЂР°С†РёСЋ")
						wait(1500)
						sampSetChatInputText("/r "..ini.Info.tag.." | "..location.." | РћСЃРјРѕС‚СЂРµРЅРѕ: "..osmot.." | Р‘Р°Рє: | РќР°РїР°СЂРЅРёРє: "..partners.."")
						sampSetChatInputEnabled(true)
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "РЎ РІРѕРµРЅРєРѕРјР°С‚Р°"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme РґРµР»Р°РµС‚ РґРѕРєР»Р°Рґ РІ СЂР°С†РёСЋ")
						wait(1500)
						sampSetChatInputText("/r "..ini.Info.tag.." | Р’РѕРµРЅРєРѕРјР°С‚:  | РћСЃРјРѕС‚СЂРµРЅРѕ: "..osmot.." | РњРµРґ.РєР°СЂС‚: "..medc.." | РќР°РїР°СЂРЅРёРє: "..partners.."")
						sampSetChatInputEnabled(true)
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "РџСЂРёРЅСЏС‚СЊ РІС‹Р·РѕРІ"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme РґРµР»Р°РµС‚ РґРѕРєР»Р°Рґ РІ СЂР°С†РёСЋ")
						wait(1500)
						sampSendChat("/r "..ini.Info.tag.." | РџСЂРёРЅСЏР»"..a.." РІС‹Р·РѕРІ ")
					end
				end)
			end

			if r.ShowClients or ini.Settings.SkinButton then
				lua_thread.create(function()
					if isKeyDown(vkeys.VK_END) then
						thisScript():reload()
					end
					X2, Y2 = getScreenResolution()
					Y2 = Y2 / 3
					X2 = X2 - renderGetFontDrawTextLength(font, " ")
					LineX, LineY = X2, Y2
					local ped = 0
					for playerid = 0, 999 do
						if sampIsPlayerConnected(playerid) then
							local result, handle = sampGetCharHandleBySampPlayerId(playerid)
							if result then
								local X3, Y3, Z3 = getCharCoordinates(handle)
								local X4, Y4, Z4 = getCharCoordinates(PLAYER_PED)
								local nick = sampGetPlayerNickname(playerid)
								local distance = getDistanceBetweenCoords3d(X3, Y3, Z3, X4, Y4, Z4)
								local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
								local _, id = sampGetPlayerIdByCharHandle(playerid)
								local nick1 = sampGetPlayerNickname(playerid).."["..playerid.."]"
								local color = string.format("%X", tonumber(sampGetPlayerColor(playerid)))
								local targetnick = string.gsub(sampGetPlayerNickname(playerid), '_',' ')
								local targetname, targetsurname = string.match(targetnick, "(.+) (.+)")
								if #color == 8 then _, color = string.match(color, "(..)(......)") end
								if distance <= 7 then

									if menu_1[playerid] == nil then
										menu_1[playerid] = false
									end
									if menu_2[playerid] == nil then
										menu_2[playerid] = false
									end
									if menu_1o[playerid] == nil then
										menu_1o[playerid] = false
									end
									if menu_1no[playerid] == nil then
										menu_1no[playerid] = false
									end
									if menu_heal[playerid] == nil then
										menu_heal[playerid] = false
									end
									if menu_healdisease[playerid] == nil then
										menu_healdisease[playerid] = false
									end
									if menu_healwoundper[playerid] == nil then
										menu_healwoundper[playerid] = false
									end
									if menu_healwoundran[playerid] == nil then
										menu_healwoundran[playerid] = false
									end
									if menu_mc[playerid] == nil then
										menu_mc[playerid] = false
									end
									if menu_setsex[playerid] == nil then
										menu_setsex[playerid] = false
									end

									ped = ped + 1
									local string = nick1.."["..playerid.."]   "
									if ini.Settings.SkinButton then
										X3, Y3 = convert3DCoordsToScreen(X3, Y3, Z3)

										if ClickTheText(font, nick1, X3, Y3,  "0xFF"..color, "0xFF"..color) then
											lua_thread.create(function()


											end)
										end
										Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
										if ClickTheText(font, "РњРµРґ. РјРµРЅСЋ", X3, Y3, 0xffff0000, 0xFFFFFFFF) then
											menu_1[playerid] = not menu_1[playerid] -- РІРєР» РІС‹РєР» РјРµРЅСЋ
											menu_2 = {}
											menu_1o = {}
											menu_1no = {}
											menu_heal = {}
											menu_healdisease = {}
											menu_healwound = {}
											menu_mc = {}
											menu_setsex = {}
										end

										if menu_1[playerid] then
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "РћС‚С‹РіСЂР°С‚СЊ", X3 + 15, Y3, 0xfffc4e4e, 0xFFFFFFFF) then
												menu_1o[playerid] = not menu_1o[playerid] -- РІРєР» РІС‹РєР» РјРµРЅСЋ
												menu_1no = {}
												menu_heal = {}
												menu_healdisease = {}
												menu_healwound = {}
												menu_mc = {}
												menu_setsex = {}
											end

											if menu_1o[playerid] then
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Р›РµС‡РµРЅРёРµ", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_heal[playerid] = not menu_heal[playerid] -- РІРєР» РІС‹РєР» РјРµРЅСЋ
													menu_healdisease = {}
													menu_healwoundper = {}
													menu_healwoundran = {}
													menu_mc = {}
													menu_setsex = {}
												end
												if menu_heal[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Р“РѕР»РѕРІРЅР°СЏ Р±РѕР»СЊ", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/do РќР° РїРѕСЏСЃРµ РґРѕРєС‚РѕСЂР° РјРµРґ.СЃСѓРјРєР°.")
														wait(1500)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РїР»Р°СЃС‚РёРЅСѓ Р°СЃРїРёСЂРёРЅР° Рё РІС‹РґР°РІРёР»"..a.." С‚Р°Р±Р»РµС‚РєСѓ")
														wait(1500)
														sampSendChat("/me РЅР°Р»РёР»"..a.." СЃС‚Р°РєР°РЅ РІРѕРґС‹ Рё РїРµСЂРµРґР°Р»"..a.." РїР°С†РёРµРЅС‚Сѓ  РІРјРµСЃС‚Рµ СЃ С‚Р°Р±Р»РµС‚РєРѕР№")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РќР°СЃРјРѕСЂРє", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me РІРЅРёРјР°С‚РµР»СЊРЅРѕ РѕСЃРјРѕС‚СЂРµР»"..a.." СЃРѕСЃС‚РѕСЏРЅРёРµ РїР°С†РёРµРЅС‚Р°")
														wait(1500)
														sampSendChat("/do РЅР° РїРѕСЏСЃРµ РґРѕРєС‚РѕСЂР° РјРµРґ.СЃСѓРјРєР°.")
														wait(1500)
														sampSendChat("РЈ Р’Р°СЃ РЅР°СЃРјРѕСЂРє. РЇ РІС‹РїРёС€Сѓ Р’Р°Рј РєР°РїР»Рё")
														wait(1500)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РёР· РјРµРґ.СЃСѓРјРєРё РєР°РїР»Рё Р›Р°Р·РѕР»РІР°РЅ")
														wait(1500)
														sampSendChat("/me РїРµСЂРµРґР°Р»"..a.." РєР°РїР»Рё РїР°С†РёРµРЅС‚Сѓ")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РљР°С€РµР»СЊ", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/do РќР° РїРѕСЏСЃРµ РґРѕРєС‚РѕСЂР° РјРµРґ.СЃСѓРјРєР°.")
														wait(1500)
														sampSendChat("/me РѕСЃРјРѕС‚СЂРµР»"..a.." РїР°С†РёРµРЅС‚Р°")
														wait(1500)
														sampSendChat("РЈ РІР°СЃ СЃРёР»СЊРЅС‹Р№ РєР°С€РµР»СЊ. РЇ РІС‹РїРёС€Сѓ РІР°Рј Р»РµРґРµРЅС†С‹ Р”РѕРєС‚РѕСЂ РњРѕРј")
														wait(1500)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." Р»РµРґРµРЅС†С‹ РёР· РјРµРґ.СЃСѓРјРєРё")
														wait(1500)
														sampSendChat("/me РїРµСЂРµРґР°Р»"..a.." "..targetname.." "..targetsurname.." Р»РµРєР°СЂСЃС‚РІРѕ")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Р›РѕРјРєР°/РћРїСЊСЏРЅРµРЅРёРµ", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me РѕСЃРјРѕС‚СЂРµР»"..a.." РїР°С†РёРµРЅС‚Р°")
														wait(1500)
														sampSendChat("/do РќР° РїРѕСЏСЃРµ РґРѕРєС‚РѕСЂР° РјРµРґСЃСѓРјРєР°.")
														wait(1500)
														sampSendChat("/me РѕС‚РєСЂС‹Р»"..a.." СЃСѓРјРєСѓ Рё РґРѕСЃС‚Р°Р»"..a.." С€РїСЂРёС† СЃ РјРѕСЂС„РёРЅРѕРј")
														wait(1500)
														sampSendChat("/me РІРІРµР»"..a.." РїРѕР»РєСѓР±РёРєР° РјРѕСЂС„РёРЅР° РїР°С†РёРµРЅС‚Сѓ РІРЅСѓС‚СЂРёРјС‹С€РµС‡РЅРѕ")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РќРµСЃРІР°СЂРµРЅРёРµ", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РёР· СЃСѓРјРєРё РїР°РєРµС‚РёРє СЃ РїРѕР»РёСЃРѕСЂР±РѕРј")
														wait(1500)
														sampSendChat("/me РЅР°Р»РёР»"..a.." РІРѕРґСѓ РёР· Р±СѓС‚С‹Р»РєРё РІ СЃС‚Р°РєР°РЅ")
														wait(1500)
														sampSendChat("/todo Р’С‹РїРµР№С‚Рµ СЌС‚Рѕ *РїРµСЂРµРґР°РІ СЃС‚Р°РєР°РЅС‡РёРє СЃ СЂР°Р·РІРµРґРµРЅРЅС‹Рј РІ РІРѕРґРµ Р»РµРєР°СЂСЃС‚РІРѕРј")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Р‘РѕР»Рё РІ Р¶РёРІРѕС‚Рµ", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("РЇ РІС‹РїРёС€Сѓ РІР°Рј С‚Р°Р±Р»РµС‚РєРё Р РµРЅРЅРё")
														wait(1500)
														sampSendChat("/do РќР° РїРѕСЏСЃРµ РґРѕРєС‚РѕСЂР° РјРµРґ.СЃСѓРјРєР°.")
														wait(1500)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РїР»Р°СЃС‚РёРЅРєСѓ С‚Р°Р±Р»РµС‚РѕРє Р РµРЅРЅРё РёР· РјРµРґ.СЃСѓРјРєРё")
														wait(1500)
														sampSendChat("/me РІС‹РїРёСЃР°Р»"..a.." РёРЅСЃС‚СЂСѓРєС†РёСЋ РїРѕ РїСЂРёРјРµРЅРµРЅРёСЋ")
														wait(1500)
														sampSendChat("/me РїРµСЂРµРґР°Р»"..a.." РёРЅСЃС‚СЂСѓРєС†РёСЋ Рё РїР»Р°СЃС‚РёРЅРєСѓ РїР°С†РёРµРЅС‚Сѓ")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Р“РµРјРѕСЂСЂРѕР№", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("Р’С‹РїРёС€Сѓ РІР°Рј СЃРІРµС‡Рё Р РµР»РёС„ Рё РЅР°Р·РЅР°С‡Сѓ РєСѓСЂСЃ Р»РµС‡РµРЅРёСЏ")
														wait(1500)
														sampSendChat("/do РќР° РїРѕСЏСЃРµ РґРѕРєС‚РѕСЂР° РјРµРґ.СЃСѓРјРєР°.")
														wait(1500)
														sampSendChat("/me РІС‹РЅСѓР»"..a.." СѓРїР°РєРѕРІРєСѓ СЂРµРєС‚Р°Р»СЊРЅС‹С… СЃРІРµС‡РµР№")
														wait(1500)
														sampSendChat("/me РїРµСЂРµРґР°Р»"..a.." РїР°С†РёРµРЅС‚Сѓ СЃРІРµС‡Рё")
														wait(1500)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РёР· РєР°СЂРјР°РЅР° Р±Р»Р°РЅРє Рё СЂСѓС‡РєСѓ")
														wait(1500)
														sampSendChat("/me РІС‹РїРёСЃР°Р»"..a.." СЂРµС†РµРїС‚")
														wait(1500)
														sampSendChat("/me РїРµСЂРµРґР°Р»"..a.." РїР°С†РёРµРЅС‚Сѓ СЂРµС†РµРїС‚")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
												end


												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Р‘РѕР»РµР·РЅРё Рё Р—Р°РІРёСЃРёРјРѕСЃС‚Рё", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_healdisease[playerid] = not menu_healdisease[playerid] -- РІРєР» РІС‹РєР» РјРµРЅСЋ
													menu_heal = {}
													menu_healwoundper = {}
													menu_healwoundran = {}
													menu_mc = {}
													menu_setsex = {}
												end
												if menu_healdisease[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РќР°СЂРєРѕР·Р°РІРёСЃРёРјРѕСЃС‚СЊ", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/todo CРѕР¶РјРёС‚Рµ СЂСѓРєСѓ РІ РєСѓР»Р°Рє *Р·Р°С‚СЏРіРёРІР°СЏ Р¶РіСѓС‚")
														wait(1500)
														sampSendChat("/me РЅР°С‰СѓРїР°Р»"..a.." РІРµРЅСѓ Р»РѕРєС‚РµРІРѕРіРѕ СЃРіРёР±Р°")
														wait(1500)
														sampSendChat("/me РЅР°Р±СЂР°Р»"..a.." РІРµС‰РµСЃС‚РІРѕ РёР· Р°РјРїСѓР»С‹ РІ С€РїСЂРёС†")
														wait(1500)
														sampSendChat("/me РІРІРµР»"..a.." Р»РµРєР°СЂСЃС‚РІРѕ РІРЅСѓС‚СЂРёРІРµРЅРЅРѕ Рё СЃРЅСЏР»"..a.." Р¶РіСѓС‚")
														wait(1500)
														sampSendChat("/me РІС‹РІРµР»"..a.." РёРіР»Сѓ РёР· РІРµРЅС‹ Рё РїРѕРґСЃС‚Р°РІРёР»"..a.." СЃРїРёСЂС‚РѕРІСѓСЋ РІР°С‚РєСѓ")
														wait(1000)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Р“СЂРёРїРї", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("РЎРµР№С‡Р°СЃ СЏ СЃРґРµР»Р°СЋ Р’Р°Рј СѓРєРѕР»СЊС‡РёРє Р±РёРѕРєСЃРѕРЅР°.")
														wait(1500)
														sampSendChat("Рђ С‚Р°РєР¶Рµ РІС‹РїРёС€Сѓ Р’Р°Рј РљР°РіРѕС†РµР»")
														wait(1500)
														sampSendChat("РќРµРѕР±С…РѕРґРёРјРѕ РЅР°Р±Р»СЋРґРµРЅРёРµ РІСЂР°С‡Р° РЅРµ С‡Р°С‰Рµ СЂР°Р·Р° РІ С‡Р°СЃ")
														wait(1500)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." Р°РјРїСѓР»Сѓ Р‘РёРѕРєСЃРѕРЅР°")
														wait(1500)
														sampSendChat("/me РЅР°Р±СЂР°Р»"..a.." Р±РёРѕРєСЃРѕРЅ РІ С€РїСЂРёС†")
														wait(1500)
														sampSendChat("/todo Р Р°СЃСЃР»Р°Р±СЊС‚РµСЃСЊ *РїСЂРѕС‚РёСЂР°СЏ РІР°С‚РєРѕР№ РјРµСЃС‚Рѕ СѓРєРѕР»Р°")
														wait(1500)
														sampSendChat("/me РІРІРµР»"..a.." СЂР°СЃС‚РІРѕСЂ Р±РёРѕРєСЃРѕРЅР° РїР°С†РёРµРЅС‚Сѓ")
														wait(1500)
														sampSendChat("/todo РњРѕР¶РµС‚Рµ СЃРѕР±РёСЂР°С‚СЊСЃСЏ *Р·Р°РїРѕР»РЅСЏСЏ СЂРµС†РµРїС‚, РїРµСЂРµРґР°Р»"..a.." СЂРµС†РµРїС‚ РїР°С†РёРµРЅС‚Сѓ")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Р‘СЂРѕРЅС…РёС‚", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/do Р’ СЂСѓРєР°С… РІСЂР°С‡Р° СЃС‚РµС‚РѕСЃРєРѕРї.")
														wait(1500)
														sampSendChat("РћРіРѕР»РёС‚Рµ С‚РѕСЂСЃ Рё РїРѕРґРѕР№РґРёС‚Рµ Р±Р»РёР¶Рµ")
														wait(1500)
														sampSendChat("/me РїРѕСЃР»СѓС€Р°Р»"..a.." Р»РµРіРєРёРµ РїР°С†РёРµРЅС‚Р°")
														wait(1500)
														sampSendChat("/todo Р�РјРµСЋС‚СЃСЏ С…СЂРёРїС‹ РІ Р»РµРіРєРёС… *СѓР±РёСЂР°СЏ СЃС‚РµС‚РѕСЃРєРѕРї")
														wait(1500)
														sampSendChat("/me РІС‹РїРёСЃР°Р»"..a.." СЂРµС†РµРїС‚ РЅР° РђРјР±СЂРѕРіРµРєСЃР°Р» Рё РѕР±РёР»СЊРЅРѕРµ С‚РµРїР»РѕРµ РїРёС‚СЊС‘")
														wait(1500)
														sampSendChat("/me РїРµСЂРµРґР°Р»"..a.." РїР°С†РёРµРЅС‚Сѓ СЂРµС†РµРїС‚ Рё РјРµРґРєР°СЂС‚Сѓ")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РћС‚СЂР°РІР»РµРЅРёРµ", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РёР· РјРµРґСЃСѓРјРєРё СѓРїР°РєРѕРІРєСѓ Р°РєС‚РёРІРёСЂРѕРІР°РЅРЅРѕРіРѕ СѓРіР»СЏ")
														wait(1500)
														sampSendChat("/me РІС‹РґР°РІРёР»"..a.." РЅРµСЃРєРѕР»СЊРєРѕ С‚Р°Р±Р»РµС‚РѕРє Р°РєС‚РёРІ. СѓРіР»СЏ")
														wait(1500)
														sampSendChat("/me РїРµСЂРµРґР°Р»"..a.." РїР°С†РёРµРЅС‚Сѓ")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РњРёРєРѕР·", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me РѕСЃРјРѕС‚СЂРµР»"..a.." РєРѕР¶Сѓ РїР°С†РёРµРЅС‚Р° Рё РѕР±РЅР°СЂСѓР¶РёР» РіСЂРёР±РєРѕРІС‹Рµ СЃРїРѕСЂС‹")
														wait(1500)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РёР· СЃСѓРјРєРё РјР°Р·СЊ Р»Р°РјРёР·РёР»")
														wait(1500)
														sampSendChat("/me РЅР°РјР°Р·Р°Р»"..a.." РїРѕСЂР°Р¶РµРЅРЅС‹Р№ РіСЂРёР±РєРѕРј СѓС‡Р°СЃС‚РѕРє РєРѕР¶Рё РјР°Р·СЊСЋ")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РљР»РµС‰РµРІРѕР№ СЌРЅС†РµС„Р°Р»РёС‚", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РёР· СЃСѓРјРєРё С€РїСЂРёС† Рё Р°РјРїСѓР»Сѓ РёРјСѓРЅРѕРіР»РѕР±СѓР»РёРЅР°")
														wait(1500)
														sampSendChat("/me РЅР°Р±СЂР°Р»"..a.." РІРµС‰РµСЃС‚РІРѕ РёР· Р°РјРїСѓР»С‹ РІ С€РїСЂРёС†")
														wait(1500)
														sampSendChat("/me РІРІРµР»"..a.." РїСЂРµРїР°СЂР°С‚ РІРЅСѓС‚СЂРёРјС‹С€РµС‡РЅРѕ")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РђР»РєРѕРіРѕР»РёР·Рј", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me РѕСЃРјРѕС‚СЂРµР»"..a.." РѕР±С‰РµРµ СЃРѕСЃС‚РѕСЏРЅРёРµ РїР°С†РёРµРЅС‚Р°")
														wait(1500)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." СЂСѓС‡РєСѓ Рё РЅР°РїРёСЃР°Р»"..a.." Р»РёСЃС‚ РЅР°Р·РЅР°С‡РµРЅРёР№")
														wait(1500)
														sampSendChat("/do Р’ СЂСѓРєР°С… РґРѕРєС‚РѕСЂР° РєРѕСЂРѕР±РѕС‡РєР° РїСЂРµРїР°СЂР°С‚Р° В«РўРµС‚СѓСЂР°РјВ».")
														wait(1500)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РїР»Р°СЃС‚РёРЅРєСѓ Рё РїРµСЂРµРґР°Р»"..a.." РїР°С†РёРµРЅС‚Сѓ")
														wait(1500)
														sampSendChat("/todo РџСЂРѕРїРµР№С‚Рµ РєСѓСЂСЃ СЃРѕРіР»Р°СЃРЅРѕ Р»РёСЃС‚Сѓ РЅР°Р·РЅР°С‡РµРЅРёСЏ*РїР°СЂР°Р»Р»РµР»СЊРЅРѕ РїСЂРёРєР»Р°РґС‹РІР°СЏ Рє СѓРїР°РєРѕРІРєРµ Р»РёСЃС‚")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
												end

												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "РџРµСЂРµР»РѕРјС‹", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_healwoundper[playerid] = not menu_healwoundper[playerid]
													menu_healwoundran = {} -- РІРєР» РІС‹РєР» РјРµРЅСЋ
													menu_heal = {}
													menu_healdisease = {}
													menu_mc = {}
													menu_setsex = {}
												end
												if menu_healwoundper[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "1. РџРµСЂРµР»РѕРј[РґРёР°РіРЅРѕСЃС‚РёРєР°]", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РЅРѕРІС‹Рµ РІРёРЅРёР»РѕРІС‹Рµ РїРµСЂС‡Р°С‚РєРё Рё РЅР°РґРµР»"..a.." РёС…")
														wait(1500)
														sampSendChat("/me РїРѕРјРѕРі(Р»Р°) РїР°С†РёРµРЅС‚Сѓ Р»РµС‡СЊ РЅР° РѕРїРµСЂР°С†РёРѕРЅРЅС‹Р№ СЃС‚РѕР»")
														wait(1500)
														sampSendChat("/b Р—Р°Р»РµР·Р°Р№С‚Рµ РЅР° СЃС‚РѕР» Рё /anim 22")
														wait(1500)
														sampSendChat("/me РІРЅРёРјР°С‚РµР»СЊРЅРѕ РѕСЃРјРѕС‚СЂРµР»"..a.." РїР°С†РёРµРЅС‚Р°")
														wait(1500)
														sampSendChat("/try РѕР±РЅР°СЂСѓР¶РёР»"..a.." РѕС‚РєСЂС‹С‚С‹Р№ РїРµСЂРµР»РѕРј")
														wait(300)
														sampAddChatMessage("{00a100}РЈРґР°С‡РЅРѕ{FFFFFF} - РћРїРµСЂР°С†РёСЏ", 0xFFFFFFFF)
														sampAddChatMessage("{ff0000}РќРµСѓРґР°С‡РЅРѕ{FFFFFF} - Р РµРЅС‚РіРµРЅ", 0xFFFFFFFF)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "2. РћРїРµСЂР°С†РёСЏ{00a100}[РЈРґР°С‡РЅРѕ]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me РІРєР»СЋС‡РёР»"..a.." СЂРµРЅС‚РіРµРЅ-Р°РїРїР°СЂР°С‚")
														wait(1500)
														sampSendChat("/me СЃРґРµР»Р°Р»"..a.." СЃРЅРёРјРѕРє РїРѕРІСЂРµР¶РґРµРЅРЅРѕР№ РєРѕРЅРµС‡РЅРѕСЃС‚Рё")
														wait(1500)
														sampSendChat("/do РЎРїСѓСЃС‚СЏ РІСЂРµРјСЏ СЃРЅРёРјРѕРє РІС‹РІРµРґРµРЅ РЅР° СЌРєСЂР°РЅ.")
														wait(1500)
														sampSendChat("/me РІРЅРёРјР°С‚РµР»СЊРЅРѕ РёР·СѓС‡РёР»"..a.." СЃРЅРёРјРѕРє")
														wait(1500)
														sampSendChat("/me РЅР°РґРµР»"..a.." РЅР° РїР°С†РёРµРЅС‚Р° РёРЅРіР°Р»СЏС†РёРѕРЅРЅСѓСЋ РјР°СЃРєСѓ")
														wait(1500)
														sampSendChat("/me РІРІС‘Р»"..a.." РїР°С†РёРµРЅС‚Р° РІ СЃРѕСЃС‚РѕСЏРЅРёРµ РѕР±С‰РµРіРѕ РЅР°СЂРєРѕР·Р°")
														wait(1500)
														sampSendChat("/me СЃРєР°Р»СЊРїРµР»РµРј СЂР°Р·СЂРµР·Р°Р»"..a.." РїР»РѕС‚СЊ РѕРєРѕР»Рѕ РїРѕРІСЂРµР¶РґРµРЅРЅРѕР№ РєРѕСЃС‚Рё")
														wait(1500)
														sampSendChat("/me РїРѕРґР¶Р°Р»"..a.." РєСЂР°СЏ РїР»РѕС‚Рё Р·Р°Р¶РёРјРѕРј")
														wait(1500)
														sampSendChat("/try РІРїСЂР°РІРёР»"..a.." РєРѕСЃС‚СЊ РїР°С†РёРµРЅС‚Сѓ")
														wait(1500)
														sampAddChatMessage("{00a100}РЈРґР°С‡РЅРѕ{FFFFFF} - Р’РїСЂР°РІРёР»", 0xFFFFFFFF)
														sampAddChatMessage("{ff0000}РќРµСѓРґР°С‡РЅРѕ{FFFFFF} - РќРµРІСЂР°РІРёР»", 0xFFFFFFFF)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "3. Р’РїСЂР°РІРёР»{00a100}[РЈРґР°С‡РЅРѕ]", X3 + 75, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me СЃРЅСЏР»"..a.." Р·Р°Р¶РёРјС‹")
														wait(1500)
														sampSendChat("/me РІР·СЏР»"..a.." Р±РёРѕРЅРёС‡РµСЃРєРёРµ РЅРёС‚Рё Рё РёРіР»Сѓ")
														wait(1500)
														sampSendChat("/me РЅР°Р»РѕР¶РёР»"..a.." С€РѕРІ РЅР° РєРѕРЅРµС‡РЅРѕСЃС‚СЊ")
														wait(1500)
														sampSendChat("/me РІС‹РјРѕС‡РёР»"..a.." РіРёРїСЃ РІ Р±РёРєСЃРµ РєРёРїСЏС‡РµРЅРЅРѕР№ РІРѕРґС‹")
														wait(1500)
														sampSendChat("/me РЅР°Р»РѕР¶РёР»"..a.." РіРёРїСЃ РЅР° РєРѕРЅРµС‡РЅРѕСЃС‚СЊ")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "3. РќРµРІРїСЂР°РІРёР»{ff0000}[РќРµСѓРґР°С‡РЅРѕ]", X3 + 75, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me РїСЂРѕС…СЂСѓСЃС‚РµР»"..a.." РїР°Р»СЊС†Р°РјРё, СЂР°Р·РјСЏРІ СЂСѓРєРё")
														wait(1500)
														sampSendChat("/me РїСЂРёР»РѕР¶РёР»"..a.." Р±РѕР»СЊС€Рµ СѓСЃРёР»РёР№ Рё СѓСЃРїРµС€РЅРѕ РІРїСЂР°РІРёР»"..a.." РєРѕСЃС‚СЊ")
														wait(1500)
														sampSendChat("/me СЃРЅСЏР»"..a.." Р·Р°Р¶РёРјС‹")
														wait(1500)
														sampSendChat("/me РІР·СЏР»"..a.." Р±РёРѕРЅРёС‡РµСЃРєРёРµ РЅРёС‚Рё Рё РёРіР»Сѓ")
														wait(1500)
														sampSendChat("/me РЅР°Р»РѕР¶РёР»"..a.." С€РѕРІ РЅР° РєРѕРЅРµС‡РЅРѕСЃС‚СЊ")
														wait(1500)
														sampSendChat("/me РІС‹РјРѕС‡РёР»"..a.." РіРёРїСЃ РІ Р±РёРєСЃРµ РєРёРїСЏС‡РµРЅРЅРѕР№ РІРѕРґС‹")
														wait(1500)
														sampSendChat("/me РЅР°Р»РѕР¶РёР»"..a.." РіРёРїСЃ РЅР° РєРѕРЅРµС‡РЅРѕСЃС‚СЊ")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "2. Р РµРЅС‚РіРµРЅ{ff0000}[РќРµСѓРґР°С‡РЅРѕ]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me РІРєР»СЋС‡РёР»"..a.." СЂРµРЅС‚РіРµРЅ Р°РїРїР°СЂР°С‚")
														wait(1500)
														sampSendChat("/me СЃРґРµР»Р°Р»"..a.." СЃРЅРёРјРѕРє РїРѕРІСЂРµР¶РґС‘РЅРЅРѕР№ РєРѕРЅРµС‡РЅРѕСЃС‚Рё")
														wait(1500)
														sampSendChat("/do РЎРїСѓСЃС‚СЏ РІСЂРµРјСЏ СЃРЅРёРјРѕРє РІС‹РІРµРґРµРЅ РЅР° СЌРєСЂР°РЅ.")
														wait(1500)
														sampSendChat("/try СѓРІРёРґРµР»"..a.." РЅР° СЃРЅРёРјРєРµ РїРµСЂРµР»РѕРј")
														wait(300)
														sampAddChatMessage("{00a100}РЈРґР°С‡РЅРѕ{FFFFFF} - Р—Р°РєСЂС‹С‚С‹Р№", 0xFFFFFFFF)
														sampAddChatMessage("{ff0000}РќРµСѓРґР°С‡РЅРѕ{FFFFFF} - РЈС€РёР±", 0xFFFFFFFF)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "3. Р—Р°РєСЂС‹С‚С‹Р№{00a100}[РЈРґР°С‡РЅРѕ]", X3 + 75, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." С€РїСЂРёС† Рё Р°РјРїСѓР»Сѓ РѕР±РµР·Р±РѕР»РёРІР°СЋС‰РµРіРѕ")
														wait(1500)
														sampSendChat("/me РЅР°Р±СЂР°Р»"..a.." РѕР±РµР·Р±РѕР»РёРІР°СЋС‰РµРµ РІ С€РїСЂРёС†")
														wait(1500)
														sampSendChat("/me РІРІРµР»"..a.." РѕР±РµР·Р±РѕР»РёРІР°СЋС‰РµРµ РїР°С†РёРµРЅС‚Сѓ")
														wait(1500)
														sampSendChat("/me РІРїСЂР°РІРёР»"..a.." РєРѕСЃС‚СЊ")
														wait(1500)
														sampSendChat("/me РЅР°Р»РѕР¶РёР»"..a.." РїРѕРІСЏР·РєСѓ СЃРѕС„С‚РєР°СЃС‚ РїР°С†РёРµРЅС‚Сѓ")
														wait(1500)
														sampSendChat("/healwound "..playerid)
														wait(1500)
														sampSendChat("/me РІС‹РґР°Р»"..a.." РїР°С†РёРµРЅС‚Сѓ РєРѕСЃС‚С‹Р»Рё")
														wait(1500)
														sampSendChat("РџРѕ РЅР°С‡Р°Р»Сѓ Р±СѓРґРµС‚ РЅРµСѓРґРѕР±РЅРѕ, РЅРѕ, СѓРІРµСЂСЏСЋ, РІС‹ СЃРїСЂР°РІРёС‚РµСЃСЊ")
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "3. РЈС€РёР±{ff0000}[РќРµСѓРґР°С‡РЅРѕ]", X3 + 75, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("Р’Р°Рј РїРѕРІРµР·Р»Рѕ, С‡С‚Рѕ РѕР±РѕС€Р»РѕСЃСЊ Р±РµР· РїРµСЂРµР»РѕРјРѕРІ")
														wait(1500)
														sampSendChat("Р’СЃРµРіРѕ Р»РёС€СЊ СѓС€РёР±")
														wait(1500)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РёР· РјРµРґСЃСѓРјРєРё С‚СЋР±РёРє РјР°Р·Рё")
														wait(1500)
														sampSendChat("/me РЅР°РЅРµСЃ"..la.." РЅР° РјРµСЃС‚Рѕ СѓС€РёР±Р° РјР°Р·СЊ Рё СЂР°СЃС‚РµСЂ"..la.." РµРµ")
														wait(1500)
														sampSendChat("/me РЅР°Р»РѕР¶РёР»"..a.." РЅР° РјРµСЃС‚Рѕ СѓС€РёР±Р° СЌР»Р°СЃС‚РёС‡РЅС‹Р№ Р±РёРЅС‚")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
												end

												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Р Р°РЅРµРЅРёСЏ", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_healwoundran[playerid] = not menu_healwoundran[playerid]
													menu_healwoundper = {} -- РІРєР» РІС‹РєР» РјРµРЅСЋ
													menu_heal = {}
													menu_healdisease = {}
													menu_mc = {}
													menu_setsex = {}
												end
												if menu_healwoundran[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Р Р°РЅС‹(СЂРµР·Р°РЅС‹Рµ, РєРѕР»РѕС‚С‹Рµ, СЂСѓР±Р»РµРЅС‹Рµ, СЂРІР°РЅС‹Рµ)", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("Р›РѕР¶РёС‚РµСЃСЊ РЅР° СЃС‚РѕР», СЃРµР№С‡Р°СЃ Р±СѓРґРµС‚Рµ РєР°Рє РЅРѕРІРµРЅСЊРєРёР№")
														wait(1500)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РёР· РјРµРґ.СЃСѓРјРєРё Р±Р°РЅРѕС‡РєСѓ Р·РµР»РµРЅРєРё")
														wait(1500)
														sampSendChat("/me РїСЂРѕРґРµР·РёРЅС„РµС†РёСЂРѕРІР°Р»"..a.." СЂР°РЅСѓ РїР°С†РёРµРЅС‚Р°")
														wait(1500)
														sampSendChat("/me РїРѕРґРіРѕС‚РѕРІРёР»"..a.." РІСЃС‘ РґР»СЏ РѕРїРµСЂР°С†РёРё")
														wait(1500)
														sampSendChat("/do Р’СЃС‘ РЅРµРѕР±С…РѕРґРёРјРѕРµ Р»РµР¶РёС‚ РЅР° СЃС‚РѕР»Рµ.")
														wait(1500)
														sampSendChat("/me РІР·СЏР»"..a.." РІ СЂСѓРєРё С…РёСЂСѓСЂРіРёС‡РµСЃРєРёРµ РЅРёС‚Рё Рё РёРіР»Сѓ")
														wait(1500)
														sampSendChat("/do Р”РѕРєС‚РѕСЂ РЅР°РєР»Р°РґС‹РІР°РµС‚ С€РІС‹ РЅР° СЂР°РЅСѓ.")
														wait(1500)
														sampSendChat("/me СѓР±СЂР°Р»"..a.." С…РёСЂСѓСЂРіРёС‡РµСЃРєРёРµ РЅРёС‚Рё Рё РёРіР»Сѓ")
														wait(1500)
														sampSendChat("/me РЅР°Р»РѕР¶РёР»"..a.." СЃС‚РµСЂРёР»СЊРЅСѓСЋ РїРѕРІСЏР·РєСѓ РЅР° РјРµСЃС‚Рѕ С€РІР°")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РћРіРЅРµСЃС‚СЂРµР»СЊРЅС‹Рµ СЂР°РЅРµРЅРёСЏ", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me РѕСЃРјРѕС‚СЂРµР»"..a.." СЂР°РЅРµРЅРёРµ РїРѕСЃС‚СЂР°РґР°РІС€РµРіРѕ")
														wait(1500)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." Р°РјРїСѓР»Сѓ РЅРѕРІРѕРєР°РёРЅР°, С€РїСЂРёС† Рё РЅР°Р±СЂР°Р»"..a.." РЅРѕРІРѕРєР°РёРЅ РІ С€РїСЂРёС†")
														wait(1500)
														sampSendChat("/me РІРІС‘Р»"..a.." РѕР±РµР·Р±РѕР»РёРІР°СЋС‰РµРµ РїР°С†РёРµРЅС‚Сѓ")
														wait(1500)
														sampSendChat("/me РІР·СЏР»"..a.." СЃРєР°Р»СЊРїРµР»СЊ Рё СЃРґРµР»Р°Р»"..a.." РЅР°РґСЂРµР· РІ РјРµСЃС‚Рµ СЂР°РЅРµРЅРёСЏ")
														wait(1500)
														sampSendChat("/me РїРѕР»РѕР¶РёР»"..a.." СЃРєР°Р»СЊРїРµР»СЊ Рё РІР·СЏР»"..a.." С‰РёРїС†С‹")
														wait(1500)
														sampSendChat("/try СѓСЃРїРµС€РЅРѕ РёР·РІР»С‘Рє"..la.." РїСѓР»СЋ")
														wait(300)
														sampAddChatMessage("{00a100}РЈРґР°С‡РЅРѕ{FFFFFF} - РћРіРЅРµСЃС‚СЂРµР»СЊРЅРѕРµ СЂР°РЅРµРЅРёРµ{00a100}[РЈРґР°С‡РЅРѕ]", 0xFFFFFFFF)
														wait(300)
														sampAddChatMessage("{ff0000}РќРµСѓРґР°С‡РЅРѕ{FFFFFF} - РћРіРЅРµСЃС‚СЂРµР»СЊРЅРѕРµ СЂР°РЅРµРЅРёРµ{ff0000}[РќРµСѓРґР°С‡РЅРѕ]", 0xFFFFFFFF)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РћРіРЅРµСЃС‚СЂРµР»{00a100}[РЈРґР°С‡РЅРѕ]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me СѓР±СЂР°Р»"..a.." РїСѓР»СЋ РІ РїРѕС‡РєРѕРѕР±СЂР°Р·РЅС‹Р№ РєРѕРЅС‚РµР№РЅРµСЂ")
														wait(1500)
														sampSendChat("/me РІР·СЏР»"..a.." РІ СЂСѓРєРё С…РёСЂСѓСЂРіРёС‡РµСЃРєСѓСЋ РёРіР»Сѓ Рё РЅРёС‚СЊ")
														wait(1500)
														sampSendChat("/do Р”РѕРєС‚РѕСЂ РЅР°РєР»Р°РґС‹РІР°РµС‚ С€РІС‹.")
														wait(1500)
														sampSendChat("/me РѕР±РѕСЂРІР°Р»"..a.." РЅРёС‚СЊ Рё СѓР±СЂР°Р»"..a.." РёРіР»Сѓ")
														wait(1500)
														sampSendChat("/me РЅР°Р»РѕР¶РёР»"..a.." РјР°СЂР»РµРІСѓСЋ РїРѕРІСЏР·РєСѓ РЅР° СЂР°РЅСѓ")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РћРіРЅРµСЃС‚СЂРµР»{ff0000}[РќРµСѓРґР°С‡РЅРѕ]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me РїРѕР»РѕР¶РёР»"..a.." С‰РёРїС†С‹ РЅР° РјРµСЃС‚Рѕ Рё РІР·СЏР»"..a.." СЃРєР°Р»СЊРїРµР»СЊ")
														wait(1500)
														sampSendChat("/me СЃРґРµР»Р°Р»"..a.." РґРѕРїРѕР»РЅРёС‚РµР»СЊРЅС‹Р№ РЅР°РґСЂРµР·")
														wait(1500)
														sampSendChat("/me СЃРЅРѕРІР° РІР·СЏР»"..a.." С‰РёРїС†С‹ Рё СѓСЃРїРµС€РЅРѕ РёР·РІР»С‘Рє(РёР·РІР»РµРєР»Р°) РїСѓР»СЋ")
														wait(1500)
														sampSendChat("/me СѓР±СЂР°Р»"..a.." РїСѓР»СЋ РІ РїРѕС‡РєРѕРѕР±СЂР°Р·РЅС‹Р№ РєРѕРЅС‚РµР№РЅРµСЂ")
														wait(1500)
														sampSendChat("/do Р”РѕРєС‚РѕСЂ РЅР°РєР»Р°РґС‹РІР°РµС‚ С€РІС‹.")
														wait(1500)
														sampSendChat("/me РѕР±СЂРµР·Р°Р»"..a.." РЅРёС‚СЊ Рё СѓР±СЂР°Р»"..a.." РёРіР»Сѓ")
														wait(1500)
														sampSendChat("/me РЅР°Р»РѕР¶РёР»"..a.." РЅР° СЂР°РЅСѓ РјР°СЂР»РµРІСѓСЋ РїРѕРІСЏР·РєСѓ")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
												end



												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "РњРµРґ.РєР°СЂС‚Р°", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_mc[playerid] = not menu_mc[playerid] -- РІРєР» РІС‹РєР» РјРµРЅСЋ
													menu_heal = {}
													menu_healdisease = {}
													menu_healwound = {}
													menu_setsex = {}
												end
												if menu_mc[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РџРѕРїСЂРѕСЃРёС‚СЊ РїР°СЃРїРѕСЂС‚", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("РџРµСЂРµРґ С‚РµРј РєР°Рє РЅР°С‡Р°С‚СЊ, РјРЅРµ РЅРµРѕР±С…РѕРґРёРјРѕ РїСЂРѕРІРµСЂРёС‚СЊ..")
														wait(1500)
														sampSendChat("..Р’Р°С€ РїР°СЃРїРѕСЂС‚. РџСЂРµРґСЉСЏРІРёС‚Рµ Р’Р°С€ РїР°СЃРїРѕСЂС‚ РІ СЂР°Р·РІРµСЂРЅСѓС‚РѕРј РІРёРґРµ")
														wait(1500)
														sampSendChat("/b /showpass "..myid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Р’С‹РґР°С‚СЊ РјРµРґ.РєР°СЂС‚Сѓ", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("РЎРµР№С‡Р°СЃ РјС‹ Р·Р°РІРµРґРµРј РјРµРґ. РєР°СЂС‚Сѓ РЅР° Р’Р°С€Рµ РёРјСЏ")
														wait(1500)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." Р±Р»Р°РЅРє РјРµРґРёС†РёРЅСЃРєРѕР№ РєР°СЂС‚С‹")
														wait(1500)
														sampSendChat("/me РІРЅРµСЃ(Р»Р°) РґР°РЅРЅС‹Рµ РїР°С†РёРµРЅС‚Р°")
														wait(1500)
														sampSendChat("/givemc "..playerid)
														wait(1500)
														sampSendChat("/me РїРµСЂРµРґР°Р»"..a.." РєР°СЂС‚Сѓ "..targetname.." "..targetsurname)
														wait(1500)
														sampSendChat("/b /showmc ID - РїРѕРєР°Р·Р°С‚СЊ РјРµРґ.РєР°СЂС‚Сѓ")
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РќР°Р№С‚Рё РјРµРґ.РєР°СЂС‚Сѓ", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("РњРёРЅСѓС‚Сѓ. РЎРµР№С‡Р°СЃ СЏ РѕР·РЅР°РєРѕРјР»СЋСЃСЊ СЃ Р’Р°С€РµР№ РјРµРґРєР°СЂС‚РѕР№")
														wait(1500)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РїР»Р°РЅС€РµС‚РЅС‹Р№ РєРѕРјРїСЊСЋС‚РµСЂ")
														wait(1500)
														sampSendChat("/me РЅР°С‡Р°Р»"..a.." РїРѕРёСЃРє РјРµРґРєР°СЂС‚С‹ РЅР° РёРјСЏ "..targetname.." "..targetsurname)
														wait(1500)
														sampSendChat("/findmc "..nick)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Р�РЅС„Рѕ Рѕ РѕС‚РјРµС‚РєРµ РіРѕРґРЅРѕСЃС‚Рё", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("Р•СЃР»Рё Р’С‹ С…РѕС‚РёС‚Рµ РїРѕР»СѓС‡РёС‚СЊ РІ РјРµРґ. РєР°СЂС‚Сѓ РїРµС‡Р°С‚СЊ...")
														wait(1500)
														sampSendChat("..Рѕ РіРѕРґРЅРѕСЃС‚Рё Рє РІРѕРёРЅСЃРєРѕР№ СЃР»СѓР¶Р±Рµ...")
														wait(1500)
														sampSendChat("...РЅРµРѕР±С…РѕРґРёРјРѕ РїСЂРѕР№С‚Рё РґРѕРїРѕР»РЅРёС‚РµР»СЊРЅСѓСЋ РјРµРґ.РєРѕРјРёСЃСЃРёСЋ")
														wait(1500)
														sampSendChat("РЎС‚РѕРёРјРѕСЃС‚СЊ С‚РµСЃС‚Р° - 5000 РІРёСЂС‚. РџСЂРѕРёР·РІРѕРґРёС‚СЃСЏ РЅР°Р»РёС‡РЅС‹РјРё РІСЂР°С‡Сѓ")
														wait(1500)
														sampSendChat("/b /pay "..myid.." 5000")
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РўРµСЃС‚ РґР»СЏ РѕС‚РјРµС‚РєРё РіРѕРґРЅРѕСЃС‚Рё", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." СЌРєСЃРїСЂРµСЃСЃ-С‚РµСЃС‚")
														wait(1500)
														sampSendChat("/do Р”РѕРєС‚РѕСЂ РІР·СЏР»(a) Р°РЅР°Р»РёР· РєСЂРѕРІРё РїР°С†РёРµРЅС‚Р°.")
														wait(1500)
														sampSendChat("/me РїСЂРѕРІРµР»"..a.." СЌРєСЃРїСЂРµСЃСЃ-С‚РµСЃС‚ РЅР° Р±РѕР»РµР·РЅРё")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
														wait(300)
														sampAddChatMessage("{ff0000}РќРµ РіРѕРґРµРЅ {ffffff}РµСЃР»Рё:", 0xFFFFFFFF)
														sampAddChatMessage("{ffffff}РќР°СЂРєРѕР·Р°РІРёСЃРёРјРѕСЃС‚СЊ, Р°Р»РєРѕРіРѕР»РёР·Рј - 1 СЃС‚Р°РґРёСЏ Рё РІС‹С€Рµ", 0xFFFFFFFF)
														sampAddChatMessage("{ffffff}Р“СЂРёРїРї, Р±СЂРѕРЅС…РёС‚, РјРёРєРѕР·, СЌРЅС†РµС„Р°Р»РёС‚ - 3 СЃС‚Р°РґРёСЏ Рё РІС‹С€Рµ", 0xFFFFFFFF)
														sampAddChatMessage("{ffffff}РћС‚СЂР°РІР»РµРЅРёРµ - 3 СЃС‚Р°РґРёСЏ Рё РІС‹С€Рµ", 0xFFFFFFFF)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РћС‚РјРµС‚РєР°{00a100}[Р“РћР”Р•Рќ]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/do Р­РєСЃРїСЂРµСЃСЃ-С‚РµСЃС‚: Р РµР·СѓР»СЊС‚Р°С‚: РѕС‚СЂРёС†Р°С‚РµР»СЊРЅС‹Р№ | Р“РѕРґРµРЅ РґР»СЏ СЃР»СѓР¶Р±С‹.")
														wait(1500)
														sampSendChat("РџРѕР·РґСЂР°РІР»СЏСЋ, РІС‹ РіРѕРґРЅС‹ Рє РІРѕРёРЅСЃРєРѕР№ СЃР»СѓР¶Р±Рµ")
														wait(1500)
														sampSendChat("/me РІРЅРµСЃ"..la.." РґР°РЅРЅС‹Рµ РІ РјРµРґРєР°СЂС‚Сѓ")
														wait(1500)
														sampSendChat("/me РїРµСЂРµРґР°Р»"..a.." РјРµРґРєР°СЂС‚Сѓ "..targetname.." "..targetsurname)
														wait(1500)
														sampSendChat("/updatemc "..playerid.." 1")
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РћС‚РјРµС‚РєР°{ff0000}[РќР• Р“РћР”Р•Рќ]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/do Р­РєСЃРїСЂРµСЃСЃ-С‚РµСЃС‚: Р РµР·СѓР»СЊС‚Р°С‚: РїРѕР»РѕР¶РёС‚РµР»СЊРЅС‹Р№ | РќРµ РіРѕРґРµРЅ РґР»СЏ СЃР»СѓР¶Р±С‹.")
														wait(1500)
														sampSendChat("РЈ Р’Р°СЃ РїРѕР»РѕР¶РёС‚РµР»СЊРЅС‹Р№ СЂРµР·СѓР»СЊС‚Р°С‚. Р’Р°Рј РЅРµРѕР±С…РѕРґРёРјРѕ РїСЂРѕР№С‚Рё Р»РµС‡РµРЅРёРµ")
														wait(1500)
														sampSendChat("/me РІРЅРµСЃ"..la.." РґР°РЅРЅС‹Рµ РІ РјРµРґРєР°СЂС‚Сѓ")
														wait(1500)
														sampSendChat("/me РїРµСЂРµРґР°Р»"..a.." РјРµРґРєР°СЂС‚Сѓ "..targetname.." "..targetsurname)
														wait(1500)
														sampSendChat("/updatemc "..playerid.." 0")
													end
												end

												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "РЎС‚СЂР°С…РѕРІР°РЅРёРµ РїР°С†РёРµРЅС‚Р°", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													wait(250)
													sampSetCursorMode(0)
													sampSendChat("РЎРµР№С‡Р°СЃ СЏ РІРЅРµСЃСѓ Р’Р°С€Рё РґР°РЅРЅС‹Рµ РІ СЃС‚СЂР°С…РѕРІРѕР№ РїРѕР»РёСЃ")
													wait(1500)
													sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." СЌР»РµРєС‚СЂРѕРЅРЅС‹Р№ РїР»Р°РЅС€РµС‚ РёР· РєР°СЂРјР°РЅР°")
													wait(1500)
													sampSendChat("/me РІРѕС€РµР»"..a.." РІ СЃРёСЃС‚РµРјСѓ Р±Р°Р·С‹ РґР°РЅРЅС‹С… РјРёРЅРёСЃС‚РµСЂСЃС‚РІР° Р·РґСЂР°РІРѕРѕС…СЂР°РЅРµРЅРёСЏ")
													wait(1500)
													sampSendChat("/me РІРїРёСЃР°Р»"..a.." РґР°РЅРЅС‹Рµ РїР°С†РёРµРЅС‚Р° РІ СЌР»РµРєС‚СЂРѕРЅРЅС‹Р№ СЃС‚СЂР°С…РѕРІРѕР№ РїРѕР»РёСЃ")
													wait(1500)
													sampSendChat("/do РћС„РѕСЂРјР»РµРЅР° Р·Р°СЏРІРєР° РЅР° РёРјСЏ "..targetname.." "..targetsurname)
													wait(1500)
													sampSendChat("/do РЈ СЃС‚РѕР»Р° СЃС‚РѕРёС‚ РєРѕРјРїР°РєС‚РЅС‹Р№ С‚РµСЂРјРёРЅР°Р».")
													wait(1500)
													sampSendChat("РџСЂРѕРёР·РІРµРґРёС‚Рµ РѕРїР»Р°С‚Сѓ РїСѓС‚РµРј РїСЂРёР»РѕР¶РµРЅРёСЏ Р’Р°С€РµР№ РєР°СЂС‚РѕС‡РєРё")
													wait(1500)
													sampSendChat("/healwound "..playerid)
												end

												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "РЎРјРµРЅР° РїРѕР»Р°", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_setsex[playerid] = not menu_setsex[playerid] -- РІРєР» РІС‹РєР» РјРµРЅСЋ
													menu_heal = {}
													menu_healdisease = {}
													menu_mc = {}
													menu_healwound = {}
												end
												if menu_setsex[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РќР° РјСѓР¶СЃРєРѕР№", X3 + 45, Y3, 0xFF0048ff, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me РїСЂРёРіРѕС‚РѕРІРёР»"..a.." СЃС‚РµСЂРёР»СЊРЅС‹Рµ РёРЅСЃС‚СЂСѓРјРµРЅС‚С‹")
														wait(1500)
														sampSendChat("/me РїСЂРёРіРѕС‚РѕРІРёР»"..a.." РЅР°СЂРєРѕР·")
														wait(1500)
														sampSendChat("/me РѕС‚С‹СЃРєР°Р»"..a.." РЅР° СЂСѓРєРµ РїР°С†РёРµРЅС‚Р° РїРµСЂРёС„РµСЂРёС‡РµСЃРєСѓСЋ РІРµРЅСѓ")
														wait(1500)
														sampSendChat("/me РІРІРµР»"..a.." РєР°С‚РµС‚РµСЂ Рё РїРѕСЃС‚Р°РІРёР»"..a.." РєР»РёРїСЃСѓ РЅР° РїР°Р»РµС†")
														wait(1500)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РёРЅРіР°Р»СЏС†РёРѕРЅРЅСѓСЋ РјР°СЃРєСѓ")
														wait(1500)
														sampSendChat("/me РЅР°РґРµР»"..a.." РјР°СЃРєСѓ РЅР° Р»РёС†Рѕ РїР°С†РёРµРЅС‚Р°")
														wait(1500)
														sampSendChat("/do РџР°С†РёРµРЅС‚ РЅР°С…РѕРґРёС‚СЃСЏ РїРѕРґ РЅР°СЂРєРѕР·РѕРј.")
														wait(1500)
														sampSendChat("/me СѓРґР°Р»РёР»"..a.." СЏРёС‡РЅРёРєРё Рё С„Р°Р»Р»РѕРїРёРµРІС‹ С‚СЂСѓР±С‹")
														wait(1500)
														sampSendChat("/me СЃРЅСЏР»"..a.." РјР°СЃРєСѓ СЃ Р»РёС†Р° РїР°С†РёРµРЅС‚Р°")
														wait(1500)
														sampSendChat("/me РѕС‚РєР»СЋС‡РёР»"..a.." РїРѕРґР°С‡Сѓ РЅР°СЂРєРѕР·Р°")
														wait(1500)
														sampSendChat("/do РћРїРµСЂР°С†РёСЏ РѕРІР°СЂРёСЌРєС‚РѕРјРёСЏ РїСЂРѕС€Р»Р° СѓСЃРїРµС€РЅРѕ.")
														wait(1500)
														sampSendChat("/setsex "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "РќР° Р¶РµРЅСЃРєРёР№", X3 + 45, Y3, 0xFFff477e, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me РїСЂРёРіРѕС‚РѕРІРёР»"..a.." СЃС‚РµСЂРёР»СЊРЅС‹Рµ РёРЅСЃС‚СЂСѓРјРµРЅС‚С‹")
														wait(1500)
														sampSendChat("/me РїСЂРёРіРѕС‚РѕРІРёР»"..a.." РЅР°СЂРєРѕР·")
														wait(1500)
														sampSendChat("/me РЅР°С€РµР»"..a.." РЅР° СЂСѓРєРµ РїР°С†РёРµРЅС‚Р° РїРµСЂРёС„РµСЂРёС‡РµСЃРєСѓСЋ РІРµРЅСѓ")
														wait(1500)
														sampSendChat("/me РІРІРµР»"..a.." РєР°С‚РµС‚РµСЂ Рё РїРѕСЃС‚Р°РІРёР»"..a.." РєР»РёРїСЃСѓ РЅР° РїР°Р»РµС†")
														wait(1500)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РёРЅРіР°Р»СЏС†РёРѕРЅРЅСѓСЋ РјР°СЃРєСѓ")
														wait(1500)
														sampSendChat("/me РЅР°РґРµР»"..a.." РјР°СЃРєСѓ РЅР° Р»РёС†Рѕ РїР°С†РёРµРЅС‚Р°")
														wait(1500)
														sampSendChat("/do РџР°С†РёРµРЅС‚ РЅР°С…РѕРґРёС‚СЃСЏ РїРѕРґ РЅР°СЂРєРѕР·РѕРј.")
														wait(1500)
														sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РёРЅСЃС‚СЂСѓРјРµРЅС‚С‹")
														wait(1500)
														sampSendChat("/me СЂР°Р·СЂРµР·Р°Р»"..a.." Рё СѓРґР°Р»РёР»"..a.." РјСѓР¶СЃРєРёРµ РїРѕР»РѕРІС‹Рµ РѕРіСЂР°РЅС‹")
														wait(1500)
														sampSendChat("/me СЃС„РѕСЂРјРёСЂРѕРІР°Р»"..a.." Р¶РµРЅСЃРєРёРµ РїРѕР»РѕРІС‹Рµ РѕСЂРіР°РЅС‹")
														wait(1500)
														sampSendChat("/me СЃРЅСЏР»"..a.." РјР°СЃРєСѓ СЃ Р»РёС†Р° РїР°С†РёРµРЅС‚Р°")
														wait(1500)
														sampSendChat("/me РѕС‚РєР»СЋС‡РёР»"..a.." РїРѕРґР°С‡Сѓ РЅР°СЂРєРѕР·Р°")
														wait(1500)
														sampSendChat("/do РћРїРµСЂР°С†РёСЏ РїСЂРѕС€Р»Р° СѓСЃРїРµС€РЅРѕ.")
														wait(1500)
														sampSendChat("/setsex "..playerid)
													end
												end

											end

											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "РќРµ РѕС‚С‹РіСЂС‹РІР°С‚СЊ", X3 + 15, Y3, 0xFFfc4e4e, 0xFFFFFFFF) then
												menu_1no[playerid] = not menu_1no[playerid] -- РІРєР» РІС‹РєР» РјРµРЅСЋ
												menu_1o = {}
											end

											if menu_1no[playerid] then
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Р›РµС‡РµРЅРёРµ", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/heal "..playerid)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Р‘РѕР»РµР·РЅРё Рё Р—Р°РІРёСЃРёРјРѕСЃС‚Рё", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/healdisease "..playerid)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "РЎС‚СЂР°С…РѕРІРєР° Рё Р—Р°С‰РёС‚Р°", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/healwound "..playerid)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Р’С‹РґР°С‚СЊ РјРµРґ.РєР°СЂС‚Сѓ", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/givemc "..playerid)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "РќР°Р№С‚Рё РјРµРґ.РєР°СЂС‚Сѓ", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/findmc "..nick)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Р“РѕРґРµРЅ", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/updatemc "..playerid.." 1")
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "РќРµ РіРѕРґРµРЅ", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/updatemc "..playerid.." 0")
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "РЎРјРµРЅРёС‚СЊ РїРѕР»", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/setsex "..playerid)
												end
											end
										end

										Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
										if ClickTheText(font, "Р”Р»СЏ СЂСѓРє-РІР° (7+)", X3, Y3, 0xFF5e5e5e, 0xFF4a4a4a) then
											menu_2[playerid] = not menu_2[playerid] -- РІРєР» РІС‹РєР» РјРµРЅСЋ
											menu_1 = {}
											menu_1o = {}
											menu_1no = {}
										end

										if menu_2[playerid] then
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "РћРЅР»Р°Р№РЅ", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/tr "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(10)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "Р§РµРєРЅСѓС‚СЊ РІС‹РіРѕРІРѕСЂС‹", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/rep "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "Р’С‹РґР°С‚СЊ РІС‹РіРѕРІРѕСЂ", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/rep add "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "РЈР±СЂР°С‚СЊ РІС‹РіРѕРІРѕСЂ", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/rep del "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "Р§РµРєРЅСѓС‚СЊ Р§РЎ", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/bl "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "Р”РѕР±Р°РІРёС‚СЊ РІ Р§РЎ", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/bl add "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "РЈР±СЂР°С‚СЊ РёР· Р§РЎ", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/bl del "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "Р›РѕРіРё", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/log "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
										end

										Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
										if ClickTheText(font, "Fast heal[RP]", X3, Y3, 0xffff0000, 0xFFFFFFFF) then
											wait(250)
											sampSetCursorMode(0)
											sampSendChat("/do РќР° РїРѕСЏСЃРµ РґРѕРєС‚РѕСЂР° РјРµРґ.СЃСѓРјРєР°.")
											wait(1000)
											sampSendChat("/me РґРѕСЃС‚Р°Р»"..a.." РїР»Р°СЃС‚РёРЅСѓ Р°СЃРїРёСЂРёРЅР° Рё РјР°Р»РµРЅСЊРєСѓСЋ Р±СѓС‚С‹Р»РєСѓ РІРѕРґС‹")
											wait(1000)
											sampSendChat("/me РІС‹РґР°РІРёР»"..a.." РёР· РїР»Р°СЃС‚РёРЅС‹ С‚Р°Р±Р»РµС‚РєСѓ")
											wait(1000)
											sampSendChat("/me РїРµСЂРµРґР°Р»"..a.." Р±СѓС‚С‹Р»РєСѓ РІРѕРґС‹ РІРјРµСЃС‚Рµ СЃ С‚Р°Р±Р»РµС‚РєРѕР№")
											wait(1000)
											sampSendChat("/heal "..playerid)
										end

									end
									Y2 = ((Y2 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
								end
							end
						end
					end
				end)
			end
		else
			if r.mouse then
				r.mouse = false
				r.ShowClients = false
				sampSetCursorMode(0)
			end
		end
	end
end

sex = "{0328fc}РњСѓР¶СЃРєРѕР№"
a = ""
la = ""
if ini.Settings.sex == true then
	sex = "{0328fc}РњСѓР¶СЃРєРѕР№"
elseif ini.Settings.sex == false then
	sex = "{ff459c}Р–РµРЅСЃРєРёР№"
	a = "Р°"
	la = "Р»a"
end

function zp()
	if check_skin_local_player() then
		paycheck()
		local render_text = string.format("Р—Р°СЂРїР»Р°С‚Р°:{008a00} %s", paycheck_money)
		if ClickTheText(font, render_text, ini.Settings.hud_x, ini.Settings.hud_y, 0xFFFFFFFF, 0xFFFFFFFF) then
		end
	end
end

function render_hud()
	if (isKeyDown(ini.Settings.Key) and check_skin_local_player()) then
		local render_text = string.format("[РЎРњР•РќР�РўР¬ РџРћР—Р�Р¦Р�Р®]", -1)
		set_pos_medic_hud()
		if ClickTheText(fontPosButton, render_text, ini.Settings.hud_x, ini.Settings.hud_y + 120, 0xFF969696, 0xFFFFFFFF) then
			medic_hud_pos = true
			wait(100)
		end
	end
end

function render_chat()
		local y = ini.Settings.ChatPosY	
		local ty = ini.Settings.ChatPosY
		if check_skin_local_player() then
			set_pos_medic_chat()
			for o = #timestamparr-10, #timestamparr do
				if isKeyDown(ini.Settings.Key) then
					ty = ty + renderGetFontDrawHeight(font)
					renderFontDrawText(chatfont, timestamparr[o], (ini.Settings.ChatPosX - renderGetFontDrawTextLength(chatfont, timestamparr[o])), ty, 0xFF8D8DFF)
				end
			end
			for i = #chat-10, #chat do
				y = y + renderGetFontDrawHeight(font)
				renderFontDrawText(chatfont, chat[i], ini.Settings.ChatPosX, y, 0xFF8D8DFF)
			end
			
		end
		if (isKeyDown(ini.Settings.Key) and check_skin_local_player()) then
			local chatpostext = string.format("[РЎРњР•РќР�РўР¬ РџРћР—Р�Р¦Р�Р®]", -1)
			y = y + renderGetFontDrawHeight(font)
			if ClickTheText(fontPosButton, chatpostext, ini.Settings.ChatPosX, y, 0xFF969696, 0xFFFFFFFF) then
				medic_chat_pos = true
				wait(100)
			end
			local chatpostext = string.format("Р Р°Р·РјРµСЂ: "..ini.Settings.ChatFontSize, -1)
			ClickTheText(fontPosButton, chatpostext, ini.Settings.ChatPosX + 160, y, 0xFF969696)

			local chatpostext = string.format("+", -1)
			if ClickTheText(fontPosButton, chatpostext, ini.Settings.ChatPosX + 240, y, 0xFF969696, 0xFFFFFFFF) then
				ini.Settings.ChatFontSize = ini.Settings.ChatFontSize + 1
				inicfg.save(ini, "Medic")
				thisScript():reload()
			end
			local chatpostext = string.format("-", -1)
			if ClickTheText(fontPosButton, chatpostext, ini.Settings.ChatPosX + 260, y, 0xFF969696, 0xFFFFFFFF) then
				ini.Settings.ChatFontSize = ini.Settings.ChatFontSize - 1
				inicfg.save(ini, "Medic")
				thisScript():reload()
			end
			rtext = "/r"
			if ClickTheText(fontPosButton, rtext, ini.Settings.ChatPosX + 300, y, 0xFF969696, 0xFFFFFFFF) then
				wait(250)
				sampSetCursorMode(0)
				sampSendChat("/seeme РїСЂРѕР±РѕСЂРјРѕС‚Р°Р»"..a.." С‡С‚Рѕ-С‚Рѕ РІ СЂР°С†РёСЋ")
				wait(0)
				sampSetChatInputText("/r "..ini.Info.tag.." | ")
				sampSetChatInputEnabled(true)
			end
			rtext = "/rb"
			if ClickTheText(fontPosButton, rtext, ini.Settings.ChatPosX + 320, y, 0xFF969696, 0xFFFFFFFF) then
				wait(250)
				sampSetCursorMode(0)
				sampSetChatInputText("/rb ")
				sampSetChatInputEnabled(true)
			end
		end
end

osmot = 0
medc = 0
function counter()
	lua_thread.create(function()
		if check_skin_local_player() then
			local render_text = string.format("РћСЃРјРѕС‚СЂРµРЅРѕ: "..osmot, -1)
			set_pos_medic_hud()
			if ClickTheText(font, render_text, ini.Settings.hud_x, ini.Settings.hud_y + 25, 0xFFFFFFFF, 0xFFFFFFFF) then
			end
		end
		if (isKeyDown(ini.Settings.Key) and check_skin_local_player()) then
			local render_text = string.format("+", -1)
			if ClickTheText(fontpmbuttons, render_text, ini.Settings.hud_x + 120, ini.Settings.hud_y + 18, 0xFFFFFFFF, 0xFFFFFFFF) then
				osmot = osmot + 1
			end
			local render_text = string.format("-", -1)
			if ClickTheText(fontpmbuttons, render_text, ini.Settings.hud_x + 150, ini.Settings.hud_y + 18, 0xFFFFFFFF, 0xFFFFFFFF) then
				osmot = osmot - 1
			end
		end

		if check_skin_local_player() then
			local render_text = string.format("РњРµРґ.РєР°СЂС‚: "..medc, -1)
			if ClickTheText(font, render_text, ini.Settings.hud_x, ini.Settings.hud_y + 50, 0xFFFFFFFF, 0xFFFFFFFF) then
			end
		end
		if (isKeyDown(ini.Settings.Key) and check_skin_local_player()) then
			local render_text = string.format("+", -1)
			if ClickTheText(fontpmbuttons, render_text, ini.Settings.hud_x + 120, ini.Settings.hud_y + 44, 0xFFFFFFFF, 0xFFFFFFFF) then
				medc = medc + 1
			end
			local render_text = string.format("-", -1)
			if ClickTheText(fontpmbuttons, render_text, ini.Settings.hud_x + 150, ini.Settings.hud_y + 44, 0xFFFFFFFF, 0xFFFFFFFF) then
				medc = medc - 1

			end
		end
	end)
end

paycheck_money = "0"
function paycheck()
	if ini.Settings.zptoggle then
		if paycheck_antiflood == nil or os.time() - paycheck_antiflood > 60 then
			paycheck_antiflood = os.time()
			sampSendChat("/paycheck")
		end
	end
end


function set_pos_medic_hud()
	if medic_hud_pos == nil then return end
	local x, y = getCursorPos()
	ini.Settings.hud_x, ini.Settings.hud_y = x, y
	sampSetCursorMode(3)
	if wasKeyPressed(1) then
		medic_hud_pos = nil
		inicfg.save(ini, "Medic")
	end
end

function set_pos_medic_chat()
	if medic_chat_pos == nil then return end
	local x, y = getCursorPos()
	ini.Settings.ChatPosX, ini.Settings.ChatPosY = x, y
	sampSetCursorMode(3)
	if wasKeyPressed(1) then
		medic_chat_pos = nil
		inicfg.save(ini, "Medic")
	end
end

-- EVENTS
chat = {}
for i = 1, 11 do chat[i] = "" end
timestamparr = {}
for o = 1, 11 do timestamparr[o] = "" end

function sampev.onServerMessage(color, message)
	local _, mid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	local mynick = sampGetPlayerNickname(mid)
	if message:find("Р’С‹ Р·Р°СЂР°Р±РѕС‚Р°Р»Рё %d+ РІРёСЂС‚. Р”РµРЅСЊРіРё Р±СѓРґСѓС‚ Р·Р°С‡РёСЃР»РµРЅС‹ РЅР° РІР°С€ Р±Р°РЅРєРѕРІСЃРєРёР№ СЃС‡РµС‚ РІ") then
		local number = message:match("Р’С‹ Р·Р°СЂР°Р±РѕС‚Р°Р»Рё (%d+) РІРёСЂС‚. Р”РµРЅСЊРіРё Р±СѓРґСѓС‚ Р·Р°С‡РёСЃР»РµРЅС‹ РЅР° РІР°С€ Р±Р°РЅРєРѕРІСЃРєРёР№ СЃС‡РµС‚ РІ")
		if os.time() - paycheck_antiflood <= 1 then
			paycheck_money = number
			return false
		end
	end
	if message:find('РќРµ С„Р»СѓРґРё!') then
        return false
    end
	if message:match("РњРµРґРёРє "..mynick.." РІС‹Р»РµС‡РёР» .+") then
		osmot = osmot + 1
	end
	if message:match("РњРµРґРєР°СЂС‚Р° РѕР±РЅРѕРІР»РµРЅР°") then
		medc = medc + 1
	end
	if message:match("РњРµРґРєР°СЂС‚Р° СЃРѕР·РґР°РЅР°") then
		medc = medc + 1
	end
	if message:match("Р’С‹ РІС‹Р»РµС‡РёР»Рё РїР°С†РёРµРЅС‚Р° .+") then
		osmot = osmot + 1
	end
	if message:match("РџР°С†РёРµРЅС‚ РІС‹Р»РµС‡РµРЅ РѕС‚ Р±РѕР»РµР·РЅРё .+") then
		osmot = osmot + 1
	end
	if message:match("РЎРµР°РЅСЃ Р»РµС‡РµРЅРёСЏ РѕС‚ Р±РѕР»РµР·РЅРё .+") then
		osmot = osmot + 1
	end

	if ini.Settings.ChatToggle then
		local standartclr = -1920073729
		local targetclr = color
		local timestamp = "["..os.date("%H:%M:%S").."]"
		if targetclr == standartclr then
			timestamparr[#timestamparr+1] = timestamp
			chat[#chat+1] = message
			return false
		end
	end


	if message:find(" Р’СЃРµРіРѕ СЃРµР°РЅСЃРѕРІ Сѓ СЌС‚РѕРіРѕ РїР°С†РёРµРЅС‚Р°: (%d+) / (%d+)") then
		local number1, number2 = message:match(" Р’СЃРµРіРѕ СЃРµР°РЅСЃРѕРІ Сѓ СЌС‚РѕРіРѕ РїР°С†РёРµРЅС‚Р°: (%d+) / (%d+)")
		local ostalnum = number2 - number1
			lua_thread.create(function()
				sampSendChat("/b Р•С‰Рµ "..ostalnum.." СѓРєРѕР»(Р°/РѕРІ)")
				wait(500)
				sampSendChat("/b РЎР»РµРґСѓСЋС‰РёР№ СѓРєРѕР» РїРѕСЃР»Рµ PayDay")
			end)
	end
		


end

toggle = false
warn = false
doklad = false
function timer(act)
	local time = os.date("%M:%S",os.time())
	local timers_warn = { "59:44", "14:44", "29:44", "44:44", }
	local timers_warnoff = { "59:45", "14:45", "29:45", "44:45", }
	local timers_doklads = { "00:00", "15:00", "30:00", "45:00", }
	local timers_dokladsoff = { "00:01", "15:01", "30:01", }
	local timer_drop = { "00:05", }
	if check_skin_local_player() then
		lua_thread.create(function()
			if act == true then
				toggletext = "{33bf00}Р’РєР»"
				if check_skin_local_player() then
					for k,v, pk, tl in pairs(timers_warn, timers_warnoff) do
						if warn == false and  time == v then
							sampSetCursorMode(0)
							sampAddChatMessage("{ff263c}[Medic] {FFFFFF}РђРІС‚РѕРјР°С‚РёС‡РµСЃРєРёР№ РґРѕРєР»Р°Рґ С‡РµСЂРµР· 15 СЃРµРє", -1)
							warn = true
						elseif time == tl then
							warn = false
						end
					end
					for d,lu, hp, yu in pairs(timers_doklads, timers_dokladsoff) do
						if doklad == false and time == lu then
							if location == " " then
								sampSetCursorMode(0)
								sampSendChat("/seeme РїСЂРѕР±РѕСЂРјРѕС‚Р°Р»"..a.." С‡С‚Рѕ-С‚Рѕ РІ СЂР°С†РёСЋ")
								sampSetChatInputText("/r "..ini.Info.tag.." | Р РµРіРёСЃС‚СЂР°С‚СѓСЂР°: "..ini.Info.reg.." | РћСЃРјРѕС‚СЂРµРЅРѕ: "..osmot.." | РњРµРґ.РєР°СЂС‚: "..medc.." | РќР°РїР°СЂРЅРёРє: "..partners.."")
								sampSetChatInputEnabled(true)
							else
								sampSetCursorMode(0)
								sampSendChat("/seeme РїСЂРѕР±РѕСЂРјРѕС‚Р°Р»"..a.." С‡С‚Рѕ-С‚Рѕ РІ СЂР°С†РёСЋ")
								sampSetChatInputText("/r "..ini.Info.tag.." | "..location.." | РћСЃРјРѕС‚СЂРµРЅРѕ: "..osmot.." | РњРµРґ.РєР°СЂС‚: "..medc.." | РќР°РїР°СЂРЅРёРє: "..partners.."")
								sampSetChatInputEnabled(true)
							end
							doklad = true
						elseif time == yu then
							doklad = false
						end
					end
					for po,ra in pairs(timer_drop) do
						if time == ra then
							osmot = 0
							medc = 0
						end
					end
				end
			elseif act == false then
				for ka,vz, oi, yz in pairs(timers_warn, timers_warnoff) do
					if warn == false and  time == vz then
						sampSetCursorMode(0)
						sampAddChatMessage("{ff263c}[Medic] {FFFFFF}РџРѕСЂР° РґРµР»Р°С‚СЊ РґРѕРєР»Р°Рґ", -1)
						warn = true
					elseif time == yz then
						warn = false
					end
				end
				toggletext = "{ff0000}Р’С‹РєР»"
			end
		end)
	end
end

partners = "-"
function partner()
	lua_thread.create(function()
		if check_skin_local_player() then
			local partner_text = string.format("РќР°РїР°СЂРЅРёРє: "..partners)
			set_pos_medic_hud()
			ClickTheText(font, partner_text, ini.Settings.hud_x, ini.Settings.hud_y + 75, 0xFFFFFFFF, 0xFFFFFFFF)
			local ped = 0
			for playerid = 0, 999 do
				if sampIsPlayerConnected(playerid) then
					local result, handle = sampGetCharHandleBySampPlayerId(playerid)
					if result then
						local X3, Y3, Z3 = getCharCoordinates(handle)
						local X4, Y4, Z4 = getCharCoordinates(PLAYER_PED)
						local distance = getDistanceBetweenCoords3d(X3, Y3, Z3, X4, Y4, Z4)
						local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
						local _, id = sampGetPlayerIdByCharHandle(playerid)
						local color = string.format("%X", tonumber(sampGetPlayerColor(playerid)))
						local targetnick = string.gsub(sampGetPlayerNickname(playerid), '_',' ')
						local targetname, targetsurname = string.match(targetnick, "(.+) (.+)")
						if #color == 8 then _, color = string.match(color, "(..)(......)") end
						if doesCharExist(handle) then
							if id ~= myid then
								if distance < 30 then
									for _, medic in pairs(skins) do
										if isCharModel(handle, medic) then
											partners = targetsurname
										end
									end
								end
								if distance > 30 then
									partners = "-"
								end
							end
						end
					end
				end
			end
		end
	end)
end

location = " "
function locations()
	lua_thread.create(function()
		if check_skin_local_player() then
			local locationtext = location
			set_pos_medic_hud()
			ClickTheText(font, locationtext, ini.Settings.hud_x, ini.Settings.hud_y + 100, 0xFFFFFFFF, 0xFFFFFFFF)

			local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
			local _, handle sampGetCharHandleBySampPlayerId(myid)

			--РђРІС‚РѕРІРѕРєР·Р°Р» Р›РЎ
			local avls1x = 1292
			local avls1y = -1718
			local avls1z = 13

			local avls2x = 1045
			local avls2y = -1843
			local avls2z = 30

			--РњСЌСЂРёСЏ
			local may1x = 1394
			local may1y = -1868
			local may1z = 13

			local may2x = 1564
			local may2y = -1738
			local may2z = 30

			--Р¤РµСЂРјР° 0
			local farm01x = -592
			local farm01y = -1288
			local farm01z = 0

			local farm02x = -212
			local farm02y = -1500
			local farm02z = 30

			--РђРЁ
			local ash1x = -2013
			local ash1y = -76
			local ash1z = 30

			local ash2x = -2095
			local ash2y = -280
			local ash2z = 50

			--РђРІС‚РѕРІРѕРєР·Р°Р» РЎР¤
			local sfav1x = -2001
			local sfav1y = 218
			local sfav1z = 10

			local sfav2x = -1923
			local sfav2y = 72
			local sfav2z = 50

			--РўРџ
			local tp1x = -1997
			local tp1y = 536
			local tp1z = 30

			local tp2x = -1907
			local tp2y = 598
			local tp2z = 50

			--РћСЂСѓР¶РµР№РЅС‹Р№ Р·Р°РІРѕРґ
			local ozav1x = -2009
			local ozav1y = -196
			local ozav1z = 30

			local ozav2x = -2201
			local ozav2y = -280
			local ozav2z = 50

			--РљР°Р·РёРЅРѕ
			local kaz1x = 2158
			local kaz1y = 2203
			local kaz1z = 0

			local kaz2x = 2363
			local kaz2y = 2027
			local kaz2z = 50

			--РђРІС‚РѕРІРѕРєР·Р°Р» Р›Р’
			local avlv1x = 2859
			local avlv1y = 1382
			local avlv1z = 0

			local avlv2x = 2758
			local avlv2y = 1224
			local avlv2z = 50

			--Р›РЎ
			local ls1x = 2930
			local ls1y = -2740
			local ls1z = 0

			local ls2x = 50
			local ls2y = -890
			local ls2z = 250

			--РЎР¤
			local sf1x = -1344
			local sf1y = -1065
			local sf1z = 250

			local sf2x = -2981
			local sf2y = 1487
			local sf2z = 0

			--Р›Р’
			local lv1x = 842
			local lv1y = 2947
			local lv1z = 250

			local lv2x = 2970
			local lv2y = 570
			local lv2z = 0

			if isCharInArea3d(PLAYER_PED, avls1x, avls1y, avls1z, avls2x, avls2y, avls2z) == true then
				location = "РџРѕСЃС‚: РђРІС‚РѕРІРѕРєР·Р°Р» Р›РЎ"
			elseif isCharInArea3d(PLAYER_PED, may1x, may1y, may1z, may2x, may2y, may2z) == true then
				location = "РџРѕСЃС‚: РњСЌСЂРёСЏ"
			elseif isCharInArea3d(PLAYER_PED, farm01x, farm01y, afarm01z, farm02x, farm02y, farm02z) == true then
				location = "РџРѕСЃС‚: Р¤РµСЂРјР° 0"
			elseif isCharInArea3d(PLAYER_PED, ash1x, ash1y, ash1z, ash2x, ash2y, ash2z) == true then
				location = "РџРѕСЃС‚: РђРІС‚РѕС€РєРѕР»Р°"
			elseif isCharInArea3d(PLAYER_PED, sfav1x, sfav1y, sfav1z, sfav2x, sfav2y, sfav2z) == true then
				location = "РџРѕСЃС‚: РђРІС‚РѕРІРѕРєР·Р°Р» РЎР¤"
			elseif isCharInArea3d(PLAYER_PED, tp1x, tp1y, tp1z, tp2x, tp2y, tp2z) == true then
				location = "РџРѕСЃС‚: РўРѕСЂРіРѕРІР°СЏ РїР»РѕС‰Р°РґРєР°"
			elseif isCharInArea3d(PLAYER_PED, ozav1x, ozav1y, ozav1z, ozav2x, ozav2y, ozav2z) == true then
				location = "РџРѕСЃС‚: РћСЂСѓР¶РµР№РЅС‹Р№ Р·Р°РІРѕРґ"
			elseif isCharInArea3d(PLAYER_PED, kaz1x, kaz1y, kaz1z, kaz2x, kaz2y, kaz2z) == true then
				location = "РџРѕСЃС‚: РљР°Р·РёРЅРѕ"
			elseif isCharInArea3d(PLAYER_PED, avlv1x, avlv1y, avlv1z, avlv2x, avlv2y, avlv2z) == true then
				location = "РџРѕСЃС‚: РђРІС‚РѕРІРѕРєР·Р°Р» Р›Р’"
			elseif isCharInArea3d(PLAYER_PED, ls1x, ls1y, ls1z, ls2x, ls2y, ls2z) == true then
				location = "РџР°С‚СЂСѓР»СЊ: LS"
			elseif isCharInArea3d(PLAYER_PED, sf1x, sf1y, sf1z, sf2x, sf2y, sf2z) == true then
				location = "РџР°С‚СЂСѓР»СЊ: SF"
			elseif isCharInArea3d(PLAYER_PED, lv1x, lv1y, lv1z, lv2x, lv2y, lv2z) == true then
				location = "РџР°С‚СЂСѓР»СЊ: LV"
			else
				location = " "
			end
		end
	end)
end

function ClickTheText(font, text, posX, posY, color, colorA)
	renderFontDrawText(font, text, posX, posY, color)
	local textLenght = renderGetFontDrawTextLength(font, text)
	local textHeight = renderGetFontDrawHeight(font)
	local curX, curY = getCursorPos()
	if curX >= posX and curX <= posX + textLenght and curY >= posY and curY <= posY + textHeight then
	  renderFontDrawText(font, "{"..ini.Settings.Color2.."}"..text, posX, posY, colorA)
	  if isKeyJustPressed(1) then
		return true
	  end
	end
end
