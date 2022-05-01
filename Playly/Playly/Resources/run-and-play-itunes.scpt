on is_running(appName)
  tell application "System Events" to (name of processes) contains appName
end is_running

if not is_running("iTunes") then
  tell application "iTunes"
    reopen
    play playlist "Music"
  end tell
end if
