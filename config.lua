Config = {}

-- settings
Config.DistanceSpawn = 20.0 -- Distance before spawning/despawning the ped. (GTA Units.)
Config.FadeIn = true
Config.Key = 'J'

-- prompt/npc/blip settings
Config.QuestNPC =
{
    {    --valentine hourly
        name            = 'Check Hourly Quest',
        prompt          = 'valquesthourly',
        questtype        = 'hourly',
        promptcoords    = vector3(-254.3225, 691.2926, 113.32689),
        npccoords       = vector4(-254.3225, 691.2926, 113.32689, 175.53314),
        showblip        = true,
        showtarget      = true,
        npcmodel         = `S_M_M_VALDEALER_01`,
        blipName        = 'Hourly Quest',
        blipSprite      = `blip_mp_deliver_target`,
        blipScale       = 0.2,
    },
    {    --valentine daily
        name            = 'Check Daily Quest',
        prompt          = 'valquestdaily',
        questtype       = 'daily',
        promptcoords    = vector3(-262.6245, 686.85748, 113.30184),
        npccoords       = vector4(-262.6245, 686.85748, 113.30184, 231.41958),
        showblip        = true,
        showtarget      = true,
        npcmodel        = `A_M_M_BlWForeman_01`,
        blipName        = 'Daily Quest',
        blipSprite      = `blip_mp_deliver_target`,
        blipScale       = 0.2,
    },
}

-- HOURLY TASKS
Config.Hourly_Mission = {
    {
        name = "Hardworking Farmer",
        label = "Collect 1 corn and 1 sugar",
        required = {
            ["corn"] = 1,
            ["sugar"] = 1,
        },
        reward_item = { -- BONUS ITEM
            --["questtoken"] = 1, 
        },
        reward_money = { -- BONUS MONEY
            ["cash"] = 1,
            -- ["bank"] = 100,
        }
    },
}

-- DAILY MISSION
Config.Daily_Mission = {
    {
        name = "Feed the People",
        label = "Collect 1 Cooked Meat and 1 Cooked Fish",
        required = {
            ["cooked_meat"] = 1,
            ["cooked_fish"] = 1,
        },
        reward_item = { -- BONUS ITEM
            --["questtoken"] = 1,
        }, 
        reward_money = { -- BONUS MONEY
            ["cash"] = 5,
        }
    },
}
