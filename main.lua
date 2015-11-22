---------------------------------------------------------------------------------
--
-- main.lua
--
---------------------------------------------------------------------------------

display.setStatusBar( display.HiddenStatusBar )

local composer 	= require "composer"
local physics 	= require "physics"

physics.start( ) --physics.pause( )

display.setDefault( "background", 1, 1, 1 )
local _H = display.contentCenterY
local _W = display.contentCenterX
local areenText 	= display.newImage( "assets/areen.png", _W-20, _H-95  )
local physicsText 	= display.newImage( "assets/physics.png", _W, _H  )
local waelText 		= display.newImage( "assets/wael2.png", _W, _H+400 )
--waelText.isVisible = true
local topBar 	= display.newRect( _W, _H-90, 160, 5 )
local bottomBar = display.newRect( _W-3, _H+23, 160, 5 )
local floor 	= display.newRect( _W, _H+285, 5, 350 )
local rightWall = display.newRect( _W+160, _H+120, 5, 350 )
local leftWall 	= display.newRect( _W-160, _H+120, 5, 350 )

local group = display.newGroup( )

floor.rotation 			= 90
topBar.rotation 		= -45
bottomBar.rotation 		= 45
areenText.rotation 		= -45
physicsText.rotation 	= 45

topBar:setFillColor( 0,0,0 )
bottomBar:setFillColor( 0,0,0 )
areenText:scale(0.3, 0.3)
physicsText:scale(0.3, 0.3)

group:insert( areenText )
group:insert( physicsText )
group:insert( topBar )
group:insert( bottomBar )
group:insert( floor )
group:insert( rightWall )
group:insert( waelText )
group:insert( leftWall )

physics.addBody( topBar, "kinematic", { friction=0.5, bounce=0.3 } )
physics.addBody( bottomBar, "kinematic", { friction=0.5, bounce=0.3 } )
physics.addBody( floor, "kinematic", { friction=0.5, bounce=0.1 } )
physics.addBody( rightWall, "kinematic", { friction=0.5, bounce=0.3 } )
physics.addBody( leftWall, "kinematic", { friction=0.5, bounce=0.3 } )

-- Vertex shape
local bodyShape = { 0, -20, 30, -20, 55, 15, -50, 15, -20, -20 }

physics.addBody( areenText, "dynamic", { friction=0.5, bounce=0.1, shape = bodyShape } )
physics.addBody( physicsText, "dynamic", { friction=0.5, bounce=0.3, shape = bodyShape } )
waelText.isBullet 		= true
areenText.isBullet 		= true
physicsText.isBullet 	= true
areenText.isSleepingAllowed 	= false
physicsText.isSleepingAllowed 	= false

local function gtfoToo()
	composer.gotoScene(  "scene1" )
	group:removeSelf()
	group = nil
end

local function throwWael()
	timer.performWithDelay( 1500, function()
	transition.to( waelText, {y = -1000, time = 1000, transition = easing.inBack, onComplete = gtfoToo} ) end)
end

local function throwHer()
	rightWall:removeSelf( )
	leftWall:removeSelf( )
	timer.performWithDelay( 1000, function ()
	transition.to( waelText, { rotation = 360, time = 1500, onComplete = throwWael}) end)
end

local function gtfo()
	--transition.to( floor, { y = 800, time = 1000} )
	physics.addBody( waelText, "static", { friction=0.5, bounce=0.3 } )
	transition.to( waelText, { y = _H, x = _W, time = 1500, onComplete = throwHer} )
	floor:removeSelf()
end

timer.performWithDelay(1500, 
	function ()
	transition.to( bottomBar, { x = _W-500, y = _H-500, time = 3000 } )
	transition.to( topBar, { x = display.contentScaleX + 500 , y = display.contentScaleY-200, time = 3000, onComplete = gtfo } )

end)

--physics.setDrawMode( "hybrid" )
--composer.gotoScene( "scene1" )

