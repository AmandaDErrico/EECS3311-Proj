note
	description: "Summary description for {PHASE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	PHASE
inherit
	ANY
		redefine
			out
		end
	COMPARABLE
		undefine
			out, is_equal
		end

create
	make

feature {NONE} -- Initialization

	make (ppid: STRING; ph_name: STRING; p_cap: INTEGER_64; expected: SET[STRING])
			-- Init for 'Current'.
		do
			pid := ppid
			name := ph_name
			capacity := p_cap
			expected_materials := expected
			create phase_containers.make
		end

feature -- Attributes
	pid: STRING -- phase id
	name: STRING
	capacity: INTEGER_64 -- capacity of containers a phase can accept
	expected_materials: SET[STRING] -- material expected in the current phase
	phase_containers: SORTED_TWO_WAY_LIST[CONTAINOR] -- containers in the current phase

feature -- Queries
	phase_count: INTEGER
		-- number of containers phase currently can accept
		do
			Result := phase_containers.count
		end

	rad_sum: DOUBLE
		-- sum of each container's radioactivity as a double value (for out later in tracker)
		local
			sum: DOUBLE
		do
			sum := 0
			across phase_containers as c
			loop
				Result := Result + c.item.radioactivity.as_double
			end
		end

	is_less alias "<" (other: like Current): BOOLEAN
		do
			Result := pid.is_less (other.pid)
		end

	get_phase_cid_index(a_cid: STRING): INTEGER
		-- get index of cids
		local
			i: INTEGER
		do
			phase_containers.start
			i := 1
			from
				i := 1
			until
				phase_containers.after
			loop
				if phase_containers.item.cid ~ a_cid then
					Result := i
				end
				i := i + 1
				phase_containers.forth
			end
			if Result > phase_containers.count then
				Result := 0
			end
		end

feature -- Out
	out: STRING
		-- string representation of phase
		local
			rad_sum_form: FORMAT_DOUBLE
		do
			create Result.make_empty
			create rad_sum_form.make (2, 2)
			Result.append (pid + "->" + name + ":" + capacity.out + "," + phase_count.out + "," + rad_sum_form.formatted (rad_sum) + ",{")
			across expected_materials as em
			loop
				Result.append (em.item + ",")
			end
			Result.remove_tail (1)
			Result.append ("}")
		end

end
