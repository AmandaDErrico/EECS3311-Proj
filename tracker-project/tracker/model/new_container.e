note
	description: "Summary description for {NEW_CONTAINER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	NEW_CONTAINER

inherit
	OPERATION

create
	make

feature{NONE}
	make(m: TRACKER; nc_id: STRING; nc_mat: STRING; nc_rad: VALUE; nc_pid: STRING; om: STRING)
		do
			tr_model := m
			state_num := tr_model.state
			create cid.make_from_string(nc_id)
			create mat.make_from_string(nc_mat)
			rad := nc_rad
			pid := nc_pid
			set_old_msg(om)
			set_old_track(false)
		end

feature -- attributes
	tr_model: TRACKER
	cid: STRING
	mat: STRING
	rad: VALUE
	pid: STRING

feature
	execute
		local
			ph: PHASE
			cont: CONTAINOR
		do
			ph := tr_model.get_phase (pid)
			tr_model.default_update
			create cont.make (cid, mat, rad, pid)
			ph.phase_containers.extend (cont)
			tr_model.containers.extend (cont)

			set_old_msg(tr_model.message)
		end

	undo
		local
			phase: PHASE
			cid_ph_index, cid_index: INTEGER
		do
			if old_msg ~ tr_model.sts_msg.default_msg then
				phase := tr_model.get_phase (pid)
				cid_ph_index := phase.get_phase_cid_index (cid)
				phase.phase_containers.go_i_th (cid_ph_index)
				phase.phase_containers.remove

				cid_index := tr_model.get_cid_index (cid)
				tr_model.containers.go_i_th (cid_index)
				tr_model.containers.remove

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
