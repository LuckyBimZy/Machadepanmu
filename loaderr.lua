local Library = {}

function Library:CreateWindow(name)
    local Window = {}
    
    function Window:CreateButton(text, callback)
        print("Button Created:", text)
        if callback then
            callback()
        end
    end
    
    return Window
end

return Library