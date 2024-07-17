-- COOKIE CLICKER PSYCH EDITION (AS ALWAYS, IT WAS MADE BY NAEL2XD)
-- DO NOT EDIT ANYTHING BELOW IF YOU DO NOT KNOW ANYTHING, PLEASE!!!!

local gameData = {
    -- Main Game
    cookies = 0,
    totalCookies = 0,
    totalClicks = 0,
    goldenCookies = 0,
    upgradesOwn = 0,
    clickMulti = 1,
    cookiePerSecond = 0,
    maxCPS = 0,
    bCPS = 0,

    -- Shop stuff
    shopOpened = false,

    -- Pricing (PROD)
    mousePrice = 15,
    mouseOwn = 0,
    grandmaPrice = 50,
    grandmaOwn = 0,
    farmPrice = 500,
    farmOwn = 0,

    -- Owning (UPGR)
    dcOwn = false,

    -- Tutorial Stuff
    tutorialBeginner = true,

    -- Timer shit
    seconds = 0,
    minutes = 0,
    hours = 0,

    -- ACHIEVEMENTS ON A LUA SPRITE??
    achievementsGot = 0,
}

local achievements = { -- ACHIEVEMENTS ON A LUA SPRITE??
    cookieGuy = false,
    cookieMaker = false,
    cookieFashionist = false,
    goldenCookieGuy = false,
    goldenCookieFortune = false,
    fastClicker = false,
    timeWaster = false,
    timeMan = false,
    mouseBuyer = false,
    mousaHolic = false,
    grandmaCookies = false,
    boughtFarm = false,
    myNewUpg = false,
}

local achievementPage = 1
local extrasType = 0
local mouseX = 0
local mouseY = 0
local ogCM = 0
local random = 0
local gcCanBeClicked = false
local feverMode = false
local inExtras = false
local inShop = false
local outputTF = false
local shopPulled = false
local tweenStarted = false
local longStats = ''
local outputAN = ''
local outputAP = ''

local DCPrice = 100

-- Here's the code.
function onCreatePost()
    loadGameData()
    debugPrint('Press "S" to save, Press "R" to reset your data.')

    local luaDebugMode = true
    setPropertyFromClass('flixel.FlxG', 'mouse.visible', true);

    makeText('cookietotal', 0, 50, 60)
    makeText('cps', 0, 120, 15)
    makeText('click', 0, 120, 30)
    makeText('stats', -720, 150, 40)

    if gameData.tutorialBeginner then
        makeText('tutorial', 0, 600, 30)
        changeTutorialText("Try to get at least 15 cookies for something to appear.")
    end

    makeLuaSprite("cookie", "game/cookie")
    addLuaSprite('cookie')
    scaleObject("cookie", 0.2, 0.2)
    screenCenter("cookie")
    setObjectCamera("cookie", "camOther")

    if not botPlay then
        setProperty('cpuControlled', true)
    end
    setProperty("click.alpha", 0)
    setProperty("camHUD.alpha", 0)
    setProperty("camGame.alpha", 0.15)

    makeLuaSprite("extrabg", "game/shopbg", -1342.5, 0)
    addLuaSprite('extrabg')
    scaleObject("extrabg", 2.5, 2)
    setObjectCamera("extrabg", "camOther")
    setProperty("extrabg.angle", 180)

    makeLuaSprite("extras", "game/extras", -125, 500)
    addLuaSprite('extras')
    scaleObject("extras", 0.5, 0.5)
    setObjectCamera("extras", "camOther")

    makeLuaSprite("statButton", "game/statButton", -1000, 625)
    addLuaSprite('statButton')
    scaleObject("statButton", 0.75, 0.75)
    setObjectCamera("statButton", "camOther")

    makeLuaSprite("achievementButton", "game/achievementButton", -785, 625)
    addLuaSprite('achievementButton')
    scaleObject("achievementButton", 0.75, 0.75)
    setObjectCamera("achievementButton", "camOther")

    runTimer("cps", 1, 0)
    runTimer("goldenCookie", math.random(30, 120), 0)

    if gameData.shopOpened then
        triggerShop(false)
        changeShopDescription("")
    end

    addHaxeLibrary('Application', 'lime.app')
    addHaxeLibrary('Image', 'lime.graphics')
    runHaxeCode([[
        var Icon:Image=Image.fromFile(Paths.modFolders('images/game/cookie.png'));
        Application.current.window.setIcon(Icon);
    ]]) -- Haxe code number 1
end

function onUpdate() -- Uh oh! Big Coding Time
    updateThings()
    if feverMode then
        gameData.clickMulti = (1 + gameData.mouseOwn) * 10
    else
        gameData.clickMulti = 1 + gameData.mouseOwn
    end
    if getPropertyFromClass("flixel.FlxG", "keys.justPressed.S") then
        saveGameData()
    end
    if getPropertyFromClass("flixel.FlxG", "keys.justPressed.R") then
        resetGameData()
        restartSong(true)
    end
    if mouseClicked("left") then
        gameData.totalClicks = gameData.totalClicks + 1
        playSound("click")
    end
    if mouseOverlaps('goldenCookie') and mouseClicked('left') and gcCanBeClicked and not (inShop or inExtras) then
        random = math.random(1, 2)
        gameData.goldenCookies = gameData.goldenCookies + 1
        if gameData.goldenCookies >= 1 and not achievements.goldenCookieGuy then
            getAchievement('goldenCookieGuy')
        end
        if random == 1 then
            ogCM = gameData.clickMulti
            gameData.clickMulti = gameData.clickMulti * math.random(10, 30)
            if gameData.clickMulti >= 500 and not achievements.goldenCookieFortune then
                getAchievement('goldenCookieFortune')
            end
            cookieClicked()
            gameData.clickMulti = ogCM
            gcCanBeClicked = false
            cancelTimer("gctime")
            cancelTween("gcbye")
            removeLuaSprite("goldenCookie")
        else
            if random == 2 then
                feverMode = true
                debugPrint('FEVER! You get 10 times the amount when you clicked!')
                gcCanBeClicked = false
                cancelTimer("gctime")
                cancelTween("gcbye")
                removeLuaSprite("goldenCookie")
                runTimer("gcFEVER", 10, 1)
            end
        end
    end
    if mouseOverlaps('cookie') and mouseClicked('left') and not (inShop or inExtras) then
        cookieClicked() -- You clicked next to the cookie, reward him.
    else
        if gameData.shopOpened then -- THE SHOP!!!!!!!!!!!!!!!!
            if mouseOverlaps('shop') and not inExtras then
                shopPulled = true
                if not inShop then
                    shopTweeninTime('1125', '0.3')
                end
                if mouseClicked('left') then
                    if not inShop then
                        if gameData.tutorialBeginner then
                            changeTutorialText("Buy the mouse item.")
                        end
                        shopTweeninTime('100', '0.65')
                        inShop = true
                    else
                        if gameData.tutorialBeginner then
                            changeTutorialText("No, Go back to the shop.")
                            if gameData.clickMulti >= 2 then
                                changeTutorialText()
                                gameData.tutorialBeginner = false
                            end
                        end
                        changeShopDescription("")
                        inShop = false
                    end
                end
            else
                if shopPulled and not inShop then
                    shopPulled = false
                    shopTweeninTime('1200', '0.65')
                else
                    if inShop then
                        changeShopDescription("Hover over an item for an info on what they do.")
                        if mouseOverlaps('mouse') then
                            changeShopDescription("Mouse - When purchased, you click the amount of times you've purchased.")
                            if mouseClicked('left') then
                                if gameData.cookies + 1 >= gameData.mousePrice then
                                    playSound("purchase")
                                    gameData.cookies = gameData.cookies - gameData.mousePrice
                                    gameData.mouseOwn = gameData.mouseOwn + 1
                                    gameData.mousePrice = gameData.mousePrice + string.format("%0f", gameData.mouseOwn)
                                    if gameData.mouseOwn >= 10 and not achievements.mousaHolic then
                                        getAchievement('mousaHolic')
                                    end
                                    if gameData.tutorialBeginner then
                                        changeTutorialText("Tutorial Complete! Have fun.")
                                        if gameData.mouseOwn <= 1 then -- You have more cookies than before, so i'm not giving you more achievements bruh!!
                                            getAchievement('mouseBuyer')
                                        end
                                    end
                                end
                            end
                        end
                        if mouseOverlaps('grandma') then
                            changeShopDescription("Grandma - When purchased, grandma will bake 3 cookies per second.")
                            if mouseClicked('left') then
                                if gameData.cookies + 1 >= gameData.grandmaPrice then
                                    playSound("purchase")
                                    gameData.cookies = gameData.cookies - gameData.grandmaPrice
                                    gameData.grandmaOwn = gameData.grandmaOwn + 1
                                    gameData.grandmaPrice = gameData.grandmaPrice + string.format("%0f", 3 * gameData.grandmaOwn)
                                    if gameData.grandmaOwn >= 1 and not achievements.grandmaCookies then
                                        getAchievement('grandmaCookies')
                                    end
                                end
                            end
                        end
                        if mouseOverlaps('farm') then
                            changeShopDescription("Farm - When purchased, the farm will grow cookie seeds worth 15 cookies per second.")
                            if mouseClicked('left') then
                                if gameData.cookies + 1 >= gameData.farmPrice then
                                    playSound("purchase")
                                    gameData.cookies = gameData.cookies - gameData.farmPrice
                                    gameData.farmOwn = gameData.farmOwn + 1
                                    gameData.farmPrice = gameData.farmPrice + string.format("%0f", 5 * gameData.farmOwn)
                                    if gameData.farmOwn >= 1 and not achievements.boughtFarm then
                                        getAchievement('boughtFarm')
                                    end
                                end
                            end
                        end
                        if mouseOverlaps('doubleCursor') then
                            changeShopDescription("Double Cursor - When you buy it, you get twice the amount when you click.")
                            if mouseClicked('left') then
                                if gameData.cookies + 1 >= DCPrice then
                                    playSound("purchase")
                                    gameData.cookies = gameData.cookies - DCPrice
                                    gameData.upgradesOwn = gameData.upgradesOwn + 1
                                    gameData.dcOwn = true
                                    removeLuaSprite("doubleCursor")
                                    removeLuaText("doubleCursorP")
                                    getAchievement('myNewUpg')
                                end
                            end
                        end
                    end
                end
            end
        end
    end
    if mouseOverlaps('extras') and not inShop then
        if not inExtras then
            extrasTweeninTime(-20, 0.65)
        end
        if mouseClicked('left') then
            if inExtras then
                extrasTweeninTime(-125, 0.65)
                inExtras = false
                if gameData.tutorialBeginner then
                    changeTutorialText("Try to get at least 15 cookies for something to appear.")
                    if gameData.shopOpened then
                        changeTutorialText("Click on the shop.")
                    end
                end
            else
                extrasTweeninTime(975, 0.65)
                inExtras = true
                if gameData.tutorialBeginner then
                    changeTutorialText("That's not how you click the cookie...")
                    if gameData.shopOpened then
                        changeTutorialText("You're seriously gonna ignore?")
                    end
                end
            end
        end
    else
        if not inExtras then
            extrasTweeninTime(-125, 0.65)
        end
    end
    if inExtras then
        if mouseOverlaps('statButton') and mouseClicked("left") then
            removeLuaText("achNameP")
            removeLuaText("achDescP")
            removeLuaText("achISunP")
            removeLuaText("achUnloP")
            removeLuaText("achPageP")
            makeText('stats', 75, 150, 40)
            extrasType = 1
        else
            if mouseOverlaps('achievementButton') and mouseClicked("left") then
                removeLuaText("stats")
                makeText('achNameP', 75, 150, 40)
                makeText('achDescP', 75, 200, 40)
                makeText('achISunP', 75, 300, 40)
                setTextString("achISunP", 'Unlocked: ')
                makeText('achUnloP', 300, 300, 40)
                makeText('achPageP', 75, 350, 40)
                extrasType = 2
            end
        end
    end
    if inExtras and extrasType == 2 then
        getListOfAchievements(achievementPage)
        setTextString("achNameP", outputAN)
        setTextString("achDescP", outputAP)
        setTextString("achUnloP", outputTF)
        setTextString("achPageP", achievementPage..' / 13')
        if getPropertyFromClass("flixel.FlxG", "keys.justPressed.LEFT") then
            achievementPage = achievementPage - 1
            if achievementPage == 0 then
                achievementPage = 13
            end
        else
            if getPropertyFromClass("flixel.FlxG", "keys.justPressed.RIGHT") then
                achievementPage = achievementPage + 1
                if achievementPage == 14 then
                    achievementPage = 1
                end
            end
        end
    end
    if mouseOverlaps('upgradeButton') and mouseClicked("left") then
        triggerShop(true)
    end
    if mouseOverlaps('itemsButton') and mouseClicked("left") then
        triggerShop(false)
    end
    if gameData.cookies >= 15 and gameData.shopOpened == false then
        gameData.shopOpened = true
        triggerShop(false)
        changeShopDescription("")
    end
end

function mouseOverlaps(tag) -- https://github.com/ShadowMario/FNF-PsychEngine/issues/12755#issuecomment-1641455548
    addHaxeLibrary('Reflect')
    return runHaxeCode([[
        var obj = game.getLuaObject(']]..tag..[[');
        if (obj == null) obj = Reflect.getProperty(game, ']]..tag..[[');
        if (obj == null) return false;
        return obj.getScreenBounds(null, obj.cameras[0]).containsPoint(FlxG.mouse.getScreenPosition(obj.cameras[0]));
    ]]) -- Haxe code number 2
end

function makeText(name, x, y, size)
    makeLuaText(name, name, 1280, x, y)
    setTextSize(name, size)
    setTextAlignment(name, 'CENTER')
    addLuaText(name)
    setObjectCamera(name, 'camOther')
    if name == 'mouseP' or name == 'grandmaP' or name =='farmP' or name == 'doubleCursorP' or name == 'stats' or name == 'achNameP' or name == 'achDescP' or name == 'achUnloP' or name == 'achPageP' or name == 'achISunP' then
        setTextAlignment(name, 'LEFT')
    end
    if name == ('achTitle' or 'achDesc') then
        setTextAlignment(name, 'RIGHT')
    end
end

function extrasTweeninTime(x, t)
    doTweenX('extrabg', "extrabg", (x - 1217.5), t, "sineOut")
    doTweenX('extras', "extras", x, t, "sineOut")
    doTweenX('stats', "stats", (x - 900), t, "sineOut")
    doTweenX('achNameP', "achNameP", (x - 900), t, "sineOut")
    doTweenX('achDescP', "achDescP", (x - 900), t, "sineOut")
    doTweenX('achISunP', "achISunP", (x - 900), t, "sineOut")
    doTweenX('achUnloP', "achUnloP", (x - 675), t, "sineOut")
    doTweenX('achPageP', "achPageP", (x - 900), t, "sineOut")
    doTweenX('statButton', "statButton", (x - 950), t, "sineOut")
    doTweenX('achievementButton', "achievementButton", (x - 665), t, "sineOut")
end

function shopTweeninTime(x, t)
    doTweenX('mouse', "mouse", (x + 200), t, "sineOut")
    doTweenX('mouseP', "mouseP", (x + 300), t, "sineOut")
    doTweenX('grandma', "grandma", (x + 230), t, "sineOut")
    doTweenX('grandmaP', "grandmaP", (x + 300), t, "sineOut")
    doTweenX('farm', "farm", (x + 230), t, "sineOut")
    doTweenX('farmP', "farmP", (x + 300), t, "sineOut")
    doTweenX('doubleCursor', "doubleCursor", (x + 230), t, "sineOut")
    doTweenX('doubleCursorP', "doubleCursorP", (x + 300), t, "sineOut")
    doTweenX('shopbg', "shopbg", (x + 92), t, "sineOut")
    doTweenX('shop', "shop", x, t, "sineOut")
    doTweenX('itemsButton', "itemsButton", (x + 575), t, "sineOut")
    doTweenX('upgradeButton', "upgradeButton", (x + 875), t, "sineOut")
end

function achTweeninTime(x, t, a)
    setTextString("achDesc", a)
    doTweenX('achTitle', "achTitle", x, t, "sineOut")
    doTweenX('achDesc', "achDesc", (x + 300), t, "sineOut")
    doTweenX('achievementTHING', "achievementTHING", (x + 800), t, "sineOut")
    runTimer("achievement", 3, 1)
end

function onTimerCompleted(tag)
    if tag == 'cps' then
        gameData.bCPS = (gameData.grandmaOwn * 3) + (gameData.farmOwn * 15)
        gameData.cookies = gameData.cookies + gameData.bCPS
        gameData.totalCookies = gameData.totalCookies + gameData.bCPS
        gameData.cookiePerSecond = gameData.bCPS
        gameData.seconds = gameData.seconds + 1
        if gameData.seconds == 60 then
            gameData.minutes = gameData.minutes + 1
            gameData.seconds = 0
            if gameData.minutes == 1 and not achievements.timeWaster then
                getAchievement('timeWaster')
            end
            if gameData.minutes == 10 and not achievements.timeMan then
                getAchievement('timeMan')
            end
        end
        if gameData.minutes == 60 then
            gameData.hours = gameData.hours + 1
            gameData.minutes = 0
        end
    end
    if tag == 'achievement' then
        doTweenX('achTitle', "achTitle", 800, 1, "sineIn")
        doTweenX('achDesc', "achDesc", 1100, 1, "sineIn")
        doTweenX('achievementTHING', "achievementTHING", 1600, 1, "sineIn")
        runTimer("achDel", 1, 1)
    end
    if tag == 'achDel' then
        removeLuaSprite("achievementTHING")
        removeLuaText("achTitle")
        removeLuaText("achDesc")
    end
    if tag == 'goldenCookie' then
        summonGoldenCookie()
    end
    if tag == 'gctime' then
        doTweenAlpha("gcbye", "goldenCookie", 0, 1, "linear")
        gcCanBeClicked = false
    end
    if tag == 'gcFEVER' then
        feverMode = false
        gameData.clickMulti = ogCM
    end
end

function onTweenCompleted(tag)
    if tag == ('movey' or 'alpha') then
        setProperty("click.visible", false)
        tweenStarted = false
    end
    if tag == 'gcbye' then
        removeLuaSprite("goldenCookie")
    end
end

function changeTutorialText(name)
    setTextString("tutorial", name)
end

function changeShopDescription(name)
    setTextString("shopDesc", name)
    if mouseOverlaps('mouse') then
        setTextString("shopDesc", name .. "\nQuantity Owned: " .. gameData.mouseOwn)
    end
    if mouseOverlaps('grandma') then
        setTextString("shopDesc", name .. "\nQuantity Owned: " .. gameData.grandmaOwn)
    end
    if mouseOverlaps('farm') then
        setTextString("shopDesc", name .. "\nQuantity Owned: " .. gameData.farmOwn)
    end
end

function triggerShop(isUpgrades)
    if isUpgrades then
        removeLuaSprite("mouse")
        removeLuaSprite("grandma")
        removeLuaSprite("farm")
        removeLuaText("mouseP")
        removeLuaText("grandmaP")
        removeLuaText("farmP")
        if not gameData.dcOwn and gameData.mouseOwn >= 1 then
            makeLuaSprite("doubleCursor", "game/upgrades/doubleCursor", 300, 150)
            addLuaSprite('doubleCursor')
            scaleObject("doubleCursor", 2, 2)
            setObjectCamera("doubleCursor", "camOther")
            makeText('doubleCursorP', 380, 165, 55)
        end
    else
        if gameData.tutorialBeginner then
            changeTutorialText("Click on the shop.")
        end
        if luaSpriteExists('doubleCursor') then
            removeLuaSprite("doubleCursor")
            removeLuaText("doubleCursorP")
        end
        if not luaSpriteExists("shop") then
            makeLuaSprite("shopbg", "game/shopbg", 1520, 0)
            addLuaSprite('shopbg')
            scaleObject("shopbg", 2.5, 2)
            setObjectCamera("shopbg", "camOther")
    
            makeLuaSprite("shop", "game/shop", 1400, 500)
            addLuaSprite('shop')
            scaleObject("shop", 0.5, 0.5)
            setObjectCamera("shop", "camOther")
        
            makeLuaSprite("itemsButton", "game/itemsButton", 1975, 625)
            addLuaSprite('itemsButton')
            scaleObject("itemsButton", 0.75, 0.75)
            setObjectCamera("itemsButton", "camOther")
            
            makeLuaSprite("upgradeButton", "game/upgradeButton", 2275, 625)
            addLuaSprite('upgradeButton')
            scaleObject("upgradeButton", 0.75, 0.75)
            setObjectCamera("upgradeButton", "camOther")
        end
        if not luaSpriteExists('mouse') then
            makeLuaSprite("mouse", "game/products/mouse", 1500, 150)
            addLuaSprite('mouse')
            scaleObject("mouse", 0.5, 0.5)
            setObjectCamera("mouse", "camOther")
            makeText('mouseP', 2000, 165, 55)
    
            makeLuaSprite("grandma", "game/products/grandma", 1530, 260)
            addLuaSprite('grandma')
            scaleObject("grandma", 0.625, 0.625)
            setObjectCamera("grandma", "camOther")
            shopTweeninTime('1200', '0.3')
            makeText('grandmaP', 1500, 265, 55)
    
            makeLuaSprite("farm", "game/products/farm", 1530, 355)
            addLuaSprite('farm')
            scaleObject("farm", 0.625, 0.625)
            setObjectCamera("farm", "camOther")
            shopTweeninTime('1200', '0.3')
            makeText('farmP', 1500, 360, 55)
    
            makeText('shopDesc', 0, 10, 20)
        end
    end
end

function updateThings()
    if luaTextExists("stats") then
        longStats = 'Time Wasted: '..gameData.hours..':'..gameData.minutes..':'..gameData.seconds..'\nTotal Clicks: '..gameData.totalClicks..'\nCookies Gained Lifetime: '..gameData.totalCookies..'\nGolden Cookies Clicked: '..gameData.goldenCookies..'\nAchievements Got: '..gameData.achievementsGot..'/13\nUpgrades Own: '..gameData.upgradesOwn..'/1'
        setTextString('stats', longStats)
    end
    setPropertyFromClass('lime.app.Application', 'current.window.title', "Cookie Clicker PSYCH EDITION")
    setTextString("cookietotal", gameData.cookies)
    setTextString("cps", gameData.cookiePerSecond .. " CPS\n" .. gameData.maxCPS .. " max CPS")
    setTextString('mouseP', gameData.mousePrice)
    setTextString('grandmaP', gameData.grandmaPrice)
    setTextString('farmP', gameData.farmPrice)
    setTextString('doubleCursorP', DCPrice)
end

function resetGameData()
    local dgd = {
        cookies = 0,
        totalCookies = 0,
        totalClicks = 0,
        goldenCookies = 0,
        upgradesOwn = 0,
        clickMulti = 1,
        cookiePerSecond = 0,
        maxCPS = 0,
        bCPS = 0,
        shopOpened = false,
        mousePrice = 15,
        mouseOwn = 0,
        grandmaPrice = 50,
        grandmaOwn = 0,
        farmPrice = 500,
        farmOwn = 0,
        dcOwn = false,
        tutorialBeginner = true,
        seconds = 0,
        minutes = 0,
        hours = 0,
        achievementsGot = 0,
    }
    local da = {
        cookieGuy = false,
        cookieMaker = false,
        cookieFashionist = false,
        goldenCookieGuy = false,
        goldenCookieFortune = false,
        fastClicker = false,
        timeWaster = false,
        timeMan = false,
        mouseBuyer = false,
        mousaHolic = false,
        grandmaCookies = false,
        boughtFarm = false,
        myNewUpg = false,
    }
    for k, v in pairs(dgd) do
        setDataFromSave('CCNael2xdVerGD', k, v)
    end
    flushSaveData('CCNael2xdVerGD')
    for k, v in pairs(da) do
        setDataFromSave('CCNael2xdVerAC', k, v)
    end
    flushSaveData('CCNael2xdVerAC')
end

function loadGameData()
    initSaveData('CCNael2xdVerGD')
    for k, v in pairs(gameData) do
        gameData[k] = getDataFromSave('CCNael2xdVerGD', k, v)
    end
    initSaveData('CCNael2xdVerAC')
    for k, v in pairs(achievements) do
        achievements[k] = getDataFromSave('CCNael2xdVerAC', k, v)
    end
end

function saveGameData()
    for k, v in pairs(gameData) do
        setDataFromSave('CCNael2xdVerGD', k, v)
    end
    flushSaveData('CCNael2xdVerGD')
    for k, v in pairs(achievements) do
        setDataFromSave('CCNael2xdVerAC', k, v)
    end
    flushSaveData('CCNael2xdVerAC')
    playSound("success")
end

function getAchievement(achName)
    cancelTimer("achievement")
    cancelTimer("achDel")
    if luaSpriteExists("achievementTHING") then
        removeLuaSprite("achievementTHING")
        removeLuaText("achTitle")
        removeLuaText("achDesc")
    end
    makeText('achTitle', 800, 165, 40)
    makeText('achDesc', 1100, 205, 20)
    setTextString("achTitle", "Achievement Unlocked:")
    makeLuaSprite("achievementTHING", "game/achievement", 1600, 165)
    addLuaSprite('achievementTHING')
    scaleObject("achievementTHING", 0.6, 0.3)
    setObjectCamera("achievementTHING", "camOther")

    -- Lists of achievements
    if achName == 'cookieGuy' then
        achievements.cookieGuy = true
        achName = 'Cookie Guy'
    end
    if achName == 'cookieMaker' then
        achievements.cookieMaker = true
        achName = 'Cookie Maker'
    end
    if achName == 'cookieFashionist' then
        achievements.cookieFashionist = true
        achName = 'Cookie Fashionist'
    end
    if achName == 'goldenCookieGuy' then
        achievements.goldenCookieGuy = true
        achName = 'Golden Cookie Guy I'
    end
    if achName == 'goldenCookieFortune' then
        achievements.goldenCookieFortune = true
        achName = 'Golden Cookie Fortune'
    end
    if achName == 'fastClicker' then
        achievements.fastClicker = true
        achName = 'Fast Clicker'
    end
    if achName == 'timeWaster' then
        achievements.timeWaster = true
        achName = 'Time Waster I'
    end
    if achName == 'timeMan' then
        achievements.timeMan = true
        achName = 'Time Waster II'
    end
    if achName == 'mouseBuyer' then
        achievements.mouseBuyer = true
        achName = 'Mouse Buyer'
    end
    if achName == 'mousaHolic' then
        achievements.mousaHolic = true
        achName = 'Mouse-A Holic'
    end
    if achName == 'grandmaCookies' then
        achievements.grandmaCookies = true
        achName = "Grandma's Cookies"
    end
    if achName == 'boughtFarm' then
        achievements.boughtFarm = true
        achName = 'Bought the farm'
    end
    if achName == 'myNewUpg' then
        achievements.myNewUpg = true
        achName = 'My First Upgrade'
    end
    gameData.achievementsGot = gameData.achievementsGot + 1
    playSound("achievement unlocked")
    achTweeninTime("0", "1", achName)
end

function summonGoldenCookie()
    makeLuaSprite("goldenCookie", "game/GoldCookie", math.random(0, 1185), math.random(0, 625))
    addLuaSprite('goldenCookie')
    setObjectCamera("goldenCookie", "camOther")
    setProperty("goldenCookie.alpha", 0)
    doTweenAlpha("gcalpha", "goldenCookie", 1, 2, "linear")
    runTimer("gctime", 12, 1)
    gcCanBeClicked = true
end

function cookieClicked()
    if tweenStarted then
        cancelTween("movey")
        cancelTween("alpha")
    end
    if gameData.dcOwn then
        gameData.cookies = gameData.cookies + (gameData.clickMulti * 2)
        gameData.cookiePerSecond = gameData.cookiePerSecond + (gameData.clickMulti * 2)
        setTextString('click', '+' .. gameData.clickMulti * 2)
    else
        gameData.cookies = gameData.cookies + gameData.clickMulti
        gameData.cookiePerSecond = gameData.cookiePerSecond + gameData.clickMulti
        setTextString('click', '+' .. gameData.clickMulti)
    end
    gameData.totalCookies = gameData.totalCookies + gameData.clickMulti
    if gameData.maxCPS <= gameData.cookiePerSecond then
        gameData.maxCPS = gameData.cookiePerSecond
    end
    mouseX = getMouseX("other") - 635
    mouseY = getMouseY("other")
    setProperty("click.visible", true)
    setProperty("click.alpha", 1)
    setProperty("click.x", mouseX)
    setProperty("click.y", mouseY)
    doTweenY("movey", "click", (mouseY - 175), 2, "linear")
    doTweenAlpha("alpha", "click", 0, 2, "linear")
    tweenStarted = true
    if gameData.cookiePerSecond >= 100 and not achievements.fastClicker then
        getAchievement('fastClicker')
    end
    if gameData.cookies >= 100 and not achievements.cookieGuy then
        getAchievement('cookieGuy')
    end
    if gameData.cookies >= 1000 and not achievements.cookieMaker then
        getAchievement('cookieMaker')
    end
    if gameData.cookies >= 10000 and not achievements.cookieFashionist then
        getAchievement('cookieFashionist')
    end
end

function getListOfAchievements(n)
    if n == 1 then
        n = 'Cookie Guy'
        outputAP = 'Get 100 cookies.'
        if achievements.cookieGuy then
            outputTF = true
        else
            outputTF = false
        end
    end
    if n == 2 then
        n = 'Cookie Maker'
        outputAP = 'Get 1,000 cookies.'
        if achievements.cookieMaker then
            outputTF = true
        else
            outputTF = false
        end
    end
    if n == 3 then
        n = 'Cookie Fashionist'
        outputAP = 'Get 10,000 cookies.'
        if achievements.cookieFashionist then
            outputTF = true
        else
            outputTF = false
        end
    end
    if n == 4 then
        n = 'Golden Cookie Guy I'
        outputAP = 'Click the Golden Cookie.'
        if achievements.goldenCookieGuy then
            outputTF = true
        else
            outputTF = false
        end
    end
    if n == 5 then
        n = 'Golden Cookie Fortune'
        outputAP = 'Get 500 cookies from a Golden Cookie.'
        if achievements.goldenCookieFortune then
            outputTF = true
        else
            outputTF = false
        end
    end
    if n == 6 then
        n = 'Fast Clicker'
        outputAP = 'Get 100 CPS.'
        if achievements.fastClicker then
            outputTF = true
        else
            outputTF = false
        end
    end
    if n == 7 then
        n = 'Time Waster I'
        outputAP = 'Play for 1 minute.'
        if achievements.timeWaster then
            outputTF = true
        else
            outputTF = false
        end
    end
    if n == 8 then
        n = 'Time Waster II'
        outputAP = 'Play for 10 minutes.'
        if achievements.timeMan then
            outputTF = true
        else
            outputTF = false
        end
    end
    if n == 9 then
        n = 'Mouse Buyer'
        outputAP = 'Buy your first mouse.'
        if achievements.mouseBuyer then
            outputTF = true
        else
            outputTF = false
        end
    end
    if n == 10 then
        n = 'Mouse-A Holic'
        outputAP = 'Buy 10 mouses.'
        if achievements.mousaHolic then
            outputTF = true
        else
            outputTF = false
        end
    end
    if n == 11 then
        n = "Grandma's Cookies"
        outputAP = 'Buy your first grandma.'
        if achievements.grandmaCookies then
            outputTF = true
        else
            outputTF = false
        end
    end
    if n == 12 then
        n = "Bought the farm"
        outputAP = 'Buy your first farm.'
        if achievements.boughtFarm then
            outputTF = true
        else
            outputTF = false
        end
    end
    if n == 13 then
        n = "My First Upgrade!"
        outputAP = 'Buy a new upgrade from the upgrade section.'
        if achievements.myNewUpg then
            outputTF = true
        else
            outputTF = false
        end
    end
    outputAN = n
end
