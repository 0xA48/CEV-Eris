/obj
	var/can_buckle = 0
	var/buckle_movable = 0
	var/buckle_dir = 0
	var/buckle_lying = -1 //bed-like behavior, forces mob.lying = buckle_lying if != -1
	var/buckle_require_restraints = 0 //require people to be handcuffed before being able to buckle. eg: pipes
	var/mob/living/buckled_mob = null

/obj/attack_hand(mob/living/user)
	. = ..()
	if(can_buckle && buckled_mob)
		user_unbuckle_mob(user)

/obj/MouseDrop_T(mob/living/M, mob/living/user)
	. = ..()
	if(can_buckle && istype(M))
		user_buckle_mob(M, user)

/obj/Destroy()
	unbuckle_mob()
	return ..()


/obj/proc/buckle_mob(mob/living/M)
	if(!can_buckle || !istype(M) || (M.loc != loc) || M.buckled || M.pinned.len || (buckle_require_restraints && !M.restrained()))
		return 0

	M.buckled = src
	M.facing_dir = null
	M.set_dir(buckle_dir ? buckle_dir : dir)
	M.update_canmove()
	buckled_mob = M
	post_buckle_mob(M)
	return 1

/obj/proc/unbuckle_mob()
	if(buckled_mob && buckled_mob.buckled == src)
		. = buckled_mob
		buckled_mob.buckled = null
		buckled_mob.anchored = initial(buckled_mob.anchored)
		buckled_mob.update_canmove()
		buckled_mob = null

		post_buckle_mob(.)

/obj/proc/post_buckle_mob(mob/living/M)
	return

/obj/proc/user_buckle_mob(mob/living/M, mob/user)
	if(!ticker)
		user << SPAN_WARNING("You can't buckle anyone in before the game starts.")
	if(!user.Adjacent(M) || user.restrained() || user.lying || user.stat || istype(user, /mob/living/silicon/pai))
		return
	if(M == buckled_mob)
		return
	if(isslime(M))
		user << SPAN_WARNING("The [M] is too squishy to buckle in.")
		return

	add_fingerprint(user)
	unbuckle_mob()

	if(buckle_mob(M))
		if(M == user)
			M.visible_message(\
				SPAN_NOTICE("[M.name] buckles themselves to [src]."),\
				SPAN_NOTICE("You buckle yourself to [src]."),\
				SPAN_NOTICE("You hear metal clanking."))
		else
			M.visible_message(\
				SPAN_DANGER("[M.name] is buckled to [src] by [user.name]!"),\
				SPAN_DANGER("You are buckled to [src] by [user.name]!"),\
				SPAN_NOTICE("You hear metal clanking."))

/obj/proc/user_unbuckle_mob(mob/user)
	var/mob/living/M = unbuckle_mob()
	if(M)
		if(M != user)
			M.visible_message(\
				SPAN_NOTICE("[M.name] was unbuckled by [user.name]!"),\
				SPAN_NOTICE("You were unbuckled from [src] by [user.name]."),\
				SPAN_NOTICE("You hear metal clanking."))
		else
			M.visible_message(\
				SPAN_NOTICE("[M.name] unbuckled themselves!"),\
				SPAN_NOTICE("You unbuckle yourself from [src]."),\
				SPAN_NOTICE("You hear metal clanking."))
		add_fingerprint(user)
	return M

