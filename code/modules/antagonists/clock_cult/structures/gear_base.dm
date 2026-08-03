/obj/structure/destructible/clockwork/gear_base
	name = "gear base"
	desc = "A large cog lying on the floor at feet level."
	icon_state = "gear_base"
	clockwork_desc = "A large cog lying on the floor at feet level."
	anchored = FALSE
	break_message = span_warning("Oh, that broke.")
	/// The string that will be appended to the initial icon_state when unanchored.
	var/unwrenched_suffix = "_unwrenched"
	/// Can this structure be wrenched? Unwrenched structures can be moved.
	var/can_unwrench = TRUE

/obj/structure/destructible/clockwork/gear_base/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/clockwork_structure_info)

/obj/structure/destructible/clockwork/gear_base/wrench_act(mob/living/user, obj/item/tool)
	if(!IS_CLOCK(user))
		return ITEM_INTERACT_BLOCKING
	if(!can_unwrench)
		balloon_alert(user, "cannot be unwrenched!")
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "[anchored ? "unwrenching" : "wrenching"]...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 50))
		return ITEM_INTERACT_BLOCKING
	visible_message(span_notice("[user] [anchored ? "unwrenches" : "wrenches down"] [src]."), span_notice("You [anchored ? "unwrench" : "wrench"] [src]."))
	anchored = !anchored
	update_icon_state()
	return ITEM_INTERACT_SUCCESS

/obj/structure/destructible/clockwork/gear_base/update_icon_state()
	. = ..()
	icon_state = base_icon_state || initial(icon_state)
	if(!anchored)
		icon_state += unwrenched_suffix
