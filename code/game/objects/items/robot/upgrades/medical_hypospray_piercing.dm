/obj/item/borg/upgrade/piercing_hypospray
	name = "cyborg piercing hypospray"
	desc = "An upgrade to a cyborg's hypospray, allowing it to \
		pierce armor and thick material."
	icon_state = "module_medical"

/obj/item/borg/upgrade/piercing_hypospray/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	var/found_hypo = FALSE
	for(var/obj/item/reagent_containers/borghypo/hypo in borg.model.usable_modules)
		hypo.bypass_protection = TRUE
		found_hypo = TRUE
	if(!found_hypo)
		to_chat(user, span_warning("There are no installed hypospray modules to upgrade with piercing!")) // Check to see if any hyposprays were upgraded.
		return FALSE
	// If we are actually going to install the upgrade due to the presence of compatible modules, make sure their emagged counterparts get upgraded too.
	for(var/obj/item/reagent_containers/borghypo/hypo in borg.model.emagged_modules)
		hypo.bypass_protection = TRUE

/obj/item/borg/upgrade/piercing_hypospray/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	for(var/obj/item/reagent_containers/borghypo/hypo in borg.model.usable_modules)
		hypo.bypass_protection = initial(hypo.bypass_protection)
	for(var/obj/item/reagent_containers/borghypo/hypo in borg.model.emagged_modules)
		hypo.bypass_protection = initial(hypo.bypass_protection)
