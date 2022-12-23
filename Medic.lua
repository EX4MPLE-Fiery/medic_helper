script_name('Medic')
script_authors("Galileo_Galilei, Serhiy_Rubin")
script_version("1.8.2")
local setcfg, ffi = require 'inicfg', require("ffi")
local infocfg = require 'inicfg'
local sampev = require "lib.samp.events"
local wm = require('windows.message')
local vkeys = require 'Medic.vkeys'
local encoding = require "Medic.encoding"
local imgui = require 'Medic.imgui'
local myinfo_window = imgui.ImBool(false)
local settings_window = imgui.ImBool(false)
encoding.default = 'CP1251'
u8 = encoding.UTF8
local rkeys = require 'Medic.rkeys'
imgui.HotKey = require('Medic.imgui_addons').HotKey
imgui.ToggleButton = require('Medic.imgui_addons').ToggleButton

local r = { mouse = false, ShowClients = false, ShowCMD = false, id = 0, nick = "", dir = "", dialog = 0 }
local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'Обнаружено обновление. Пытаюсь обновиться c '..thisScript().version..' на '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('Загружено %d из %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('Загрузка обновления завершена.')sampAddChatMessage(b..'Обновление завершено!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'Обновление прошло неудачно. Запускаю устаревшую версию..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': Обновление не требуется.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': Не могу проверить обновление. Смиритесь или проверьте самостоятельно на '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, выходим из ожидания проверки обновления. Смиритесь или проверьте самостоятельно на '..c)end end}]])
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
local set = setcfg.load({
Settings = {
	Enable = true,
	SkinButton = true,
	FontName = 'Arial',
	FontSize = 11,
	FontFlag = 13,
	Color1 = "FFFFFF",
	Color2 = "e89f00",
	hud_x = 1.0,
	hud_y = 1.0,
	hudtoggle = true,
	zptoggle = true,
	ChatPosX = 1.0,
	ChatPosY = 1.0,
	ChatFontSize = 11,
	ChatFontName = 'Arial',
	ChatFontFlag = 13,
	ChatToggle = true,
	ChatAnsToggle = true,
	AutoTag = true,
	AutoClist = true,
	AllToggle = true,
},
})
if setcfg.load(nil, "MedicSettings") == nil then setcfg.save(set, "MedicSettings") end
local set = setcfg.load(nil, "MedicSettings")

local info = infocfg.load({
Info = {
	ranknum = 0,
	rank = "Мед.Работник",
	clist = "18",
	tag = "Student MoH",
	tagnum = 0,
	reg = "SFMC",
	regnum = 1,
	sex = true,
	Key = vkeys.VK_RBUTTON,
}
})
if infocfg.load(nil, "MedicInfo") == nil then infocfg.save(info, "MedicInfo") end
local info = infocfg.load(nil, "MedicInfo")

ActiveMenu = {
	v = {info.Info.Key}
}
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

local sw, sh = getScreenResolution()
local autodokladtoggle = imgui.ImBool(false)
local zptoggle = imgui.ImBool(set.Settings.zptoggle)
local hudtoggle = imgui.ImBool(set.Settings.hudtoggle)
local chattoggle = imgui.ImBool(set.Settings.ChatToggle)
local autotagtogglebutton = imgui.ImBool(set.Settings.AutoTag)
local autoclisttoggle = imgui.ImBool(set.Settings.AutoClist)
local FontSizeInput = imgui.ImBuffer(256)
local alltogglebutton = imgui.ImBool(set.Settings.AllToggle)
local Sextogglebutton = imgui.ImBool(info.Info.sex)
local rankbox = imgui.ImInt(info.Info.ranknum)
local tagbox = imgui.ImInt(info.Info.tagnum)
local regbox = imgui.ImInt(info.Info.regnum)

if info.Info.sex then
	a = ""
	la = ""
else
	a = "а"
	la = "лa"
end

function imgui.OnDrawFrame()
    local tLastKeys = {}
	if not settings_window.v and not myinfo_window.v then
		imgui.Process = false
	end

    if settings_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(250, 300), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh /2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8'Настройки', settings_window)

			imgui.Text(u8"Сменить клавишу:")
			imgui.SameLine()
			if imgui.HotKey("##active", ActiveMenu, tLastKeys, 100) then
				rkeys.changeHotKey(bindID, ActiveMenu.v)
				sampAddChatMessage("{ff263c}[Medic] {ffffff}Старое значение: " .. table.concat(rkeys.getKeysName(tLastKeys.v), " + ") .. " | Новое: " .. table.concat(rkeys.getKeysName(ActiveMenu.v), " + "), -1)
				info.Info.Key = vkeys.name_to_id(table.concat(rkeys.getKeysName(ActiveMenu.v)))
				infocfg.save(info, "MedicInfo")
			end
			imgui.Separator()

			imgui.Text(u8"Cпособ активации:")
			imgui.SameLine()
			if imgui.ToggleButton("alltogglebutton", alltogglebutton) then
				set.Settings.AllToggle = not set.Settings.AllToggle
				setcfg.save(set, "MedicSettings")
				if set.Settings.AllToggle then
					sampAddChatMessage("Способ активации: {33bf00}Зажатие", -1)
				else
					sampAddChatMessage("Способ активации: {ff0000}Переключение", -1)
				end
			end
			imgui.Separator()
			
			imgui.Text(u8"Автодоклады:")
			imgui.SameLine()
			if imgui.ToggleButton("autodokladtoggle", autodokladtoggle) then
				toggle = not toggle
				if toggle then
					sampAddChatMessage("Автодоклады: {33bf00}Вкл", -1)
				else
					sampAddChatMessage("Автодоклады: {ff0000}Выкл", -1)
				end
			end
			imgui.Separator()

			imgui.Text(u8"Зар.плата:")
			imgui.SameLine()
			if imgui.ToggleButton("zptoggle", zptoggle) then
				set.Settings.zptoggle = not set.Settings.zptoggle
				setcfg.save(set, "MedicSettings")
				if set.Settings.zptoggle then
					sampAddChatMessage("Зар.плата: {33bf00}Вкл", -1)
				else
					sampAddChatMessage("Зар.плата: {ff0000}Выкл", -1)
				end
			end
			imgui.Separator()

			imgui.Text(u8"HUD:")
			imgui.SameLine()
			if imgui.ToggleButton("hudtoggle", hudtoggle) then
				set.Settings.hudtoggle = not set.Settings.hudtoggle
				setcfg.save(set, "MedicSettings")
				if set.Settings.hudtoggle then
					sampAddChatMessage("HUD: {33bf00}Вкл", -1)
				else
					sampAddChatMessage("HUD: {ff0000}Выкл", -1)
				end
			end
			imgui.Separator()

			imgui.Text(u8"Отдельный чат рации:")
			imgui.SameLine()
			if imgui.ToggleButton("chattoggle", chattoggle) then
				set.Settings.ChatToggle = not set.Settings.ChatToggle
				setcfg.save(set, "MedicSettings")
				if set.Settings.ChatToggle then
					sampAddChatMessage("Отдельный чат рации: {33bf00}Вкл", -1)
				else
					sampAddChatMessage("Отдельный чат рации: {ff0000}Выкл", -1)
				end
			end
			imgui.Separator()

			imgui.Text(u8"[AUTO]TAG:")
			imgui.SameLine()
			if imgui.ToggleButton("autotagtoggle", autotagtogglebutton) then
				set.Settings.AutoTag = not set.Settings.AutoTag
				setcfg.save(set, "MedicSettings")
				if set.Settings.AutoTag then
					sampAddChatMessage("[AUTO]TAG: {33bf00}Вкл", -1)
				else
					sampAddChatMessage("[AUTO]TAG: {ff0000}Выкл", -1)
				end
			end
			imgui.Separator()

			imgui.Text(u8"[AUTO]CLIST:")
			imgui.SameLine()
			if imgui.ToggleButton("autoclisttoggle", autoclisttoggle) then
				set.Settings.AutoClist = not set.Settings.AutoClist
				setcfg.save(set, "MedicSettings")
				if set.Settings.AutoClist then
					sampAddChatMessage("[AUTO]CLIST: {33bf00}Вкл", -1)
				else
					sampAddChatMessage("[AUTO]CLIST: {ff0000}Выкл", -1)
				end
			end
			imgui.Separator()

			imgui.Text(u8"[FONT]Размер:")
			imgui.SameLine()
			imgui.PushItemWidth(100)
			imgui.InputText(u8"", FontSizeInput)
			if imgui.Button(u8"Сохранить") then
				lua_thread.create(function()
					for n in u8:decode(FontSizeInput.v):gmatch('[^\r\n]+') do
						set.Settings.FontSize = n
						setcfg.save(set, "MedicSettings")
						thisScript():reload()
					end
				end)
			end
			imgui.Separator()
			

	  	imgui.End()
    end

	if myinfo_window.v then
		imgui.SetNextWindowSize(imgui.ImVec2(300, 300), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2((sw / 2), sh /2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.Begin(u8'Мои данные', myinfo_window)

			imgui.Text(u8"Пол:")
			imgui.SameLine()
			if imgui.ToggleButton("Sextogglebutton", Sextogglebutton) then
				info.Info.sex = not info.Info.sex
				infocfg.save(info, "MedicInfo")
				if info.Info.sex then
					sampAddChatMessage("Вы выбрали пол: {0328fc}Мужской", -1)
				else
					sampAddChatMessage("Вы выбрали пол: {ff459c}Женский", -1)
				end
			end
			imgui.Separator()

			imgui.Text(u8"Должность:")
			imgui.SameLine()
			if imgui.Combo("###1", rankbox, {u8'[1] Мед.Работник', u8'[2] Ст.Мед.Работник', u8'[3] Фельдшер', u8'[4] Интерн', u8'[5] Нарколог', u8'[6] Психиатр', u8'[9] Терапевт', u8'[8] Хирург', u8'[9] Зам Глав.Врача', u8'[10] Глав.Врач'}, 10) then
				if rankbox.v == 0 then
					info.Info.rank = "Мед.Работник"
					info.Info.ranknum = 1
					infocfg.save(info, "MedicInfo")
				elseif rankbox.v == 1 then
					info.Info.rank = "Ст.Мед.Работник"
					info.Info.ranknum = 1
					infocfg.save(info, "MedicInfo")
				elseif rankbox.v == 2 then
					info.Info.rank = "Фельдшер"
					info.Info.ranknum = 2
					infocfg.save(info, "MedicInfo")
				elseif rankbox.v == 3 then
					info.Info.rank = "Интерн"
					info.Info.ranknum = 3
					infocfg.save(info, "MedicInfo")
				elseif rankbox.v == 4 then
					info.Info.rank = "Нарколог"
					info.Info.ranknum = 4
					infocfg.save(info, "MedicInfo")
				elseif rankbox.v == 5 then
					info.Info.rank = "Психиатр"
					info.Info.ranknum = 5
					infocfg.save(info, "MedicInfo")
				elseif rankbox.v == 6 then
					info.Info.rank = "Терапевт"
					info.Info.ranknum = 6
					infocfg.save(info, "MedicInfo")
				elseif rankbox.v == 7 then
					info.Info.rank = "Хирург"
					info.Info.ranknum = 7
					infocfg.save(info, "MedicInfo")
				elseif rankbox.v == 8 then
					info.Info.rank = "Зам Глав.Врача"
					info.Info.ranknum = 8
					infocfg.save(info, "MedicInfo")
				elseif rankbox.v == 9 then
					info.Info.rank = "Глав.Врач"
					info.Info.ranknum = 9
					infocfg.save(info, "MedicInfo")
				end
			end
			imgui.Separator()

			imgui.Text(u8"Tag:")
			imgui.SameLine()
			if imgui.Combo("###2", tagbox, {u8'Student MoH', u8'Agent ASGH', u8'Agent LVH', u8'Agent SFMC', u8'RH ASGH', u8'RH LVH', u8'RH SFMC', u8'Deputy AP', u8'Deputy CW', u8'Deputy GA', u8'Head of CC', u8'Head of CID', u8'Head of MoH'}, 13) then
				if tagbox.v == 0 then
					info.Info.tag = "Student MoH"
					info.Info.tagnum = 0
					info.Info.clist = 18
					infocfg.save(info, "MedicInfo")
					sampSendChat("/clist "..info.Info.clist)
				elseif tagbox.v == 1 then
					info.Info.tag = "Agent ASGH"
					info.Info.tagnum = 1
					info.Info.clist = 3
					infocfg.save(info, "MedicInfo")
					sampSendChat("/clist "..info.Info.clist)
				elseif tagbox.v == 2 then
					info.Info.tag = "Agent LVH"
					info.Info.tagnum = 2
					info.Info.clist = 3
					infocfg.save(info, "MedicInfo")
					sampSendChat("/clist "..info.Info.clist)
				elseif tagbox.v == 3 then
					info.Info.tag = "Agent SFMC"
					info.Info.tagnum = 3
					info.Info.clist = 3
					infocfg.save(info, "MedicInfo")
					sampSendChat("/clist "..info.Info.clist)
				elseif tagbox.v == 4 then
					info.Info.tag = "RH ASGH"
					info.Info.tagnum = 4
					info.Info.clist = 14
					infocfg.save(info, "MedicInfo")
					sampSendChat("/clist "..info.Info.clist)
				elseif tagbox.v == 5 then
					info.Info.tag = "RH LVH"
					info.Info.tagnum = 5
					info.Info.clist = 24
					infocfg.save(info, "MedicInfo")
					sampSendChat("/clist "..info.Info.clist)
				elseif tagbox.v == 6 then
					info.Info.tag = "RH SFMC"
					info.Info.tagnum = 6
					info.Info.clist = 19
					infocfg.save(info, "MedicInfo")
					sampSendChat("/clist "..info.Info.clist)
				elseif tagbox.v == 7 then
					info.Info.tag = "Deputy AP"
					info.Info.tagnum = 7
					info.Info.clist = 12
					infocfg.save(info, "MedicInfo")
					sampSendChat("/clist "..info.Info.clist)
				elseif tagbox.v == 8 then
					info.Info.tag = "Deputy CW"
					info.Info.tagnum = 8
					info.Info.clist = 12
					infocfg.save(info, "MedicInfo")
					sampSendChat("/clist "..info.Info.clist)
				elseif tagbox.v == 9 then
					info.Info.tag = "Deputy GA"
					info.Info.tagnum = 9
					info.Info.clist = 12
					infocfg.save(info, "MedicInfo")
					sampSendChat("/clist "..info.Info.clist)
				elseif tagbox.v == 10 then
					info.Info.tag = "Head of CC"
					info.Info.tagnum = 10
					info.Info.clist = 12
					infocfg.save(info, "MedicInfo")
					sampSendChat("/clist "..info.Info.clist)
				elseif tagbox.v == 11 then
					info.Info.tag = "Head of CID"
					info.Info.tagnum = 11
					info.Info.clist = 12
					infocfg.save(info, "MedicInfo")
					sampSendChat("/clist "..info.Info.clist)
				elseif tagbox.v == 12 then
					info.Info.tag = "Head of MoH"
					info.Info.tagnum = 12
					info.Info.clist = 12
					infocfg.save(info, "MedicInfo")
					sampSendChat("/clist "..info.Info.clist)
				end
			end
			imgui.Separator()

			imgui.Text(u8"Больница:")
			imgui.SameLine()
			if imgui.Combo("###3", regbox, {u8'[ASGH] All Saints General Hospital', u8'[SFMC] San Fierro Medical Center', u8'[LVH] Las Venturas Hospital'}, 3) then
				if regbox.v == 0 then
					info.Info.reg = "ASGH"
					info.Info.regnum = 0
					infocfg.save(info, "MedicInfo")
				elseif regbox.v == 1 then
					info.Info.reg = "SFMC"
					info.Info.regnum = 1
					infocfg.save(info, "MedicInfo")
				elseif regbox.v == 2 then
					info.Info.reg = "LVH"
					info.Info.regnum = 2
					infocfg.save(info, "MedicInfo")
				end
			end
			imgui.Separator()
	  	imgui.End()
	end
end

function medic_myinfo()
	myinfo_window.v = not myinfo_window.v
	imgui.Process = myinfo_window.v
end

function medic_settings()
	settings_window.v = not settings_window.v
	imgui.Process = settings_window.v
end

alltoggle = false
function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end	

	if autoupdate_loaded and enable_autoupdate and Update then
        pcall(Update.check, Update.json_url, Update.prefix, Update.url)
    end

	sampAddChatMessage("{ff263c}[Medic] {ffffff}Скрипт успешно загружен. {fc0303}Версия: 1.8.2", -1)

	chatfont = renderCreateFont(set.Settings.FontName, set.Settings.ChatFontSize, set.Settings.FontFlag)
	font = renderCreateFont(set.Settings.FontName, set.Settings.FontSize, set.Settings.FontFlag)
	fontPosButton = renderCreateFont(set.Settings.FontName, set.Settings.FontSize - 2, set.Settings.FontFlag)
	fontChatPosButton = renderCreateFont(set.Settings.ChatFontName, set.Settings.ChatFontSize, set.Settings.ChatFontFlag)
	fontpmbuttons = renderCreateFont(set.Settings.FontName, set.Settings.FontSize + 2, set.Settings.FontFlag)

	sampRegisterChatCommand("medic_hud_pos",function()
		medic_hud_pos = true	
	end)

	sampRegisterChatCommand("medic_chat_pos",function()
		medic_chat_pos = true	
	end)

	sampRegisterChatCommand("medic", function()
		set.Settings.Enable = not set.Settings.Enable
		setcfg.save(set, "MedicSettings")
		thisScript():unload()
	end)

	while true do
		wait(0)

			if set.Settings.AutoClist then
				autoclist()
			end

			if set.Settings.AutoTag then
				sampRegisterChatCommand("r", function(tmsg) sampSendChat("/r "..info.Info.tag.." | "..tmsg) end)
			else
				sampUnregisterChatCommand("r", function(tmsg) sampSendChat("/r "..tmsg) end)
			end

			timer(toggle)
			if set.Settings.ChatToggle then
				render_chat()
			end

			if set.Settings.zptoggle then
				zp()
			end

			if set.Settings.hudtoggle then
				render_hud()
				counter()
				locations()
			end

			if set.Settings.AllToggle then
				if isKeyDown(info.Info.Key) then
					alltoggle = true
				else 
					alltoggle = false
				end
			else
				if wasKeyPressed(info.Info.Key) then
					alltoggle = not alltoggle
				end
			end

			if alltoggle and check_skin_local_player() then
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
					menu_doklad = false
				end
				showCursor(true)
				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Онлайн медики"
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
					sampSendChat("/members 1")
				end
				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Список вызовов"
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
					sampSendChat("/service")
				end
				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Быстрые команды"
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
					sampSendChat("/fmenu")
				end
				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Сменить больницу"
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
					sampSendChat("/spawnchange")
				end
				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Мои данные"
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
					medic_myinfo()
					menu_binds = false
					menu_doklad = false
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Настройки"
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
					medic_settings()
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Общие бинды"
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
						rtext = "Приветствие"
						if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
							wait(250)
							
							sampSendChat("/todo Здравствуйте! Я доктор "..surname.."! *улыбаясь")
							wait(1000)
							sampSendChat("/do На бейджике: "..info.Info.tag.." | Доктор "..surname.." | "..info.Info.rank.."")
							wait(1000)
							sampSendChat("Что Вас беспокоит?")
						end

						Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
						rtext = "Попросить следовать"
						if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
							wait(250)
							
							sampSendChat("Пройдёмте за мной")
						end

						Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
						rtext = "Прощание"
						if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
							wait(250)
							
							sampSendChat("Всего доброго и не болейте.")
							wait(1000)
							sampSendChat("Берегите себя и своих близких.")
						end

						Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
						rtext = "Надеть бейджик"
						if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
							wait(250)
							
							sampSendChat("/me достал"..a.." из кармана бейджик")
							wait(1000)
							sampSendChat("/me надел"..a.." бейджик")
							wait(1000)
							sampSendChat("/do На бейджике: "..info.Info.tag.." | Доктор "..surname.." | "..info.Info.rank.."")
							wait(1000)
							sampSendChat("/clist "..info.Info.clist.."")
						end

						Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
						rtext = "Поправить бейджик"
						if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
							wait(250)
							
							sampSendChat("/me поправил"..a.." бейджик")
							wait(1000)
							sampSendChat("/do На бейджике: "..info.Info.tag.." | Доктор "..surname.." | "..info.Info.rank.."")
							wait(1000)
							sampSendChat("/clist "..info.Info.clist.."")
						end

						Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
						rtext = "Занять регистратуру"
						if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
							if set.Settings.AutoTag then
								wait(250)
								
								sampSendChat("/seeme говорит в рацию")
								wait(0)
								sampSetChatInputText("/r Занимаю регистратуру "..info.Info.reg.."")
								sampSetChatInputEnabled(true)
							else
								wait(250)
								
								sampSendChat("/seeme говорит в рацию")
								wait(0)
								sampSetChatInputText("/r "..info.Info.tag.." | Занимаю регистратуру "..info.Info.reg.."")
								sampSetChatInputEnabled(true)
							end
						end

						Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
						rtext = "Покинуть регистратуру"
						if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
							if set.Settings.AutoTag then
								wait(250)
								
								sampSendChat("/seeme говорит в рацию")
								wait(0)
								sampSetChatInputText("/r Покидаю регистратуру "..info.Info.reg.."")
								sampSetChatInputEnabled(true)
							else
								wait(250)
								
								sampSendChat("/seeme говорит в рацию")
								wait(0)
								sampSetChatInputText("/r "..info.Info.tag.." | Покидаю регистратуру "..info.Info.reg.."")
								sampSetChatInputEnabled(true)
							end
							
						end

						Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
						rtext = "Транквилизатор (Deagle)[5+ ранг]"
						if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
							wait(250)
							
							sampSendChat("/do На поясе доктора закреплена кобура.")
							wait(1000)
							sampSendChat("/me достал"..a.." из кобуры пистолет с транквилизатором MP-53M")
							wait(1000)
							sampSendChat("/do Пистолет заряжен, поставлен на предохранитель.")
							wait(1000)
							sampSendChat("/do Дротики оснащены снотворным средством.")
							wait(1000)
							sampSendChat("/me снял"..a.." с предохранителя и отвёл"..a.." затвор")
						end
					end)
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Доклады"
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
						rtext = "С регистратуры"
						if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
							if set.Settings.AutoTag then
								wait(250)
								sampSendChat("/seeme делает доклад в рацию")
								wait(1500)
								sampSetChatInputText("/r Регистратура: "..info.Info.reg.." | Осмотрено: "..osmot.." | Мед.карт: "..medc.." | Напарник: -")
								sampSetChatInputEnabled(true)
							else
								wait(250)
								sampSendChat("/seeme делает доклад в рацию")
								wait(1500)
								sampSetChatInputText("/r "..info.Info.tag.." | Регистратура: "..info.Info.reg.." | Осмотрено: "..osmot.." | Мед.карт: "..medc.." | Напарник: -")
								sampSetChatInputEnabled(true)
							end
						end

						Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
						rtext = "С поста / с патруля"
						if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
							if set.Settings.AutoTag then
								wait(250)
								
								sampSendChat("/seeme делает доклад в рацию")
								wait(1500)
								sampSetChatInputText("/r "..location.." | Осмотрено: "..osmot.." | Бак: | Напарник: -")
								sampSetChatInputEnabled(true)
							else
								wait(250)
								
								sampSendChat("/seeme делает доклад в рацию")
								wait(1500)
								sampSetChatInputText("/r "..info.Info.tag.." | "..location.." | Осмотрено: "..osmot.." | Бак: | Напарник: -")
								sampSetChatInputEnabled(true)
							end
						end

						Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
						rtext = "С военкомата"
						if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
							if set.Settings.AutoTag then
								wait(250)
								
								sampSendChat("/seeme делает доклад в рацию")
								wait(1500)
								sampSetChatInputText("/r Военкомат:  | Осмотрено: "..osmot.." | Мед.карт: "..medc.." | Напарник: -")
								sampSetChatInputEnabled(true)
							else
								wait(250)
								
								sampSendChat("/seeme делает доклад в рацию")
								wait(1500)
								sampSetChatInputText("/r "..info.Info.tag.." | Военкомат:  | Осмотрено: "..osmot.." | Мед.карт: "..medc.." | Напарник: -")
								sampSetChatInputEnabled(true)
							end
						end

						Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
						rtext = "Принять вызов"
						if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
							if set.Settings.AutoTag then
								wait(250)
								
								sampSendChat("/seeme делает доклад в рацию")
								wait(1500)
								sampSendChat("/r Принял"..a.." вызов ")
							else
								wait(250)
								
								sampSendChat("/seeme делает доклад в рацию")
								wait(1500)
								sampSendChat("/r "..info.Info.tag.." | Принял"..a.." вызов ")
							end
						end
					end)
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "/r"
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y + 20, 0xFF8D8DFF, 0xFF8D8DFF) then
					if set.Settings.AutoTag then
						wait(250)
						
						sampSendChat("/seeme пробормотал"..a.." что-то в рацию")
						sampSetChatInputText("/r ")
						sampSetChatInputEnabled(true)
					else
						wait(250)
						
						sampSendChat("/seeme делает доклад в рацию")
						wait(1500)
						sampSendChat("/r "..info.Info.tag.." | ")
					end
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rbtext = "/rb"
				if ClickTheText(font, rbtext, (X - renderGetFontDrawTextLength(font, rbtext.."  ")), Y + 20, 0xFF8D8DFF, 0xFF8D8DFF) then
					wait(250)
					
					sampSetChatInputText("/rb ")
					sampSetChatInputEnabled(true)
				end
				if set.Settings.SkinButton then
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
										if set.Settings.SkinButton then
											X3, Y3 = convert3DCoordsToScreen(X3, Y3, Z3)
											Y3 = Y3 / 1.2
											X3 = X3 / 1.1
											JustText(font, nick1, X3, Y3,  "0xFF"..color, "0xFF"..color)
											
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "Мед. меню", X3, Y3, 0xffff0000, 0xFFFFFFFF) then
												menu_1[playerid] = not menu_1[playerid] -- вкл выкл меню
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
												if ClickTheText(font, "Отыграть", X3 + 15, Y3, 0xfffc4e4e, 0xFFFFFFFF) then
													menu_1o[playerid] = not menu_1o[playerid] -- вкл выкл меню
													menu_1no = {}
													menu_heal = {}
													menu_healdisease = {}
													menu_healwound = {}
													menu_mc = {}
													menu_setsex = {}
												end

												if menu_1o[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Лечение", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
														menu_heal[playerid] = not menu_heal[playerid] -- вкл выкл меню
														menu_healdisease = {}
														menu_healwoundper = {}
														menu_healwoundran = {}
														menu_mc = {}
														menu_setsex = {}
													end
													if menu_heal[playerid] then
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Головная боль", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/do На поясе доктора мед.сумка.")
															wait(1500)
															sampSendChat("/me достал"..a.." пластину аспирина и выдавил"..a.." таблетку")
															wait(1500)
															sampSendChat("/me налил"..a.." стакан воды и передал"..a.." пациенту  вместе с таблеткой")
															wait(1500)
															sampSendChat("/heal "..playerid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Насморк", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me внимательно осмотрел"..a.." состояние пациента")
															wait(1500)
															sampSendChat("/do на поясе доктора мед.сумка.")
															wait(1500)
															sampSendChat("У Вас насморк. Я выпишу Вам капли")
															wait(1500)
															sampSendChat("/me достал"..a.." из мед.сумки капли Лазолван")
															wait(1500)
															sampSendChat("/me передал"..a.." капли пациенту")
															wait(1500)
															sampSendChat("/heal "..playerid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Кашель", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/do На поясе доктора мед.сумка.")
															wait(1500)
															sampSendChat("/me осмотрел"..a.." пациента")
															wait(1500)
															sampSendChat("У вас сильный кашель. Я выпишу вам леденцы Доктор Мом")
															wait(1500)
															sampSendChat("/me достал"..a.." леденцы из мед.сумки")
															wait(1500)
															sampSendChat("/me передал"..a.." "..targetname.." "..targetsurname.." лекарство")
															wait(1500)
															sampSendChat("/heal "..playerid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Ломка/Опьянение", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me осмотрел"..a.." пациента")
															wait(1500)
															sampSendChat("/do На поясе доктора медсумка.")
															wait(1500)
															sampSendChat("/me открыл"..a.." сумку и достал"..a.." шприц с морфином")
															wait(1500)
															sampSendChat("/me ввел"..a.." полкубика морфина пациенту внутримышечно")
															wait(1500)
															sampSendChat("/heal "..playerid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Несварение", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me достал"..a.." из сумки пакетик с полисорбом")
															wait(1500)
															sampSendChat("/me налил"..a.." воду из бутылки в стакан")
															wait(1500)
															sampSendChat("/todo Выпейте это *передав стаканчик с разведенным в воде лекарством")
															wait(1500)
															sampSendChat("/heal "..playerid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Боли в животе", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("Я выпишу вам таблетки Ренни")
															wait(1500)
															sampSendChat("/do На поясе доктора мед.сумка.")
															wait(1500)
															sampSendChat("/me достал"..a.." пластинку таблеток Ренни из мед.сумки")
															wait(1500)
															sampSendChat("/me выписал"..a.." инструкцию по применению")
															wait(1500)
															sampSendChat("/me передал"..a.." инструкцию и пластинку пациенту")
															wait(1500)
															sampSendChat("/heal "..playerid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Геморрой", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("Выпишу вам свечи Релиф и назначу курс лечения")
															wait(1500)
															sampSendChat("/do На поясе доктора мед.сумка.")
															wait(1500)
															sampSendChat("/me вынул"..a.." упаковку ректальных свечей")
															wait(1500)
															sampSendChat("/me передал"..a.." пациенту свечи")
															wait(1500)
															sampSendChat("/me достал"..a.." из кармана бланк и ручку")
															wait(1500)
															sampSendChat("/me выписал"..a.." рецепт")
															wait(1500)
															sampSendChat("/me передал"..a.." пациенту рецепт")
															wait(1500)
															sampSendChat("/heal "..playerid)
														end
													end


													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Болезни и Зависимости", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
														menu_healdisease[playerid] = not menu_healdisease[playerid] -- вкл выкл меню
														menu_heal = {}
														menu_healwoundper = {}
														menu_healwoundran = {}
														menu_mc = {}
														menu_setsex = {}
													end
													if menu_healdisease[playerid] then
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Наркозависимость", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/todo Cожмите руку в кулак *затягивая жгут")
															wait(1500)
															sampSendChat("/me нащупал"..a.." вену локтевого сгиба")
															wait(1500)
															sampSendChat("/me набрал"..a.." вещество из ампулы в шприц")
															wait(1500)
															sampSendChat("/me ввел"..a.." лекарство внутривенно и снял"..a.." жгут")
															wait(1500)
															sampSendChat("/me вывел"..a.." иглу из вены и подставил"..a.." спиртовую ватку")
															wait(1000)
															sampSendChat("/healdisease "..playerid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Грипп", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("Сейчас я сделаю Вам укольчик биоксона.")
															wait(1500)
															sampSendChat("А также выпишу Вам Кагоцел")
															wait(1500)
															sampSendChat("Необходимо наблюдение врача не чаще раза в час")
															wait(1500)
															sampSendChat("/me достал"..a.." ампулу Биоксона")
															wait(1500)
															sampSendChat("/me набрал"..a.." биоксон в шприц")
															wait(1500)
															sampSendChat("/todo Расслабьтесь *протирая ваткой место укола")
															wait(1500)
															sampSendChat("/me ввел"..a.." раствор биоксона пациенту")
															wait(1500)
															sampSendChat("/todo Можете собираться *заполняя рецепт, передал"..a.." рецепт пациенту")
															wait(1500)
															sampSendChat("/healdisease "..playerid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Бронхит", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/do В руках врача стетоскоп.")
															wait(1500)
															sampSendChat("Оголите торс и подойдите ближе")
															wait(1500)
															sampSendChat("/me послушал"..a.." легкие пациента")
															wait(1500)
															sampSendChat("/todo Имеются хрипы в легких *убирая стетоскоп")
															wait(1500)
															sampSendChat("/me выписал"..a.." рецепт на Амброгексал и обильное теплое питьё")
															wait(1500)
															sampSendChat("/me передал"..a.." пациенту рецепт и медкарту")
															wait(1500)
															sampSendChat("/healdisease "..playerid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Отравление", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me достал"..a.." из медсумки упаковку активированного угля")
															wait(1500)
															sampSendChat("/me выдавил"..a.." несколько таблеток актив. угля")
															wait(1500)
															sampSendChat("/me передал"..a.." пациенту")
															wait(1500)
															sampSendChat("/healdisease "..playerid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Микоз", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me осмотрел"..a.." кожу пациента и обнаружил грибковые споры")
															wait(1500)
															sampSendChat("/me достал"..a.." из сумки мазь ламизил")
															wait(1500)
															sampSendChat("/me намазал"..a.." пораженный грибком участок кожи мазью")
															wait(1500)
															sampSendChat("/healdisease "..playerid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Клещевой энцефалит", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me достал"..a.." из сумки шприц и ампулу имуноглобулина")
															wait(1500)
															sampSendChat("/me набрал"..a.." вещество из ампулы в шприц")
															wait(1500)
															sampSendChat("/me ввел"..a.." препарат внутримышечно")
															wait(1500)
															sampSendChat("/healdisease "..playerid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Алкоголизм", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me осмотрел"..a.." общее состояние пациента")
															wait(1500)
															sampSendChat("/me достал"..a.." ручку и написал"..a.." лист назначений")
															wait(1500)
															sampSendChat("/do В руках доктора коробочка препарата «Тетурам».")
															wait(1500)
															sampSendChat("/me достал"..a.." пластинку и передал"..a.." пациенту")
															wait(1500)
															sampSendChat("/todo Пропейте курс согласно листу назначения*параллельно прикладывая к упаковке лист")
															wait(1500)
															sampSendChat("/healdisease "..playerid)
														end
													end

													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Переломы", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
														menu_healwoundper[playerid] = not menu_healwoundper[playerid]
														menu_healwoundran = {} -- вкл выкл меню
														menu_heal = {}
														menu_healdisease = {}
														menu_mc = {}
														menu_setsex = {}
													end
													if menu_healwoundper[playerid] then
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "1. Перелом[диагностика]", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me достал"..a.." новые виниловые перчатки и надел"..a.." их")
															wait(1500)
															sampSendChat("/me помог"..la.." пациенту лечь на операционный стол")
															wait(1500)
															sampSendChat("/b Залезайте на стол и /anim 22")
															wait(1500)
															sampSendChat("/me внимательно осмотрел"..a.." пациента")
															wait(1500)
															sampSendChat("/try обнаружил"..a.." открытый перелом")
															wait(300)
															sampAddChatMessage("{00a100}Удачно{FFFFFF} - Операция", 0xFFFFFFFF)
															sampAddChatMessage("{ff0000}Неудачно{FFFFFF} - Рентген", 0xFFFFFFFF)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "2. Операция{00a100}[Удачно]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me включил"..a.." рентген-аппарат")
															wait(1500)
															sampSendChat("/me сделал"..a.." снимок поврежденной конечности")
															wait(1500)
															sampSendChat("/do Спустя время снимок выведен на экран.")
															wait(1500)
															sampSendChat("/me внимательно изучил"..a.." снимок")
															wait(1500)
															sampSendChat("/me надел"..a.." на пациента ингаляционную маску")
															wait(1500)
															sampSendChat("/me ввёл"..a.." пациента в состояние общего наркоза")
															wait(1500)
															sampSendChat("/me скальпелем разрезал"..a.." плоть около поврежденной кости")
															wait(1500)
															sampSendChat("/me поджал"..a.." края плоти зажимом")
															wait(1500)
															sampSendChat("/try вправил"..a.." кость пациенту")
															wait(1500)
															sampAddChatMessage("{00a100}Удачно{FFFFFF} - Вправил", 0xFFFFFFFF)
															sampAddChatMessage("{ff0000}Неудачно{FFFFFF} - Невравил", 0xFFFFFFFF)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "3. Вправил{00a100}[Удачно]", X3 + 75, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me снял"..a.." зажимы")
															wait(1500)
															sampSendChat("/me взял"..a.." бионические нити и иглу")
															wait(1500)
															sampSendChat("/me наложил"..a.." шов на конечность")
															wait(1500)
															sampSendChat("/me вымочил"..a.." гипс в биксе кипяченной воды")
															wait(1500)
															sampSendChat("/me наложил"..a.." гипс на конечность")
															wait(1500)
															sampSendChat("/healwound "..playerid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "3. Невправил{ff0000}[Неудачно]", X3 + 75, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me прохрустел"..a.." пальцами, размяв руки")
															wait(1500)
															sampSendChat("/me приложил"..a.." больше усилий и успешно вправил"..a.." кость")
															wait(1500)
															sampSendChat("/me снял"..a.." зажимы")
															wait(1500)
															sampSendChat("/me взял"..a.." бионические нити и иглу")
															wait(1500)
															sampSendChat("/me наложил"..a.." шов на конечность")
															wait(1500)
															sampSendChat("/me вымочил"..a.." гипс в биксе кипяченной воды")
															wait(1500)
															sampSendChat("/me наложил"..a.." гипс на конечность")
															wait(1500)
															sampSendChat("/healwound "..playerid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "2. Рентген{ff0000}[Неудачно]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me включил"..a.." рентген аппарат")
															wait(1500)
															sampSendChat("/me сделал"..a.." снимок повреждённой конечности")
															wait(1500)
															sampSendChat("/do Спустя время снимок выведен на экран.")
															wait(1500)
															sampSendChat("/try увидел"..a.." на снимке перелом")
															wait(300)
															sampAddChatMessage("{00a100}Удачно{FFFFFF} - Закрытый", 0xFFFFFFFF)
															sampAddChatMessage("{ff0000}Неудачно{FFFFFF} - Ушиб", 0xFFFFFFFF)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "3. Закрытый{00a100}[Удачно]", X3 + 75, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me достал"..a.." шприц и ампулу обезболивающего")
															wait(1500)
															sampSendChat("/me набрал"..a.." обезболивающее в шприц")
															wait(1500)
															sampSendChat("/me ввел"..a.." обезболивающее пациенту")
															wait(1500)
															sampSendChat("/me вправил"..a.." кость")
															wait(1500)
															sampSendChat("/me наложил"..a.." повязку софткаст пациенту")
															wait(1500)
															sampSendChat("/healwound "..playerid)
															wait(1500)
															sampSendChat("/me выдал"..a.." пациенту костыли")
															wait(1500)
															sampSendChat("По началу будет неудобно, но, уверяю, вы справитесь")
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "3. Ушиб{ff0000}[Неудачно]", X3 + 75, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("Вам повезло, что обошлось без переломов")
															wait(1500)
															sampSendChat("Всего лишь ушиб")
															wait(1500)
															sampSendChat("/me достал"..a.." из медсумки тюбик мази")
															wait(1500)
															sampSendChat("/me нанес"..la.." на место ушиба мазь и растер"..la.." ее")
															wait(1500)
															sampSendChat("/me наложил"..a.." на место ушиба эластичный бинт")
															wait(1500)
															sampSendChat("/healwound "..playerid)
														end
													end

													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Ранения", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
														menu_healwoundran[playerid] = not menu_healwoundran[playerid]
														menu_healwoundper = {} -- вкл выкл меню
														menu_heal = {}
														menu_healdisease = {}
														menu_mc = {}
														menu_setsex = {}
													end
													if menu_healwoundran[playerid] then
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Раны(резаные, колотые, рубленые, рваные)", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("Ложитесь на стол, сейчас будете как новенький")
															wait(1500)
															sampSendChat("/me достал"..a.." из мед.сумки баночку зеленки")
															wait(1500)
															sampSendChat("/me продезинфецировал"..a.." рану пациента")
															wait(1500)
															sampSendChat("/me подготовил"..a.." всё для операции")
															wait(1500)
															sampSendChat("/do Всё необходимое лежит на столе.")
															wait(1500)
															sampSendChat("/me взял"..a.." в руки хирургические нити и иглу")
															wait(1500)
															sampSendChat("/do Доктор накладывает швы на рану.")
															wait(1500)
															sampSendChat("/me убрал"..a.." хирургические нити и иглу")
															wait(1500)
															sampSendChat("/me наложил"..a.." стерильную повязку на место шва")
															wait(1500)
															sampSendChat("/healwound "..playerid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Огнестрельные ранения", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me осмотрел"..a.." ранение пострадавшего")
															wait(1500)
															sampSendChat("/me достал"..a.." ампулу новокаина, шприц и набрал"..a.." новокаин в шприц")
															wait(1500)
															sampSendChat("/me ввёл"..a.." обезболивающее пациенту")
															wait(1500)
															sampSendChat("/me взял"..a.." скальпель и сделал"..a.." надрез в месте ранения")
															wait(1500)
															sampSendChat("/me положил"..a.." скальпель и взял"..a.." щипцы")
															wait(1500)
															sampSendChat("/try успешно извлёк"..la.." пулю")
															wait(300)
															sampAddChatMessage("{00a100}Удачно{FFFFFF} - Огнестрельное ранение{00a100}[Удачно]", 0xFFFFFFFF)
															wait(300)
															sampAddChatMessage("{ff0000}Неудачно{FFFFFF} - Огнестрельное ранение{ff0000}[Неудачно]", 0xFFFFFFFF)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Огнестрел{00a100}[Удачно]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me убрал"..a.." пулю в почкообразный контейнер")
															wait(1500)
															sampSendChat("/me взял"..a.." в руки хирургическую иглу и нить")
															wait(1500)
															sampSendChat("/do Доктор накладывает швы.")
															wait(1500)
															sampSendChat("/me оборвал"..a.." нить и убрал"..a.." иглу")
															wait(1500)
															sampSendChat("/me наложил"..a.." марлевую повязку на рану")
															wait(1500)
															sampSendChat("/healwound "..playerid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Огнестрел{ff0000}[Неудачно]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me положил"..a.." щипцы на место и взял"..a.." скальпель")
															wait(1500)
															sampSendChat("/me сделал"..a.." дополнительный надрез")
															wait(1500)
															sampSendChat("/me снова взял"..a.." щипцы и успешно извлёк(извлекла) пулю")
															wait(1500)
															sampSendChat("/me убрал"..a.." пулю в почкообразный контейнер")
															wait(1500)
															sampSendChat("/do Доктор накладывает швы.")
															wait(1500)
															sampSendChat("/me обрезал"..a.." нить и убрал"..a.." иглу")
															wait(1500)
															sampSendChat("/me наложил"..a.." на рану марлевую повязку")
															wait(1500)
															sampSendChat("/healwound "..playerid)
														end
													end



													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Мед.карта", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
														menu_mc[playerid] = not menu_mc[playerid] -- вкл выкл меню
														menu_heal = {}
														menu_healdisease = {}
														menu_healwound = {}
														menu_setsex = {}
													end
													if menu_mc[playerid] then
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Попросить паспорт", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("Перед тем как начать, мне необходимо проверить..")
															wait(1500)
															sampSendChat("..Ваш паспорт. Предъявите Ваш паспорт в развернутом виде")
															wait(1500)
															sampSendChat("/b /showpass "..myid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Выдать мед.карту", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("Сейчас я заведу мед. карту на Ваше имя")
															wait(1500)
															sampSendChat("/me достал"..a.." бланк медицинской карты")
															wait(1500)
															sampSendChat("/me внес"..la.." данные пациента")
															wait(1500)
															sampSendChat("/givemc "..playerid)
															wait(1500)
															sampSendChat("/me передал"..a.." карту "..targetname.." "..targetsurname)
															wait(1500)
															sampSendChat("/b /showmc ID - показать мед.карту")
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Найти мед.карту", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("Минуту. Сейчас я ознакомлюсь с Вашей медкартой")
															wait(1500)
															sampSendChat("/me достал"..a.." планшетный компьютер")
															wait(1500)
															sampSendChat("/me начал"..a.." поиск медкарты на имя "..targetname.." "..targetsurname)
															wait(1500)
															sampSendChat("/findmc "..nick)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Инфо о отметке годности", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("Если Вы хотите получить в мед. карту печать...")
															wait(1500)
															sampSendChat("..о годности к воинской службе...")
															wait(1500)
															sampSendChat("...необходимо пройти дополнительную мед.комиссию")
															wait(1500)
															sampSendChat("Стоимость теста - 5000 вирт. Производится наличными врачу")
															wait(1500)
															sampSendChat("/b /pay "..myid.." 5000")
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Тест для отметки годности", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me достал"..a.." экспресс-тест")
															wait(1500)
															sampSendChat("/do Доктор взял"..a.." анализ крови пациента.")
															wait(1500)
															sampSendChat("/me провел"..a.." экспресс-тест на болезни")
															wait(1500)
															sampSendChat("/healdisease "..playerid)
															wait(300)
															sampAddChatMessage("{ff0000}Не годен {ffffff}если:", 0xFFFFFFFF)
															sampAddChatMessage("{ffffff}Наркозависимость, алкоголизм - 1 стадия и выше", 0xFFFFFFFF)
															sampAddChatMessage("{ffffff}Грипп, бронхит, микоз, энцефалит - 3 стадия и выше", 0xFFFFFFFF)
															sampAddChatMessage("{ffffff}Отравление - 3 стадия и выше", 0xFFFFFFFF)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Отметка{00a100}[ГОДЕН]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/do Экспресс-тест: Результат: отрицательный | Годен для службы.")
															wait(1500)
															sampSendChat("Поздравляю, вы годны к воинской службе")
															wait(1500)
															sampSendChat("/me внес"..la.." данные в медкарту")
															wait(1500)
															sampSendChat("/me передал"..a.." медкарту "..targetname.." "..targetsurname)
															wait(1500)
															sampSendChat("/updatemc "..playerid.." 1")
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "Отметка{ff0000}[НЕ ГОДЕН]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/do Экспресс-тест: Результат: положительный | Не годен для службы.")
															wait(1500)
															sampSendChat("У Вас положительный результат. Вам необходимо пройти лечение")
															wait(1500)
															sampSendChat("/me внес"..la.." данные в медкарту")
															wait(1500)
															sampSendChat("/me передал"..a.." медкарту "..targetname.." "..targetsurname)
															wait(1500)
															sampSendChat("/updatemc "..playerid.." 0")
														end
													end

													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Страхование пациента", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
														wait(250)
														
														sampSendChat("Сейчас я внесу Ваши данные в страховой полис")
														wait(1500)
														sampSendChat("/me достал"..a.." электронный планшет из кармана")
														wait(1500)
														sampSendChat("/me вошел"..a.." в систему базы данных министерства здравоохранения")
														wait(1500)
														sampSendChat("/me вписал"..a.." данные пациента в электронный страховой полис")
														wait(1500)
														sampSendChat("/do Оформлена заявка на имя "..targetname.." "..targetsurname)
														wait(1500)
														sampSendChat("/do У стола стоит компактный терминал.")
														wait(1500)
														sampSendChat("Произведите оплату путем приложения Вашей карточки")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end

													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Смена пола", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
														menu_setsex[playerid] = not menu_setsex[playerid] -- вкл выкл меню
														menu_heal = {}
														menu_healdisease = {}
														menu_mc = {}
														menu_healwound = {}
													end
													if menu_setsex[playerid] then
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "На мужской", X3 + 45, Y3, 0xFF0048ff, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me приготовил"..a.." стерильные инструменты")
															wait(1500)
															sampSendChat("/me приготовил"..a.." наркоз")
															wait(1500)
															sampSendChat("/me отыскал"..a.." на руке пациента периферическую вену")
															wait(1500)
															sampSendChat("/me ввел"..a.." катетер и поставил"..a.." клипсу на палец")
															wait(1500)
															sampSendChat("/me достал"..a.." ингаляционную маску")
															wait(1500)
															sampSendChat("/me надел"..a.." маску на лицо пациента")
															wait(1500)
															sampSendChat("/do Пациент находится под наркозом.")
															wait(1500)
															sampSendChat("/me удалил"..a.." яичники и фаллопиевы трубы")
															wait(1500)
															sampSendChat("/me снял"..a.." маску с лица пациента")
															wait(1500)
															sampSendChat("/me отключил"..a.." подачу наркоза")
															wait(1500)
															sampSendChat("/do Операция овариэктомия прошла успешно.")
															wait(1500)
															sampSendChat("/setsex "..playerid)
														end
														Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
														if ClickTheText(font, "На женский", X3 + 45, Y3, 0xFFff477e, 0xFFFFFFFF) then
															wait(250)
															
															sampSendChat("/me приготовил"..a.." стерильные инструменты")
															wait(1500)
															sampSendChat("/me приготовил"..a.." наркоз")
															wait(1500)
															sampSendChat("/me нашел"..a.." на руке пациента периферическую вену")
															wait(1500)
															sampSendChat("/me ввел"..a.." катетер и поставил"..a.." клипсу на палец")
															wait(1500)
															sampSendChat("/me достал"..a.." ингаляционную маску")
															wait(1500)
															sampSendChat("/me надел"..a.." маску на лицо пациента")
															wait(1500)
															sampSendChat("/do Пациент находится под наркозом.")
															wait(1500)
															sampSendChat("/me достал"..a.." инструменты")
															wait(1500)
															sampSendChat("/me разрезал"..a.." и удалил"..a.." мужские половые ограны")
															wait(1500)
															sampSendChat("/me сформировал"..a.." женские половые органы")
															wait(1500)
															sampSendChat("/me снял"..a.." маску с лица пациента")
															wait(1500)
															sampSendChat("/me отключил"..a.." подачу наркоза")
															wait(1500)
															sampSendChat("/do Операция прошла успешно.")
															wait(1500)
															sampSendChat("/setsex "..playerid)
														end
													end

												end

												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Не отыгрывать", X3 + 15, Y3, 0xFFfc4e4e, 0xFFFFFFFF) then
													menu_1no[playerid] = not menu_1no[playerid] -- вкл выкл меню
													menu_1o = {}
												end

												if menu_1no[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Лечение", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Болезни и Зависимости", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Страховка и Защита", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
														sampSendChat("/healwound "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Выдать мед.карту", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
														sampSendChat("/givemc "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Найти мед.карту", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
														sampSendChat("/findmc "..nick)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Годен", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
														sampSendChat("/updatemc "..playerid.." 1")
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Не годен", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
														sampSendChat("/updatemc "..playerid.." 0")
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "Сменить пол", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
														sampSendChat("/setsex "..playerid)
													end
												end
											end

											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "Для рук-ва (7+)", X3, Y3, 0xFF5e5e5e, 0xFF4a4a4a) then
												menu_2[playerid] = not menu_2[playerid] -- вкл выкл меню
												menu_1 = {}
												menu_1o = {}
												menu_1no = {}
											end

											if menu_2[playerid] then
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Онлайн", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
													sampSetChatInputText("/tr "..playerid)
													sampSetChatInputEnabled(true)
													setVirtualKeyDown(13, true)
													wait(10)
													setVirtualKeyDown(13, false)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Чекнуть выговоры", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
													sampSetChatInputText("/rep "..playerid)
													sampSetChatInputEnabled(true)
													setVirtualKeyDown(13, true)
													wait(100)
													setVirtualKeyDown(13, false)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Выдать выговор", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
													sampSetChatInputText("/rep add "..playerid)
													sampSetChatInputEnabled(true)
													setVirtualKeyDown(13, true)
													wait(100)
													setVirtualKeyDown(13, false)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Убрать выговор", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
													sampSetChatInputText("/rep del "..playerid)
													sampSetChatInputEnabled(true)
													setVirtualKeyDown(13, true)
													wait(100)
													setVirtualKeyDown(13, false)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Чекнуть ЧС", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
													sampSetChatInputText("/bl "..playerid)
													sampSetChatInputEnabled(true)
													setVirtualKeyDown(13, true)
													wait(100)
													setVirtualKeyDown(13, false)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Добавить в ЧС", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
													sampSetChatInputText("/bl add "..playerid)
													sampSetChatInputEnabled(true)
													setVirtualKeyDown(13, true)
													wait(100)
													setVirtualKeyDown(13, false)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Убрать из ЧС", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
													sampSetChatInputText("/bl del "..playerid)
													sampSetChatInputEnabled(true)
													setVirtualKeyDown(13, true)
													wait(100)
													setVirtualKeyDown(13, false)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "Логи", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
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
												
												sampSendChat("/do На поясе доктора мед.сумка.")
												wait(1000)
												sampSendChat("/me достал"..a.." пластину аспирина и маленькую бутылку воды")
												wait(1000)
												sampSendChat("/me выдавил"..a.." из пластины таблетку")
												wait(1000)
												sampSendChat("/me передал"..a.." бутылку воды вместе с таблеткой")
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
					showCursor(false)
				end
			end
	

	end
end


MedicClists = { 2863857664, 2857434774, 2863857664, 2853039615, 2868880928, 2853375487, 2860620717 }
function autoclist()
	if check_skin_local_player() then
		local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
		local myclist = sampGetPlayerColor(myid)
		while myclist == 2862896983 do
			sampSendChat("/clist "..info.Info.clist)
			wait(5000)
			break
		end
	end
end

function zp()
	if check_skin_local_player() then
		paycheck()
		local render_text = string.format("Зарплата:{008a00} %s", paycheck_money)
		JustText(font, render_text, set.Settings.hud_x, set.Settings.hud_y, 0xFFFFFFFF, 0xFFFFFFFF)
	end
end

function render_chat()
		local y = set.Settings.ChatPosY	
		local ty = set.Settings.ChatPosY
		local x = set.Settings.ChatPosX
		if check_skin_local_player() then
			set_pos_medic_chat()
			for o = #timestamparr-10, #timestamparr do
				if alltoggle then
					ty = ty + renderGetFontDrawHeight(font)
					renderFontDrawText(chatfont, timestamparr[o], (set.Settings.ChatPosX - renderGetFontDrawTextLength(chatfont, timestamparr[o])), ty, 0xFF8D8DFF)
				end
			end
			for i = #chat-10, #chat do
				local rchatmsg = chat[i]
				local rrank, rnick, rid, rmsg = rchatmsg:match(" (.+) (.+)%[(%d+)%]: (.+)")
				y = y + renderGetFontDrawHeight(font)
				if set.Settings.ChatAnsToggle == true then
					ChatAnsToggle = "Вкл"
					if ClickTheText(chatfont, chat[i], set.Settings.ChatPosX, y, 0xFF8D8DFF, 0xFFffffff) then
						local rname, rsurname = string.match(rnick, "(.+)_(.+)")
						if set.Settings.AutoTag then
							sampSetChatInputText("/r Доктор "..rsurname..", ")
							sampSetChatInputEnabled(true)
						else
							sampSetChatInputText("/r "..info.Info.tag.." | Доктор "..rsurname..", ")
							sampSetChatInputEnabled(true)
						end
					end
				elseif set.Settings.ChatAnsToggle == false then
					ChatAnsToggle = "Выкл"
					JustText(chatfont, chat[i], set.Settings.ChatPosX, y, 0xFF8D8DFF)
				end
			end
			
		end
		if (alltoggle and check_skin_local_player()) then
			chatpostext = string.format("[СМЕНИТЬ ПОЗИЦИЮ]  ", -1)
			y = y + renderGetFontDrawHeight(font)
			if ClickTheText(fontChatPosButton, chatpostext, set.Settings.ChatPosX, y, 0xFF969696, 0xFFFFFFFF) then
				medic_chat_pos = true
				wait(100)
			end
			x = x + renderGetFontDrawTextLength(fontChatPosButton, chatpostext)
			chatsizetext = string.format("Размер: "..set.Settings.ChatFontSize.." ", -1)
			JustText(fontChatPosButton, chatsizetext, x, y, 0xFFFFFFFF)

			x = x + renderGetFontDrawTextLength(fontChatPosButton, chatsizetext)
			chatsizeplustext = string.format(" + ", -1)
			if ClickTheText(fontChatPosButton, chatsizeplustext, x, y, 0xFF969696, 0xFFFFFFFF) then
				set.Settings.ChatFontSize = set.Settings.ChatFontSize + 1
				setcfg.save(set, "MedicSettings")
				thisScript():reload()
			end

			x = x + renderGetFontDrawTextLength(fontChatPosButton, chatsizeplustext)
			chatsizeminustext = string.format(" - ", -1)
			if ClickTheText(fontChatPosButton, chatsizeminustext, x, y, 0xFF969696, 0xFFFFFFFF) then
				set.Settings.ChatFontSize = set.Settings.ChatFontSize - 1
				setcfg.save(set, "MedicSettings")
				thisScript():reload()
			end

			x = x + renderGetFontDrawTextLength(fontChatPosButton, chatsizeminustext) * 2
			rtext = "/r"
			if ClickTheText(fontChatPosButton, rtext, x, y, 0xFF969696, 0xFFFFFFFF) then
				if set.Settings.AutoTag then
					wait(250)
					
					sampSendChat("/seeme пробормотал"..a.." что-то в рацию")
					sampSetChatInputText("/r ")
					sampSetChatInputEnabled(true)
				else
					wait(250)
					
					sampSendChat("/seeme пробормотал"..a.." что-то в рацию")
					sampSetChatInputText("/r "..info.Info.tag.." | ")
					sampSetChatInputEnabled(true)
				end
			end

			x = x + renderGetFontDrawTextLength(fontChatPosButton, rtext) * 2
			rbtext = "/rb"
			if ClickTheText(fontChatPosButton, rbtext, x, y, 0xFF969696, 0xFFFFFFFF) then
				wait(250)
				
				sampSetChatInputText("/rb ")
				sampSetChatInputEnabled(true)
			end

			x = x + renderGetFontDrawTextLength(fontChatPosButton, rbtext) * 2
			AnsToggletext = "Ответ по клику:"
			JustText(fontChatPosButton, AnsToggletext, x, y, 0xFFFFFFFF)

			x = x + renderGetFontDrawTextLength(fontChatPosButton, AnsToggletext)  * 1.1
			if ClickTheText(fontChatPosButton, ChatAnsToggle, x, y, 0xFF969696, 0xFFFFFFFF) then
				set.Settings.ChatAnsToggle = not set.Settings.ChatAnsToggle
				setcfg.save(set, "MedicSettings")
				setcfg.load(set, "MedicSettings")
			end

		end
end

osmot = 0
medc = 0
function counter()
	local Y = set.Settings.hud_y
	local X = set.Settings.hud_x
	lua_thread.create(function()
		if check_skin_local_player() then
			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			osmotreno = string.format("Осмотрено: "..osmot, -1)
			set_pos_medic_hud()
			JustText(font, osmotreno, X, Y, 0xFFFFFFFF, 0xFFFFFFFF)
		end
		if (alltoggle and check_skin_local_player()) then
			local render_textosmotplus = string.format("+", -1)
			if ClickTheText(fontpmbuttons, render_textosmotplus, (X + renderGetFontDrawTextLength(font, osmotreno) * 1.1), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				osmot = osmot + 1
			end
			local render_textosmotminus = string.format("-", -1)
			if ClickTheText(fontpmbuttons, render_textosmotminus, (X + renderGetFontDrawTextLength(font, osmotreno) * 1.3), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				osmot = osmot - 1
			end
		end

		if check_skin_local_player() then
			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			medcarty = string.format("Мед.карт: "..medc, -1)
			JustText(font, medcarty, X, Y, 0xFFFFFFFF, 0xFFFFFFFF)
		end
		if (alltoggle and check_skin_local_player()) then
			render_textmedplus = string.format("+", -1)
			if ClickTheText(fontpmbuttons, render_textmedplus, (X + renderGetFontDrawTextLength(font, medcarty) * 1.1), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				medc = medc + 1
			end
			render_textmedminus = string.format("-", -1)
			if ClickTheText(fontpmbuttons, render_textmedminus, (X + renderGetFontDrawTextLength(font, medcarty) * 1.3), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				medc = medc - 1

			end
		end
	end)
end

function render_hud()
	local Y = set.Settings.hud_y
	if (alltoggle and check_skin_local_player()) then
		local render_textpos = string.format("[СМЕНИТЬ ПОЗИЦИЮ]", -1)
		set_pos_medic_hud()
		Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) * 4))
		if ClickTheText(fontPosButton, render_textpos, set.Settings.hud_x, Y, 0xFF969696, 0xFFFFFFFF) then
			medic_hud_pos = true
			wait(100)
		end
	end
end

paycheck_money = "0"
function paycheck()
	if set.Settings.zptoggle then
		if paycheck_antiflood == nil or os.time() - paycheck_antiflood > 60 then
			paycheck_antiflood = os.time()
			sampSendChat("/paycheck")
		end
	end
end

function set_pos_medic_hud()
	if medic_hud_pos == nil then return end
	local x, y = getCursorPos()
	set.Settings.hud_x, set.Settings.hud_y = x, y
	if wasKeyPressed(1) then
		medic_hud_pos = nil
		setcfg.save(set, "MedicSettings")
	end
end

function set_pos_medic_chat()
	if medic_chat_pos == nil then return end
	local x, y = getCursorPos()
	set.Settings.ChatPosX, set.Settings.ChatPosY = x, y
	if wasKeyPressed(1) then
		medic_chat_pos = nil
		setcfg.save(set, "MedicSettings")
	end
end

-- EVENTS
chat = {}
for i = 1, 11 do chat[i] = "" end
timestamparr = {}
for o = 1, 11 do timestamparr[o] = "" end
chatmsginfo = {}
for c = 1, 11 do chatmsginfo[c] = "" end

function sampev.onServerMessage(color, message)
	local _, mid = sampGetPlayerIdByCharHandle(PLAYER_PED)
	local mynick = sampGetPlayerNickname(mid)
	if message:find("Вы заработали %d+ вирт. Деньги будут зачислены на ваш банковский счет в") then
		local number = message:match("Вы заработали (%d+) вирт. Деньги будут зачислены на ваш банковский счет в")
		if os.time() - paycheck_antiflood <= 1 then
			paycheck_money = number
			return false
		end
	end
	if message:find('Не флуди!') then
        return false
    end
	if message:match("Медик "..mynick.." вылечил .+") then
		osmot = osmot + 1
	end
	if message:match("Медкарта обновлена") then
		medc = medc + 1
	end
	if message:match("Медкарта создана") then
		medc = medc + 1
	end
	if message:match("Вы вылечили пациента .+") then
		osmot = osmot + 1
	end
	if message:match("Пациент вылечен от болезни .+") then
		osmot = osmot + 1
	end
	if message:match("Сеанс лечения от болезни .+") then
		osmot = osmot + 1
	end

	if message:find(' Рабочий день начат') then
		return false
	end
	if message:find(' Рабочий день окончен') then
		return false
	end

	if set.Settings.ChatToggle then
		local standartclr = -1920073729
		local targetclr = color
		local timestamp = "["..os.date("%H:%M:%S").."]"
		if targetclr == standartclr then
			timestamparr[#timestamparr+1] = timestamp
			chat[#chat+1] = message
			return false
		end
	end

	if message:find(" Всего сеансов у этого пациента: (%d+) / (%d+)") then
		local number1, number2 = message:match(" Всего сеансов у этого пациента: (%d+) / (%d+)")
		local ostalnum = number2 - number1
			lua_thread.create(function()
				sampSendChat("/b Осталось уколов: "..ostalnum)
				wait(500)
				sampSendChat("/b Следующий укол после PayDay")
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
				toggletext = "{33bf00}Вкл"
				if check_skin_local_player() then
					for k,v, pk, tl in pairs(timers_warn, timers_warnoff) do
						if warn == false and  time == v then
							
							sampAddChatMessage("{ff263c}[Medic] {FFFFFF}Автоматический доклад через 15 сек", -1)
							warn = true
						elseif time == tl then
							warn = false
						end
					end
					for d,lu, hp, yu in pairs(timers_doklads, timers_dokladsoff) do
						if doklad == false and time == lu then
							if location == " " then
								if set.Settings.AutoTag then
									
									sampSendChat("/seeme пробормотал"..a.." что-то в рацию")
									sampSetChatInputText("/r Регистратура: "..info.Info.reg.." | Осмотрено: "..osmot.." | Мед.карт: "..medc.." | Напарник: -")
									sampSetChatInputEnabled(true)
								else
									
									sampSendChat("/seeme пробормотал"..a.." что-то в рацию")
									sampSetChatInputText("/r "..info.Info.tag.." | Регистратура: "..info.Info.reg.." | Осмотрено: "..osmot.." | Мед.карт: "..medc.." | Напарник: -")
									sampSetChatInputEnabled(true)
								end

							else
								if set.Settings.AutoTag then
									
									sampSendChat("/seeme пробормотал"..a.." что-то в рацию")
									sampSetChatInputText("/r "..location.." | Осмотрено: "..osmot.." | Мед.карт: "..medc.." | Напарник: -")
									sampSetChatInputEnabled(true)
								else
									
									sampSendChat("/seeme пробормотал"..a.." что-то в рацию")
									sampSetChatInputText("/r "..info.Info.tag.." | "..location.." | Осмотрено: "..osmot.." | Мед.карт: "..medc.." | Напарник: -")
									sampSetChatInputEnabled(true)
								end
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

						sampAddChatMessage("{ff263c}[Medic] {FFFFFF}Пора делать доклад", -1)
						warn = true
					elseif time == yz then
						warn = false
					end
				end
				toggletext = "{ff0000}Выкл"
			end
		end)
	end
end


location = " "
function locations()
	local y = set.Settings.hud_y
	lua_thread.create(function()
		if check_skin_local_player() then
			local locationtext = location
			set_pos_medic_hud()
			y = y + renderGetFontDrawHeight(font) * 3.3
			JustText(font, locationtext, set.Settings.hud_x, y, 0xFFFFFFFF, 0xFFFFFFFF)

			local _, myid = sampGetPlayerIdByCharHandle(PLAYER_PED)
			local _, handle sampGetCharHandleBySampPlayerId(myid)

			--Автовокзал ЛС
			local avls1x = 1292
			local avls1y = -1718
			local avls1z = 13

			local avls2x = 1045
			local avls2y = -1843
			local avls2z = 30

			--Мэрия
			local may1x = 1394
			local may1y = -1868
			local may1z = 13

			local may2x = 1564
			local may2y = -1738
			local may2z = 30

			--Ферма 0
			local farm01x = -592
			local farm01y = -1288
			local farm01z = 0

			local farm02x = -212
			local farm02y = -1500
			local farm02z = 30

			--АШ
			local ash1x = -2013
			local ash1y = -76
			local ash1z = 30

			local ash2x = -2095
			local ash2y = -280
			local ash2z = 50

			--Автовокзал СФ
			local sfav1x = -2001
			local sfav1y = 218
			local sfav1z = 10

			local sfav2x = -1923
			local sfav2y = 72
			local sfav2z = 50

			--ТП
			local tp1x = -1997
			local tp1y = 536
			local tp1z = 30

			local tp2x = -1907
			local tp2y = 598
			local tp2z = 50

			--Оружейный завод
			local ozav1x = -2009
			local ozav1y = -196
			local ozav1z = 30

			local ozav2x = -2201
			local ozav2y = -280
			local ozav2z = 50

			--Казино
			local kaz1x = 2158
			local kaz1y = 2203
			local kaz1z = 0

			local kaz2x = 2363
			local kaz2y = 2027
			local kaz2z = 50

			--Автовокзал ЛВ
			local avlv1x = 2859
			local avlv1y = 1382
			local avlv1z = 0

			local avlv2x = 2758
			local avlv2y = 1224
			local avlv2z = 50

			--ЛС
			local ls1x = 2930
			local ls1y = -2740
			local ls1z = 0

			local ls2x = 50
			local ls2y = -890
			local ls2z = 250

			--СФ
			local sf1x = -1344
			local sf1y = -1065
			local sf1z = 250

			local sf2x = -2981
			local sf2y = 1487
			local sf2z = 0

			--ЛВ
			local lv1x = 842
			local lv1y = 2947
			local lv1z = 250

			local lv2x = 2970
			local lv2y = 570
			local lv2z = 0

			if isCharInArea3d(PLAYER_PED, avls1x, avls1y, avls1z, avls2x, avls2y, avls2z) == true then
				location = "Пост: Автовокзал ЛС"
			elseif isCharInArea3d(PLAYER_PED, may1x, may1y, may1z, may2x, may2y, may2z) == true then
				location = "Пост: Мэрия"
			elseif isCharInArea3d(PLAYER_PED, farm01x, farm01y, afarm01z, farm02x, farm02y, farm02z) == true then
				location = "Пост: Ферма 0"
			elseif isCharInArea3d(PLAYER_PED, ash1x, ash1y, ash1z, ash2x, ash2y, ash2z) == true then
				location = "Пост: Автошкола"
			elseif isCharInArea3d(PLAYER_PED, sfav1x, sfav1y, sfav1z, sfav2x, sfav2y, sfav2z) == true then
				location = "Пост: Автовокзал СФ"
			elseif isCharInArea3d(PLAYER_PED, tp1x, tp1y, tp1z, tp2x, tp2y, tp2z) == true then
				location = "Пост: Торговая площадка"
			elseif isCharInArea3d(PLAYER_PED, ozav1x, ozav1y, ozav1z, ozav2x, ozav2y, ozav2z) == true then
				location = "Пост: Оружейный завод"
			elseif isCharInArea3d(PLAYER_PED, kaz1x, kaz1y, kaz1z, kaz2x, kaz2y, kaz2z) == true then
				location = "Пост: Казино"
			elseif isCharInArea3d(PLAYER_PED, avlv1x, avlv1y, avlv1z, avlv2x, avlv2y, avlv2z) == true then
				location = "Пост: Автовокзал ЛВ"
			elseif isCharInArea3d(PLAYER_PED, ls1x, ls1y, ls1z, ls2x, ls2y, ls2z) == true then
				location = "Патруль: LS"
			elseif isCharInArea3d(PLAYER_PED, sf1x, sf1y, sf1z, sf2x, sf2y, sf2z) == true then
				location = "Патруль: SF"
			elseif isCharInArea3d(PLAYER_PED, lv1x, lv1y, lv1z, lv2x, lv2y, lv2z) == true then
				location = "Патруль: LV"
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
	  renderFontDrawText(font, "{"..set.Settings.Color2.."}"..text, posX, posY, colorA)
	  if isKeyJustPressed(1) then
		return true
	  end
	end
end

function JustText(font, text, posX, posY, color, colorA)
	renderFontDrawText(font, text, posX, posY, color)
	local textLenght = renderGetFontDrawTextLength(font, text)
	local textHeight = renderGetFontDrawHeight(font)
	local curX, curY = getCursorPos()
	renderFontDrawText(font, text, posX, posY, colorA)
end

