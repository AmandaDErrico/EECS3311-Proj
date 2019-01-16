note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_NEW_PHASE
inherit
	ETF_NEW_PHASE_INTERFACE
		redefine new_phase end
create
	make
feature -- Command
	new_phase(pid: STRING ; phase_name: STRING ; capacity: INTEGER_64 ; expected_materials: ARRAY[INTEGER_64])
		require else
			new_phase_precond(pid, phase_name, capacity, expected_materials)
		local
			new_phase_oper: NEW_PHASE
    	do
			if not model.containers.is_empty then
				model.update_msg (model.sts_msg.e1)
			elseif pid.is_empty or not (pid[1].is_alpha or pid[1].is_digit) then
				model.update_msg (model.sts_msg.e5)
			elseif model.get_pid_index (pid) /= 0 then
				model.update_msg (model.sts_msg.e6)
			elseif phase_name.is_empty or not (phase_name[1].is_alpha or phase_name[1].is_digit) then
				model.update_msg (model.sts_msg.e5)
			elseif capacity <= 0 then
				model.update_msg (model.sts_msg.e7)
			elseif convert_material_array(expected_materials).count < 1 then
				model.update_msg (model.sts_msg.e8)
			else
				model.new_phase (pid, phase_name, capacity, convert_material_array(expected_materials))
			end
			create new_phase_oper.make(model, pid, phase_name, capacity, convert_material_array(expected_materials), model.message)
			model.clear_redo
			model.set_undo (new_phase_oper)

			etf_cmd_container.on_change.notify ([Current])
    	end

end
