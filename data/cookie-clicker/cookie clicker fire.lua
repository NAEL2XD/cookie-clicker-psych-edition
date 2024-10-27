-- "Why would you put cookie clicker in da fnf" - zamination_1

-- If you are a dev and want to debug stuff, set "debugger" to true
local debugger = false

local appData = {
    -- main game
    cookie = 0,
    cookiePerClick = 1,

    -- products
    CursorOwn = 0,
    CursorPrice = 15,
    CursorUpgradeMult = 1,

    GrandmaOwn = 0,
    GrandmaPrice = 100,
    GrandmaUpgradeMult = 1,

    FarmOwn = 0,
    FarmPrice = 1100,
    FarmUpgradeMult = 1,

    MineOwn = 0,
    MinePrice = 12000,
    MineUpgradeMult = 1,

    FactoryOwn = 0,
    FactoryPrice = 130000,
    FactoryUpgradeMult = 1,

    -- settings
    flyCookie = true,
    cookieSpawnLimit = 100,
    flyNumbs = true,
    watermark = true,
    autoSave = true,
    jingleLeave = false,

    -- upgrades
    rifUnlocked = false,
    rifBought = false,

    ctpcUnlocked = false,
    ctpcBought = false,

    AmbidextrousUnlocked = false,
    AmbidextrousBought = false,

    frgUnlocked = false,
    frgBought = false,

    prpnUnlocked = false,
    prpnBought = false,

    ldUnlocked = false,
    ldBought = false,

    chUnlocked = false,
    chBought = false,

    scbUnlocked = false,
    scbBought = false
}

-- Game Data (no save)
local cps = 0
local cookieVer = "0.5.0"

-- non list
local clickCount = 0
local cookieOverlap = false
local upgradeLength = 0
local productHovered = false
local isClicked = false
local insideExtras = false
local goldenCookieHere = false
local timerRan = false
local settingsChosen = 1
local extrasState = "menu"
local scrollFast = 0
local isLeaving = false
local coolState = "Cookie Clicker: Psych Engine Edition (v"..cookieVer..")"

local productList = {
--   Name | Description | CPS | St. Val
    {"Cursor",  "Autoclicks once every 10 seconds.",           0.1,     15},
    {"Grandma", "A nice grandma to bake more cookies",           1,    100},
    {"Farm",    "Grows cookie plants from cookie seeds.",        8,   1100},
    {"Mine",    "Mines out cookie dough and chocolate chips.",  47,  12000},
    {"Factory", "Produces large quantities of cookies.",       260, 130000}
}

local settingsName = {
    -- Name | Val in appData | Description | Type ({min:int, max:int, seconds to num:float})
    {"Cookie Popups", "flyCookie", "If true, the cookie will spawn from cookie clicked and on top of game.", "boolean"},
    {"Sky Cookie Spawn Limit", "cookieSpawnLimit", "How much cookies you want them to spawn on top?", "int", {1, 1000, 0.005}},
    {"Number Popups", "flyNumbs", "If true, the number will spawn only from cookie clicked.", "boolean"},
    {"Watermark", "watermark", "If true, then the watermark will be gone.", "boolean"},
    {"Auto Saving", "autoSave", "If false, Auto Save won't do anything. Kinda used for performance increase?.", "boolean"},
    {"Jingle If Save & Exit Pressed", "jingleLeave", "If ON, you'll hear a jingle if you press Save & Exit.", "boolean"},
}

local upgradesList = {
--   Name | Description | ID | Req to Unlock {Products, value} | St. VAL
    {"rif",          "The mouse and cursors are twice as efficient.", 1, {"Cursor",   1},      100},
    {"ctpc",         "The mouse and cursors are twice as efficient.", 1, {"Cursor",   1},     1000},
    {"Ambidextrous", "The mouse and cursors are twice as efficient.", 1, {"Cursor",  10},    10000},
    {"frg",          "Grandmas are twice as efficient.",              2, {"Grandma",  1},     1000},
    {"prpn",         "Grandmas are twice as efficient.",              2, {"Grandma",  5},     5000},
    {"ld",           "Grandmas are twice as efficient.",              2, {"Grandma", 25},    50000},
    {"ch",           "Farms are twice as efficient.",                 3, {"Farm",     1},    11000},
    {"scb",          "Factories are twice as efficient.",             4, {"Factory",  1},  1300000}
}

local upgradesUnlocked = {}
local allGraphic = {}
local listToRemove = {"cookie", "smallCookie", "click", "intro", "cookieClicked"}
local extrasName = {
    {"Game Settings", "Configure Game Settings Here."},
    {"About CCPE",    "About Cookie Clicker: Psych Engine Edition."},
    {"Save & Exit",   "Saves Progress and Exits PlayState."},
}

function onCreatePost()
    --[[initSaveData('CCNael2xdVer')
    for k, v in pairs(appData) do
        appData[k] = getDataFromSave('CCNael2xdVer', k, v)
    end]]

    if debugger then
        makeText("deb", 0, 0, 60)
        screenCenter("deb")
        setProperty("deb.alpha", 0.4)
        setTextString("deb", "Debug Mode")
        setObjectOrder("deb", 123456789)
        table.insert(extrasName, {"Restart", "This is ONLY for debugging purposes."})
        makeText("debugText", 0, 0, 16)
        setTextAlignment("debugText", "right")
        setProperty("debugText.y", 0)
    end

    setProperty("camGame.alpha", 0)
    setProperty("camHUD.alpha", 0)
    setPropertyFromClass("ClientPrefs", "hideHud", true)
    setPropertyFromClass('flixel.FlxG', 'mouse.visible', true)

    -- Sprites (i should precache them)
    makeSprite("background", 0, 0)
    scaleObject("background", 1.25, 0.775)
    makeSprite("glowBlack", 0, 365)
    scaleObject("glowBlack", 1.35, 1)
    makeSprite("cookie", 0, 0)
    scaleObject("cookie", 0.2, 0.2)
    screenCenter("cookie")
    makeSprite("extras", 0, 0)
    scaleObject("extras", 0.33, 0.33)
    screenCenter("extras")
    setProperty("extras.y", 625)
    makeSprite('coolbg', 0, 685, true)
    scaleObject("coolbg", 0.5375, 0.5)
    setProperty("coolbg.angle", 180)

    -- Text Stuff
    makeText("cookieOwn", 0, 75, 60)
    setTextBorder("cookieOwn", 2, "000000")
    makeText("cpsOwn", 0, 145, 20)
    setTextBorder("cpsOwn", 1, "000000")
    makeText("prodDescription", 0, 10, 25)
    setTextString("prodDescription", "")
    makeText("Saving", 750, 650, 45)
    setTextString("Saving", "Saving...")
    setTextBorder("Saving", 1, "000000")
    makeText("ccpe", 2, 702, 12)
    setTextAlignment("ccpe", "left")
    makeText("menuAbout", 0, 0, 34)
    setTextString("menuAbout", "")

    makeAnimatedLuaSprite("loading", "loading", 1485, 640)
    addAnimationByPrefix("loading", "loading", "loading", 12, true)
    addLuaSprite("loading", true)
    scaleObject("loading", 0.5, 0.5)
    setObjectCamera("loading", "other")

    makeAnimatedLuaSprite("static", "static", 0, 0)
    addAnimationByPrefix("static", "static", "static", 24, true)
    addLuaSprite("static", true)
    setObjectCamera("static", "other")
    screenCenter("static")
    setProperty("static.alpha", 0)
    setObjectOrder("static", 100000000)

    runTimer("cps", 1, 0)
    runTimer("save", 60, 0)
    runTimer("goldenCookie", getRandomFloat(30, 150), 1)

    for i=1,#productList do
        if appData.cookie >= productList[i][4] then
            makeProduct(i)
        end
    end

    makeSprite("intro", 0, 0, true)
    doTweenX("introx", "intro.scale", 200, 3, "easeIn")
    doTweenY("introy", "intro.scale", 200, 3, "easeIn")
    setObjectOrder("extras", 1000000000)
    setObjectOrder("intro", 1000050000)
    setPropertyFromClass('lime.app.Application', 'current.window.title', "Cookie Clicker Psych Edition (v"..cookieVer..")")

    addHaxeLibrary('Application', 'lime.app')
    addHaxeLibrary('Image', 'lime.graphics')
    runHaxeCode([[
        var Icon:Image=Image.fromFile(Paths.modFolders('images/smallCookie.png'));
        Application.current.window.setIcon(Icon);
    ]])

    sortUpgrade()
    recalculateCps()
end

function onPause()
    return Function_Stop
end

function onUpdate()
    setTextString("cookieOwn", math.floor(appData.cookie))
    setTextString("cpsOwn", cps.." cookies per second")

    if not insideExtras then
        changePresence(coolState, "Cookies: "..appData.cookie.." | In Game") -- just found out using changeDiscordPresence fucks shit up
    end

    if appData.watermark then
        setTextString("ccpe", "Cookie Clicker Psych Edition (v"..cookieVer..")")
        setProperty("coolbg.alpha", 1)
    else
        setTextString("ccpe", "")
        setProperty("coolbg.alpha", 0)
    end

    if mouseClicked("left") then
        if cookieOverlap then
            playSound("click"..getRandomInt(1,7))
        else
            playSound("click")
        end
    end

    if productHovered then
        productHovered = false
        runTimer("prodBye", 0, 1)
    end

    if debugger then
        -- If you wanna debug with a value or list, do so here
        setTextString("debugText", upgradesUnlocked)
        setObjectOrder("debugText", 1000000000)
    end

    if mouseOverlaps("extras") and mouseClicked("left") then
        if insideExtras and not isLeaving then
            insideExtras = false
            extrasState = "menu"
            stopSound("hi1")
            stopSound("hi2")
            cancelTimer("camloop")
            cancelTween("static")
            cancelTimer("colorChange")
            setProperty("static.alpha", 1)
            doTweenAlpha("staticShit", "static", 0, 0.33, "linear")
            setProperty("cookieOwn.alpha", 1)
            setProperty("cpsOwn.alpha", 1)
            for i=#allGraphic,1,-1 do
                removeLuaSprite(allGraphic[i])
                removeLuaSprite("extraOutline"..i)
                removeLuaSprite("extraButton"..i)
                removeLuaSprite("extrasName"..i)
                removeLuaText("extrasName"..i)
                allGraphic[i] = nil
            end
            for i=1,#productList do
                setProperty("productInfo"..i..".alpha", 1)
                setProperty("products/"..productList[i][1]..".alpha", 1)
                setProperty("smallCookiePrice"..i..".alpha", 1)
                setProperty("price"..i..".alpha", 1)
                setProperty("own"..i..".alpha", 1)
                setProperty(productList[i][1]..".alpha", 1)
            end
        elseif not isLeaving then
            insideExtras = true
            playSound("camloop", 2, "hi1")
            playSound("menu", 1, "hi2")
            runTimer("camloop", 9, 0)
            setProperty("static.alpha", 1)
            doTweenAlpha("staticShit", "static", 0.35, 1, "linear")
            graphicMake("bar5", 0, 0, 1280, 50, "FFFFFF")
            graphicMake("bar6", 0, 0, 50, 1280, "FFFFFF")
            graphicMake("bar7", 1235, 0, 50, 1280, "FFFFFF")
            graphicMake("bar8", 0, 670, 1280, 50, "FFFFFF")
            graphicMake("bar1", 0, 0, 1280, 45, "000000")
            graphicMake("bar2", 0, 0, 45, 1280, "000000")
            graphicMake("bar3", 1240, 0, 45, 1280, "000000")
            graphicMake("bar4", 0, 675, 1280, 45, "000000")
            local add = {"infoThing1", "infoThing2", "coolCol", "yea"}
            for i=1,#add do
                table.insert(allGraphic, add[i])
            end
            for i=1,3 do
                graphicMake("move"..i, 0, 0, 0, 0, "000000")
            end
            runTimer("colorChangebegin", 0, 1)
            runTimer("colorChange", 2, 0)
            setProperty("cookieOwn.alpha", 0)
            setProperty("cpsOwn.alpha", 0)
            for i=1,#productList do
                setProperty("productInfo"..i..".alpha", 0)
                setProperty("products/"..productList[i][1]..".alpha", 0)
                setProperty("smallCookiePrice"..i..".alpha", 0)
                setProperty("price"..i..".alpha", 0)
                setProperty("own"..i..".alpha", 0)
                setProperty(productList[i][1]..".alpha", 0)
            end
            for i=1,#extrasName do
                makeExtras(i)
            end
        end
    end

    if not insideExtras then
        if goldenCookieHere then
            spawnGoldenCookie()
        end
        -- Products
        for i=1,#productList do
            setBlendMode("productInfo"..i, "NORMAL")
            if mouseOverlaps("productInfo"..i) then
                productHovered = true
                setBlendMode("productInfo"..i, "LIGHTEN")
                setTextString("prodDescription", productList[i][2])
                if mouseClicked("left") and appData.cookie >= appData[productList[i][1].."Price"] then
                    playSound("buy"..getRandomInt(1,4))
                    appData.cookie = appData.cookie - appData[productList[i][1].."Price"]
                    appData[productList[i][1].."Own"] = appData[productList[i][1].."Own"]+1
                    appData[productList[i][1].."Price"] = math.floor(appData[productList[i][1].."Price"] * 1.025)
                    setTextString("price"..i, math.floor(appData[productList[i][1].."Price"]))
                    setTextString("own"..i, appData[productList[i][1].."Own"])
                    for ii=1,#upgradesList do
                        local isUnlocked = true
                        for iii=1,#upgradesUnlocked do
                            if ii == upgradesUnlocked[iii] then
                                isUnlocked = false
                            end
                        end
                        if (appData[upgradesList[ii][4][1].."Own"] >= upgradesList[ii][4][2]) and isUnlocked then
                            makeUpgrade(ii)
                            table.insert(upgradesUnlocked, ii)
                            sortUpgrade()
                        end
                    end
                    recalculateCps()
                end
            end
            if appData.cookie >= appData[productList[i][1].."Price"] then
                setTextColor("price"..i, "00FF00")
            else
                setTextColor("price"..i, "FF0000")
            end
        end
        -- Upgrades
        for i=1,#upgradesList do
            setBlendMode("upgradeFrame"..i, "NORMAL")
            if appData.cookie >= upgradesList[i][5] then
                setBlendMode("upgrades/"..upgradesList[i][1], "NORMAL")
            else
                setBlendMode("upgrades/"..upgradesList[i][1], "DARKEN")
            end
            if mouseOverlaps("upgradeFrame"..i) then
                setBlendMode("upgradeFrame"..i, "LIGHTEN")
                setTextString("prodDescription", upgradesList[i][2].."\nCookie Costs: "..upgradesList[i][5])
                productHovered = true
                if mousePressed("left") and appData.cookie >= upgradesList[i][5] and not isClicked then
                    playSound("buy"..getRandomInt(1,4))
                    appData.cookie = appData.cookie - upgradesList[i][5]
                    upgradeLength = upgradeLength-1
                    appData[upgradesList[i][1].."Bought"] = true
                    removeLuaSprite("upgradeFrame"..i)
                    removeLuaSprite("upgrades/"..upgradesList[i][1])
                    sortUpgrade()
                    recalculateCps(upgradesList[i][3])
                end
                isClicked = mousePressed("left") -- Psych Engine really making me make another local then
            end
        end
        -- Cookie Physics
        if mouseOverlaps('cookie') then
            if not cookieOverlap then
                doTweenX("boing1", "cookie.scale", 0.225, 2, "elasticOut")
                doTweenY("boing2", "cookie.scale", 0.225, 2, "elasticOut")
            end
            cookieOverlap = true
            if mouseClicked("left") then
                setProperty("cookie.scale.x", 0.2175)
                setProperty("cookie.scale.y", 0.2175)
                doTweenX("boing1", "cookie.scale", 0.225, 2, "elasticOut")
                doTweenY("boing2", "cookie.scale", 0.225, 2, "elasticOut")
                appData.cookie = appData.cookie + appData.cookiePerClick
                for i=1,#productList do
                    if appData.cookie >= productList[i][4] and not luaTextExists("price"..i) then
                        makeProduct(i)
                        sortUpgrade()
                    end
                end
                spawnCookies(true)
            end
        else
            if cookieOverlap then
                doTweenX("boing1", "cookie.scale", 0.2, 2, "elasticOut")
                doTweenY("boing2", "cookie.scale", 0.2, 2, "elasticOut")
            end
            cookieOverlap = false
        end
        if mouseOverlaps("goldCookie") and mouseClicked("left") then
            removeLuaSprite("goldCookie")
            local chance = getRandomInt(1, 1)
            getGoldenCookieReward(chance)
            playSound("fortune")
        end
    else
        local find = {}
        for i=1,3 do
            table.insert(find, math.floor(getProperty("move"..i..".x")))
        end
        graphicMake("coolCol", 0, 0, 1280, 720, rgbToHex(find))
        setObjectOrder("coolCol", getObjectOrder("bar5"))
        setTextBorder("menuAbout", 2, rgbToHex(find))

        -- Le Menu Items
        if extrasState == "menu" then
            changePresence(coolState, "Cookies: "..appData.cookie.." | In Extras Menu")
            doTweenY("no no", "extras", 625, 0.25, "linear")
            local isHoveredOnSomething = false
            for i=1,#extrasName do
                setProperty("extraOutline"..i..".alpha", 1)
                setProperty("extraButton"..i..".alpha", 1)
                setProperty("extrasName"..i..".alpha", 1)
                if mouseOverlaps("extraButton"..i) then
                    isHoveredOnSomething = true
                    setTextString("menuAbout", extrasName[i][2])
                elseif not isHoveredOnSomething then
                    setTextString("menuAbout", "")
                end
                if mouseOverlaps("extraButton"..i) and mouseClicked("left") then
                    local hoverName = getTextString("extrasName"..i)
                    if not isLeaving then
                        if hoverName == "Game Settings" then
                            extrasState = "settings"
                            makeSettings()
                            makeText('settingsDesc', 0, 65, 25)
                        elseif hoverName == "Save & Exit" then
                            for k, v in pairs(appData) do
                                setDataFromSave('CCNael2xdVer', k, v)
                            end
                            flushSaveData('CCNael2xdVer')
                            if appData.jingleLeave then
                                graphicMake("bye", 0, 0, 2000, 2000, "000000", true)
                                setProperty("bye.alpha", 0)
                                setObjectOrder("bye", 2147000000)
                                doTweenAlpha("bye", "bye", 1, 3.35, "linear")
                                cancelTimer("camloop")
                                playSound("leave")
                                stopSound("hi1")
                                stopSound("hi2")
                                runTimer("quitGame", 8.5)
                                isLeaving = true
                            else
                                exitSong(true)
                            end
                        elseif hoverName == "About CCPE" then
                            extrasState = "about"
                        elseif hoverName == "Restart" then
                            restartSong(true)
                        end
                    end
                end
            end
        else
            doTweenY("no no", "extras", 750, 0.1, "linear")
            setTextString("menuAbout", "")
            for i=1,#extrasName do
                setProperty("extraOutline"..i..".alpha", 0)
                setProperty("extraButton"..i..".alpha", 0)
                setProperty("extrasName"..i..".alpha", 0)
            end
            if extrasState == "settings" then
                changePresence(coolState, "Cookies: "..appData.cookie.." | In Game Settings")
                graphicMake("infoThing1", 59, 55, 1167, 90, "FFFFFF")
                graphicMake("infoThing2", 65, 60, 1155, 80, "000000")
                setTextString("settingsDesc", settingsName[settingsChosen][3].."\nPress ESCAPE to leave Game Settings and Save your Progress.")
                if keyboardJustPressed("W") or keyboardJustPressed("Z") or keyboardJustPressed("UP") then
                    settingsChosen = settingsChosen-1
                    if settingsChosen == 0 then
                        settingsChosen = #settingsName
                    end
                    makeSettings()
                    playSound("scrollMenu")
                elseif keyboardJustPressed("S") or keyboardJustPressed("DOWN") then
                    settingsChosen = settingsChosen+1
                    if settingsChosen == #settingsName+1 then
                        settingsChosen = 1
                    end
                    makeSettings()
                    playSound("scrollMenu")
                end
                for i=1,#settingsName do
                    if i == settingsChosen then
                        setTextBorder("settings"..i, 3, "000000")
                        if settingsName[i][4] == "boolean" then
                            timerRan = false
                            cancelTimer("settingsScroll")
                            if keyJustPressed("accept") then
                                appData[settingsName[i][2]] = not appData[settingsName[i][2]]
                                playSound("confirmMenu")
                                local textToApply = appData[settingsName[i][2]]
                                local type = settingsName[i][4]
                                if type == "boolean" then
                                    textToApply = (appData[settingsName[i][2]] and "ON" or "OFF")
                                end
                                setTextString("settings"..i, settingsName[i][1]..": "..textToApply)
                            end
                        end
                        if settingsName[i][4] == "int" then
                            if not timerRan then
                                scrollFast = getSpeed()
                                runTimer("settingsScroll", settingsName[i][5][3], 0)
                            end
                            timerRan = true
                        end
                    else
                        setTextBorder("settings"..i, 0)
                    end
                end
            end
            if extrasState == "about" then
                changePresence(coolState, "Cookies: "..appData.cookie.." | In About Game")
                makeText('info', 0, 75, 50)
                setTextString("info", "Cookie Clicker: Psych Engine Edition.\nA ported game by Nael2xd.")
                setTextColor("info", rgbToHex(find))
                setTextBorder("info", 2, "000000")
                makeText('ver', 0, 600, 35)
                setTextString("ver", "Your Current Version: "..cookieVer)
                makeText('source', 0, 550, 25)
                setTextString("source", "Press ENTER to view latest releases or Press ESCAPE or BACKSPACE to return.")
                if keyboardJustPressed("ENTER") then
                    os.execute("start https://github.com/NAEL2XD/cookie-clicker-psych-edition/releases")
                end
            end
            if (keyJustPressed("pause") and not keyboardJustPressed("ENTER")) or keyboardPressed("BACKSPACE") then
                if extrasState == "settings" then
                    runTimer("save", 0.01, 1)
                end
                extrasState = "menu"
                timerRan = false
                removeLuaText("settingsDesc")
                removeLuaSprite("infoThing1")
                removeLuaSprite("infoThing2")
                removeLuaText("info")
                removeLuaText("ver")
                removeLuaText("source")
                makeSettings()
                playSound("cancelMenu")
            end
        end
    end
end

function onTimerCompleted(tag, loops, loopsLeft)
    if stringStartsWith(tag, "cps") then
        local seconds = 0
        if cps >= appData.cookieSpawnLimit then
            repeat
                seconds = seconds + (1/appData.cookieSpawnLimit)
                runTimer("cookieFall"..seconds, seconds, 1)
            until seconds >= 1
        else
            repeat
                seconds = seconds + (1/cps)
                runTimer("cookieFall"..seconds, seconds, 1)
            until seconds >= 1
        end
        appData.cookie = appData.cookie+cps
    end
    if stringStartsWith(tag, "save") and appData.autoSave then
        if stringEndsWith(tag, "Back") then
            doTweenX("save1", "Saving", 750, 0.75, "cubeIn")
            doTweenX("save2", "loading", 1485, 0.75, "cubeIn")
        else
            for k, v in pairs(appData) do
                setDataFromSave('CCNael2xdVer', k, v)
            end
            flushSaveData('CCNael2xdVer')
            doTweenX("save1", "Saving", 450, 0.75, "cubeOut")
            doTweenX("save2", "loading", 1185, 0.75, "cubeOut")
            runTimer("saveBack", 3, 1)
        end
    end
    if tag == "prodBye" then
        setTextString("prodDescription", "")
    end
    if stringStartsWith(tag, "cookieFall") then
        spawnCookies(false)
    end
    if tag == "camloop" then
        playSound("camloop", 1, "hi1")
    end
    if stringStartsWith(tag, "colorChange") then
        local aCol = {}
        for i=1,3 do
            table.insert(aCol, getRandomInt(0,255))
            doTweenX("movin"..i, "move"..i, aCol[i], 2, "linear")
        end
    end
    if tag == "settingsScroll" then
        local getVal = appData[settingsName[settingsChosen][2]]
        if keyboardPressed("Q") or keyboardPressed("A") or keyboardPressed("LEFT") then
            if getVal <= settingsName[settingsChosen][5][1] then
                appData[settingsName[settingsChosen][2]] = settingsName[settingsChosen][5][1]
            else
                appData[settingsName[settingsChosen][2]] = getVal-scrollFast
            end
        end
        if keyboardPressed("D") or keyboardPressed("RIGHT") then
            if getVal >= settingsName[settingsChosen][5][2] then
                appData[settingsName[settingsChosen][2]] = settingsName[settingsChosen][5][2]
            else
                appData[settingsName[settingsChosen][2]] = getVal+scrollFast
            end
        end
        setTextString("settings"..settingsChosen, settingsName[settingsChosen][1]..": "..tostring(math.floor(appData[settingsName[settingsChosen][2]])))
    end
    if tag == "goldenCookie" then
        if insideExtras then
            goldenCookieHere = true
        else
            spawnGoldenCookie()
        end
    end
    if tag == "gCookieBye" then
        doTweenAlpha("byeGC", "goldCookie", 0, 2.5, "linear")
        doTweenX("weews1", "goldCookie.scale", 0.75, 2.5, "linear")
        doTweenY("weews2", "goldCookie.scale", 0.75, 2.5, "linear")
    end
    if tag == "byeGC" then
        removeLuaSprite("goldCookie")
    end
    if tag == "quitGame" then
        exitSong(true)
    end
end

function onTweenCompleted(tag)
    for v in pairs(listToRemove) do
        if stringStartsWith(tag, v) then
            if luaSpriteExists(tag) then
                removeLuaSprite(tag)
            else
                removeLuaText(tag)
            end
            break
        end
    end
    if tag == "repeatGoldLeft" then
        doTweenAngle("repeatGoldRight", "goldCookie", -5, 0.25, "linear")
    end
    if tag == "repeatGoldRight" then
        doTweenAngle("repeatGoldLeft", "goldCookie", 5, 0.25, "linear")
    end
    if tag == "luck" then
        removeLuaText("luck")
        removeLuaSprite("glowin")
    end
end

function makeSprite(name, x, y, isFront)
    local name2 = name
    if stringStartsWith(name, "smallCookie") then
        name2 = "smallCookie"
    elseif stringStartsWith(name, "productInfo") then
        name2 = "productInfo"
    elseif stringStartsWith(name, "upgradeFrame") then
        name2 = "upgradeFrame"
    end
    if not (name2 == "smallCookie" and insideExtras) then
        makeLuaSprite(name, name2, 0, 0)
        addLuaSprite(name, isFront)
        setObjectCamera(name, "other")
        screenCenter(name)
        setProperty(name..".x", x)
        setProperty(name..".y", y)
    end
end

function graphicMake(name, x, y, width, height, color, center)
    if not (stringStartsWith(name, "infoThing") or name == "coolCol" or name == "yea") then
        table.insert(allGraphic, name)
    end
    makeLuaSprite(name, "", 0, 0)
    makeGraphic(name, width, height, color)
    addLuaSprite(name)
    setObjectCamera(name, "other")
    setProperty(name..".x", x)
    setProperty(name..".y", y)
    if center then
        screenCenter(name)
        setProperty(name..".y", y)
    end
end

function makeText(name, x, y, size)
    makeLuaText(name, name, 1280, x, y)
    setTextSize(name, size)
    setTextAlignment(name, 'CENTER')
    addLuaText(name)
    setObjectCamera(name, 'camOther')
    setTextBorder(name, 0)
end

function makeProduct(id)
    appData[upgradesList[id][1].."Unlocked"] = true
    makeSprite("productInfo"..id, 1000, 0 + (72 * id))
    scaleObject("productInfo"..id, 0.75, 0.75)
    makeSprite("products/"..productList[id][1], 1004, 3 + (72 * id))
    setProperty("products/"..productList[id][1]..".antialiasing", false)
    if productList[id][1] == "Cursor" then
        scaleObject("products/"..productList[id][1], 0.675, 0.675)
    else
        scaleObject("products/"..productList[id][1], 0.7375, 0.7375)
    end
    makeText(productList[id][1], 1060, 7.5 + (72 * id), 30)
    makeSprite('smallCookiePrice'..id, 1065, 45 + (72 * id))
    scaleObject("smallCookiePrice"..id, 0.25, 0.25)
    makeText("price"..id, 1085, 42 + (72 * id), 15)
    setTextColor("price"..id, "FF0000")
    setTextString("price"..id, appData[productList[id][1].."Price"])
    makeText("own"..id, -10, 8 + (72 * id), 45)
    setTextString("own"..id, appData[productList[id][1].."Own"])
    setProperty("own"..id..".alpha", 0.9)
    setTextColor("own"..id, "737163")
    setTextBorder("own"..id, 1, "959385")
    setTextAlignment("own"..id, "right")
    setTextAlignment("price"..id, "left")
    setTextAlignment(productList[id][1], "left")
    setTextBorder(productList[id][1], 1, "000000")
end

function makeUpgrade(id)
    appData[upgradesList[id][1].."Unlocked"] = true
    upgradeLength = upgradeLength+1
    makeSprite("upgradeFrame"..id, -60 + (61*upgradeLength), 0)
    scaleObject("upgradeFrame"..id, 0.5, 0.5)
    makeSprite("upgrades/"..upgradesList[id][1], -55 + (61*upgradeLength), 7.5)
    setProperty("upgrades/"..upgradesList[id][1]..".antialiasing", false)
end

function makeExtras(id)
    graphicMake("extraOutline"..id, 0, -21+(80*id), 266, 72, "FFFFFF", true)
    graphicMake("extraButton"..id, 0, -16.5+(80*id), 256, 64, "000000", true)
    makeText("extrasName"..id, 0, -5+(80*id), 30)
    setTextString("extrasName"..id, extrasName[id][1])
end

function makeSettings()
    for i=1,#settingsName do
        if settingsName[i][4] == "int" then
            appData[settingsName[i][2]] = math.floor(appData[settingsName[i][2]])
        end
        if not (extrasState == "menu") then
            local textToApply = appData[settingsName[i][2]]
            local type = settingsName[i][4]
            local xy = {175+(20*(i-settingsChosen)), 320+(60*(i-settingsChosen))}
            if type == "boolean" then
                textToApply = (appData[settingsName[i][2]] and "ON" or "OFF")
            end
            if not luaTextExists("settings"..i) then
                makeText("settings"..i, xy[1], xy[2], 50)
                setTextBorder("settings"..i, 3, "676767")
                setTextAlignment("settings"..i, "left")
                setObjectOrder("settings"..i, getObjectOrder("bar6"))
            else
                setProperty("settings"..i..".x", xy[1])
                setProperty("settings"..i..".y", xy[2])
            end
            setTextString("settings"..i, settingsName[i][1]..": "..textToApply)
        else
            removeLuaText("settings"..i)
        end
    end
    graphicMake("yea", 0, 0, 1000, 5, "000000")
end

function sortUpgrade()
    -- Deletes all frames and upgrade looks and makes it again but in ID sort.
    for i=1,#upgradesList do
        if luaSpriteExists("upgradeFrame"..i) then
            removeLuaSprite("upgradeFrame"..i)
            removeLuaSprite("upgrades/"..upgradesList[i][1])
        end
        upgradesUnlocked[i] = nil
    end
    upgradeLength = 0
    for i=1,#upgradesList do
        if (appData[upgradesList[i][4][1].."Own"] >= upgradesList[i][4][2]) and (appData[upgradesList[i][1].."Unlocked"] and not appData[upgradesList[i][1].."Bought"]) then
            makeUpgrade(i)
            table.insert(upgradesUnlocked, i)
        elseif appData[upgradesList[i][1].."Bought"] then
            table.insert(upgradesUnlocked, i)
        end
    end
end

function spawnCookies(clicked)
    -- complex shit? yeah i made it complex.
    clickCount = clickCount+1
    local opti = 'cookieClicked'..clickCount
    local x = getMouseX("other") - 635
    local y = getMouseY("other")
    local opti2 = "smallCookie"..clickCount
    local repeatTimes = (clicked and 1 or 2)
    if repeatTimes == 1 and appData.flyNumbs then
        makeText(opti, x, y, 30)
        setTextBorder(opti, 1, "000000")
        setTextString(opti, "+"..appData.cookiePerClick)
        doTweenY("click"..clickCount, opti, getProperty(opti..".y") - 200, 2.5, "linear")
        doTweenAlpha(opti, opti, 0, 2.5, "linear")
    end
    if appData.flyCookie then
        for i=repeatTimes,2 do
            if repeatTimes == 2 then
                opti2 = "smallCookieSky"..clickCount
            end
            makeSprite(opti2, (stringStartsWith(opti2, "smallCookieSky") and getRandomInt(-30, 1275) or x+617), (stringStartsWith(opti2, "smallCookieSky") and -50 or y-15), true)
            scaleObject(opti2, 0.5, 0.5)
            setProperty(opti2..".alpha", 0.65)
            if i == 1 then
                doTweenX("wee"..opti2, opti2, x+getRandomInt(417, 817), 1.5, "linear")
                doTweenY("velo"..opti2, opti2, y+(getMouseY("other")+395), 1.5, "backIn")
                doTweenAngle(opti2, opti2, getRandomInt(-90, 90), 1.5, "linear")
                doTweenAlpha("ohHi"..opti2, opti2, -0.33, 1.5, "linear")
            else
                doTweenX("weew"..opti2, opti2, getProperty(opti2..".x")+getRandomInt(-150, 150), 1.675, "5")
                doTweenY("velo1"..opti2, opti2, 900+getRandomFloat(25, 250), 1.675, "sineIn")
                doTweenAngle(opti2, opti2, getRandomInt(-180, 180), 1.675, "linear")
                doTweenAlpha("ohHi1"..opti2, opti2, -0.33, 1.675, "linear")
                setObjectOrder(opti2, getObjectOrder("background")+1)
            end
            opti2 = "smallCookieSky"..clickCount
        end
    end
end

function recalculateCps(name)
    if name == 1 then
        appData.cookiePerClick = appData.cookiePerClick*2
        appData.CursorUpgradeMult = appData.CursorUpgradeMult*2
    end
    if name == 2 then
        appData.GrandmaUpgradeMult = appData.GrandmaUpgradeMult*2
    end
    if name == 3 then
        appData.FarmUpgradeMult = appData.FarmUpgradeMult*2
    end
    if name == 4 then
        appData.FactoryUpgradeMult = appData.FactoryUpgradeMult*2
    end
    cps = appData.CursorOwn/10 * appData.CursorUpgradeMult
    for i=2,#productList do
        cps = cps + ((appData[productList[i][1].."Own"]*productList[i][3]) * appData[productList[i][1].."UpgradeMult"])
    end
end

function getGoldenCookieReward(rew)
    -- could've been thinking for some rewards, i'm lazzzzy. :(
    local x = getMouseX("other")-625
    local y = getMouseY("other")-25
    makeSprite('glowin', getMouseX("other")-175, y+5)
    scaleObject("glowin", 1.25, 1.35)
    makeText("luck", x, y, 24)
    doTweenY("Lucky!", "luck", y-150, 2.5, "cubeOut")
    doTweenAlpha("luck", "luck", 0, 5, "cubeOut")
    doTweenY("Lucky!2", "glowin", y-145, 2.5, "cubeOut")
    doTweenAlpha("glowin", "glowin", 0, 5, "cubeOut")
    if rew == 1 then
        local reward = math.floor((cps+1)*getRandomFloat(25, 200))
        setTextString("luck", "Lucky!\n+"..reward.." cookies.")
        appData.cookie = appData.cookie + reward
    end
end

function spawnGoldenCookie()
    cancelTimer("goldenCookie")
    runTimer("goldenCookie", getRandomInt(30, 150), 1)
    makeSprite("goldCookie", getRandomInt(-10, 800), getRandomInt(-10, 650), false)
    setProperty("goldCookie.alpha", 0)
    scaleObject("goldCookie", 0.75, 0.75)
    doTweenAlpha("eug", "goldCookie", 0.65, 2.5, "linear")
    doTweenX("weews1", "goldCookie.scale", 1, 2.5, "linear")
    doTweenY("weews2", "goldCookie.scale", 1, 2.5, "linear")
    runTimer("gCookieBye", getRandomInt(10, 13))
end

function getSpeed()
    local fast = 0
    local count = 0
    local getFps = getPropertyFromClass('ClientPrefs', 'framerate')
    repeat
        fast = fast + settingsName[settingsChosen][5][3]
        count = count + 1
    until fast >= 1
    return count / getFps
end

------------------------------------------------------------------------------------------------------------------------
--- CODES I USED FROM OTHER SOURCES!! ALL LINKS ARE INCLUDED ASWELL ----------------------------------------------------
------------------------------------------------------------------------------------------------------------------------

-- https://github.com/ShadowMario/FNF-PsychEngine/issues/12755#issuecomment-1641455548
function mouseOverlaps(tag)
    addHaxeLibrary('Reflect')
    return runHaxeCode([[
        var obj = game.getLuaObject(']]..tag..[[');
        if (obj == null) obj = Reflect.getProperty(game, ']]..tag..[[');
        if (obj == null) return false;
        return obj.getScreenBounds(null, obj.cameras[0]).containsPoint(FlxG.mouse.getScreenPosition(obj.cameras[0]));
    ]])
end

-- https://gist.github.com/marceloCodget/3862929
function rgbToHex(rgb)
    local hexadecimal = ''
    for key, value in pairs(rgb) do
        local hex = ''
        while (value > 0) do
            local index = math.fmod(value, 16)+1
            value = math.floor(value / 16)
            hex = string.sub('0123456789ABCDEF', index, index) .. hex
        end
        if (string.len(hex) == 0) then
            hex = '00'
        elseif (string.len(hex) == 1) then
            hex = '0' .. hex
        end
        hexadecimal = hexadecimal .. hex
    end
    return hexadecimal
end