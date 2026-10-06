/obj/item/borg/upgrade
	name = "borg upgrade module."
	desc = "Protected by FRM."
	icon = 'icons/mob/silicon/robot_items.dmi'
	icon_state = "module_general"
	w_class = WEIGHT_CLASS_SMALL
	/// Whitelist of model types that can use this upgrade.
	var/list/model_type = null
	/// Bitflags listing model compatibility. Used in the exosuit fabricator for creating sub-categories.
	var/list/model_flags = NONE
	/// List of items to add with the module, if any.
	var/list/items_to_add
	/// List of items to remove with the module, if any.
	var/list/items_to_remove
	/// If true, requires the cyborg to have chosen a module.
	var/require_model = FALSE
	/// If true, will be deleted after usage and will not be stored in the cyborg.
	var/one_use = FALSE
	/// If true, allows duplicates of itself to exist within the cyborg.
	var/allow_duplicates = FALSE

/**
 * Attempts to upgrade the cyborg.
 * - borg: The cyborg being upgraded.
 * - user: The [/mob] (via item usage) or [/client] (via admin borg panel) that is performing the upgrade.
 */
/obj/item/borg/upgrade/proc/action(mob/living/silicon/robot/borg, user)
	if(borg.stat == DEAD)
		to_chat(user, span_warning("[src] will not function on a deceased cyborg!"))
		return FALSE
	if(model_type && !is_type_in_list(borg.model, model_type))
		to_chat(borg, span_alert("Upgrade mounting error! No suitable hardpoint detected."))
		to_chat(user, span_warning("There's no mounting point for the module!"))
		return FALSE
	if(!allow_duplicates && (locate(type) in borg.upgrades))
		to_chat(borg, span_alert("Upgrade mounting error! Hardpoint already occupied!"))
		to_chat(user, span_warning("The mounting point for the module is already occupied!"))
		return FALSE
	// Handles adding/removing items.
	if(length(items_to_add))
		install_items(borg, user, items_to_add)
	if(length(items_to_remove))
		remove_items(borg, user, items_to_remove)
	return TRUE

/**
 * Attempts to downgrade the cyborg.
 * - borg: The cyborg being downgraded.
 * - user: The [/mob] (via item usage) or [/client] (via admin borg panel) that is performing the downgrade.
 */
/obj/item/borg/upgrade/proc/deactivate(mob/living/silicon/robot/borg, user = usr)
	if (!(src in borg.upgrades))
		return FALSE
	// Handles reverting the items back.
	if(length(items_to_add))
		remove_items(borg, user, items_to_add)
	if(length(items_to_remove))
		install_items(borg, user, items_to_remove)
	return TRUE

/**
 * Handles adding items with the module.
 * - borg: The cyborg getting the items.
 * - user: The [/mob] (via item usage) or [/client] (via admin borg panel) that is giving the items (upgrading).
 * - items: List of item typepaths to create and give.
 */
/obj/item/borg/upgrade/proc/install_items(mob/living/silicon/robot/borg, user, list/items)
	for(var/item_to_add in items)
		var/obj/item/module_item = new item_to_add(borg)
		borg.model.basic_modules += module_item
		borg.model.add_module(module_item, FALSE, TRUE)
	return TRUE

/**
 * Handles adding items with the module.
 * - borg: The cyborg losing the items.
 * - user: The [/mob] (via item usage) or [/client] (via admin borg panel) that is removing the items (downgrading).
 * - items: List of item typepaths to find and delete.
 */
/obj/item/borg/upgrade/proc/remove_items(mob/living/silicon/robot/borg, user = usr, list/items)
	for(var/item_to_remove in items)
		var/obj/item/module_item = locate(item_to_remove) in borg.model.usable_modules
		if(module_item)
			borg.model.remove_module(module_item)
	return TRUE
