@{
  # Keep the default rule set, but exclude rules that don't fit a setup-orchestrator UX.
  ExcludeRules = @(
    'PSAvoidUsingWriteHost',
    'PSUseSingularNouns'
  )
}

