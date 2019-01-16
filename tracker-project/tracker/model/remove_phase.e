note
	description: "Summary description for {REMOVE_PHASE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REMOVE_PHASE

inherit
	OPERATION

create
	make

feature {NONE} -- Init

	make(m: TRACKER; rp: PHASE; om: STRING)
			-- Initialization for 'Current'.
		do
			tr_model := m
			state_num := tr_model.state
			phase := rp
			set_old_msg(om)
			set_old_track(false)
		end

feature -- Attributes
	phase: PHASE
	tr_model: TRACKER

feature
	execute
		local
			ph_index: INTEGER
		do
			-- only when containers are removed can phase be removed
			tr_model.default_update

			ph_index := tr_model.get_pid_index (phase.pid)
			tr_model.phases.go_i_th (ph_index)
			tr_model.phases.remove

			set_old_msg(tr_model.message)
		end

	undo
		do
			if old_msg ~ tr_model.sts_msg.default_msg then
				tr_model.phases.extend (phase)
				tr_model.update_msg (old_msg)
			else
				tr_model.update_msg (tr_model.sts_msg.default_msg)
			end

		end

	redo
		do
			execute
		end

end
