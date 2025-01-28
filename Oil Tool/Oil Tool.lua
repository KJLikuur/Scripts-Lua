script_name("Oil Helper")
script_author(" KJ // Likuur")
script_version("1.3")

local fa = require("fAwesome6")
local sampev = require("samp.events")
local imgui = require 'mimgui'
local encoding = require 'encoding'
encoding.default = 'CP1251'
local u8 = encoding.UTF8
local lfs = require("lfs")
local ffi = require 'ffi'
local sf = require 'sampfuncs'
local gta = ffi.load("GTASA")
local sizeX, sizeY = getScreenResolution()
local request = require("requests")
local inicfg = require 'inicfg'
local monet = require("MoonMonet")
local new, str = imgui.new, ffi.string
local MDS = MONET_DPI_SCALE
local new = imgui.new
local AI_TOGGLE = {}
local ToU32 = imgui.ColorConvertFloat4ToU32
local mainMenu = new.bool()
local found_update = new.bool()
local tab = 1
local widgets = require('widgets') -- for WIDGET_(...)

local configDirectory = getWorkingDirectory():gsub('\\','/') .. "/Oil Tool"
local path_settings = configDirectory .. "/settings.json"
local path_helper = getWorkingDirectory():gsub('\\','/') .. "/Oil Tool.lua"
    local settings = {}
local default_settings = {
	cfg = {
    moneyoherall = 0,
    boolGiveaz = 1,
  boolGivemoney =124000,
    Settings = false,
    moneycfg = false,
    azcfg = false,
    viborts = false,
    aytoH = false,
    autoalt = false,
    zarmon = 0,
    azzar = 0,
    skipdi = false,
    boshkiini = 0,
    boshkamenu = false,
    custom_dpi = 1.0,
    autofind_dpi = false,
    },
    	theme = {
        moonmonet = (61951),
    }
}
function load_settings()
    if not doesDirectoryExist(configDirectory) then
        createDirectory(configDirectory)
    end
    if not doesFileExist(path_settings) then
        settings = default_settings
		print('Файл с настройками не найден, использую стандартные настройки!')
    else
        local file = io.open(path_settings, 'r')
        if file then
            local contents = file:read('*a')
            file:close()
			if #contents == 0 then
				settings = default_settings
				print(' Не удалось открыть файл с настройками, использую стандартные настройки!')
			else
				local result, loaded = pcall(decodeJson, contents)
				if result then
					settings = loaded
					for category, _ in pairs(default_settings) do
						if settings[category] == nil then
							settings[category] = {}
						end
						for key, value in pairs(default_settings[category]) do
							if settings[category][key] == nil then
								settings[category][key] = value
							end
						end
					end
					print('Настройки успешно загружены!')
				else
					print('Не удалось открыть файл с настройками, использую стандартные настройки!')
				end
			end
        else
            settings = default_settings
			print('Не удалось открыть файл с настройками, использую стандартные настройки!')
        end
    end
end
function cfg_save()
    local file, errstr = io.open(path_settings, 'w')
    if file then
        local result, encoded = pcall(encodeJson, settings)
        file:write(result and encoded or "")
        file:close()
		print(' Настройки сохранены!')
        return result
    else
        print('Не удалось сохранить настройки хелпера, ошибка: ', errstr)
        return false
    end
end
load_settings()
local objectcheck = false
local viborts = imgui.new.bool(settings.cfg.viborts)
local OilStats = imgui.new.bool(false)
local zarmonsesia = 0
local azzarsesia = 0
local boxhkosesia = 0
local moneyoherallses = 0

local moneycfg = imgui.new.bool(settings.cfg.moneycfg)
local azcfg = imgui.new.bool(settings.cfg.azcfg)
local skipdi = new.bool(settings.cfg.skipdi)
local boshkamenu = imgui.new.bool(settings.cfg.boshkamenu)
local boolGiveaz = imgui.new.int(settings.cfg.boolGiveaz)
local boolGivemoney = imgui.new.int(settings.cfg.boolGivemoney)
local infobarik = imgui.new.bool(false)

         
        imgui.OnInitialize(function()
    imgui.GetIO().IniFilename = nil
    local config = imgui.ImFontConfig()
    config.MergeMode = true
    config.PixelSnapH = true
    iconRanges = imgui.new.ImWchar[3](fa.min_range, fa.max_range, 0)
    imgui.GetIO().Fonts:AddFontFromMemoryCompressedBase85TTF(fa.get_font_data_base85('light'), 29, config, iconRanges)
end)
        
        
        
     
function check_update()
	
	print('Начинаю проверку на наличие обновлений...')
	msg('Начинаю проверку на наличие обновлений...')
	local path = configDirectory .. "/Update_Info.json"
	os.remove(path)
	local url = 'https://github.com/KJLikuur/Scripts-Lua/raw/refs/heads/main/Oil%20Tool/Update_Info.json'
	if isMonetLoader() then
		downloadToFile(url, path, function(type, pos, total_size)
			if type == "finished" then
				local updateInfo = readJsonFile(path)
				if updateInfo then
					local uVer = updateInfo.current_version
					local uUrl = updateInfo.update_url
					local uText = updateInfo.update_info
					print("Текущая установленная версия:", thisScript().version)
					print("Текущая версия в облаке:", uVer)
					if thisScript().version ~= uVer then
						print('Доступно обновление!')
						msg('Доступно обновление!')
						need_update_helper = true
						updateUrl = uUrl
						updateVer = uVer
						updateInfoText = uText
						found_update[0] = true
					else
						print('Обновление не нужно!')
						msg('Обновление не нужно, у вас актуальная версия!')
					end
				end
			end
		end)
	else
		downloadUrlToFile(url, path, function(id, status)
			if status == 6 then -- ENDDOWNLOADDATA
				local updateInfo = readJsonFile(path)
				if updateInfo then
					local uVer = updateInfo.current_version
					local uUrl = updateInfo.update_url
					local uText = updateInfo.update_info
					print("Текущая установленная версия:", thisScript().version)
					print("Текущая версия в облаке:", uVer)
					if thisScript().version ~= uVer then
						print('Доступно обновление!')
						msg('Доступно обновление!')
						need_update_helper = true
						updateUrl = uUrl
						updateVer = uVer
						updateInfoText = uText
						found_update[0] = true
					else
						print('Обновление не нужно!')
						msg('Обновление не нужно, у вас актуальная версия!')
					end
				end
			end
		end)
	end
	function readJsonFile(filePath)
		if not doesFileExist(filePath) then
			print("Ошибка: Файл " .. filePath .. " не существует")
			return nil
		end
		local file = io.open(filePath, "r")
		local content = file:read("*a")
		file:close()
		local jsonData = decodeJson(content)
		if not jsonData then
			print("Ошибка: Неверный формат JSON в файле " .. filePath)
			return nil
		end
		return jsonData
	end
end
function downloadToFile(url, path, callback, progressInterval)
	callback = callback or function() end
	progressInterval = progressInterval or 0.1

	local effil = require("effil")
	local progressChannel = effil.channel(0)

	local runner = effil.thread(function(url, path)
	local http = require("socket.http")
	local ltn = require("ltn12")

	local r, c, h = http.request({
		method = "HEAD",
		url = url,
	})

	if c ~= 200 then
		return false, c
	end
	local total_size = h["content-length"]

	local f = io.open(path, "wb")
	if not f then
		return false, "failed to open file"
	end
	local success, res, status_code = pcall(http.request, {
		method = "GET",
		url = url,
		sink = function(chunk, err)
		local clock = os.clock()
		if chunk and not lastProgress or (clock - lastProgress) >= progressInterval then
			progressChannel:push("downloading", f:seek("end"), total_size)
			lastProgress = os.clock()
		elseif err then
			progressChannel:push("error", err)
		end

		return ltn.sink.file(f)(chunk, err)
		end,
	})

	if not success then
		return false, res
	end

	if not res then
		return false, status_code
	end

	return true, total_size
	end)
	local thread = runner(url, path)

	local function checkStatus()
	local tstatus = thread:status()
	if tstatus == "failed" or tstatus == "completed" then
		local result, value = thread:get()

		if result then
		callback("finished", value)
		else
		callback("error", value)
		end

		return true
	end
	end

	lua_thread.create(function()
	if checkStatus() then
		return
	end

	while thread:status() == "running" do
		if progressChannel:size() > 0 then
		local type, pos, total_size = progressChannel:pop()
		callback(type, pos, total_size)
		end
		wait(0)
	end

	checkStatus()
	end)
end
function downloadFileFromUrlToPath(url, path)
	print('Начинаю скачивание файла в ' .. path)
	if isMonetLoader() then
		downloadToFile(url, path, function(type, pos, total_size)
			if type == "downloading" then
				--print(("Скачивание %d/%d"):format(pos, total_size))
			elseif type == "finished" then
				if download_helper then
					msg('Загрузка новой версии хелпера завершена успешно! Перезагрузка..')
					reload_script = true	
					script_reload()			
					end
			end
		end)
	end
end

function separator(number)
    local formatted = tostring(number):reverse():gsub("%d%d%d", "%1 "):reverse()
    return formatted
end

imgui.OnFrame(function() return mainMenu[0] end, function(player)
    local resX, resY = getScreenResolution()
        local sizeX, sizeY = 600 * MDS, 300 * MDS
              
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2, resY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        imgui.Begin('Oil Tool', mainMenu,imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize )
        if imgui.BeginChild('##1', imgui.ImVec2(350, -1), true) then
        if imgui.CustomButton(tab == 1, fa("screwdriver_wrench"), u8(" Главная"), 0.80) then tab = 1 end
                if imgui.CustomButton(tab == 2, fa("screwdriver_wrench"), u8(" Информация"), 0.80) then tab = 2 end
        					
        imgui.EndChild() 
        end 
       
        imgui.SameLine()
        if imgui.BeginChild('Name', imgui.ImVec2(-1, -1), true) then

        if tab == 1 then 
     		          if imgui.Checkbox(u8' Статистика',infobarik) then
                    OilStats[0]= not OilStats[0]              
                end	
                imgui.Separator()
if imgui.Checkbox(u8' Заработанные вирты', moneycfg) then settings.cfg.moneycfg = moneycfg[0] cfg_save()  end
            if imgui.Checkbox(u8' Заработанные AZ-Coins', azcfg) then settings.cfg.azcfg = azcfg[0]  cfg_save() end 
                        if imgui.Checkbox(u8'Кол-во проданных бочек', boshkamenu) then settings.cfg.boshkamenu = boshkamenu[0]  cfg_save() end
         imgui.Separator()               
  		    		imgui.CenterText(u8'Заработано AZ-coins за всё время: '..settings.cfg.azzar.. 'шт.')
				    		imgui.CenterText(u8'Заработано AZ-coins за сессию: '..azzarsesia.. 'шт.')
		imgui.CenterText(u8'Заработано вирт за сессию: ' ..separator(zarmonsesia).. '$.')
		imgui.CenterText(u8'Заработано вирт за всё время: ' ..separator(settings.cfg.zarmon).. '$.')
	imgui.CenterText(u8'Продано бочек за сессию: '..boxhkosesia.. 'шт.')
	imgui.CenterText(u8'Продано бочек за всё время: '..settings.cfg.boshkiini.. 'шт.')
	imgui.CenterText(u8'Заработано денег учётом охраны за все время: '..separator(moneyoherall))
	imgui.CenterText(u8'Заработано денег учётом охраны за сессию: '..separator(moneyoherallses))
		        if imgui.Button(u8' Очистить статистику', imgui.ImVec2(-1, 45)) then
deleteAll()
end 
   imgui.Separator()
                imgui.CenterText(u8'Кол-во  АЗ за 1 бочку:')
             
                if imgui.InputInt('##test',boolGiveaz,1,15) then
                settings.cfg.boolGiveaz = boolGiveaz[0]
                cfg_save() 
                end 	imgui.Separator()
                imgui.CenterText(u8'Кол-во  $ за 1 бочку:')
             
                if imgui.InputInt('##test2',boolGivemoney,0,0) then
                settings.cfg.boolGivemoney = boolGivemoney[0]
                cfg_save() 
                end 
                imgui.Separator()	
if imgui.Checkbox(u8'АвтоВыбор занятого слота', viborts) then
                    settings.cfg.viborts = viborts[0]
                    cfg_save() 
                end 
      if imgui.Checkbox(u8'Скрыть диалог покупки', skipdi) then
                    settings.cfg.skipdi = skipdi[0]
                    cfg_save() 
                end                
        elseif tab == 2 then 
    imgui.CenterText(fa.CIRCLE_INFO .. u8' Дополнительная информация про хелпер')
    imgui.Separator()
    
    imgui.Text(fa.CIRCLE_USER..u8" Разработчик данного хелпера: KJ // Likuur")
				imgui.Separator()
				imgui.Text(fa.CIRCLE_INFO .. u8' Установленная версия хелпера ' .. thisScript().version)				
			            if imgui.Button(fa.TAG .. u8" Проверить обновление") then
                check_update()
            end	
				imgui.Separator()
				imgui.Text(fa.HEADSET..u8" Тех.поддержка по хелперу:")
				imgui.SameLine()
				if imgui.SmallButton('Telegram канал') then
					openLink('https://t.me/K_Jmods')
				end
				
				imgui.Separator()
				imgui.Text(fa.GLOBE..u8" Тема хелпера на форуме BlastHack:")
				imgui.SameLine()
				if imgui.SmallButton(u8' Скоро') then
					openLink('')							
end
imgui.BeginChild('##3', imgui.ImVec2(-1 * MONET_DPI_SCALE, 90 * MONET_DPI_SCALE), true)
				imgui.CenterText(fa.PALETTE .. u8' Цветовая тема хелпера:')
				imgui.Separator()
				if imgui.ColorEdit3('## COLOR', mmcolor, imgui.ColorEditFlags.NoInputs) then
                r,g,b = mmcolor[0] * 255, mmcolor[1] * 255, mmcolor[2] * 255
              argb = join_argb(0, r, g, b)
                settings.theme.moonmonet = argb
                cfg_save()
          apply_n_t()
            end
            imgui.SameLine()
            imgui.Text(fa.NOTE_STICKY..u8' Цвет MoonMonet') 
                   
					imgui.EndChild()
					
            if imgui.Button(fa.TAG .. u8" Выключение", imgui.ImVec2(imgui.GetMiddleButtonX(4), 24 * settings.cfg.custom_dpi)) then
                imgui.OpenPopup(fa.MONEY_CHECK_DOLLAR..u8' Выключение')
            end
            if imgui.BeginPopupModal(fa.MONEY_CHECK_DOLLAR..u8' Выключение', _, imgui.WindowFlags.AlwaysAutoResize) then
                imgui.CenterText(u8'Вы действительно хотите выгрузить (отключить) хелпер?')
					imgui.Separator()
					if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * settings.cfg.custom_dpi, 25 * settings.cfg.custom_dpi)) then
						imgui.CloseCurrentPopup()
					end
					imgui.SameLine()
					if imgui.Button(fa.POWER_OFF .. u8' Да, выгрузить', imgui.ImVec2(200 * settings.cfg.custom_dpi, 25 * settings.cfg.custom_dpi)) then
						reload_script = true				
						msg('Хелпер приостановил свою работу до следущего входа в игру!')					
						thisScript():unload()
					end
                imgui.EndPopup()
            end 
imgui.SameLine()
                  if imgui.Button(fa.TAG .. u8" Удаление", imgui.ImVec2(imgui.GetMiddleButtonX(4), 24 * settings.cfg.custom_dpi)) then
                imgui.OpenPopup(fa.MONEY_CHECK_DOLLAR..u8' Удаление')
            end
            if imgui.BeginPopupModal(fa.MONEY_CHECK_DOLLAR..u8' Удаление', _, imgui.WindowFlags.AlwaysAutoResize) then
imgui.CenterText(u8'Вы действительно хотите удалить Oil Tool?')
					imgui.Separator()
					if imgui.Button(fa.CIRCLE_XMARK .. u8' Нет, отменить', imgui.ImVec2(200 * settings.cfg.custom_dpi, 25 * settings.cfg.custom_dpi)) then
						imgui.CloseCurrentPopup()
					end
					imgui.SameLine()
					if imgui.Button(fa.TRASH_CAN .. u8' Да, я хочу удалить', imgui.ImVec2(200 * settings.cfg.custom_dpi, 25 * settings.cfg.custom_dpi)) then
						msg('Хелпер полностю удалён из вашего устройства!')			
						reload_script = true
						os.remove(path_helper)
						os.remove(path_settings)							os.remove(configDirectory) 							
						thisScript():unload()
					end
                imgui.EndPopup()
            end 
imgui.SameLine()
if imgui.Button(fa.ROTATE_RIGHT .. u8" Перезагрузка ", imgui.ImVec2(imgui.GetMiddleButtonX(4), 25 * settings.cfg.custom_dpi)) then
					reload_script = true
					thisScript():reload()
				end   
				end
				imgui.EndChild()            
        
    end
    imgui.End() 
end)  
  imgui.OnFrame(function() return OilStats[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 8, sizeY / 1.7), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
      
       imgui.Begin('Oil Helper', OilStats, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize )
      if settings.cfg.moneycfg then 
      imgui.CenterText(fa.CIRCLE_DOLLAR..u8'Заработано денег: ' ..separator(zarmonsesia))
      end 
      imgui.CenterText(fa.CIRCLE_DOLLAR..u8'Заработано денег учётом охраны: '..separator(moneyoherallses))
      imgui.Separator()
      if settings.cfg.azcfg then 
      imgui.CenterText(fa.CIRCLE_DOLLAR..u8'Заработано AZ-coins:  '..azzarsesia.. 'шт.')
      end
      if settings.cfg.boshkamenu then 
      imgui.CenterText(fa.CIRCLE_DOLLAR..u8'Продано бочек: '..boxhkosesia.. 'шт.')
      end 
      imgui.Separator()
      imgui.Text(fa.CLOCK..u8' Текущее время: '..os.date("%H:%M:%S"))
      imgui.End()
      end)
      
  
      function sampev.onServerMessage(color, text)
          local proc = text:match('нефтебочки увеличена на (%d+).+, поскольку у вашего охранника есть специальная характеристика')
          moneyoherallses = moneyoherallses+boolGivemoney[0]*proc/100
          settings.cfg.moneyoherall = settings.cfg.moneyoherall+boolGivemoney[0]*proc/100
          cfg_save()
if text:match('Вы успешно продали бочку') then
        settings.cfg.zarmon = settings.cfg.zarmon+boolGivemoney[0]
        zarmonsesia = zarmonsesia+boolGivemoney[0]
        azzarsesia = azzarsesia + 1
        settings.cfg.azzar = settings.cfg.azzar + 1      
                boxhkosesia = boxhkosesia + 1
        settings.cfg.boshkiini = settings.cfg.boshkiini + 1
        cfg_save()
        end
end 
      function deleteAll()
 azzarsesia=0
 zarmonsesia=0
 settings.cfg.azzar = 0
 settings.cfg.zarmon=0
 settings.cfg.boshkiini=0
 boxhkosesia=0
 moneyoherallses=0
	moneyoherall=0
 cfg_save()
 msg('Статистика сброшена')
end  
  imgui.OnInitialize(function()
  decor()
    local tmp = imgui.ColorConvertU32ToFloat4(settings.theme['moonmonet'])
  gen_color = monet.buildColors(settings.theme.moonmonet, 1.0, true)
  mmcolor = imgui.new.float[3](tmp.z, tmp.y, tmp.x)
  apply_n_t()
end) 
function sampev.onShowDialog(id, style, title, button1, button2, text)
    if skipdi[0] == true and title:find("Покупка бочки") then
        sampSendDialogResponse(id, 1, nil, nil)
        return false
    end
      if viborts[0] and title:find('Бочки в транспорте') then
        for line in text:gmatch('([^\n\r]+)') do
            line = line:gsub('{......}', ' ')
            local num, status = line:match('%№(%d+) (.+)')           
            if status:find('Забрать') and viborts[0] and not objectcheck then
                sampSendDialogResponse(id,1,num-1,'')
                return false
            end
       end 
end 
end 

function msg(text)
    gen_color = monet.buildColors(settings.theme.moonmonet, 1.0, true)
    local a, r, g, b = explode_argb(gen_color.accent1.color_300)
    curcolor = '{' .. rgb2hex(r, g, b) .. '}'
    curcolor1 = '0x' .. ('%X'):format(gen_color.accent1.color_300)
    sampAddChatMessage("[Oil Tool]: {FFFFFF}" .. text, curcolor1)
end

function script_reload()
lua_thread.create(function()
wait(0)
thisScript():reload()
end)
end

function script_unload()
lua_thread.create(function()
wait(0)
thisScript():unload()
end)
end


--Автообновление взял у MTG MODS автор разрешил https://t.me/mtgmods
imgui.OnFrame(function() return found_update[0] end, function(player)
    imgui.SetNextWindowPos(imgui.ImVec2(sizeX / 2, sizeY / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		imgui.Begin(fa.CIRCLE_INFO .. u8" Оповещение##found_update", _, imgui.WindowFlags.NoCollapse + imgui.WindowFlags.NoResize + imgui.WindowFlags.AlwaysAutoResize )
    imgui.CenterText(u8'У вас сейчас установлена версия хелпера ' .. u8(tostring(thisScript().version)) .. ".")
		imgui.CenterText(u8'В базе данных найдена версия хелпера - ' .. u8(updateVer) .. ".")
		imgui.CenterText(u8'Рекомендуется обновиться, дабы иметь весь актуальный функционал!')
		imgui.Separator()
		imgui.CenterText(u8('Что нового в версии ') .. u8(updateVer) .. ':')
		imgui.Text(u8(updateInfoText))
		imgui.Separator()
		if imgui.Button(fa.CIRCLE_XMARK .. u8' Не обновлять ',  imgui.ImVec2(300 * settings.cfg.custom_dpi, 25 * settings.cfg.custom_dpi)) then
			found_update[0] = false
		end
		imgui.SameLine()
		if imgui.Button(fa.DOWNLOAD ..u8' Загрузить новую версию',  imgui.ImVec2(300 * settings.cfg.custom_dpi, 25 * settings.cfg.custom_dpi)) then
			download_helper = true
			downloadFileFromUrlToPath(updateUrl, path_helper)
		found_update[0] = false
		end
		imgui.End()
    end
)

   
function decor()
	imgui.SwitchContext()
	local ImVec4 = imgui.ImVec4
	imgui.GetStyle().WindowPadding = imgui.ImVec2(5, 5)
	imgui.GetStyle().FramePadding = imgui.ImVec2(5, 5)
	imgui.GetStyle().ItemSpacing = imgui.ImVec2(5, 5)
	imgui.GetStyle().ItemInnerSpacing = imgui.ImVec2(2, 2)
	imgui.GetStyle().TouchExtraPadding = imgui.ImVec2(0, 0)
	imgui.GetStyle().IndentSpacing = 0
	imgui.GetStyle().ScrollbarSize = 10
	imgui.GetStyle().GrabMinSize = 10
	imgui.GetStyle().WindowBorderSize = 1
	imgui.GetStyle().ChildBorderSize = 1
	imgui.GetStyle().PopupBorderSize = 1
	imgui.GetStyle().FrameBorderSize = 1
	imgui.GetStyle().TabBorderSize = 1
	imgui.GetStyle().WindowRounding = 8
	imgui.GetStyle().ChildRounding = 8
	imgui.GetStyle().FrameRounding = 8
	imgui.GetStyle().PopupRounding = 8
	imgui.GetStyle().ScrollbarRounding = 8
	imgui.GetStyle().GrabRounding = 8
	imgui.GetStyle().TabRounding = 8
 end
function imgui.ToggleButton(str_id, value)
	local duration = 0.3
	local p = imgui.GetCursorScreenPos()
    local DL = imgui.GetWindowDrawList()
	local size = imgui.ImVec2(65, 35)
    local title = str_id:gsub('##.*$', '')
    local ts = imgui.CalcTextSize(title)
    local cols = {
    	enable = imgui.GetStyle().Colors[imgui.Col.ButtonActive],
    	disable = imgui.GetStyle().Colors[imgui.Col.TextDisabled]	
    }
    local radius = 6
    local o = {
    	x = 4,
    	y = p.y + (size.y / 2)
    }
    local A = imgui.ImVec2(p.x + radius + o.x, o.y)
    local B = imgui.ImVec2(p.x + size.x - radius - o.x, o.y)

    if AI_TOGGLE[str_id] == nil then
        AI_TOGGLE[str_id] = {
        	clock = nil,
        	color = value[0] and cols.enable or cols.disable,
        	pos = value[0] and B or A
        }
    end
    local pool = AI_TOGGLE[str_id]
    
    imgui.BeginGroup()
	    local pos = imgui.GetCursorPos()
	    local result = imgui.InvisibleButton(str_id, imgui.ImVec2(size.x, size.y))
	    if result then
	        value[0] = not value[0]
	        pool.clock = os.clock()
	    end
	    if #title > 0 then
		    local spc = imgui.GetStyle().ItemSpacing
		    imgui.SetCursorPos(imgui.ImVec2(pos.x + size.x + spc.x, pos.y + ((size.y - ts.y) / 2)))
	    	imgui.Text(title)
    	end
    imgui.EndGroup()

 	if pool.clock and os.clock() - pool.clock <= duration then
        pool.color = bringVec4To(
            imgui.ImVec4(pool.color),
            value[0] and cols.enable or cols.disable,
            pool.clock,
            duration
        )

        pool.pos = bringVec2To(
        	imgui.ImVec2(pool.pos),
        	value[0] and B or A,
        	pool.clock,
            duration
        )
    else
        pool.color = value[0] and cols.enable or cols.disable
        pool.pos = value[0] and B or A
    end

	DL:AddRect(p, imgui.ImVec2(p.x + size.x, p.y + size.y), ToU32(pool.color), 10, 15, 1)
	DL:AddCircleFilled(pool.pos, radius, ToU32(pool.color))

    return result
end

function bringVec4To(from, to, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return imgui.ImVec4(
            from.x + (count * (to.x - from.x) / 100),
            from.y + (count * (to.y - from.y) / 100),
            from.z + (count * (to.z - from.z) / 100),
            from.w + (count * (to.w - from.w) / 100)
        ), true
    end
    return (timer > duration) and to or from, false
end

function bringVec2To(from, to, start_time, duration)
    local timer = os.clock() - start_time
    if timer >= 0.00 and timer <= duration then
        local count = timer / (duration / 100)
        return imgui.ImVec2(
            from.x + (count * (to.x - from.x) / 100),
            from.y + (count * (to.y - from.y) / 100)
        ), true
    end
    return (timer > duration) and to or from, false
end

CButton = {}
function imgui.CustomButton(bool,icon,text,duration)
    -- \\ Variables
    icon = icon or '#'
    text = text or 'None'
    size = size or imgui.ImVec2(350, 50)
    duration = duration or 0.50

    local dl = imgui.GetWindowDrawList()
    local p = imgui.GetCursorScreenPos()

    if not CButton[text] then
        CButton[text] = {time = nil}
    end

    -- \\ Button
    local result = imgui.InvisibleButton(text, size)
    if result and not bool then
        CButton[text].time = os.clock()
    end

    if bool then
        if CButton[text].time and (os.clock() - CButton[text].time) < duration then
            local wide = (os.clock() - CButton[text].time) * (size.x / duration)
            dl:AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + wide, p.y + size.y), 0xFF404040,5)
        else
            dl:AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + size.x, p.y + size.y), 0xFF404040,5,5)

            imgui.SetCursorPos(imgui.ImVec2(size.x+1,imgui.GetCursorPosY()-size.y-5))
            local p = imgui.GetCursorScreenPos()
            dl:AddRectFilled(imgui.ImVec2(p.x,p.y),imgui.ImVec2(p.x+3,p.y+size.y),0xFF808080,10)
        end
    else
        if imgui.IsItemHovered() then
            dl:AddRectFilled(imgui.ImVec2(p.x, p.y), imgui.ImVec2(p.x + size.x, p.y + size.y), 0xFF404040,5)
        end
    end

    -- \\ Text
    imgui.SameLine(5); imgui.SetCursorPosY(imgui.GetCursorPos().y + 9)
    if bool then
        imgui.Text((' '):rep(3) .. icon)
        imgui.SameLine(50)
        imgui.Text(text)
    else
        imgui.TextColored(imgui.ImVec4(0.60, 0.60, 0.60, 1.00), (' '):rep(3) .. icon)
        imgui.SameLine(50)
        imgui.TextColored(imgui.ImVec4(0.60, 0.60, 0.60, 1.00), text)
    end
    
    -- \\ Normal display
    imgui.SetCursorPosY(imgui.GetCursorPos().y - 9)

    -- \\ Result button
    return result
end
function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end

function main()
if not isSampfuncsLoaded() or not isSampLoaded() then return end
	while not isSampAvailable() do wait(100) end
	while not sampIsLocalPlayerSpawned() do wait(0) end
msg("Загрузка хелпера прошла успешно!")
print(' Загрузка хелпера прошла успешно!')
msg("Чтоб открыть меню хелпера введите команду /oil")
check_update()
sampRegisterChatCommand('oil', function() mainMenu[0] = not mainMenu[0]
end)
end

function isMonetLoader() return MONET_VERSION ~= nil end
if isMonetLoader() then
gta = ffi.load('GTASA') 
ffi.cdef[[
    void _Z12AND_OpenLinkPKc(const char* link);
]]

function openLink(link)
    gta._Z12AND_OpenLinkPKc(link)
	end
	
	if not settings.cfg.autofind_dpi then
	print('Применение авто-размера менюшек...')
	if isMonetLoader() then
		settings.cfg.custom_dpi = MONET_DPI_SCALE
	else
		local base_width = 1366
		local base_height = 768
		local current_width, current_height = getScreenResolution()
		local width_scale = current_width / base_width
		local height_scale = current_height / base_height
		settings.cfg.custom_dpi = (width_scale + height_scale) / 2
	end
	settings.cfg.autofind_dpi = true
	print('Установлено значение: ' .. settings.cfg.custom_dpi)
	cfg_save()
end


function imgui.CenterText(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.Text(text)
end
function imgui.CenterTextDisabled(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
    imgui.TextDisabled(text)
end
function imgui.CenterColumnText(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.Text(text)
end
function imgui.CenterColumnTextDisabled(text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
    imgui.TextDisabled(text)
end
function imgui.CenterColumnColorText(imgui_RGBA, text)
    imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	imgui.TextColored(imgui_RGBA, text)
end
function imgui.CenterButton(text)
    local width = imgui.GetWindowWidth()
    local calc = imgui.CalcTextSize(text)
    imgui.SetCursorPosX( width / 2 - calc.x / 2 )
	if imgui.Button(text) then
		return true
	else
		return false
	end
end
function imgui.CenterColumnButton(text)
	if text:find('(.+)##(.+)') then
		local text1, text2 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text1).x / 2)
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	end
    if imgui.Button(text) then
		return true
	else
		return false
	end
end
function imgui.CenterColumnSmallButton(text)
	if text:find('(.+)##(.+)') then
		local text1, text2 = text:match('(.+)##(.+)')
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text1).x / 2)
	else
		imgui.SetCursorPosX((imgui.GetColumnOffset() + (imgui.GetColumnWidth() / 2)) - imgui.CalcTextSize(text).x / 2)
	end
    if imgui.SmallButton(text) then
		return true
	else
		return false
	end
end
function imgui.GetMiddleButtonX(count)
    local width = imgui.GetWindowContentRegionWidth() 
    local space = imgui.GetStyle().ItemSpacing.x
    return count == 1 and width or width/count - ((space * (count-1)) / count)
end
	
function apply_monet()
	imgui.SwitchContext()
	local style = imgui.GetStyle()
	local colors = style.Colors
	local clr = imgui.Col
	local ImVec4 = imgui.ImVec4
    style.WindowPadding = imgui.ImVec2(15, 15)
    style.WindowRounding = 10.0
    style.ChildRounding = 6.0
    style.FramePadding = imgui.ImVec2(8, 7)
    style.FrameRounding = 8.0
    style.ItemSpacing = imgui.ImVec2(8, 8)
    style.ItemInnerSpacing = imgui.ImVec2(10, 6)
    style.IndentSpacing = 25.0
    style.ScrollbarSize = 25.0
    style.ScrollbarRounding = 12.0
    style.GrabMinSize = 10.0
    style.GrabRounding = 6.0
    style.PopupRounding = 8
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.5)
    style.ButtonTextAlign = imgui.ImVec2(0.5, 0.5)
	local generated_color = monet.buildColors(settings.theme.moonmonet, 1.0, true)
	colors[clr.Text] = ColorAccentsAdapter(generated_color.accent2.color_50):as_vec4()
	colors[clr.TextDisabled] = ColorAccentsAdapter(generated_color.neutral1.color_600):as_vec4()
	colors[clr.WindowBg] = ColorAccentsAdapter(generated_color.accent2.color_900):as_vec4()
	colors[clr.ChildBg] = ColorAccentsAdapter(generated_color.accent2.color_800):as_vec4()
	colors[clr.PopupBg] = ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
	colors[clr.Border] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0xcc):as_vec4()
	colors[clr.Separator] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0xcc):as_vec4()
	colors[clr.BorderShadow] = imgui.ImVec4(0.00, 0.00, 0.00, 0.00)
	colors[clr.FrameBg] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x60):as_vec4()
	colors[clr.FrameBgHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x70):as_vec4()
	colors[clr.FrameBgActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x50):as_vec4()
	colors[clr.TitleBg] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xcc):as_vec4()
	colors[clr.TitleBgCollapsed] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0x7f):as_vec4()
	colors[clr.TitleBgActive] = ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
	colors[clr.MenuBarBg] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x91):as_vec4()
	colors[clr.ScrollbarBg] = imgui.ImVec4(0,0,0,0)
	colors[clr.ScrollbarGrab] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x85):as_vec4()
	colors[clr.ScrollbarGrabHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.ScrollbarGrabActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	colors[clr.CheckMark] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	colors[clr.SliderGrab] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	colors[clr.SliderGrabActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0x80):as_vec4()
	colors[clr.Button] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	colors[clr.ButtonHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.ButtonActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	colors[clr.Tab] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	colors[clr.TabActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	colors[clr.TabHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.Header] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xcc):as_vec4()
	colors[clr.HeaderHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.HeaderActive] = ColorAccentsAdapter(generated_color.accent1.color_600):apply_alpha(0xb3):as_vec4()
	colors[clr.ResizeGrip] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xcc):as_vec4()
	colors[clr.ResizeGripHovered] = ColorAccentsAdapter(generated_color.accent2.color_700):as_vec4()
	colors[clr.ResizeGripActive] = ColorAccentsAdapter(generated_color.accent2.color_700):apply_alpha(0xb3):as_vec4()
	colors[clr.PlotLines] = ColorAccentsAdapter(generated_color.accent2.color_600):as_vec4()
	colors[clr.PlotLinesHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.PlotHistogram] = ColorAccentsAdapter(generated_color.accent2.color_600):as_vec4()
	colors[clr.PlotHistogramHovered] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.TextSelectedBg] = ColorAccentsAdapter(generated_color.accent1.color_600):as_vec4()
	colors[clr.ModalWindowDimBg] = ColorAccentsAdapter(generated_color.accent1.color_200):apply_alpha(0x26):as_vec4()
end

function apply_n_t()
    gen_color = monet.buildColors(settings.theme.moonmonet, 1.0, true)
    local a, r, g, b = explode_argb(gen_color.accent1.color_300)
  curcolor = '{'..rgb2hex(r, g, b)..'}'
    curcolor1 = '0x'..('%X'):format(gen_color.accent1.color_300)
    apply_monet()
end

function explode_argb(argb)
    local a = bit.band(bit.rshift(argb, 24), 0xFF)
    local r = bit.band(bit.rshift(argb, 16), 0xFF)
    local g = bit.band(bit.rshift(argb, 8), 0xFF)
    local b = bit.band(argb, 0xFF)
    return a, r, g, b
end

function rgb2hex(r, g, b)
    local hex = string.format("#%02X%02X%02X", r, g, b)
    return hex
end

function ColorAccentsAdapter(color)
    local a, r, g, b = explode_argb(color)
    local ret = {a = a, r = r, g = g, b = b}
    function ret:apply_alpha(alpha)
        self.a = alpha
        return self
    end
    function ret:as_u32()
        return join_argb(self.a, self.b, self.g, self.r)
    end
    function ret:as_vec4()
        return imgui.ImVec4(self.r / 255, self.g / 255, self.b / 255, self.a / 255)
    end
    function ret:as_argb()
        return join_argb(self.a, self.r, self.g, self.b)
    end
    function ret:as_rgba()
        return join_argb(self.r, self.g, self.b, self.a)
    end
    function ret:as_chat()
        return string.format("%06X", ARGBtoRGB(join_argb(self.a, self.r, self.g, self.b)))
    end
    return ret
end

function join_argb(a, r, g, b)
    local argb = b  -- b
    argb = bit.bor(argb, bit.lshift(g, 8))  -- g
    argb = bit.bor(argb, bit.lshift(r, 16)) -- r
    argb = bit.bor(argb, bit.lshift(a, 24)) -- a
    return argb
end

local function ARGBtoRGB(color)
    return bit.band(color, 0xFFFFFF)
		end
	end
	
	function onScriptTerminate(script, game_quit)
    if script == thisScript() and not game_quit and not reload_script then
		msg('Произошла неизвестная ошибка, хелпер приостановил свою работу!')
		end
	end