/obj/item/borg/upgrade/thrusters
	name = "ion thruster upgrade"
	desc = "An energy-operated thruster system for cyborgs."
	icon_state = "module_general"

/obj/item/borg/upgrade/thrusters/action(mob/living/silicon/robot/borg, user)
	. = ..()
	if(!.)
		return
	if(borg.ionpulse)
		to_chat(user, span_warning("This unit already has ion thrusters installed!"))
		return FALSE
	borg.ionpulse = TRUE
	borg.toggle_ionpulse() // Enabled by default.

/obj/item/borg/upgrade/thrusters/deactivate(mob/living/silicon/robot/borg, user)
	. = ..()
	if(!.)
		return .
	borg.ionpulse = FALSE
