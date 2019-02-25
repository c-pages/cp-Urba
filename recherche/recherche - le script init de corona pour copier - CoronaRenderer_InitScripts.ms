(
	-- ===========================================================================================================
	-- General functions.
	-- ===========================================================================================================

	fn isPluginInstalled = (
		classof CoronaRenderer == RendererClass
	)

	fn isMenuRegistered entries = (
		(getINISetting "$plugcfg\\CoronaRendererMenus.ini" entries "registered") == "true"
	)

	fn setMenuRegistered entries registered = (
		setINISetting "$plugcfg\\CoronaRendererMenus.ini" entries "registered" (if registered then "true" else "false")
	)

	fn findItemByName menu itemName = (
		itemIndex = undefined
		for i = 1 to menu.numItems() while itemIndex == undefined do (
			if (menu.getItem i).getTitle() == itemName then (
				itemIndex = i
			)
		)
		itemIndex
	)

	-- ===========================================================================================================
	-- Main menu stuff.
	-- ===========================================================================================================

	-- Note that menu items names used below must be kept in sync with set button texts for Macro Scripts that are
	-- used for the items.

	fn addMainMenuEntries = (
		-- Adds Corona menu before the last "Help" item, if needed.
		local coronaMenu = menuMan.findMenu "Corona"
		if coronaMenu == undefined then (
			coronaMenu = menuMan.createMenu "Corona"
			local coronaItem = menuMan.createSubMenuItem "Corona" coronaMenu
			local mainMenu = menuMan.getMainMenuBar()
			mainMenu.addItem coronaItem (mainMenu.numItems())
		)
		-- Adds Corona Material Library.
		local itemIndex = findItemByName coronaMenu "Material Library"
		if itemIndex == undefined then (
			coronaMenu.addItem (menuMan.createActionItem "CoronaMaterialLibrary" "Corona Renderer") -1
		)
		menuMan.updateMenuBar()
		setMenuRegistered "MainMenuEntries" true
	)

	fn removeMainMenuEntries = (
		local coronaMenu = menuMan.findMenu "Corona"
		if coronaMenu != undefined then (
			-- Removes Corona Material Library.
 			local itemIndex = findItemByName coronaMenu "Material Library"
			if itemIndex != undefined then (
				coronaMenu.removeItemByPosition itemIndex
			)
			-- Removes Corona menu if it is empty. Here we have to be extremely cautious not to break Max installation.
			-- We can unregister a menu only if it is not used as a submenu within some other menu.
			if coronaMenu.numItems() < 1 then (
				local mainMenu = menuMan.getMainMenuBar()
				local itemIndex = findItemByName mainMenu "Corona"
				if itemIndex != undefined then (
					mainMenu.removeItemByPosition itemIndex
					menuMan.unRegisterMenu coronaMenu
				)
			)
			menuMan.updateMenuBar()
			setMenuRegistered "MainMenuEntries" false
		)
	)

	-- ===========================================================================================================
	-- Quad menu stuff.
	-- ===========================================================================================================

	-- Note that menu items names used below must be kept in sync with set button texts for Macro Scripts that are
	-- used for the items.

	fn addQuadMenuEntries = (
		local quadMenu = menuMan.getViewportRightClickMenu #nonePressed
		if quadMenu != undefined then (
			local upperRightMenu = quadMenu.getMenu 1
			if upperRightMenu != undefined then (
				-- Adds leading seperator.
				upperRightMenu.addItem (menuMan.createSeparatorItem()) -1
				-- Adds Corona Proxy Exporter.
				local itemIndex = findItemByName upperRightMenu "Corona Proxy Exporter"
				if itemIndex == undefined then (
					upperRightMenu.addItem (menuMan.createActionItem "CoronaProxyExporter" "Corona Renderer") -1
				)
				-- Adds Corona Converter.
				local itemIndex = findItemByName upperRightMenu "Corona Converter"
				if itemIndex == undefined then (
					upperRightMenu.addItem (menuMan.createActionItem "CoronaConverter" "Corona Renderer") -1
				)
				setMenuRegistered "QuadMenuEntries" true
			)
		)
	)

	fn removeQuadMenuEntries = (
		local quadMenu = menuMan.getViewportRightClickMenu #nonePressed
		if quadMenu != undefined then (
			local upperRightMenu = quadMenu.getMenu 1
			if upperRightMenu != undefined then (
				-- Removes legacy Corona Proxy Exporter.
 				local itemIndex = findItemByName upperRightMenu "Corona proxy exporter"
				if itemIndex != undefined then (
					upperRightMenu.removeItemByPosition itemIndex
				)
				-- Removes Corona Proxy Exporter.
				local itemIndex = findItemByName upperRightMenu "Corona Proxy Exporter"
				if itemIndex != undefined then (
					upperRightMenu.removeItemByPosition itemIndex
				)
				-- Removes Corona Converter.
				local itemIndex = findItemByName upperRightMenu "Corona Converter"
				if itemIndex != undefined then (
					upperRightMenu.removeItemByPosition itemIndex
				)
 				-- Removes a seperator if it is last one there.
				if (upperRightMenu.getItem (upperRightMenu.numItems())).getIsSeparator() then (
					upperRightMenu.removeItemByPosition (upperRightMenu.numItems())
				)
				setMenuRegistered "QuadMenuEntries" false
			)
		)
	)

	-- ===========================================================================================================
	-- Macro Scripts.
	-- ===========================================================================================================

	-- Note that Macro Script names must be kept in sync with paths in the removeMacroScripts() function. Similarly,
	-- button texts set for Macro Scripts must be kept in sync with menu items above where the scripts are used.

	local pluginInstalled = isPluginInstalled()

	if pluginInstalled then (
		macroScript CoronaMaterialLibrary
			category:"Corona Renderer" buttonText:"Material Library" tooltip:"Corona Material Library" (
			CoronaMaterialLibrary.MaterialLibraryFp.showBrowserIfPossible true
		)
	)

	if pluginInstalled then (
		macroScript CoronaConverter
			category:"Corona Renderer" buttonText:"Corona Converter" tooltip:"Corona Mtl/Lights converter" (
			local scriptDirectory = (GetDir #scripts) + "\\CoronaRenderer"
			local scriptFiles = getfiles (scriptDirectory + "\\CoronaConverter_v*.ms")
			if scriptFiles.count > 0 then (
				sort scriptFiles
				local latestFile = scriptFiles[scriptFiles.count]
				filein latestFile
			) else (
				messageBox (@"No CoronaConverter script file found in " + scriptDirectory) title:"Error"
			)
		)
	)

	if pluginInstalled then (
		macroScript CoronaProxyExporter
			category:"Corona Renderer" buttonText:"Corona Proxy Exporter" tooltip:"Corona Proxy Exporter" (
			local scriptDirectory = (GetDir #scripts) + "\\CoronaRenderer"
			local scriptFiles = getfiles (scriptDirectory + "\\coronaProxyExporter_v*.ms")
			if scriptFiles.count > 0 then (
				sort scriptFiles
				local latestFile = scriptFiles[scriptFiles.count]
				filein latestFile
			) else (
				messageBox (@"No CoronaProxyExporter script file found in " + scriptDirectory) title:"Error"
			)
		)
	)

	fn removeMacroScripts = (
		local scriptDirectory = getDir #usermacros
		local scriptFiles = #(
			(scriptDirectory + "\\" + "Corona Renderer-CoronaMaterialLibrary.mcr"),
			(scriptDirectory + "\\" + "corona-corona_proxy_exporter.mcr"),
			(scriptDirectory + "\\" + "Corona Renderer-CoronaConverter.mcr"),
			(scriptDirectory + "\\" + "Corona Renderer-CoronaProxyExporter.mcr")
		)
		for scriptFile in scriptFiles do(
			if doesFileExist scriptFile then (
				try (
					deleteFile scriptFile
				) catch (
				)
			)
		)
	)

	if not pluginInstalled then (
		removeMacroScripts()
	)

	-- ===========================================================================================================
	-- Menu registrations.
	-- ===========================================================================================================

	local mainMenuRegistered = isMenuRegistered "MainMenuEntries"
	if pluginInstalled and not mainMenuRegistered then (
		removeMainMenuEntries()
		addMainMenuEntries()
	)
	if not pluginInstalled and mainMenuRegistered then (
		removeMainMenuEntries()
	)

	local quadMenuRegistered = isMenuRegistered "QuadMenuEntries"
	if pluginInstalled and not quadMenuRegistered then (
		removeQuadMenuEntries()
		addQuadMenuEntries()
	)
	if not pluginInstalled and quadMenuRegistered then (
		removeQuadMenuEntries()
	)
)
