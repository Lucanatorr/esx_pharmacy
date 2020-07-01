ESX = nil

local enteredMarker, currentAction, currentActionMsg, currentActionData = false, nil, nil, {}
local hours, fastHealing = 0, false

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(100)
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)
		hours = GetClockHours()
		
		if currentAction ~= nil then
			ESX.ShowHelpNotification(currentActionMsg)

			if IsControlJustReleased(0, 38) then
				if currentAction == 'pharm_menu' then
					OpenPharmMenu(currentActionData.location)
				end

				currentAction = nil
			end
		else
			Citizen.Wait(500)
		end
	end
end)

Citizen.CreateThread(function()

	if Config.UseBlip then
		for k,v in pairs(Config.ShopLocations) do
			local blip = AddBlipForCoord(v.loc.x, v.loc.y, v.loc.z)


			SetBlipSprite (blip, Config.Blip.BlipType.Sprite)
			SetBlipDisplay(blip, Config.Blip.BlipType.Display)
			SetBlipScale  (blip, Config.Blip.BlipType.Scale)
			SetBlipColour (blip, Config.Blip.BlipType.Color)
			SetBlipAsShortRange(blip, true)

			BeginTextCommandSetBlipName('STRING')
			AddTextComponentSubstringPlayerName(_U('blip_name'))
			EndTextCommandSetBlipName(blip)
		end
    end
end)

Citizen.CreateThread(function()

	if Config.UseNPCShop then

        RequestModel(Config.NPCModel)
        while not HasModelLoaded(Config.NPCModel) do
            Wait(1)
		end

		for k,v in pairs(Config.ShopLocations) do
		
			ped = CreatePed(1, Config.NPCModel, v.loc.x, v.loc.y, v.loc.z - .65, v.npcHeading.h, false, true)
			
        	SetBlockingOfNonTemporaryEvents(ped, true)
        	SetPedDiesWhenInjured(ped, false)
    		SetPedCanPlayAmbientAnims(ped, true)
       		SetPedCanRagdollFromPlayerImpact(ped, false)
			SetEntityInvincible(ped, true)
    		FreezeEntityPosition(ped, true)
			TaskStartScenarioInPlace(ped, "WORLD_HUMAN_CLIPBOARD", 0, true)
		end
	end
end)

Citizen.CreateThread(function()
    while true do
		Citizen.Wait(0)
		
		local inMarker = false
		local playerCoords = GetEntityCoords(PlayerPedId())

		for k,v in pairs(Config.ShopLocations) do
			local distance = GetDistanceBetweenCoords(playerCoords, v.loc.x, v.loc.y, v.loc.z, true)

			if distance <= Config.DrawDistance then
				if Config.UseMarker then
					DrawMarker(Config.MarkerType, v.loc.x, v.loc.y, v.loc.z - .6, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Size.x, Config.Size.y, Config.Size.z, Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, 100, false, true, 2, false, nil, nil, false)
					
					if distance <= Config.Size.x then
						inMarker = true
						currentZone = k
					end
				elseif not Config.UseMarker then
					if distance <= Config.Size.x then
						inMarker = true
						currentZone = k
					end
				end
			end
		end

		if inMarker and not enteredMarker then
			if hours >= 7 and hours <= 19 then
				enteredMarker = true
				TriggerEvent('esx_pharmacy:enteredMarker', currentZone)
			else
				ESX.ShowNotification(_U('come_back_later'), false, true, 70)
			end
		elseif not inMarker and enteredMarker then
			enteredMarker = false
			TriggerEvent('esx_pharmacy:exitedMarker')
		end

		if fastHealing then
			Citizen.Wait(120000) --2 minutes
			SetPlayerHealthRechargeMultiplier(ped, 1.0)
			fastHealing = false
		end
    end
end)

AddEventHandler('esx_pharmacy:enteredMarker', function(location)
	currentAction = 'pharm_menu'
	currentActionMsg = _U('help_text')
	currentActionData = {location = location}
end)

AddEventHandler('esx_pharmacy:exitedMarker', function(location)
	currentAction = nil
	ESX.UI.Menu.CloseAll()
end)



function OpenPharmMenu(location)
	local elements = {
		{label = ('Buy'), value = 'buy_menu'},
		{label = ('Prescriptions'), value = 'pres_menu'},
	}
	local items = {}
	local presItems = {}

	for i=1, #Config.ShopLocations[location].items, 1 do
		local item = Config.ShopLocations[location].items[i]
		local price = item.price
		local label = item.label

		table.insert(items, {
			label      = ('%s - <span style="color:green;">%s</span>'):format(label, _U('shop_item', ESX.Math.GroupDigits(price))),
			itemLabel = label,
			item       = item.item,
			price      = price,

			-- menu properties
			value      = 1,
			type       = 'slider',
			min        = 1,
			max        = 50
		})
	end

	for i=1, #Config.PrescriptionItems, 1 do
		local item = Config.PrescriptionItems[i]
		local label = item.label
		local maxRefill = item.maxRefill
		local price = item.price

		table.insert(presItems, {
			label      = ('%s - <span style="color:green;">%s</span>'):format(label, _U('shop_item', ESX.Math.GroupDigits(price))),
			itemLabel = label,
			item       = item.item,
			price      = price,

			-- menu properties
			value      = 1,
			type       = 'slider',
			min        = 1,
			max        = maxRefill
		})
	end

	ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pharm_menu', {
        title    = _U('shop_title'),
        align    = 'right',
        elements = elements
    }, function(data, menu)

    if data.current.value == 'buy_menu' then

        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pharm_shop', {
			title    = _U('shop_title'),
			align    = 'right',
			elements = items
		}, function(data, menu)
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
				title    = _U('shop_confirm', data.current.value, data.current.itemLabel, ESX.Math.GroupDigits(data.current.price * data.current.value)),
				align    = 'right',
				elements = {
					{label = _U('no'),  value = 'no'},
					{label = _U('yes'), value = 'yes'}
			}}, function(data2, menu2)
				if data2.current.value == 'yes' then
					TriggerServerEvent('esx_pharmacy:buyItem', data.current.item, data.current.value, data.current.price, data.current.itemLabel)
				else
					menu2.close()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
        

    elseif data.current.value == 'pres_menu' then
        ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'pharm_shop', {
			title    = _U('shop_title'),
			align    = 'right',
			elements = presItems
		}, function(data, menu)
			ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'shop_confirm', {
				title    = _U('shop_confirm', data.current.value, data.current.itemLabel, ESX.Math.GroupDigits(data.current.price * data.current.value)),
				align    = 'right',
				elements = {
					{label = _U('no'),  value = 'no'},
					{label = _U('yes'), value = 'yes'}
			}}, function(data2, menu2)
				if data2.current.value == 'yes' then
					TriggerServerEvent('esx_pharmacy:presCheck', data.current.item, data.current.value, data.current.price, data.current.itemLabel, data.current.max)
				else
					menu2.close()
				end
			end, function(data2, menu2)
				menu2.close()
			end)
		end, function(data, menu)
			menu.close()
		end)
        
    end

    end, function(data, menu)
        menu.close()
		menuOpen = false
		
		currentAction = 'pharm_menu'
		currentActionMsg = _U('help_text')
		currentActionData = {location = location}
    end)
end

---Using the item---
local ped = PlayerPedId()
local getPed = GetPlayerPed(-1)
local maxHealth = GetEntityMaxHealth(ped)
local lib, anim = 'mp_player_intdrink', 'loop_bottle'

RegisterNetEvent('esx_pharmacy:painkillers')
AddEventHandler('esx_pharmacy:painkillers', function(source)
	local health = GetEntityHealth(ped)

	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(getPed, lib, anim, 1.0, -1.0, 2000, 0, 1, true, true, true)
	end)

	if health < 200 and health > 100 then
		if health < 125 and health > 100 then
			SetEntityHealth(ped, 125)

			SetPlayerHealthRechargeMultiplier(ped, 1.2)
			fastHealing = true

			ESX.ShowNotification(_U('used_painkiller'), false, true, 70)
		elseif health < 150 and health >= 125 then
			SetEntityHealth(ped, 150)
			
			SetPlayerHealthRechargeMultiplier(ped, 1.2)
			fastHealing = true

			ESX.ShowNotification(_U('used_painkiller'), false, true, 70)
		elseif health < 175 and health >= 150 then
			SetEntityHealth(ped, 175)
			
			SetPlayerHealthRechargeMultiplier(ped, 1.2)
			fastHealing = true

			ESX.ShowNotification(_U('used_painkiller'), false, true, 70)
		elseif health < 200 and health >= 175 then
			SetEntityHealth(ped, 200)
			
			SetPlayerHealthRechargeMultiplier(ped, 1.2)
			fastHealing = true
			ESX.ShowNotification(_U('used_painkiller'), false, true, 70)
		end
	end
end)

RegisterNetEvent('esx_pharmacy:presPainkillers')
AddEventHandler('esx_pharmacy:presPainkillers', function(source)
	local health = GetEntityHealth(ped)

	ESX.Streaming.RequestAnimDict(lib, function()
		TaskPlayAnim(getPed, lib, anim, 1.0, -1.0, 2000, 0, 1, true, true, true)
	end)

	if health < 200 and health > 100 then
		if health < 125 and health > 100 then
			SetEntityHealth(ped, 125)
			SetPlayerHealthRechargeMultiplier(ped, 1.2)
			fastHealing = true
			
			ESX.ShowNotification(_U('used_painkiller'), false, true, 70)
			AddArmourToPed(ped, 25)
		elseif health < 150 and health >= 125 then
			SetEntityHealth(ped, 150)
			SetPlayerHealthRechargeMultiplier(ped, 1.2)
			fastHealing = true

			ESX.ShowNotification(_U('used_painkiller'), false, true, 70)
			AddArmourToPed(ped, 25)
		elseif health < 175 and health >= 150 then
			SetEntityHealth(ped, 175)
			SetPlayerHealthRechargeMultiplier(ped, 1.2)
			fastHealing = true

			ESX.ShowNotification(_U('used_painkiller'), false, true, 70)
			AddArmourToPed(ped, 50)
		elseif health < 200 and health >= 175 then
			SetEntityHealth(ped, 200)
			SetPlayerHealthRechargeMultiplier(ped, 1.2)
			fastHealing = true

			AddArmourToPed(ped, 50)
			ESX.ShowNotification(_U('used_painkiller'), false, true, 70)
		end
	elseif health == maxHealth then
		AddArmourToPed(ped, 50)
	end

	if Config.UsingMythicHospital then
		exports['mythic_hospital']:ResetAll()
	end
end)
