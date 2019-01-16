note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_NEW_CONTAINER
inherit
	ETF_NEW_CONTAINER_INTERFACE
		redefine new_container end
create
	make
feature -- Command
	new_container(cid: STRING ; c: TUPLE[material: INTEGER_64; radioactivity: VALUE] ; pid: STRING)
		require else
			new_container_precond(cid, c, pid)
		local
			new_container_oper: NEW_CONTAINER
			zero: VALUE
			ph: PHASE
    	do
			create zero.make_from_int (0)

			if cid.is_empty or not (cid[1].is_alpha or cid[1].is_digit) then
				model.update_msg (model.sts_msg.e5)
			elseif model.get_cid_index(cid) /= 0 then
				model.update_msg (model.sts_msg.e10)
			elseif pid.is_empty or not (pid[1].is_alpha or pid[1].is_digit) then
				model.update_msg (model.sts_msg.e5)
			elseif model.get_pid_index (pid) = 0 then
				model.update_msg (model.sts_msg.e9)
			elseif c.radioactivity.is_less (zero) then
				model.update_msg (model.sts_msg.e18)
			else
				-- find the phase with particular pid
				ph := model.get_phase (pid)
				if ph.phase_count + 1 > ph.capacity then
					model.update_msg (model.sts_msg.e11)
				elseif c.radioactivity > model.tracker.max_container_radiation then
					model.update_msg (model.sts_msg.e14)
				elseif ph.rad_sum.plus (c.radioactivity) > model.tracker.max_phase_radiation.as_double then
					model.update_msg (model.sts_msg.e12)
				elseif not ph.expected_materials.has (convert_index_to_material(c.material)) then
					model.update_msg (model.sts_msg.e13)
				else
					model.new_container (cid, convert_index_to_material(c.material), c.radioactivity, pid)
				end
			end
			model.clear_redo
			create new_container_oper.make (model, cid, convert_index_to_material(c.material), c.radioactivity, pid, model.message)
			model.undo_stk.put (new_container_oper)

			etf_cmd_container.on_change.notify ([Current])
    	end

end
