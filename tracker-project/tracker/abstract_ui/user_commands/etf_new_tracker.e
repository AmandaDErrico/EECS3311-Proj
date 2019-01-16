note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_NEW_TRACKER
inherit
	ETF_NEW_TRACKER_INTERFACE
		redefine new_tracker end
create
	make
feature -- Command
	new_tracker(max_phase_radiation: VALUE ; max_container_radiation: VALUE)
		local
			new_tracker_oper: NEW_TRACKER
    	do
			if not model.containers.is_empty then
				-- current tracker is in use
				model.update_msg (model.sts_msg.e1)
			elseif max_phase_radiation < max_phase_radiation.zero then
				model.update_msg (model.sts_msg.e2)
			elseif max_container_radiation < max_container_radiation.zero then
				model.update_msg (model.sts_msg.e3)
			elseif max_phase_radiation < max_container_radiation then
				model.update_msg (model.sts_msg.e4)
			else
				model.new_tracker(max_phase_radiation, max_container_radiation)
			end
			create new_tracker_oper.make (model, max_phase_radiation, max_container_radiation, model.message)
			if model.message ~ model.sts_msg.default_msg then
				model.clear_undo
			end
			model.clear_redo
			model.set_undo (new_tracker_oper)
			etf_cmd_container.on_change.notify ([Current])
    	end

end
