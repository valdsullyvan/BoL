AddDrawCallback(function()
  DrawText(os.date("%A, %B %d %Y - %X - "..GetLatency().." ms"), 15, WINDOW_W/1.45, WINDOW_W/180, 0xFFFFFFFF);
end);
