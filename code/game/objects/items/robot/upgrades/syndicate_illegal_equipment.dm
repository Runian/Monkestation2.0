/obj/item/borg/upgrade/syndicate
	name = "illegal equipment module"
	desc = "Unlocks the hidden, deadlier functions of a cyborg."
	icon_state = "module_illegal"
	require_model = TRUE

/obj/item/borg/upgrade/syndicate/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	if(borg.emagged)
		return FALSE
	borg.SetEmagged(TRUE)
	borg.logevent("WARN: hardware installed with missing security certificate!") // A bit of fluff to hint it was an illegal tech item.
	borg.logevent("WARN: root privleges granted to PID [num2hex(rand(1,65535), -1)][num2hex(rand(1,65535), -1)].") // Random eight digit hex value. Two are used because rand(1, 4294967295) throws an error.
	return TRUE

/obj/item/borg/upgrade/syndicate/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	borg.SetEmagged(FALSE)
