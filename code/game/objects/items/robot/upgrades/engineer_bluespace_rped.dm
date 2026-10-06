/obj/item/borg/upgrade/bs_rped
	name = "engineering cyborg bluespace RPED"
	desc = "A bluespace rapid part exchange device for the engineering cyborg."
	icon_state = "module_engineer"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/engineering, /obj/item/robot_model/syndicate/saboteur, /obj/item/robot_model/science)
	model_flags = BORG_MODEL_ENGINEERING

/obj/item/borg/upgrade/bs_rped/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return

	var/obj/item/storage/part_replacer/cyborg/rped = locate() in borg.model.usable_modules
	if(isnull(rped))
		to_chat(user, span_warning("This cyborg doesn't have a rapid part exchange device to upgrade!"))
		return FALSE

	install_items(borg, user, list(/obj/item/storage/part_replacer/bluespace))
	var/obj/item/storage/part_replacer/bluespace/brped = locate() in borg.model.usable_modules
	var/move_location = borg.drop_location()
	brped.atom_storage.silent_for_user = TRUE
	for(var/obj/item in rped)
		if(!brped.atom_storage.attempt_insert(item, borg, TRUE))
			item.forceMove(move_location)
	brped.atom_storage.silent_for_user = initial(brped.atom_storage.silent_for_user)
	remove_items(borg, user, list(/obj/item/storage/part_replacer/cyborg))
	return TRUE

/obj/item/borg/upgrade/bs_rped/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return

	var/obj/item/storage/part_replacer/bluespace/brped = locate() in borg.model.usable_modules
	if(isnull(brped))
		return FALSE

	install_items(borg, user, list(/obj/item/storage/part_replacer/cyborg))
	var/obj/item/storage/part_replacer/cyborg/rped = locate() in borg.model.usable_modules
	var/move_location = borg.drop_location()
	rped.atom_storage.silent_for_user = TRUE
	for(var/obj/item in brped)
		if(!rped.atom_storage.attempt_insert(item, borg, TRUE))
			item.forceMove(move_location)
	rped.atom_storage.silent_for_user = initial(rped.atom_storage.silent_for_user)
	remove_items(borg, user, list(/obj/item/storage/part_replacer/bluespace))
	return TRUE
