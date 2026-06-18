global outputRows
set outputRows to {}

set skipSubmenus to {"Recent Items", "Services", "Open Recent"}

tell application "System Events"
	set frontProc to first application process whose frontmost is true
	tell frontProc
		repeat with topItem in menu bar items of menu bar 1
			set topTitle to my menuText(name of topItem)

			if topTitle is not "" and topTitle is not in {"Apple", "Help"} then
				try
					my collectMenuItems(menu items of menu 1 of topItem, topTitle, 0)
				end try
			end if
		end repeat
	end tell
end tell

return my joinRows(outputRows)

on collectMenuItems(menuItems, pathPrefix, depth)
	global outputRows

	if depth > 6 then return

	tell application "System Events"
		repeat with itemRef in menuItems
			try
				set itemTitle to my menuText(name of itemRef)

				if itemTitle is not "" then
					set fullPath to pathPrefix & " > " & itemTitle

					set cmdChar to missing value
					set cmdGlyph to missing value
					set cmdMods to missing value

					try
						set cmdChar to value of attribute "AXMenuItemCmdChar" of itemRef
					end try
					try
						set cmdGlyph to value of attribute "AXMenuItemCmdGlyph" of itemRef
					end try
					try
						set cmdMods to value of attribute "AXMenuItemCmdModifiers" of itemRef
					end try

					if my hasShortcut(cmdChar, cmdGlyph) then
						set end of outputRows to my cleanCell(cmdChar) & tab & my cleanCell(cmdGlyph) & tab & my cleanCell(cmdMods) & tab & my cleanCell(fullPath) & tab & my cleanCell(itemTitle)
					end if

					if depth < 6 and my shouldRecurseInto(itemTitle) then
						try
							if (count of menus of itemRef) > 0 then
								my collectMenuItems(menu items of menu 1 of itemRef, fullPath, depth + 1)
							end if
						end try
					end if
				end if
			end try
		end repeat
	end tell
end collectMenuItems

on shouldRecurseInto(itemTitle)
	global skipSubmenus

	repeat with skipName in skipSubmenus
		if itemTitle is skipName then return false
	end repeat

	return true
end shouldRecurseInto

on hasShortcut(cmdChar, cmdGlyph)
	if cmdChar is not missing value then
		try
			if (cmdChar as text) is not "" then return true
		end try
	end if

	if cmdGlyph is not missing value then
		try
			if (cmdGlyph as text) is not "" then return true
		end try
	end if

	return false
end hasShortcut

on menuText(valueRef)
	if valueRef is missing value then return ""
	try
		return valueRef as text
	end try
	return ""
end menuText

on cleanCell(valueText)
	if valueText is missing value then return ""

	try
		set valueText to valueText as text
	end try

	set text item delimiters to tab
	set parts to text items of valueText
	set text item delimiters to " "
	set valueText to parts as text

	set text item delimiters to linefeed
	set parts to text items of valueText
	set text item delimiters to " "
	set valueText to parts as text

	set text item delimiters to ""
	return valueText
end cleanCell

on joinRows(rows)
	set text item delimiters to linefeed
	set joinedRows to rows as text
	set text item delimiters to ""
	return joinedRows
end joinRows
