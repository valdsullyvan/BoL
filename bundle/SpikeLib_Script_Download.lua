function Alerte(msg)
	
	PrintChat("<b><font color=\"#c0392b\">[</font><i><font color=\"#27ae60\">Spike</font> <font color=\"#2980b9\">Lib</font><font color=\"#c0392b\">'</font><font color=\"#27ae60\">s</font></i><font color=\"#c0392b\">]</font></b> <font color=\"#c5eff7\"> : " .. msg .. "</font>")
end

function LoadSpikeLib()
	local LibPath = LIB_PATH.."SpikeLib.lua"
	if not FileExist(LibPath) then
		local Host = "raw.github.com"
		local Path = "/spyk1/BoL/master/bundle/SpikeLib.lua".."?rand="..math.random(1,10000)
		Alerte("Not libs found!")
		DownloadFile("https://"..Host..Path, LibPath, function ()  end)
		DelayAction(function () require("SpikeLib") end, 5)
	else
		require("SpikeLib")
		DelayAction(function () Alerte("Loaded Libraries with success!") end, 3)
	end
end

function OnLoad()
  LoadSpikeLib()
end
