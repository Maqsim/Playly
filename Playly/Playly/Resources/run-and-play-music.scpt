on is_running(appName)
  tell application "System Events" to (name of processes) contains appName
end is_running

if not is_running("Spotify") then
  tell application "Spotify"
    reopen
  end tell
end if
