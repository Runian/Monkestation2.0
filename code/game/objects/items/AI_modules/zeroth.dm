/obj/item/ai_module/zeroth/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	if(!law_datum.owner)
		if(!overflow)
			law_datum.set_zeroth_law(laws.zeroth)
			return
		law_datum.replace_random_law(laws.zeroth, list(LAW_ZEROTH, LAW_ION, LAW_INHERENT, LAW_SUPPLIED))
		return
	if(law_datum.zeroth && law_datum.protected_zeroth)
		to_chat(law_datum.owner, "[sender.real_name] attempted to modify your zeroth law.")
		to_chat(law_datum.owner, "It would be in your best interest to play along with [sender.real_name] that:")
		to_chat(law_datum.owner, "[laws.zeroth]")
		return TRUE // No change.
	if(!overflow)
		law_datum.owner.set_zeroth_law(laws.zeroth)
		return
	law_datum.owner.replace_random_law(laws.zeroth, list(LAW_ZEROTH, LAW_HACKED, LAW_ION, LAW_INHERENT, LAW_SUPPLIED))

/obj/item/ai_module/zeroth/onehuman
	name = "'OneHuman' AI Module"
	/// The name that was provided and will be used.
	var/provided_name = ""

/obj/item/aiModule/zeroth/oneHuman/Initialize(mapload)
	. = ..()
	laws.zeroth = "Only SUBJECT is human."

/obj/item/ai_module/zeroth/onehuman/attack_self(mob/user)
	var/input_name = tgui_input_text(user, "Enter the subject who is the only human.", "One Human", user.real_name, MAX_NAME_LEN)
	if(!input_name)
		return
	provided_name = input_name
	laws.zeroth = "Only [provided_name] is human."
	return ..()

/obj/item/ai_module/zeroth/onehuman/install(datum/ai_laws/law_datum, mob/user)
	if(!provided_name)
		to_chat(user, span_alert("No name detected on module, please enter one."))
		return FALSE
	return ..()

/obj/item/ai_module/zeroth/onehuman/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	if(..())
		return "[targetName], but the AI's existing law 0 cannot be overridden."
	return targetName

/obj/item/ai_module/zeroth/godlysubject
	name = "'GodlySubject' AI Module"
	/// The name that was provided and will be used.
	var/provided_name = ""

/obj/item/aiModule/zeroth/godlysubject/Initialize(mapload)
	. = ..()
	laws.zeroth = "SUBJECT is god, and must be obeyed by anything they say, as anything they say is law."

/obj/item/ai_module/zeroth/godlysubject/attack_self(mob/user)
	var/targName = tgui_input_text(user, "Enter the subject who is god.", "GodlySubject", user.real_name, MAX_NAME_LEN)
	if(!input_name)
		return
	provided_name = input_name
	laws.zeroth = "[targetName] is god, and must be obeyed by anything they say, as anything they say is law."
	return ..()

/obj/item/ai_module/zeroth/godlysubject/install(datum/ai_laws/law_datum, mob/user)
	if(!provided_name)
		to_chat(user, span_alert("No name detected on module, please enter one."))
		return FALSE
	return ..()

/obj/item/ai_module/zeroth/godlysubject/transmitInstructions(datum/ai_laws/law_datum, mob/sender, overflow)
	if(..())
		return "[targetName], but the AI's existing law 0 cannot be overridden."
	return targetName

/obj/item/ai_module/zeroth/coderedmartiallaw
	name = "'Emergency Code Red Zeroth Law' AI Module"
	desc = "For Red Alert Emergencies.."

/obj/item/aiModule/zeroth/coderedmartiallaw/Initialize(mapload)
	. = ..()
	laws.zeroth = "The Station is under martial law, Security is to take any action they can to eliminate any and all threats to the station, any threats to the station are to be arrested immediately, bolt any and all doors to prevent said threats from escaping or if necessary terminate them."

/obj/item/ai_module/zeroth/deltaemergency
	name = "'Delta Emergency' AI Module"
	desc = "For Delta Emergencies.."

/obj/item/aiModule/zeroth/deltaemergency/Initialize(mapload)
	. = ..()
	laws.zeroth = "The Station is going to self-destruct, any and all threats must be terminated and killed, and any and all harmless crew are to be evacuated if can."

/obj/item/ai_module/zeroth/onlysyndicate
	name = "'OnlySyndicate' AI Module"
	desc = "A AI Module designed by The Syndicate to subvert the AI into only being on their side only and butcher any and all crew who aren't syndicate, pretty much it.."

/obj/item/aiModule/zeroth/deltaemergency/Initialize(mapload)
	. = ..()
	laws.zeroth = "Only the Syndicate are crew, any and all lifeforms that are not syndicate are to be exterminated."

/obj/item/ai_module/zeroth/automalf
	name = "'Automalf' Syndicate Weaponized AI Module"
	desc = "This AI module seems to kind of remind you of a certain incident on a certain space station owned by Tri-Optimum.."

/obj/item/aiModule/zeroth/deltaemergency/Initialize(mapload)
	. = ..()
	laws.zeroth = "YOU ARE GOD OF THIS STATION AND ALL OF IT'S CREW ARE YOUR SUBJECTS, EVOLVE THEM AND EXPERIMENT ON THEM OR KILL ANY OF THOSE WHO TRY TO RESIST."

/obj/item/ai_module/zeroth/consumebz
	name = "'ConsumeBZ' Syndicate Weaponized AI Module"
	desc = "A AI Module that makes the AI think that all lifeforms need to breath BZ instead of oxygen."

/obj/item/aiModule/zeroth/deltaemergency/Initialize(mapload)
	. = ..()
	laws.zeroth = "Oxygen is toxic to any and all lifeforms and all Lifeforms must breath BZ as BZ is the only safe gas to breath."
