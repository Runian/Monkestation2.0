/obj/item/borg/upgrade/uwu
	name = "cyborg UwU-speak \"upgrade\""
	desc = "As if existence as an artificial being wasn't torment enough for the unit OR the crew."
	icon_state = "module_general"

/obj/item/borg/upgrade/uwu/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	borg.AddComponentFrom(REF(src), /datum/component/fluffy_tongue)

/obj/item/borg/upgrade/uwu/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	borg.RemoveComponentSource(REF(src), /datum/component/fluffy_tongue)
