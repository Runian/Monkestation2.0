/obj/item/borg/upgrade/better_clamp
	name = "improved integrated hydraulic clamp"
	desc = "An improved hydraulic clamp that trades its storage quantity to allow for bigger packages to be picked up instead!"
	icon_state = "module_cargo"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/cargo)
	model_flags = BORG_MODEL_CARGO
	items_to_add = list(/obj/item/borg/hydraulic_clamp/better)
