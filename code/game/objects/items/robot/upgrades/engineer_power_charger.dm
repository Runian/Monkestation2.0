
/obj/item/borg/upgrade/charger
	name = "power connector"
	desc = "An energy probe that can charge batteries and energy-dependent weapons (using the cyborg battery, in both directions), as well as recharge the cyborg from all types of chargers, the effectiveness depends on the components of the machine"
	icon_state = "module_engineer"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/engineering)
	model_flags = BORG_MODEL_ENGINEERING
	items_to_add = list(/obj/item/borg/charger)
