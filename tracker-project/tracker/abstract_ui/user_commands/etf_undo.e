note
	description: ""
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	ETF_UNDO
inherit
	ETF_UNDO_INTERFACE
		redefine undo end
create
	make
feature -- etf Command
	undo
    	do
    		-- Undo checks for size = 1. Two cases: The model's message is the defult or undo/redo error messages or it's not. If it is not the
    		-- default or e19 or e20 then this is the case where New_Tracker (or any other class) has an error message caught in the ETF class.
    		-- This means we call model.undo, where New_Tracker's undo will be called and the initial state of Tracker is reset. If the message
    		-- is default or e19 or e20, then we must check if the item on top is New_Tracker. If it is, then there is no more to undo, else we
    		-- undo on each effective class that are not New_Tracker.
			if model.undo_stk.count = 1 then
				if model.message ~ model.sts_msg.default_msg or model.message ~ model.sts_msg.e20 or model.message ~ model.sts_msg.e19 then -- not redo either, since we cannot compare old_msg
			    	if model.undo_stk.item.new_track then
						model.update_msg(model.sts_msg.e19) -- new_tracker in top of undo_stk, or undo_stk is empty
					else
						model.undo
					end
				else
					model.undo
				end

			-- If the undo_stk is empty in the first place, then there is no more to undo
			else if model.undo_stk.is_empty then
				model.update_msg(model.sts_msg.e19) -- undo_stk is empty

			-- If there are many items in the stack the undo normally
			else
				model.undo
			end


    	end
		etf_cmd_container.on_change.notify ([Current])

		end
end
