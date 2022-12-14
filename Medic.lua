script_name('Medic')
script_authors("Galileo_Galilei, Serhiy_Rubin")
script_version("1.6.8")
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
    local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Îáíàðóæåíî îáíîâëåíèå. Ïûòàþñü îáíîâèòüñÿ c '..thisScript().version..' íà '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Çàãðóæåíî %d èç %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Çàãðóçêà îáíîâëåíèÿ çàâåðøåíà.')sampAddChatMessage(b..'Îáíîâëåíèå çàâåðøåíî!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Îáíîâëåíèå ïðîøëî íåóäà÷íî. Çàïóñêàþ óñòàðåâøóþ âåðñèþ..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': Îáíîâëåíèå íå òðåáóåòñÿ.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Íå ìîãó ïðîâåðèòü îáíîâëåíèå. Ñìèðèòåñü èëè ïðîâåðüòå ñàìîñòîÿòåëüíî íà '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, âûõîäèì èç îæèäàíèÿ ïðîâåðêè îáíîâëåíèÿ. Ñìèðèòåñü èëè ïðîâåðüòå ñàìîñòîÿòåëüíî íà '..c)end end}]])
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
	rank = "Ìåä.ðàáîòíèê",
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

	sampAddChatMessage("{ff263c}[Medic] {ffffff}Ñêðèïò óñïåøíî çàãðóæåí. Âåðñèÿ: 1.6.8", -1)

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
			ChatToggleText = "{33bf00}Âêë"
			render_chat()
		else 
			ChatToggleText = "{ff0000}Âûêë"
		end
		if ini.Settings.zptoggle then
			ZpToggleText = "{33bf00}Âêë"
			zp()
		else
			ZpToggleText = "{ff0000}Âûêë"
		end
		if ini.Settings.hudtoggle then
			hudtoggletext = "{33bf00}Âêë"
			render_hud()
			counter()
			partner()
			locations()
		else
			hudtoggletext = "{ff0000}Âûêë"
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
			rtext = "Îíëàéí ìåäèêè"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				sampSendChat("/members 1")
			end
			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "Ñïèñîê âûçîâîâ"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				sampSendChat("/service")
			end
			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "Áûñòðûå êîìàíäû"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				sampSendChat("/fmenu")
			end
			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "Ñìåíèòü áîëüíèöó"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				sampSendChat("/spawnchange")
			end
			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "Ìîè äàííûå"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				menu_myinfo = not menu_myinfo
				menu_binds = false
				menu_doklad = false
			end
			if menu_myinfo then
				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Ïîë: {FFFFFF}"..sex
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y, 0xFF858585, 0xFFFFFFFF) then
					ini.Settings.sex = not ini.Settings.sex
					inicfg.save(ini, "Medic")
					thisScript():reload()
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Äîëæíîñòü: {FFFFFF}"..ini.Info.rank
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y, 0xFF858585, 0xFFFFFFFF) then
					sampShowDialog(6406, "Óêàæèòå âàøó äîëæíîñòü", "Âàøà äîëæíîñòü:", "ÎÊ", "Îòìåíà", DIALOG_STYLE_INPUT)
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
				rtext = "Òýã: {FFFFFF}"..ini.Info.tag
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y, 0xFF858585, 0xFFFFFFFF) then
					sampShowDialog(6410, "Óêàæèòå âàø òýã", "Âàø òýã:", "ÎÊ", "Îòìåíà", DIALOG_STYLE_INPUT)
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
				rtext = "Áåéäæ: {FFFFFF}"..ini.Info.clist
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y, 0xFF858585, 0xFFFFFFFF) then
					sampShowDialog(6411, "Óêàæèòå âàø áåéäæ", "Âàø áåéäæ:", "ÎÊ", "Îòìåíà", DIALOG_STYLE_INPUT)
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
				rtext = "Áîëüíèöà: {FFFFFF}"..ini.Info.reg
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y, 0xFF858585, 0xFFFFFFFF) then
					sampShowDialog(6412, "Óêàæèòå âàøó ðåãèñòðàòóðó", "Âàøà ðåãèñòðàòóðà:", "ÎÊ", "Îòìåíà", DIALOG_STYLE_INPUT)
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
			rtext = "Íàñòðîéêè"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				menu_settings = not menu_settings
			end
			if menu_settings then
				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Àâòîäîêëàäû "..toggletext
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
					toggle = not toggle
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Çàðïëàòà "..ZpToggleText
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
			rtext = "Îáùèå áèíäû"
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
					rtext = "Ïðèâåòñòâèå"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/todo Çäðàâñòâóéòå! ß äîêòîð "..surname.."! *óëûáàÿñü")
						wait(1000)
						sampSendChat("/do Íà áåéäæèêå: "..ini.Info.tag.." | Äîêòîð "..surname.." | "..ini.Info.rank.."")
						wait(1000)
						sampSendChat("×òî Âàñ áåñïîêîèò?")
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "Ïîïðîñèòü ñëåäîâàòü"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("Ïðîéä¸ìòå çà ìíîé")
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "Ïðîùàíèå"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("Âñåãî äîáðîãî è íå áîëåéòå.")
						wait(1000)
						sampSendChat("Áåðåãèòå ñåáÿ è ñâîèõ áëèçêèõ.")
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "Íàäåòü áåéäæèê"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/me äîñòàë"..a.." èç êàðìàíà áåéäæèê")
						wait(1000)
						sampSendChat("/me íàäåë"..a.." áåéäæèê")
						wait(1000)
						sampSendChat("/do Íà áåéäæèêå: "..ini.Info.tag.." | Äîêòîð "..surname.." | "..ini.Info.rank.."")
						wait(1000)
						sampSendChat("/clist "..ini.Info.clist.."")
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "Ïîïðàâèòü áåéäæèê"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/me ïîïðàâèë"..a.." áåéäæèê")
						wait(1000)
						sampSendChat("/do Íà áåéäæèêå: "..ini.Info.tag.." | Äîêòîð "..surname.." | "..ini.Info.rank.."")
						wait(1000)
						sampSendChat("/clist "..ini.Info.clist.."")
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "Çàíÿòü ðåãèñòðàòóðó"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme ãîâîðèò â ðàöèþ")
						wait(0)
						sampSetChatInputText("/r "..ini.Info.tag.." | Çàíèìàþ ðåãèñòðàòóðó "..ini.Info.reg.."")
						sampSetChatInputEnabled(true)
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "Ïîêèíóòü ðåãèñòðàòóðó"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme ãîâîðèò â ðàöèþ")
						wait(0)
						sampSetChatInputText("/r "..ini.Info.tag.." | Ïîêèäàþ ðåãèñòðàòóðó "..ini.Info.reg.."")
						sampSetChatInputEnabled(true)
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "Òðàíêâèëèçàòîð (Deagle)[5+ ðàíã]"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/do Íà ïîÿñå äîêòîðà çàêðåïëåíà êîáóðà.")
						wait(1000)
						sampSendChat("/me äîñòàë"..a.." èç êîáóðû ïèñòîëåò ñ òðàíêâèëèçàòîðîì MP-53M")
						wait(1000)
						sampSendChat("/do Ïèñòîëåò çàðÿæåí, ïîñòàâëåí íà ïðåäîõðàíèòåëü.")
						wait(1000)
						sampSendChat("/do Äðîòèêè îñíàùåíû ñíîòâîðíûì ñðåäñòâîì.")
						wait(1000)
						sampSendChat("/me ñíÿë"..a.." ñ ïðåäîõðàíèòåëÿ è îòâ¸ë"..a.." çàòâîð")
					end
				end)
			end

			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "Äîêëàäû"
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
					rtext = "Ñ ðåãèñòðàòóðû"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme äåëàåò äîêëàä â ðàöèþ")
						wait(1500)
						sampSetChatInputText("/r "..ini.Info.tag.." | Ðåãèñòðàòóðà: "..ini.Info.reg.." | Îñìîòðåíî: "..osmot.." | Ìåä.êàðò: "..medc.." | Íàïàðíèê: "..partners.."")
						sampSetChatInputEnabled(true)
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "Ñ ïîñòà / ñ ïàòðóëÿ"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme äåëàåò äîêëàä â ðàöèþ")
						wait(1500)
						sampSetChatInputText("/r "..ini.Info.tag.." | "..location.." | Îñìîòðåíî: "..osmot.." | Áàê: | Íàïàðíèê: "..partners.."")
						sampSetChatInputEnabled(true)
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "Ñ âîåíêîìàòà"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme äåëàåò äîêëàä â ðàöèþ")
						wait(1500)
						sampSetChatInputText("/r "..ini.Info.tag.." | Âîåíêîìàò:  | Îñìîòðåíî: "..osmot.." | Ìåä.êàðò: "..medc.." | Íàïàðíèê: "..partners.."")
						sampSetChatInputEnabled(true)
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "Ïðèíÿòü âûçîâ"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme äåëàåò äîêëàä â ðàöèþ")
						wait(1500)
						sampSendChat("/r "..ini.Info.tag.." | Ïðèíÿë"..a.." âûçîâ ")
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
										if ClickTheText(font, "Ìåä. ìåíþ", X3, Y3, 0xffff0000, 0xFFFFFFFF) then
											menu_1[playerid] = not menu_1[playerid] -- âêë âûêë ìåíþ
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
											if ClickTheText(font, "Îòûãðàòü", X3 + 15, Y3, 0xfffc4e4e, 0xFFFFFFFF) then
												menu_1o[playerid] = not menu_1o[playerid] -- âêë âûêë ìåíþ
												menu_1no = {}
												menu_heal = {}
												menu_healdisease = {}
												menu_healwound = {}
												menu_mc = {}
												menu_setsex = {}
											end

											if menu_1o[playerid] then
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Ëå÷åíèå", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_heal[playerid] = not menu_heal[playerid] -- âêë âûêë ìåíþ
													menu_healdisease = {}
													menu_healwoundper = {}
													menu_healwoundran = {}
													menu_mc = {}
													menu_setsex = {}
												end
												if menu_heal[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Ãîëîâíàÿ áîëü", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/do Íà ïîÿñå äîêòîðà ìåä.ñóìêà.")
														wait(1500)
														sampSendChat("/me äîñòàë"..a.." ïëàñòèíó àñïèðèíà è âûäàâèë"..a.." òàáëåòêó")
														wait(1500)
														sampSendChat("/me íàëèë"..a.." ñòàêàí âîäû è ïåðåäàë"..a.." ïàöèåíòó  âìåñòå ñ òàáëåòêîé")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Íàñìîðê", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me âíèìàòåëüíî îñìîòðåë"..a.." ñîñòîÿíèå ïàöèåíòà")
														wait(1500)
														sampSendChat("/do íà ïîÿñå äîêòîðà ìåä.ñóìêà.")
														wait(1500)
														sampSendChat("Ó Âàñ íàñìîðê. ß âûïèøó Âàì êàïëè")
														wait(1500)
														sampSendChat("/me äîñòàë"..a.." èç ìåä.ñóìêè êàïëè Ëàçîëâàí")
														wait(1500)
														sampSendChat("/me ïåðåäàë"..a.." êàïëè ïàöèåíòó")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Êàøåëü", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/do Íà ïîÿñå äîêòîðà ìåä.ñóìêà.")
														wait(1500)
														sampSendChat("/me îñìîòðåë"..a.." ïàöèåíòà")
														wait(1500)
														sampSendChat("Ó âàñ ñèëüíûé êàøåëü. ß âûïèøó âàì ëåäåíöû Äîêòîð Ìîì")
														wait(1500)
														sampSendChat("/me äîñòàë"..a.." ëåäåíöû èç ìåä.ñóìêè")
														wait(1500)
														sampSendChat("/me ïåðåäàë"..a.." "..targetname.." "..targetsurname.." ëåêàðñòâî")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Ëîìêà/Îïüÿíåíèå", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me îñìîòðåë"..a.." ïàöèåíòà")
														wait(1500)
														sampSendChat("/do Íà ïîÿñå äîêòîðà ìåäñóìêà.")
														wait(1500)
														sampSendChat("/me îòêðûë"..a.." ñóìêó è äîñòàë"..a.." øïðèö ñ ìîðôèíîì")
														wait(1500)
														sampSendChat("/me ââåë"..a.." ïîëêóáèêà ìîðôèíà ïàöèåíòó âíóòðèìûøå÷íî")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Íåñâàðåíèå", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me äîñòàë"..a.." èç ñóìêè ïàêåòèê ñ ïîëèñîðáîì")
														wait(1500)
														sampSendChat("/me íàëèë"..a.." âîäó èç áóòûëêè â ñòàêàí")
														wait(1500)
														sampSendChat("/todo Âûïåéòå ýòî *ïåðåäàâ ñòàêàí÷èê ñ ðàçâåäåííûì â âîäå ëåêàðñòâîì")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Áîëè â æèâîòå", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("ß âûïèøó âàì òàáëåòêè Ðåííè")
														wait(1500)
														sampSendChat("/do Íà ïîÿñå äîêòîðà ìåä.ñóìêà.")
														wait(1500)
														sampSendChat("/me äîñòàë"..a.." ïëàñòèíêó òàáëåòîê Ðåííè èç ìåä.ñóìêè")
														wait(1500)
														sampSendChat("/me âûïèñàë"..a.." èíñòðóêöèþ ïî ïðèìåíåíèþ")
														wait(1500)
														sampSendChat("/me ïåðåäàë"..a.." èíñòðóêöèþ è ïëàñòèíêó ïàöèåíòó")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Ãåìîððîé", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("Âûïèøó âàì ñâå÷è Ðåëèô è íàçíà÷ó êóðñ ëå÷åíèÿ")
														wait(1500)
														sampSendChat("/do Íà ïîÿñå äîêòîðà ìåä.ñóìêà.")
														wait(1500)
														sampSendChat("/me âûíóë"..a.." óïàêîâêó ðåêòàëüíûõ ñâå÷åé")
														wait(1500)
														sampSendChat("/me ïåðåäàë"..a.." ïàöèåíòó ñâå÷è")
														wait(1500)
														sampSendChat("/me äîñòàë"..a.." èç êàðìàíà áëàíê è ðó÷êó")
														wait(1500)
														sampSendChat("/me âûïèñàë"..a.." ðåöåïò")
														wait(1500)
														sampSendChat("/me ïåðåäàë"..a.." ïàöèåíòó ðåöåïò")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
												end


												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Áîëåçíè è Çàâèñèìîñòè", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_healdisease[playerid] = not menu_healdisease[playerid] -- âêë âûêë ìåíþ
													menu_heal = {}
													menu_healwoundper = {}
													menu_healwoundran = {}
													menu_mc = {}
													menu_setsex = {}
												end
												if menu_healdisease[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Íàðêîçàâèñèìîñòü", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/todo Cîæìèòå ðóêó â êóëàê *çàòÿãèâàÿ æãóò")
														wait(1500)
														sampSendChat("/me íàùóïàë"..a.." âåíó ëîêòåâîãî ñãèáà")
														wait(1500)
														sampSendChat("/me íàáðàë"..a.." âåùåñòâî èç àìïóëû â øïðèö")
														wait(1500)
														sampSendChat("/me ââåë"..a.." ëåêàðñòâî âíóòðèâåííî è ñíÿë"..a.." æãóò")
														wait(1500)
														sampSendChat("/me âûâåë"..a.." èãëó èç âåíû è ïîäñòàâèë"..a.." ñïèðòîâóþ âàòêó")
														wait(1000)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Ãðèïï", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("Ñåé÷àñ ÿ ñäåëàþ Âàì óêîëü÷èê áèîêñîíà.")
														wait(1500)
														sampSendChat("À òàêæå âûïèøó Âàì Êàãîöåë")
														wait(1500)
														sampSendChat("Íåîáõîäèìî íàáëþäåíèå âðà÷à íå ÷àùå ðàçà â ÷àñ")
														wait(1500)
														sampSendChat("/me äîñòàë"..a.." àìïóëó Áèîêñîíà")
														wait(1500)
														sampSendChat("/me íàáðàë"..a.." áèîêñîí â øïðèö")
														wait(1500)
														sampSendChat("/todo Ðàññëàáüòåñü *ïðîòèðàÿ âàòêîé ìåñòî óêîëà")
														wait(1500)
														sampSendChat("/me ââåë"..a.." ðàñòâîð áèîêñîíà ïàöèåíòó")
														wait(1500)
														sampSendChat("/todo Ìîæåòå ñîáèðàòüñÿ *çàïîëíÿÿ ðåöåïò, ïåðåäàë"..a.." ðåöåïò ïàöèåíòó")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Áðîíõèò", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/do Â ðóêàõ âðà÷à ñòåòîñêîï.")
														wait(1500)
														sampSendChat("Îãîëèòå òîðñ è ïîäîéäèòå áëèæå")
														wait(1500)
														sampSendChat("/me ïîñëóøàë"..a.." ëåãêèå ïàöèåíòà")
														wait(1500)
														sampSendChat("/todo Èìåþòñÿ õðèïû â ëåãêèõ *óáèðàÿ ñòåòîñêîï")
														wait(1500)
														sampSendChat("/me âûïèñàë"..a.." ðåöåïò íà Àìáðîãåêñàë è îáèëüíîå òåïëîå ïèòü¸")
														wait(1500)
														sampSendChat("/me ïåðåäàë"..a.." ïàöèåíòó ðåöåïò è ìåäêàðòó")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Îòðàâëåíèå", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me äîñòàë"..a.." èç ìåäñóìêè óïàêîâêó àêòèâèðîâàííîãî óãëÿ")
														wait(1500)
														sampSendChat("/me âûäàâèë"..a.." íåñêîëüêî òàáëåòîê àêòèâ. óãëÿ")
														wait(1500)
														sampSendChat("/me ïåðåäàë"..a.." ïàöèåíòó")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Ìèêîç", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me îñìîòðåë"..a.." êîæó ïàöèåíòà è îáíàðóæèë ãðèáêîâûå ñïîðû")
														wait(1500)
														sampSendChat("/me äîñòàë"..a.." èç ñóìêè ìàçü ëàìèçèë")
														wait(1500)
														sampSendChat("/me íàìàçàë"..a.." ïîðàæåííûé ãðèáêîì ó÷àñòîê êîæè ìàçüþ")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Êëåùåâîé ýíöåôàëèò", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me äîñòàë"..a.." èç ñóìêè øïðèö è àìïóëó èìóíîãëîáóëèíà")
														wait(1500)
														sampSendChat("/me íàáðàë"..a.." âåùåñòâî èç àìïóëû â øïðèö")
														wait(1500)
														sampSendChat("/me ââåë"..a.." ïðåïàðàò âíóòðèìûøå÷íî")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Àëêîãîëèçì", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me îñìîòðåë"..a.." îáùåå ñîñòîÿíèå ïàöèåíòà")
														wait(1500)
														sampSendChat("/me äîñòàë"..a.." ðó÷êó è íàïèñàë"..a.." ëèñò íàçíà÷åíèé")
														wait(1500)
														sampSendChat("/do Â ðóêàõ äîêòîðà êîðîáî÷êà ïðåïàðàòà «Òåòóðàì».")
														wait(1500)
														sampSendChat("/me äîñòàë"..a.." ïëàñòèíêó è ïåðåäàë"..a.." ïàöèåíòó")
														wait(1500)
														sampSendChat("/todo Ïðîïåéòå êóðñ ñîãëàñíî ëèñòó íàçíà÷åíèÿ*ïàðàëëåëüíî ïðèêëàäûâàÿ ê óïàêîâêå ëèñò")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
												end

												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Ïåðåëîìû", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_healwoundper[playerid] = not menu_healwoundper[playerid]
													menu_healwoundran = {} -- âêë âûêë ìåíþ
													menu_heal = {}
													menu_healdisease = {}
													menu_mc = {}
													menu_setsex = {}
												end
												if menu_healwoundper[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "1. Ïåðåëîì[äèàãíîñòèêà]", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me äîñòàë"..a.." íîâûå âèíèëîâûå ïåð÷àòêè è íàäåë"..a.." èõ")
														wait(1500)
														sampSendChat("/me ïîìîã(ëà) ïàöèåíòó ëå÷ü íà îïåðàöèîííûé ñòîë")
														wait(1500)
														sampSendChat("/b Çàëåçàéòå íà ñòîë è /anim 22")
														wait(1500)
														sampSendChat("/me âíèìàòåëüíî îñìîòðåë"..a.." ïàöèåíòà")
														wait(1500)
														sampSendChat("/try îáíàðóæèë"..a.." îòêðûòûé ïåðåëîì")
														wait(300)
														sampAddChatMessage("{00a100}Óäà÷íî{FFFFFF} - Îïåðàöèÿ", 0xFFFFFFFF)
														sampAddChatMessage("{ff0000}Íåóäà÷íî{FFFFFF} - Ðåíòãåí", 0xFFFFFFFF)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "2. Îïåðàöèÿ{00a100}[Óäà÷íî]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me âêëþ÷èë"..a.." ðåíòãåí-àïïàðàò")
														wait(1500)
														sampSendChat("/me ñäåëàë"..a.." ñíèìîê ïîâðåæäåííîé êîíå÷íîñòè")
														wait(1500)
														sampSendChat("/do Ñïóñòÿ âðåìÿ ñíèìîê âûâåäåí íà ýêðàí.")
														wait(1500)
														sampSendChat("/me âíèìàòåëüíî èçó÷èë"..a.." ñíèìîê")
														wait(1500)
														sampSendChat("/me íàäåë"..a.." íà ïàöèåíòà èíãàëÿöèîííóþ ìàñêó")
														wait(1500)
														sampSendChat("/me ââ¸ë"..a.." ïàöèåíòà â ñîñòîÿíèå îáùåãî íàðêîçà")
														wait(1500)
														sampSendChat("/me ñêàëüïåëåì ðàçðåçàë"..a.." ïëîòü îêîëî ïîâðåæäåííîé êîñòè")
														wait(1500)
														sampSendChat("/me ïîäæàë"..a.." êðàÿ ïëîòè çàæèìîì")
														wait(1500)
														sampSendChat("/try âïðàâèë"..a.." êîñòü ïàöèåíòó")
														wait(1500)
														sampAddChatMessage("{00a100}Óäà÷íî{FFFFFF} - Âïðàâèë", 0xFFFFFFFF)
														sampAddChatMessage("{ff0000}Íåóäà÷íî{FFFFFF} - Íåâðàâèë", 0xFFFFFFFF)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "3. Âïðàâèë{00a100}[Óäà÷íî]", X3 + 75, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ñíÿë"..a.." çàæèìû")
														wait(1500)
														sampSendChat("/me âçÿë"..a.." áèîíè÷åñêèå íèòè è èãëó")
														wait(1500)
														sampSendChat("/me íàëîæèë"..a.." øîâ íà êîíå÷íîñòü")
														wait(1500)
														sampSendChat("/me âûìî÷èë"..a.." ãèïñ â áèêñå êèïÿ÷åííîé âîäû")
														wait(1500)
														sampSendChat("/me íàëîæèë"..a.." ãèïñ íà êîíå÷íîñòü")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "3. Íåâïðàâèë{ff0000}[Íåóäà÷íî]", X3 + 75, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ïðîõðóñòåë"..a.." ïàëüöàìè, ðàçìÿâ ðóêè")
														wait(1500)
														sampSendChat("/me ïðèëîæèë"..a.." áîëüøå óñèëèé è óñïåøíî âïðàâèë"..a.." êîñòü")
														wait(1500)
														sampSendChat("/me ñíÿë"..a.." çàæèìû")
														wait(1500)
														sampSendChat("/me âçÿë"..a.." áèîíè÷åñêèå íèòè è èãëó")
														wait(1500)
														sampSendChat("/me íàëîæèë"..a.." øîâ íà êîíå÷íîñòü")
														wait(1500)
														sampSendChat("/me âûìî÷èë"..a.." ãèïñ â áèêñå êèïÿ÷åííîé âîäû")
														wait(1500)
														sampSendChat("/me íàëîæèë"..a.." ãèïñ íà êîíå÷íîñòü")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "2. Ðåíòãåí{ff0000}[Íåóäà÷íî]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me âêëþ÷èë"..a.." ðåíòãåí àïïàðàò")
														wait(1500)
														sampSendChat("/me ñäåëàë"..a.." ñíèìîê ïîâðåæä¸ííîé êîíå÷íîñòè")
														wait(1500)
														sampSendChat("/do Ñïóñòÿ âðåìÿ ñíèìîê âûâåäåí íà ýêðàí.")
														wait(1500)
														sampSendChat("/try óâèäåë"..a.." íà ñíèìêå ïåðåëîì")
														wait(300)
														sampAddChatMessage("{00a100}Óäà÷íî{FFFFFF} - Çàêðûòûé", 0xFFFFFFFF)
														sampAddChatMessage("{ff0000}Íåóäà÷íî{FFFFFF} - Óøèá", 0xFFFFFFFF)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "3. Çàêðûòûé{00a100}[Óäà÷íî]", X3 + 75, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me äîñòàë"..a.." øïðèö è àìïóëó îáåçáîëèâàþùåãî")
														wait(1500)
														sampSendChat("/me íàáðàë"..a.." îáåçáîëèâàþùåå â øïðèö")
														wait(1500)
														sampSendChat("/me ââåë"..a.." îáåçáîëèâàþùåå ïàöèåíòó")
														wait(1500)
														sampSendChat("/me âïðàâèë"..a.." êîñòü")
														wait(1500)
														sampSendChat("/me íàëîæèë"..a.." ïîâÿçêó ñîôòêàñò ïàöèåíòó")
														wait(1500)
														sampSendChat("/healwound "..playerid)
														wait(1500)
														sampSendChat("/me âûäàë"..a.." ïàöèåíòó êîñòûëè")
														wait(1500)
														sampSendChat("Ïî íà÷àëó áóäåò íåóäîáíî, íî, óâåðÿþ, âû ñïðàâèòåñü")
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "3. Óøèá{ff0000}[Íåóäà÷íî]", X3 + 75, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("Âàì ïîâåçëî, ÷òî îáîøëîñü áåç ïåðåëîìîâ")
														wait(1500)
														sampSendChat("Âñåãî ëèøü óøèá")
														wait(1500)
														sampSendChat("/me äîñòàë"..a.." èç ìåäñóìêè òþáèê ìàçè")
														wait(1500)
														sampSendChat("/me íàíåñ"..la.." íà ìåñòî óøèáà ìàçü è ðàñòåð"..la.." åå")
														wait(1500)
														sampSendChat("/me íàëîæèë"..a.." íà ìåñòî óøèáà ýëàñòè÷íûé áèíò")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
												end

												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Ðàíåíèÿ", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_healwoundran[playerid] = not menu_healwoundran[playerid]
													menu_healwoundper = {} -- âêë âûêë ìåíþ
													menu_heal = {}
													menu_healdisease = {}
													menu_mc = {}
													menu_setsex = {}
												end
												if menu_healwoundran[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Ðàíû(ðåçàíûå, êîëîòûå, ðóáëåíûå, ðâàíûå)", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("Ëîæèòåñü íà ñòîë, ñåé÷àñ áóäåòå êàê íîâåíüêèé")
														wait(1500)
														sampSendChat("/me äîñòàë"..a.." èç ìåä.ñóìêè áàíî÷êó çåëåíêè")
														wait(1500)
														sampSendChat("/me ïðîäåçèíôåöèðîâàë"..a.." ðàíó ïàöèåíòà")
														wait(1500)
														sampSendChat("/me ïîäãîòîâèë"..a.." âñ¸ äëÿ îïåðàöèè")
														wait(1500)
														sampSendChat("/do Âñ¸ íåîáõîäèìîå ëåæèò íà ñòîëå.")
														wait(1500)
														sampSendChat("/me âçÿë"..a.." â ðóêè õèðóðãè÷åñêèå íèòè è èãëó")
														wait(1500)
														sampSendChat("/do Äîêòîð íàêëàäûâàåò øâû íà ðàíó.")
														wait(1500)
														sampSendChat("/me óáðàë"..a.." õèðóðãè÷åñêèå íèòè è èãëó")
														wait(1500)
														sampSendChat("/me íàëîæèë"..a.." ñòåðèëüíóþ ïîâÿçêó íà ìåñòî øâà")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Îãíåñòðåëüíûå ðàíåíèÿ", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me îñìîòðåë"..a.." ðàíåíèå ïîñòðàäàâøåãî")
														wait(1500)
														sampSendChat("/me äîñòàë"..a.." àìïóëó íîâîêàèíà, øïðèö è íàáðàë"..a.." íîâîêàèí â øïðèö")
														wait(1500)
														sampSendChat("/me ââ¸ë"..a.." îáåçáîëèâàþùåå ïàöèåíòó")
														wait(1500)
														sampSendChat("/me âçÿë"..a.." ñêàëüïåëü è ñäåëàë"..a.." íàäðåç â ìåñòå ðàíåíèÿ")
														wait(1500)
														sampSendChat("/me ïîëîæèë"..a.." ñêàëüïåëü è âçÿë"..a.." ùèïöû")
														wait(1500)
														sampSendChat("/try óñïåøíî èçâë¸ê"..la.." ïóëþ")
														wait(300)
														sampAddChatMessage("{00a100}Óäà÷íî{FFFFFF} - Îãíåñòðåëüíîå ðàíåíèå{00a100}[Óäà÷íî]", 0xFFFFFFFF)
														wait(300)
														sampAddChatMessage("{ff0000}Íåóäà÷íî{FFFFFF} - Îãíåñòðåëüíîå ðàíåíèå{ff0000}[Íåóäà÷íî]", 0xFFFFFFFF)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Îãíåñòðåë{00a100}[Óäà÷íî]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me óáðàë"..a.." ïóëþ â ïî÷êîîáðàçíûé êîíòåéíåð")
														wait(1500)
														sampSendChat("/me âçÿë"..a.." â ðóêè õèðóðãè÷åñêóþ èãëó è íèòü")
														wait(1500)
														sampSendChat("/do Äîêòîð íàêëàäûâàåò øâû.")
														wait(1500)
														sampSendChat("/me îáîðâàë"..a.." íèòü è óáðàë"..a.." èãëó")
														wait(1500)
														sampSendChat("/me íàëîæèë"..a.." ìàðëåâóþ ïîâÿçêó íà ðàíó")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Îãíåñòðåë{ff0000}[Íåóäà÷íî]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ïîëîæèë"..a.." ùèïöû íà ìåñòî è âçÿë"..a.." ñêàëüïåëü")
														wait(1500)
														sampSendChat("/me ñäåëàë"..a.." äîïîëíèòåëüíûé íàäðåç")
														wait(1500)
														sampSendChat("/me ñíîâà âçÿë"..a.." ùèïöû è óñïåøíî èçâë¸ê(èçâëåêëà) ïóëþ")
														wait(1500)
														sampSendChat("/me óáðàë"..a.." ïóëþ â ïî÷êîîáðàçíûé êîíòåéíåð")
														wait(1500)
														sampSendChat("/do Äîêòîð íàêëàäûâàåò øâû.")
														wait(1500)
														sampSendChat("/me îáðåçàë"..a.." íèòü è óáðàë"..a.." èãëó")
														wait(1500)
														sampSendChat("/me íàëîæèë"..a.." íà ðàíó ìàðëåâóþ ïîâÿçêó")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
												end



												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Ìåä.êàðòà", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_mc[playerid] = not menu_mc[playerid] -- âêë âûêë ìåíþ
													menu_heal = {}
													menu_healdisease = {}
													menu_healwound = {}
													menu_setsex = {}
												end
												if menu_mc[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Ïîïðîñèòü ïàñïîðò", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("Ïåðåä òåì êàê íà÷àòü, ìíå íåîáõîäèìî ïðîâåðèòü..")
														wait(1500)
														sampSendChat("..Âàø ïàñïîðò. Ïðåäúÿâèòå Âàø ïàñïîðò â ðàçâåðíóòîì âèäå")
														wait(1500)
														sampSendChat("/b /showpass "..myid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Âûäàòü ìåä.êàðòó", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("Ñåé÷àñ ìû çàâåäåì ìåä. êàðòó íà Âàøå èìÿ")
														wait(1500)
														sampSendChat("/me äîñòàë"..a.." áëàíê ìåäèöèíñêîé êàðòû")
														wait(1500)
														sampSendChat("/me âíåñ(ëà) äàííûå ïàöèåíòà")
														wait(1500)
														sampSendChat("/givemc "..playerid)
														wait(1500)
														sampSendChat("/me ïåðåäàë"..a.." êàðòó "..targetname.." "..targetsurname)
														wait(1500)
														sampSendChat("/b /showmc ID - ïîêàçàòü ìåä.êàðòó")
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Íàéòè ìåä.êàðòó", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("Ìèíóòó. Ñåé÷àñ ÿ îçíàêîìëþñü ñ Âàøåé ìåäêàðòîé")
														wait(1500)
														sampSendChat("/me äîñòàë"..a.." ïëàíøåòíûé êîìïüþòåð")
														wait(1500)
														sampSendChat("/me íà÷àë"..a.." ïîèñê ìåäêàðòû íà èìÿ "..targetname.." "..targetsurname)
														wait(1500)
														sampSendChat("/findmc "..nick)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Èíôî î îòìåòêå ãîäíîñòè", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("Åñëè Âû õîòèòå ïîëó÷èòü â ìåä. êàðòó ïå÷àòü...")
														wait(1500)
														sampSendChat("..î ãîäíîñòè ê âîèíñêîé ñëóæáå...")
														wait(1500)
														sampSendChat("...íåîáõîäèìî ïðîéòè äîïîëíèòåëüíóþ ìåä.êîìèññèþ")
														wait(1500)
														sampSendChat("Ñòîèìîñòü òåñòà - 5000 âèðò. Ïðîèçâîäèòñÿ íàëè÷íûìè âðà÷ó")
														wait(1500)
														sampSendChat("/b /pay "..myid.." 5000")
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Òåñò äëÿ îòìåòêè ãîäíîñòè", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me äîñòàë"..a.." ýêñïðåññ-òåñò")
														wait(1500)
														sampSendChat("/do Äîêòîð âçÿë(a) àíàëèç êðîâè ïàöèåíòà.")
														wait(1500)
														sampSendChat("/me ïðîâåë"..a.." ýêñïðåññ-òåñò íà áîëåçíè")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
														wait(300)
														sampAddChatMessage("{ff0000}Íå ãîäåí {ffffff}åñëè:", 0xFFFFFFFF)
														sampAddChatMessage("{ffffff}Íàðêîçàâèñèìîñòü, àëêîãîëèçì - 1 ñòàäèÿ è âûøå", 0xFFFFFFFF)
														sampAddChatMessage("{ffffff}Ãðèïï, áðîíõèò, ìèêîç, ýíöåôàëèò - 3 ñòàäèÿ è âûøå", 0xFFFFFFFF)
														sampAddChatMessage("{ffffff}Îòðàâëåíèå - 3 ñòàäèÿ è âûøå", 0xFFFFFFFF)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Îòìåòêà{00a100}[ÃÎÄÅÍ]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/do Ýêñïðåññ-òåñò: Ðåçóëüòàò: îòðèöàòåëüíûé | Ãîäåí äëÿ ñëóæáû.")
														wait(1500)
														sampSendChat("Ïîçäðàâëÿþ, âû ãîäíû ê âîèíñêîé ñëóæáå")
														wait(1500)
														sampSendChat("/me âíåñ"..la.." äàííûå â ìåäêàðòó")
														wait(1500)
														sampSendChat("/me ïåðåäàë"..a.." ìåäêàðòó "..targetname.." "..targetsurname)
														wait(1500)
														sampSendChat("/updatemc "..playerid.." 1")
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Îòìåòêà{ff0000}[ÍÅ ÃÎÄÅÍ]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/do Ýêñïðåññ-òåñò: Ðåçóëüòàò: ïîëîæèòåëüíûé | Íå ãîäåí äëÿ ñëóæáû.")
														wait(1500)
														sampSendChat("Ó Âàñ ïîëîæèòåëüíûé ðåçóëüòàò. Âàì íåîáõîäèìî ïðîéòè ëå÷åíèå")
														wait(1500)
														sampSendChat("/me âíåñ"..la.." äàííûå â ìåäêàðòó")
														wait(1500)
														sampSendChat("/me ïåðåäàë"..a.." ìåäêàðòó "..targetname.." "..targetsurname)
														wait(1500)
														sampSendChat("/updatemc "..playerid.." 0")
													end
												end

												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Ñòðàõîâàíèå ïàöèåíòà", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													wait(250)
													sampSetCursorMode(0)
													sampSendChat("Ñåé÷àñ ÿ âíåñó Âàøè äàííûå â ñòðàõîâîé ïîëèñ")
													wait(1500)
													sampSendChat("/me äîñòàë"..a.." ýëåêòðîííûé ïëàíøåò èç êàðìàíà")
													wait(1500)
													sampSendChat("/me âîøåë"..a.." â ñèñòåìó áàçû äàííûõ ìèíèñòåðñòâà çäðàâîîõðàíåíèÿ")
													wait(1500)
													sampSendChat("/me âïèñàë"..a.." äàííûå ïàöèåíòà â ýëåêòðîííûé ñòðàõîâîé ïîëèñ")
													wait(1500)
													sampSendChat("/do Îôîðìëåíà çàÿâêà íà èìÿ "..targetname.." "..targetsurname)
													wait(1500)
													sampSendChat("/do Ó ñòîëà ñòîèò êîìïàêòíûé òåðìèíàë.")
													wait(1500)
													sampSendChat("Ïðîèçâåäèòå îïëàòó ïóòåì ïðèëîæåíèÿ Âàøåé êàðòî÷êè")
													wait(1500)
													sampSendChat("/healwound "..playerid)
												end

												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Ñìåíà ïîëà", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_setsex[playerid] = not menu_setsex[playerid] -- âêë âûêë ìåíþ
													menu_heal = {}
													menu_healdisease = {}
													menu_mc = {}
													menu_healwound = {}
												end
												if menu_setsex[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Íà ìóæñêîé", X3 + 45, Y3, 0xFF0048ff, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ïðèãîòîâèë"..a.." ñòåðèëüíûå èíñòðóìåíòû")
														wait(1500)
														sampSendChat("/me ïðèãîòîâèë"..a.." íàðêîç")
														wait(1500)
														sampSendChat("/me îòûñêàë"..a.." íà ðóêå ïàöèåíòà ïåðèôåðè÷åñêóþ âåíó")
														wait(1500)
														sampSendChat("/me ââåë"..a.." êàòåòåð è ïîñòàâèë"..a.." êëèïñó íà ïàëåö")
														wait(1500)
														sampSendChat("/me äîñòàë"..a.." èíãàëÿöèîííóþ ìàñêó")
														wait(1500)
														sampSendChat("/me íàäåë"..a.." ìàñêó íà ëèöî ïàöèåíòà")
														wait(1500)
														sampSendChat("/do Ïàöèåíò íàõîäèòñÿ ïîä íàðêîçîì.")
														wait(1500)
														sampSendChat("/me óäàëèë"..a.." ÿè÷íèêè è ôàëëîïèåâû òðóáû")
														wait(1500)
														sampSendChat("/me ñíÿë"..a.." ìàñêó ñ ëèöà ïàöèåíòà")
														wait(1500)
														sampSendChat("/me îòêëþ÷èë"..a.." ïîäà÷ó íàðêîçà")
														wait(1500)
														sampSendChat("/do Îïåðàöèÿ îâàðèýêòîìèÿ ïðîøëà óñïåøíî.")
														wait(1500)
														sampSendChat("/setsex "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Íà æåíñêèé", X3 + 45, Y3, 0xFFff477e, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ïðèãîòîâèë"..a.." ñòåðèëüíûå èíñòðóìåíòû")
														wait(1500)
														sampSendChat("/me ïðèãîòîâèë"..a.." íàðêîç")
														wait(1500)
														sampSendChat("/me íàøåë"..a.." íà ðóêå ïàöèåíòà ïåðèôåðè÷åñêóþ âåíó")
														wait(1500)
														sampSendChat("/me ââåë"..a.." êàòåòåð è ïîñòàâèë"..a.." êëèïñó íà ïàëåö")
														wait(1500)
														sampSendChat("/me äîñòàë"..a.." èíãàëÿöèîííóþ ìàñêó")
														wait(1500)
														sampSendChat("/me íàäåë"..a.." ìàñêó íà ëèöî ïàöèåíòà")
														wait(1500)
														sampSendChat("/do Ïàöèåíò íàõîäèòñÿ ïîä íàðêîçîì.")
														wait(1500)
														sampSendChat("/me äîñòàë"..a.." èíñòðóìåíòû")
														wait(1500)
														sampSendChat("/me ðàçðåçàë"..a.." è óäàëèë"..a.." ìóæñêèå ïîëîâûå îãðàíû")
														wait(1500)
														sampSendChat("/me ñôîðìèðîâàë"..a.." æåíñêèå ïîëîâûå îðãàíû")
														wait(1500)
														sampSendChat("/me ñíÿë"..a.." ìàñêó ñ ëèöà ïàöèåíòà")
														wait(1500)
														sampSendChat("/me îòêëþ÷èë"..a.." ïîäà÷ó íàðêîçà")
														wait(1500)
														sampSendChat("/do Îïåðàöèÿ ïðîøëà óñïåøíî.")
														wait(1500)
														sampSendChat("/setsex "..playerid)
													end
												end

											end

											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "Íå îòûãðûâàòü", X3 + 15, Y3, 0xFFfc4e4e, 0xFFFFFFFF) then
												menu_1no[playerid] = not menu_1no[playerid] -- âêë âûêë ìåíþ
												menu_1o = {}
											end

											if menu_1no[playerid] then
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Ëå÷åíèå", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/heal "..playerid)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Áîëåçíè è Çàâèñèìîñòè", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/healdisease "..playerid)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Ñòðàõîâêà è Çàùèòà", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/healwound "..playerid)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Âûäàòü ìåä.êàðòó", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/givemc "..playerid)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Íàéòè ìåä.êàðòó", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/findmc "..nick)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Ãîäåí", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/updatemc "..playerid.." 1")
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Íå ãîäåí", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/updatemc "..playerid.." 0")
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Ñìåíèòü ïîë", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/setsex "..playerid)
												end
											end
										end

										Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
										if ClickTheText(font, "Äëÿ ðóê-âà (7+)", X3, Y3, 0xFF5e5e5e, 0xFF4a4a4a) then
											menu_2[playerid] = not menu_2[playerid] -- âêë âûêë ìåíþ
											menu_1 = {}
											menu_1o = {}
											menu_1no = {}
										end

										if menu_2[playerid] then
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "Îíëàéí", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/tr "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(10)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "×åêíóòü âûãîâîðû", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/rep "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "Âûäàòü âûãîâîð", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/rep add "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "Óáðàòü âûãîâîð", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/rep del "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "×åêíóòü ×Ñ", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/bl "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "Äîáàâèòü â ×Ñ", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/bl add "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "Óáðàòü èç ×Ñ", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/bl del "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "Ëîãè", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
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
											sampSendChat("/do Íà ïîÿñå äîêòîðà ìåä.ñóìêà.")
											wait(1000)
											sampSendChat("/me äîñòàë"..a.." ïëàñòèíó àñïèðèíà è ìàëåíüêóþ áóòûëêó âîäû")
											wait(1000)
											sampSendChat("/me âûäàâèë"..a.." èç ïëàñòèíû òàáëåòêó")
											wait(1000)
											sampSendChat("/me ïåðåäàë"..a.." áóòûëêó âîäû âìåñòå ñ òàáëåòêîé")
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

sex = "{0328fc}Ìóæñêîé"
a = ""
la = ""
if ini.Settings.sex == true then
	sex = "{0328fc}Ìóæñêîé"
elseif ini.Settings.sex == false then
	sex = "{ff459c}Æåíñêèé"
	a = "à"
	la = "ëa"
end

function zp()
	if check_skin_local_player() then
		paycheck()
		local render_text = string.format("Çàðïëàòà:{008a00} %s", paycheck_money)
		if ClickTheText(font, render_text, ini.Settings.hud_x, ini.Settings.hud_y, 0xFFFFFFFF, 0xFFFFFFFF) then
		end
	end
end

function render_hud()
	if (isKeyDown(ini.Settings.Key) and check_skin_local_player()) then
		local render_text = string.format("[ÑÌÅÍÈÒÜ ÏÎÇÈÖÈÞ]", -1)
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
			local chatpostext = string.format("[ÑÌÅÍÈÒÜ ÏÎÇÈÖÈÞ]", -1)
			y = y + renderGetFontDrawHeight(font)
			if ClickTheText(fontPosButton, chatpostext, ini.Settings.ChatPosX, y, 0xFF969696, 0xFFFFFFFF) then
				medic_chat_pos = true
				wait(100)
			end
			local chatpostext = string.format("Ðàçìåð: "..ini.Settings.ChatFontSize, -1)
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
				sampSendChat("/seeme ïðîáîðìîòàë"..a.." ÷òî-òî â ðàöèþ")
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
			local render_text = string.format("Îñìîòðåíî: "..osmot, -1)
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
			local render_text = string.format("Ìåä.êàðò: "..medc, -1)
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
	if message:find("Âû çàðàáîòàëè %d+ âèðò. Äåíüãè áóäóò çà÷èñëåíû íà âàø áàíêîâñêèé ñ÷åò â") then
		local number = message:match("Âû çàðàáîòàëè (%d+) âèðò. Äåíüãè áóäóò çà÷èñëåíû íà âàø áàíêîâñêèé ñ÷åò â")
		if os.time() - paycheck_antiflood <= 1 then
			paycheck_money = number
			return false
		end
	end
	if message:find('Íå ôëóäè!') then
        return false
    end
	if message:match("Ìåäèê "..mynick.." âûëå÷èë .+") then
		osmot = osmot + 1
	end
	if message:match("Ìåäêàðòà îáíîâëåíà") then
		medc = medc + 1
	end
	if message:match("Ìåäêàðòà ñîçäàíà") then
		medc = medc + 1
	end
	if message:match("Âû âûëå÷èëè ïàöèåíòà .+") then
		osmot = osmot + 1
	end
	if message:match("Ïàöèåíò âûëå÷åí îò áîëåçíè .+") then
		osmot = osmot + 1
	end
	if message:match("Ñåàíñ ëå÷åíèÿ îò áîëåçíè .+") then
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


	if message:find(" Âñåãî ñåàíñîâ ó ýòîãî ïàöèåíòà: (%d+) / (%d+)") then
		local number1, number2 = message:match(" Âñåãî ñåàíñîâ ó ýòîãî ïàöèåíòà: (%d+) / (%d+)")
		local ostalnum = number2 - number1
			lua_thread.create(function()
				sampSendChat("/b Åùå "..ostalnum.." óêîë(à/îâ)")
				wait(500)
				sampSendChat("/b Ñëåäóþùèé óêîë ïîñëå PayDay")
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
				toggletext = "{33bf00}Âêë"
				if check_skin_local_player() then
					for k,v, pk, tl in pairs(timers_warn, timers_warnoff) do
						if warn == false and  time == v then
							sampSetCursorMode(0)
							sampAddChatMessage("{ff263c}[Medic] {FFFFFF}Àâòîìàòè÷åñêèé äîêëàä ÷åðåç 15 ñåê", -1)
							warn = true
						elseif time == tl then
							warn = false
						end
					end
					for d,lu, hp, yu in pairs(timers_doklads, timers_dokladsoff) do
						if doklad == false and time == lu then
							if location == " " then
								sampSetCursorMode(0)
								sampSendChat("/seeme ïðîáîðìîòàë"..a.." ÷òî-òî â ðàöèþ")
								sampSetChatInputText("/r "..ini.Info.tag.." | Ðåãèñòðàòóðà: "..ini.Info.reg.." | Îñìîòðåíî: "..osmot.." | Ìåä.êàðò: "..medc.." | Íàïàðíèê: "..partners.."")
								sampSetChatInputEnabled(true)
							else
								sampSetCursorMode(0)
								sampSendChat("/seeme ïðîáîðìîòàë"..a.." ÷òî-òî â ðàöèþ")
								sampSetChatInputText("/r "..ini.Info.tag.." | "..location.." | Îñìîòðåíî: "..osmot.." | Ìåä.êàðò: "..medc.." | Íàïàðíèê: "..partners.."")
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
						sampAddChatMessage("{ff263c}[Medic] {FFFFFF}Ïîðà äåëàòü äîêëàä", -1)
						warn = true
					elseif time == yz then
						warn = false
					end
				end
				toggletext = "{ff0000}Âûêë"
			end
		end)
	end
end

partners = "-"
function partner()
	lua_thread.create(function()
		if check_skin_local_player() then
			local partner_text = string.format("Íàïàðíèê: "..partners)
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

			--Àâòîâîêçàë ËÑ
			local avls1x = 1292
			local avls1y = -1718
			local avls1z = 13

			local avls2x = 1045
			local avls2y = -1843
			local avls2z = 30

			--Ìýðèÿ
			local may1x = 1394
			local may1y = -1868
			local may1z = 13

			local may2x = 1564
			local may2y = -1738
			local may2z = 30

			--Ôåðìà 0
			local farm01x = -592
			local farm01y = -1288
			local farm01z = 0

			local farm02x = -212
			local farm02y = -1500
			local farm02z = 30

			--ÀØ
			local ash1x = -2013
			local ash1y = -76
			local ash1z = 30

			local ash2x = -2095
			local ash2y = -280
			local ash2z = 50

			--Àâòîâîêçàë ÑÔ
			local sfav1x = -2001
			local sfav1y = 218
			local sfav1z = 10

			local sfav2x = -1923
			local sfav2y = 72
			local sfav2z = 50

			--ÒÏ
			local tp1x = -1997
			local tp1y = 536
			local tp1z = 30

			local tp2x = -1907
			local tp2y = 598
			local tp2z = 50

			--Îðóæåéíûé çàâîä
			local ozav1x = -2009
			local ozav1y = -196
			local ozav1z = 30

			local ozav2x = -2201
			local ozav2y = -280
			local ozav2z = 50

			--Êàçèíî
			local kaz1x = 2158
			local kaz1y = 2203
			local kaz1z = 0

			local kaz2x = 2363
			local kaz2y = 2027
			local kaz2z = 50

			--Àâòîâîêçàë ËÂ
			local avlv1x = 2859
			local avlv1y = 1382
			local avlv1z = 0

			local avlv2x = 2758
			local avlv2y = 1224
			local avlv2z = 50

			--ËÑ
			local ls1x = 2930
			local ls1y = -2740
			local ls1z = 0

			local ls2x = 50
			local ls2y = -890
			local ls2z = 250

			--ÑÔ
			local sf1x = -1344
			local sf1y = -1065
			local sf1z = 250

			local sf2x = -2981
			local sf2y = 1487
			local sf2z = 0

			--ËÂ
			local lv1x = 842
			local lv1y = 2947
			local lv1z = 250

			local lv2x = 2970
			local lv2y = 570
			local lv2z = 0

			if isCharInArea3d(PLAYER_PED, avls1x, avls1y, avls1z, avls2x, avls2y, avls2z) == true then
				location = "Ïîñò: Àâòîâîêçàë ËÑ"
			elseif isCharInArea3d(PLAYER_PED, may1x, may1y, may1z, may2x, may2y, may2z) == true then
				location = "Ïîñò: Ìýðèÿ"
			elseif isCharInArea3d(PLAYER_PED, farm01x, farm01y, afarm01z, farm02x, farm02y, farm02z) == true then
				location = "Ïîñò: Ôåðìà 0"
			elseif isCharInArea3d(PLAYER_PED, ash1x, ash1y, ash1z, ash2x, ash2y, ash2z) == true then
				location = "Ïîñò: Àâòîøêîëà"
			elseif isCharInArea3d(PLAYER_PED, sfav1x, sfav1y, sfav1z, sfav2x, sfav2y, sfav2z) == true then
				location = "Ïîñò: Àâòîâîêçàë ÑÔ"
			elseif isCharInArea3d(PLAYER_PED, tp1x, tp1y, tp1z, tp2x, tp2y, tp2z) == true then
				location = "Ïîñò: Òîðãîâàÿ ïëîùàäêà"
			elseif isCharInArea3d(PLAYER_PED, ozav1x, ozav1y, ozav1z, ozav2x, ozav2y, ozav2z) == true then
				location = "Ïîñò: Îðóæåéíûé çàâîä"
			elseif isCharInArea3d(PLAYER_PED, kaz1x, kaz1y, kaz1z, kaz2x, kaz2y, kaz2z) == true then
				location = "Ïîñò: Êàçèíî"
			elseif isCharInArea3d(PLAYER_PED, avlv1x, avlv1y, avlv1z, avlv2x, avlv2y, avlv2z) == true then
				location = "Ïîñò: Àâòîâîêçàë ËÂ"
			elseif isCharInArea3d(PLAYER_PED, ls1x, ls1y, ls1z, ls2x, ls2y, ls2z) == true then
				location = "Ïàòðóëü: LS"
			elseif isCharInArea3d(PLAYER_PED, sf1x, sf1y, sf1z, sf2x, sf2y, sf2z) == true then
				location = "Ïàòðóëü: SF"
			elseif isCharInArea3d(PLAYER_PED, lv1x, lv1y, lv1z, lv2x, lv2y, lv2z) == true then
				location = "Ïàòðóëü: LV"
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
