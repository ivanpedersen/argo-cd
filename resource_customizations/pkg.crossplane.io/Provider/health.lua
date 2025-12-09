-- Provider health check - looks at the active ProviderRevision status
-- Supports both old format (Installed + Healthy) and new format (single Healthy condition)
local hs = {}
if obj.status ~= nil then
  if obj.status.conditions ~= nil then
    -- Check for both old and new formats
    local installed = false
    local healthy = false
    local installed_message = ""
    local healthy_message = ""
    local hasInstalledCondition = false
    
    for i, condition in ipairs(obj.status.conditions) do
      if condition.type == "Installed" then
        hasInstalledCondition = true
        installed = condition.status == "True"
        installed_message = condition.reason or ""
      elseif condition.type == "Healthy" then
        if condition.status == "True" then
          healthy = true
          healthy_message = condition.reason or ""
        elseif condition.status == "False" then
          healthy = false
          healthy_message = condition.message or condition.reason or ""
        elseif condition.status == "Unknown" then
          -- Unknown status means progressing (for new format)
          if not hasInstalledCondition then
            hs.status = "Progressing"
            hs.message = condition.message or condition.reason or "Provider health status unknown"
            return hs
          end
        end
      end
    end
    
    -- If we found an Installed condition, use old format logic
    if hasInstalledCondition then
      if installed and healthy then
        hs.status = "Healthy"
      else
        hs.status = "Degraded"
      end
      hs.message = installed_message .. " " .. healthy_message
      return hs
    end
    
    -- Otherwise use new format (single Healthy condition)
    if healthy_message ~= "" then
      if healthy then
        hs.status = "Healthy"
        hs.message = healthy_message
        return hs
      else
        hs.status = "Degraded"
        hs.message = healthy_message
        return hs
      end
    end
  end
end

hs.status = "Progressing"
hs.message = "Waiting for provider to be installed"
return hs
