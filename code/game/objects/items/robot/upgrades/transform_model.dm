/obj/item/borg/upgrade/transform
	name = "borg model picker (Standard)"
	desc = "Allows you to to turn a cyborg into a standard cyborg."
	icon_state = "module_general"
	var/obj/item/robot_model/new_model = null

/obj/item/borg/upgrade/transform/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return
	if(!new_model)
		return FALSE
	borg.apply_model(new_model)
	borg.apply_skin(borg.model.default_skin)

/obj/item/borg/upgrade/transform/clown
	name = "borg model picker (Clown)"
	desc = "Allows you to turn a cyborg into a clown, honk."
	icon_state = "module_honk"
	new_model = /obj/item/robot_model/clown

/obj/item/borg/upgrade/transform/centcom
	name = "borg model picker (CentCom)"
	desc = "Allows you to to turn a cyborg into a CentCom cyborg."
	icon_state = "module_general"
	new_model = /obj/item/robot_model/centcom
