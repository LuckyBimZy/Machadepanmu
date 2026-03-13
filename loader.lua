-- ==================== LOADER.LUA ====================
-- Loader sederhana berdasarkan PlaceId
-- Simpan di root folder

local placeId = game.PlaceId
local githubRaw = "https://raw.githubusercontent.com/LuckyBimZy/Machadepanmu/main/games/"

-- Daftar game yang didukung
local supportedGames = {
    [1234567890] = { -- Ganti dengan ID game Violence District yang sebenarnya
        name = "Violence District",
        file = "violence.lua"
    },
    [111111111] = { -- Ganti dengan ID game Abyss
        name = "Abyss",
        file = "abyss.lua"
    },
    [222222222] = { -- Ganti dengan ID game Fisch
        name = "Fisch",
        file = "fisch.lua"
    }
}

-- Cek apakah game didukung
local gameData = supportedGames[placeId]

if gameData then
    print("========================================")
    print("Loader: Detected " .. gameData.name)
    print("Loading script: " .. gameData.file)
    print("========================================")
    
    -- Load script dari GitHub
    local success, err = pcall(function()
        loadstring(game:HttpGet(githubRaw .. gameData.file))()
    end)
    
    if success then
        print("✅ Script loaded successfully!")
    else
        warn("❌ Failed to load script: " .. tostring(err))
    end
else
    warn("========================================")
    warn("Game not supported!")
    warn("Place ID: " .. placeId)
    warn("Supported games:")
    for id, data in pairs(supportedGames) do
        warn("  - " .. data.name .. " (ID: " .. id .. ")")
    end
    warn("========================================")
end