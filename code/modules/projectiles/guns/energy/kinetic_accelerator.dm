/obj/item/gun/energy/recharge/kinetic_accelerator
	name = "proto-kinetic accelerator"
	desc = "A self recharging, ranged mining tool that does increased damage in low pressure."
	icon_state = "kineticgun"
	base_icon_state = "kineticgun"
	inhand_icon_state = "kineticgun"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic)
	item_flags = NONE
	obj_flags = UNIQUE_RENAME
	weapon_weight = WEAPON_LIGHT
	gun_flags = NOT_A_REAL_GUN
	/// List of all mobs that projectiles fired from this gun will ignore.
	var/list/ignored_mob_types
	/// List of all modkits currently in the kinetic accelerator.
	var/list/obj/item/borg/upgrade/modkit/modkits = list()
	/// The max capacity of modkits the PKA can have installed at once.
	var/max_mod_capacity = 100
	/// Prevents the removal or addition of any modkits.
	var/disable_modification = FALSE

/obj/item/gun/energy/recharge/kinetic_accelerator/Initialize(mapload)
	. = ..()

	AddElement( \
		/datum/element/contextual_screentip_bare_hands, \
		rmb_text = "Detach a modkit", \
	)

	var/static/list/tool_behaviors = list(
		TOOL_CROWBAR = list(
			SCREENTIP_CONTEXT_LMB = "Eject all modkits",
		),
	)
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)

/obj/item/gun/energy/recharge/kinetic_accelerator/Exited(atom/movable/gone, direction)
	if(gone in modkits)
		var/obj/item/borg/upgrade/modkit/gone_modkit = gone
		gone_modkit.uninstall(src)
	return ..()

/obj/item/gun/energy/recharge/kinetic_accelerator/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(istype(arrived, /obj/item/borg/upgrade/modkit))
		modkits |= arrived

/obj/item/gun/energy/recharge/kinetic_accelerator/examine(mob/user)
	. = ..()
	if(disable_modification)
		for(var/obj/item/borg/upgrade/modkit/modkit_upgrade as anything in modkits)
			. += span_notice("There is \a [modkit_upgrade] installed.")
		return
	. += "<b>[get_remaining_mod_capacity()]%</b> mod capacity remaining."
	. += span_info("You can use a <b>crowbar</b> to remove all modules or <b>right-click</b> with an empty hand to remove a specific one.")
	for(var/obj/item/borg/upgrade/modkit/modkit_upgrade as anything in modkits)
		. += span_notice("There is \a [modkit_upgrade] installed, using <b>[modkit_upgrade.cost]%</b> capacity.")


/obj/item/gun/energy/recharge/kinetic_accelerator/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/borg/upgrade/modkit))
		return NONE
	if(disable_modification)
		to_chat(user, span_notice("Modifications cannot be installed on this!"))
		return ITEM_INTERACT_BLOCKING
	var/obj/item/borg/upgrade/modkit/installing_modkit = tool
	installing_modkit.install(src, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/gun/energy/recharge/kinetic_accelerator/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!LAZYLEN(modkits))
		return SECONDARY_ATTACK_CONTINUE_CHAIN

	var/list/display_names = list()
	var/list/items = list()
	for(var/modkits_length in 1 to length(modkits))
		var/obj/item/thing = modkits[modkits_length]
		display_names["[thing.name] ([modkits_length])"] = REF(thing)
		var/image/item_image = image(icon = thing.icon, icon_state = thing.icon_state)
		if(length(thing.overlays))
			item_image.copy_overlays(thing)
		items["[thing.name] ([modkits_length])"] = item_image

	var/pick = show_radial_menu(user, src, items, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 36, require_near = TRUE, tooltips = TRUE)
	if(!pick)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	var/modkit_reference = display_names[pick]
	var/obj/item/borg/upgrade/modkit/modkit_to_remove = locate(modkit_reference) in modkits
	if(!istype(modkit_to_remove))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	if(!user.put_in_hands(modkit_to_remove))
		modkit_to_remove.forceMove(drop_location())
	update_appearance(UPDATE_ICON)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/gun/energy/recharge/kinetic_accelerator/crowbar_act(mob/living/user, obj/item/tool)
	. = TRUE
	if(!modkits.len)
		to_chat(user, span_notice("There are no modifications currently installed."))
		return
	if(disable_modification)
		to_chat(user, span_notice("The modifications cannot be removed."))
		return
	to_chat(user, span_notice("You pry all the modifications out."))
	tool.play_tool_sound(src, 100)
	for(var/obj/item/borg/upgrade/modkit/modkit_upgrade as anything in modkits)
		modkit_upgrade.forceMove(drop_location()) // Uninstallation handled in Exited(). For cyborgs, uninstallation is handled via [/mob/living/silicon/robot/remove_from_upgrades()] instead.

/obj/item/gun/energy/recharge/kinetic_accelerator/apply_fantasy_bonuses(bonus)
	. = ..()
	max_mod_capacity = modify_fantasy_variable("max_mod_capacity", max_mod_capacity, bonus * 10)

/obj/item/gun/energy/recharge/kinetic_accelerator/remove_fantasy_bonuses(bonus)
	max_mod_capacity = reset_fantasy_variable("max_mod_capacity", max_mod_capacity)
	return ..()

/obj/item/gun/energy/recharge/kinetic_accelerator/add_bayonet_point()
	AddComponent(/datum/component/bayonet_attachable, offset_x = 20, offset_y = 12)

/obj/item/gun/energy/recharge/kinetic_accelerator/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/weapons/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 15, \
		overlay_y = 9)

/obj/item/gun/energy/recharge/kinetic_accelerator/shoot_with_empty_chamber(mob/living/user)
	playsound(src, dry_fire_sound, 30, TRUE) // Click sound but no to_chat message to cut on spam.
	return

/// Checks if the radial menu can be kept open.
/obj/item/gun/energy/recharge/kinetic_accelerator/proc/check_menu(mob/living/carbon/human/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated())
		return FALSE
	return TRUE

/// Gets the remaining amount of mod capacity.
/obj/item/gun/energy/recharge/kinetic_accelerator/proc/get_remaining_mod_capacity()
	var/current_capacity_used = 0
	for(var/obj/item/borg/upgrade/modkit/modkit_upgrade as anything in modkits)
		current_capacity_used += modkit_upgrade.cost
	return max_mod_capacity - current_capacity_used

/// Modifies the projectile as it is being fired.
/obj/item/gun/energy/recharge/kinetic_accelerator/proc/modify_projectile(obj/projectile/kinetic/kinetic_projectile)
	kinetic_projectile.kinetic_gun = src // Do something special on-hit, easy!
	for(var/obj/item/borg/upgrade/modkit/modkit_upgrade as anything in modkits)
		modkit_upgrade.modify_projectile(kinetic_projectile)

/// Handles any effects that should be done before anything. No damage has been applied yet. It has not been modified by pressure reduction yet.
/// This occurs before the modkit effects.
/obj/item/gun/energy/recharge/kinetic_accelerator/proc/projectile_prehit(obj/projectile/kinetic/projectile, atom/target)
	return

/// Handles any effects that should be done just before damage is dealt.
/// This occurs before the modkit effects.
/obj/item/gun/energy/recharge/kinetic_accelerator/proc/projectile_strike_predamage(obj/projectile/kinetic/projectile, turf/target_turf, atom/target)
	return

/// Handles any effects that should be done just before damage is dealt.
/// This occurs before the modkit effects and after [projectile_strike_predamage()] above.
/obj/item/gun/energy/recharge/kinetic_accelerator/proc/projectile_strike(obj/projectile/kinetic/projectile, turf/target_turf, atom/target)
	return

/obj/item/gun/energy/recharge/kinetic_accelerator/minebot
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL
	recharge_time = 2 SECONDS
	holds_charge = TRUE
	unique_frequency = TRUE

/obj/item/gun/energy/recharge/kinetic_accelerator/cyborg
	holds_charge = TRUE
	unique_frequency = TRUE

/obj/item/gun/energy/recharge/kinetic_accelerator/cyborg/add_bayonet_point()
	AddComponent(/datum/component/bayonet_attachable, starting_bayonet = new /obj/item/knife/combat/survival(src), offset_x = 20, offset_y = 12, removable = FALSE)

/obj/item/gun/energy/recharge/kinetic_accelerator/glock
	name = "proto-kinetic pistol"
	desc = "An innovative take on the Proto-Kinetic Accelerator, this model comes with none of the technology that makes the accelerator actually good. \
	Working a late shift one night, the Mining Research Director used a box of salvaged spare parts from busted accelerators to throw together this design. While it lacks \
	most of what makes the accelerator a good tool, it makes up for it with a unprecidented amount of room for modification, capable of holding nearly triple \
	the amount of mods that a normal accelerator could. 'Assemble it yourself' he said."
	icon = 'icons/obj/weapons/guns/energy.dmi'
	icon_state = "kineticpistol"
	base_icon_state = "kineticpistol"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/glock)
	max_mod_capacity = 210

/obj/item/gun/energy/recharge/kinetic_accelerator/railgun
	name = "proto-kinetic railgun"
	desc = "Before the nice streamlined and modern day Proto-Kinetic Accelerator was created, multiple designs were drafted by the Mining Research and Development \
	team. Many were failures, including this one, which came out too bulky and too ineffective. Well recently the MR&D Team got drunk and said 'fuck it we ball' and \
	went back to the bulky design, overclocked it, and made it functional, turning it into what is essentially a literal man portable particle accelerator. \
	The design results in a massive hard to control blast of kinetic energy, with the power to punch right through creatures and cause massive damage. The \
	only problem with the design is that it is so bulky you need to carry it with two hands, and the technology has been outfitted with a special firing pin \
	that denies use near or on the station, due to its destructive nature."
	icon = 'icons/obj/weapons/guns/energy.dmi'
	icon_state = "kineticrailgun"
	base_icon_state = "kineticrailgun"
	w_class = WEIGHT_CLASS_BULKY
	pin = /obj/item/firing_pin/wastes
	recharge_time = 3 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/railgun)
	weapon_weight = WEAPON_HEAVY
	max_mod_capacity = 0 // Fuck off
	recoil = 1 // Railgun go brrrrr
	disable_modification = TRUE

/obj/item/gun/energy/recharge/kinetic_accelerator/repeater
	name = "proto-kinetic repeater"
	desc = "A Proto-Kinetic Accelerator with multiple smaller capacitors instead of one big one for storing charges. Turns out using less than \
	full power on the kinetic force generation means that you can fit a couple more smaller capacitors in without the entire thing exploding. \
	This results in a multi shot accelerator that doesn't combust on the first shot and allows rapid follow up shots in short succession. \
	The director said 'It came to me in a delusion' when we asked him how the team came up with this."
	icon = 'icons/obj/weapons/guns/energy.dmi'
	icon_state = "kineticrepeater"
	base_icon_state = "kineticrepeater"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/repeater)
	max_mod_capacity = 60

/obj/item/gun/energy/recharge/kinetic_accelerator/shockwave
	name = "proto-kinetic shockwave"
	desc = "Innovating on the mining blast mod, Mining Research and Development has managed to overclock the performance of the mod to the extreme. \
	The result is a specialized accelerator frame that when equipped with the accompanying modkit grants a fairly punchy, large blast that is excellent \
	for clearing large amounts of rocks and crowded fauna. \
	The only downside is the lowered mod capacity, lack of range and longer cooldown... but its pretty good for clearing rocks."
	icon = 'icons/obj/weapons/guns/energy.dmi'
	icon_state = "kineticshockwave"
	base_icon_state = "kineticshockwave"
	recharge_time = 2 SECONDS
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/shockwave)
	max_mod_capacity = 60

/obj/item/gun/energy/recharge/kinetic_accelerator/shockwave/modify_projectile(obj/projectile/kinetic/kinetic_projectile)
	kinetic_projectile.aoe_explosion_range = max(kinetic_projectile.aoe_explosion_range, 2)
	kinetic_projectile.aoe_explosion_affects_turfs = TRUE
	kinetic_projectile.aoe_explosion_damage_multiplier += 0.5
	return ..()

/obj/item/gun/energy/recharge/kinetic_accelerator/meme
	name = "adminium reaper"
	desc = "Mining RnD broke the fabric of space time, please return to your nearest centralcommand officer. <b> WARNING FROM THE MINING RND DIRECTOR : DO NOT RAPIDLY PULL TRIGGER : FABRIC OF SPACE TIME LIABLE TO BREAK </b>"
	recharge_time = 0.1
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/meme)
	max_mod_capacity = 420

/obj/item/gun/energy/recharge/kinetic_accelerator/meme/nonlethal
	name = "adminium stunner"
	desc = "Mining RnD broke the fabric of space time AGAIN, please return to your nearest centralcommand officer. <b> WARNING FROM THE MINING RND DIRECTOR : DO NOT RAPIDLY PULL TRIGGER : FABRIC OF SPACE TIME LIABLE TO BREAK </b>\
	Im being bullied by the admins"
	ammo_type = list(/obj/item/ammo_casing/energy/kinetic/meme/nonlethal)
	max_mod_capacity = 0

//
// Casing
//

/obj/item/ammo_casing/energy/kinetic
	projectile_type = /obj/projectile/kinetic
	select_name = "kinetic"
	e_cost = LASER_SHOTS(1, STANDARD_CELL_CHARGE * 0.5)
	fire_sound = 'sound/weapons/kenetic_accel.ogg' // Fine spelling there chap.

/obj/item/ammo_casing/energy/kinetic/ready_proj(atom/target, mob/living/user, quiet, zone_override = "")
	. = ..()
	if(!loc || !istype(loc, /obj/item/gun/energy/recharge/kinetic_accelerator))
		return
	var/obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun = loc
	kinetic_gun.modify_projectile(loaded_projectile)

//
// Modkits
//

/obj/item/borg/upgrade/modkit
	name = "kinetic accelerator modification kit"
	desc = "An upgrade for kinetic accelerators."
	icon = 'icons/obj/objects.dmi'
	icon_state = "modkit"
	w_class = WEIGHT_CLASS_SMALL
	require_model = TRUE
	model_type = list(/obj/item/robot_model/miner)
	model_flags = BORG_MODEL_MINER
	// Most modkits are supposed to allow duplicates. The ones that don't should be blocked by PKA code anyways.
	allow_duplicates = TRUE
	/// The modkit type that will be checked for when installing this upgrade.
	var/denied_type = null
	/// The amount of [denied_type] modkits that there can be. If it reaches this amount, this upgrade cannot be installed.
	var/maximum_of_type = 1
	/// The capacity it takes up inside of a kinetic accelerator.
	var/cost = 30
	/// For usage in modkits that have numerical modifiers. Useful for subtypes that do similar things, but with different numbers.
	var/modifier = 1
	/// Can this be installed into minebots?
	var/minebot_upgrade = TRUE
	/// Is this only allowed to be installed into minebots?
	var/minebot_exclusive = FALSE

/obj/item/borg/upgrade/modkit/examine(mob/user)
	. = ..()
	. += span_notice("Occupies <b>[cost]%</b> of mod capacity.")

/obj/item/borg/upgrade/modkit/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/gun/energy/recharge/kinetic_accelerator))
		return NONE
	if(issilicon(user)) // Cyborgs should get external help to get their upgrades.
		return ITEM_INTERACT_BLOCKING
	install(tool, user)
	return ITEM_INTERACT_SUCCESS

/obj/item/borg/upgrade/modkit/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return
	for(var/obj/item/gun/energy/recharge/kinetic_accelerator/cyborg/kinetic_gun in borg.model.modules)
		return install(kinetic_gun, usr, FALSE)

/obj/item/borg/upgrade/modkit/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return
	for(var/obj/item/gun/energy/recharge/kinetic_accelerator/cyborg/kinetic_gun in borg.model.modules)
		uninstall(kinetic_gun)

/// Installs the modkit if it can do so.
/obj/item/borg/upgrade/modkit/proc/install(obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun, mob/user, transfer_to_loc = TRUE)
	if(istype(kinetic_gun.loc, /mob/living/basic/mining_drone))
		if(!minebot_upgrade)
			to_chat(user, span_notice("The modkit you're trying to install is not rated for minebot use."))
			return FALSE
	else
		if(minebot_exclusive)
			to_chat(user, span_notice("The modkit you're trying to install is only rated for minebot use."))
			return FALSE
	if(denied_type)
		var/number_of_denied = 0
		for(var/obj/item/borg/upgrade/modkit/modkit_upgrade as anything in kinetic_gun.modkits)
			if(!istype(modkit_upgrade, denied_type))
				continue
			number_of_denied++
			if(number_of_denied >= maximum_of_type)
				to_chat(user, span_notice("The modkit you're trying to install would conflict with an already installed modkit. Remove existing modkits first."))
				return FALSE
	if(cost > kinetic_gun.get_remaining_mod_capacity())
		to_chat(user, span_notice("You don't have room(<b>[kinetic_gun.get_remaining_mod_capacity()]%</b> remaining, [cost]% needed) to install this modkit. Use a crowbar or right click with an empty hand to remove existing modkits."))
		return FALSE
	if(transfer_to_loc && !user.transferItemToLoc(src, kinetic_gun))
		return FALSE
	to_chat(user, span_notice("You install the modkit."))
	playsound(loc, 'sound/items/screwdriver.ogg', 100, TRUE)
	kinetic_gun.modkits |= src
	return TRUE

/// Uninstalls the modkit.
/obj/item/borg/upgrade/modkit/proc/uninstall(obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun)
	kinetic_gun.modkits -= src

/// Modifies the projectile as it is being fired.
/obj/item/borg/upgrade/modkit/proc/modify_projectile(obj/projectile/kinetic/kinetic_projectile)

/// Handles any effects that should be done before anything. No damage has been applied yet. It has not been modified by pressure reduction yet.
/// This occurs after the kinetic accelerator's effects.
/obj/item/borg/upgrade/modkit/proc/projectile_prehit(obj/projectile/kinetic/kinetic_projectile, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun)

/// Handles any effects that should be done just before damage is dealt.
/// This occurs after the kinetic accelerator's effects.
/obj/item/borg/upgrade/modkit/proc/projectile_strike_predamage(obj/projectile/kinetic/kinetic_projectile, turf/target_turf, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun)

/// Handles any effects that should be done just before damage is dealt.
/// This occurs after the kinetic accelerator's effects and after [projectile_strike_predamage()] above.
/obj/item/borg/upgrade/modkit/proc/projectile_strike(obj/projectile/kinetic/kinetic_projectile, turf/target_turf, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun)

/obj/item/borg/upgrade/modkit/range
	name = "range increase"
	desc = "Increases the range of a kinetic accelerator when installed."
	modifier = 1
	cost = 25

/obj/item/borg/upgrade/modkit/range/modify_projectile(obj/projectile/kinetic/kinetic_projectile)
	kinetic_projectile.range += modifier

/obj/item/borg/upgrade/modkit/damage
	name = "damage increase"
	desc = "Increases the damage of kinetic accelerator when installed."
	modifier = 10

/obj/item/borg/upgrade/modkit/damage/modify_projectile(obj/projectile/kinetic/kinetic_projectile)
	kinetic_projectile.damage += modifier
	return ..()

/obj/item/borg/upgrade/modkit/cooldown
	name = "cooldown decrease"
	desc = "Decreases the cooldown of a kinetic accelerator. Not rated for minebot use."
	modifier = 3.2
	minebot_upgrade = FALSE

// Recalculate recharge time after adding or removing cooldown mods.
/obj/item/borg/upgrade/modkit/cooldown/proc/get_recharge_time(obj/item/gun/energy/recharge/kinetic_accelerator/KA)
	var/new_recharge_time = initial(KA.recharge_time)
	for(var/obj/item/borg/upgrade/modkit/modkit_upgrade as anything in KA.modkits)
		if(istype(modkit_upgrade, src))
			new_recharge_time -= modifier
	return new_recharge_time

/obj/item/borg/upgrade/modkit/cooldown/install(obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun, mob/user, transfer_to_loc)
	. = ..()
	if(!.)
		return
	kinetic_gun.recharge_time = get_recharge_time(kinetic_gun)

/obj/item/borg/upgrade/modkit/cooldown/uninstall(obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun)
	..()
	kinetic_gun.recharge_time = get_recharge_time(kinetic_gun)

/obj/item/borg/upgrade/modkit/cooldown/minebot
	name = "minebot cooldown decrease"
	desc = "Decreases the cooldown of a kinetic accelerator. Only rated for minebot use."
	icon_state = "door_electronics"
	icon = 'icons/obj/module.dmi'
	denied_type = /obj/item/borg/upgrade/modkit/cooldown/minebot
	modifier = 10
	cost = 0
	minebot_upgrade = TRUE
	minebot_exclusive = TRUE

/obj/item/borg/upgrade/modkit/aoe
	modifier = 0
	/// Should the explosion affect turfs as well?
	var/turf_aoe = FALSE

/obj/item/borg/upgrade/modkit/aoe/modify_projectile(obj/projectile/kinetic/kinetic_projectile)
	kinetic_projectile.name = "kinetic explosion"
	kinetic_projectile.aoe_explosion_range = max(kinetic_projectile.aoe_explosion_range, 1)
	if(turf_aoe)
		kinetic_projectile.aoe_explosion_affects_turfs = TRUE
	kinetic_projectile.aoe_explosion_damage_multiplier += modifier
	return ..()

/obj/item/borg/upgrade/modkit/aoe/turfs
	name = "mining explosion"
	desc = "Causes the kinetic accelerator to destroy rock in an AoE."
	denied_type = /obj/item/borg/upgrade/modkit/aoe/turfs
	turf_aoe = TRUE

/obj/item/borg/upgrade/modkit/aoe/turfs/andmobs
	name = "offensive mining explosion"
	desc = "Causes the kinetic accelerator to destroy rock and damage mobs in an AoE."
	maximum_of_type = 3
	modifier = 0.25

/obj/item/borg/upgrade/modkit/aoe/mobs
	name = "offensive explosion"
	desc = "Causes the kinetic accelerator to damage mobs in an AoE."
	modifier = 0.2

/obj/item/borg/upgrade/modkit/minebot_passthrough
	name = "minebot passthrough"
	desc = "Causes kinetic accelerator shots to pass through minebots."
	denied_type = /obj/item/borg/upgrade/modkit/human_passthrough
	cost = 0

/obj/item/borg/upgrade/modkit/minebot_passthrough/install(obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun, mob/user, transfer_to_loc)
	. = ..()
	if(!.)
		return
	LAZYADD(kinetic_gun.ignored_mob_types, typecacheof(/mob/living/basic/mining_drone))

/obj/item/borg/upgrade/modkit/minebot_passthrough/uninstall(obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun)
	. = ..()
	if(!.)
		return
	LAZYREMOVE(kinetic_gun.ignored_mob_types, typecacheof(/mob/living/basic/mining_drone))

/obj/item/borg/upgrade/modkit/human_passthrough
	name = "human passthrough"
	desc = "Causes kinetic accelerator shots to pass through humans, good for preventing friendly fire."
	denied_type = /obj/item/borg/upgrade/modkit/minebot_passthrough
	cost = 0

/obj/item/borg/upgrade/modkit/human_passthrough/install(obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun, mob/user, transfer_to_loc)
	. = ..()
	if(!.)
		return
	LAZYADD(kinetic_gun.ignored_mob_types, typecacheof(/mob/living/carbon/human))

/obj/item/borg/upgrade/modkit/human_passthrough/uninstall(obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun)
	. = ..()
	if(!.)
		return
	LAZYREMOVE(kinetic_gun.ignored_mob_types, typecacheof(/mob/living/carbon/human))

/obj/item/borg/upgrade/modkit/cooldown/repeater
	name = "rapid repeater"
	desc = "Quarters the kinetic accelerator's cooldown on striking a living target, but greatly increases the base cooldown."
	denied_type = /obj/item/borg/upgrade/modkit/cooldown/repeater
	modifier = -1.4 SECONDS //Makes the cooldown 3 seconds (with no cooldown mods) if you miss. Don't miss.
	cost = 50

/obj/item/borg/upgrade/modkit/cooldown/repeater/projectile_strike_predamage(obj/projectile/kinetic/kinetic_projectile, turf/target_turf, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun)
	var/valid_repeat = FALSE
	if(isliving(target))
		var/mob/living/living_target = target
		if(living_target.stat != DEAD)
			valid_repeat = TRUE
	if(ismineralturf(target_turf))
		valid_repeat = TRUE
	if(!valid_repeat)
		return
	kinetic_gun.cell.use(kinetic_gun.cell.charge)
	kinetic_gun.attempt_reload(kinetic_gun.recharge_time * 0.25) // If you hit, the cooldown drops to 0.75 seconds.

/obj/item/borg/upgrade/modkit/lifesteal
	name = "lifesteal crystal"
	desc = "Causes kinetic accelerator shots to slightly heal the firer on striking a living target."
	icon_state = "modkit_crystal"
	modifier = 2.5 // Not a very effective method of healing.
	cost = 20
	/// The order of damage types to heal.
	var/static/list/damage_heal_order = list(BRUTE, BURN, OXY)

/obj/item/borg/upgrade/modkit/lifesteal/projectile_prehit(obj/projectile/kinetic/kinetic_projectile, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun)
	if(!isliving(target) || isliving(kinetic_projectile.firer))
		return
	var/mob/living/living_target = target
	if(living_target.stat == DEAD)
		return
	living_target = kinetic_projectile.firer
	living_target.heal_ordered_damage(modifier, damage_heal_order)

/obj/item/borg/upgrade/modkit/resonator_blasts
	name = "resonator blast"
	desc = "Causes kinetic accelerator shots to leave and detonate resonator blasts."
	denied_type = /obj/item/borg/upgrade/modkit/resonator_blasts
	cost = 30
	modifier = 0.25 // A bonus 15 damage if you burst the field on a target. 60 if you lure them into it.

/obj/item/borg/upgrade/modkit/resonator_blasts/projectile_strike(obj/projectile/kinetic/kinetic_projectile, turf/target_turf, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun)
	if(!target_turf)
		return
	if(ismineralturf(target_turf)) // Don't make fields on mineral turfs.
		return
	var/obj/effect/temp_visual/resonance/resonance_effect = locate(/obj/effect/temp_visual/resonance) in target_turf
	if(!resonance_effect)
		new /obj/effect/temp_visual/resonance(target_turf, kinetic_projectile.firer, null, RESONATOR_MODE_MANUAL, 100) // Manual detonate mode and will NOT spread.
		return
	resonance_effect.damage_multiplier = modifier
	resonance_effect.burst()

/obj/item/borg/upgrade/modkit/bounty
	name = "death syphon"
	desc = "Killing or assisting in killing a creature permanently increases your damage against that type of creature."
	denied_type = /obj/item/borg/upgrade/modkit/bounty
	modifier = 1.25
	cost = 30
	/// The maximum amount of bounties / bonus damage possible.
	var/maximum_bounty = 25
	/// Associative list: living_typepath = bounty.
	var/list/bounties_reaped = list()

/obj/item/borg/upgrade/modkit/bounty/projectile_prehit(obj/projectile/kinetic/kinetic_projectile, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun)
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	var/list/existing_marks = living_target.has_status_effect_list(/datum/status_effect/syphon_mark)
	for(var/i in existing_marks)
		var/datum/status_effect/syphon_mark/syphon_mark_effect = i
		if(syphon_mark_effect.reward_target != src)
			continue // We want to allow multiple people with bounty modkits to use them, but we need to replace our own marks so we don't multi-reward.
		syphon_mark_effect.reward_target = null
		qdel(syphon_mark_effect)
	living_target.apply_status_effect(/datum/status_effect/syphon_mark, src)

/obj/item/borg/upgrade/modkit/bounty/projectile_strike(obj/projectile/kinetic/kinetic_projectile, turf/target_turf, atom/target, obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun)
	if(!isliving(target))
		return
	var/mob/living/living_target = target
	if(!bounties_reaped[living_target.type])
		return
	var/damage_multiplier = 1
	if(kinetic_projectile.pressure_decrease_active)
		damage_multiplier *= kinetic_projectile.pressure_decrease
	var/armor = living_target.run_armor_check(kinetic_projectile.def_zone, kinetic_projectile.armor_flag, "", "", kinetic_projectile.armour_penetration)
	living_target.apply_damage(bounties_reaped[living_target.type] * damage_multiplier, kinetic_projectile.damage_type, kinetic_projectile.def_zone, armor)

/obj/item/borg/upgrade/modkit/bounty/proc/get_kill(mob/living/living_target)
	var/bounty_multiplier = ismegafauna(living_target) ? 4 : 1
	if(!bounties_reaped[living_target.type])
		bounties_reaped[living_target.type] = min(modifier * bounty_multiplier, maximum_bounty)
		return
	bounties_reaped[living_target.type] = min(bounties_reaped[living_target.type] + (modifier * bounty_multiplier), maximum_bounty)

/obj/item/borg/upgrade/modkit/indoors
	name = "decrease pressure penalty"
	desc = "A syndicate modification kit that increases the damage a kinetic accelerator does in high pressure environments."
	modifier = 2
	denied_type = /obj/item/borg/upgrade/modkit/indoors
	maximum_of_type = 2
	cost = 35

/obj/item/borg/upgrade/modkit/indoors/modify_projectile(obj/projectile/kinetic/kinetic_projectile)
	kinetic_projectile.pressure_decrease *= modifier

/obj/item/borg/upgrade/modkit/trigger_guard
	name = "modified trigger guard"
	desc = "Allows creatures normally incapable of firing guns to operate the weapon when installed."
	cost = 20
	denied_type = /obj/item/borg/upgrade/modkit/trigger_guard

/obj/item/borg/upgrade/modkit/trigger_guard/install(obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun, mob/user, transfer_to_loc)
	. = ..()
	if(!.)
		return
	kinetic_gun.trigger_guard = TRIGGER_GUARD_ALLOW_ALL

/obj/item/borg/upgrade/modkit/trigger_guard/uninstall(obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun)
	. = ..()
	if(!.)
		return
	kinetic_gun.trigger_guard = TRIGGER_GUARD_NORMAL

// Hardmode modkits.
/obj/item/borg/upgrade/modkit/hardmode
	name = "HRD-MDE accelerator injector"
	desc = "An experimental attachment to a kinetic accelerator that can make megafauna crystallize a core, making them harder."
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	icon_state = "crevice_shard"
	cost = 0
	denied_type = /obj/item/borg/upgrade/modkit/hardmode

/obj/item/borg/upgrade/modkit/hardmode/examine_more(mob/user)
	. = ..()
	. += span_notice("An experimental injector developed by the Nanotrasen Science Division used to force a megafauna to crystallize a core.")
	. += span_notice("Due to the crystallization process the megafauna becomes much stronger, however the core can be extracted post-death.")
	. += span_notice("A use for crystallized cores has not yet been found, but many experienced miners show them off just like trophies.")

/obj/item/borg/upgrade/modkit/hardmode/projectile_strike(obj/projectile/kinetic/kinetic_projectile, turf/target_turf, mob/living/simple_animal/hostile/megafauna/target, obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun)
	if(!istype(target))
		return
	if(isnull(target.hardmode_reward) || target.hardmode)
		return
	if(is_station_level(target.z))
		return
	target.activate_hardmode()
	log_combat(kinetic_gun, target, "turned on hardmode for", src)
	qdel(src)

/obj/item/borg/upgrade/modkit/chassis_mod
	name = "super chassis"
	desc = "Makes your KA yellow. All the fun of having a more powerful KA without actually having a more powerful KA."
	cost = 0
	denied_type = /obj/item/borg/upgrade/modkit/chassis_mod
	/// The name to replace the kinetic accelerator's current name with.
	var/chassis_name = "super-kinetic accelerator"
	/// The icon state to replace the kinetic accelerator's current icon states with.
	var/chassis_iconstate = "kineticgun_u"
	/// List of all kinetic accelerator types that cannot use this modkit.
	var/static/list/blacklisted_kinetic_types = list(
		/obj/item/gun/energy/recharge/kinetic_accelerator/glock,
		/obj/item/gun/energy/recharge/kinetic_accelerator/meme,
		/obj/item/gun/energy/recharge/kinetic_accelerator/railgun,
		/obj/item/gun/energy/recharge/kinetic_accelerator/repeater,
		/obj/item/gun/energy/recharge/kinetic_accelerator/shockwave,
	)

/obj/item/borg/upgrade/modkit/chassis_mod/install(obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun, mob/user, transfer_to_loc)
	if(is_type_in_list(kinetic_gun, blacklisted_kinetic_types))
		to_chat(user, span_warning("[src] is not compatible with [kinetic_gun]."))
		return FALSE
	. = ..()
	if(!.)
		return
	kinetic_gun.icon_state = chassis_iconstate
	kinetic_gun.inhand_icon_state = chassis_iconstate
	kinetic_gun.name = chassis_name
	if(!iscarbon(kinetic_gun.loc))
		return
	var/mob/living/carbon/holder = kinetic_gun.loc
	holder.update_held_items()

/obj/item/borg/upgrade/modkit/chassis_mod/uninstall(obj/item/gun/energy/recharge/kinetic_accelerator/kinetic_gun)
	. = ..()
	if(!.)
		return
	kinetic_gun.icon_state = initial(kinetic_gun.icon_state)
	kinetic_gun.inhand_icon_state = initial(kinetic_gun.inhand_icon_state)
	kinetic_gun.name = initial(kinetic_gun.name)
	if(!iscarbon(kinetic_gun.loc))
		return
	var/mob/living/carbon/holder = kinetic_gun.loc
	holder.update_held_items()

/obj/item/borg/upgrade/modkit/chassis_mod/orange
	name = "hyper chassis"
	desc = "Makes your KA orange. All the fun of having explosive blasts without actually having explosive blasts."
	chassis_name = "hyper-kinetic accelerator"
	chassis_iconstate = "kineticgun_h"

/obj/item/borg/upgrade/modkit/tracer
	name = "white tracer bolts"
	desc = "Causes kinetic accelerator bolts to have a white tracer trail and explosion."
	cost = 0
	denied_type = /obj/item/borg/upgrade/modkit/tracer
	/// The color of the projectile.
	var/bolt_color = "#FFFFFF"

/obj/item/borg/upgrade/modkit/tracer/modify_projectile(obj/projectile/kinetic/kinetic_projectile)
	kinetic_projectile.icon_state = "ka_tracer"
	kinetic_projectile.color = bolt_color

/obj/item/borg/upgrade/modkit/tracer/adjustable
	name = "adjustable tracer bolts"
	desc = "Causes kinetic accelerator bolts to have an adjustable-colored tracer trail and explosion. Use in-hand to change color."

/obj/item/borg/upgrade/modkit/tracer/adjustable/interact(mob/user)
	. = ..()
	choose_bolt_color(user)

/// Prompts the user to pick what color they want the projectile to be.
/obj/item/borg/upgrade/modkit/tracer/adjustable/proc/choose_bolt_color(mob/user)
	set waitfor = FALSE

	var/new_color = tgui_color_picker(user, "", "Choose Color", bolt_color)
	bolt_color = new_color || bolt_color
