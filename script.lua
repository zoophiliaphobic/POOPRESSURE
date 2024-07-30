local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local hum = char:WaitForChild("Humanoid")
local us = game:GetService("UserInputService")
local runs = game:GetService("RunService")

local camera = workspace.CurrentCamera
local rooms = workspace:WaitForChild("Rooms")
local monstersfolder = workspace:WaitForChild("Monsters")
local itemsfolder = game.ReplicatedStorage:WaitForChild("Items")
local shopitemsfolder = game.ReplicatedStorage:WaitForChild("DropItems")
local charactersfolder = workspace:WaitForChild("Characters")

local fixminigame = plr:WaitForChild("PlayerGui"):WaitForChild("Main"):WaitForChild("FixMinigame")
local fixgamemiddleframe = fixminigame:WaitForChild("Background"):WaitForChild("Frame"):WaitForChild("Middle")
local fixgamepointer = fixgamemiddleframe:WaitForChild("Pointer")
local fixgamesafezone = fixgamemiddleframe:WaitForChild("Circle")

local pandemoniumgameframe = plr.PlayerGui.Main:WaitForChild("PandemoniumMiniGame")
local pandegamecirle = pandemoniumgameframe:WaitForChild("Background"):WaitForChild("Frame"):WaitForChild("circle")

-- made entirely with solara btw..
-- im just that sigma

local library = loadstring(game:HttpGet("https://raw.githubusercontent.com/zoophiliaphobic/psychic-octo-pancake/main/library.lua"))()
local window = library.createwindow({title="welcome! press ` to close/open"})

window.visibilitychanged = function(opened)
    if opened then
        window.changetitle("poopressure gui (created by @zoophiliaphobic)")
    end
end

local espgroups = {
    monsters = {},
    keycards = {},
    items = {},
    money = {},
    doors = {},
    lockers = {},
    generators = {},
    walldwellers = {},
    squiddles = {},
    players = {},
}

local removedhazards = {}
local removedsquiddleroots = {}
local removedsearchlightseyes = {}

function clearespgroup(name)
    if name == "all" then
        for _,list in pairs(espgroups) do
            for i,v in pairs(list) do
                v.Enabled = false
                v:Destroy()
            end

            table.clear(list)
        end
    else
        local list = espgroups[name]

        if list then
            for i,v in pairs(list) do
                v.Enabled = false
                v:Destroy()
            end
        end
        table.clear(list)
    end
end

function newesp(tbl,color,text,group,offset,overridesize,maxdistance)
    task.wait()
    offset = offset or Vector3.new(0,0,0)
    maxdistance = maxdistance or math.huge
    for i,v in pairs(tbl) do
        if not v:IsDescendantOf(workspace) then
            local tries = 0
            repeat task.wait()
                tries += 1
            until v:IsDescendantOf(workspace) or tries > 100

            if tries > 100 then
                error("could not find part for esp group ".. group..", called ".. text)
            end
        end

        local billboard = Instance.new("BillboardGui")
        billboard.Size = UDim2.new(0,500,0,25)
        billboard.AlwaysOnTop = true
        billboard.StudsOffsetWorldSpace = offset
        billboard.Name = "esp_".. group.."_".. text..#espgroups[group]

        local dotframe = Instance.new("Frame",billboard)
        dotframe.BackgroundColor3 = color
        dotframe.Size = UDim2.new(0,8,0,8)
        dotframe.AnchorPoint = Vector2.new(0.5,0.5)
        dotframe.Position = UDim2.new(0.5,0,0.5,0)

        local dotframestroke = Instance.new("UIStroke",dotframe)
        dotframestroke.Thickness = 2

        local dotframecorner = Instance.new("UICorner",dotframe)
        dotframecorner.CornerRadius = UDim.new(1,0)

        local infoframe = Instance.new("TextLabel",billboard)
        infoframe.BackgroundTransparency = 1
        infoframe.Size = UDim2.new(0.5,0,0.75,0)
        infoframe.AnchorPoint = Vector2.new(0.5,0.5)
        infoframe.Position = UDim2.new(0.78,0,0.5,0)
        infoframe.TextScaled = true
        infoframe.TextXAlignment = "Left"
        infoframe.TextColor3 = color
        infoframe.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json",Enum.FontWeight.Heavy)
        infoframe.Name = "TEXT"

        local infoframestroke = Instance.new("UIStroke",infoframe)
        infoframestroke.Thickness = 2

        local box = Instance.new("BoxHandleAdornment")
        box.Color3 = color
        box.ZIndex = 10
        box.AlwaysOnTop = true
        box.Transparency = 0.5
        box.CFrame = CFrame.new(offset)
        box.Name = "BOX"

        local partorigin = nil
        if v:IsA("Model") then
            local cf,size = v:GetBoundingBox()
            box.Size = size
            partorigin = cf.Position
        elseif v:IsA("BasePart") then
            box.Size = v.Size
            partorigin = v.Position
        end

        if overridesize then
            box.Size = overridesize
        end

        v.AncestryChanged:Connect(function()
            if not v:IsDescendantOf(workspace) then
                if billboard:IsDescendantOf(game.CoreGui) then
                    billboard.Enabled = false
                    billboard:Destroy()
                end
            end
        end)

        billboard.Adornee = v
        box.Adornee = v

        billboard.Parent = game.CoreGui
        box.Parent = billboard

        task.spawn(function()
            while billboard:IsDescendantOf(game.CoreGui) do
                local distfromchar = math.floor((camera.CFrame.Position-partorigin).Magnitude)
                if v:IsA("Model") then
                    local cf,size = v:GetBoundingBox()
                    partorigin = cf.Position
                elseif v:IsA("BasePart") then
                    partorigin = v.Position
                end

                infoframe.Text = text .." (".. distfromchar..")"

                billboard.Enabled = distfromchar <= maxdistance
                box.Visible = distfromchar <= maxdistance

                task.wait()
            end
        end)

        table.insert(espgroups[group],billboard)
        return billboard
    end
end

local keycardnames = {
    NormalKeyCard = {"Keycard"},
    InnerKeyCard = {"Purple Keycard",Color3.fromRGB(150,50,255)},
    RidgeKeyCard = {"Keycard"},
}

local itemnames = {"BigFlashBeacon"}
for i,v in pairs(shopitemsfolder:GetChildren()) do
    table.insert(itemnames,v.Name)
end
for i,v in pairs(itemsfolder:WaitForChild("Battery"):GetChildren()) do
    table.insert(itemnames,v.Name)
end

local monsternames = {
    "A60",
    "Angler",
    "Blitz",
    "Chainsmoker",
    "DeathAngel",
    "Froger",
    "Pandemonium",
    "Pinkie",
    "Mirage",
}

function findfirstdescendant(what,lookfor,class)
    local found = nil
    for i,v in pairs(what:GetDescendants()) do
        if v.Name == lookfor then
            if class then
                if v:IsA(class) then
                    found = v
                    break
                end
            else
                found = v
                break
            end
        end
    end

    if not found then
        local connection
        connection = what.DescendantAdded:Connect(function(v)
            if v.Name == lookfor then
                if class then
                    if v:IsA(class) then
                        connection:Disconnect()
                        connection = nil
                        return v
                    end
                else
                    connection:Disconnect()
                    connection = nil
                    return v
                end
            end
        end)
    else
        return found
    end
end

function startmonsteresp()
    for _,entity in pairs(workspace:GetChildren()) do
        local realname = string.gsub(entity.Name,"Ridge","")
        if table.find(monsternames,realname) then
            newesp({entity},Color3.fromRGB(255,50,50),realname,"monsters",Vector3.new(0,5,0),Vector3.one*10)
        end
    end
end

function startkeycardesp()
    for _,room in pairs(rooms:GetChildren()) do
        for i,v in pairs(room:GetDescendants()) do
            if v:IsA("Model") then
                local infotbl = keycardnames[v.Name]
                if infotbl then
                    newesp({v},infotbl[2] or Color3.fromRGB(140,200,255),infotbl[1],"keycards")
                end
            end
        end
    end
end

function startitemesp()
    for _,room in pairs(rooms:GetChildren()) do
        for i,v in pairs(room:GetDescendants()) do
            if v:IsA("Model") and table.find(itemnames,v.Name) and (v:GetAttribute("InteractionType") == "ItemBase" or v:GetAttribute("InteractionType") == "Battery") and not v:GetAttribute("Price") then
                local link = shopitemsfolder:FindFirstChild(v.Name)
                local displayname = (link and link:GetAttribute("DisplayName")) or v.Name

                if displayname == "BigFlashBeacon" then
                    displayname = "Flash Beacon"
                end

                if v:GetAttribute("InteractionType") == "Battery" then
                    displayname = "Battery"
                end

                newesp({v},Color3.fromRGB(255,190,45),displayname,"items")
            end
        end
    end
end

function startgeneratoresp()
    for _,room in pairs(rooms:GetChildren()) do
        for i,v in pairs(room:GetDescendants()) do
            if v:IsA("Model") and (v.Name == "Generator" or v.Name == "EncounterGenerator" or v.Name == "BrokenCables") then
                local fixedvalue = v:WaitForChild("Fixed")
                local genesppart
                local genespname

                if v.Name == "BrokenCables" then
                    genesppart = findfirstdescendant(v,"Root","MeshPart")
                    genespname = "Broken Cables"
                else
                    genesppart = findfirstdescendant(v,"ParticlesPart","MeshPart")
                    genespname = "Broken Generator"
                end

                if fixedvalue.Value < 100 then
                    local espbillboard = newesp({genesppart},Color3.fromRGB(90,255,90),genespname,"generators")

                    fixedvalue:GetPropertyChangedSignal("Value"):Connect(function()
                        if fixedvalue.Value >= 100 then
                            espbillboard.Enabled = false
                            espbillboard:Destroy()
                        end
                    end)
                end
            end
        end
    end
end

function startdooresp()
    for _,room in pairs(rooms:GetChildren()) do
        for i,v in pairs(room:GetDescendants()) do
            if v:IsA("Model") then
                if v.Name == "NormalDoor" then
                    local openvalue = v:FindFirstChild("OpenValue")
                    
                    if v.Parent.Name == "Entrances" and openvalue.Value == false then
                        local espbillboard = newesp({v:WaitForChild("Door")},Color3.fromRGB(125,255,125),"Door","doors")
                
                        openvalue:GetPropertyChangedSignal("Value"):Once(function()
                            espbillboard.Enabled = false
                            espbillboard:Destroy()
                        end)
                    end
                elseif v.Name == "Trickster" then
                    if v.Parent.Name == "Interactables" then
                        newesp({v:WaitForChild("TricksterDoor"):WaitForChild("Door")},Color3.fromRGB(255,25,40),"Fake Door","doors",nil,nil,300)
                    end
                elseif v.Name == "BigDoor" then
                    local openvalue = v:FindFirstChild("OpenValue")
                    
                    if v.Parent.Name == "Entrances" and openvalue.Value == false then
                        local espbillboard = newesp({v:WaitForChild("Door"):WaitForChild("BigRoomDoor")},Color3.fromRGB(125,255,125),"Door","doors")
                
                        openvalue:GetPropertyChangedSignal("Value"):Once(function()
                            espbillboard.Enabled = false
                            espbillboard:Destroy()
                        end)
                    end
                end
            end
        end
    end
end

function startlockeresp()
    for _,room in pairs(rooms:GetChildren()) do
        for i,v in pairs(room:GetDescendants()) do
            if v:IsA("Model") then
                if v.Name == "Locker" or v.Name == "LockerUnderwater" then
                    newesp({v:WaitForChild("LockerCollision")},Color3.fromRGB(190,70,200),"Locker","lockers")
                elseif v.Name == "MonsterLocker" then
                    newesp({v:WaitForChild("LockerCollision")},Color3.fromRGB(255,0,0),"Void Locker","lockers")
                end
            end
        end
    end
end

function startplayeresp()
    for _,character in pairs(charactersfolder:GetChildren()) do
        if character ~= char then
            local human = character:FindFirstChildOfClass("Humanoid")

            if human then
                local espbillboard = newesp({character},Color3.fromRGB(255,50,190),character.Name,"players")
            end
        end
    end
end

function startwalldwelleresp()
    for i,v in pairs(monstersfolder:GetChildren()) do
        if v.Name == "WallDweller" then
            newesp({v},Color3.fromRGB(255,50,50),"WallDweller","walldwellers")
        end
    end
end

function setppduration(duration,range,lineofsight)
    for i,v in pairs(rooms:GetDescendants()) do
        if v:IsA("ProximityPrompt") then
            local islockerprompt = v:FindFirstAncestor("Locker") or v:FindFirstAncestor("MonsterLocker")
            
            if duration then
                if not v:GetAttribute("ogduration") then
                    v:SetAttribute("ogduration",v.HoldDuration)
                end
                
                v.HoldDuration = 0
            else   
                v.HoldDuration = v:GetAttribute("ogduration") or 0
            end

            if range then
                if not v:GetAttribute("ogrange") then
                    v:SetAttribute("ogrange",v.MaxActivationDistance)
                end
                
                v.MaxActivationDistance = math.max(v.MaxActivationDistance,11)
            else   
                v.MaxActivationDistance = v:GetAttribute("ogrange") or 6
            end

            if lineofsight then
                v.RequiresLineOfSight = false
            else   
                v.RequiresLineOfSight = true
            end

            if islockerprompt then
                v.Enabled = not isgodmodeactive
            else
                v.Enabled = true
            end
        end
    end
end

function startsquiddlesesp()
    for _,room in pairs(rooms:GetChildren()) do
        for i,v in pairs(room:GetChildren()) do
            if v:IsA("Model") then
                if v:GetAttribute("Decal") and v:GetAttribute("SpawnChance") then
                    newesp({v},Color3.fromRGB(255,50,50),"Squiddle","squiddles")
                end
            end
        end
    end
end

function startremovehazards()
    for _,room in pairs(rooms:GetChildren()) do
        for i,v in pairs(room:GetDescendants()) do
            if v.Name == "DamagePart" or v.Name == "BlockPart" or v.Name == "Invisible" or v.Name == "DamageParts" or (v.Name == "Electricity" and v:FindFirstChildOfClass("Sound")) then
                table.insert(removedhazards,{what=v,ogparent=v.Parent})
                v.Parent = nil
            end
        end
    end
end

function startremovesquiddles()
    for _,room in pairs(rooms:GetChildren()) do
        for i,v in pairs(room:GetChildren()) do
            if v:GetAttribute("Decal") and v:GetAttribute("SpawnChance") then
                local sqroot = v:FindFirstChild("HumanoidRootPart")

                if sqroot then
                    table.insert(removedsquiddleroots,{what=sqroot,ogparent=sqroot.Parent})
                    v.Parent = nil
                end
            end
        end
    end
end

function startremovesearchlights()
    for _,room in pairs(rooms:GetChildren()) do
        for i,v in pairs(room:GetChildren()) do
            if v.Name == "Searchlights" then
                local eyesfolder = v:WaitForChild("Eyes")

                if eyesfolder then
                    table.insert(removedsearchlightseyes,{what=eyesfolder,ogparent=eyesfolder.Parent})
                    --eyesfolder.Parent = nil
                    eyesfolder:Destroy()
                end
            end
        end
    end
end

function startdisableeyefest(enable)
    for _,room in pairs(rooms:GetChildren()) do
        for i,v in pairs(room:GetDescendants()) do
            if v.Name == "Eyefestation" then
                local activevalue = v:FindFirstChild("Active")
                activevalue.Value = enable
            end
        end
    end
end

local tab_hacks = window.createtab({title="hacks"})
local tab_hacks_toggle_fullbright = tab_hacks.newtoggle({title="fullbright",onclick=function(bool)
    game.Lighting.Ambient = bool and Color3.new(1,1,1) or Color3.new(0,0,0)
end})
local tab_hacks_toggle_monsters = tab_hacks.newtoggle({title="notify when node entity spawns"})
local tab_hacks_toggle_walldweller = tab_hacks.newtoggle({title="notify when walldweller spawns"})
local tab_hacks_toggle_prompts = tab_hacks.newtoggle({title="instant interact",onclick=function(bool)
    setppduration(bool)
end})
local tab_hacks_toggle_promptsrange = tab_hacks.newtoggle({title="long range interact",onclick=function(bool)
    setppduration(nil,bool)
end})
local tab_hacks_toggle_promptslos = tab_hacks.newtoggle({title="interact through walls",onclick=function(bool)
    setppduration(nil,nil,bool)
end})
local tab_hacks_toggle_ezfix = tab_hacks.newtoggle({title="easy generator repair"})
local tab_hacks_toggle_pandegame = tab_hacks.newtoggle({title="auto pandemonium minigame"})
local tab_hacks_toggle_noeyefest = tab_hacks.newtoggle({title="disable eyefestation",onclick=function(bool)
    startdisableeyefest(bool)
end})
local tab_hacks_toggle_squids = tab_hacks.newtoggle({title="friendly squiddles",onclick=function(bool)
    if bool then
        startremovesquiddles()
    else
        for i,v in pairs(removedsquiddleroots) do
            if v.ogparent then
                v.what.Parent = v.ogparent
            end
        end
        table.clear(removedsquiddleroots)
    end
end})
local tab_hacks_toggle_searchlights = tab_hacks.newtoggle({title="remove searchlights eyes",onclick=function(bool)
    if bool then
        startremovesearchlights()
    else
        -- searchlights just completely breaks if you bring back the eyes
        
        -- for i,v in pairs(removedsearchlightseyes) do
        --     if v.ogparent then
        --         v.what.Parent = v.ogparent
        --     end
        -- end
        -- table.clear(removedsearchlightseyes)
    end
end})
local tab_hacks_toggle_deletepande = tab_hacks.newtoggle({title="delete pandemonium lol",onclick=function(bool)
    if bool then
        for i,v in pairs(workspace:GetChildren()) do
            local realname = string.gsub(v.Name,"Ridge","")
            if realname == "Pandemonium" then
                v:Destroy()
            end
        end
    end
end})
local tab_hacks_toggle_nohazards = tab_hacks.newtoggle({title="remove environmental hazards",onclick=function(bool)
    if bool then
        startremovehazards()
    else
        for i,v in pairs(removedhazards) do
            if v.ogparent then
                v.what.Parent = v.ogparent
            end
        end
        table.clear(removedhazards)
    end
end})

local tab_player = window.createtab({title="player"})
local tab_player_slider_swimspeed = tab_player.newslider({title="swim speed",min=1,max=5,default=1,increment=0.01})
local tab_player_slider_walkspeed = tab_player.newslider({title="walkspeed",min=16,max=200,default=16,increment=1})
local tab_player_toggle_speed = tab_player.newtoggle({title="enable walkspeed",onclick=function(bool)
    if bool then
        hum.WalkSpeed = tab_player_slider_walkspeed.getvalue()
    else
        hum.WalkSpeed = 16
    end
end})
local tab_player_slider_jumppower = tab_player.newslider({title="jump power",min=0,max=200,default=50,increment=1})
local tab_player_toggle_jumping = tab_player.newtoggle({title="enable jumping",onclick=function(bool)
    if bool then
        hum.JumpPower = tab_player_slider_jumppower.getvalue()
        hum.UseJumpPower = true
    else
        hum.JumpPower = 50
        hum.UseJumpPower = false
    end
end})

local tab_player_slider_fov = tab_player.newslider({title="camera field of view",min=0,max=120,default=90,increment=1,onchanged=function(val)
    camera.FieldOfView = val
end})

local isgodmodeactive = false

function enablegodmode(bool)
    local lockers = {}
    for i,v in pairs(workspace.Rooms:GetDescendants()) do
        if (v.Name == "Locker" or v.Name == "LockerUnderwater") and v:FindFirstChild("Folder") then
            table.insert(lockers,{what=v,dist=plr:DistanceFromCharacter(v:GetPivot().Position)})
        end
    end

    table.sort(lockers,function(a,b)
        return a.dist < b.dist
    end)

    local locker = lockers[1].what

    if bool then
        locker.Folder.Enter:InvokeServer()
    else
        locker.Folder.Exit:FireServer()
    end
    isgodmodeactive = bool
    setppduration(tab_hacks_toggle_prompts.getvalue(),tab_hacks_toggle_promptsrange.getvalue(),tab_hacks_toggle_promptslos.getvalue())

    hum.WalkSpeed = (tab_player_toggle_speed.getvalue() and tab_player_slider_walkspeed.getvalue()) or 16
end

local tab_hacks_toggle_godmode = tab_hacks.newtoggle({title="dont die to node monsters (unless its pandemonium) and if you enter a locker you have to disable and re-enable this",onclick=function(bool)
    enablegodmode(bool)
end})

local tab_esp = window.createtab({title="visual"})
local tab_esp_toggle_monsters = tab_esp.newtoggle({title="node monster esp",onclick=function(bool)
    if bool then
        startmonsteresp()
    else
        clearespgroup("monsters")
    end
end})
local tab_esp_toggle_dwellers = tab_esp.newtoggle({title="wall dweller esp",onclick=function(bool)
    if bool then
        startwalldwelleresp()
    else
        clearespgroup("walldwellers")
    end
end})
local tab_esp_toggle_squiddles = tab_esp.newtoggle({title="squiddles esp",onclick=function(bool)
    if bool then
        startsquiddlesesp()
    else
        clearespgroup("squiddles")
    end
end})
local tab_esp_toggle_cards = tab_esp.newtoggle({title="keycard esp",onclick=function(bool)
    if bool then
        startkeycardesp()
    else
        clearespgroup("keycards")
    end
end})
local tab_esp_toggle_items = tab_esp.newtoggle({title="item esp",onclick=function(bool)
    if bool then
        startitemesp()
    else
        clearespgroup("items")
    end
end})
local tab_esp_toggle_doors = tab_esp.newtoggle({title="door esp",onclick=function(bool)
    if bool then
        startdooresp()
    else
        clearespgroup("doors")
    end
end})
local tab_esp_toggle_generators = tab_esp.newtoggle({title="generator esp",onclick=function(bool)
    if bool then
        startgeneratoresp()
    else
        clearespgroup("generators")
    end
end})
local tab_esp_toggle_players = tab_esp.newtoggle({title="player esp",onclick=function(bool)
    if bool then
        startplayeresp()
    else
        clearespgroup("players")
    end
end})
local tab_esp_toggle_lockers = tab_esp.newtoggle({title="locker esp",onclick=function(bool)
    if bool then
        startlockeresp()
    else
        clearespgroup("lockers")
    end
end})

local tab_esp_slider_moneyamount
local lastmoneyslideramt = 0

function startmoneyesp()
    for _,room in pairs(rooms:GetChildren()) do
        for i,v in pairs(room:GetDescendants()) do
            if v:IsA("Model") then
                if v:GetAttribute("InteractionType") == "CurrencyBase" then
                    local cash = v:GetAttribute("Amount")

                    if tonumber(cash) >= tonumber(tab_esp_slider_moneyamount.getvalue()) then
                        newesp({v},Color3.fromRGB(255,255,0),tostring(cash).." research","money")
                    end
                end
            end
        end
    end
end

local tab_esp_toggle_money = tab_esp.newtoggle({title="research esp",onclick=function(bool)
    if bool then
        startmoneyesp()
    else
        clearespgroup("money")
    end
end})
local canchange = true
tab_esp_slider_moneyamount = tab_esp.newslider({title="minimum research amount",min=0,max=500,increment=5,onchanged=function(val)
    if tab_esp_toggle_money.getvalue() then
        if canchange then
            canchange = false
            clearespgroup("money")
            startmoneyesp()

            task.delay(1,function()
                local curval = tab_esp_slider_moneyamount.getvalue()
                if curval ~= lastmoneyslideramt and tab_esp_toggle_money.getvalue() then
                    clearespgroup("money")
                    startmoneyesp()
                    canchange = true
                end
                lastmoneyslideramt = curval
            end)
        end
    end
end})

local tab_esp_toggle_nodes = tab_esp.newtoggle({title="show path nodes",onclick=function(bool)
    for _,v in pairs(rooms:GetChildren()) do
        local folder = v:FindFirstChild("EntityNodes")

        if folder then
            for _,node in pairs(folder:GetChildren()) do
                node.Transparency = bool and 0 or 1
            end
        end
    end
end})

fixgamepointer.Changed:Connect(function()
    if tab_hacks_toggle_ezfix.getvalue() then
        fixgamesafezone.Rotation = fixgamepointer.Rotation-22.5
    end
end)

pandegamecirle.Changed:Connect(function()
    if tab_hacks_toggle_pandegame.getvalue() then
        pandegamecirle.Position = UDim2.new(0.5,0,0.5,0)
    end
end)

local loopingswimspeed = false
hum.Changed:Connect(function()
    if tab_player_toggle_speed.getvalue() then
        hum.WalkSpeed = tab_player_slider_walkspeed.getvalue()
    end
    
    if tab_player_toggle_jumping.getvalue() then
        hum.JumpPower = tab_player_slider_jumppower.getvalue()
    end

    if hum.PlatformStand and not loopingswimspeed then
        local head = char:WaitForChild("Head")
        local swimspeed = tab_player_slider_swimspeed.getvalue()-1
        loopingswimspeed = true

        while hum.PlatformStand do
            swimspeed = tab_player_slider_swimspeed.getvalue()-1
            char:PivotTo(char:GetPivot()+head.AssemblyLinearVelocity*(swimspeed/100))
            task.wait()
        end
        loopingswimspeed = false
    end
end)

rooms.ChildAdded:Connect(function(room)
    local interactables = room:WaitForChild("Interactables")
    local nodesfolder = room:WaitForChild("EntityNodes")

    local function descendantadded(v)
        if v:IsA("Model") then
            if keycardnames[v.Name] and tab_esp_toggle_cards.getvalue() then
                local infotbl = keycardnames[v.Name]
                if infotbl then
                    newesp({v},infotbl[2] or Color3.fromRGB(140,200,255),infotbl[1],"keycards")
                end
            elseif table.find(itemnames,v.Name) then
                if tab_esp_toggle_items.getvalue() and (v:GetAttribute("InteractionType") == "ItemBase" or v:GetAttribute("InteractionType") == "Battery") and not v:GetAttribute("Price") then
                    local link = shopitemsfolder:FindFirstChild(v.Name)
                    local displayname = (link and link:GetAttribute("DisplayName")) or v.Name

                    if displayname == "BigFlashBeacon" then
                        displayname = "Flash Beacon"
                    end

                    if v:GetAttribute("InteractionType") == "Battery" then
                        displayname = "Battery"
                    end

                    newesp({v},Color3.fromRGB(255,190,45),displayname,"items")
                end
            elseif v.Name == "Locker" or v.Name == "LockerUnderwater" then
                if tab_esp_toggle_lockers.getvalue() then
                    newesp({v:WaitForChild("LockerCollision")},Color3.fromRGB(190,70,200),"Locker","lockers")
                end
            elseif v.Name == "MonsterLocker" then
                if tab_esp_toggle_lockers.getvalue() then
                    ewesp({v:WaitForChild("LockerCollision")},Color3.fromRGB(255,0,0),"Void Locker","lockers")
                end
            elseif v.Name == "NormalDoor" then
                if tab_esp_toggle_doors.getvalue() and v.Parent.Name == "Entrances" then
                    local openvalue = v:WaitForChild("OpenValue")
                    local espbillboard = newesp({v:WaitForChild("Door")},Color3.fromRGB(125,255,125),"Door","doors")
                
                    openvalue:GetPropertyChangedSignal("Value"):Once(function()
                        espbillboard.Enabled = false
                        espbillboard:Destroy()
                    end)
                end
            elseif v.Name == "Trickster" then
                if tab_esp_toggle_doors.getvalue() and v.Parent.Name == "Interactables" then
                    newesp({v:WaitForChild("TricksterDoor"):WaitForChild("Door")},Color3.fromRGB(255,25,40),"Fake Door","doors",nil,nil,300)
                end
            elseif v.Name == "BigDoor" then
                if tab_esp_toggle_doors.getvalue() and v.Parent.Name == "Entrances" then
                    local openvalue = v:WaitForChild("OpenValue")
                    local espbillboard = newesp({v:WaitForChild("Door"):WaitForChild("BigRoomDoor")},Color3.fromRGB(125,255,125),"Door","doors")
                
                    openvalue:GetPropertyChangedSignal("Value"):Once(function()
                        espbillboard.Enabled = false
                        espbillboard:Destroy()
                    end)
                end
            elseif (v.Name == "Generator" or v.Name == "EncounterGenerator" or v.Name == "BrokenCables") then
                local fixedvalue = v:WaitForChild("Fixed")
                local genesppart
                local genespname

                if v.Name == "BrokenCables" then
                    genesppart = findfirstdescendant(v,"Root","MeshPart")
                    genespname = "Broken Cables"
                else
                    genesppart = findfirstdescendant(v,"ParticlesPart","MeshPart")
                    genespname = "Broken Generator"
                end

                if fixedvalue.Value < 100 then
                    local espbillboard = newesp({genesppart},Color3.fromRGB(90,255,90),genespname,"generators")

                    fixedvalue:GetPropertyChangedSignal("Value"):Connect(function()
                        if fixedvalue.Value >= 100 then
                            espbillboard.Enabled = false
                            espbillboard:Destroy()
                        end
                    end)
                end
            elseif v:GetAttribute("InteractionType") == "CurrencyBase" then
                if tab_esp_toggle_money.getvalue() then
                    local cash = v:GetAttribute("Amount")

                    if tonumber(cash) >= tonumber(tab_esp_slider_moneyamount.getvalue()) then
                        newesp({v},Color3.fromRGB(255,255,0),tostring(cash).." research","money")
                    end
                end
            elseif v:GetAttribute("Decal") and v:GetAttribute("SpawnChance") then
                if tab_esp_toggle_squiddles then
                    newesp({v},Color3.fromRGB(255,50,50),"Squiddle","squiddles")
                end

                if tab_hacks_toggle_squids.getvalue() then
                    local sqroot = v:WaitForChild("HumanoidRootPart")

                    if sqroot then
                        table.insert(removedsquiddleroots,{what=sqroot,ogparent=sqroot.Parent})
                        v.Parent = nil
                    end
                end
            elseif v.Name == "Searchlights" then
                if tab_hacks_toggle_searchlights.getvalue() then
                    local eyesfolder = v:WaitForChild("Eyes")
                    
                    if eyesfolder then
                        task.wait(1)
                        table.insert(removedsearchlightseyes,{what=eyesfolder,ogparent=eyesfolder.Parent})
                        --eyesfolder.Parent = nil
                        eyesfolder:Destroy()
                    end
                end
            end
        end

        -- if tab_esp_toggle_doors.getvalue() and v.Name == "Door2" then
        --     local normdoor = v:FindFirstAncestor("NormalDoor")
        --     if normdoor then
        --         local openvalue = normdoor:WaitForChild("OpenValue")
        --         local espbillboard = newesp({v},Color3.fromRGB(125,255,125),"Door","doors")
            
        --         openvalue:GetPropertyChangedSignal("Value"):Once(function()
        --             espbillboard.Enabled = false
        --             espbillboard:Destroy()
        --         end)
        --     elseif v:FindFirstAncestor("Trickster") then
        --         newesp({v},Color3.fromRGB(255,25,40),"Fake Door","doors")
        --     end
        -- end

        if tab_hacks_toggle_nohazards.getvalue() then
            task.wait()
            if v.Name == "DamagePart" or v.Name == "BlockPart" or v.Name == "Invisible" or v.Name == "DamageParts" or (v.Name == "Electricity" and v:FindFirstChildOfClass("Sound")) then
                task.defer(function()
                    table.insert(removedhazards,{what=v,ogparent=v.Parent})
                    v.Parent = nil

                    for i=1,100 do
                        v.Parent = nil
                        task.wait()
                    end
                end)
            end
        end

        if tab_hacks_toggle_noeyefest.getvalue() then
            task.wait()
            if v.Name == "Eyefestation" then
                local activevalue = v:WaitForChild("Active")
                activevalue.Value = false

                activevalue.Changed:Connect(function()
                    activevalue.Value = false
                end)
            end
        end

        if v:IsA("ProximityPrompt") then
            task.wait()
            local islockerprompt = v:FindFirstAncestor("Locker") or v:FindFirstAncestor("MonsterLocker") or v:FindFirstAncestor("LockerUnderwater")
            
            if tab_hacks_toggle_prompts.getvalue() then
                if not v:GetAttribute("ogduration") then
                    v:SetAttribute("ogduration",v.HoldDuration)
                end

                v.HoldDuration = 0
            end

            if tab_hacks_toggle_promptsrange.getvalue() then
                if not v:GetAttribute("ogrange") then
                    v:SetAttribute("ogrange",v.MaxActivationDistance)
                end

                v.MaxActivationDistance = math.max(v.MaxActivationDistance,11)
            end

            if tab_hacks_toggle_promptslos.getvalue() then
                v.RequiresLineOfSight = false
            end

            if islockerprompt then
                v.Enabled = not isgodmodeactive
            else
                v.Enabled = true
            end

            v.Changed:Connect(function()
                if islockerprompt then
                    v.Enabled = not isgodmodeactive
                else
                    v.Enabled = true
                end

                if tab_hacks_toggle_prompts.getvalue() then
                    v.HoldDuration = 0
                end
                if tab_hacks_toggle_promptsrange.getvalue() then
                    v.MaxActivationDistance = math.max(v.MaxActivationDistance,11)
                end
                if tab_hacks_toggle_promptslos.getvalue() then
                    v.RequiresLineOfSight = false
                end
            end)
        end

        if v:IsDescendantOf(nodesfolder) and v:IsA("BasePart") then
            if tab_esp_toggle_nodes.getvalue() then
                v.Transparency = 0
            end
        end
    end

    room.DescendantAdded:Connect(function(v)
        task.wait()
        task.defer(function()
            descendantadded(v)
        end)
    end)

    for i,v in pairs(room:GetDescendants()) do
        task.spawn(function()
            descendantadded(v)
        end)
    end
end)

workspace.ChildAdded:Connect(function(entity)
    local realname = string.gsub(entity.Name,"Ridge","")

    if table.find(monsternames,realname) then
        local deletedpandelol = realname == "Pandemonium" and tab_hacks_toggle_deletepande.getvalue()

        if tab_hacks_toggle_monsters.getvalue() then
            if deletedpandelol then
                local message = Instance.new("Message",workspace)
                message.Text = "pandemonium WAS going to come.. but you deleted him!!"
                task.wait(2)
                message:Destroy()
            else
                local message = Instance.new("Message",workspace)
                message.Text = realname .." coming"
                task.wait(1)
                message:Destroy()
            end
        end

        if tab_esp_toggle_monsters.getvalue() and not deletedpandelol then
            newesp({entity},Color3.fromRGB(255,50,50),realname,"monsters",Vector3.new(0,5,0),Vector3.one*10)
        end

        if deletedpandelol then
            task.defer(function()
                entity:Destroy()
            end)
        end
    end
end)

monstersfolder.ChildAdded:Connect(function(v)
    if v.Name == "WallDweller" then
        local message = Instance.new("Message",workspace)
        message.Text = "theres a wall dweller in that wall..."
        task.wait(1.5)
        message:Destroy()

        if tab_esp_toggle_dwellers.getvalue() then
            newesp({v},Color3.fromRGB(255,50,50),"WallDweller","walldwellers")
        end
    end
end)

charactersfolder.ChildAdded:Connect(function(character)
    if tab_esp_toggle_players.getvalue() and character ~= char then
        local human = character:FindFirstChildOfClass("Humanoid")

        if human then
            local espbillboard = newesp({character},Color3.fromRGB(255,50,190),character.Name,"players")
        end
    end
end)
