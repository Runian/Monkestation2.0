
// This is a base item which should be inherited from.
/obj/item/borg/upgrade/syringe
	name = "cyborg syringe upgrade"
	desc = "An upgrade that replaces the standard built-in syringe."
	icon_state = "module_medical"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical, /obj/item/robot_model/syndicate/medical)
	model_flags = BORG_MODEL_MEDICAL
	/// The typepath of the syringe to copy.
	var/obj/item/reagent_containers/syringe/upgraded_syringe_typepath = null

/obj/item/borg/upgrade/syringe/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return FALSE
	if(!upgraded_syringe_typepath)
		to_chat(user, span_warning("This upgrade doesn't seem to do anything."))
		return FALSE
	for(var/obj/item/borg/upgrade/syringe/other_syringe_upgrade in borg.upgrades)
		other_syringe_upgrade.forceMove(get_turf(borg))
	for(var/obj/item/reagent_containers/syringe/syringe_module in borg.model.usable_modules)
		upgrade_syringe(borg, syringe_module) // This is solely because we don't want to shuffle the item around in their inventory.
		syringe_module.update_appearance()

/obj/item/borg/upgrade/syringe/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return FALSE
	for(var/obj/item/reagent_containers/syringe/syringe_module in borg.model.usable_modules)
		downgrade_syringe(borg, syringe_module)
		syringe_module.update_appearance()

/// Upgrades the syringe to use most of the new syringe's values.
/obj/item/borg/upgrade/syringe/proc/upgrade_syringe(mob/living/silicon/robot/borg, obj/item/reagent_containers/syringe/syringe_to_upgrade)
	syringe_to_upgrade.name = initial(upgraded_syringe_typepath.name)
	syringe_to_upgrade.desc = initial(upgraded_syringe_typepath.desc)
	syringe_to_upgrade.base_icon_state = initial(upgraded_syringe_typepath.base_icon_state)
	var/obj/item/reagent_containers/syringe/upgraded_syringe = new upgraded_syringe_typepath()
	syringe_to_upgrade.possible_transfer_amounts = upgraded_syringe.possible_transfer_amounts.Copy() // Created only to get a list.
	qdel(upgraded_syringe)
	var/overflowing_reagents = syringe_to_upgrade.reagents.total_volume - initial(upgraded_syringe_typepath.volume)
	if(overflowing_reagents)
		var/datum/reagents/reagents_to_splash = new(overflowing_reagents)
		syringe_to_upgrade.reagents.trans_to(reagents_to_splash, reagents_to_splash.maximum_volume)
		var/turf/current_turf = borg.loc
		current_turf.add_liquid_from_reagents(reagents_to_splash)
	syringe_to_upgrade.amount_per_transfer_from_this = initial(upgraded_syringe_typepath.amount_per_transfer_from_this)
	syringe_to_upgrade.volume = initial(upgraded_syringe_typepath.volume)
	syringe_to_upgrade.reagents.maximum_volume = syringe_to_upgrade.volume
	syringe_to_upgrade.inject_flags = initial(upgraded_syringe_typepath.inject_flags)

/// Downgrades the syringe to its initial values.
/obj/item/borg/upgrade/syringe/proc/downgrade_syringe(mob/living/silicon/robot/borg, obj/item/reagent_containers/syringe/syringe_to_downgrade)
	syringe_to_downgrade.name = initial(syringe_to_downgrade.name)
	syringe_to_downgrade.desc = initial(syringe_to_downgrade.desc)
	syringe_to_downgrade.base_icon_state = initial(syringe_to_downgrade.base_icon_state)
	var/obj/item/reagent_containers/syringe/old_syringe = new syringe_to_downgrade.type()
	syringe_to_downgrade.possible_transfer_amounts = old_syringe.possible_transfer_amounts.Copy() // Created only to get a list.
	qdel(old_syringe)
	var/overflowing_reagents = syringe_to_downgrade.reagents.total_volume - initial(syringe_to_downgrade.volume)
	if(overflowing_reagents)
		var/datum/reagents/reagents_to_splash = new(overflowing_reagents)
		syringe_to_downgrade.reagents.trans_to(reagents_to_splash, reagents_to_splash.maximum_volume)
		var/turf/current_turf = borg.loc
		current_turf.add_liquid_from_reagents(reagents_to_splash)
	syringe_to_downgrade.amount_per_transfer_from_this = initial(syringe_to_downgrade.amount_per_transfer_from_this)
	syringe_to_downgrade.volume = initial(syringe_to_downgrade.volume)
	syringe_to_downgrade.reagents.maximum_volume = syringe_to_downgrade.volume
	syringe_to_downgrade.inject_flags = initial(syringe_to_downgrade.inject_flags)

/obj/item/borg/upgrade/syringe/piercing
	name = "cyborg piercing syringe upgrade"
	desc = "An upgrade that replaces the standard built-in syringe with a syringe that can pierce thick material."
	upgraded_syringe_typepath = /obj/item/reagent_containers/syringe/piercing

/obj/item/borg/upgrade/syringe/bluespace
	name = "cyborg bluespace syringe upgrade"
	desc = "An upgrade that replaces the standard built-in syringe with a syringe that can hold more reagents."
	upgraded_syringe_typepath = /obj/item/reagent_containers/syringe/bluespace
