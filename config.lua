Config = {} --dont touch plz
Config.Locale = 'en'

Config.UsingMythicHospital = true --set to true if youre using mythic_hospital
---Marker configuration--
Config.UseMarker = true --set to true if you want to use a marker on the ground
Config.MarkerType = 27
Config.DrawDistance = 25
Config.MarkerColor = { r = 16, g = 113, b = 204 }
Config.Size = { x = 2.0, y = 2.0, z = 2.0}
-------------------------

--blip configuration--
Config.UseBlip = true
Config.Blip = {
    BlipType = {
        Sprite = 51,
        Display = 4,
        Scale = 0.8,
        Color = 4,
    },
}
---------------------


Config.PrescriptionItems = { --items available for prescription
    { item = 'ppainkiller', label = 'Prescription Painkillers', maxRefill = 3, price = 7500}
}
Config.UseNPCShop = true -- set to true if you want to use an NPC at all shop locations
Config.NPCModel = -730659924 --npc doctor hash
Config.ShopLocations = { --locations, add or remove as needed

    DollarPillsStrawberry = {
        loc = { x = 68.69, y = -1569.79, z = 29.3 },
        items = {
            { item = 'otcpainkiller', label = 'Painkillers', price = 1000 },
            { item = 'medikit', label = 'Medkit', price = 1500 },
            { item = 'bandage', label = 'Bandage', price = 750 },
            { item = 'firstaidpass', label = 'First-Aid License', price = 50000 },
        },
        npcHeading = { h = 50.83 },
    },

    DollarPillsHarmony = {
        loc = { x = 591.23, y = 2744.08, z = 41.70 },
        items = {
            { item = 'otcpainkiller', label = 'Painkillers', price = 1000 },
            { item = 'medikit', label = 'Medkit', price = 1500 },
            { item = 'bandage', label = 'Bandage', price = 750 },
            { item = 'firstaidpass', label = 'First-Aid License', price = 50000 },
        },
        npcHeading = { h = 186.59 },
    },

    DollarPillsHawick = {
        loc = { x = 96.71, y = -224.26, z = 54.25 },
        items = {
            { item = 'otcpainkiller', label = 'Painkillers', price = 1000 },
            { item = 'medikit', label = 'Medkit', price = 1500 },
            { item = 'bandage', label = 'Bandage', price = 750 },
            { item = 'firstaidpass', label = 'First-Aid License', price = 50000 },
        },
        npcHeading = { h = 349.34 },
    },

    BaySideDrugsPaleto = {
        loc = { x = -172.16, y = 6380.63, z = 31.1 },
        items = {
            { item = 'otcpainkiller', label = 'Painkillers', price = 1000 },
            { item = 'medikit', label = 'Medkit', price = 1500 },
            { item = 'bandage', label = 'Bandage', price = 750 },
            { item = 'firstaidpass', label = 'First-Aid License', price = 50000 },
        },
        npcHeading = { h = 228.65 },
    },

    OdeasChumash = {
        loc = { x = -3157.87, y = 1095.25, z = 20.50 },
        items = {
            { item = 'otcpainkiller', label = 'Painkillers', price = 1000 },
            { item = 'medikit', label = 'Medkit', price = 1500 },
            { item = 'bandage', label = 'Bandage', price = 750 },
            { item = 'firstaidpass', label = 'First-Aid License', price = 50000 },
        },
        npcHeading = { h = 228.65 },
    },
}

