AddTickCallback(function()
    if myHero:CanUseSpell(_W) == READY and Param.Key then
      CastSpell(_W, myHero)
    end
end)

AddLoadCallback(function()
    Param = scriptConfig("Kappa Galio", "Kappa Galio")
    Param:addParam("Key", "Enable the AutoShield?" , SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("T"))
end)

-- For Identity
