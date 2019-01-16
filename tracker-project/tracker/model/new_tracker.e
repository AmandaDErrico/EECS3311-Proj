note
	description: "Summary description for {NEW_TRACKER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	NEW_TRACKER

inherit
	OPERATION

create
	make

feature {NONE} -- Initialization

	make(m: TRACKER; a_max_phase_rad: VALUE ; a_max_cont_rad: VALUE; om: STRING)
			-- Initialization for 'Current'.
		do
			tr_model := m
			state_num := tr_model.state
			phase_r := a_max_phase_rad
			container_r := a_max_cont_rad
			set_old_msg(om)
			set_old_track(true)
		end


feature -- attributes
	tr_model: TRACKER
	phase_r: VALUE
	container_r: VALUE


feature -- Commands
	execute
		do
			tr_model.tracker.set_max_phase_rad (phase_r)
			tr_model.tracker.set_max_container_rad (container_r)
			tr_model.default_update

			set_old_msg(tr_model.message)
		end


	undo
		local
			zero: VALUE
		do
			if old_msg  /~ tr_model.sts_msg.default_msg and tr_model.undo_stk.is_empty then
				create zero.make_from_int (0)
				tr_model.update_msg(tr_model.sts_msg.default_msg)
				tr_model.tracker.set_max_phase_rad (zero)
				tr_model.tracker.set_max_container_rad (zero)
			else
				tr_model.update_msg (old_msg)
			end

		end


	redo
		do
			execute
		end
end
