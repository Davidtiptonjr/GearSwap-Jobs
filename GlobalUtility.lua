-------------------------------------------------------------------------------------------------------------------
-- General utility functions that can be used by any job files.  Outside the scope of what the main
-- include file deals with.
-------------------------------------------------------------------------------------------------------------------

local utility = {}

-------------------------------------------------------------------------------------------------------------------
-- Functions to set user-specified binds, generally on load and unload.
-- Kept separate from the main include so as to not get clobbered when the main is updated.
-------------------------------------------------------------------------------------------------------------------

-- Function to bind GearSwap binds when loading a GS script.
function utility.binds_on_load()
	windower.send_command('bind f9 gs c cycle OffenseMode')
	windower.send_command('bind ^f9 gs c cycle DefenseMode')
	windower.send_command('bind !f9 gs c cycle WeaponskillMode')
	windower.send_command('bind f10 gs c activate PhysicalDefense')
	windower.send_command('bind ^f10 gs c cycle PhysicalDefenseMode')
	windower.send_command('bind !f10 gs c toggle kiting')
	windower.send_command('bind f11 gs c activate MagicalDefense')
	windower.send_command('bind ^f11 gs c cycle CastingMode')
	windower.send_command('bind !f11 gs c set CastingMode Dire')
	windower.send_command('bind f12 gs c update user')
	windower.send_command('bind ^f12 gs c cycle IdleMode')
	windower.send_command('bind !f12 gs c reset defense')
end

-- Function to re-bind Spellcast binds when unloading GearSwap.
function utility.binds_on_unload()
	windower.send_command('bind f9 input /ma CombatMode Cycle(Offense)')
	windower.send_command('bind ^f9 input /ma CombatMode Cycle(Defense)')
	windower.send_command('bind !f9 input /ma CombatMode Cycle(WS)')
	windower.send_command('bind f10 input /ma PhysicalDefense .On')
	windower.send_command('bind ^f10 input /ma PhysicalDefense .Cycle')
	windower.send_command('bind !f10 input /ma CombatMode Toggle(Kite)')
	windower.send_command('bind f11 input /ma MagicalDefense .On')
	windower.send_command('bind ^f11 input /ma CycleCastingMode')
	windower.send_command('bind !f11 input /ma CastingMode Dire')
	windower.send_command('bind f12 input /ma Update .Manual')
	windower.send_command('bind ^f12 input /ma CycleIdleMode')
	windower.send_command('bind !f12 input /ma Reset .Defense')
end


-------------------------------------------------------------------------------------------------------------------
-- Utility functions for changing target types.
-------------------------------------------------------------------------------------------------------------------

function utility.auto_change_target(spell, action, spellMap)
	-- Do not modify target for spells where we get <lastst> or <me>.
	if spell.target.raw == ('<lastst>') or spell.target.raw == ('<me>') then
		return
	end
	
	-- init a new eventArgs
	local eventArgs = {handled = false, pcTargetMode = 'default', selectNPCTargets = false}

	-- Allow the job to do custom handling
	-- They can completely handle it, or set one of the secondary eventArgs vars to selectively
	-- override the default state vars.
	if job_auto_change_target then
		job_auto_change_target(spell, action, spellMap, eventArgs)
	end
	
	-- If the job handled it, we're done.
	if eventArgs.handled then
		return
	end
			

	local canUseOnPlayer = spell.validtarget.Self or spell.validtarget.Player or spell.validtarget.Party or spell.validtarget.Ally or spell.validtarget.NPC

	local newTarget = ''
	
	-- For spells that we can cast on players:
	if canUseOnPlayer then
		if eventArgs.pcTargetMode == 'stal' or state.PCTargetMode == 'stal' then
			-- Use <stal> if possible, otherwise fall back to <stpt>.
			if spell.validtarget.Ally then
				newTarget = '<stal>'
			elseif spell.validtarget.Party then
				newTarget = '<stpt>'
			end
		elseif eventArgs.pcTargetMode == 'stpt' or state.PCTargetMode == 'stpt' then
			-- Even ally-possible spells are limited to the current party.
			if spell.validtarget.Ally or spell.validtarget.Party then
				newTarget = '<stpt>'
			end
		elseif eventArgs.pcTargetMode == 'stpc' or state.PCTargetMode == 'stpc' then
			-- If it's anything other than a self-only spell, can change to <stpc>.
			if spell.validtarget.Player or spell.validtarget.Party or spell.validtarget.Ally or spell.validtarget.NPC then
				newTarget = '<stpc>'
			end
		end
	-- For spells that can be used on enemies:
	elseif spell.validtarget.Enemy then
		if eventArgs.selectNPCTargets or state.SelectNPCTargets then
			-- Note: this means macros should be written for <t>, and it will change to <stnpc>
			-- if the flag is set.  It won't change <stnpc> back to <t>.
			newTarget = '<stnpc>'
		end
	end
	
	-- If a new target was selected and is different from the original, call the change function.
	if newTarget ~= '' and newTarget ~= spell.target.raw then
		change_target(newTarget)
	end
end


-------------------------------------------------------------------------------------------------------------------
-- Other utility functions
-------------------------------------------------------------------------------------------------------------------

function utility.set_macro_page(set,book)
	if not tonumber(set) then error('Macro page: Set not a valid number ('..tostring(set)..')', 2) end

	if book then
		if not tonumber(book) then error('Macro page: Book not a valid number ('..tostring(book)..')', 2) end
		windower.send_command('input /macro book '..tostring(book)..';wait .1;input /macro set '..tostring(set))
	else
		windower.send_command('input /macro set '..tostring(set))
	end
end


return utility
