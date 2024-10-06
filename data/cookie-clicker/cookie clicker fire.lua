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

    -- upgrades
    rifUnlocked = false,
    rifBought = false,

    ctpcUnlocked = false,
    ctpcBought = false,

    AmbidextrousUnlocked = false,
    AmbidextrousBought = false,

    frgUnlocked = false,
    frgBought = false,
}

-- Game Data (no save)
local cps = 0
local cookieVer = "0.2.0"

-- non list
local clickCount = 0
local cookieOverlap = false
local upgradeLength = 0
local productHovered = false

-- list
local productList = {
    {"Cursor",  "Autoclicks once every 10 seconds.",   0.1,  15,  15, 1.15},
    {"Grandma", "A nice grandma to bake more cookies",   1, 100, 100, 1.25}
}

local upgradesList = {
    {"rif",          "The mouse and cursors are twice as efficient.", 1, {"Cursor",  1},   100},
    {"ctpc",         "The mouse and cursors are twice as efficient.", 1, {"Cursor",  1},  1000},
    {"Ambidextrous", "The mouse and cursors are twice as efficient.", 1, {"Cursor", 10}, 10000},
    {"frg",          "Grandmas are twice as efficient.",              2, {"Grandma", 1},  1000},
}

local currentUpgradeSpawn = {} -- Leaving it empty
local upgradesUnlocked = {}

local listToRemove = {
    "cookie", "smallCookie", "click", "intro", "cookieClicked"
}

function onCreatePost()
    initSaveData('CCNael2xdVer')
    for k, v in pairs(appData) do
        appData[k] = getDataFromSave('CCNael2xdVer', k, v)
    end

    setProperty("camGame.alpha", 0)
    setProperty("camHUD.alpha", 0)
    setPropertyFromClass("ClientPrefs", "hideHud", true)
    setPropertyFromClass('flixel.FlxG', 'mouse.visible', true)

    -- Text Stuff
    makeText("cookieOwn", 0, 75, 60)
    makeText("cpsOwn", 0, 145, 20)
    makeText("prodDescription", 0, 635, 25)
    setTextString("prodDescription", "")
    makeText("Saving", 750, 650, 45)
    setTextString("Saving", "Saving...")
    makeText("ccpe", 2, 702, 12)
    setTextAlignment("ccpe", "left")
    setTextString("ccpe", "Cookie Clicker Psych Edition (v"..cookieVer..")")

    -- Sprites (i should precache them)
    makeSprite("background", 0, 0)
    scaleObject("background", 1.25, 0.775)
    makeSprite("glowBlack", 0, 365)
    scaleObject("glowBlack", 1.35, 1)
    makeSprite("cookie", 0, 0)
    scaleObject("cookie", 0.2, 0.2)
    screenCenter("cookie")

    makeAnimatedLuaSprite("loading", "loading", 1485, 640)
    addAnimationByPrefix("loading", "loading", "loading", 12, true)
    addLuaSprite("loading", true)
    scaleObject("loading", 0.5, 0.5)
    setObjectCamera("loading", "other")

    runTimer("cps", 1, 0)
    runTimer("save", 60, 0)

    for i in pairs(productList) do
        if appData.cookie >= productList[i][4] then
            makeProduct(i)
        end
    end

    for i in pairs(upgradesList) do
        if (appData[upgradesList[i][4][1].."Own"] >= upgradesList[i][4][2]) and (appData[upgradesList[i][1].."Unlocked"] and not appData[upgradesList[i][1].."Bought"]) then
            makeUpgrade(i)
            table.insert(upgradesUnlocked, i)
        else
            if appData[upgradesList[i][1].."Bought"] then
                table.insert(upgradesUnlocked, i)
            end
        end
    end

    makeSprite("intro", 0, 0, true)
    doTweenX("introx", "intro.scale", 200, 3, "easeIn")
    doTweenY("introy", "intro.scale", 200, 3, "easeIn")

    recalculateCps()
end

function onPause()
    restartSong(true)
end

function onUpdate()
    setTextString("cookieOwn", math.floor(appData.cookie))
    setTextString("cpsOwn", cps.." cookies per second")

    if mouseClicked("left") then
        playSound("click")
    end

    if productHovered then
        productHovered = false
        runTimer("prodBye", 0, 1)
    end

    -- Products
    for i in pairs(productList) do
        setBlendMode("productInfo"..i, "NORMAL")
        if mouseOverlaps("productInfo"..i) then
            productHovered = true
            setBlendMode("productInfo"..i, "LIGHTEN")
            setTextString("prodDescription", productList[i][2])
            if mouseClicked("left") and appData.cookie >= appData[productList[i][1].."Price"] then
                playSound("purchase")
                appData.cookie = appData.cookie - appData[productList[i][1].."Price"]
                appData[productList[i][1].."Own"] = appData[productList[i][1].."Own"] + 1
                appData[productList[i][1].."Price"] = math.floor(appData[productList[i][1].."Price"] * productList[i][6])
                setTextString("price"..i, math.floor(appData[productList[i][1].."Price"]))
                setTextString("own"..i, appData[productList[i][1].."Own"])
                for ii in pairs(upgradesList) do
                    local isUnlocked = true
                    for iii in pairs(upgradesUnlocked) do
                        if ii == upgradesUnlocked[iii] then
                            isUnlocked = false
                        end
                    end
                    if (appData[upgradesList[ii][4][1].."Own"] >= upgradesList[ii][4][2]) and isUnlocked then
                        makeUpgrade(ii)
                        table.insert(upgradesUnlocked, ii)
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
    for i in pairs(upgradesList) do
        setBlendMode("upgradeFrame"..i, "NORMAL")
        if mouseOverlaps("upgradeFrame"..i) then
            setBlendMode("upgradeFrame"..i, "LIGHTEN")
            setTextString("prodDescription", upgradesList[i][2].."\nCookie Costs: "..upgradesList[i][5])
            productHovered = true
            if mouseClicked("left") and appData.cookie >= upgradesList[i][5] then
                playSound("purchase")
                appData.cookie = appData.cookie - upgradesList[i][5]
                upgradeLength = upgradeLength - 1
                appData[upgradesList[i][1].."Bought"] = true
                removeLuaSprite("upgradeFrame"..i)
                removeLuaSprite("upgrades/"..upgradesList[i][1])
                local exists = 0
                for ii=1,#upgradesList do
                    if luaSpriteExists("upgradeFrame"..ii) then
                        exists = exists + 1
                        setProperty("upgradeFrame"..ii..".x", -60 + (60*exists))
                        setProperty("upgrades/"..upgradesList[ii][1]..".x", -55 + (60*exists))
                    end
                end
                table.remove(currentUpgradeSpawn, i)
                recalculateCps(upgradesList[i][3]) -- HUH??? WHY DOES IT NOT SEND!? IS IT STUPID???
            end
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
            for i in pairs(productList) do
                if appData.cookie >= productList[i][5] and not luaTextExists("price"..i) then
                    makeProduct(i)
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
end

function onTimerCompleted(tag, loops, loopsLeft)
    if stringStartsWith(tag, "cps") then
        local seconds = 0
        repeat
            seconds = seconds + (1/cps)
            runTimer("cookieFall"..seconds, seconds, 1)
        until seconds >= 1
        appData.cookie = appData.cookie + math.fmod(cps,1)
    end
    if stringStartsWith(tag, "save") then
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
        appData.cookie = appData.cookie + 1
        spawnCookies(false)
    end
end

function onTweenCompleted(tag)
    for k, v in pairs(listToRemove) do
        if stringStartsWith(tag, v) then
            if luaSpriteExists(tag) then
                removeLuaSprite(tag)
            else
                removeLuaText(tag)
            end
            break
        end
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
    makeLuaSprite(name, name2, 0, 0)
    addLuaSprite(name, isFront)
    setObjectCamera(name, "other")
    screenCenter(name)
    setProperty(name..".x", x)
    setProperty(name..".y", y)
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
    if productList[id][1] == "Cursor" then
        scaleObject("products/"..productList[id][1], 0.675, 0.675)
    else
        scaleObject("products/"..productList[id][1], 0.7375, 0.7375)
    end
    makeText(productList[id][1], 1060, 5 + (72 * id), 35)
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
end

function makeUpgrade(id)
    appData[upgradesList[id][1].."Unlocked"] = true
    upgradeLength = upgradeLength + 1
    table.insert(currentUpgradeSpawn, id)
    makeSprite("upgradeFrame"..id, -60 + (61*upgradeLength), 0)
    scaleObject("upgradeFrame"..id, 0.5, 0.5)
    makeSprite("upgrades/"..upgradesList[id][1], -55 + (61*upgradeLength), 7.5)
end

function spawnCookies(isClicked)
    clickCount = clickCount + 1
    local opti = 'cookieClicked'..clickCount
    local x = getMouseX("other") - 635
    local y = getMouseY("other")
    local opti2 = "smallCookie"..clickCount
    local repeatTimes = (isClicked and 1 or 2)
    if repeatTimes == 1 then
        makeText(opti, x, y, 25)
    end
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
            setTextString(opti, "+"..appData.cookiePerClick)
            doTweenY("click"..clickCount, opti, getProperty(opti..".y") - 200, 2.5, "linear")
            doTweenAlpha(opti, opti, 0, 2.5, "linear")
        else
            doTweenX("weew"..opti2, opti2, getProperty(opti2..".x")+getRandomInt(-150, 150), 1.675, "5")
            doTweenY("velo1"..opti2, opti2, 900, 1.675, "sineIn")
            doTweenAngle(opti2, opti2, getRandomInt(-180, 180), 1.675, "linear")
            doTweenAlpha("ohHi1"..opti2, opti2, -0.33, 1.675, "linear")
        end
        opti2 = "smallCookieSky"..clickCount
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
    cps = appData.CursorOwn/10 * appData.CursorUpgradeMult
    cps = cps + (appData.GrandmaOwn * appData.GrandmaUpgradeMult)
end

------------------------------------------------------------------------------------------------------------------------

function mouseOverlaps(tag) -- https://github.com/ShadowMario/FNF-PsychEngine/issues/12755#issuecomment-1641455548
    addHaxeLibrary('Reflect')
    return runHaxeCode([[
        var obj = game.getLuaObject(']]..tag..[[');
        if (obj == null) obj = Reflect.getProperty(game, ']]..tag..[[');
        if (obj == null) return false;
        return obj.getScreenBounds(null, obj.cameras[0]).containsPoint(FlxG.mouse.getScreenPosition(obj.cameras[0]));
    ]])
end