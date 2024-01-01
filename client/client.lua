local RSGCore = exports['rsg-core']:GetCoreObject()
local createdEntries = {}
CanTakeDailyMission = false 
CanTakeHourlyMission = false 

--------------------------------------------
-- prompts and target
--------------------------------------------
Citizen.CreateThread(function()
    for _,v in pairs(Config.QuestNPC) do
        if not v.showtarget then
            exports['rsg-core']:createPrompt(v.prompt, v.promptcoords, RSGCore.Shared.Keybinds[Config.KeyShop], Lang:t('menu.open_prompt') .. v.name, {
                type = 'client',
                event = 'rsg-questsystem:client:CheckMissionMenu',
                args = { v.questtype },
            })
        else
            exports['rsg-target']:AddCircleZone(v.prompt, v.promptcoords, 2, {
                name = v.prompt,
                debugPoly = false,
            }, {
                options = {
                    {
                        type = "client",
                        label =  'Check Mission',
                        icon = "fas fa-comments-dollar",
                        action = function()
                            TriggerEvent('rsg-questsystem:client:CheckMissionMenu', v.questtype)
                        end,
                    },
                },
                distance = 3,
            })
        end
        if v.showblip == true then
            local QuestBlip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, v.promptcoords)
            SetBlipSprite(QuestBlip, joaat(v.blipSprite), true)
            SetBlipScale(QuestBlip, v.blipScale)
            Citizen.InvokeNative(0x9CB1A1623062F402, QuestBlip, v.blipName)
        end
    end
end)

--------------------------------------------
-- check if daily mission has been taken on login
--------------------------------------------
RegisterNetEvent('RSGCore:Client:OnPlayerLoaded', function()
    RSGCore.Functions.TriggerCallback('rsg-questsystem:server:CheckMission', function(data)
        CanTakeDailyMission = data
    end, "dailymission")
    RSGCore.Functions.TriggerCallback('rsg-questsystem:server:CheckMission', function(data)
        CanTakeHourlyMission = data
    end, "hourlymission")
end)

--------------------------------------------
-- check which mission menu
--------------------------------------------
RegisterNetEvent('rsg-questsystem:client:CheckMissionMenu', function(questtype)
    if questtype == 'daily' then
        TriggerEvent('rsg-questsystem:client:DailyMissionMenu')
    end
    if questtype == 'hourly' then
        TriggerEvent('rsg-questsystem:client:HourlyMissionMenu')
    end
end)

--------------------------------------------
-- daily mission menu
--------------------------------------------
RegisterNetEvent("rsg-questsystem:client:DailyMissionMenu", function()

    local DailyMissionMenu = {}

    DailyMissionMenu[#DailyMissionMenu+1] = {
        title = "Get Daily Quests",
        description = "Daily quests will reset when a new day passes",
        icon = 'fa-solid fa-eye',
        event = "rsg-questsystem:client:TakeDailyMission",
        arrow = true
    }

    DailyMissionMenu[#DailyMissionMenu+1] = {
        title = 'Checking process',
        description = "Check your current task progress",
        event = "rsg-questsystem:client:CheckProgress",
        args = { missiontype = 'dailymission' },
        arrow = true
    }

    lib.registerContext({
        id = 'daily_missions_menu',
        title = 'Daily Missions',
        position = 'top-right',
        options = DailyMissionMenu
    })

    lib.showContext('daily_missions_menu')
end)

--------------------------------------------
-- hourly mission menu
--------------------------------------------
RegisterNetEvent("rsg-questsystem:client:HourlyMissionMenu", function()

    local HourlyMissionMenu = {}

    HourlyMissionMenu[#HourlyMissionMenu+1] = {
        title = "Get Hourly Quests",
        description = "Daily quests will be reset every hour",
        icon = 'fa-solid fa-eye',
        event = "rsg-questsystem:client:TakeHourlyMission",
        arrow = true
    }

    HourlyMissionMenu[#HourlyMissionMenu+1] = {
        title = 'Checking process',
        description = "Check your current task progress",
        event = "rsg-questsystem:client:CheckProgress",
        args = { missiontype = 'hourlymission' },
        arrow = true
    }

    lib.registerContext({
        id = 'hourly_missions_menu',
        title = 'Hourly Quests',
        position = 'top-right',
        options = HourlyMissionMenu
    })

    lib.showContext('hourly_missions_menu')

end)

--------------------------------------------
-- take daily mission
--------------------------------------------
RegisterNetEvent("rsg-questsystem:client:TakeDailyMission", function()
    if RSGCore.Functions.GetPlayerData().metadata["dailymission"] == 0 or not RSGCore.Functions.GetPlayerData().metadata["dailymission"] then  
        RSGCore.Functions.TriggerCallback('rsg-questsystem:server:CheckMission', function(data)
            if data then 
                local Random_Mission = math.random(1, #Config.Daily_Mission)
                TriggerServerEvent("rsg-questsystem:server:TakeDailyMission", Random_Mission)
                TriggerEvent("rsg-questsystem:client:CheckProgress", "dailymission")
            end
        end, "dailymission")
    else 
        lib.notify({ title = 'Daily Mission', description = 'You have already received the day\'s mission, please wait for a new day', type = 'inform', duration = 7000 })
    end 
end)

--------------------------------------------
-- take hourly mission
--------------------------------------------
RegisterNetEvent("rsg-questsystem:client:TakeHourlyMission", function()
    if RSGCore.Functions.GetPlayerData().metadata["hourlymission"] == 0 or not RSGCore.Functions.GetPlayerData().metadata["hourlymission"] then
        RSGCore.Functions.TriggerCallback('rsg-questsystem:server:CheckMission', function(data)
            if data then 
                local Random_Mission = math.random(1, #Config.Hourly_Mission)
                TriggerServerEvent("rsg-questsystem:server:TakeHourlyMission", Random_Mission)
                TriggerEvent("rsg-questsystem:client:CheckProgress", "hourlymission")
            end
        end, "hourlymission")
    else 
        lib.notify({ title = 'Hourly Mission', description = 'You have already received the hourly mission, please wait a little longer', type = 'inform', duration = 7000 })
    end 
end)

--------------------------------------------
-- check mission progress
--------------------------------------------
RegisterNetEvent("rsg-questsystem:client:CheckProgress", function(data)
    if data.missiontype == 'dailymission' then
        if Config.Daily_Mission[RSGCore.Functions.GetPlayerData().metadata['dailymission']] then
            TriggerServerEvent('rsg-questsystem:server:CheckProgress', 'dailymission', Config.Daily_Mission[RSGCore.Functions.GetPlayerData().metadata["dailymission"]].required, Config.Daily_Mission[RSGCore.Functions.GetPlayerData().metadata["dailymission"]].reward_item, Config.Daily_Mission[RSGCore.Functions.GetPlayerData().metadata["dailymission"]].reward_money)
        end
    end
    if data.missiontype == 'hourlymission' then 
        if Config.Hourly_Mission[RSGCore.Functions.GetPlayerData().metadata["hourlymission"]] then 
            TriggerServerEvent('rsg-questsystem:server:CheckProgress', 'hourlymission', Config.Hourly_Mission[RSGCore.Functions.GetPlayerData().metadata["hourlymission"]].required, Config.Hourly_Mission[RSGCore.Functions.GetPlayerData().metadata["hourlymission"]].reward_item, Config.Hourly_Mission[RSGCore.Functions.GetPlayerData().metadata["hourlymission"]].reward_money)
        end 
    end 
end)
