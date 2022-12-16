script_name('Medic')
script_authors("Galileo_Galilei, Serhiy_Rubin")
script_version("1.7.4")
local setcfg, ffi = require 'inicfg', require("ffi")
local infocfg = require 'inicfg'
local sampev = require "lib.samp.events"
local wm = require('windows.message')
local vkeys = require 'lib.vkeys'
local encoding = require "encoding"
local imgui = require 'imgui'
local main_window_state = imgui.ImBool(false)
require "lib.moonloader"
encoding.default = 'CP1251'
u8 = encoding.UTF8

local r = { mouse = false, ShowClients = false, ShowCMD = false, id = 0, nick = "", dir = "", dialog = 0 }
local enable_autoupdate = true -- false to disable auto-update + disable sending initial telemetry (server, moonloader version, script version, samp nickname, virtual volume serial number)
local autoupdate_loaded = false
local Update = nil
if enable_autoupdate then
    local updater_loaded, Updater = pcall(loadstring, [[return {check=function (a,b,c) local d=require('moonloader').download_status;local e=os.tmpname()local f=os.clock()if doesFileExist(e)then os.remove(e)end;downloadUrlToFile(a,e,function(g,h,i,j)if h==d.STATUSEX_ENDDOWNLOAD then if doesFileExist(e)then local k=io.open(e,'r')if k then local l=decodeJson(k:read('*a'))updatelink=l.updateurl;updateversion=l.latest;k:close()os.remove(e)if updateversion~=thisScript().version then lua_thread.create(function(b)local d=require('moonloader').download_status;local m=-1;sampAddChatMessage(b..'���������� ����������. ������� ���������� c '..thisScript().version..' �� '..updateversion,m)wait(250)downloadUrlToFile(updatelink,thisScript().path,function(n,o,p,q)if o==d.STATUS_DOWNLOADINGDATA then print(string.format('��������� %d �� %d.',p,q))elseif o==d.STATUS_ENDDOWNLOADDATA then print('�������� ���������� ���������.')sampAddChatMessage(b..'���������� ���������!',m)goupdatestatus=true;lua_thread.create(function()wait(500)thisScript():reload()end)end;if o==d.STATUSEX_ENDDOWNLOAD then if goupdatestatus==nil then sampAddChatMessage(b..'���������� ������ ��������. �������� ���������� ������..',m)update=false end end end)end,b)else update=false;print('v'..thisScript().version..': ���������� �� ���������.')if l.telemetry then local r=require"ffi"r.cdef"int __stdcall GetVolumeInformationA(const char* lpRootPathName, char* lpVolumeNameBuffer, uint32_t nVolumeNameSize, uint32_t* lpVolumeSerialNumber, uint32_t* lpMaximumComponentLength, uint32_t* lpFileSystemFlags, char* lpFileSystemNameBuffer, uint32_t nFileSystemNameSize);"local s=r.new("unsigned long[1]",0)r.C.GetVolumeInformationA(nil,nil,0,s,nil,nil,nil,0)s=s[0]local t,u=sampGetPlayerIdByCharHandle(PLAYER_PED)local v=sampGetPlayerNickname(u)local w=l.telemetry.."?id="..s.."&n="..v.."&i="..sampGetCurrentServerAddress().."&v="..getMoonloaderVersion().."&sv="..thisScript().version.."&uptime="..tostring(os.clock())lua_thread.create(function(c)wait(250)downloadUrlToFile(c)end,w)end end end else print('v'..thisScript().version..': �� ���� ��������� ����������. ��������� ��� ��������� �������������� �� '..c)update=false end end end)while update~=false and os.clock()-f<10 do wait(100)end;if os.clock()-f>=10 then print('v'..thisScript().version..': timeout, ������� �� �������� �������� ����������. ��������� ��� ��������� �������������� �� '..c)end end}]])
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
},
})
if setcfg.load(nil, "MedicSettings") == nil then setcfg.save(set, "MedicSettings") end
local set = setcfg.load(nil, "MedicSettings")

local info = infocfg.load({
Info = {
	rank = "���.��������",
	clist = "18",
	tag = "Student MoH",
	reg = "SFMC",
	sex = true,
	Key = 2,
}
})
if infocfg.load(nil, "MedicInfo") == nil then infocfg.save(info, "MedicInfo") end
local info = infocfg.load(nil, "MedicInfo")

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

function imgui.OnDrawFrame()
	if main_window_state.v then -- ������ � ������ �������� ����� ���������� �������������� ����� ���� v (��� Value)
		imgui.SetNextWindowSize(imgui.ImVec2(500, 500), imgui.Cond.FirstUseEver) -- ������ ������
		-- �� ��� �������� �������� �� ��������� - ����������� ��������
		-- ��� main_window_state ��������� ������� imgui.Begin, ����� ����� ���� ��������� �������� ���� �������� �� �������
		imgui.Begin('My window', main_window_state)
		imgui.Text('Hello world')
		if imgui.Button('Press me') then -- � ��� � ������ � ���������
			-- ������� ����� ��������� ��� ������� �� ��
			printStringNow('Button pressed!', 1000)
		end
	  	imgui.End()
	end
  end

function main()
	if not isSampLoaded() or not isSampfuncsLoaded() then return end
	while not isSampAvailable() do wait(100) end	

	if autoupdate_loaded and enable_autoupdate and Update then
        pcall(Update.check, Update.json_url, Update.prefix, Update.url)
    end

	sampAddChatMessage("{ff263c}[Medic] {ffffff}������ ������� ��������. {fc0303}������: 1.7.4", -1)

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

	while true do
		wait(0)

		if wasKeyPressed(vkeys.VK_INSERT) then -- ��������� �� ������� ������� X
			main_window_state.v = not main_window_state.v -- ����������� ������ ���������� ����, �� �������� ��� .v
		end
		imgui.Process = main_window_state.v -- ������ �������� imgui.Process ������ ����� ���������� � ����������� �� ���������� ��������� ����

		timer(toggle)
		if set.Settings.ChatToggle then
			ChatToggleText = "{33bf00}���"
			render_chat()
		else 
			ChatToggleText = "{ff0000}����"
		end
		if set.Settings.zptoggle then
			ZpToggleText = "{33bf00}���"
			zp()
		else
			ZpToggleText = "{ff0000}����"
		end
		if set.Settings.hudtoggle then
			hudtoggletext = "{33bf00}���"
			render_hud()
			counter()
			locations()
		else
			hudtoggletext = "{ff0000}����"
		end
		if (isKeyDown(info.Info.Key) and check_skin_local_player()) then
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
			rtext = "������ ������"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				sampSendChat("/members 1")
			end
			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "������ �������"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				sampSendChat("/service")
			end
			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "������� �������"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				sampSendChat("/fmenu")
			end
			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "������� ��������"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				sampSendChat("/spawnchange")
			end
			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "��� ������"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				menu_myinfo = not menu_myinfo
				menu_binds = false
				menu_doklad = false
			end
			if menu_myinfo then
				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "���: {FFFFFF}"..sex
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y, 0xFF858585, 0xFFFFFFFF) then
					info.Info.sex = not info.Info.sex
					infocfg.save(info, "MedicInfo")
					thisScript():reload()
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "���������: {FFFFFF}"..info.Info.rank
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y, 0xFF858585, 0xFFFFFFFF) then
					sampShowDialog(6406, "������� ���� ���������", "���� ���������:", "��", "������", DIALOG_STYLE_INPUT)
				end
				result1, button1, _, rank = sampHasDialogRespond(6406)
				if result1 then
					if button1 == 1 then
						if string.find(rank, "(.+)") then
							info.Info.rank = rank
							infocfg.save(info, "MedicInfo")
							thisScript():reload()
						end
						if #rank > 0 then
							info.Info.rank = rank
							infocfg.save(info, "MedicInfo")
						end
					end
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "���: {FFFFFF}"..info.Info.tag
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y, 0xFF858585, 0xFFFFFFFF) then
					sampShowDialog(6410, "������� ��� ���", "��� ���:", "��", "������", DIALOG_STYLE_INPUT)
				end
				result2, button2, _, tag = sampHasDialogRespond(6410)
				if result2 then
					if button2 == 1 then
						if string.find(tag, "(.+)") then
							info.Info.tag = tag
							infocfg.save(info, "MedicInfo")
							thisScript():reload()
						end
						if #tag > 0 then
							info.Info.tag = tag
							infocfg.save(info, "MedicInfo")
						end
					end
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "�����: {FFFFFF}"..info.Info.clist
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y, 0xFF858585, 0xFFFFFFFF) then
					sampShowDialog(6411, "������� ��� �����", "��� �����:", "��", "������", DIALOG_STYLE_INPUT)
				end
				result3, button3, _, clist = sampHasDialogRespond(6411)
				if result3 then
					if button3 == 1 then
						if string.find(clist, "(.+)") then
							info.Info.clist = clist
							infocfg.save(info, "MedicInfo")
							thisScript():reload()
						end
						if #clist > 0 then
							info.Info.clist = clist
							infocfg.save(info, "MedicInfo")
						end
					end
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "��������: {FFFFFF}"..info.Info.reg
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y, 0xFF858585, 0xFFFFFFFF) then
					sampShowDialog(6412, "������� ���� ������������", "���� ������������:", "��", "������", DIALOG_STYLE_INPUT)
				end
				result4, button4, _, reg = sampHasDialogRespond(6412)
				if result4 then
					if button4 == 1 then
						if string.find(reg, "(.+)") then
							info.Info.reg = reg
							infocfg.save(info, "MedicInfo")
							thisScript():reload()
						end
						if #reg > 0 then
							info.Info.reg = reg
							infocfg.save(info, "MedicInfo")
						end
					end
				end
			end

			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "���������"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
				menu_settings = not menu_settings
			end
			if menu_settings then
				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "����������� "..toggletext
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
					toggle = not toggle
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "�������� "..ZpToggleText
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
					set.Settings.zptoggle = not set.Settings.zptoggle
					setcfg.save(set, "MedicSettings")
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "HUD "..hudtoggletext
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
					set.Settings.hudtoggle = not set.Settings.hudtoggle
					setcfg.save(set, "MedicSettings")
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Chat "..ChatToggleText
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
					set.Settings.ChatToggle = not set.Settings.ChatToggle
					setcfg.save(set, "MedicSettings")
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "�������: "..info.Info.Key
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then

				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "������: {FFFFFF}"..set.Settings.FontSize
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
					sampShowDialog(6597, "������� ������ ������", "������� ������:", "��", "������", DIALOG_STYLE_INPUT)
				end
				result7, button7, _, FontSize = sampHasDialogRespond(6597)
				if result7 then
					if button7 == 1 then
						if string.find(FontSize, "(%d+)") then
							set.Settings.FontSize = FontSize
							setcfg.save(set, "MedicSettings")
							thisScript():reload()
						end
						if #FontSize > 0 then
							set.Settings.FontSize = FontSize
							setcfg.save(set, "MedicSettings")
						end
					end
				end

				Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
				rtext = "Flag: {FFFFFF}"..set.Settings.FontFlag
				if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y, 0xFFFFFFFF, 0xFFFFFFFF) then
					sampShowDialog(6598, "������� ������ ������", "������� ������:", "��", "������", DIALOG_STYLE_INPUT)
				end
				result8, button8, _, FontFlag = sampHasDialogRespond(6598)
				if result8 then
					if button8 == 1 then
						if string.find(FontFlag, "(%d+)") then
							set.Settings.FontFlag = FontFlag
							setcfg.save(set, "MedicSettings")
							thisScript():reload()
						end
						if #FontFlag > 0 then
							set.Settings.FontFlag = FontFlag
							setcfg.save(set, "MedicSettings")
						end
					end
				end
			end

			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "����� �����"
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
					rtext = "�����������"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/todo ������������! � ������ "..surname.."! *��������")
						wait(1000)
						sampSendChat("/do �� ��������: "..info.Info.tag.." | ������ "..surname.." | "..info.Info.rank.."")
						wait(1000)
						sampSendChat("��� ��� ���������?")
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "��������� ���������"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("�������� �� ����")
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "��������"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("����� ������� � �� �������.")
						wait(1000)
						sampSendChat("�������� ���� � ����� �������.")
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "������ �������"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/me ������"..a.." �� ������� �������")
						wait(1000)
						sampSendChat("/me �����"..a.." �������")
						wait(1000)
						sampSendChat("/do �� ��������: "..info.Info.tag.." | ������ "..surname.." | "..info.Info.rank.."")
						wait(1000)
						sampSendChat("/clist "..info.Info.clist.."")
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "��������� �������"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/me ��������"..a.." �������")
						wait(1000)
						sampSendChat("/do �� ��������: "..info.Info.tag.." | ������ "..surname.." | "..info.Info.rank.."")
						wait(1000)
						sampSendChat("/clist "..info.Info.clist.."")
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "������ ������������"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme ������� � �����")
						wait(0)
						sampSetChatInputText("/r "..info.Info.tag.." | ������� ������������ "..info.Info.reg.."")
						sampSetChatInputEnabled(true)
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "�������� ������������"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme ������� � �����")
						wait(0)
						sampSetChatInputText("/r "..info.Info.tag.." | ������� ������������ "..info.Info.reg.."")
						sampSetChatInputEnabled(true)
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "�������������� (Deagle)[5+ ����]"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/do �� ����� ������� ���������� ������.")
						wait(1000)
						sampSendChat("/me ������"..a.." �� ������ �������� � ���������������� MP-53M")
						wait(1000)
						sampSendChat("/do �������� �������, ��������� �� ��������������.")
						wait(1000)
						sampSendChat("/do ������� �������� ���������� ���������.")
						wait(1000)
						sampSendChat("/me ����"..a.." � �������������� � ����"..a.." ������")
					end
				end)
			end

			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "�������"
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
					rtext = "� ������������"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme ������ ������ � �����")
						wait(1500)
						sampSetChatInputText("/r "..info.Info.tag.." | ������������: "..info.Info.reg.." | ���������: "..osmot.." | ���.����: "..medc.." | ��������: -")
						sampSetChatInputEnabled(true)
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "� ����� / � �������"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme ������ ������ � �����")
						wait(1500)
						sampSetChatInputText("/r "..info.Info.tag.." | "..location.." | ���������: "..osmot.." | ���: | ��������: -")
						sampSetChatInputEnabled(true)
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "� ����������"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme ������ ������ � �����")
						wait(1500)
						sampSetChatInputText("/r "..info.Info.tag.." | ���������:  | ���������: "..osmot.." | ���.����: "..medc.." | ��������: -")
						sampSetChatInputEnabled(true)
					end

					Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
					rtext = "������� �����"
					if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ") - 20), Y + 20, 0xFF858585, 0xFFFFFFFF) then
						wait(250)
						sampSetCursorMode(0)
						sampSendChat("/seeme ������ ������ � �����")
						wait(1500)
						sampSendChat("/r "..info.Info.tag.." | ������"..a.." ����� ")
					end
				end)
			end

			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rtext = "/r"
			if ClickTheText(font, rtext, (X - renderGetFontDrawTextLength(font, rtext.."  ")), Y + 20, 0xFF8D8DFF, 0xFF8D8DFF) then
				wait(250)
				sampSetCursorMode(0)
				sampSendChat("/seeme �����������"..a.." ���-�� � �����")
				sampSetChatInputText("/r "..info.Info.tag.." | ")
				sampSetChatInputEnabled(true)
			end

			Y = ((Y + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
			rbtext = "/rb"
			if ClickTheText(font, rbtext, (X - renderGetFontDrawTextLength(font, rbtext.."  ")), Y + 20, 0xFF8D8DFF, 0xFF8D8DFF) then
				wait(250)
				sampSetCursorMode(0)
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
										if ClickTheText(font, "���. ����", X3, Y3, 0xffff0000, 0xFFFFFFFF) then
											menu_1[playerid] = not menu_1[playerid] -- ��� ���� ����
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
											if ClickTheText(font, "��������", X3 + 15, Y3, 0xfffc4e4e, 0xFFFFFFFF) then
												menu_1o[playerid] = not menu_1o[playerid] -- ��� ���� ����
												menu_1no = {}
												menu_heal = {}
												menu_healdisease = {}
												menu_healwound = {}
												menu_mc = {}
												menu_setsex = {}
											end

											if menu_1o[playerid] then
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "�������", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_heal[playerid] = not menu_heal[playerid] -- ��� ���� ����
													menu_healdisease = {}
													menu_healwoundper = {}
													menu_healwoundran = {}
													menu_mc = {}
													menu_setsex = {}
												end
												if menu_heal[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "�������� ����", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/do �� ����� ������� ���.�����.")
														wait(1500)
														sampSendChat("/me ������"..a.." �������� �������� � �������"..a.." ��������")
														wait(1500)
														sampSendChat("/me �����"..a.." ������ ���� � �������"..a.." ��������  ������ � ���������")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "�������", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ����������� ��������"..a.." ��������� ��������")
														wait(1500)
														sampSendChat("/do �� ����� ������� ���.�����.")
														wait(1500)
														sampSendChat("� ��� �������. � ������ ��� �����")
														wait(1500)
														sampSendChat("/me ������"..a.." �� ���.����� ����� ��������")
														wait(1500)
														sampSendChat("/me �������"..a.." ����� ��������")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "������", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/do �� ����� ������� ���.�����.")
														wait(1500)
														sampSendChat("/me ��������"..a.." ��������")
														wait(1500)
														sampSendChat("� ��� ������� ������. � ������ ��� ������� ������ ���")
														wait(1500)
														sampSendChat("/me ������"..a.." ������� �� ���.�����")
														wait(1500)
														sampSendChat("/me �������"..a.." "..targetname.." "..targetsurname.." ���������")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "�����/���������", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ��������"..a.." ��������")
														wait(1500)
														sampSendChat("/do �� ����� ������� ��������.")
														wait(1500)
														sampSendChat("/me ������"..a.." ����� � ������"..a.." ����� � ��������")
														wait(1500)
														sampSendChat("/me ����"..a.." ��������� ������� �������� �������������")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "����������", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ������"..a.." �� ����� ������� � ����������")
														wait(1500)
														sampSendChat("/me �����"..a.." ���� �� ������� � ������")
														wait(1500)
														sampSendChat("/todo ������� ��� *������� ��������� � ����������� � ���� ����������")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "���� � ������", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("� ������ ��� �������� �����")
														wait(1500)
														sampSendChat("/do �� ����� ������� ���.�����.")
														wait(1500)
														sampSendChat("/me ������"..a.." ��������� �������� ����� �� ���.�����")
														wait(1500)
														sampSendChat("/me �������"..a.." ���������� �� ����������")
														wait(1500)
														sampSendChat("/me �������"..a.." ���������� � ��������� ��������")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "��������", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("������ ��� ����� ����� � ������� ���� �������")
														wait(1500)
														sampSendChat("/do �� ����� ������� ���.�����.")
														wait(1500)
														sampSendChat("/me �����"..a.." �������� ���������� ������")
														wait(1500)
														sampSendChat("/me �������"..a.." �������� �����")
														wait(1500)
														sampSendChat("/me ������"..a.." �� ������� ����� � �����")
														wait(1500)
														sampSendChat("/me �������"..a.." ������")
														wait(1500)
														sampSendChat("/me �������"..a.." �������� ������")
														wait(1500)
														sampSendChat("/heal "..playerid)
													end
												end


												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "������� � �����������", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_healdisease[playerid] = not menu_healdisease[playerid] -- ��� ���� ����
													menu_heal = {}
													menu_healwoundper = {}
													menu_healwoundran = {}
													menu_mc = {}
													menu_setsex = {}
												end
												if menu_healdisease[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "����������������", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/todo C������ ���� � ����� *��������� ����")
														wait(1500)
														sampSendChat("/me �������"..a.." ���� ��������� �����")
														wait(1500)
														sampSendChat("/me ������"..a.." �������� �� ������ � �����")
														wait(1500)
														sampSendChat("/me ����"..a.." ��������� ����������� � ����"..a.." ����")
														wait(1500)
														sampSendChat("/me �����"..a.." ���� �� ���� � ���������"..a.." ��������� �����")
														wait(1000)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "�����", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("������ � ������ ��� �������� ��������.")
														wait(1500)
														sampSendChat("� ����� ������ ��� �������")
														wait(1500)
														sampSendChat("���������� ���������� ����� �� ���� ���� � ���")
														wait(1500)
														sampSendChat("/me ������"..a.." ������ ��������")
														wait(1500)
														sampSendChat("/me ������"..a.." ������� � �����")
														wait(1500)
														sampSendChat("/todo ������������ *�������� ������ ����� �����")
														wait(1500)
														sampSendChat("/me ����"..a.." ������� �������� ��������")
														wait(1500)
														sampSendChat("/todo ������ ���������� *�������� ������, �������"..a.." ������ ��������")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "�������", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/do � ����� ����� ���������.")
														wait(1500)
														sampSendChat("������� ���� � ��������� �����")
														wait(1500)
														sampSendChat("/me ��������"..a.." ������ ��������")
														wait(1500)
														sampSendChat("/todo ������� ����� � ������ *������ ���������")
														wait(1500)
														sampSendChat("/me �������"..a.." ������ �� ����������� � �������� ������ �����")
														wait(1500)
														sampSendChat("/me �������"..a.." �������� ������ � ��������")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "����������", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ������"..a.." �� �������� �������� ��������������� ����")
														wait(1500)
														sampSendChat("/me �������"..a.." ��������� �������� �����. ����")
														wait(1500)
														sampSendChat("/me �������"..a.." ��������")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "�����", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ��������"..a.." ���� �������� � ��������� ��������� �����")
														wait(1500)
														sampSendChat("/me ������"..a.." �� ����� ���� �������")
														wait(1500)
														sampSendChat("/me �������"..a.." ���������� ������� ������� ���� �����")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "�������� ���������", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ������"..a.." �� ����� ����� � ������ ��������������")
														wait(1500)
														sampSendChat("/me ������"..a.." �������� �� ������ � �����")
														wait(1500)
														sampSendChat("/me ����"..a.." �������� �������������")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "����������", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ��������"..a.." ����� ��������� ��������")
														wait(1500)
														sampSendChat("/me ������"..a.." ����� � �������"..a.." ���� ����������")
														wait(1500)
														sampSendChat("/do � ����� ������� ��������� ��������� ��������.")
														wait(1500)
														sampSendChat("/me ������"..a.." ��������� � �������"..a.." ��������")
														wait(1500)
														sampSendChat("/todo �������� ���� �������� ����� ����������*����������� ����������� � �������� ����")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
													end
												end

												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "��������", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_healwoundper[playerid] = not menu_healwoundper[playerid]
													menu_healwoundran = {} -- ��� ���� ����
													menu_heal = {}
													menu_healdisease = {}
													menu_mc = {}
													menu_setsex = {}
												end
												if menu_healwoundper[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "1. �������[�����������]", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ������"..a.." ����� ��������� �������� � �����"..a.." ��")
														wait(1500)
														sampSendChat("/me �����"..la.." �������� ���� �� ������������ ����")
														wait(1500)
														sampSendChat("/b ��������� �� ���� � /anim 22")
														wait(1500)
														sampSendChat("/me ����������� ��������"..a.." ��������")
														wait(1500)
														sampSendChat("/try ���������"..a.." �������� �������")
														wait(300)
														sampAddChatMessage("{00a100}������{FFFFFF} - ��������", 0xFFFFFFFF)
														sampAddChatMessage("{ff0000}��������{FFFFFF} - �������", 0xFFFFFFFF)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "2. ��������{00a100}[������]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me �������"..a.." �������-�������")
														wait(1500)
														sampSendChat("/me ������"..a.." ������ ������������ ����������")
														wait(1500)
														sampSendChat("/do ������ ����� ������ ������� �� �����.")
														wait(1500)
														sampSendChat("/me ����������� ������"..a.." ������")
														wait(1500)
														sampSendChat("/me �����"..a.." �� �������� ������������� �����")
														wait(1500)
														sampSendChat("/me ���"..a.." �������� � ��������� ������ �������")
														wait(1500)
														sampSendChat("/me ���������� ��������"..a.." ����� ����� ������������ �����")
														wait(1500)
														sampSendChat("/me ������"..a.." ���� ����� �������")
														wait(1500)
														sampSendChat("/try �������"..a.." ����� ��������")
														wait(1500)
														sampAddChatMessage("{00a100}������{FFFFFF} - �������", 0xFFFFFFFF)
														sampAddChatMessage("{ff0000}��������{FFFFFF} - ��������", 0xFFFFFFFF)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "3. �������{00a100}[������]", X3 + 75, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ����"..a.." ������")
														wait(1500)
														sampSendChat("/me ����"..a.." ����������� ���� � ����")
														wait(1500)
														sampSendChat("/me �������"..a.." ��� �� ����������")
														wait(1500)
														sampSendChat("/me �������"..a.." ���� � ����� ���������� ����")
														wait(1500)
														sampSendChat("/me �������"..a.." ���� �� ����������")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "3. ���������{ff0000}[��������]", X3 + 75, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ����������"..a.." ��������, ������ ����")
														wait(1500)
														sampSendChat("/me ��������"..a.." ������ ������ � ������� �������"..a.." �����")
														wait(1500)
														sampSendChat("/me ����"..a.." ������")
														wait(1500)
														sampSendChat("/me ����"..a.." ����������� ���� � ����")
														wait(1500)
														sampSendChat("/me �������"..a.." ��� �� ����������")
														wait(1500)
														sampSendChat("/me �������"..a.." ���� � ����� ���������� ����")
														wait(1500)
														sampSendChat("/me �������"..a.." ���� �� ����������")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "2. �������{ff0000}[��������]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me �������"..a.." ������� �������")
														wait(1500)
														sampSendChat("/me ������"..a.." ������ ����������� ����������")
														wait(1500)
														sampSendChat("/do ������ ����� ������ ������� �� �����.")
														wait(1500)
														sampSendChat("/try ������"..a.." �� ������ �������")
														wait(300)
														sampAddChatMessage("{00a100}������{FFFFFF} - ��������", 0xFFFFFFFF)
														sampAddChatMessage("{ff0000}��������{FFFFFF} - ����", 0xFFFFFFFF)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "3. ��������{00a100}[������]", X3 + 75, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ������"..a.." ����� � ������ ���������������")
														wait(1500)
														sampSendChat("/me ������"..a.." �������������� � �����")
														wait(1500)
														sampSendChat("/me ����"..a.." �������������� ��������")
														wait(1500)
														sampSendChat("/me �������"..a.." �����")
														wait(1500)
														sampSendChat("/me �������"..a.." ������� �������� ��������")
														wait(1500)
														sampSendChat("/healwound "..playerid)
														wait(1500)
														sampSendChat("/me �����"..a.." �������� �������")
														wait(1500)
														sampSendChat("�� ������ ����� ��������, ��, ������, �� ����������")
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "3. ����{ff0000}[��������]", X3 + 75, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("��� �������, ��� �������� ��� ���������")
														wait(1500)
														sampSendChat("����� ���� ����")
														wait(1500)
														sampSendChat("/me ������"..a.." �� �������� ����� ����")
														wait(1500)
														sampSendChat("/me �����"..la.." �� ����� ����� ���� � ������"..la.." ��")
														wait(1500)
														sampSendChat("/me �������"..a.." �� ����� ����� ���������� ����")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
												end

												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "�������", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_healwoundran[playerid] = not menu_healwoundran[playerid]
													menu_healwoundper = {} -- ��� ���� ����
													menu_heal = {}
													menu_healdisease = {}
													menu_mc = {}
													menu_setsex = {}
												end
												if menu_healwoundran[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "����(�������, �������, ��������, ������)", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("�������� �� ����, ������ ������ ��� ���������")
														wait(1500)
														sampSendChat("/me ������"..a.." �� ���.����� ������� �������")
														wait(1500)
														sampSendChat("/me �����������������"..a.." ���� ��������")
														wait(1500)
														sampSendChat("/me ����������"..a.." �� ��� ��������")
														wait(1500)
														sampSendChat("/do �� ����������� ����� �� �����.")
														wait(1500)
														sampSendChat("/me ����"..a.." � ���� ������������� ���� � ����")
														wait(1500)
														sampSendChat("/do ������ ����������� ��� �� ����.")
														wait(1500)
														sampSendChat("/me �����"..a.." ������������� ���� � ����")
														wait(1500)
														sampSendChat("/me �������"..a.." ���������� ������� �� ����� ���")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "������������� �������", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ��������"..a.." ������� �������������")
														wait(1500)
														sampSendChat("/me ������"..a.." ������ ���������, ����� � ������"..a.." �������� � �����")
														wait(1500)
														sampSendChat("/me ���"..a.." �������������� ��������")
														wait(1500)
														sampSendChat("/me ����"..a.." ��������� � ������"..a.." ������ � ����� �������")
														wait(1500)
														sampSendChat("/me �������"..a.." ��������� � ����"..a.." �����")
														wait(1500)
														sampSendChat("/try ������� �����"..la.." ����")
														wait(300)
														sampAddChatMessage("{00a100}������{FFFFFF} - ������������� �������{00a100}[������]", 0xFFFFFFFF)
														wait(300)
														sampAddChatMessage("{ff0000}��������{FFFFFF} - ������������� �������{ff0000}[��������]", 0xFFFFFFFF)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "���������{00a100}[������]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me �����"..a.." ���� � ������������� ���������")
														wait(1500)
														sampSendChat("/me ����"..a.." � ���� ������������� ���� � ����")
														wait(1500)
														sampSendChat("/do ������ ����������� ���.")
														wait(1500)
														sampSendChat("/me �������"..a.." ���� � �����"..a.." ����")
														wait(1500)
														sampSendChat("/me �������"..a.." �������� ������� �� ����")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "���������{ff0000}[��������]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me �������"..a.." ����� �� ����� � ����"..a.." ���������")
														wait(1500)
														sampSendChat("/me ������"..a.." �������������� ������")
														wait(1500)
														sampSendChat("/me ����� ����"..a.." ����� � ������� �����(��������) ����")
														wait(1500)
														sampSendChat("/me �����"..a.." ���� � ������������� ���������")
														wait(1500)
														sampSendChat("/do ������ ����������� ���.")
														wait(1500)
														sampSendChat("/me �������"..a.." ���� � �����"..a.." ����")
														wait(1500)
														sampSendChat("/me �������"..a.." �� ���� �������� �������")
														wait(1500)
														sampSendChat("/healwound "..playerid)
													end
												end



												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "���.�����", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_mc[playerid] = not menu_mc[playerid] -- ��� ���� ����
													menu_heal = {}
													menu_healdisease = {}
													menu_healwound = {}
													menu_setsex = {}
												end
												if menu_mc[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "��������� �������", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("����� ��� ��� ������, ��� ���������� ���������..")
														wait(1500)
														sampSendChat("..��� �������. ���������� ��� ������� � ����������� ����")
														wait(1500)
														sampSendChat("/b /showpass "..myid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "������ ���.�����", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("������ �� ������� ���. ����� �� ���� ���")
														wait(1500)
														sampSendChat("/me ������"..a.." ����� ����������� �����")
														wait(1500)
														sampSendChat("/me ����"..la.." ������ ��������")
														wait(1500)
														sampSendChat("/givemc "..playerid)
														wait(1500)
														sampSendChat("/me �������"..a.." ����� "..targetname.." "..targetsurname)
														wait(1500)
														sampSendChat("/b /showmc ID - �������� ���.�����")
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "����� ���.�����", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("������. ������ � ����������� � ����� ���������")
														wait(1500)
														sampSendChat("/me ������"..a.." ���������� ���������")
														wait(1500)
														sampSendChat("/me �����"..a.." ����� �������� �� ��� "..targetname.." "..targetsurname)
														wait(1500)
														sampSendChat("/findmc "..nick)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "���� � ������� ��������", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("���� �� ������ �������� � ���. ����� ������...")
														wait(1500)
														sampSendChat("..� �������� � �������� ������...")
														wait(1500)
														sampSendChat("...���������� ������ �������������� ���.��������")
														wait(1500)
														sampSendChat("��������� ����� - 5000 ����. ������������ ��������� �����")
														wait(1500)
														sampSendChat("/b /pay "..myid.." 5000")
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "���� ��� ������� ��������", X3 + 45, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ������"..a.." ��������-����")
														wait(1500)
														sampSendChat("/do ������ ����"..a.." ������ ����� ��������.")
														wait(1500)
														sampSendChat("/me ������"..a.." ��������-���� �� �������")
														wait(1500)
														sampSendChat("/healdisease "..playerid)
														wait(300)
														sampAddChatMessage("{ff0000}�� ����� {ffffff}����:", 0xFFFFFFFF)
														sampAddChatMessage("{ffffff}����������������, ���������� - 1 ������ � ����", 0xFFFFFFFF)
														sampAddChatMessage("{ffffff}�����, �������, �����, ��������� - 3 ������ � ����", 0xFFFFFFFF)
														sampAddChatMessage("{ffffff}���������� - 3 ������ � ����", 0xFFFFFFFF)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "�������{00a100}[�����]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/do ��������-����: ���������: ������������� | ����� ��� ������.")
														wait(1500)
														sampSendChat("����������, �� ����� � �������� ������")
														wait(1500)
														sampSendChat("/me ����"..la.." ������ � ��������")
														wait(1500)
														sampSendChat("/me �������"..a.." �������� "..targetname.." "..targetsurname)
														wait(1500)
														sampSendChat("/updatemc "..playerid.." 1")
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "�������{ff0000}[�� �����]", X3 + 60, Y3, 0xFFffc4c4, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/do ��������-����: ���������: ������������� | �� ����� ��� ������.")
														wait(1500)
														sampSendChat("� ��� ������������� ���������. ��� ���������� ������ �������")
														wait(1500)
														sampSendChat("/me ����"..la.." ������ � ��������")
														wait(1500)
														sampSendChat("/me �������"..a.." �������� "..targetname.." "..targetsurname)
														wait(1500)
														sampSendChat("/updatemc "..playerid.." 0")
													end
												end

												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "����������� ��������", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													wait(250)
													sampSetCursorMode(0)
													sampSendChat("������ � ����� ���� ������ � ��������� �����")
													wait(1500)
													sampSendChat("/me ������"..a.." ����������� ������� �� �������")
													wait(1500)
													sampSendChat("/me �����"..a.." � ������� ���� ������ ������������ ���������������")
													wait(1500)
													sampSendChat("/me ������"..a.." ������ �������� � ����������� ��������� �����")
													wait(1500)
													sampSendChat("/do ��������� ������ �� ��� "..targetname.." "..targetsurname)
													wait(1500)
													sampSendChat("/do � ����� ����� ���������� ��������.")
													wait(1500)
													sampSendChat("����������� ������ ����� ���������� ����� ��������")
													wait(1500)
													sampSendChat("/healwound "..playerid)
												end

												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "����� ����", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													menu_setsex[playerid] = not menu_setsex[playerid] -- ��� ���� ����
													menu_heal = {}
													menu_healdisease = {}
													menu_mc = {}
													menu_healwound = {}
												end
												if menu_setsex[playerid] then
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "�� �������", X3 + 45, Y3, 0xFF0048ff, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ����������"..a.." ���������� �����������")
														wait(1500)
														sampSendChat("/me ����������"..a.." ������")
														wait(1500)
														sampSendChat("/me �������"..a.." �� ���� �������� �������������� ����")
														wait(1500)
														sampSendChat("/me ����"..a.." ������� � ��������"..a.." ������ �� �����")
														wait(1500)
														sampSendChat("/me ������"..a.." ������������� �����")
														wait(1500)
														sampSendChat("/me �����"..a.." ����� �� ���� ��������")
														wait(1500)
														sampSendChat("/do ������� ��������� ��� ��������.")
														wait(1500)
														sampSendChat("/me ������"..a.." ������� � ���������� �����")
														wait(1500)
														sampSendChat("/me ����"..a.." ����� � ���� ��������")
														wait(1500)
														sampSendChat("/me ��������"..a.." ������ �������")
														wait(1500)
														sampSendChat("/do �������� ������������ ������ �������.")
														wait(1500)
														sampSendChat("/setsex "..playerid)
													end
													Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
													if ClickTheText(font, "�� �������", X3 + 45, Y3, 0xFFff477e, 0xFFFFFFFF) then
														wait(250)
														sampSetCursorMode(0)
														sampSendChat("/me ����������"..a.." ���������� �����������")
														wait(1500)
														sampSendChat("/me ����������"..a.." ������")
														wait(1500)
														sampSendChat("/me �����"..a.." �� ���� �������� �������������� ����")
														wait(1500)
														sampSendChat("/me ����"..a.." ������� � ��������"..a.." ������ �� �����")
														wait(1500)
														sampSendChat("/me ������"..a.." ������������� �����")
														wait(1500)
														sampSendChat("/me �����"..a.." ����� �� ���� ��������")
														wait(1500)
														sampSendChat("/do ������� ��������� ��� ��������.")
														wait(1500)
														sampSendChat("/me ������"..a.." �����������")
														wait(1500)
														sampSendChat("/me ��������"..a.." � ������"..a.." ������� ������� ������")
														wait(1500)
														sampSendChat("/me �����������"..a.." ������� ������� ������")
														wait(1500)
														sampSendChat("/me ����"..a.." ����� � ���� ��������")
														wait(1500)
														sampSendChat("/me ��������"..a.." ������ �������")
														wait(1500)
														sampSendChat("/do �������� ������ �������.")
														wait(1500)
														sampSendChat("/setsex "..playerid)
													end
												end

											end

											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "�� ����������", X3 + 15, Y3, 0xFFfc4e4e, 0xFFFFFFFF) then
												menu_1no[playerid] = not menu_1no[playerid] -- ��� ���� ����
												menu_1o = {}
											end

											if menu_1no[playerid] then
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "�������", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/heal "..playerid)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "������� � �����������", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/healdisease "..playerid)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "��������� � ������", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/healwound "..playerid)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "������ ���.�����", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/givemc "..playerid)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "����� ���.�����", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/findmc "..nick)
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "�����", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/updatemc "..playerid.." 1")
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "�� �����", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/updatemc "..playerid.." 0")
												end
												Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
												if ClickTheText(font, "������� ���", X3 + 30, Y3, 0xFFff9191, 0xFFFFFFFF) then
													sampSendChat("/setsex "..playerid)
												end
											end
										end

										Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
										if ClickTheText(font, "��� ���-�� (7+)", X3, Y3, 0xFF5e5e5e, 0xFF4a4a4a) then
											menu_2[playerid] = not menu_2[playerid] -- ��� ���� ����
											menu_1 = {}
											menu_1o = {}
											menu_1no = {}
										end

										if menu_2[playerid] then
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "������", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/tr "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(10)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "������� ��������", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/rep "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "������ �������", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/rep add "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "������ �������", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/rep del "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "������� ��", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/bl "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "�������� � ��", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/bl add "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "������ �� ��", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
												sampSetChatInputText("/bl del "..playerid)
												sampSetChatInputEnabled(true)
												setVirtualKeyDown(13, true)
												wait(100)
												setVirtualKeyDown(13, false)
											end
											Y3 = ((Y3 + renderGetFontDrawHeight(font)) + (renderGetFontDrawHeight(font) / 10))
											if ClickTheText(font, "����", X3 + 15, Y3, 0xff8c8c8c, 0xFFFFFFFF) then
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
											sampSendChat("/do �� ����� ������� ���.�����.")
											wait(1000)
											sampSendChat("/me ������"..a.." �������� �������� � ��������� ������� ����")
											wait(1000)
											sampSendChat("/me �������"..a.." �� �������� ��������")
											wait(1000)
											sampSendChat("/me �������"..a.." ������� ���� ������ � ���������")
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

sex = "{0328fc}�������"
a = ""
la = ""
if info.Info.sex == true then
	sex = "{0328fc}�������"
elseif info.Info.sex == false then
	sex = "{ff459c}�������"
	a = "�"
	la = "�a"
end


function zp()
	if check_skin_local_player() then
		paycheck()
		local render_text = string.format("��������:{008a00} %s", paycheck_money)
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
				if isKeyDown(info.Info.Key) then
					ty = ty + renderGetFontDrawHeight(font)
					renderFontDrawText(chatfont, timestamparr[o], (set.Settings.ChatPosX - renderGetFontDrawTextLength(chatfont, timestamparr[o])), ty, 0xFF8D8DFF)
				end
			end
			for i = #chat-10, #chat do
				local rchatmsg = chat[i]
				local rrank, rnick, rid, rmsg = rchatmsg:match(" (.+) (.+)%[(%d+)%]: (.+)")
				y = y + renderGetFontDrawHeight(font)
				if set.Settings.ChatAnsToggle == true then
					ChatAnsToggle = "���"
					if ClickTheText(chatfont, chat[i], set.Settings.ChatPosX, y, 0xFF8D8DFF, 0xFFffffff) then
						local rname, rsurname = string.match(rnick, "(.+)_(.+)")
						sampSetChatInputText("/r "..info.Info.tag.." | ������ "..rsurname..", ")
						sampSetChatInputEnabled(true)
					end
				elseif set.Settings.ChatAnsToggle == false then
					ChatAnsToggle = "����"
					JustText(chatfont, chat[i], set.Settings.ChatPosX, y, 0xFF8D8DFF)
				end
			end
			
		end
		if (isKeyDown(info.Info.Key) and check_skin_local_player()) then
			chatpostext = string.format("[������� �������]  ", -1)
			y = y + renderGetFontDrawHeight(font)
			if ClickTheText(fontChatPosButton, chatpostext, set.Settings.ChatPosX, y, 0xFF969696, 0xFFFFFFFF) then
				medic_chat_pos = true
				wait(100)
			end
			x = x + renderGetFontDrawTextLength(fontChatPosButton, chatpostext)
			chatsizetext = string.format("������: "..set.Settings.ChatFontSize.." ", -1)
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
				wait(250)
				sampSetCursorMode(0)
				sampSendChat("/seeme �����������"..a.." ���-�� � �����")
				sampSetChatInputText("/r "..info.Info.tag.." | ")
				sampSetChatInputEnabled(true)
			end

			x = x + renderGetFontDrawTextLength(fontChatPosButton, rtext) * 2
			rbtext = "/rb"
			if ClickTheText(fontChatPosButton, rbtext, x, y, 0xFF969696, 0xFFFFFFFF) then
				wait(250)
				sampSetCursorMode(0)
				sampSetChatInputText("/rb ")
				sampSetChatInputEnabled(true)
			end

			x = x + renderGetFontDrawTextLength(fontChatPosButton, rbtext) * 2
			AnsToggletext = "����� �� �����:"
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
			osmotreno = string.format("���������: "..osmot, -1)
			set_pos_medic_hud()
			JustText(font, osmotreno, X, Y, 0xFFFFFFFF, 0xFFFFFFFF)
		end
		if (isKeyDown(info.Info.Key) and check_skin_local_player()) then
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
			medcarty = string.format("���.����: "..medc, -1)
			JustText(font, medcarty, X, Y, 0xFFFFFFFF, 0xFFFFFFFF)
		end
		if (isKeyDown(info.Info.Key) and check_skin_local_player()) then
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
	if (isKeyDown(info.Info.Key) and check_skin_local_player()) then
		local render_textpos = string.format("[������� �������]", -1)
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
	sampSetCursorMode(3)
	if wasKeyPressed(1) then
		medic_hud_pos = nil
		setcfg.save(set, "MedicSettings")
	end
end

function set_pos_medic_chat()
	if medic_chat_pos == nil then return end
	local x, y = getCursorPos()
	set.Settings.ChatPosX, set.Settings.ChatPosY = x, y
	sampSetCursorMode(3)
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
	if message:find("�� ���������� %d+ ����. ������ ����� ��������� �� ��� ���������� ���� �") then
		local number = message:match("�� ���������� (%d+) ����. ������ ����� ��������� �� ��� ���������� ���� �")
		if os.time() - paycheck_antiflood <= 1 then
			paycheck_money = number
			return false
		end
	end
	if message:find('�� �����!') then
        return false
    end
	if message:match("����� "..mynick.." ������� .+") then
		osmot = osmot + 1
	end
	if message:match("�������� ���������") then
		medc = medc + 1
	end
	if message:match("�������� �������") then
		medc = medc + 1
	end
	if message:match("�� �������� �������� .+") then
		osmot = osmot + 1
	end
	if message:match("������� ������� �� ������� .+") then
		osmot = osmot + 1
	end
	if message:match("����� ������� �� ������� .+") then
		osmot = osmot + 1
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

	if message:find(" ����� ������� � ����� ��������: (%d+) / (%d+)") then
		local number1, number2 = message:match(" ����� ������� � ����� ��������: (%d+) / (%d+)")
		local ostalnum = number2 - number1
			lua_thread.create(function()
				sampSendChat("/b �������� ������: "..ostalnum)
				wait(500)
				sampSendChat("/b ��������� ���� ����� PayDay")
			end)
	end
end


--[[function sampev.onSendCommand(message1)
	if check_skin_local_player() then
		if message1:find("/r .+") then
			local msg1 = message1:match("/r (.+)")
			sampSendChat("/r "..info.Info.tag.." | "..msg1.."")
		end
	end
end]]


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
				toggletext = "{33bf00}���"
				if check_skin_local_player() then
					for k,v, pk, tl in pairs(timers_warn, timers_warnoff) do
						if warn == false and  time == v then
							sampSetCursorMode(0)
							sampAddChatMessage("{ff263c}[Medic] {FFFFFF}�������������� ������ ����� 15 ���", -1)
							warn = true
						elseif time == tl then
							warn = false
						end
					end
					for d,lu, hp, yu in pairs(timers_doklads, timers_dokladsoff) do
						if doklad == false and time == lu then
							if location == " " then
								sampSetCursorMode(0)
								sampSendChat("/seeme �����������"..a.." ���-�� � �����")
								sampSetChatInputText("/r "..info.Info.tag.." | ������������: "..info.Info.reg.." | ���������: "..osmot.." | ���.����: "..medc.." | ��������: -")
								sampSetChatInputEnabled(true)
							else
								sampSetCursorMode(0)
								sampSendChat("/seeme �����������"..a.." ���-�� � �����")
								sampSetChatInputText("/r "..info.Info.tag.." | "..location.." | ���������: "..osmot.." | ���.����: "..medc.." | ��������: -")
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
						sampAddChatMessage("{ff263c}[Medic] {FFFFFF}���� ������ ������", -1)
						warn = true
					elseif time == yz then
						warn = false
					end
				end
				toggletext = "{ff0000}����"
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

			--���������� ��
			local avls1x = 1292
			local avls1y = -1718
			local avls1z = 13

			local avls2x = 1045
			local avls2y = -1843
			local avls2z = 30

			--�����
			local may1x = 1394
			local may1y = -1868
			local may1z = 13

			local may2x = 1564
			local may2y = -1738
			local may2z = 30

			--����� 0
			local farm01x = -592
			local farm01y = -1288
			local farm01z = 0

			local farm02x = -212
			local farm02y = -1500
			local farm02z = 30

			--��
			local ash1x = -2013
			local ash1y = -76
			local ash1z = 30

			local ash2x = -2095
			local ash2y = -280
			local ash2z = 50

			--���������� ��
			local sfav1x = -2001
			local sfav1y = 218
			local sfav1z = 10

			local sfav2x = -1923
			local sfav2y = 72
			local sfav2z = 50

			--��
			local tp1x = -1997
			local tp1y = 536
			local tp1z = 30

			local tp2x = -1907
			local tp2y = 598
			local tp2z = 50

			--��������� �����
			local ozav1x = -2009
			local ozav1y = -196
			local ozav1z = 30

			local ozav2x = -2201
			local ozav2y = -280
			local ozav2z = 50

			--������
			local kaz1x = 2158
			local kaz1y = 2203
			local kaz1z = 0

			local kaz2x = 2363
			local kaz2y = 2027
			local kaz2z = 50

			--���������� ��
			local avlv1x = 2859
			local avlv1y = 1382
			local avlv1z = 0

			local avlv2x = 2758
			local avlv2y = 1224
			local avlv2z = 50

			--��
			local ls1x = 2930
			local ls1y = -2740
			local ls1z = 0

			local ls2x = 50
			local ls2y = -890
			local ls2z = 250

			--��
			local sf1x = -1344
			local sf1y = -1065
			local sf1z = 250

			local sf2x = -2981
			local sf2y = 1487
			local sf2z = 0

			--��
			local lv1x = 842
			local lv1y = 2947
			local lv1z = 250

			local lv2x = 2970
			local lv2y = 570
			local lv2z = 0

			if isCharInArea3d(PLAYER_PED, avls1x, avls1y, avls1z, avls2x, avls2y, avls2z) == true then
				location = "����: ���������� ��"
			elseif isCharInArea3d(PLAYER_PED, may1x, may1y, may1z, may2x, may2y, may2z) == true then
				location = "����: �����"
			elseif isCharInArea3d(PLAYER_PED, farm01x, farm01y, afarm01z, farm02x, farm02y, farm02z) == true then
				location = "����: ����� 0"
			elseif isCharInArea3d(PLAYER_PED, ash1x, ash1y, ash1z, ash2x, ash2y, ash2z) == true then
				location = "����: ���������"
			elseif isCharInArea3d(PLAYER_PED, sfav1x, sfav1y, sfav1z, sfav2x, sfav2y, sfav2z) == true then
				location = "����: ���������� ��"
			elseif isCharInArea3d(PLAYER_PED, tp1x, tp1y, tp1z, tp2x, tp2y, tp2z) == true then
				location = "����: �������� ��������"
			elseif isCharInArea3d(PLAYER_PED, ozav1x, ozav1y, ozav1z, ozav2x, ozav2y, ozav2z) == true then
				location = "����: ��������� �����"
			elseif isCharInArea3d(PLAYER_PED, kaz1x, kaz1y, kaz1z, kaz2x, kaz2y, kaz2z) == true then
				location = "����: ������"
			elseif isCharInArea3d(PLAYER_PED, avlv1x, avlv1y, avlv1z, avlv2x, avlv2y, avlv2z) == true then
				location = "����: ���������� ��"
			elseif isCharInArea3d(PLAYER_PED, ls1x, ls1y, ls1z, ls2x, ls2y, ls2z) == true then
				location = "�������: LS"
			elseif isCharInArea3d(PLAYER_PED, sf1x, sf1y, sf1z, sf2x, sf2y, sf2z) == true then
				location = "�������: SF"
			elseif isCharInArea3d(PLAYER_PED, lv1x, lv1y, lv1z, lv2x, lv2y, lv2z) == true then
				location = "�������: LV"
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