local _, _, _, P, _ = unpack(ElvUI)

local defaults = {
    healerOnly = false,
    monitorBloodDK = false,
    monitorBrewMonk = false
}

P.hop = {
    enable = false,
    unitframe = {}
}
for _, group in next, {'party', 'raid1', 'raid2', 'raid3'} do
    P.hop.unitframe[group] = CopyTable(defaults)    
end
