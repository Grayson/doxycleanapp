(class Controller is NSObject
	(ivar 	(id) PresetsPopupButton
			(id) DeletePresetButton
			(id) RunDoxygenButton
			(id) PresetWindow
			(id) PresetField
			(id) configuration)
	(ivar-accessors)
	
	(- (void) awakeFromNib  is
		(self setConfiguration:(dict))
		
		(if (== nil ((NSWorkspace sharedWorkspace) fullPathForApplication:"Doxygen"))
			((self RunDoxygenButton) setEnabled:NO))
		
		(self updatePresets) )
	
	(- (void) run:(id)sender is
		((sender window) makeFirstResponder:(sender window)) ; Propogate bindings changes
		
		(if (and (== YES ((self configuration) objectForKey:"shouldRunDoxygenFirst") )
				 (!= 0 (((self configuration) objectForKey:"doxygenConfigPath") length) ))
			(set doxygen ((NSWorkspace sharedWorkspace) fullPathForApplication:"Doxygen"))
			(set doxygen (doxygen stringByAppendingPathComponent:"Contents/Resources/doxygen"))
			
			(NSTask launchedTaskWithLaunchPath:doxygen arguments:(array ((self configuration) objectForKey:"doxygenConfigPath"))) )
		
		(set doxyclean ((NSBundle mainBundle) pathForResource:"doxyclean" ofType:"py" inDirectory:"doxyclean"))
		(set args (array 
			"-i" ((self configuration) objectForKey:"pathToXMLFolder") 
			"-o" ((self configuration) objectForKey:"outputPath")
			"-n" ((self configuration) objectForKey:"projectName") ))
		(if (== YES ((self configuration) objectForKey:"shouldOnlyGenerateXML")) (args addObject:"-x"))
		(NSTask launchedTaskWithLaunchPath:doxyclean arguments:args) )
		
	(- (void) deletePreset:(id)sender is
		(set presets ((NSUserDefaults standardUserDefaults) objectForKey:"presets")) 
		(presets removeObjectForKey:((self PresetsPopupButton) titleOfSelectedItem))
		((NSUserDefaults standardUserDefaults) setObject:presets forKey:"presets")
		(self updatePresets)
		(self setConfiguration:(dict)) )
		
	(- (void) saveAsPreset:(id)sender is
		((sender window) makeFirstResponder:(sender window))
		(set NSApp (NSApplication sharedApplication))
		(NSApp beginSheet:(self PresetWindow) modalForWindow:(NSApp mainWindow) modalDelegate:nil didEndSelector:nil contextInfo:nil)
		(NSApp runModalForWindow:(self PresetWindow))
		(NSApp endSheet:(self PresetWindow))
		((self PresetWindow) orderOut:nil) )
	
	(- (void) closePresetNameWindow:(id)sender is
		(set ud (NSUserDefaults standardUserDefaults))
		(set presets (ud objectForKey:"presets"))
		(if (== nil presets) (set presets (dict)))
		(presets setObject:(self configuration) forKey:((self PresetField) stringValue))
		(ud setObject:presets forKey:"presets")
		(self updatePresets)
		((NSApplication sharedApplication) stopModal) )
		
	(- (void) choosePathToXMLFolder:(id) sender is
		(set tmp (self runOpenPanel:NO))
		(if (!= nil tmp) ((self configuration) setObject:tmp forKey:"pathToXMLFolder")) )
	
	(- (void) chooseOutputPath:(id)sender is
		(set tmp (self runOpenPanel:NO))
		(if (!= nil tmp) ((self configuration) setObject:tmp forKey:"outputPath")) )
		
	(- (void) chooseDoxygenConfig:(id)sender is
		(set tmp (self runOpenPanel:YES))
		(if (!= nil tmp) ((self configuration) setObject:tmp forKey:"doxygenConfigPath")) )
	
	(- (void) changePreset:(id)sender is
		(set preset (((NSUserDefaults standardUserDefaults) objectForKey:"presets") objectForKey:(sender titleOfSelectedItem)) )
		(self setConfiguration:preset) )
	
	(- (id) runOpenPanel:(BOOL)canChooseFiles is
		(set op (NSOpenPanel openPanel))
		(if (!= YES canChooseFiles) (op setCanChooseDirectories:YES))
		(op setCanChooseFiles:canChooseFiles)
		(set filename nil)
		(if (> (op runModal) 0)
			(set filename (op filename)) )
		(filename) )
	
	(- (void) updatePresets is
		((self PresetsPopupButton) removeAllItems)
		(set presets (((NSUserDefaults standardUserDefaults) objectForKey:"presets") allKeys) )
		((self PresetsPopupButton) addItemWithTitle:"<<No preset>>")
		(((self PresetsPopupButton) menu) addItem:(NSMenuItem separatorItem))
		((self PresetsPopupButton) addItemsWithTitles:presets) )
)