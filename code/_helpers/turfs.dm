// Returns the atom sitting on the turf.
// For example, using this on a disk, which is in a bag, on a mob, will return the mob because it's on the turf.
/proc/get_atom_on_turf(var/atom/movable/M)
	var/atom/mloc = M
	while(mloc && mloc.loc && !istype(mloc.loc, /turf/))
		mloc = mloc.loc
	return mloc

/proc/iswall(turf/T)
	return (istype(T, /turf/simulated/wall) || istype(T, /turf/unsimulated/wall))

/proc/isfloor(turf/T)
	return (istype(T, /turf/simulated/floor) || istype(T, /turf/unsimulated/floor))


//Edit by Nanako
//This proc is used in only two places, ive changed it to make more sense
//The old behaviour returned zero if there were any simulated atoms at all, even pipes and wires
//Now it just finds if the tile is blocked by anything solid.
/proc/turf_clear(turf/T)
	if (T.density)
		return 0
	for(var/atom/A in T)
		if(A.density)
			return 0
	return 1

/proc/get_random_turf_in_range(var/atom/origin, var/outer_range, var/inner_range)
	origin = get_turf(origin)
	if(!origin)
		return
	var/list/turfs = list()
	for(var/turf/T in orange(origin, outer_range))
		if(!(T.z in current_map.sealed_levels)) // Picking a turf outside the map edge isn't recommended
			if(T.x >= world.maxx-TRANSITIONEDGE || T.x <= TRANSITIONEDGE)
				continue
			if(T.y >= world.maxy-TRANSITIONEDGE || T.y <= TRANSITIONEDGE)
				continue
		if(!inner_range || get_dist(origin, T) >= inner_range)
			turfs += T
	if(turfs.len)
		return pick(turfs)

// This proc will check if a neighboring tile in the stated direction "dir" is dense or not
// Will return 1 if it is dense and zero if not
/proc/check_neighbor_density(turf/T, var/dir)
	if (!T.loc)
		CRASH("The Turf has no location!")
	switch (dir)
		if (NORTH)
			return !turf_clear(get_turf(locate(T.x, T.y+1, T.z)))
		if (NORTHEAST)
			return !turf_clear(get_turf(locate(T.x+1, T.y+1, T.z)))
		if (EAST)
			return !turf_clear(get_turf(locate(T.x+1, T.y, T.z)))
		if (SOUTHEAST)
			return !turf_clear(get_turf(locate(T.x+1, T.y-1, T.z)))
		if (SOUTH)
			return !turf_clear(get_turf(locate(T.x, T.y-1, T.z)))
		if (SOUTHWEST)
			return !turf_clear(get_turf(locate(T.x-1, T.y-1, T.z)))
		if (WEST)
			return !turf_clear(get_turf(locate(T.x-1, T.y, T.z)))
		if (NORTHWEST)
			return !turf_clear(get_turf(locate(T.x-1, T.y+1, T.z)))
		else return

// Picks a turf without a mob from the given list of turfs, if one exists.
// If no such turf exists, picks any random turf from the given list of turfs.
/proc/pick_mobless_turf_if_exists(var/list/start_turfs)
	if(!start_turfs.len)
		return null

	var/list/available_turfs = list()
	for(var/start_turf in start_turfs)
		var/mob/M = locate() in start_turf
		if(!M)
			available_turfs += start_turf
	if(!available_turfs.len)
		available_turfs = start_turfs
	return pick(available_turfs)

/proc/turf_contains_dense_objects(var/turf/T)
	return T.contains_dense_objects()

/proc/not_turf_contains_dense_objects(var/turf/T)
	return !turf_contains_dense_objects(T)

/proc/is_station_turf(var/turf/T)
	return T && isStationLevel(T.z)

/proc/is_below_sound_pressure(var/turf/T)
	var/datum/gas_mixture/environment = T ? T.return_air() : null
	var/pressure =  environment ? environment.return_pressure() : 0
	if(pressure < SOUND_MINIMUM_PRESSURE)
		return TRUE
	return FALSE
