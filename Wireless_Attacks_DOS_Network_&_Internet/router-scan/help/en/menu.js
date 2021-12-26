Tree = [
	[1, 1, imgLogo, "Router Scan", [
		[0, imgPage, "About", "main.html"],
		[0, imgPage, "License Agreement", "eula.html"],
		[1, 1, imgFolder, "User's Manual", [
			[0, imgPage, "Introduction", "manual/index.html"],
			[1, 0, imgFolder, "User Interface", [
				[0, imgPage, "Main Window", "manual/gui/winmain.html"],
				[0, imgPage, "Settings", "manual/gui/winsettings.html"],
				[0, imgPage, "Filter Rules", "manual/gui/winfilter.html"],
				[0, imgPage, "Exclusions", "manual/gui/winexclusions.html"],
				[0, imgPage, "WPS PIN Companion", "manual/gui/winwpspin.html"],
				[0, imgPage, "3WiFi Uploader", "manual/gui/winupload.html"],
			]],
			[0, imgPage, "Files description", "manual/files.html"],
			[0, imgPage, "INI configuration", "manual/iniconf.html"],
		]],
		[0, imgPage, "F.A.Q.", "faq.html"],
		[1, 1, imgFolder, "Technical information", [
			[0, imgPage, "Changelog", "changelog.html"],
			[0, imgPage, "Supported devices", "supported.html"],
			[0, imgPage, "Exploit list", "exploits.html"],
		]],
		[1, 0, imgFolder, "For developers", [
			[0, imgPage, "Sources", "sources.html"],
			[1, 0, imgFolder, "LibRouter API", [
				[0, imgPage, "Introduction", "librouter/index.html"],
				[1, 1, imgFolder, "General functions", [
					[0, imgPage, "Initialize", "librouter/Initialize.html"],
					[0, imgPage, "GetParam", "librouter/GetParam.html"],
					[0, imgPage, "SetParam", "librouter/SetParam.html"],
				]],
				[1, 1, imgFolder, "Working with modules", [
					[0, imgPage, "GetModuleCount", "librouter/GetModuleCount.html"],
					[0, imgPage, "GetModuleInfo", "librouter/GetModuleInfo.html"],
					[0, imgPage, "SwitchModule", "librouter/SwitchModule.html"],
					[0, imgPage, "ModuleDesc", "librouter/ModuleDesc.html"],
				]],
				[1, 1, imgFolder, "Callback procedures", [
					[0, imgPage, "WriteLog", "librouter/WriteLog.html"],
					[0, imgPage, "SetTableData", "librouter/SetTableData.html"],
				]],
				[1, 1, imgFolder, "Router processor", [
					[0, imgPage, "PrepareRouter", "librouter/PrepareRouter.html"],
					[0, imgPage, "ScanRouter", "librouter/ScanRouter.html"],
					[0, imgPage, "StopRouter", "librouter/StopRouter.html"],
					[0, imgPage, "IsRouterStopping", "librouter/IsRouterStopping.html"],
					[0, imgPage, "FreeRouter", "librouter/FreeRouter.html"],
				]],
			]],
		]],
	]],
];
