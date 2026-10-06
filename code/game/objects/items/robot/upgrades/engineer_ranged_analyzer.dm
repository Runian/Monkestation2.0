/obj/item/borg/upgrade/ranged_analyzer
	name = "engineering ranged analyzer upgrade"
	desc = "An upgrade that improves the standard built-in gas analyzer's range."
	icon_state = "module_engineer"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/engineering, /obj/item/robot_model/syndicate/saboteur) // Engineering-exclusive. Do not give this to science cyborgs.
	model_flags = BORG_MODEL_ENGINEERING

/obj/item/borg/upgrade/ranged_analyzer/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return FALSE
	for(var/obj/item/analyzer/gas_analyzer in borg.model.usable_modules)
		gas_analyzer.name = /obj/item/analyzer/ranged::name
		gas_analyzer.desc = /obj/item/analyzer/ranged::desc
		gas_analyzer.icon_state = /obj/item/analyzer/ranged::icon_state
		gas_analyzer.ranged_scan_distance = /obj/item/analyzer/ranged::ranged_scan_distance
		gas_analyzer.update_appearance()

/obj/item/borg/upgrade/ranged_analyzer/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return FALSE
	for(var/obj/item/analyzer/gas_analyzer in borg.model.usable_modules)
		gas_analyzer.name = initial(gas_analyzer.name)
		gas_analyzer.desc = initial(gas_analyzer.desc)
		gas_analyzer.icon_state = initial(gas_analyzer.icon_state)
		gas_analyzer.ranged_scan_distance = initial(gas_analyzer.ranged_scan_distance)
		gas_analyzer.update_appearance()
