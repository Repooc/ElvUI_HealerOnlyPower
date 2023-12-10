local E, L, _, P, _ = unpack(ElvUI)
local UF = E.UnitFrames
local ACH = E.Libs.ACH
local RRP = LibStub('RepoocReforged-1.0'):LoadMainCategory()
local AddOnName = ...
local module = E:GetModule(AddOnName)

--* Move to locale file is/when I get around to adding locales
L["CREDITS"] = "Just a want to give credit to The following people for helping me maintain this addon with testing, coding, textures and people who also have helped me through donations. Please note for donation acknowledgments, only the names of people who messaged me or noted in the donation will be listed as you ask (within reason of course)."

local CODERS = {
	'WRMSRwasTaken (Github)',
}

local function SortList(a, b)
	return E:StripString(a) < E:StripString(b)
end

sort(CODERS, SortList)

local CODING_STRING = table.concat(CODERS, '|n')

local function GetOptionsTable_HealerOnlyPower(group)
    local config = ACH:Group('|cff00FF98Healer Only|r |cffA330C9Power|r', nil, 99, nil, function(info) return E.db.hop.unitframe[info[#info-3]][info[#info]] end, function(info, value) E.db.hop.unitframe[info[#info-3]][info[#info]] = value module:UpdateOptions(group) module:UpdateAllFrames(group) end, function(info) return not E.db.hop.enable end)
    config.inline = true

    config.args.healerOnly = ACH:Toggle(L["Healer Only"], nil, 1, nil, nil, nil, nil, nil, function(info) return E.db.unitframe.units[group].power.enable end)
    config.args.monitorBloodDK = ACH:Toggle(L["DK Tanks"], nil, 2, nil, nil, nil, nil, nil, function(info) return E.db.unitframe.units[group].power.enable or not E.db.hop.unitframe[group].healerOnly end)
    config.args.monitorBrewMonk = ACH:Toggle(L["Monk Tanks"], nil, 2, nil, nil, nil, nil, nil, function(info) return E.db.unitframe.units[group].power.enable or not E.db.hop.unitframe[group].healerOnly end)

	return config
end

local function configTable()
    --* Repooc Reforged Plugin section
    local rrp = E.Options.args.rrp
    if not rrp then print("Error Loading Repooc Reforged Plugin Library") return end

    -- if not rrp then
    --     rrp = ACH:Group('|cff00FF98Repooc Reforged|r |cffA330C9Plugins|r', nil, 6, nil, nil, nil, function() return not UF.Initialized end)
	--     E.Options.args.rrp = rrp
    -- end
 
    --* Healer Only Power Section
    local HealerOnlyPower = ACH:Group('|cff00FF98Healer Only|r |cffA330C9Power|r', nil, 6, 'tab', nil, nil, function() return not UF.Initialized end)
    rrp.args.hop = HealerOnlyPower
    HealerOnlyPower.args.enable = ACH:Toggle(L["Enable"], nil, 0, nil, nil, nil, function(info) return E.db.hop[info[#info]] end, function(info, value) E.db.hop[info[#info]] = value module:UpdateOptions() module:UpdateAllFrames() end)
    
    local Help = ACH:Group(L["Help"], nil, 99, nil, nil, nil, false)
	HealerOnlyPower.args.help = Help

	local Support = ACH:Group(L["Support"], nil, 1)
	Help.args.support = Support
	Support.inline = true
	Support.args.wago = ACH:Execute(L["Wago Page"], nil, 1, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://addons.wago.io/addons/elvui-healeronlypower') end, nil, nil, 140)
	Support.args.curse = ACH:Execute(L["Curseforge Page"], nil, 1, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://curseforge.com/wow/addons/elvui-healer-only-power') end, nil, nil, 140)
	Support.args.git = ACH:Execute(L["Ticket Tracker"], nil, 2, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://github.com/Repooc/ElvUI_HealerOnlyPower/issues') end, nil, nil, 140)
	Support.args.discord = ACH:Execute(L["Discord"], nil, 3, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://repoocreforged.dev/discord') end, nil, nil, 140)

	local Download = ACH:Group(L["Download"], nil, 2)
	Help.args.download = Download
	Download.inline = true
	Download.args.development = ACH:Execute(L["Development Version"], L["Link to the latest development version."], 1, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://github.com/Repooc/ElvUI_HealerOnlyPower/archive/refs/heads/main.zip') end, nil, nil, 140)

	local Credits = ACH:Group(L["Credits"], nil, 5)
	Help.args.credits = Credits
	Credits.inline = true
	Credits.args.string = ACH:Description(E:TextGradient(L["CREDITS"], 0.27,0.72,0.86, 0.51,0.36,0.80, 0.69,0.28,0.94, 0.94,0.28,0.63, 1.00,0.51,0.00, 0.27,0.96,0.43), 1, 'medium')

	local Coding = ACH:Group(L["Textures/Coding"], nil, 6)
	Help.args.coding = Coding
	Coding.inline = true
	Coding.args.string = ACH:Description(CODING_STRING, 1, 'medium')

    --* Modifications for ElvUI UnitFrame section
    local UnitFrames = E.Options.args.unitframe.args.groupUnits.args
    for _, group in next, {'party', 'raid1', 'raid2', 'raid3'} do
        UnitFrames[group].args.power.args.HealerOnlyPower = GetOptionsTable_HealerOnlyPower(group)
    end
end

tinsert(module.Configs, configTable)
