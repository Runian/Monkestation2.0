
/mob/living/silicon/robot/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	if(pending_model)
		apply_model(pending_model)
		apply_skin(prompt_skin_selection(pending_model, FALSE))
		pending_model = null
	regenerate_icons()
	show_laws(0)
