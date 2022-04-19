### Version 1.0.0

```
Initial release.
```

### Version 2.0.0 (10/12/2018)

```
Code rewrite from PowerShell to C# to add flexibility.
Multi threads and multiple shell now sync.
```

### Version 2.0.1 (11/12/2018)

```
Payload generator supports exe.
Custom response headers added.
```

### Version 2.0.2 (11/12/2018)

```
Bug fix.
Auto install dependencies on first run.
```

### Version 2.1.0 (26/12/2018)

```
Bug fix.
Integration of the web interface.
Fixed the coding style (tab vs space). It's not standardized using tabs.
```

### Version 2.1.1 (08/01/2019)

```
Bug fix.
Getting rid of MySQL. ThunderShell only need Redis now even for the syncing.
```

### Version 2.1.2 (11/01/2019)

```
Bug fix.
Fixed payload fetch method from the GUI.
```

### Version 3.0.0 (04/02/2019)

```
What changed:

* Moved from Python v2 to v3.
* Minor GUI change (server info is now in a box instead of top bar).
* New screenshot features for the client.
* All logs can now be viewed from the View Logs feature.
* Removed splash message at initiation (tested on Ubuntu 18.0.4 & Kali).

Known issues:

* 4k monitor not fully captured when using screenshot.
* Multiple monitors not always captured with screenshot. Not sure why (line 64@85 in stager.cs).
* When multiple instances of the client are running on a victim machine, the keylogger seems to send data sporadically.
```

### Version 3.1.0 (02/03/2019)

```
Fixed CSS issues.
Fixed shell command issues.
Code cleaning. Still a lot to be cleaned.
```

### Version 3.1.1 (09/03/2019)

```
Fixing bug in the command parser.
```