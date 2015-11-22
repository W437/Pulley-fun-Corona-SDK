
local aspectRatio = display.pixelHeight / display.pixelWidth

application =
{

	content =
	{
      width = 1080,
      height = 1920,
      scale = "adaptive",
		fps = 60,
		
		--[[
		imageSuffix =
		{
			    ["@2x"] = 2,
		},
		--]]
	},

	--[[
	-- Push notifications
	notification =
	{
		iphone =
		{
			types =
			{
				"badge", "sound", "alert", "newsstand"
			}
		}
	},
	--]]    
}
