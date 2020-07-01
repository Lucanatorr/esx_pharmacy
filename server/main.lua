ESX = nil
local refillsUsed = 0

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterCommand('givepres', 'user', function(xPlayer, args, showError)
	if xPlayer and xPlayer.job.name == 'ambulance' then
		args.playerId.addInventoryItem(args.item, args.count)
	else
		TriggerClientEvent('chatMessage', '', {255,0,0}, 'You do not have permission')
	end
end, true, {help = _U('givepres'), validate = true, arguments = {
	{name = 'playerId', help = 'Player ID', type = 'player'},
	{name = 'item', help = 'Prescription to give', type = 'item'},
	{name = 'count', help = 'Amount to give', type = 'number'}
}})

RegisterServerEvent('esx_pharmacy:buyItem')
AddEventHandler('esx_pharmacy:buyItem', function(item, amount, price, itemLabel)

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

	price = ESX.Math.Round(amount * price)

	if xPlayer.getMoney() >= price then
		if xPlayer.job.name == 'police' or xPlayer.job.name == 'ambulance' then
			price = ESX.Math.Round(price * 0.8) --20% discount for emergency services--
			
			if xPlayer.canCarryItem(item, amount) then
            	xPlayer.addInventoryItem(item, amount)

            	xPlayer.removeMoney(price)

				xPlayer.showNotification(_U('bought', amount, itemLabel, ESX.Math.GroupDigits(price)), false, true, 70)
				xPlayer.showHelpNotification(_U('given_discount'))
        	else
            	xPlayer.showNotification(_U('not_enough_space'), false, true, 70)
			end
		else
			if xPlayer.canCarryItem(item, amount) then
				xPlayer.addInventoryItem(item, amount)

				xPlayer.removeMoney(price)

				xPlayer.showNotification(_U('bought', amount, itemLabel, ESX.Math.GroupDigits(price)), false, true, 70)
			else
				xPlayer.showNotification(_U('not_enough_space'), false, true, 70)
			end
		end 
    else 
        local missingMoney = price - xPlayer.getMoney()

        xPlayer.showNotification(_U('not_enough_cash', ESX.Math.GroupDigits(missingMoney)), false, true, 70)
    end


end)

RegisterServerEvent('esx_pharmacy:presCheck')
AddEventHandler('esx_pharmacy:presCheck', function(item, amount, price, itemLabel, Maxrefills)

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)

	price = ESX.Math.Round(amount * price)


    if xPlayer.getMoney() >= price then
        if xPlayer.canCarryItem(item, amount) then
			if xPlayer.getInventoryItem('painpres').count > 0 then
				if item == 'ppainkiller' then
					if refillsUsed < Maxrefills then
						xPlayer.addInventoryItem(item, amount)

						refillsUsed = refillsUsed + amount
						xPlayer.showNotification(_U('bought', amount, itemLabel, ESX.Math.GroupDigits(price)), false, true, 70)
					elseif refillsUsed == Maxrefills then
						xPlayer.removeInventoryItem('painpres', 1)

						xPlayer.showNotification(_U('max_refills_met'), false, true, 70)
						refillsUsed = 0
					end
				end
			else
				xPlayer.showNotification(_U('no_pres'), false, true, 70)
			end
		else
			xPlayer.showNotification(_U('not_enough_space'), false, true, 70)
		end
	else 
        local missingMoney = price - xPlayer.getMoney()

        xPlayer.showNotification(_U('not_enough_cash', ESX.Math.GroupDigits(missingMoney)), false, true, 70)
    end
end)

----Usable Items----
ESX.RegisterUsableItem('otcpainkiller', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('otcpainkiller', 1)

	TriggerClientEvent('esx_pharmacy:painkillers', source)
end)

ESX.RegisterUsableItem('ppainkiller', function(source)
	local xPlayer = ESX.GetPlayerFromId(source)

	xPlayer.removeInventoryItem('ppainkiller', 1)

	TriggerClientEvent('esx_pharmacy:presPainkillers', source)
end)
