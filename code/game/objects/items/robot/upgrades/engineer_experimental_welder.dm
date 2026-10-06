/obj/item/borg/upgrade/experimental_weldingtool
	name = "experimental welder upgrade"
	desc = "An upgrade to fit the self-replenishing tank of an experimental welding tool to a cyborg."
	icon_state = "module_engineer"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/engineering, /obj/item/robot_model/syndicate/saboteur, /obj/item/robot_model/science)
	model_flags = BORG_MODEL_ENGINEERING

/obj/item/borg/upgrade/experimental_weldingtool/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	for(var/obj/item/weldingtool/largetank/cyborg/tool in borg.model.usable_modules)
		tool.refuel = TRUE
		tool.can_off_process = TRUE
		if(!tool.welding)
			START_PROCESSING(SSobj, tool)

/obj/item/borg/upgrade/experimental_weldingtool/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	for(var/obj/item/weldingtool/largetank/cyborg/tool in borg.model.usable_modules)
		tool.refuel = initial(tool.refuel)
		tool.can_off_process = initial(tool.can_off_process) // It'll stop processing on its own.
