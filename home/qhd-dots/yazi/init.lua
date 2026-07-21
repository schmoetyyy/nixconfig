require("folder-rules"):setup()



function Entity:icon()
	local icon = self._file:icon()
	if not icon then
		return ""
	end
	return ui.Line(icon.text .. " "):style(icon.style)
end
