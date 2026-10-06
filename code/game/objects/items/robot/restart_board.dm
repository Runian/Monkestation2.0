// A reusable tool that can bring borgs back to life. They gotta be repaired first, though.
/obj/item/borg_restart_board
	name = "cyborg emergency reboot module"
	desc = "A reusable firmware reset tool that can force a reboot of a disabled-but-repaired cyborg, bringing it back online."
	icon = 'icons/mob/silicon/robot_items.dmi'
	icon_state = "cyborg_upgrade1"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/borg_restart_board/pre_attack(atom/target, mob/living/user, list/modifiers, list/attack_modifiers) //do stuff before attackby!
	if(!iscyborg(target))
		return ..()
	var/mob/living/silicon/robot/cyborg = target
	if(!cyborg.opened)
		to_chat(user, span_warning("You must access the cyborg's internals!"))
		return ..()
	if(cyborg.health < 0)
		to_chat(user, span_warning("You have to repair the cyborg before using this module!"))
		return ..()
	if(!(borg.stat & DEAD))
		to_chat(user, span_warning("This cyborg is already operational!"))
		return ..()

	if(cyborg.mind)
		cyborg.mind.grab_ghost()
		playsound(loc, 'sound/voice/liveagain.ogg', 75, TRUE)
	else
		playsound(loc, 'sound/machines/ping.ogg', 75, TRUE)

	cyborg.revive()
	cyborg.logevent("WARN -- System recovered from unexpected shutdown.")
	cyborg.logevent("System brought online.")
	return ..()
