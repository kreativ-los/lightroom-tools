-- Access the Lightroom SDK namespaces.
local LrApplication = import 'LrApplication'
local LrFunctionContext = import 'LrFunctionContext'
local LrBinding = import 'LrBinding'
local LrDialogs = import 'LrDialogs'
local LrView = import 'LrView'
local LrTasks = import 'LrTasks'
local LrLogger = import 'LrLogger'
local myLogger = LrLogger('KreativlosLogger')
myLogger:enable( "logfile" )

function dump(o)
    if type(o) == 'table' then
       local s = '{ '
       for k,v in pairs(o) do
          if type(k) ~= 'number' then k = '"'..k..'"' end
          s = s .. '['..k..'] = ' .. dump(v) .. ','
       end
       return s .. '} '
    else
       return tostring(o)
    end
 end

function tablelength(T)
    local count = 0
    for _ in pairs(T) do count = count + 1 end
    return count
end

local function markImages(imagesFilter)
    local catalog = LrApplication.activeCatalog()
    local collection = catalog:getActiveSources()[1]

    local searchTable = {
        {
            criteria = "collection",
            operation = "all",
            value = collection:getName(),
            value2 = "",
        },
        combine = "intersect",
    }
    
    local filesTable = {
        combine = "union",
    }

    for key, filter in pairs(imagesFilter) do
        table.insert(filesTable, filter)
    end

    table.insert(searchTable, filesTable)

    local foundPhotos = catalog:findPhotos {
        searchDesc = searchTable,
    }

    catalog:withWriteAccessDo("Pick images", function(context)
        for key, photo in pairs(foundPhotos) do
            photo:setRawMetadata('pickStatus', 1)
        end
    end)
end

local function showCustomDialog()
    LrFunctionContext.callWithContext("showCustomDialog", function(context)
        local f = LrView.osFactory()

        -- Create a bindable table.  Whenever a field in this table changes
        -- then notifications will be sent.
        local props = LrBinding.makePropertyTable(context)


        props:addObserver('images', function( properties, key, imageNames )
            local fileNameFilters = {}
            for imageName in imageNames:gmatch("[^\r\n]+") do
                table.insert(fileNameFilters, {
                    criteria = "filename",
                    operation = "beginsWith",
                    value = imageName:match("(.+)%..+$"),
                    value2 = "",
                })
            end

            LrTasks.startAsyncTask(function()
                markImages(fileNameFilters)
            end)

            -- for key, image in pairs(imagesInCollection) do
            --     local name = image.getFormattedMetadata('fileName')
            --     myLogger:debug(name)
            -- end
        end )

        -- Create the contents for the dialog.
        local c = f:row{

            -- Bind the table to the view.  This enables controls to be bound
            -- to the named field of the 'props' table.

            bind_to_object = props,

            -- Add an edit_field.

            f:edit_field{
                height_in_lines = 10,
                placeholder = "Liste von Bildnamen",
                value = LrView.bind('images'),
            }
        }

        LrDialogs.presentModalDialog {title = "Bilder markieren", contents = c}

    end) -- end main function

end

-- Now display the dialogs.
LrTasks.startAsyncTask(showCustomDialog)
