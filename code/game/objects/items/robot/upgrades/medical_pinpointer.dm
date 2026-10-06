/obj/item/borg/upgrade/pinpointer
	name = "medical cyborg crew pinpointer"
	desc = "A crew pinpointer module for the medical cyborg. Permits remote access to the crew monitor."
	icon_state = "module_medical"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical, /obj/item/robot_model/syndicate/medical)
	model_flags = BORG_MODEL_MEDICAL
	items_to_add = list(/obj/item/pinpointer/crew)
	var/datum/action/crew_monitor

/obj/item/borg/upgrade/pinpointer/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	crew_monitor = new /datum/action/item_action/crew_monitor(src)
	crew_monitor.Grant(borg)

/obj/item/borg/upgrade/pinpointer/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	crew_monitor.Remove(borg)
	QDEL_NULL(crew_monitor)

/obj/item/borg/upgrade/pinpointer/ui_action_click()
	if(..())
		return
	var/mob/living/silicon/robot/borg = usr
	GLOB.crewmonitor.show(borg, borg)

/datum/action/item_action/crew_monitor
	name = "Interface With Crew Monitor"
	button_icon = 'icons/obj/device.dmi'
	button_icon_state = "scanner_med"
