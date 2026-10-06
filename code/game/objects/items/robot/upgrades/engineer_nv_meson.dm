/obj/item/borg/upgrade/nvmeson
	name = "night vision mesons upgrade"
	desc = "An augmentation to the standard meson sensor array seen on mining and engineering cyborgs to increase low light visibility."
	icon_state = "module_engineer"
	require_model = TRUE
	model_type = list(/obj/item/robot_model/engineering, /obj/item/robot_model/miner)
	model_flags = BORG_MODEL_ENGINEERING

/obj/item/borg/upgrade/nvmeson/action(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	var/datum/action/cooldown/borg_sight_vision/sight_vision_action = borg.model.sight_vision_ref?.resolve()
	if(isnull(sight_vision_action))
		return FALSE
	if(sight_vision_action.given_sight_mode == BORGNVMESON)
		to_chat(user, span_warning("This cyborg already has night vision!"))
		return FALSE

	sight_vision_action.name = "Toggle Night Vision Meson Vision"
	sight_vision_action.button_icon_state = "nvgmeson"
	sight_vision_action.change_sight_mode(BORGNVMESON)
	sight_vision_action.build_all_button_icons()

/obj/item/borg/upgrade/nvmeson/deactivate(mob/living/silicon/robot/borg, user = usr)
	. = ..()
	if(!.)
		return .
	var/datum/action/cooldown/borg_sight_vision/sight_vision_action = borg.model.sight_vision_ref?.resolve()
	if(isnull(sight_vision_action))
		return FALSE
	sight_vision_action.name = initial(sight_vision_action.name)
	sight_vision_action.button_icon_state = initial(sight_vision_action.button_icon_state)
	sight_vision_action.change_sight_mode(initial(sight_vision_action.given_sight_mode))
	sight_vision_action.build_all_button_icons()
