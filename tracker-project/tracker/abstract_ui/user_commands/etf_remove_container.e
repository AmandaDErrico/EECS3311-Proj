note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_REMOVE_CONTAINER
inherit
	ETF_REMOVE_CONTAINER_INTERFACE
		redefine remove_container end
create
	make
feature -- Command
	remove_container(cid: STRING)
		require else
			remove_container_precond(cid)
		local
			remove_container_oper: REMOVE_CONTAINER
			container: CONTAINOR
			phase: PHASE
			pid: STRING
			zero: VALUE
			e: SET[STRING_8]
    	do
    		if model.get_cid_index (cid) = 0 then
				model.update_msg (model.sts_msg.e15)
			else
				container := model.get_container (cid)
				pid := container.pid -- get phase where container is currently in
				phase := model.get_phase(pid)
				model.remove_container (cid)
			end
			model.clear_redo
			if attached phase as p and then attached container as c then
				create remove_container_oper.make (model, p, c, model.message)
			else
				create zero.make_from_int (0)
				create e.make_empty
				create phase.make ("", "", -1, e)
				create container.make ("", "", zero, "")
				create remove_container_oper.make (model, phase, container, model.message)
			end

			model.set_undo (remove_container_oper)

			etf_cmd_container.on_change.notify ([Current])
    	end

end
