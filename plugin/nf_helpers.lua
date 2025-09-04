function tableContains(table, value)
    if #table > 0 then
        for i = 1,#table do
            if table[i] == value then
                return true
            end
        end
    end
    return false
end

function get_index(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return index
        end
    end

    return -1
end

function get_file_name(path)
    local filename, extension = path:match("^.+/(.+)%.(.+)$")
    return filename
end

function get_folder_from_path(path)
    return path:match("(.*[/\\])")
end
