--require "nf_image"
--require "nf_palett"
--require "nf_helpers"
dofile "nf_image.lua"
dofile "nf_palett.lua"
dofile "nf_helpers.lua"

function export_nesfab(path, fileName, format_str, chrromStartIndex)
    print("######################################")

    -- Check constraints
    if app.sprite == nil then
        app.alert("No Sprite...")
        return
    elseif app.sprite.width < 8 or app.sprite.height < 8 then
        app.alert("Sprite must be at least 8x8")
        return
    elseif app.sprite.colorMode ~= ColorMode.INDEXED then
        app.alert("Sprite color mode must be Indexed")
        return
    elseif format_str ~= "8x8" and format_str ~= "16x16" then
        app.alert("Format must be '8x8' or '16x16'")
        return
    end


    local format = 0
    local spritePerMeta = 0
    if format_str == "8x8" then
        format = 8
        spritePerMeta = 1
    elseif format_str == "16x16" then
        format = 16
        spritePerMeta = 4
    end

    local paletts = {}
    local spriteDatum = {}
    local pngFileNames = {}
    
    for i,cel in ipairs(app.sprite.cels) do
        local imageFile = fileName.."_"..i..".png"
        table.insert(pngFileNames, imageFile)
        export_image(path..imageFile, spriteDatum, paletts,format, cel.image)
    end

    saveSecondaryData(path, fileName, spriteDatum, pngFileNames, spritePerMeta, chrromStartIndex, #app.sprite.cels > 1)
    savePalett(paletts, path)
end

function export_image(filePath, spriteDatum, paletts, format, image)

    -- Get paletts, then clean up list
    for y=0,image.height-1, 8 do
        for x=0,image.width-1, 8 do
            table.insert(paletts, getPalette8x8(image, x, y))
        end
    end
    cleanupPaletts(paletts)

    if #paletts > 4 then
        app.alert("Found "..#paletts.." discrete paletts. Only 4 are supported for foreground or background")
    end

    local resultImage = prepareImage(spriteDatum, paletts, format, image)
    resultImage:saveAs{ filename=filePath, palette=getExportPalett() } 
end

function saveSecondaryData(path, fileName, spriteDatum, pngFileNames, spritesPerMeta, chrromStartIndex, isAnimation)
    local spriteStr = "data /sprites\n"
    local spriteCount=0
    for sprite_index, spriteData in ipairs(spriteDatum) do
        local metaspriteCount = math.floor(spriteCount / spritesPerMeta)
        if (sprite_index-1) % spritesPerMeta == 0 then
            local suffix = ""
            if isAnimation then suffix = suffix..metaspriteCount end
            spriteStr=spriteStr.."    [] "..fileName..suffix.."\n        (make_metasprite(0, Ms{}(\n"
        end

        spriteStr=spriteStr.."            Ms("..spriteData.indexToCoords[(sprite_index-1) % spritesPerMeta]
        local spriteAddress = chrromStartIndex + metaspriteCount * spritesPerMeta + spriteData.spriteIndex
        spriteStr=spriteStr..string.format("$%02X, $%02X),\n", spriteAddress, spriteData.extraData)

        if (sprite_index-1) % spritesPerMeta == spritesPerMeta - 1 then
            spriteStr = spriteStr:sub(1, -3)
            spriteStr=spriteStr.."\n    )))\n"
        end

        spriteCount = spriteCount + 1
    end

    local animationStr = ""

    if isAnimation then
        animationStr = "\n    [] "..fileName.."_animation\n        (make_anim(Fs{}(\n"
        for metaspriteCount = 0, (#spriteDatum / spritesPerMeta)-1 do
	        local ticks = 60
            animationStr = animationStr.."            Fs("..ticks..", @"..fileName..metaspriteCount.."),\n"
	    end
        animationStr = animationStr.."    )))\n\n"
    end

    local chrromStr = string.format("\nchrrom $%02X0\n", chrromStartIndex)
    for _, pngFileName in ipairs(pngFileNames) do
        chrromStr=chrromStr.."    file(fmt, \""..pngFileName.."\")\n"
    end

    local f = io.open(path..fileName..".fab", "w")
    io.output(f)
    f:write(spriteStr)
    f:write(animationStr)
    f:write(chrromStr)
    io.close(f)
end
