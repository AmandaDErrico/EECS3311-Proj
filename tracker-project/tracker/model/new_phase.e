note
	description: "Summary description for {NEW_PHASE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	NEW_PHASE

inherit
	OPERATION

create
	make

feature {NONE} -- Initialization
	make(m: TRACKER; np_id: STRING; np_name: STRING; np_cap: INTEGER_64; np_mats: ARRAY[STRING]; om: STRING)
			-- Initialization for 'Current'.
		do
			tr_model := m
			state_num := tr_model.state
			pid := np_id
			name := np_name
			capacity := np_cap
			create materials.make_from_array (np_mats)
			set_old_msg(om)
			set_old_track(false)
		end

feature -- Attributes
	tr_model: TRACKER
	pid: STRING
	name: STRING
	capacity: INTEGER_64
	materials: ARRAY[STRING]

feature
	execute
		local
			a_phase: PHASE
		do
			create a_phase.make (pid, name, capacity, materials)
			tr_model.phases.extend (a_phase)
			tr_model.default_update
			set_old_msg(tr_model.message)
		end

	undo
		local
			pid_index: INTEGER
		do
			if old_msg ~ tr_model.sts_msg.default_msg then
				pid_index := tr_model.get_pid_index (pid)
				tr_model.phases.go_i_th (pid_index)
				tr_model.phases.remove
				tr_model.update_msg (old_msg)
			else
				tr_model.update_msg(tr_model.sts_msg.default_msg)
			end
		end

	redo
		do
			execute
		end
end
