/obj/item/borg/upgrade/disablercooler
	name = "cyborg rapid disabler cooling module"
	desc = "Used to cool a mounted disabler, increasing the potential current in it and thus its recharge rate."
	icon_state = "module_security"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/security)
	model_flags = BORG_MODEL_SECURITY
	// We handle this in a custom way.
	allow_duplicates = TRUE
	/// The amount that the disabler's charge_delay was decreased. Used to ensure it is increased without issues if upgrade was removed.
	var/delay_difference = 0

/obj/item/borg/upgrade/disablercooler/action(mob/living/silicon/robot/borg, user)
	. = ..()
	if(!.)
		return
	var/obj/item/gun/energy/disabler/cyborg/disabler = locate() in borg.model.usable_modules
	if(isnull(disabler))
		to_chat(user, span_warning("There's no disabler in this unit!"))
		return FALSE
	if(disabler.charge_delay <= 2)
		to_chat(borg, span_warning("A cooling unit is already installed!"))
		to_chat(user, span_warning("There's no room for another cooling unit!"))
		return FALSE
	var/old_charge_delay = disabler.charge_delay
	disabler.charge_delay = max(2, disabler.charge_delay - 4)
	delay_difference = old_charge_delay - disabler.charge_delay

/obj/item/borg/upgrade/disablercooler/deactivate(mob/living/silicon/robot/borg, user)
	. = ..()
	if(!.)
		return
	var/obj/item/gun/energy/disabler/cyborg/disabler = locate() in borg.model.usable_modules
	if(isnull(disabler))
		return FALSE
	disabler.charge_delay = min(disabler.charge_delay + delay_difference, initial(disabler.charge_delay))
