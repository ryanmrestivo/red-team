Tree = [
	[1, 1, imgLogo, "Router Scan", [
		[0, imgPage, "О проекте", "main.html"],
		[0, imgPage, "Лицензионное соглашение", "eula.html"],
		[1, 1, imgFolder, "Руководство по эксплуатации", [
			[0, imgPage, "Введение", "manual/index.html"],
			[1, 0, imgFolder, "Навигация по интерфейсу", [
				[0, imgPage, "Главное окно", "manual/gui/winmain.html"],
				[0, imgPage, "Настройки", "manual/gui/winsettings.html"],
				[0, imgPage, "Правила фильтрации", "manual/gui/winfilter.html"],
				[0, imgPage, "Исключения сканирования", "manual/gui/winexclusions.html"],
				[0, imgPage, "Помощник WPS PIN", "manual/gui/winwpspin.html"],
				[0, imgPage, "Загрузчик 3WiFi", "manual/gui/winupload.html"],
			]],
			[0, imgPage, "Описание файлов", "manual/files.html"],
			[0, imgPage, "Настройки в INI файле", "manual/iniconf.html"],
		]],
		[0, imgPage, "Часто задаваемые вопросы", "faq.html"],
		[1, 1, imgFolder, "Техническая информация", [
			[0, imgPage, "История изменений", "changelog.html"],
			[0, imgPage, "Поддерживаемые устройства", "supported.html"],
			[0, imgPage, "Список эксплойтов", "exploits.html"],
		]],
		[1, 0, imgFolder, "Для разработчиков", [
			[0, imgPage, "Исходные коды", "sources.html"],
			[1, 0, imgFolder, "LibRouter API", [
				[0, imgPage, "Введение", "librouter/index.html"],
				[1, 1, imgFolder, "Основные функции", [
					[0, imgPage, "Initialize", "librouter/Initialize.html"],
					[0, imgPage, "GetParam", "librouter/GetParam.html"],
					[0, imgPage, "SetParam", "librouter/SetParam.html"],
				]],
				[1, 1, imgFolder, "Работа с модулями", [
					[0, imgPage, "GetModuleCount", "librouter/GetModuleCount.html"],
					[0, imgPage, "GetModuleInfo", "librouter/GetModuleInfo.html"],
					[0, imgPage, "SwitchModule", "librouter/SwitchModule.html"],
					[0, imgPage, "ModuleDesc", "librouter/ModuleDesc.html"],
				]],
				[1, 1, imgFolder, "Обратная связь", [
					[0, imgPage, "WriteLog", "librouter/WriteLog.html"],
					[0, imgPage, "SetTableData", "librouter/SetTableData.html"],
				]],
				[1, 1, imgFolder, "Обработчик роутеров", [
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
