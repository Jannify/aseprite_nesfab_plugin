function prepareImage(spriteDatum, paletts, format, image)    
    local indexToCoords =
    {
        [0] = "-8, -8, ",
        [1] = " 0, -8, ",
        [2] = "-8,  0, ",
        [3] = " 0,  0, ",
    }

    if image.height == 16 and format == 16 then
        local resultImage = Image(image.width * 2, 8, ColorMode.INDEXED)
        local spriteCount = 0
        for y=0,image.height-1, format do
            for x=0,image.width-1, format do
                local sliceTop = Image(image, Rectangle(x, y, 16, 8))
                convert8x8(spriteDatum, paletts, sliceTop, indexToCoords, spriteCount*2, 0, 0)
                convert8x8(spriteDatum, paletts, sliceTop, indexToCoords, spriteCount*2 + 1, 8, 0)
                
                resultImage:drawImage(sliceTop, Point(spriteCount*16,0))
                spriteCount = spriteCount + 1

                local sliceBot = Image(image, Rectangle(x, y + 8, 16, 8))
                convert8x8(spriteDatum, paletts, sliceBot, indexToCoords, spriteCount*2, 0, 0)
                convert8x8(spriteDatum, paletts, sliceBot, indexToCoords, spriteCount*2 + 1, 8, 0)
                
                resultImage:drawImage(sliceBot, Point(spriteCount*16,0))
                spriteCount = spriteCount + 1
            end
        end

        return resultImage
    elseif image.height == 8 then
        local resultImage = Image(image)
        local spriteCount = 0
        for x=0,image.width-1, 8 do    
            convert8x8(spriteDatum, paletts, resultImage, indexToCoords, spriteCount, x, 0)
            spriteCount = spriteCount + 1
        end
        return resultImage
    else
        app.alert("Sprite height is not 16px or 8px")
    end
end