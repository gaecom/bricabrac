note
	description: "Summary description for {WIKI_BLOCKQUOTE}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	WIKI_PREFORMATTED_TEXT

inherit
	WIKI_BOX [WIKI_LINE]
		redefine
			process
		end

create
	make

feature {NONE} -- Initialization

	make (s: STRING)
		require
			s_attached: s /= Void
			s_starts_with_space: s.count > 0 and then s.item (1).is_space
		do
			initialize
			add_element (create {WIKI_LINE}.make (s.substring (2, s.count)))
		end

feature -- Visitor

	process (a_visitor: WIKI_VISITOR)
		do
			a_visitor.process_preformatted_text (Current)
		end

end
