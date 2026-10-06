/obj/item/borg/upgrade/gps
	name = "cyborg global positioning system upgrade"
	desc = "An upgrade kit for all cyborgs to connect them to the GPS network."
	icon_state = "module_general"
	require_model = TRUE
	items_to_add = list(/obj/item/gps/cyborg)

/obj/item/borg/upgrade/gps/action(mob/living/silicon/robot/borg, user = usr)
	for(var/obj/item/gps/cyborg/GPS in borg.model.usable_modules) //mining borgs start with a GPS
		to_chat(user, span_warning("This unit already has a GPS installed!"))
		return FALSE
	return ..()
