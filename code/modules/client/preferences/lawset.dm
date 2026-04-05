/// Which lawset AIs and masterless cyborgs start with.
/datum/preference/choiced/lawset
	category = PREFERENCE_CATEGORY_NON_CONTEXTUAL
	can_randomize = FALSE
	savefile_identifier = PREFERENCE_CHARACTER
	savefile_key = "preferred_lawset"
	should_update_preview = FALSE

// This is what that #warn wants you to remove :)
/datum/preference/choiced/lawset/deserialize(input, datum/preferences/preferences)
	if (!(input in GLOB.security_depts_prefs))
		return SEC_DEPT_NONE
	return ..(input, preferences)

/datum/preference/choiced/lawset/init_possible_values()
	return GLOB.security_depts_prefs

/datum/preference/choiced/lawset/apply_to_human(mob/living/carbon/human/target, value)
	return

/datum/preference/choiced/lawset/create_default_value()
	return NONE


GLOBAL_LIST_INIT(acceptable_preferred_lawsets, sort_list(list(
	PREFERRED_LAWSET_RANDOM,
	SEC_DEPT_MEDICAL,
	SEC_DEPT_NONE,
	SEC_DEPT_SCIENCE,
	SEC_DEPT_SUPPLY,
)))

GLOBAL_DATUM_INIT(acceptable_preferred_lawset_datum, /datum/preferred_lawset_datum, new)

/datum/preferred_lawset_datum
	var/wawa = FALSE

/datum/preferred_lawset_datum/New()
	var/list/law_ids = CONFIG_GET(keyed_list/random_laws)
	var/list/specified_law_ids = CONFIG_GET(keyed_list/specified_laws)

	var/list/datum/ai_laws/randlaws = list()
	for(var/lpath in subtypesof(/datum/ai_laws))
		var/datum/ai_laws/L = lpath
		if(initial(L.id) in law_ids)
			randlaws += initial(L.id)
