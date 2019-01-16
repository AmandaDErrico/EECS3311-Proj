note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_REDO
inherit
	ETF_REDO_INTERFACE
		redefine redo end
create
	make
feature -- Command
	redo
    	do
			if model.redo_stk.is_empty then
				model.update_msg(model.sts_msg.e20)
			else
				model.redo
			end
			etf_cmd_container.on_change.notify ([Current])
    	end

end
