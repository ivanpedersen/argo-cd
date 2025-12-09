-- ProviderRevision health check
-- Supports both old (Healthy) and new (RevisionHealthy + RuntimeHealthy) condition types
hs = {
  status = "Progressing",
  message = "Installing provider revision..."
}

if obj.status ~= nil and obj.status.conditions ~= nil then
  local hasHealthy = false
  local revisionHealthy = false
  local runtimeHealthy = false
  local degradedMsg = nil

  for i, condition in ipairs(obj.status.conditions) do
    -- Old format: single Healthy condition
    if condition.type == "Healthy" then
      if condition.status == "True" then
        hs.status = "Healthy"
        hs.message = condition.reason or "Provider revision is healthy"
        return hs
      elseif condition.status == "False" then
        hs.status = "Degraded"
        hs.message = condition.message or condition.reason or "Provider revision is unhealthy"
        return hs
      end
    -- New format: separate RevisionHealthy and RuntimeHealthy conditions
    elseif condition.type == "RevisionHealthy" then
      if condition.status == "True" then
        revisionHealthy = true
      elseif condition.status == "False" then
        degradedMsg = condition.message or condition.reason or "Provider revision is unhealthy"
      end
    elseif condition.type == "RuntimeHealthy" then
      if condition.status == "True" then
        runtimeHealthy = true
      elseif condition.status == "False" then
        degradedMsg = condition.message or condition.reason or "Provider runtime is unhealthy"
      end
    end
  end

  -- Handle new format with separate conditions
  if degradedMsg ~= nil then
    hs.status = "Degraded"
    hs.message = degradedMsg
    return hs
  end

  if revisionHealthy and runtimeHealthy then
    hs.status = "Healthy"
    hs.message = "Provider revision is healthy"
    return hs
  end
end

return hs
