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
        args = {"dailymission"},
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
        args = {"hourlymission"},
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
