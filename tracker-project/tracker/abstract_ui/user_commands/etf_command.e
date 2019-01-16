note
	description: "The interface for an input COMMAND"
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	ETF_COMMAND

inherit
	ETF_COMMAND_INTERFACE
		redefine
			make
		end

feature {NONE}
	make(an_etf_cmd_name: STRING; etf_cmd_args: TUPLE; an_etf_cmd_container: ETF_ABSTRACT_UI_INTERFACE)
		local
		  model_access: TRACKER_ACCESS
		do
			Precursor(an_etf_cmd_name, etf_cmd_args, an_etf_cmd_container)
			-- may set your own model state here ...
			model := model_access.m
			materials := <<"glass", "metal", "plastic", "liquid">>
		end

feature -- Attributes
	-- may declare your own model state here
	model : TRACKER
	materials: ARRAY[STRING]

feature -- Queries
	convert_index_to_material(a: INTEGER_64): STRING
		require
			a.to_integer = glass or a.to_integer = metal or a.to_integer = plastic or a.to_integer = liquid
		local
			n: INTEGER
		do
			n := a.to_integer
			Result := materials[n]
		end

	convert_material_array(a: ARRAY[INTEGER_64]): ARRAY[STRING]
		local
			i: INTEGER
		do
			create Result.make_empty
			from
				i := 1
			until
				i > a.upper
			loop
				Result.force (convert_index_to_material(a[i]), i)
				i := i + 1
			end
		end

end
