indexing
	description	: "Main window for this application"
	author		: "Generated by the New Vision2 Application Wizard."
	date		: "$Date$"
	revision	: "1.0.0"

class
	MAIN_WINDOW

inherit
	EV_WINDOW
		redefine
			initialize,
			is_in_default_state
		end

create
	default_create

feature {NONE} -- Initialization

	initialize is
			-- Build the interface for this window.
		do
			Precursor {EV_WINDOW}
			disable_border

			build_main_container
			extend (main_container)

				-- Execute `request_close_window' when the user clicks
				-- on the cross in the title bar.
			close_request_actions.extend (agent destroy_and_exit_if_last)

				-- Set the title of the window
			set_title (Window_title)

				-- Set the initial size of the window
			show_actions.extend_kamikaze (agent on_resized)
			resize_actions.force_extend (agent on_resized)
			get_arguments
			set_width (400)
		end

	is_in_default_state: BOOLEAN is
			-- Is the window in its default state
			-- (as stated in `initialize')
		do
			Result := Precursor
		end

	get_arguments is
			--
		local
			a: ARGUMENTS
		do
			create a
			if a.argument_count > 0 then
				set_folder_name (a.argument (1))
			end
		end

feature {NONE} -- Implementation

	main_container: EV_HORIZONTAL_BOX
			-- Main container (contains all widgets displayed in this window)

	build_main_container is
			-- Create and populate `main_container'.
		require
			main_container_not_yet_created: main_container = Void
		local
			ib: EV_VERTICAL_BOX
			h: EV_HORIZONTAL_BOX
			b: EV_BUTTON
			da: EV_DRAWING_AREA
			rda: EV_DRAWING_AREA

			vp: EV_VIEWPORT
			f: EV_FIXED
			c: EV_CELL
			colf, colb: EV_COLOR
			ag: PROCEDURE [ANY, TUPLE]
			bgcolor: EV_COLOR
		do
			create bgcolor.make_with_8_bit_rgb (0,90,90)
			create main_container
			main_container.set_border_width (2)
			main_container.set_background_color (bgcolor)

			create c
			c.set_background_color (bgcolor)
			colb := c.foreground_color
			create colf.make_with_8_bit_rgb (255 - colb.red_8_bit, 255 - colb.green_8_bit, 255 - colb.blue_8_bit)

				--| Close drawing area
			create da
			da.set_data ([colf, colb])
			ag := agent (ada: EV_DRAWING_AREA)
					local
						acols: TUPLE [a: EV_COLOR; b: EV_COLOR]
					do
						acols ?= ada.data
						ada.set_data ([acols.b, acols.a])
						ada.redraw
					end(da)
			da.expose_actions.extend (agent draw_close (da,?,?,?,?))
			da.pointer_enter_actions.extend (ag)
			da.pointer_leave_actions.extend (ag)
			da.pointer_button_release_actions.force_extend (agent close_request_actions.call (Void))

				--| Resize drawing area	
			create rda
			rda.set_data ([colf, c.background_color])
			ag := agent (ada: EV_DRAWING_AREA)
					local
						acols: TUPLE [a: EV_COLOR; b: EV_COLOR]
					do
						acols ?= ada.data
						ada.set_data ([acols.b, acols.a])
						ada.redraw
					end(rda)
			rda.expose_actions.extend (agent draw_resize (rda,?,?,?,?))
			rda.pointer_enter_actions.extend (ag)
			rda.pointer_leave_actions.extend (ag)
--			rda.pointer_button_release_actions.force_extend (agent close_request_actions.call (Void))


				--| Fixed area
			create vp
			create f
			f.extend_with_position_and_size (c, 0, 0, f.width, f.height)
			f.extend_with_position_and_size (da, f.width - 2, 2, 8, 8)
			f.extend_with_position_and_size (rda, f.width - 2, f.height - 2, 10, 10)


			create ib
			ib.set_border_width (3)
			ib.set_padding_width (5)

			main_container.extend (ib)
			vp.extend (f)
			vp.set_minimum_width (20)
			vp.resize_actions.extend (agent (avp: EV_VIEWPORT; af: EV_FIXED; awid: EV_CELL; ada, arda: EV_DRAWING_AREA; ax,ay,aw,ah: INTEGER)
					do
						af.set_minimum_size (avp.width, avp.height)
						af.set_item_position (ada, aw - ada.width - 2, 2)
						af.set_item_position (arda, aw - arda.width - 2, ah - arda.height - 2)
						awid.set_minimum_size (aw, ah)
					end (vp, f, c, da, rda, ?,?,?,?)
				)
			main_container.extend (vp)
--			main_container.extend (f)
			main_container.disable_item_expand (vp)

			create h
			h.set_padding_width (5)
			create progress_label.make_with_text ("...")
			progress_label.align_text_right
			progress_label.set_minimum_width (10)
			create remove_folder_checkbox
			h.extend (remove_folder_checkbox)
			h.disable_item_expand (remove_folder_checkbox)
			h.extend (progress_label)
			ib.extend (h)
			ib.disable_item_expand (h)

			create b.make_with_text_and_action ("Erase", agent process_erasing)
			erase_button := b
			h.extend (b)
			h.disable_item_expand (b)

			create error_logs
			ib.extend (error_logs)

			progress_label.file_drop_actions.extend (agent on_files_dropped)
			erase_button.disable_sensitive

			error_logs.set_minimum_height (30)
			ib.set_background_color (create {EV_COLOR}.make_with_8_bit_rgb (255,255,255))
			ib.propagate_background_color

			create moving_grip.make (c, Current)
			moving_grip.enable

			create resize_grip.make (rda, Current)
			resize_grip.enable
--			resize_grip.enable_maximize (agent on_maximize)
		ensure
			main_container_created: main_container /= Void
		end

	moving_grip: WINDOW_MOVING_GRIP
	resize_grip: WINDOW_RESIZING_GRIP

	progress_label: EV_LABEL
	error_logs: EV_TEXT
	remove_folder_checkbox: EV_CHECK_BUTTON
	erase_button: EV_BUTTON

	new_grip (w: EV_WINDOW): EV_WIDGET is
			--
		local
			lw: EV_LABEL
		do
			create lw.make_with_text ("##")
		end

	is_maximized: BOOLEAN
	last_size_position: TUPLE [x: INTEGER; y: INTEGER; w: INTEGER; h: INTEGER]

feature -- Action

	on_maximize (b: BOOLEAN) is
		local
			sc: EV_SCREEN
		do
			if b then
				last_size_position := [x_position, y_position, width, height]
				create sc
				set_position (0, 0)
				set_size (sc.width, sc.height)
				is_maximized := True
			else
				set_size (last_size_position.w, last_size_position.h)
				set_position (last_size_position.x, last_size_position.y)
				last_size_position := Void
				is_maximized := False
			end
		end

	draw_close (ada: EV_DRAWING_AREA; ax,ay,aw,ah: INTEGER) is
			--
		local
			acols: TUPLE [fg: EV_COLOR; bg: EV_COLOR]
		do
			acols ?= ada.data
			ada.set_background_color (acols.bg)
			ada.set_foreground_color (acols.fg)

			ada.clear
			ada.set_line_width (aw // 4)
			ada.draw_straight_line (0,0, aw-1, ah-1)
			ada.draw_straight_line (0,ah-1, aw-1,0)
		end

	draw_resize (ada: EV_DRAWING_AREA; ax,ay,aw,ah: INTEGER) is
			--
		local
			acols: TUPLE [fg: EV_COLOR; bg: EV_COLOR]
		do
			acols ?= ada.data
			ada.set_background_color (acols.bg)
			ada.set_foreground_color (acols.fg)

			ada.clear
			ada.set_line_width (aw // 4)

			if not is_maximized then
				ada.fill_polygon (<<
							create {EV_COORDINATE}.make_precise (0, (ah-1)),
							create {EV_COORDINATE}.make_precise ((aw - 1), 0),
							create {EV_COORDINATE}.make_precise ((aw - 1), (ah -1))
				 		>>
				 	)
			else
				ada.fill_polygon (<<
							create {EV_COORDINATE}.make_precise (0, (ah-1)),
							create {EV_COORDINATE}.make_precise ((aw - 1), 0),
							create {EV_COORDINATE}.make_precise (0, 0)
				 		>>
				 	)
			end
		end

	on_files_dropped (fns: LIST [STRING_32]) is
			--
		local
			fn: STRING
		do
			if fns.count > 0 then
				fn := fns.first
				set_folder_name (fn)
			end
		end

	on_resized is
		do
--			progress_label.set_minimum_width (10) --progress_label.parent.width - 5)
--			progress_label.set_text (progress_label.text)
			progress_label.refresh_now
		end

	set_folder_name (fn: STRING) is
			--
		do
			folder_name := fn
			progress_label.set_text ("Erase %"" + fn + "%" ?")
			remove_folder_checkbox.set_tooltip (progress_label.text)
			progress_label.refresh_now
			enable_process
		end

	folder_name: STRING

	error_count: INTEGER

	process_erasing is
		local
			b: BOOLEAN
			fn: like folder_name
		do
			error_logs.set_text ("Erase folder %"" + folder_name + "%" %N")
			error_count := 0
			b := remove_folder_checkbox.is_selected
			if b then
				fn := rename_folder_to_remove (folder_name)
			else
				fn := folder_name
			end
			erase_folder (fn, not b)
			if error_count > 0 then
				error_logs.append_text ("%N%N" + error_count.out + " error(s) occured.%N")
				error_logs.scroll_to_end
			end
			progress_label.set_text ("Folder %"" + folder_name + "%" erased.%N")
		end

	rename_folder_to_remove (dn: STRING): STRING is
		local
			fn: STRING
			d: DIRECTORY
		do
			if fn = Void then
				create fn.make_from_string (dn)
				fn.append (".to-remove")
				create d.make (dn)
				d.change_name (fn)
				Result := fn
				error_logs.append_text ("%NRenamed as %"" + Result + "%".%N")
			else
				Result := fn
			end
		rescue
			error_logs.append_text ("%NImpossible to rename %"" + dn + "%" into %"" + fn + "%" %N")
			fn := dn
			retry
		end

	enable_process is
		do
			erase_button.enable_sensitive
		end

	erase_folder (fn: STRING; keep_folder: BOOLEAN) is
			--
		local
			dir: DIRECTORY

			l: LINEAR [STRING_8]
			file_name: FILE_NAME
			file: RAW_FILE
			file_count: INTEGER_32
			current_directory: STRING_8
			parent_directory: STRING_8
		do
--			ev_application.process_graphical_events
			ev_application.process_events
			if dir = Void then
				progress_label.set_text (fn)
				progress_label.refresh_now

				create dir.make (fn)
				file_count := 1
				l := dir.linear_representation
				current_directory := "."
				parent_directory := ".."
				from
					l.start
				until
					l.after
				loop
					if not l.item.is_equal (current_directory) and not l.item.is_equal (parent_directory) then
						create file_name.make_from_string (fn)
						file_name.set_file_name (l.item)
						create file.make (file_name)
						if file.exists and then not file.is_symlink and then file.is_directory then
							erase_folder (file_name, False)
						else
							if file.exists then
								progress_label.set_text (file_name)
								progress_label.refresh_now
								erase_file (file)
							end
						end
						file_count := file_count + 1
					end
					l.forth
				end

				if not keep_folder and dir.is_empty and dir.is_writable then
					dir.delete
				end
			end
		rescue
			error_count := error_count + 1
			retry
		end

	erase_file (f: RAW_FILE) is
		require
			f /= Void
			f.exists
		local
			retried: BOOLEAN
		do
			if not retried and then f.is_writable then
				f.delete
			else

			end
		rescue
			error_count := error_count + 1
			error_logs.append_text ("Error: " + f.name + "%N")
			retried := True
			retry
		end

feature {NONE} -- Implementation / Constants

	Window_title: STRING is "Folder Eraser"
			-- Title of the window.

end -- class MAIN_WINDOW
