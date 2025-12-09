-- Function health check - looks at the active FunctionRevision status
hs = {
  status = "Progressing",
  message = "Installing function..."
}

if obj.status ~= nil and obj.status.conditions ~= nil then
  for i, condition in ipairs(obj.status.conditions) do
    if condition.type == "Healthy" then
      if condition.status == "True" then
        hs.status = "Healthy"
        hs.message = condition.reason or "Function is healthy"
        return hs
      elseif condition.status == "False" then
        hs.status = "Degraded"
        hs.message = condition.message or condition.reason or "Function is unhealthy"
        return hs
      else
        hs.status = "Progressing"
        hs.message = condition.message or condition.reason or "Function health status unknown"
        return hs
      end
    end
  end
end

return hs
