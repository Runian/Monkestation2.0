
/obj/item/borg/upgrade/selfrepair
	name = "self-repair module"
	desc = "This module will repair the cyborg over time."
	icon_state = "module_general"
	require_model = TRUE
	/// The amount of burn and brute damage to be healed.
	var/repair_amount = 1
	/// The amount of deciseconds between repairs.
	var/repair_cooldown = 4 SECONDS
	/// The energy cost of the repair.
	var/energy_cost = 0.01 * STANDARD_CELL_CHARGE
	/// Is self-repair active?
	var/on = FALSE
	/// The action used to toggle self-repair.
	var/datum/action/toggle_action
	/// The cooldown between repairs.
	COOLDOWN_DECLARE(next_repair)

/obj/item/borg/upgrade/selfrepair/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	icon_state = "selfrepair_off"
	toggle_action = new /datum/action/item_action/toggle(src)
	toggle_action.Grant(borg)

/obj/item/borg/upgrade/selfrepair/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	toggle_action.Remove(borg)
	QDEL_NULL(toggle_action)
	deactivate_sr()

/obj/item/borg/upgrade/selfrepair/ui_action_click()
	if(on)
		to_chat(toggle_action.owner, span_notice("You deactivate the self-repair module."))
		deactivate_sr()
	else
		to_chat(toggle_action.owner, span_notice("You activate the self-repair module."))
		activate_sr()

/obj/item/borg/upgrade/selfrepair/update_icon_state()
	if(toggle_action)
		icon_state = "selfrepair_[on ? "on" : "off"]"
	else
		icon_state = "cyborg_upgrade5"
	return ..()

/obj/item/borg/upgrade/selfrepair/proc/activate_sr()
	START_PROCESSING(SSobj, src)
	on = TRUE
	update_appearance()

/obj/item/borg/upgrade/selfrepair/proc/deactivate_sr()
	STOP_PROCESSING(SSobj, src)
	on = FALSE
	update_appearance()

/obj/item/borg/upgrade/selfrepair/process()
	if(!COOLDOWN_FINISHED(src, next_repair))
		return
	if(!iscyborg(toggle_action.owner))
		return
	var/mob/living/silicon/robot/borg = toggle_action.owner
	if(!istype(borg) || borg.stat == DEAD || !on)
		deactivate_sr()
		return
	if(!borg.cell)
		to_chat(borg, span_alert("Self-repair module deactivated. Please insert power cell."))
		deactivate_sr()
		return
	if(borg.cell.charge < energy_cost * 2)
		to_chat(borg, span_alert("Self-repair module deactivated. Please recharge."))
		deactivate_sr()
		return
	if(borg.health < borg.maxHealth)
		if(borg.health < 0)
			repair_amount = 2.5
			energy_cost = 0.03 * STANDARD_CELL_CHARGE
		else
			repair_amount = 1
			energy_cost = 0.01 * STANDARD_CELL_CHARGE
		borg.adjustBruteLoss(-repair_amount)
		borg.adjustFireLoss(-repair_amount)
		borg.updatehealth()
		borg.cell.use(energy_cost)
	else
		borg.cell.use(0.005 * STANDARD_CELL_CHARGE)
	COOLDOWN_START(src, next_repair, repair_cooldown)
	if(!TIMER_COOLDOWN_FINISHED(src, COOLDOWN_BORG_SELF_REPAIR))
		return
	TIMER_COOLDOWN_START(src, COOLDOWN_BORG_SELF_REPAIR, 200 SECONDS)
	var/msgmode = "standby"
	if(borg.health < 0)
		msgmode = "critical"
	else if(borg.health < borg.maxHealth)
		msgmode = "normal"
	to_chat(borg, span_notice("Self-repair is active in [span_boldnotice("[msgmode]")] mode."))
