note
	description: "Summary description for {REMOVE_CONTAINER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	REMOVE_CONTAINER
inherit
	OPERATION
create
	make

feature {NONE}
	make(m: TRACKER; rp: PHASE; rc: CONTAINOR; om: STRING)
		do
			tr_model := m
			state_num := tr_model.state
			phase := rp
			cont := rc
			set_old_msg(om)
			set_old_track(false)
		end

feature -- attributes
	tr_model: TRACKER
	cont: CONTAINOR
	phase: PHASE
feature
	execute
		local
			cid_index, cid_ph_index: INTEGER
		do
			tr_model.default_update
			-- remove container from phase
			cid_index := tr_model.get_cid_index (cont.cid)

			phase := tr_model.get_phase (phase.pid)
			cid_ph_index := phase.get_phase_cid_index (cont.cid)
			phase.phase_containers.go_i_th (cid_ph_index)
			phase.phase_containers.remove

			-- remove container from containers in model
			tr_model.containers.go_i_th (cid_index)
			tr_model.containers.remove

			set_old_msg(tr_model.message)
		end

	undo
		do
			if old_msg ~ tr_model.sts_msg.default_msg then
				phase := tr_model.get_phase (phase.pid)
				phase.phase_containers.extend (cont)
				tr_model.containers.extend (cont)

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
