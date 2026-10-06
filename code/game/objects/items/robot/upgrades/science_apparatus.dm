
// This is a base item which should be inherited from.
/obj/item/borg/upgrade/science_apparatus_improvement
	name = "science apparatus upgrade"
	desc = "An upgrade for science cyborgs that enables them to hold and manipulate more items with their apparatus."
	icon_state = "module_science"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/science)
	model_flags = BORG_MODEL_SCIENCE
	var/list/storables_to_add = list()

/obj/item/borg/upgrade/science_apparatus_improvement/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	var/obj/item/borg/apparatus/circuit/science/apparatus = locate() in borg.model.usable_modules
	if(isnull(apparatus))
		to_chat(user, span_warning("This cyborg doesn't have an apparatus to upgrade!"))
		return FALSE
	if(!length(storables_to_add))
		to_chat(user, span_warning("This upgrade doesn't seem to do anything!"))
		return FALSE
	apparatus.whitelist_storables |= storables_to_add

/obj/item/borg/upgrade/science_apparatus_improvement/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	var/obj/item/borg/apparatus/circuit/science/apparatus = locate() in borg.model.usable_modules
	if(isnull(apparatus))
		return FALSE
	if(!length(storables_to_add))
		return FALSE
	apparatus.whitelist_storables -= storables_to_add

/obj/item/borg/upgrade/science_apparatus_improvement/robotics
	name = "science robotics upgrade"
	desc = "An upgrade for science cyborgs that enables them to hold and manipulate robotics-related items."
	storables_to_add = list(
		/obj/item/borg/upgrade,
		/obj/item/mmi,
		/obj/item/assembly/flash,
		/obj/item/bodypart/arm/left/robot,
		/obj/item/bodypart/arm/right/robot,
		/obj/item/bodypart/leg/left/robot,
		/obj/item/bodypart/leg/right/robot,
		/obj/item/bodypart/chest/robot,
		/obj/item/bodypart/head/robot
	)

/obj/item/borg/upgrade/science_apparatus_improvement/ordnance
	name = "science ordnance upgrade"
	desc = "An upgrade for science cyborgs that enables them to hold and manipulate ordnance-related items."
	items_to_add = list(
		/obj/item/pipe_dispenser
	)
	storables_to_add = list(
		/obj/item/tank/internals,
		/obj/item/transfer_valve
	)

/obj/item/borg/upgrade/science_apparatus_improvement/circuits
	name = "science circuits upgrade"
	desc = "An upgrade for science cyborgs that enables them to hold and manipulate circuits-related items."
	items_to_add = list(
		/obj/item/multitool/circuit
	)
	storables_to_add = list(
		/obj/item/circuit_component,
		/obj/item/shell,
		/obj/item/usb_cable,
		/obj/item/keyboard_shell,
		/obj/item/wiremod_scanner,
		/obj/item/integrated_circuit,
		/obj/item/mod/module/circuit,
	)

/obj/item/borg/upgrade/science_xenobiology
	name = "science xenobiology upgrade"
	desc = "An upgrade for science cyborgs that enables them to perform work in xenobiology."
	icon_state = "module_science"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/science)
	model_flags = BORG_MODEL_SCIENCE
	items_to_add = list(
		/obj/item/vacuum_pack,
		/obj/item/storage/bag/xeno,
		/obj/item/construction/plumbing/research
	)
