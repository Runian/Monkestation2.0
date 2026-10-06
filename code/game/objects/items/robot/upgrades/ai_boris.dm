/obj/item/borg/upgrade/ai
	name = "B.O.R.I.S. module"
	desc = "Bluespace Optimized Remote Intelligence Synchronization. An uplink device which takes the place of an MMI in cyborg endoskeletons, creating a robotic shell controlled by an AI."
	icon = 'icons/obj/module.dmi'
	icon_state = "boris"

/obj/item/borg/upgrade/ai/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	if(borg.key) // You cannot replace a player unless the key is completely removed.
		to_chat(user, span_warning("Intelligence patterns detected in this [borg.braintype]. Aborting."))
		return FALSE
	borg.make_shell(src)

/obj/item/borg/upgrade/ai/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!. || !borg.shell)
		return .
	borg.undeploy()
	borg.notify_ai(AI_NOTIFICATION_AI_SHELL)
