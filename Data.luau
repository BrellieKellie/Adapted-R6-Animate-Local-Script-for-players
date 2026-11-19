-- Original Player (local) Animate script by Roblox's development team
-- Heavily reworked by @LunixHenry2040 
-- August 2026

local Data = {}


---------------------------------- Animation Libraries

--[[ IMPORTANT: Animation table for the new animate script

	When referencing the AnimLibrary, the glossary goes as follows:
	
		name: the name of the animation as it appears in the library. Used as a key in the library
		idx: the index of the animation in the
	
		fileList: the sub-library which is extracted when indexing with name. The fileList contains the animId and weight, as well as other properties
	:) 
]]

Data.AnimLibrary = { 

	------------------------------------------- Movement
	idle = 	{	
		{ id = "http://www.roblox.com/asset/?id=134124586963110"--[[180435571"]], weight = 9 },
		{ id = "http://www.roblox.com/asset/?id=180435792", weight = 1 }
	},
	sneak = 	{ 	
		{ id = "http://www.roblox.com/asset/?id=82024088516638", weight = 10 } 
	}, 
	prone = 	{ 	
		{ id = "http://www.roblox.com/asset/?id=122006114649909", weight = 10 } 
	}, 
	walk = 	{ 	
		{ id = "http://www.roblox.com/asset/?id=98790009949082", weight = 10 } 
	}, 
	run = 	{
		{ id = "http://www.roblox.com/asset/?id=82324728610517", weight = 10 } 
	}, 
	jump = 	{
		{ id = "http://www.roblox.com/asset/?id=125750702", weight = 10 } 
	}, 
	fall = 	{
		{ id = "http://www.roblox.com/asset/?id=180436148", weight = 10 } 
	}, 
	climb = {
		{ id = "http://www.roblox.com/asset/?id=82647445171081", weight = 10 } 
	}, 
	sit = 	{
		{ id = "http://www.roblox.com/asset/?id=178130996", weight = 10 } 
	},	
	platformstand = 	{
		{ id = "http://www.roblox.com/asset/?id=139975759048908", weight = 10 } 
	},	


	------------------------------------------- Emotes

	-- Non-dances
	wave = {
		{ id = "http://www.roblox.com/asset/?id=128777973", weight = 10, soundid = "http://www.roblox.com/asset/?id=139945781730068", soundstartpos = 0},
	},
	point = {
		{ id = "http://www.roblox.com/asset/?id=128853357", weight = 10 } 
	},
	laugh = {
		{ id = "http://www.roblox.com/asset/?id=129423131", weight = 10, soundid = "http://www.roblox.com/asset/?id=133017003825496", soundstartpos = 0}, 
	},
	cheer = {
		{ id = "http://www.roblox.com/asset/?id=129423030", weight = 10, soundid = "http://www.roblox.com/asset/?id=79020702281821", soundstartpos = 0 }, 
	},
	sitdown = {
		{ id = "http://www.roblox.com/asset/?id=133258115169126", weight = 10 },
	},
	afk = {
		{ id = "http://www.roblox.com/asset/?id=89907322922808", weight = 10, soundid = "http://www.roblox.com/asset/?id=6874092168", soundstartpos = 0},
	},
	whoawhoawhoaholdon = {
		{ id = "http://www.roblox.com/asset/?id=95869039103320", weight = 10, soundid = "http://www.roblox.com/asset/?id=3218541059", soundstartpos = 0},
	},
	spin = {
		{ id = "http://www.roblox.com/asset/?id=98175076109493", weight = 10, soundid = "http://www.roblox.com/asset/?id=9128579655", soundstartpos = 0},
	},
	helicopter = {
		{ id = "http://www.roblox.com/asset/?id=140563255158605", weight = 10, soundid = "http://www.roblox.com/asset/?id=126966962086051", soundstartpos = 0},
	},

	-- Dances
	dance1 = {
		{ id = "http://www.roblox.com/asset/?id=182435998", weight = 10 }, 
		{ id = "http://www.roblox.com/asset/?id=182491037", weight = 10 }, 
		{ id = "http://www.roblox.com/asset/?id=182491065", weight = 10 }, 
	},
	dance2 = {
		{ id = "http://www.roblox.com/asset/?id=182436842", weight = 10 }, 
		{ id = "http://www.roblox.com/asset/?id=182491248", weight = 10 }, 
		{ id = "http://www.roblox.com/asset/?id=182491277", weight = 10 }, 
	},
	dance3 = {
		{ id = "http://www.roblox.com/asset/?id=182436935", weight = 10 }, 
		{ id = "http://www.roblox.com/asset/?id=182491368", weight = 10 }, 
		{ id = "http://www.roblox.com/asset/?id=182491423", weight = 10 }, 
	},
	fresh = {
		{ id = "http://www.roblox.com/asset/?id=93958536632733", weight = 10, soundid = "http://www.roblox.com/asset/?id=140073352616820", soundstartpos = 1.6},
	},
	defaultdance = {
		{ id = "http://www.roblox.com/asset/?id=104128895138607", weight = 100, soundid = "http://www.roblox.com/asset/?id=77552319501916", soundstartpos = 21.5},
	},
	aerostep = {
		{ id = "http://www.roblox.com/asset/?id=87172540538495", weight = 10, soundid = "http://www.roblox.com/asset/?id=9044545570", soundstartpos = 19},
	},
	cleangroove = {
		{ id = "http://www.roblox.com/asset/?id=124483764535024", weight = 10, soundid = "http://www.roblox.com/asset/?id=92774322259700", soundstartpos = 0},
	},
	toprock = {
		{ id = "http://www.roblox.com/asset/?id=114058922483544", weight = 10 , soundid = "http://www.roblox.com/asset/?id=129139515441074", soundstartpos = 8},
	},
	electroshuffle = {
		{ id = "http://www.roblox.com/asset/?id=112029395639554", weight = 10 , soundid = "http://www.roblox.com/asset/?id=5410081112", soundstartpos = 114.8},
	},
	monstermash = {
		{ id = "http://www.roblox.com/asset/?id=94654990662867", weight = 10, soundid = "http://www.roblox.com/asset/?id=35930009", soundstartpos = 0},
	},
	catdance = {
		{ id = "http://www.roblox.com/asset/?id=124379051648577", weight = 10, soundid = "http://www.roblox.com/asset/?id=98183029921262", soundstartpos = 0},
	},
	groovin = {
		{ id = "http://www.roblox.com/asset/?id=132528825203594", weight = 10, soundid = "http://www.roblox.com/asset/?id=124698937788234", soundstartpos = 0},
	},
	moving = {
		{ id = "http://www.roblox.com/asset/?id=97223823498874", weight = 10, soundid = "http://www.roblox.com/asset/?id=1836798379", soundstartpos = 15.85},
	},
	breakdown = {
		{ id = "http://www.roblox.com/asset/?id=110947905956821", weight = 10, soundid = "http://www.roblox.com/asset/?id=124698937788234", soundstartpos = 0},
	},
	dr33mf33t = {
		{ id = "http://www.roblox.com/asset/?id=72037276420807", weight = 10, soundid = "http://www.roblox.com/asset/?id=101048309929837", soundstartpos = 0},
	},
	lucio = {
		{ id = "http://www.roblox.com/asset/?id=98465180359401", weight = 10, soundid = "http://www.roblox.com/asset/?id=97219704009826", soundstartpos = 0},
	},
	destiny = {
		{ id = "http://www.roblox.com/asset/?id=140420431027080", weight = 10 , soundid = "http://www.roblox.com/asset/?id=93783795673603", soundstartpos = 0},
	},
	flydance = {
		{ id = "http://www.roblox.com/asset/?id=121994454083208", weight = 10, soundid = "http://www.roblox.com/asset/?id=1842822168", soundstartpos = 32.35},
	},
	lowcortisol = {
		{ id = "http://www.roblox.com/asset/?id=119556629684805", weight = 10, soundid = "http://www.roblox.com/asset/?id=110919391228823", soundstartpos = 31.5 }
	},
}

-- Existance in this list signifies that it is an emote, the value indicates if it is a looping emote
Data.Emotes = { 
	NonDances = {
		-- Non-dances
		wave = false,
		point = false,
		laugh = false,
		cheer = false,
		sitdown = true,
		afk = true,
		whoawhoawhoaholdon = true,
		spin = true,
		helicopter = true,
	},

	-- Dances
	Dances = {
		dance1 = true,
		dance2 = true,
		dance3 = true,  
		fresh = true,  
		defaultdance = true, 
		aerostep = true, 
		cleangroove = true, 
		toprock = true, 
		electroshuffle = true, 
		monstermash = true, 
		catdance = true, 
		groovin = true, 
		moving = true, 
		breakdown = true,  
		dr33mf33t = true, 
		lucio = true,  
		destiny = true, 
		flydance = true, 
		lowcortisol = true, 
	}
}

Data.EmotesTables = { 
	NonDances = {
		-- Non-dances
		"wave",
		"point",
		"laugh",
		"cheer",
		"sitdown",
		"afk",
		"whoawhoawhoaholdon",
		"spin",
		"helicopter",
	},

	-- Dances
	Dances = {
		"dance1",
		"dance2",
		"dance3",  
		"fresh",  
		"defaultdance", 
		"aerostep", 
		"cleangroove", 
		"toprock", 
		"electroshuffle", 
		"monstermash", 
		"catdance", 
		"groovin", 
		"moving", 
		"breakdown",  
		"dr33mf33t", 
		"lucio",  
		"destiny", 
		"flydance", 
		"lowcortisol", 
	}
}



---------------------------------- Other Data
Data.Settings = {
	EmoteTransitionTime = 0.5,
	FallTransitionTime = 0.3,

	JumpAnimDuration = 0.3,
	JumpMaxLimbVelocity = 0.75,
}


return Data
