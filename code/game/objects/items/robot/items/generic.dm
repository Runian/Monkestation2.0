#define HUG_MODE_NICE 0
#define HUG_MODE_HUG 1
#define HUG_MODE_SHOCK 2
#define HUG_MODE_CRUSH 3

#define HUG_SHOCK_COOLDOWN (2 SECONDS)
#define HUG_CRUSH_COOLDOWN (1 SECONDS)

#define HARM_ALARM_NO_SAFETY_COOLDOWN (60 SECONDS)
#define HARM_ALARM_SAFETY_COOLDOWN (20 SECONDS)

#define CHARGER_MODE_DRAW "draw"
#define CHARGER_MODE_CHARGE "charge"

/obj/item/borg
	icon = 'icons/mob/silicon/robot_items.dmi'

/// Cost to use the stun arm
#define CYBORG_STUN_CHARGE_COST (STANDARD_CELL_CHARGE * 0.1)

/obj/item/borg/stun
	name = "electrically-charged arm"
	icon_state = "elecarm"
	COOLDOWN_DECLARE(non_charge_cooldown)

/obj/item/borg/stun/attack(mob/living/attacked_mob, mob/living/user)
	if(ishuman(attacked_mob))
		var/mob/living/carbon/human/human = attacked_mob
		if(human.check_block(src, 0, "[attacked_mob]'s [name]", MELEE_ATTACK))
			playsound(attacked_mob, 'sound/weapons/genhit.ogg', 50, TRUE)
			return FALSE
	if(iscyborg(user))
		var/mob/living/silicon/robot/robot_user = user
		if(!robot_user.cell.use(CYBORG_STUN_CHARGE_COST))
			return

	user.do_attack_animation(attacked_mob)
	attacked_mob.adjust_stutter(10 SECONDS)
	if(ishuman(user) && !COOLDOWN_FINISHED(src, non_charge_cooldown))
		attacked_mob.stamina.adjust(-5)
		attacked_mob.visible_message(span_danger("[user] weakly prods [attacked_mob] with [src]!"), \
					span_userdanger("[user] weakly prods you with [src]!"))
		COOLDOWN_START(src, non_charge_cooldown, 3 SECONDS)
		return

	attacked_mob.stamina.adjust(-50)
	COOLDOWN_START(src, non_charge_cooldown, 5 SECONDS)

	attacked_mob.visible_message(span_danger("[user] prods [attacked_mob] with [src]!"), \
					span_userdanger("[user] prods you with [src]!"))

	playsound(loc, 'sound/weapons/egloves.ogg', 50, TRUE, -1)

	log_combat(user, attacked_mob, "stunned", src, "(Combat mode: [(user.istate & ISTATE_HARM) ? "On" : "Off"])")

/obj/item/borg/cyborghug
	name = "hugging module"
	icon_state = "hugmodule"
	desc = "For when a someone really needs a hug."
	/// Hug mode
	var/mode = HUG_MODE_NICE
	/// Crush cooldown
	COOLDOWN_DECLARE(crush_cooldown)
	/// Shock cooldown
	COOLDOWN_DECLARE(shock_cooldown)
	/// Can it be a stunarm when emagged. Only PK borgs get this by default.
	var/shockallowed = FALSE
	var/boop = FALSE

/obj/item/borg/cyborghug/attack_self(mob/living/user)
	if(iscyborg(user))
		var/mob/living/silicon/robot/robot_user = user
		if(robot_user.emagged && shockallowed == 1)
			if(mode < HUG_MODE_CRUSH)
				mode++
			else
				mode = HUG_MODE_NICE
		else if(mode < HUG_MODE_HUG)
			mode++
		else
			mode = HUG_MODE_NICE
	switch(mode)
		if(HUG_MODE_NICE)
			to_chat(user, "<span class='infoplain'>Power reset. Hugs!</span>")
		if(HUG_MODE_HUG)
			to_chat(user, "<span class='infoplain'>Power increased!</span>")
		if(HUG_MODE_SHOCK)
			to_chat(user, "<span class='warningplain'>BZZT. Electrifying arms...</span>")
		if(HUG_MODE_CRUSH)
			to_chat(user, "<span class='warningplain'>ERROR: ARM ACTUATORS OVERLOADED.</span>")

/obj/item/borg/cyborghug/attack(mob/living/attacked_mob, mob/living/silicon/robot/user, params)
	if(attacked_mob == user)
		return
	if(attacked_mob.health < 0)
		return
	switch(mode)
		if(HUG_MODE_NICE)
			if(isanimal_or_basicmob(attacked_mob))
				var/list/modifiers = params2list(params)
				if (!(user.istate & ISTATE_HARM) && !(user.istate & ISTATE_SECONDARY))
					attacked_mob.attack_hand(user, modifiers) //This enables borgs to get the floating heart icon and mob emote from simple_animal's that have petbonus == true.
				return
			if(user.zone_selected == BODY_ZONE_HEAD)
				user.visible_message(span_notice("[user] playfully boops [attacked_mob] on the head!"), \
								span_notice("You playfully boop [attacked_mob] on the head!"))
				user.do_attack_animation(attacked_mob, ATTACK_EFFECT_BOOP)
				playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE, -1)
			else if(ishuman(attacked_mob))
				if(user.body_position == LYING_DOWN)
					user.visible_message(span_notice("[user] shakes [attacked_mob] trying to get [attacked_mob.p_them()] up!"), \
									span_notice("You shake [attacked_mob] trying to get [attacked_mob.p_them()] up!"))
				else
					user.visible_message(span_notice("[user] hugs [attacked_mob] to make [attacked_mob.p_them()] feel better!"), \
							span_notice("You hug [attacked_mob] to make [attacked_mob.p_them()] feel better!"))
					//MONKESTATION EDIT START
					if(HAS_TRAIT(attacked_mob, TRAIT_FEEBLE))
						feeble_quirk_wound_chest(attacked_mob, hugger=user)
					//MONKESTATION EDIT END
				if(attacked_mob.resting)
					attacked_mob.set_resting(FALSE, TRUE)
			else
				user.visible_message(span_notice("[user] pets [attacked_mob]!"), \
						span_notice("You pet [attacked_mob]!"))
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
		if(HUG_MODE_HUG)
			if(ishuman(attacked_mob))
				attacked_mob.adjust_status_effects_on_shake_up()
				if(attacked_mob.body_position == LYING_DOWN)
					user.visible_message(span_notice("[user] shakes [attacked_mob] trying to get [attacked_mob.p_them()] up!"), \
									span_notice("You shake [attacked_mob] trying to get [attacked_mob.p_them()] up!"))
				else if(user.zone_selected == BODY_ZONE_HEAD)
					user.visible_message(span_warning("[user] bops [attacked_mob] on the head!"), \
									span_warning("You bop [attacked_mob] on the head!"))
					user.do_attack_animation(attacked_mob, ATTACK_EFFECT_PUNCH)
				else
					user.visible_message(span_warning("[user] hugs [attacked_mob] in a firm bear-hug! [attacked_mob] looks uncomfortable..."), \
							span_warning("You hug [attacked_mob] firmly to make [attacked_mob.p_them()] feel better! [attacked_mob] looks uncomfortable..."))
				if(attacked_mob.resting)
					attacked_mob.set_resting(FALSE, TRUE)
			else
				user.visible_message(span_warning("[user] bops [attacked_mob] on the head!"), \
						span_warning("You bop [attacked_mob] on the head!"))
			playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE, -1)
		if(HUG_MODE_SHOCK)
			if (!COOLDOWN_FINISHED(src, shock_cooldown))
				return
			if(ishuman(attacked_mob))
				attacked_mob.electrocute_act(5, "[user]", flags = SHOCK_NOGLOVES)
				user.visible_message(span_userdanger("[user] electrocutes [attacked_mob] with [user.p_their()] touch!"), \
					span_danger("You electrocute [attacked_mob] with your touch!"))
			else
				if(!iscyborg(attacked_mob))
					attacked_mob.adjustFireLoss(10)
					user.visible_message(span_userdanger("[user] shocks [attacked_mob]!"), \
						span_danger("You shock [attacked_mob]!"))
				else
					user.visible_message(span_userdanger("[user] shocks [attacked_mob]. It does not seem to have an effect"), \
						span_danger("You shock [attacked_mob] to no effect."))
			playsound(loc, 'sound/effects/sparks2.ogg', 50, TRUE, -1)
			user.cell.charge -= 500
			COOLDOWN_START(src, shock_cooldown, HUG_SHOCK_COOLDOWN)
		if(HUG_MODE_CRUSH)
			if (!COOLDOWN_FINISHED(src, crush_cooldown))
				return
			if(ishuman(attacked_mob))
				user.visible_message(span_userdanger("[user] crushes [attacked_mob] in [user.p_their()] grip!"), \
					span_danger("You crush [attacked_mob] in your grip!"))
			else
				user.visible_message(span_userdanger("[user] crushes [attacked_mob]!"), \
						span_danger("You crush [attacked_mob]!"))
			playsound(loc, 'sound/weapons/smash.ogg', 50, TRUE, -1)
			attacked_mob.adjustBruteLoss(15)
			user.cell.charge -= 300
			COOLDOWN_START(src, crush_cooldown, HUG_CRUSH_COOLDOWN)

/obj/item/borg/cyborghug/peacekeeper
	shockallowed = TRUE

/obj/item/borg/cyborghug/medical
	boop = TRUE

/obj/item/borg/charger
	name = "power connector"
	desc = "An energy probe that can charge batteries and energy-dependent weapons (using the cyborg battery, in both directions), as well as recharge the cyborg from all types of chargers, APC or even other cyborgs, the effectiveness depends on the components of the machine."
	icon_state = "charger_draw"
	item_flags = NOBLUDGEON
	/// Charging mode
	var/mode = CHARGER_MODE_DRAW
	var/datum/looping_sound/charger/soundloop
	var/busy = FALSE
	/// Whitelist of charging machines
	var/static/list/charge_machines = typecacheof(list(
		/obj/machinery/cell_charger,
		/obj/machinery/cell_charger_multi,
		/obj/machinery/recharger,
		/obj/machinery/recharge_station,
		/obj/machinery/mech_bay_recharge_port,
		/obj/machinery/power/apc,
	))
	/// Whitelist of chargable items
	var/static/list/charge_items = typecacheof(list(
		/obj/item/stock_parts/power_store/cell,
		/obj/item/gun/energy,
		/obj/item/melee/baton/security,
	))

/obj/item/borg/charger/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)

/obj/item/borg/charger/update_icon_state()
	icon_state = "charger_[mode]"
	return ..()

/obj/item/borg/charger/attack_self(mob/user)
	if(mode == CHARGER_MODE_DRAW)
		mode = CHARGER_MODE_CHARGE
	else
		mode = CHARGER_MODE_DRAW
	playsound(src, 'sound/weapons/batonextend.ogg', 50, TRUE)
	to_chat(user, span_notice("You toggle [src] to \"[mode]\" mode."))
	update_appearance()

/obj/item/borg/charger/interact_with_atom(atom/target, mob/living/silicon/robot/user, list/modifiers)
	if(!iscyborg(user))
		return NONE

	. = ITEM_INTERACT_BLOCKING

	if(busy)
		to_chat(user, span_warning("Can not be used while charging!"))
		return
/////	Machines	/////
	if(is_type_in_list(target, charge_machines))
		if(mode == CHARGER_MODE_CHARGE)
			to_chat(user, span_warning("You can't charge [target]"))
			return

		var/obj/machinery/target_machine = target
		if((target_machine.machine_stat & (NOPOWER|BROKEN)) || !target_machine.anchored)
			to_chat(user, span_warning("[target_machine] is unpowered!"))
			return

		var/capacitor_rate = 1
		for(var/datum/stock_part/capacitor/capacitor_parts in target_machine.component_parts)
			if(capacitor_parts)
				capacitor_rate = capacitor_parts.tier

		var/cell_rate = 1
		for(var/obj/item/stock_parts/power_store/cell_parts in target_machine.component_parts)
			if(cell_parts)
				if(istype(cell_parts, /obj/item/stock_parts/power_store/cell))
					cell_rate = cell_parts.chargerate / STANDARD_CELL_RATE * 2
				if(istype(cell_parts, /obj/item/stock_parts/power_store/battery))
					cell_rate = cell_parts.chargerate / STANDARD_BATTERY_RATE * 2

		busy = TRUE
		soundloop.start()
		to_chat(user, span_notice("You connect to [target_machine]'s power line..."))
		while(do_after(user, 1.5 SECONDS, target = target_machine, progress = FALSE))
			if(!user || !user.cell || mode != CHARGER_MODE_DRAW)
				break

			if((target_machine.machine_stat & (NOPOWER|BROKEN)) || !target_machine.anchored)
				break

			target_machine.charge_cell(0.3 * STANDARD_CELL_CHARGE * capacitor_rate * cell_rate, user.cell)
			do_sparks(1, FALSE, target)
			to_chat(user, span_nicegreen("Battery level: <b>[round(user.cell.percent(), 0.1)]%</b>."))

		busy = FALSE
		soundloop.stop()
		to_chat(user, span_notice("You stop charging yourself."))

/////	Cells & Guns	/////
	if(is_type_in_list(target, charge_items))
		var/obj/item/stock_parts/power_store/cell/target_cell = target
		var/charge_ratio = 1

		if(!istype(target_cell))
			target_cell = locate(/obj/item/stock_parts/power_store/cell) in target
		if(!target_cell)
			to_chat(user, span_warning("[target] has no power cell!"))
			return
		if(istype(target, /obj/item/gun/energy))
			var/obj/item/gun/energy/energy_gun = target
			charge_ratio = 3
			if(!energy_gun.can_charge)
				to_chat(user, span_warning("[target] has no power port!"))
				return

		if(mode == CHARGER_MODE_DRAW && !target_cell.charge)
			to_chat(user, span_warning("[target] has no power!"))
			return
		if(mode == CHARGER_MODE_CHARGE && target_cell.charge >= target_cell.maxcharge)
			to_chat(user, span_warning("[target] is already charged!"))
			return

	// Charging process
		busy = TRUE
		soundloop.start()
		to_chat(user, span_notice("You connect to [target]'s power port..."))
		while(do_after(user, 1.5 SECONDS, target = target, progress = FALSE))
			if(!target_cell || !target)
				return
			if(target_cell != target && target_cell.loc != target)
				return
			if(!user || !user.cell)
				return

			if(mode == CHARGER_MODE_DRAW)
				var/draw = min(target_cell.charge, target_cell.chargerate * charge_ratio, user.cell.maxcharge - user.cell.charge)
				if(!target_cell.use(draw))
					break
				if(!user.cell.give(draw))
					break
			else
				var/draw = min(user.cell.charge, target_cell.chargerate * charge_ratio, target_cell.maxcharge - target_cell.charge)
				if(!user.cell.use(draw))
					break
				if(!target_cell.give(draw))
					break

			target.update_appearance()
			do_sparks(1, FALSE, target)
			to_chat(user, span_nicegreen("Battery level: <b>[round(user.cell.percent(), 0.1)]%</b>, [target.name] battery level: <b>[round(target_cell.percent(), 0.1)]%</b>."))

		busy = FALSE
		soundloop.stop()
		to_chat(user, span_notice("You stop charging [mode == CHARGER_MODE_CHARGE ? "[target]" : "yourself"]."))

/////	Cyborgs		/////
	if(istype(target, /mob/living/silicon/robot))
		var/mob/living/silicon/robot/borg = target
		var/charge_ratio = 1

		if(target == user)
			to_chat(user, span_warning("You can't charging yourself!"))
			return
		if(!borg.cell)
			to_chat(user, span_warning("[target] has no power cell!"))
			return
		if(mode == CHARGER_MODE_DRAW && !borg.cell.charge)
			to_chat(user, span_warning("[target] has no power!"))
			return
		if(mode == CHARGER_MODE_CHARGE && borg.cell.charge >= borg.cell.maxcharge - 100)
			to_chat(user, span_warning("[target] is already charged!"))
			return

	// Charging process
		busy = TRUE
		soundloop.start()
		to_chat(user, span_notice("You connect to [target]'s power port..."))
		while(do_after(user, 1.5 SECONDS, target = target, progress = FALSE))
			if(!borg.cell || !target)
				return
			if(borg.cell != target && borg.cell.loc != target)
				return
			if(!user || !user.cell)
				return
			if(get_dist(user, target) > 1)
				to_chat(user, span_notice("Where did he go?"))
				return

			if(mode == CHARGER_MODE_DRAW)
				var/draw = min(borg.cell.charge, borg.cell.chargerate * charge_ratio, user.cell.maxcharge - user.cell.charge)
				if(!borg.cell.use(draw))
					break
				if(!user.cell.give(draw))
					break
			else
				var/draw = min(user.cell.charge, borg.cell.chargerate * charge_ratio, borg.cell.maxcharge - borg.cell.charge)
				if(!user.cell.use(draw))
					break
				if(!borg.cell.give(draw))
					break

			target.update_appearance()
			do_sparks(1, FALSE, target)
			to_chat(user, span_nicegreen("Battery level: <b>[round(user.cell.percent(), 0.1)]%</b>, [target.name] battery level: <b>[round(borg.cell.percent(), 0.1)]%</b>."))

		busy = FALSE
		soundloop.stop()
		to_chat(user, span_notice("You stop charging [mode == CHARGER_MODE_CHARGE ? "[target]" : "yourself"]."))

/obj/item/borg/charger/Destroy()
	QDEL_NULL(soundloop)
	return ..()

/obj/item/harmalarm
	name = "\improper Sonic Harm Prevention Tool"
	desc = "Releases a harmless blast that confuses most organics. For when the harm is JUST TOO MUCH."
	icon = 'icons/obj/device.dmi'
	icon_state = "megaphone"
	/// Harm alarm cooldown
	COOLDOWN_DECLARE(alarm_cooldown)

/obj/item/harmalarm/emag_act(mob/user, obj/item/card/emag/emag_card)
	obj_flags ^= EMAGGED
	if(obj_flags & EMAGGED)
		balloon_alert(user, "safeties shorted")
	else
		balloon_alert(user, "safeties reset")
	return TRUE

/obj/item/harmalarm/attack_self(mob/user)
	var/safety = !(obj_flags & EMAGGED)
	if (!COOLDOWN_FINISHED(src, alarm_cooldown))
		to_chat(user, "<font color='red'>The device is still recharging!</font>")
		return

	if(iscyborg(user))
		var/mob/living/silicon/robot/robot_user = user
		if(!robot_user.cell || robot_user.cell.charge < 1200)
			to_chat(user, span_warning("You don't have enough charge to do this!"))
			return
		robot_user.cell.charge -= 1000
		if(robot_user.emagged)
			safety = FALSE

	if(safety == TRUE)
		user.visible_message("<font color='red' size='2'>[user] blares out a near-deafening siren from its speakers!</font>", \
			span_userdanger("Your siren blares around [iscyborg(user) ? "you" : "and confuses you"]!"), \
			span_danger("The siren pierces your hearing!"))
		for(var/mob/living/carbon/carbon in get_hearers_in_view(9, user))
			if(carbon.get_ear_protection())
				continue
			carbon.adjust_confusion(6 SECONDS)

		audible_message("<font color='red' size='7'>HUMAN HARM</font>")
		playsound(get_turf(src), 'sound/ai/harmalarm.ogg', 70, 3)
		COOLDOWN_START(src, alarm_cooldown, HARM_ALARM_SAFETY_COOLDOWN)
		user.log_message("used a Cyborg Harm Alarm", LOG_ATTACK)
		if(iscyborg(user))
			var/mob/living/silicon/robot/robot_user = user
			to_chat(robot_user.connected_ai, "<br>[span_notice("NOTICE - Peacekeeping 'HARM ALARM' used by: [user]")]<br>")
	else
		user.audible_message("<font color='red' size='7'>BZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZT</font>")
		for(var/mob/living/carbon/carbon in get_hearers_in_view(9, user))
			var/bang_effect = carbon.soundbang_act(2, 0, 0, 5)
			switch(bang_effect)
				if(1)
					carbon.adjust_confusion(5 SECONDS)
					carbon.adjust_stutter(20 SECONDS)
					carbon.adjust_jitter(20 SECONDS)
				if(2)
					carbon.Paralyze(40)
					carbon.adjust_confusion(10 SECONDS)
					carbon.adjust_stutter(30 SECONDS)
					carbon.adjust_jitter(50 SECONDS)
		playsound(get_turf(src), 'sound/machines/warning-buzzer.ogg', 130, 3)
		COOLDOWN_START(src, alarm_cooldown, HARM_ALARM_NO_SAFETY_COOLDOWN)
		user.log_message("used an emagged Cyborg Harm Alarm", LOG_ATTACK)

#undef HUG_MODE_NICE
#undef HUG_MODE_HUG
#undef HUG_MODE_SHOCK
#undef HUG_MODE_CRUSH

#undef HUG_SHOCK_COOLDOWN
#undef HUG_CRUSH_COOLDOWN

#undef HARM_ALARM_NO_SAFETY_COOLDOWN
#undef HARM_ALARM_SAFETY_COOLDOWN

#undef CHARGER_MODE_DRAW
#undef CHARGER_MODE_CHARGE

/obj/item/borg/gambling_plushie
	name = "gambling plushie"
	desc = "Feed it credits and activate it for a chance to win big!"
	icon = 'monkestation/code/modules/blueshift/icons/plushes.dmi' // TODO: robot_items.dmi?
	icon_state = "debug" // TODO: A real sprite.
	w_class = WEIGHT_CLASS_NORMAL
	/// The current amount of money that we will attempt to double.
	var/gambling_money = 0
	/// The cooldown between gambling attempts.
	COOLDOWN_DECLARE(gambling_cooldown)

/obj/item/borg/gambling_plushie/examine(mob/user)
	. = ..()
	. += span_notice("It contains [gambling_money] credits ready to gambled with.")

/obj/item/borg/gambling_plushie/attack_self(mob/user)
	if(!iscyborg(user))
		return
	if(!COOLDOWN_FINISHED(src, gambling_cooldown))
		return
	if(!gambling_money)
		to_chat(user, span_notice("[src] has no money to gamble with."))
		return
	COOLDOWN_START(src, gambling_cooldown, 2 SECONDS)
	user.visible_message(span_notice("[src]'s eyes start spinning!"))
	playsound(src, 'sound/machines/ding_short.ogg', 50)
	addtimer(CALLBACK(src, PROC_REF(reveal_winnings), user), 1 SECONDS)

/obj/item/borg/gambling_plushie/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isitem(interacting_with))
		return NONE
	var/obj/item/depositing_item = interacting_with
	var/gambling_value = depositing_item.get_item_credit_value()
	if(!gambling_value)
		to_chat(user, span_warning("[src] spits out [interacting_with] as it is not worth anything!"))
		return
	gambling_money += gambling_value
	to_chat(user, span_notice("[src] quicky gobbles up [interacting_with] as the value goes up by [gambling_value] credits."))
	playsound(src, 'sound/weapons/bite.ogg', 50)
	qdel(interacting_with)

/// Determines and deals with the outcome of gambling.
/obj/item/borg/gambling_plushie/proc/reveal_winnings(mob/living/gambling_user)
	if(prob(33))
		gambling_user.visible_message(span_notice("[src] cashes out!"))
		playsound(src, 'sound/arcade/win.ogg', 10)
		var/obj/item/holochip/gambling_winnings = new(gambling_user.drop_location(), gambling_money * 2)
		gambling_winnings.throw_at(get_step(loc, pick(GLOB.alldirs)), 3 , 1, gambling_user)
		gambling_money = 0
		return
	gambling_user.visible_message(span_notice("[src] gobbles up all the money!"))
	playsound(src, 'sound/machines/buzz-sigh.ogg', 10, 1)
	gambling_money = 0

/obj/item/borg/disco_dance
	name = "disco dance"
	desc = "Emits an irresistible sound that makes everyone suddenly want to move!"
	icon_state = "disco_dance"
	/// The cooldown between dance attempts.
	COOLDOWN_DECLARE(dance_cooldown)

/obj/item/borg/disco_dance/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, dance_cooldown))
		return
	COOLDOWN_START(src, dance_cooldown, 1.5 SECONDS)
	playsound(src, 'sound/effects/arcade_jump.ogg', 50)
	for(var/mob/hearer in ohearers(7, get_turf(src)))
		if(HAS_TRAIT(hearer, TRAIT_DEAF))
			continue
		switch(rand(1,3))
			if(1)
				INVOKE_ASYNC(hearer, TYPE_PROC_REF(/mob, emote), "flip")
			if(2)
				INVOKE_ASYNC(hearer, TYPE_PROC_REF(/mob, emote), "spin")
			if(3)
				INVOKE_ASYNC(hearer, TYPE_PROC_REF(/mob, emote), "flip")
				INVOKE_ASYNC(hearer, TYPE_PROC_REF(/mob, emote), "spin")

/obj/item/borg/rng
	name = "random number generator"
	desc = "A robot device that allows a synthetic entity to, finally, make random numbers. The future is here."
	icon = 'icons/obj/toys/dice.dmi'
	icon_state = "magicdicebag"
	/// How many sides do we have?
	var/sides
	/// What is the current result?
	var/result
	/// The cooldown between dice attempts.
	COOLDOWN_DECLARE(dice_cooldown)

/obj/item/borg/rng/update_icon()
	if(sides && (sides in list(4, 6, 8, 10, 12, 20, 100)))
		icon = 'icons/obj/toys/dice.dmi'
	else
		icon = initial(icon)
	return ..()

/obj/item/borg/rng/update_icon_state()
	. = ..()
	switch(sides)
		if(4)
			icon_state = "d4"
			return
		if(6)
			icon_state = "d6"
			return
		if(8)
			icon_state = "d8"
			return
		if(10)
			icon_state = "d10"
			return
		if(12)
			icon_state = "d12"
			return
		if(20)
			icon_state = "d20"
			return
		if(100)
			icon_state = "d100"
			return
	icon_state = initial(icon_state)

/obj/item/borg/rng/update_overlays()
	. = ..()
	if(icon_state == initial(icon_state))
		return
	. += "[icon_state]-[result]"

/obj/item/borg/rng/attack_self(mob/user)
	if(!COOLDOWN_FINISHED(src, dice_cooldown))
		return
	if(!sides)
		user.balloon_alert(user, "not configured!")
		return
	COOLDOWN_START(src, dice_cooldown, 1 SECONDS)
	result = rand(1, sides)
	user.visible_message(
		span_notice("\The [user] rolls a virtual [sides]-sided die. The result is [result]."),
		span_notice("You roll a virtual [sides]-sided die. The result is [result]."),
		span_notice("You hear synthesized audio of clattering plastic with a soft ping.")
	)
	user.balloon_alert(user, "rolled: [result]")
	playsound(user, 'sound/effects/diceroll_robotic.ogg', 75, 0)

/obj/item/borg/rng/attack_self_secondary(mob/user, modifiers)
	var/desired_sides = tgui_input_number(user, "Enter how many faces you want your virtual dice to have, (no more than 1000 sides):", "Custom Dice Roll", 4, 1000, 0)
	if(desired_sides <= 0)
		return
	sides = round(desired_sides)
	result = roll(sides)
	user.balloon_alert(user, "selected: [sides]")
	update_appearance()
