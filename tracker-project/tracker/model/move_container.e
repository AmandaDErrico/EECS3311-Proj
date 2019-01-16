note
	description: "Summary description for {MOVE_CONTAINER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	MOVE_CONTAINER

inherit
	OPERATION

create
	make

feature {NONE}
	make(m: TRACKER; sc: CONTAINOR; dc: CONTAINOR; p1: PHASE; p2: PHASE; om: STRING)
		do
			tr_model := m
			state_num := tr_model.state
			source_cont := sc
			dest_cont := dc
			phase1:= p1
			phase2 := p2
			set_old_msg(om)
			set_old_track(false)
		end

feature -- attributes.
	tr_model: TRACKER
	phase1, phase2: PHASE
	source_cont, dest_cont: CONTAINOR

feature
	execute
		local
			cid_s_index, cid_index: INTEGER
		do
			tr_model.default_update
			phase1 := tr_model.get_phase (phase1.pid)
			-- remove the cid from source phase	
			cid_s_index := phase1.get_phase_cid_index (source_cont.cid)
			phase1.phase_containers.go_i_th (cid_s_index)
			phase1.phase_containers.remove

			-- delete from models
			cid_index := tr_model.get_cid_index (source_cont.cid)
			tr_model.containers.go_i_th (cid_index)
			tr_model.containers.remove

			-- add the container, but with the dest phase and add back to tr_model with new pid
			phase2 := tr_model.get_phase (phase2.pid)
			phase2.phase_containers.extend (dest_cont)
			tr_model.containers.extend (dest_cont)

			set_old_msg(tr_model.message)
		end

	undo
		local
			cid_d_index, cid_index: INTEGER
		do
			if old_msg ~ tr_model.sts_msg.default_msg then
				-- remove the cid from dest phase	
				phase2 := tr_model.get_phase (phase2.pid)
				cid_d_index := phase2.get_phase_cid_index (dest_cont.cid)
				phase2.phase_containers.go_i_th (cid_d_index)
				phase2.phase_containers.remove

				-- delete from models
				cid_index := tr_model.get_cid_index (dest_cont.cid)
				tr_model.containers.go_i_th (cid_index)
				tr_model.containers.remove

				-- add the container, but bck to the source phase and add back to tr_model with new pid
				phase1 := tr_model.get_phase (phase1.pid)
				phase1.phase_containers.extend (source_cont)
				tr_model.containers.extend (source_cont)
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
