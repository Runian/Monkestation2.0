/obj/item/borg/upgrade/condiment_synthesizer
	name = "service cyborg condiment synthesiser"
	desc = "An upgrade for service model cyborgs that allows them to produce solid condiments."
	icon_state = "module_service"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/service)
	model_flags = BORG_MODEL_SERVICE
	items_to_add = list(/obj/item/reagent_containers/borghypo/condiment_synthesizer)
