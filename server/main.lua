---------------------------------------
--     ESX_WEEDSHOP by Dividerz      --
-- FOR SUPPORT: Arne#7777 on Discord --
---------------------------------------

ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback('esx_weedshop:callback:getWeedStorage', function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM weedshop WHERE type = @type', { ['@type'] = 'weed' }, function(result)
        cb(result[1].amount)
    end)
end)

ESX.RegisterServerCallback('esx_weedshop:callback:getJointStorage', function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM weedshop WHERE type = @type', { ['@type'] = 'joint' }, function(result)
        cb(result[1].amount)
    end)
end)

ESX.RegisterServerCallback('esx_weedshop:callback:getRegisterAmount', function(source, cb)
    MySQL.Async.fetchAll('SELECT * FROM weedshop WHERE type = @type', { ['@type'] = 'register' }, function(result)
        cb(result[1].amount)
    end)
end)

ESX.RegisterServerCallback('esx_weedshop:callback:getPlayerCashMoney', function(source, cb)
    local sourcePlayer = ESX.GetPlayerFromId(source)
    
    --if Config.usingWeight then
    --    local amount = sourcePlayer.getAccount('money').money
    --else
        local amount = sourcePlayer.getMoney()
    --end

    if amount ~= nil then
        cb(amount)
    end
end)

ESX.RegisterServerCallback('esx_weedshop:callback:checkPlayerWeed', function(source, cb)
    local sourcePlayer = ESX.GetPlayerFromId(source)

    if sourcePlayer.getInventoryItem(Config.WeedItem).count > 0 then
        cb(true)
    else
        cb(false)
    end
end)

RegisterNetEvent('esx_weedshop:server:createJoint')
AddEventHandler('esx_weedshop:server:createJoint', function()
    local sourcePlayer = ESX.GetPlayerFromId(source)

    MySQL.Async.fetchAll('SELECT * FROM weedshop WHERE type = @type', { ['@type'] = 'weed' }, function(result)
        if result[1].amount >= 1 then --[[check weed amount]]
            MySQL.Async.execute('UPDATE weedshop SET amount = @amount WHERE type = @type', { ['@amount'] = result[1].amount - 1, ['@type'] = 'weed' })

            MySQL.Async.fetchAll('SELECT * FROM weedshop WHERE type = @type', { ['@type'] = 'joint' }, function(result2)
                MySQL.Async.execute('UPDATE weedshop SET amount = @amount WHERE type = @type', { ['@amount'] = result2[1].amount + 1, ['@type'] = 'joint' })
                sourcePlayer.showNotification('You rolled ~y~1~s~ joint.')
            end)
        else
            sourcePlayer.showNotification('There is not enough weed in the storage.')
        end
    end)

    -- ADD ONE JOINT
    --[[MySQL.Async.fetchAll('SELECT * FROM weedshop WHERE type = @type', { ['@type'] = 'joint' }, function(result)
        MySQL.Async.execute('UPDATE weedshop SET amount = @amount WHERE type = @type', { ['@amount'] = result[1].amount + 1, ['@type'] = 'joint' })
    end)

    -- DELETE ONE WEED
    MySQL.Async.fetchAll('SELECT * FROM weedshop WHERE type = @type', { ['@type'] = 'weed' }, function(result)
        MySQL.Async.execute('UPDATE weedshop SET amount = @amount WHERE type = @type', { ['@amount'] = result[1].amount - 1, ['@type'] = 'weed' })
    end)]]

    
end)

RegisterNetEvent('esx_weedshop:server:getRegisterMoney')
AddEventHandler('esx_weedshop:server:getRegisterMoney', function(amount)
    local sourcePlayer = ESX.GetPlayerFromId(source)

    -- REMOVE REGISTER MONEY
    MySQL.Async.fetchAll('SELECT * FROM weedshop WHERE type = @type', { ['@type'] = 'register' }, function(result)
        if amount <= result[1].amount then
            MySQL.Async.execute('UPDATE weedshop SET amount = @amount WHERE type = @type', { ['@amount'] = result[1].amount - amount, ['@type'] = 'register' })
            sourcePlayer.addMoney(amount)
            sourcePlayer.showNotification('You got ~g~$' .. amount .. '~s~ cash from the register.')
        else
            sourcePlayer.showNotification('There is not enough money in the register.')
        end
    end)
end)

RegisterNetEvent('esx_weedshop:server:buyJoint')
AddEventHandler('esx_weedshop:server:buyJoint', function(price)
    local sourcePlayer = ESX.GetPlayerFromId(source)

    if Config.usingWeight then
        if sourcePlayer.canCarryItem('joint', 1) then
            sourcePlayer.addInventoryItem('joint', 1)
            sourcePlayer.removeMoney(price)

            -- DELETE ONE JOINT FROM STORAGE
            MySQL.Async.fetchAll('SELECT * FROM weedshop WHERE type = @type', { ['@type'] = 'joint' }, function(result)
                MySQL.Async.execute('UPDATE weedshop SET amount = @amount WHERE type = @type', { ['@amount'] = result[1].amount - 1, ['@type'] = 'joint' })
            end)

            -- ADD MONEY TO REGISTER
            MySQL.Async.fetchAll('SELECT * FROM weedshop WHERE type = @type', { ['@type'] = 'register' }, function(result)
                MySQL.Async.execute('UPDATE weedshop SET amount = @amount WHERE type = @type', { ['@amount'] = result[1].amount + Config.JointPrice, ['@type'] = 'register' })
            end)
        else
            sourcePlayer.showNotification("You can't carry this item...")
        end
    else
        local sourceItem = sourcePlayer.getInventoryItem('joint')
        if sourceItem.limit ~= -1 and (sourceItem.count + 1) > sourceItem.limit then
            sourcePlayer.showNotification("You can't carry any more joints...")
        else
            sourcePlayer.addInventoryItem('joint', amount)
                -- DELETE ONE JOINT FROM STORAGE
            MySQL.Async.fetchAll('SELECT * FROM weedshop WHERE type = @type', { ['@type'] = 'joint' }, function(result)
                MySQL.Async.execute('UPDATE weedshop SET amount = @amount WHERE type = @type', { ['@amount'] = result[1].amount - 1, ['@type'] = 'joint' })
            end)

            -- ADD MONEY TO REGISTER
            MySQL.Async.fetchAll('SELECT * FROM weedshop WHERE type = @type', { ['@type'] = 'register' }, function(result)
                MySQL.Async.execute('UPDATE weedshop SET amount = @amount WHERE type = @type', { ['@amount'] = result[1].amount + Config.JointPrice, ['@type'] = 'register' })
            end)
        end        
    end
end)

RegisterNetEvent('esx_weedshop:server:sellWeed')
AddEventHandler('esx_weedshop:server:sellWeed', function()
    local sourcePlayer = ESX.GetPlayerFromId(source)
    local itemamount = sourcePlayer.getInventoryItem(Config.WeedItem).count

    if itemamount >= 1 then
        sourcePlayer.removeInventoryItem(Config.WeedItem, itemamount)
        sourcePlayer.addMoney(itemamount * Config.WeedPrice)

        -- ADD WEED TO STORAGE
        MySQL.Async.fetchAll('SELECT * FROM weedshop WHERE type = @type', { ['@type'] = 'weed' }, function(result)
            MySQL.Async.execute('UPDATE weedshop SET amount = @amount WHERE type = @type', { ['@amount'] = result[1].amount + itemamount, ['@type'] = 'weed' })
        end)

        sourcePlayer.showNotification("You sold ~y~" .. itemamount .. "~w~ x " .. Config.WeedItem .. " for ~g~$" .. itemamount * Config.WeedPrice .. "~w~.")
    else
        sourcePlayer.showNotification("You don\'t have any weed.")
    end
end)
