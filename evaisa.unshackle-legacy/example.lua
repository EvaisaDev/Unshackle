RegisterFunction("Save", function(filePath, data)
    print("Saving data to file ["..filePath.."]: "..tostring(data))
    local file,err = io.open(filePath,'w')
    if file then
        file:write(tostring(data))
        file:close()
    else
        print("error:", err) -- not so hard?
    end
end)