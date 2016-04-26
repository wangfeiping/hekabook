require "os"

local counter = 0

function process_message ()
    local payload = read_message("Payload")
    add_to_payload(payload)
    
    counter = counter + 1
    
    inject_payload("txt", "filter")
    
    return 0
end

function timer_event(ns)
    add_to_payload(getOsTimeString(), " counter=", counter, "\n")
    inject_payload("txt", "hekadlog")
end

-- 获得的统一是格林威治时间，所以需要设置一个偏移量以保证获得当前系统的正确时间
function getOsTimeString()
    return os.date("%Y-%m-%d %H:%M:%S", os.time() + 28800)
end
