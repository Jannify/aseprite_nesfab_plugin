function getPalette8x8(image, x, y)
    local pallet = {0}
    local pallet_len = 1
    for it in image:pixels(Rectangle(x, y, 8, 8)) do
        local pixelValue = it()

        if pixelValue > 64 then
            pixelValue = -1
            pallet[pallet_len] = pixelValue
        else
            local p_index = get_index(pallet, pixelValue)
            if p_index == -1 then
                pallet_len = pallet_len + 1
                local p_index = pallet_len
                pallet[p_index] = pixelValue
            end
        end
    end

    if pallet_len > 4 then
        app.alert("Area from ["..x..", "..y.."] to ["..(x+8)..", "..(y+8).."] has more than 3 colors")
    end
    return pallet
end

function convert8x8(spriteDatum, paletts, image, indexToCoords, sprite_number, x, y)
    local entry = {}
    entry.palettIndex = setPalette8x8(paletts, image, x, y)
    entry.spriteIndex = sprite_number
    entry.indexToCoords = indexToCoords
    entry.extraData = (entry.palettIndex - 1) -- Flip and palett information
    table.insert(spriteDatum, entry)
end

function setPalette8x8(paletts, image, x, y)
    local colors = {}
    for it in image:pixels(Rectangle(x, y, 8, 8)) do
        local pixelValue = it()
        if not tableContains(colors, pixelValue) then
            table.insert(colors, pixelValue)
        end
    end

    local paletteIndex = getSamePalettIndexInPaletts(paletts, colors)
    if paletteIndex == -1 then
        app.alert("Could not find palett for square")
        return -1
    end

    for it in image:pixels(Rectangle(x, y, 8, 8)) do
        local pixelValue = it()
        local p_index = get_index(paletts[paletteIndex], pixelValue)
        it(p_index - 1)
    end

    return paletteIndex
end


function cleanupPaletts(paletts)
    for paletts_index, paletts_entry in ipairs(paletts) do
        local i = paletts_index + 1
        while i <= #paletts do
            local isSame = true
            for _, paletts_entry_color in ipairs(paletts[i]) do
                if not tableContains(paletts_entry, paletts_entry_color) then
                    isSame = false
                    break
                end
            end
            if isSame and #paletts > 1 then
                table.remove(paletts, i)
            else
                i = i + 1
            end
        end
    end
end

function getSamePalettIndexInPaletts(paletts, pal)
    local returnValue = -1
    for paletts_index, paletts_entry in ipairs(paletts) do
        for __, pal_color in ipairs(pal) do
            if not tableContains(paletts_entry, pal_color) then
                returnValue = -1
                break
            end
            returnValue = paletts_index
        end
    end

    return returnValue
end

function savePalett(paletts, filePath)
    local palettStr = [[ct U[25] sprite_palette = U[25](
    $32, $01, $02, //Background Palett 1
    $03, $21, $3B, //Background Palett 2
    $15, $23, $31, //Background Palett 3
    $17, $25, $33, //Background Palett 4
    
]]
    for i=1,4 do
        if i <= #paletts then
            palettStr=palettStr.."    "
            for ii=2,#(paletts[i]) do
            palettStr=palettStr..string.format("$%02X, ", paletts[i][ii])
            end
            palettStr= palettStr.."\n"
        else
            palettStr=palettStr.."    $64, $64, $64,  //Not used\n"
        end
    end
    palettStr=palettStr.."\n    $0F)\n\n"

    local f1 = io.open(filePath.."palett.fab", "w")
    io.output(f1)
    f1:write(palettStr)
    io.close(f1)

    local f2 = io.open(filePath.."palett.json", "w")
    io.output(f2)
    f2:write(json.encode(paletts))
    io.close(f2)
end

function getExportPalett()
    local basic_palette = Palette(4)
    basic_palette:setColor(0, Color{ r=0, g=0, b=0, a=0 }) 
    basic_palette:setColor(1, Color{ r=255, g=0, b=0 }) 
    basic_palette:setColor(2, Color{ r=0, g=255, b=0 }) 
    basic_palette:setColor(3, Color{ r=0, g=0, b=255 })
    return basic_palette
end