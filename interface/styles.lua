local NeP = NeP
NeP.Interface = {}

local DiesalTools = _G.LibStub("DiesalTools-1.0")
local DiesalStyle = _G.LibStub("DiesalStyle-1.0")

local Colors = DiesalStyle.Colors
local HSL = DiesalTools.HSL

NeP.Interface.statusBarStylesheet = {
  ['frame-texture'] = {
    type		= 'texture',
    layer		= 'BORDER',
    gradient	= 'VERTICAL',
    color		= '000000',
    alpha 		= 0.7,
    alphaEnd	= 0.1,
    offset		= 0,
  }
}

NeP.Interface.sectionStylesheet = {
    ["button-background"] = {
        type = "texture",
        layer = "BACKGROUND",
        gradient = {"VERTICAL", Colors.UI_400_GR[1], Colors.UI_400_GR[2]},
        alpha = .95,
        position = {0, 0, -1, 0}
    },
    ["button-outline"] = {
        type = "outline",
        layer = "BACKGROUND",
        color = "000000",
        position = {1, 1, 0, 1}
    },
    ["button-inline"] = {
        type = "outline",
        layer = "ARTWORK",
        gradient = {"VERTICAL", "ffffff", "ffffff"},
        alpha = {.03, .02},
        position = {0, 0, -1, 0}
    },
    ["button-hover"] = {
        type = "texture",
        layer = "HIGHLIGHT",
        color = "ffffff",
        alpha = .1
    },
    ["button-leftExpandIcon"] = {
        type = "texture",
        position = {0, nil, -1, nil},
        height = 16,
        width = 16,
        image = {"DiesalGUIcons", {3, 6, 16, 256, 128}, HSL(Colors.UI_Hue, Colors.UI_Saturation, .65)},
        alpha = 1
    },
    ["button-leftCollapseIcon"] = {
        type = "texture",
        position = {0, nil, -1, nil},
        height = 16,
        width = 16,
        image = {"DiesalGUIcons", {4, 6, 16, 256, 128}, HSL(Colors.UI_Hue, Colors.UI_Saturation, .65)},
        alpha = 1
    },
    ["content-background"] = {
        type = "texture",
        layer = "BACKGROUND",
        color = Colors.UI_300,
        alpha = .95,
        position = {0, 0, -1, 0}
    },
    ["content-topShadow"] = {
        type = "texture",
        layer = "ARTWORK",
        gradient = {"VERTICAL", "000000", "000000"},
        alpha = {.05, 0},
        position = {0, 0, -1, nil},
        height = 4
    },
    ["content-bottomShadow"] = {
        type = "texture",
        layer = "ARTWORK",
        gradient = {"VERTICAL", "000000", "000000"},
        alpha = {0, .05},
        position = {0, 0, nil, 0},
        height = 4
    },
    ["content-inline"] = {
        type = "outline",
        layer = "ARTWORK",
        color = "ffffff",
        alpha = .02,
        position = {0, 0, -1, 0}
    },
    ["text-Font"] = {
        type = "font",
        color = Colors.UI_F450
    }
}

NeP.Interface.buttonStyleSheet = {
	['frame-color'] = {
		type			= 'texture',
		layer			= 'BACKGROUND',
		color			= '2f353b',
		offset		= 0,
	},
	['frame-highlight'] = {
		type			= 'texture',
		layer			= 'BORDER',
		gradient	= 'VERTICAL',
		color			= 'FFFFFF',
		alpha 		= 0,
		alphaEnd	= .1,
		offset		= -1,
	},
	['frame-outline'] = {
		type			= 'outline',
		layer			= 'BORDER',
		color			= '000000',
		offset		= 0,
	},
	['frame-inline'] = {
		type			= 'outline',
		layer			= 'BORDER',
		gradient	= 'VERTICAL',
		color			= 'ffffff',
		alpha 		= .02,
		alphaEnd	= .09,
		offset		= -1,
	},
	['frame-hover'] = {
		type			= 'texture',
		layer			= 'HIGHLIGHT',
		color			= 'ffffff',
		alpha			= .1,
		offset		= 0,
	},
	['text-color'] = {
		type			= 'Font',
		color			= 'b8c2cc',
	},
}

NeP.Interface.createButtonStyle = {
	type			= 'texture',
	texFile		= 'DiesalGUIcons',
	texCoord		= {1,6,16,256,128},
	alpha 		= .7,
	offset		= {-2,nil,-2,nil},
	width			= 16,
	height		= 16,
}

NeP.Interface.deleteButtonStyle = {
	type			= 'texture',
	texFile		='DiesalGUIcons',
	texCoord		= {2,6,16,256,128},
	alpha 		= .7,
	offset		= {-2,nil,-2,nil},
	width			= 16,
	height		= 16,
}
