function Contains(tab, val)
    for _, value in pairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
