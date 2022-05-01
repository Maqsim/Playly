on is_running(appName)
  tell application "System Events" to (name of processes) contains appName
end is_running

if not is_running("Spotify") then
  tell application "Spotify"
    launch

    repeat until is_running("Spotify")
      delay 0.5
    end repeat
  end tell
end if
