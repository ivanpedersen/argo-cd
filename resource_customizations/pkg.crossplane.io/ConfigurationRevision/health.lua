-- ConfigurationRevision health check
-- Supports both old (Healthy) and new (RevisionHealthy) condition types
hs = {
  status = "Progressing",
  message = "Installing configuration revision..."
}

if obj.status ~= nil and obj.status.conditions ~= nil then
  for i, condition in ipairs(obj.status.conditions) do
    -- Check for both Healthy (older versions) and RevisionHealthy (newer versions)
    if condition.type == "Healthy" or condition.type == "RevisionHealthy" then
      if condition.status == "True" then
        hs.status = "Healthy"
        hs.message = condition.reason or "Configuration revision is healthy"
        return hs
      elseif condition.status == "False" then
        hs.status = "Degraded"
        hs.message = condition.message or condition.reason or "Configuration revision is unhealthy"
        return hs
      end
    end
  end
end

return hs
