note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_REMOVE_PHASE
inherit
	ETF_REMOVE_PHASE_INTERFACE
		redefine remove_phase end
create
	make
feature -- Command
	remove_phase(pid: STRING)
		require else
			remove_phase_precond(pid)
		local
			remove_phase_oper: REMOVE_PHASE
			phase: PHASE
			emp: SET[STRING]
    	do
    		if not model.containers.is_empty then
				model.update_msg(model.sts_msg.e1)
			elseif model.get_pid_index (pid) = 0 then
				model.update_msg (model.sts_msg.e9)
			else
				phase := model.get_phase(pid)
				model.remove_phase (pid)
			end
			model.clear_redo
			if attached phase as p then
				create remove_phase_oper.make (model, p, model.message)
			else
				create emp.make_empty
				create phase.make ("", "", 0, emp)
				create remove_phase_oper.make (model, phase, model.message)
			end
			model.undo_stk.put (remove_phase_oper)

			etf_cmd_container.on_change.notify ([Current])
    	end

end
