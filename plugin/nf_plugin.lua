--require "nf_export"
--require "nf_image"
--require "nf_palett"
--require "nf_helpers"
dofile "nf_export.lua"
dofile "nf_image.lua"
dofile "nf_palett.lua"
dofile "nf_helpers.lua"

function init(plugin)
    -- we can use "plugin.preferences" as a table with fields for
    -- our plugin (these fields are saved between sessions)
    if plugin.preferences.count == nil then
        plugin.preferences.count = 0
        plugin.preferences.exportFolder = get_folder_from_path(app.sprite.filename)
        plugin.preferences.formatStr = "16x16"
        plugin.preferences.chrromStartIndex = "0"
    end

    plugin:newCommand{
        id="export_nesfab",
        title="Export as Nesfab png and code",
        group="file_export_1",
        onclick=function()
            start_export(plugin)
        end
    }
end

function exit(plugin)
end

function start_export(plugin)
    local dlg = Dialog()
    dlg:file{ id="exportPath",
            label="Export Path: ",
            title="Select a any file inside the desired export folder",
            filename=plugin.preferences.exportFolder,
            open=true,
            entry=true}
    dlg:entry{ id="fileName",
           label="Export file name (lower case): ",
           text=get_file_name(app.sprite.filename)}

    dlg:combobox{ id="formatStr", label="Format:", option=plugin.preferences.formatStr, options={ "8x8", "16x16" }}
    dlg:entry{ id="chrromStartIndex", label="Chrrom Start Index (hex):", text=""..plugin.preferences.chrromStartIndex}
    dlg:button{ id="cancel", text="Cancel" }
    dlg:button{ id="confirm", text="Confirm" }
    dlg:show()

    local data = dlg.data
    if data.confirm then
        plugin.preferences.exportFolder = get_folder_from_path(data.exportPath)
        plugin.preferences.formatStr = data.formatStr
        plugin.preferences.chrromStartIndex = data.chrromStartIndex

        local chrromStartIndexhex = tonumber(data.chrromStartIndex, 16)
        export_nesfab(plugin.preferences.exportFolder, string.lower(data.fileName), data.formatStr, chrromStartIndexhex)
    end
end