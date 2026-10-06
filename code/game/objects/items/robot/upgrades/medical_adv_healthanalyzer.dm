/obj/item/borg/upgrade/adv_healthanalyzer
	name = "health analyzer upgrade"
	desc = "An updated sensor and driver kit for medical cyborgs. Allowing the cyborg unit to perform more in-depth analysis of patients."
	icon_state = "module_medical"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical, /obj/item/robot_model/syndicate/medical) // The fact that syndicate medical doesn't get advanced stock surprises me just as much as you.
	model_flags = BORG_MODEL_MEDICAL

/obj/item/borg/upgrade/adv_healthanalyzer/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	for(var/obj/item/healthanalyzer/cyborg/analyzer in borg.model.usable_modules)
		analyzer.works_from_distance = /obj/item/healthanalyzer/advanced::works_from_distance
		analyzer.advanced = /obj/item/healthanalyzer/advanced::advanced
		analyzer.give_wound_treatment_bonus = /obj/item/healthanalyzer/advanced::give_wound_treatment_bonus
		analyzer.name = /obj/item/healthanalyzer/advanced::name
		analyzer.desc = /obj/item/healthanalyzer/advanced::desc
		analyzer.icon_state = /obj/item/healthanalyzer/advanced::icon_state
		analyzer.update_appearance()

/obj/item/borg/upgrade/adv_healthanalyzer/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	for(var/obj/item/healthanalyzer/cyborg/analyzer in borg.model.usable_modules)
		analyzer.works_from_distance = initial(analyzer.works_from_distance)
		analyzer.advanced = initial(analyzer.advanced)
		analyzer.give_wound_treatment_bonus = initial(analyzer.give_wound_treatment_bonus)
		analyzer.name = initial(analyzer.name)
		analyzer.desc = initial(analyzer.desc)
		analyzer.icon_state = initial(analyzer.icon_state)
		analyzer.update_appearance()
