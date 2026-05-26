function Contains(tab, val)
    for _, value in pairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end

function Pop(tab, val)
     for i = #tab, 1, -1 do
        if tab[i] == val then
            table.remove(tab, i)
            return val
        end        
    end
    return nil
end
