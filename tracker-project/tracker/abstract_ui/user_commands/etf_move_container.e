note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_MOVE_CONTAINER
inherit
	ETF_MOVE_CONTAINER_INTERFACE
		redefine move_container end
create
	make
feature -- Command
	move_container(cid: STRING ; pid1: STRING ; pid2: STRING)
		require else
			move_container_precond(cid, pid1, pid2)
		local
			move_cont_oper: MOVE_CONTAINER
			source_cont, dest_cont: CONTAINOR
			source, dest: PHASE
			zero: VALUE
			emp: SET[STRING]
    	do
    		if model.get_cid_index (cid) = 0 then
				model.update_msg (model.sts_msg.e15)
			elseif pid1 ~ pid2 then
				model.update_msg (model.sts_msg.e16)
			elseif (model.get_pid_index (pid1) = 0) or (model.get_pid_index (pid2) = 0) then
				model.update_msg (model.sts_msg.e9)
			else
				-- since cid, pid1, pid2 are all valid attributes
				source_cont := model.get_container (cid)
				create dest_cont.make (cid, source_cont.material, source_cont.radioactivity, pid2)
				source := model.get_phase (pid1)
				dest := model.get_phase (pid2)

				if source.get_phase_cid_index (cid) = 0 then
					model.update_msg (model.sts_msg.e17)
				elseif dest.phase_count + 1 > dest.capacity then
					model.update_msg (model.sts_msg.e11)
				elseif dest.rad_sum + source_cont.radioactivity > model.tracker.max_phase_radiation then
					model.update_msg (model.sts_msg.e12)
				elseif not dest.expected_materials.has (source_cont.material) then
					model.update_msg (model.sts_msg.e13)
				else
					model.move_container (cid, pid1, pid2)
				end
			end
			model.clear_redo
			if attached source_cont as c1 and then attached dest_cont as c2 and then attached source as s
					and then attached dest as d and then model.message ~ model.sts_msg.default_msg then
				create move_cont_oper.make(model, c1, c2, s, d, model.message)
			else
				create zero.make_from_int (0)
				create emp.make_empty
				create source_cont.make ("", "", zero, "")
				create dest_cont.make ("", "", zero, "")
				create source.make ("", "", -1, emp)
				create dest.make ("", "", -1, emp)
				create move_cont_oper.make(model, source_cont, dest_cont, source, dest, model.message)
			end
			model.undo_stk.put (move_cont_oper)
			etf_cmd_container.on_change.notify ([Current])
    	end

end
