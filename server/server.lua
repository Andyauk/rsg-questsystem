local RSGCore = exports['rsg-core']:GetCoreObject()

--------------------------------------------
-- version checker
--------------------------------------------
local function versionCheckPrint(_type, log)
    local color = _type == 'success' and '^2' or '^1'

    print(('^5['..GetCurrentResourceName()..']%s %s^7'):format(color, log))
end

local function CheckVersion()
    PerformHttpRequest('https://raw.githubusercontent.com/Rexshack-RedM/rsg-questsystem/main/version.txt', function(err, text, headers)
        local currentVersion = GetResourceMetadata(GetCurrentResourceName(), 'version')

        if not text then 
            versionCheckPrint('error', 'Currently unable to run a version check.')
            return 
        end

        --versionCheckPrint('success', ('Current Version: %s'):format(currentVersion))
        --versionCheckPrint('success', ('Latest Version: %s'):format(text))
        
        if text == currentVersion then
            versionCheckPrint('success', 'You are running the latest version.')
        else
            versionCheckPrint('error', ('You are currently running an outdated version, please update to version %s'):format(text))
        end
    end)
end

--------------------------------------------
-- check mission callback
--------------------------------------------
RSGCore.Functions.CreateCallback('rsg-questsystem:server:CheckMission', function(source, cb, type)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    local DailyMission = Player.PlayerData.metadata["dailymission"] or false 
    local HourlyMission = Player.PlayerData.metadata["hourlymission"] or false

    if not DailyMission then 
        DailyMission = 0 
    end 

    if not HourlyMission then 
        HourlyMission = 0 
    end

    if type == "dailymission" then 
        cb(DailyMission)
   end
    if type == "hourlymission" then 
        cb(HourlyMission)
    end
end)

--------------------------------------------
-- take daily mission
--------------------------------------------
RegisterNetEvent("rsg-questsystem:server:TakeDailyMission", function(mission)
    local src = source 
    local Player = RSGCore.Functions.GetPlayer(src)
    local time_table = os.date ("*t")
    if tonumber(Player.PlayerData.metadata["dailymission_timestamp"]) ~= tonumber(time_table.day) then
        TriggerClientEvent('ox_lib:notify', src, {title = 'Daily Mission', description = 'You have received the daily quest called '..Config.Daily_Mission[mission].name..' This mission requires you '..Config.Daily_Mission[mission].label, type = 'success', duration = 7000 })
        Player.Functions.SetMetaData("dailymission_timestamp", time_table.day)
        Player.Functions.SetMetaData("dailymission", mission)
    else
        TriggerClientEvent('ox_lib:notify', src, {title = 'Daily Mission', description = 'You have already received the day\'s quest, please wait for a new day', type = 'error', duration = 7000 })
    end
end)

--------------------------------------------
-- take hourly mission
--------------------------------------------
RegisterNetEvent("rsg-questsystem:server:TakeHourlyMission", function(mission)
    local src = source 
    local Player = RSGCore.Functions.GetPlayer(src)
    local time_table = os.date ("*t")
    
    if Player.PlayerData.metadata["hourlymission_timestamp"] ~= time_table.hour then
        TriggerClientEvent('ox_lib:notify', src, {title = 'Hourly Mission', description = 'You have received the hourly quest called '..Config.Hourly_Mission[mission].name..' This mission requires you '..Config.Hourly_Mission[mission].label, type = 'success', duration = 7000 })

    Player.Functions.SetMetaData("hourlymission_timestamp", time_table.hour)
        Player.Functions.SetMetaData("hourlymission", mission)
    else 
        TriggerClientEvent('ox_lib:notify', src, {title = 'Hourly Mission', description = 'You have already received the hours\'s quest, please wait for a new hour', type = 'error', duration = 7000 })
    end
end)

--------------------------------------------
-- check mission progress
--------------------------------------------
RegisterNetEvent('rsg-questsystem:server:CheckProgress', function(missiontype, requiredTable, RewardItems, RewardMoney)
    local src = source 
    local Player = RSGCore.Functions.GetPlayer(src)
    local text = ""
    local reward_item_text = ""
    local reward_money_text = ""
    local progress = {}
    local progress_text = ""

    if hasMissionItems(src, requiredTable) then 
        completeMission(src, missiontype, RewardItems, RewardMoney)
    else 
        for k, v in pairs (requiredTable) do
            if Player.Functions.GetItemByName(k) then
                progress[k] = Player.Functions.GetItemByName(k).amount 
            else 
                progress[k] = 0
            end
            
            if progress[k] < v then 
                progress_text = "["..(progress[k]).."/" .. v .. "]"
            else 
                progress_text = "Finish"
            end 
            
            text = text.." - ".. RSGCore.Shared.Items[k]["label"] .. " "..progress_text.." "
        end

        for k, v in pairs (RewardItems) do
            
            reward_item_text = reward_item_text.." - "..v.." ".. RSGCore.Shared.Items[k]["label"] .. " "..reward_item_text.." "
        end

        for k, v in pairs(RewardMoney) do 
            if k == "cash" then 
                money_label = "CASH"
            else 
                money_label = "BANK"
            end 
            reward_money_text = reward_money_text.. " - "  ..money_label..": $"..v
        end
        TriggerClientEvent('ox_lib:notify', src, {title = 'Mission Status', description = text..' Reward '..reward_item_text..' '..reward_money_text, type = 'success', duration = 7000 })
    end
end)

--------------------------------------------
-- functions
--------------------------------------------
function hasMissionItems(source, CostItems)
    local Player = RSGCore.Functions.GetPlayer(source)
    for k, v in pairs(CostItems) do
        if Player.Functions.GetItemByName(k) ~= nil then
            if Player.Functions.GetItemByName(k).amount < (v) then
                return false
            end
        else
            return false
        end
    end
    for k, v in pairs(CostItems) do  
        Player.Functions.RemoveItem(k, v)
        TriggerClientEvent('inventory:client:ItemBox', source, RSGCore.Shared.Items[k], "remove")
    end
    return true
end

function completeMission(source, type, RewardItems, RewardMoney)
    local src = source
    local Player = RSGCore.Functions.GetPlayer(src)
    
    if type == "dailymission" then 
        Player.Functions.SetMetaData("dailymission", 0)
    elseif type == "hourlymission" then 
        Player.Functions.SetMetaData("hourlymission", 0)
    else 
        Player.Functions.SetMetaData(type.."_done", true)
    end


    if RewardItems ~= nil then
        for k, v in pairs(RewardItems) do
            Player.Functions.AddItem(k, v)
            TriggerClientEvent('inventory:client:ItemBox', src, RSGCore.Shared.Items[k], "add")
        end
    end 
    
    if RewardMoney ~= nil then
        for k, v in pairs(RewardMoney) do 
            Player.Functions.AddMoney(k, v)
        end
    end

    TriggerClientEvent('ox_lib:notify', source, {title = 'Congratulations', description = 'you completed the mission and got the reward', type = 'success', duration = 5000 })

end

--------------------------------------------
-- admin reset missions
--------------------------------------------
RSGCore.Commands.Add("resetmission", "Reset player's date/time quest", {{name = "id", help = "Player ID"}}, false, function(source, args)
    local src = source
    if args[1] then
        local Player = RSGCore.Functions.GetPlayer(tonumber(args[1]))
        if Player then
            TriggerClientEvent('hospital:client:Revive', Player.PlayerData.source)
            Player.Functions.SetMetaData("dailymission", 0)
            Player.Functions.SetMetaData("hourlymission", 0)
            Player.Functions.SetMetaData("dailymission_timestamp", 0)
            Player.Functions.SetMetaData("hourlymission_timestamp", 0)
            TriggerClientEvent('ox_lib:notify', src, {title = 'Missions Reset', description = 'You have reset the mission for '..Player.PlayerData.source, type = 'success' })
        else
            TriggerClientEvent('ox_lib:notify', src, {title = 'Error', description = "Players not online", type = 'error' })
        end
    else
        local Player = RSGCore.Functions.GetPlayer(src)
        TriggerClientEvent('ox_lib:notify', src, {title = 'Missions Reset', description = 'you reset your own missions', type = 'success' })
        Player.Functions.SetMetaData("dailymission", 0)
        Player.Functions.SetMetaData("hourlymission", 0)
        Player.Functions.SetMetaData("dailymission_timestamp", 0)
        Player.Functions.SetMetaData("hourlymission_timestamp", 0)
    end
end, "admin")

--------------------------------------------------------------------------------------------------
-- start version check
--------------------------------------------------------------------------------------------------
CheckVersion()
