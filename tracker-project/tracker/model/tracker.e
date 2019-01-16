note
	description: "A default business model."
	author: "Jackie Wang"
	date: "$Date$"
	revision: "$Revision$"

class
	TRACKER

inherit
	ANY
		redefine
			out
		end

create {TRACKER_ACCESS}
	make

feature {NONE} -- Initialization
	make
			-- Initialization for 'Current'.
		do
			state := 0
			dstate := 0
			create dest.make_empty -- to state for undo
			create sts_msg.make_g
			message := sts_msg.default_msg
			create tracker.make
			create phases.make
			create containers.make
			create undo_stk.make(0)
			create redo_stk.make(0)
		end

feature -- model attributes
	message : STRING
	sts_msg: STATUS_MSG
	state, dstate: INTEGER
	dest: STRING
	tracker: TRACKER_PLANT -- max phase and container radiation are stored.
	phases: SORTED_TWO_WAY_LIST[PHASE]
	containers: SORTED_TWO_WAY_LIST[CONTAINOR]
	undo_stk, redo_stk: ARRAYED_STACK[OPERATION]

feature -- queries
	get_phase(m_pid: STRING): PHASE
		require
			pid_exists: get_pid_index(m_pid) /= 0
		local
			ph_int: INTEGER
		do
			ph_int := get_pid_index(m_pid)
			Result := phases.at (ph_int)
		ensure
			Result.pid ~ m_pid
		end

	get_container(m_cid: STRING): CONTAINOR
		require
			m_cid_exists: get_cid_index(m_cid) /= 0
		local
			cid_int: INTEGER
		do
			cid_int := get_cid_index(m_cid)
			Result := containers.at (cid_int)
		end

	get_pid_index(p: STRING): INTEGER
		-- get index of pid to remove
		local
			i: INTEGER
		do
			phases.start
			i := 1
			from
				i := 1
			until
				phases.after
			loop
				if phases.item.pid ~ p then
					Result := i
				end
				i := i + 1
				phases.forth
			end
			if Result > phases.count then
				Result := 0
			end
		end

	get_cid_index(c: STRING): INTEGER
		-- get index of cid to remove
		local
			i: INTEGER
		do
			containers.start
			i := 1
			from
				i := 1
			until
				containers.after
			loop
				if containers.item.cid ~ c then
					Result := i
				end
				containers.forth
				i := i + 1
			end
			if Result > containers.count then
				Result := 0
			end
		end


feature -- model operations
	new_tracker(p_rad: VALUE; cont_rad: VALUE)
		local
			new_tracker_oper: NEW_TRACKER
		do
			create new_tracker_oper.make (Current, p_rad, cont_rad, message)
			new_tracker_oper.execute
		end

	new_phase(m_pid: STRING ; ph_name: STRING; cap: INTEGER_64; exp_materials: ARRAY[STRING])
		local
			new_phase_oper: NEW_PHASE
		do
			create new_phase_oper.make (Current, m_pid, ph_name, cap, exp_materials, message)
			new_phase_oper.execute
		ensure
			phases_count: phases.count = old phases.count + 1 and get_pid_index(m_pid) /= 0
		end

	new_container(m_cid: STRING; mats: STRING; rad: VALUE; m_pid: STRING)
		local
			new_cont_oper: NEW_CONTAINER
		do
			create new_cont_oper.make (Current, m_cid, mats, rad, m_pid, message)
			new_cont_oper.execute
		ensure
			containers_count: containers.count = old containers.count + 1 and get_cid_index(m_cid) /= 0
		end

	remove_container(m_cid: STRING)
		local
			remove_cont_oper: REMOVE_CONTAINER
			container: CONTAINOR
			phase: PHASE
			pid: STRING
		do
			container := get_container (m_cid)
			pid := container.pid -- get phase where container is currently in
			phase := get_phase(pid)
			create remove_cont_oper.make (Current, phase, container, message)
			remove_cont_oper.execute
		ensure
			containers_count: containers.count = old containers.count - 1 and get_cid_index(m_cid) = 0
		end

	remove_phase(m_pid: STRING)
		-- remove phase with specific pid
		local
			remove_phase_oper: REMOVE_PHASE
			phase: PHASE
		do
			phase := get_phase(m_pid)
			create remove_phase_oper.make (Current, phase, message)
			remove_phase_oper.execute
		ensure
			phases_count: phases.count = old phases.count - 1 and get_pid_index(m_pid) = 0
		end

	move_container(m_cid: STRING; m_pid1: STRING; m_pid2: STRING)
		local
			move_cont_oper: MOVE_CONTAINER
			phase1, phase2: PHASE
			s_cont, d_cont: CONTAINOR
		do
			phase1 := get_phase(m_pid1)
			phase2 := get_phase(m_pid2)
			s_cont := get_container(m_cid)
			create d_cont.make (m_cid, s_cont.material, s_cont.radioactivity, m_pid2)
			create move_cont_oper.make (Current, s_cont, d_cont, phase1, phase2, message)
			move_cont_oper.execute
		ensure
			phases_and_container_count: phases.count = old phases.count and containers.count = old containers.count
				and get_pid_index(m_pid1) /= 0 and get_pid_index(m_pid2) /= 0 and get_cid_index(m_cid) /= 0
		end

	undo
		local
			op: OPERATION
		do
			op := undo_stk.item
			undo_stk.remove
			if op.old_msg  /~ sts_msg.e19 then
				redo_stk.put (op)
			end
			if undo_stk.is_empty then
				-- nothing in the stack
				update_dstate(0)
			else
				update_dstate(undo_stk.item.state_num)
			end
			dest.append (" (to " + dstate.out + ")")

			op.undo
			if not undo_stk.is_empty then
				update_msg(undo_stk.item.old_msg)
			end
		end

	redo
		local
			op: OPERATION
		do
			op := redo_stk.item
			redo_stk.remove
			if op.old_msg  /~ sts_msg.e20 then
				undo_stk.put (op)
			end

			update_dstate(undo_stk.item.state_num)
			dest.append (" (to " + dstate.out + ")")
			if op.old_msg ~ sts_msg.default_msg then
				op.redo
			else
				message := op.old_msg
			end
		end


feature -- setters
	set_undo(op: OPERATION)
		do
			undo_stk.put (op)
		end

	clear_undo
		do
			undo_stk.wipe_out
		ensure
			undo_stk.is_empty
		end

	clear_redo
		do
			redo_stk.wipe_out
		ensure
			redo_stk.is_empty
		end

	default_update
			-- Default update to model message = ok.
		do
			message := sts_msg.default_msg
		end

	update_msg(s: STRING)
			-- Perform update to the model message
		do
			message := s
		end

	update_dstate(s: INTEGER)
			-- Perform update to the state, primarily for undo
		do
			dstate := s
		end

	reset
			-- Reset model state.
		do
			make
		end


feature -- Out
	phases_out : STRING
		do
			create Result.make_from_string("%N  phases: pid->name:capacity,count,radiation")
			if not phases.is_empty then
				across phases as ph
				loop
					Result.append("%N    " + ph.item.out)
				end
			end
		end


	containers_out : STRING
		do
			create Result.make_from_string("%N  containers: cid->pid->material,radioactivity")
			if not containers.is_empty then
				across containers as cont
				loop
					Result.append("%N    " + cont.item.out)
				end
			end
		end


	tracker_plant_out : STRING
		-- print out tracker, phases and containers information when there is no error message
		do
			create Result.make_empty
			if message ~ sts_msg.default_msg then
				Result.append ("%N  " + tracker.out + phases_out + containers_out)
			end
		end


	out : STRING
		-- dest only in use for undo and redo, initializes back to 0. No tracker_out when error msg.
		do
			create Result.make_from_string ("  state " + state.out)
			Result.append (dest)
			Result.append (" " + message)
			Result.append (tracker_plant_out)
			state := state + 1
			dest := ""
		end
end






