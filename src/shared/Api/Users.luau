local HttpService = game:GetService("HttpService")

return function ()
    local URL_USERS = "https://nontestable-emory-punningly.ngrok-free.dev/users/"

    -- Make the request to our endpoint URL
    local response = HttpService:GetAsync(URL_USERS)

    if response then
        print(response)
        -- Parse the JSON response
        -- local data = HttpService:JSONDecode(response)
        -- if data then
        --     print("Received data from API:")
        --     print(data)
        -- else
        --     print("Failed to decode JSON response.")
        -- end
    end
end