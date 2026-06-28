/obj/item/grenade/hypnotic
	name = "flashbang"
	desc = "A modified flashbang which uses hypnotic flashes and mind-altering soundwaves to induce an instant trance upon detonation."
	icon_state = "flashbang"
	inhand_icon_state = "flashbang"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	var/flashbang_range = 7

/obj/item/grenade/hypnotic/apply_grenade_fantasy_bonuses(quality)
	flashbang_range = modify_fantasy_variable("flashbang_range", flashbang_range, quality)

/obj/item/grenade/hypnotic/remove_grenade_fantasy_bonuses(quality)
	flashbang_range = reset_fantasy_variable("flashbang_range", flashbang_range)

/obj/item/grenade/hypnotic/detonate(mob/living/lanced_by)
	. = ..()
	if(!.)
		return

	update_mob()
	var/flashbang_turf = get_turf(src)
	if(!flashbang_turf)
		return
	do_sparks(rand(5, 9), FALSE, src)
	playsound(flashbang_turf, 'sound/effects/screech.ogg', 100, TRUE, 8, 0.9)
	new /obj/effect/dummy/lighting_obj (flashbang_turf, flashbang_range + 2, 4, LIGHT_COLOR_PURPLE, 2)
	for(var/mob/living/living_mob in get_hearers_in_view(flashbang_range, flashbang_turf))
		bang(get_turf(living_mob), living_mob)
	qdel(src)

/obj/item/grenade/hypnotic/proc/bang(turf/turf, mob/living/living_mob)
	if(living_mob.stat == DEAD) // They're dead!
		return
	var/distance = max(0, get_dist(get_turf(src), turf))

	var/hypno_sound = FALSE // Will they have hallucinations?
	var/paralyze_duration = 0 SECONDS
	var/knockdown_duration = 0 SECONDS

	// Banging.
	if(iscarbon(living_mob))
		var/mob/living/carbon/target = living_mob
		var/list/reflist = list(1)
		SEND_SIGNAL(target, COMSIG_CARBON_SOUNDBANG, reflist)
		var/intensity = reflist[1]
		var/ear_safety = target.get_ear_protection()
		var/effect_amount = intensity - ear_safety
		if(effect_amount > 0)
			hypno_sound = TRUE

	if(!distance || loc == living_mob || loc == living_mob.loc)
		paralyze_duration = max(paralyze_duration, 1 SECONDS)
		knockdown_duration = max(knockdown_duration, 1 SECONDS)
		if(iscarbon(living_mob))
			hypno_sound = TRUE
	else if(distance <= 1)
		paralyze_duration = max(paralyze_duration, 0.5 SECONDS)
		knockdown_duration = max(knockdown_duration, 3 SECONDS)

	if(hypno_sound)
		to_chat(living_mob, span_hypnophrase("The sound echoes in your brain..."))
		living_mob.adjust_hallucinations(100 SECONDS)

	// Flashing.
	if(living_mob.flash_act(affect_silicon = TRUE))
		paralyze_duration = max(paralyze_duration, max(1 SECONDS / max(1, distance), 0.5 SECONDS))
		knockdown_duration = max(knockdown_duration, max(10 SECONDS / max(1, distance), 4 SECONDS))

		if(iscyborg(living_mob))
			var/mob/living/silicon/robot/flashed_cyborg = living_mob
			successfully_flashed = flashed_cyborg.try_standard_flashing(TRUE, FALSE, max(paralyze_duration, knockdown_duration))
			return // Cyborg handles their stuns differently.

		if(iscarbon(living_mob))
			var/mob/living/carbon/target = living_mob
			if(target.hypnosis_vulnerable()) // Hallucinations may allow hypnosis, but other conditions may prevent it (e.g. mindshield).
				target.apply_status_effect(/datum/status_effect/trance, 100, TRUE)
			else
				to_chat(target, span_hypnophrase("The light is so pretty..."))
				target.adjust_drowsiness_up_to(20 SECONDS, 40 SECONDS)
				target.adjust_confusion_up_to(10 SECONDS, 20 SECONDS)
				target.adjust_dizzy_up_to(20 SECONDS, 40 SECONDS)

	if(paralyze_duration)
		living_mob.Paralyze(paralyze_duration)
	if(knockdown_duration)
		living_mob.Knockdown(knockdown_duration)
