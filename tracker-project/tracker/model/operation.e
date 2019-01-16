note
	description: "Summary description for {OPERATION}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	OPERATION

feature -- Attributes
	old_msg: STRING
	state_num: INTEGER
	new_track: BOOLEAN -- indicates when a tracker is in undo_stk

feature -- operations
	execute
		deferred
		end

	undo
		deferred
		end

	redo
		deferred
		end

feature -- helper functions
	set_old_msg(msg: STRING)
		do
			old_msg := msg
		end

	set_old_track(b: BOOLEAN)
		do
			new_track := b
		end
end
