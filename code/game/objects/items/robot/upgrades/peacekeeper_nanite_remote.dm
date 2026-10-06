/obj/item/borg/upgrade/nanite_remote
	name = "peacekeeper cyborg nanite remote"
	desc = "An upgrade to the Peacekeeper model, installing a nanite remote. \
			Allowing the cyborg to signal nanites in crew."
	icon_state = "module_peace"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/peacekeeper, /obj/item/robot_model/security, /obj/item/robot_model/science)
	model_flags = BORG_MODEL_PEACEKEEPER
	items_to_add = list(/obj/item/nanite_remote/cyborg)
