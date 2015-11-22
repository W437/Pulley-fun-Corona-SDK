---------------------------------------------------------------------------------
--
-- scene.lua
--
---------------------------------------------------------------------------------

local composer 	= require( "composer" )
local physics 	= require( "physics" )
local widget 	= require( "widget" )

physics.start( )
physics.setContinuous( false )
--physics.setDrawMode( "normal")
local scene = composer.newScene()

---------------------------------------------------------------------------------
local _H = display.contentCenterY
local _W = display.contentCenterX
local crate
local crate2
local gear
local platform
local floor
local rightWall, leftWall
local crateXY, crate2XY
local drawMode = {hybrid="false", normal="true", debug="false"}
local wall
local button
local boxes = {}
local boxWeight
local fixedRotation = true
local box

function scene:create( event )
    local sceneGroup = self.view
    local relativeScaling = 0
    local waelbg = display.newImage( "assets/waelbg.png", _W, _H  )
    waelbg:scale( 0.316, 0.316 )
    crate = display.newImageRect( "assets/box.png", 50, 50 )
    --crate:setFillColor( 0, 0, 0 )
    crate2 = display.newImageRect( "assets/box2.png", 50, 50 )
    wall = display.newRect( _W+45, _H-200, 10, 100 )
    wall.alpha = 0
    gear = display.newImageRect("assets/gear.png", 20, 20)
    platform = display.newImageRect( "assets/platform.png", 200, 50 )
    
    platform.x 	= _W - 70 
    platform.y 	= _H - 80
    crate.x 	= _W - 120 
    crate.y 	= _H - 150 
    crate2.x 	= _W + 50
    crate2.y 	= _H + 100
    gear.x 		= _W + 40
    gear.y 		= _H - 125
    
    floor 		= display.newRect( _W, _H+285, 5, 350 )
    rightWall 	= display.newRect( _W+163, _H+120, 5, 350 )
    leftWall	= display.newRect( _W-163, _H+120, 5, 350 )
    floor.alpha 	= 0
    rightWall.alpha = 0
    leftWall.alpha 	= 0
    floor.rotation 	= 90

--[[
    local myJoints = {}
for i = 1,5 do
    local link = {}
    for j = 1,17 do
        link[j] = display.newImage( "link.png" )
        link[j].x = 121 + (i*34)
        link[j].y = 55 + (j*17)
        physics.addBody( link[j], { density=2.0, friction=0, bounce=0 } )
        if (j > 1) then
            prevLink = link[j-1] 
        else
            prevLink = crate 
        end
        myJoints[#myJoints + 1] = physics.newJoint( "pivot", prevLink, link[j], 121 + (i*34), 46 + (j*17) )

    end
end
--]]

end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if phase == "will" then
        -- Called when the scene is still off screen and is about to move on screen
    elseif phase == "did" then

    local crate2Weight 	= display.newText( "" .. crate.width .. "kg" , crate2.x, crate2.y + 50,  native.systemFont, 12 )
    local gravityText 	= display.newText( "[G] (m/s²)" .. "\nx: 0\ny: 9.8"  , _W-124, _H+138, 60, 0,  native.systemFont, 12, "left" )
    local crateWeight 	= display.newText( "" .. crate.width .. "kg" , crate.x, crate.y + 50,  native.systemFontBold, 12 )
    local crateXY 		= display.newText( "[CRATE 1] \nX: " .. crate.x .. "\nY: " .. crate.y .. "\nR: " .. string.format( "%6.6f", crate.rotation )
        .. "\nSX: " .. crate.xScale .. "\nSY: " .. crate.yScale, _W-120, _H - 10, 70, 0, native.systemFont, 12, "left" )
    local crate2XY = display.newText( "[CRATE 2] \nX: " .. crate2.x .. "\nY: " .. crate2.y .."\nr: " .. crate2.rotation ..  "\nisFixed: " .. tostring(fixedRotation), _W-120, _H+80, 70, 0, native.systemFont, 12, "left" )
    
    physics.addBody( crate2, "dynamic", { friction=0.5, bounce=0.3 } )
    crate2.isFixedRotation = true
    physics.addBody( crate, "dynamic", { friction=0.5, bounce=0.3 } )
    physics.addBody( gear, "static", { friction=0.5, bounce=0.3, radius = 9 } )
    crate2.isSleepingAllowed = flase
    physics.addBody( platform, "static", { friction=0.5, bounce=0.3 } )
    physics.addBody( wall, "static", { friction=0.5, bounce=0.3 } )
    --physics.addBody( floor, "static", { friction=0.5, bounce=0.1 } )
    physics.addBody( rightWall, "static", { friction=0.5, bounce=0.3 } )
    physics.addBody( leftWall, "static", { friction=0.5, bounce=0.3 } )
    local pulleyJoint = physics.newJoint( "pulley", crate, crate2, crate.x+170, crate.y+18, crate2.x,
     crate2.y, crate.x, crate.y, crate2.x, crate2.y, 1.0 )

    local function sliderListener( event )
        if(event.value < 20) then 
            event.value = 20
        else
            print( "Slider at " .. event.value .. "%" )
            local crateScale = event.value 
            local cY, cX = crate.y, crate.x
            crate.width = crateScale
            crate.height = crateScale
            physics.removeBody( crate )
            physics.addBody( crate, "dynamic", { friction=0.5, bounce=0.3 } )
            resetCrateCoordinates()
            local pulleyJoint = physics.newJoint( "pulley", crate, crate2, crate.x+170, crate.y+18, crate2.x,
                crate2.y, crate.x, crate.y, crate2.x, crate2.y, 1.0 )
            crate.isSleepingAllowed = false
            crate.rotation, crate2.rotation = 0
        end
    end

    local function spawnBox(event)
        if(event.phase == "ended") then
            --boxes = {}
            box = display.newImageRect( "assets/box.png", 25, 25 ) 
            box.x = event.x
            box.y = event.y
            physics.addBody( box, "dynamic", { bounce=0.3, friction = 0.5 } )
            box.isSleepingAllowed = false
            boxes[#boxes + 1] = box
        end
    end
    Runtime:addEventListener( "touch", spawnBox )

    local function btnListener(event)
        if(drawMode.normal == "true") then
            physics.setDrawMode( "debug" )
            drawMode.normal = "false"
            drawMode.debug = "true"
            timer.performWithDelay( 2500, 
                function ()
                    physics.setDrawMode("hybrid")
                    button:setLabel("HYBRID")
                    drawMode.debug = "false"
                    drawMode.hybrid = "true" 
                end 
            )
        elseif(drawMode.hybrid == "true") then
            physics.setDrawMode( "normal" )
            button:setLabel("NORMAL")
            drawMode.hybrid = "false"
            drawMode.normal = "true"
        end
    end

    local function btnListener2(event)
        if(event.phase == "ended") then
            for i=1, #boxes, 1 do
                print("removing " .. i)
                boxes[i]:removeSelf()
                print(i .. " removed")
                boxes[i] = nil
            end
        end
    end

	local function btnListener3(event)
    	if(event.phase == "ended") then
        	if(crate2.isFixedRotation == true) then
            	crate2.isFixedRotation = false
            	fixedRotation = false
            	button3:setLabel( "UNFIXED" )
        	else
            	crate2.isFixedRotation = true
            	fixedRotation = true
            	button3:setLabel( "FIXED" )
        	end
    	end
	end

    local function gravityListenerY(event)
        local gy2 = event.value / 10
        local gx, gy = physics.getGravity( )
        physics.setGravity( gx, gy2 ) 
    end

    local function gravityListenerX(event)
        local gx2 = event.value / 10
        local gx, gy = physics.getGravity( )
        physics.setGravity( gx2, gy ) 
    end
     
    --[[
    local function gravityListener( event, axis )
    	if( axis == "x" ) then
    		local gxt = event.value / 10
    		local gx, gy = physics.getGravity()
    		physics.setGravity(gxt, gy)
    	else 
    		local gyt = event.value / 10
    		local gx, gy = physics.getGravity()
    		physics.setGravity(gx, gyt)
    	end
    end
--]]

    button = widget.newButton
    {
        id = "drawBtn",
        label = "NORMAL",
        width = 100,
        height = 30,
        x = _W - 30,
        y = _H - 30,
        shape = "roundedRect",
        onRelease = btnListener

    }


    button3 = widget.newButton
    {
        id = "isFXDROTATION",
        label = "FIXED",
        width = 100,
        height = 30,
        x = _W - 30,
        y = _H + 40,
        shape = "roundedRect",
        onRelease = btnListener3

    }

    button3.alpha = 0.6

    button2 = widget.newButton
    {
        id = "removeBtn",
        label = "DESTROY",
        width = 100,
        height = 30,
        x = _W - 30,
        y = _H + 5,
        shape = "roundedRect",
        onRelease = btnListener2

    }
    
    button2.alpha = 0.6
    button.alpha = 0.6

    local slider = widget.newSlider
    {
        x = _W,
        y = _H-250,
        width = 250,
        value = 50,  
        listener = sliderListener
    }

    local gravityY = widget.newSlider
    {
        x = _W-140,
        y = _H+210,
        height = 100,
        value = 98, 
        orientation  = "vertical", 
        listener = gravityListenerY
    }

    local gravityX = widget.newSlider
    {
        x = _W-110,
        y = _H+230,
        height = 100,
        value = 0, 
        orientation  = "vertical", 
        listener = gravityListenerX
    }

    function resetCrateCoordinates()
        crate.x = _W - 120
        crate.y = _H - 150
        crate2.x = _W + 50
        crate2.y = _H + 100
        return true
    end

    local function getRotation( n )
    	local cR
    	if( n == 1 ) then
        	if crate.rotation > 360 or crate.rotation < -360 then
            	crate.rotation = 0 
            	return crate.rotation
            else 
            	return crate.rotation
    		end
    	elseif ( n == 2 ) then
            if crate2.rotation > 360 or crate2.rotation < -360 then
            	crate2.rotation = 0
            	return crate2.rotation
            else
            	return crate2.rotation
            end
        end
    end

    local function updateCoordinates()
        crateXY.text = "[CRATE 1] \nx: " .. string.format( "%3.3f ", crate.x ) .. "\ny: " .. string.format( "%3.3f", crate.y) .. "\nr: " .. string.format( "%3.3f", getRotation(1) )  
        .. "\nw: " .. crate.width .. "\nh: " .. crate.height
        crate2XY.text = "[CRATE 2] \nx: " .. string.format( "%3.3f", crate2.x) .. "\ny: " .. string.format( "%3.3f", crate2.y) ..   "\nr: " .. string.format( "%3.3f", getRotation(2) )  .. "\nisFixed: " .. tostring(fixedRotation) 
        crateWeight.text = "" .. crate.width .. "kg"
        crateWeight.x = crate.x 
        crateWeight.y = crate.y - 30
        crate2Weight.x = crate2.x
        crate2Weight.y = crate2.y - 30
        --crate2.rotation = 0
        --crate2.x = _W +50
        local gx, gy = physics.getGravity( )
        gravityText.text = "[G] (m/s²)" .. "\nx: " .. string.format( "%2.1f ", gx ) .. "\ny: " .. string.format( "%2.1f ", gy )

    end
    Runtime:addEventListener( "enterFrame", updateCoordinates )

function dragBody( event, params )
    local body = event.target
    local phase = event.phase
    local stage = display.getCurrentStage()
    if "began" == phase then
        stage:setFocus( body, event.id )
        body.isFocus = true
        if params and params.center then
            body.tempJoint = physics.newJoint( "touch", body, body.x, body.y )
        else
            body.tempJoint = physics.newJoint( "touch", body, event.x, event.y )
        end
        if params then
            local maxForce, frequency, dampingRatio
            if params.maxForce then
                body.tempJoint.maxForce = params.maxForce
            end
            if params.frequency then
                body.tempJoint.frequency = params.frequency
            end
            if params.dampingRatio then
                body.tempJoint.dampingRatio = params.dampingRatio
            end
        end
    elseif body.isFocus then
        if "moved" == phase then
            body.tempJoint:setTarget( event.x, event.y )
        elseif "ended" == phase or "cancelled" == phase then
            stage:setFocus( body, nil )
            body.isFocus = false    
            body.tempJoint:removeSelf()
        end
    end
    return true
end
    crate:addEventListener( "touch", dragBody )
 
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase

    if event.phase == "will" then
        -- Called when the scene is on screen and is about to move off screen
        --
        -- INSERT code here to pause the scene
        -- e.g. stop timers, stop animation, unload sounds, etc.)
    elseif phase == "did" then
        -- Called when the scene is now off screen

		end
    end 
end


function scene:destroy( event )
    local sceneGroup = self.view

    -- Called prior to the removal of scene's "view" (sceneGroup)
    -- 
    -- INSERT code here to cleanup the scene
    -- e.g. remove display objects, remove touch listeners, save state, etc
end

---------------------------------------------------------------------------------

-- Listener setup
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )

---------------------------------------------------------------------------------

return scene
