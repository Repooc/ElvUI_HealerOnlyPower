local E, L, P, V, G = unpack(ElvUI)
local EP = E.Libs.EP
local UF = E.UnitFrames
local AddOnName, Engine = ...

local module = E:NewModule(AddOnName, 'AceHook-3.0', 'AceEvent-3.0')
module.Version = GetAddOnMetadata(AddOnName, 'Version')
module.Configs = {}

function module:Print(...)
	(E.db and _G[E.db.general.messageRedirect] or _G.DEFAULT_CHAT_FRAME):AddMessage(strjoin('', E.media.hexvaluecolor or '|cff00b3ff', 'Healer Only Power:|r ', ...))
end

local function GetOptions()
	for _, func in pairs(module.Configs) do
		func()
	end
end

local function shouldDisplayBar(frame)
	if not frame then return end

	local unitframeType = frame.unitframeType
	if not unitframeType then return end
	local hopDB = E.db.hop

	local unit = hopDB.unitframe[unitframeType]
	if not unit then return end

	if not unit.healerOnly then return end

	local role = UnitGroupRolesAssigned(frame.unit)
	if role == 'HEALER' then
		return true
	end

	if role ~= 'TANK' then return end
	local _, class = UnitClass(frame.unit)

	if (class == 'DEATHKNIGHT' and unit.monitorBloodDK) or (class == 'MONK' and unit.monitorBrewMonk) then
		return true
	end

	return
end

function module:UpdateAllFrames(group)
	if InCombatLockdown() then
		module.NeedsUpdating = true
		module:RegisterEvent('PLAYER_REGEN_ENABLED')
		return	
	end

	if group and group ~= 'All' then
		UF:CreateAndUpdateHeaderGroup(group)
	else
		UF:CreateAndUpdateHeaderGroup('party')

		for i = 1, 3 do
			UF:CreateAndUpdateHeaderGroup('raid'..i)
		end	
	end
end

function module:PLAYER_REGEN_ENABLED()
	if module.NeedsUpdating then
		module:UpdateAllFrames()
		module.NeedsUpdating = nil	
	end

	module:UnregisterEvent('PLAYER_REGEN_ENABLED')
end

function module:Update_Frames(frame, db)
	if not (frame or frame.db or frame:IsShown() or E.db.hop.enable or (frame.unitframeType and E.db.hop.unitframe[frame.unitframeType].healerOnly)) then return end
	if not db.enable or db.power.enable or frame.isChild then return end

	if frame.isForced then
		if random(1, 3) ~= 1 then
			return
		end
	elseif not shouldDisplayBar(frame) then
		return
	end

	frame.USE_POWERBAR = true
	frame.POWERBAR_DETACHED = false
	frame.USE_INSET_POWERBAR = not frame.POWERBAR_DETACHED and db.power.width == 'inset' and frame.USE_POWERBAR
	frame.USE_MINI_POWERBAR = (not frame.POWERBAR_DETACHED and db.power.width == 'spaced' and frame.USE_POWERBAR)
	frame.USE_POWERBAR_OFFSET = (db.power.width == 'offset' and db.power.offset ~= 0) and frame.USE_POWERBAR and not frame.POWERBAR_DETACHED
	frame.POWERBAR_OFFSET = frame.USE_POWERBAR_OFFSET and db.power.offset or 0
	frame.POWERBAR_HEIGHT = not frame.USE_POWERBAR and 0 or db.power.height
	frame.POWERBAR_WIDTH = frame.USE_MINI_POWERBAR and (frame.UNIT_WIDTH - (UF.BORDER*2))*0.5 or (frame.POWERBAR_DETACHED and db.power.detachedWidth or (frame.UNIT_WIDTH - ((UF.BORDER+UF.SPACING)*2)))
	frame.CLASSBAR_WIDTH = frame.UNIT_WIDTH - frame.PORTRAIT_WIDTH - (frame.ORIENTATION == 'MIDDLE' and (frame.POWERBAR_OFFSET*2) or frame.POWERBAR_OFFSET)
	frame.CLASSBAR_YOFFSET = (not frame.USE_CLASSBAR or not frame.CLASSBAR_SHOWN or frame.CLASSBAR_DETACHED) and 0 or (frame.USE_MINI_CLASSBAR and (UF.SPACING+(frame.CLASSBAR_HEIGHT*0.5)) or (frame.CLASSBAR_HEIGHT - (UF.BORDER-UF.SPACING)))
	frame.USE_INFO_PANEL = not frame.USE_MINI_POWERBAR and not frame.USE_POWERBAR_OFFSET and db.infoPanel.enable
	frame.BOTTOM_OFFSET = UF:GetHealthBottomOffset(frame)

	UF:Configure_InfoPanel(frame)
	UF:Configure_HealthBar(frame)
	UF:Configure_Power(frame)

	frame:UpdateAllElements('ElvUI_UpdateAllElements')
end

function module:UpdateOptions(group)
	if not (UF.Initialized or E.private.unitframe.enable) then return end
	module.db = E.db.hop

	if module.db.enable then
		if not module:IsHooked(UF, 'Update_RaidFrames') then
			-- print('|cff00FF98HOP:|r Enabled')
			module:SecureHook(UF, 'Update_PartyFrames', module.Update_Frames)
			module:SecureHook(UF, 'Update_RaidFrames', module.Update_Frames)
			module:RegisterEvent('PLAYER_ROLES_ASSIGNED', module.UpdateAllFrames)
		end
	elseif not module.db.enable then
		if module:IsHooked(UF, 'Update_RaidFrames') then
			-- print('|cff00FF98HOP:|r Disabled')
			module:Unhook(UF, 'Update_PartyFrames')
			module:Unhook(UF, 'Update_RaidFrames')
			module:UnregisterEvent('PLAYER_ROLES_ASSIGNED')
		end
	end
end

function module:Initialize()
	EP:RegisterPlugin(AddOnName, GetOptions)
	if not UF.Initialized then return end
	
	module:UpdateOptions()
	hooksecurefunc(E, 'UpdateAll', module.UpdateOptions)
end

E.Libs.EP:HookInitialize(module, module.Initialize)
