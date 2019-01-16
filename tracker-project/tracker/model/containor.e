note
	description: "Summary description for {CONTAINOR}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	CONTAINOR
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

	make (ccid: STRING ; cmaterial: STRING; cradioactivity: VALUE; cpid: STRING)
			-- Initialization for 'Current'.
		do
			cid := ccid
			material := cmaterial
			radioactivity := cradioactivity
			pid := cpid
		end

feature -- Attributes
	cid: STRING -- container id
	material: STRING
	radioactivity: VALUE
	pid: STRING -- location of container

feature -- Queries
	is_less alias "<" (other: like Current): BOOLEAN
		do
			Result := cid.is_less (other.cid)
		end

	out: STRING
		local
			rad: DOUBLE
			rad_form: FORMAT_DOUBLE
		do
			create Result.make_empty
			rad := radioactivity.as_double
			create rad_form.make (2, 2)
			Result.append(cid + "->" + pid + "->" + material + "," + rad_form.formatted (rad))
		end

end
