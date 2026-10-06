/obj/item/borg/upgrade/panel_access_remover
	name = "cyborg firmware hack"
	desc = "Used to override the default firmware of a cyborg and disable panel access restrictions."
	icon_state = "cyborg_upgrade2"
	one_use = TRUE

/obj/item/borg/upgrade/panel_access_remover/action(mob/living/silicon/robot/R, user = usr)
	R.req_access = list()
	R.req_one_access = list()
	return TRUE //Makes sure we delete the upgrade since it's one_use

/obj/item/borg/upgrade/panel_access_remover/freeminer
	name = "free miner cyborg firmware hack"
	desc = "Used to override the default firmware of a cyborg with the freeminer version."
	icon_state = "cyborg_upgrade2"

/obj/item/borg/upgrade/panel_access_remover/freeminer/action(mob/living/silicon/robot/R, user = usr)
	R.req_access = list()
	R.req_one_access = list(ACCESS_AWAY_ENGINEERING, ACCESS_AWAY_SCIENCE)
	new /obj/item/borg/upgrade/panel_access_remover/freeminer(R.drop_location())
	//This deletes the upgrade which is why we create a new one. This prevents the message "Upgrade Error" without a adding a once-used variable to every board
	return TRUE
