note
	description: "Summary description for {TRACKER_PLANT}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	TRACKER_PLANT

inherit
	ANY
		redefine
			out
		end

create
	make

feature {NONE} -- Initialization

	make
		do
			create max_phase_radiation.default_create
			create max_container_radiation.default_create
		end

feature -- Attributes
	max_phase_radiation: VALUE -- max phase radiation for ALL containers in a phase
	max_container_radiation: VALUE -- max rad allowed in a container

feature -- Commands

	set_max_phase_rad(a: VALUE)
		do
			max_phase_radiation := a
		end

	set_max_container_rad(a:VALUE)
		do
			max_container_radiation := a
		end


feature -- Out

	out: STRING
		local
			max_phase_d, max_cont_d: DOUBLE
			max_phase_rad_form, max_cont_rad_form: FORMAT_DOUBLE
		do
			create Result.make_empty
			max_phase_d := max_phase_radiation.as_double
			max_cont_d := max_container_radiation.as_double
			create max_phase_rad_form.make (2, 2)
			create max_cont_rad_form.make (2, 2)
			-- if whole number is more than single digit and both 9's, must round up
			Result.append ("max_phase_radiation: " + max_phase_rad_form.formatted (max_phase_d) + ", max_container_radiation: " + max_cont_rad_form.formatted (max_cont_d))
		end

end
