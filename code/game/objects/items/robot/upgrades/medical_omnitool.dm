
// This is a base item which should be inherited from.
/obj/item/borg/upgrade/surgery_omnitool
	name = "cyborg surgical omni-tool upgrade"
	desc = "An upgrade that changes the standard built-in surgical omnitool somehow."
	icon_state = "module_medical"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/medical, /obj/item/robot_model/syndicate/medical)
	model_flags = BORG_MODEL_MEDICAL

/obj/item/borg/upgrade/surgery_omnitool/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return FALSE
	for(var/obj/item/borg/upgrade/surgery_omnitool/other_omnitool_upgrade in borg.upgrades)
		other_omnitool_upgrade.forceMove(get_turf(borg))

/obj/item/borg/upgrade/surgery_omnitool/advanced
	name = "cyborg surgical advanced omni-tool upgrade"
	desc = "An upgrade that upgrades the standard built-in surgical omnitool to be on par with advanced surgical tools which allows for faster surgery."

/obj/item/borg/upgrade/surgery_omnitool/advanced/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return FALSE
	for(var/obj/item/borg/cyborg_omnitool/medical/omnitool_module in borg.model.usable_modules)
		if(omnitool_module.upgraded)
			continue
		omnitool_module.set_upgraded(TRUE)

/obj/item/borg/upgrade/surgery_omnitool/advanced/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return FALSE
	for(var/obj/item/borg/cyborg_omnitool/medical/omnitool_module in borg.model.usable_modules)
		if(omnitool_module.upgraded && initial(omnitool_module.upgraded)) // Omnitools that start out upgraded shall stay upgraded.
			continue
		omnitool_module.set_upgraded(FALSE)

/obj/item/borg/upgrade/surgery_omnitool/alien
	name = "cyborg surgical alien omni-tool upgrade"
	desc = "An upgrade that replaces the standard built-in surgical omnitool with an alien variant of it which allows for even faster surgery."

/obj/item/borg/upgrade/surgery_omnitool/alien/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return FALSE
	for(var/obj/item/borg/cyborg_omnitool/medical/omnitool_module in borg.model.usable_modules) // Solely because we don't want to shuffle the item around in their inventory.
		omnitool_module.replace_tool(/obj/item/scalpel/cyborg, /obj/item/scalpel/cyborg/alien)
		omnitool_module.replace_tool(/obj/item/surgicaldrill/cyborg, /obj/item/surgicaldrill/cyborg/alien)
		omnitool_module.replace_tool(/obj/item/hemostat/cyborg, /obj/item/hemostat/cyborg/alien)
		omnitool_module.replace_tool(/obj/item/retractor/cyborg, /obj/item/retractor/cyborg/alien)
		omnitool_module.replace_tool(/obj/item/cautery/cyborg, /obj/item/cautery/cyborg/alien)
		omnitool_module.replace_tool(/obj/item/circular_saw/cyborg, /obj/item/circular_saw/cyborg/alien)
		omnitool_module.replace_tool(/obj/item/bonesetter/cyborg, /obj/item/bonesetter/cyborg/alien)

/obj/item/borg/upgrade/surgery_omnitool/alien/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return FALSE
	for(var/obj/item/borg/cyborg_omnitool/medical/omnitool_module in borg.model.usable_modules)
		omnitool_module.replace_tool(/obj/item/scalpel/cyborg/alien, /obj/item/scalpel/cyborg)
		omnitool_module.replace_tool(/obj/item/surgicaldrill/cyborg/alien, /obj/item/surgicaldrill/cyborg)
		omnitool_module.replace_tool(/obj/item/hemostat/cyborg/alien, /obj/item/hemostat/cyborg)
		omnitool_module.replace_tool(/obj/item/retractor/cyborg/alien, /obj/item/retractor/cyborg)
		omnitool_module.replace_tool(/obj/item/cautery/cyborg/alien, /obj/item/cautery/cyborg)
		omnitool_module.replace_tool(/obj/item/circular_saw/cyborg/alien, /obj/item/circular_saw/cyborg)
		omnitool_module.replace_tool(/obj/item/bonesetter/cyborg/alien, /obj/item/bonesetter/cyborg)
