# Prevent upload failures when Solid Queue tables are unavailable.
# Analyze/Purge jobs run inline as a safe fallback.
ActiveSupport.on_load(:after_initialize) do
  ActiveStorage::AnalyzeJob.queue_adapter = :inline
  ActiveStorage::PurgeJob.queue_adapter = :inline
end
