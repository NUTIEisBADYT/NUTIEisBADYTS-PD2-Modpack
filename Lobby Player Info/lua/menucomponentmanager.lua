local lpi_original_menucomponentmanager_mousedoubleclick = MenuComponentManager.mouse_double_click
function MenuComponentManager:mouse_double_click(o, button, x, y)
	if self._contract_gui then
		return self._contract_gui:mouse_double_click(o, button, x, y)
	end
	return lpi_original_menucomponentmanager_mousedoubleclick(self, o, button, x, y)
end
