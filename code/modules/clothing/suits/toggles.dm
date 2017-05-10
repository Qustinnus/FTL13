//Hoods for winter coats and chaplain hoodie etc

/obj/item/clothing/suit/hooded
	actions_types = list(/datum/action/item_action/toggle_hood)
	var/obj/item/clothing/head/hood
	var/hoodtype = /obj/item/clothing/head/winterhood //so the chaplain hoodie or other hoodies can override this
	var/click_cooldown = 0

/obj/item/clothing/suit/hooded/New()
	MakeHood()
	..()

/obj/item/clothing/suit/hooded/Destroy()
	qdel(hood)
	return ..()

/obj/item/clothing/suit/hooded/proc/MakeHood()
	if(!hood)
		var/obj/item/clothing/head/W = new hoodtype(src)
		hood = W

/obj/item/clothing/suit/hooded/ui_action_click()
	ToggleHood()

/obj/item/clothing/suit/hooded/item_action_slot_check(slot, mob/user)
	if(slot == slot_wear_suit)
		return 1

/obj/item/clothing/suit/hooded/equipped(mob/user, slot)
	if(slot != slot_wear_suit)
		RemoveHood()
	..()

/obj/item/clothing/suit/hooded/proc/RemoveHood()
	src.icon_state = "[initial(icon_state)]"
	suittoggled = 0
	if(ishuman(hood.loc))
		var/mob/living/carbon/H = hood.loc
		H.unEquip(hood, 1)
		H.update_inv_wear_suit()
	hood.loc = src
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/suit/hooded/dropped()
	..()
	RemoveHood()

/obj/item/clothing/suit/hooded/proc/ToggleHood()
	if(world.time < click_cooldown)
		return
	click_cooldown = world.time + 5
	if(!suittoggled)
		if(ishuman(src.loc))
			var/mob/living/carbon/human/H = src.loc
			if(H.wear_suit != src)
				to_chat(H, "<span class='warning'>You must be wearing [src] to put up the hood!</span>")
				return
			if(H.head)
				to_chat(H, "<span class='warning'>You're already wearing something on your head!</span>")
				return
			else if(H.equip_to_slot_if_possible(hood,slot_head,0,0,1))
				suittoggled = 1
				src.icon_state = "[initial(icon_state)]_t"
				H.update_inv_wear_suit()
				for(var/X in actions)
					var/datum/action/A = X
					A.UpdateButtonIcon()
	else
		RemoveHood()

//Toggle exosuits for different aesthetic styles (hoodies, suit jacket buttons, etc)

/obj/item/clothing/suit/toggle/AltClick(mob/user)
	..()
	if(!user.canUseTopic(src, be_close=TRUE))
		to_chat(user, "<span class='warning'>You can't do that right now!</span>")
		return
	else
		suit_toggle(user)

/obj/item/clothing/suit/toggle/ui_action_click()
	suit_toggle()

/obj/item/clothing/suit/toggle/proc/suit_toggle()
	set src in usr

	if(!can_use(usr))
		return 0

	if(togglename)
		to_chat(usr, "<span class='notice'>You toggle [src]'s [togglename].</span>")
	else
		to_chat(usr, "<span class='notice'>You toggle [src].</span>")

	if(src.suittoggled)
		src.icon_state = "[initial(icon_state)]"
		src.suittoggled = 0
	else if(!src.suittoggled)
		src.icon_state = "[initial(icon_state)]_t"
		src.suittoggled = 1
	usr.update_inv_wear_suit()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/suit/toggle/examine(mob/user)
	..()
	if(togglename)
		to_chat(user, "Alt-click on [src] to toggle the [togglename].")
	else
		to_chat(user, "Alt-click on [src] to toggle it.")

//Hardsuit toggle code
/obj/item/clothing/suit/space/hardsuit
	var/click_cooldown

/obj/item/clothing/suit/space/hardsuit/New()
	MakeHelmet()
	..()

/obj/item/clothing/suit/space/hardsuit/Destroy()
	if(helmet)
		helmet.suit = null
		qdel(helmet)
	qdel(jetpack)
	return ..()

/obj/item/clothing/head/helmet/space/hardsuit/Destroy()
	if(suit)
		suit.helmet = null
	return ..()

/obj/item/clothing/suit/space/hardsuit/proc/MakeHelmet()
	if(!helmettype)
		return
	if(!helmet)
		var/obj/item/clothing/head/helmet/space/hardsuit/W = new helmettype(src)
		W.suit = src
		helmet = W

/obj/item/clothing/suit/space/hardsuit/ui_action_click()
	..()
	ToggleHelmet()

/obj/item/clothing/suit/space/hardsuit/equipped(mob/user, slot)
	if(!helmettype)
		return
	if(slot != slot_wear_suit)
		RemoveHelmet()
	..()

/obj/item/clothing/suit/space/hardsuit/proc/RemoveHelmet(sound, tint)
	if(!helmet)
		return
	suittoggled = 0
	if(ishuman(helmet.loc))
		var/mob/living/carbon/H = helmet.loc
		if(helmet.on)
			helmet.attack_self(H)
		H.unEquip(helmet, 1)
		H.update_inv_wear_suit()
		to_chat(H, "<span class='notice'>The helmet on the hardsuit disengages.</span>")
		if(!sound)
			playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
		else
			playsound(src.loc, sound, 50, 1)
		if(tint)
			H.update_tint()
	helmet.loc = src

/obj/item/clothing/suit/space/hardsuit/dropped()
	..()
	RemoveHelmet()

/obj/item/clothing/suit/space/hardsuit/proc/ToggleHelmet(sound, tint)
	if(world.time < click_cooldown)
		return
	click_cooldown = world.time + 5
	var/mob/living/carbon/human/H = src.loc
	if(!helmettype)
		return
	if(!helmet)
		return
	if(!suittoggled)
		if(ishuman(src.loc))
			if(H.wear_suit != src)
				to_chat(H, "<span class='warning'>You must be wearing [src] to engage the helmet!</span>")
				return
			if(H.head)
				to_chat(H, "<span class='warning'>You're already wearing something on your head!</span>")
				return
			else if(H.equip_to_slot_if_possible(helmet,slot_head,0,0,1))
				to_chat(H, "<span class='notice'>You engage the helmet on the hardsuit.</span>")
				suittoggled = 1
				H.update_inv_wear_suit()
				if(!sound)
					playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, 1)
				else
					playsound(src.loc, sound, 50, 1)
				if(tint)
					H.update_tint()
	else
		if(!sound && !tint)
			RemoveHelmet()
		if(sound && !tint)
			RemoveHelmet(sound)
		if(sound && tint)
			RemoveHelmet(tint)
