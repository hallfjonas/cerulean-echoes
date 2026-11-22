-- Cerulean Echoes: one double-click starts the player (the server in tools/trajectory, which starts SuperCollider
-- when a track plays) and opens it in the browser. Quitting the app (Dock icon: Quit, or Cmd-Q) stops the player and
-- SuperCollider. The work is done by tools/launcher/launch.sh; tools/launcher/build.sh compiles this source into
-- "Cerulean Echoes.app" in the repo folder. No properties or globals, so the applet never rewrites its own file.

-- launch.sh next to this app: <repo>/Cerulean Echoes.app → <repo>/tools/launcher/launch.sh (spaces in the path are fine)
on launcher()
	set appPath to POSIX path of (path to me)
	if appPath ends with "/" then set appPath to text 1 thru -2 of appPath
	set repoPath to do shell script "dirname " & quoted form of appPath
	return quoted form of (repoPath & "/tools/launcher/launch.sh")
end launcher

on run
	set sh to launcher()
	try
		if (do shell script sh & " check") is "install" then
			display notification "First start: installing the player's helpers, about 1-2 minutes." with title "Cerulean Echoes"
			do shell script sh & " install"
		end if
		-- the app's own process id: the started player is stopped also when the app is force quit
		set appPid to do shell script "echo $PPID"
		set started to do shell script sh & " start --watch " & appPid
		set opened to do shell script sh & " open"
	on error errText
		display alert "Cerulean Echoes cannot start" message errText as critical
		quit
		return
	end try
	-- no notifications when started without a browser (the launcher's test)
	if started is "running" then
		if opened is "opened" then display notification "The player was already running: opened it in the browser." with title "Cerulean Echoes"
		quit
	else if opened is "opened" then
		display notification "The player runs. To stop it, quit Cerulean Echoes (Dock icon: Quit)." with title "Cerulean Echoes"
	end if
end run

-- double-click again, or a click on the Dock icon
on reopen
	set sh to launcher()
	try
		set address to do shell script sh & " url"
		set choice to button returned of (display dialog "The player runs at " & address & ". Keep only one browser tab of it open." buttons {"Stop", "Open player"} default button "Open player" with title "Cerulean Echoes" giving up after 120)
	on error
		return
	end try
	if choice is "Stop" then
		quit
	else if choice is "Open player" then
		try
			do shell script sh & " open"
		end try
	end if
end reopen

-- every 5 s: did the player end by itself?
on idle
	try
		do shell script launcher() & " alive"
	on error errText number code
		if code is 1 then
			display alert "The player stopped" message "Start Cerulean Echoes again. Details: ~/Library/Logs/cerulean-echoes.log" as warning
			quit
		end if
	end try
	return 5
end idle

on quit
	try
		do shell script launcher() & " stop"
	end try
	continue quit
end quit
