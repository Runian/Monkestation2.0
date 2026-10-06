/obj/item/borg/upgrade/breathingbag
	name = "breathing bag upgrade"
	desc = "An upgrade allowing the medical module to assist a patient with breathing."
	icon_state = "module_medical"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical, /obj/item/robot_model/syndicate/medical)
	model_flags = BORG_MODEL_MEDICAL
	items_to_add = list(/obj/item/breathing_bag)
