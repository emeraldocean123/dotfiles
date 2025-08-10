@{
    # Example tuned rules; adjust as needed
    Severity = @('Warning','Error')
    ExcludeRules = @(
        # Tighten gradually; examples to suppress noisy rules:
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSAvoidUsingWriteHost'
    )
    Rules = @{
        PSUseConsistentIndentation = @{ Enable = $true; IndentationSize = 4; PipelineIndentation = 'IncreaseIndentationForFirstPipeline' }
        PSUseConsistentWhitespace = @{ Enable = $true; CheckInnerBrace = $true; CheckPipe = $true; CheckOpenBrace = $true; CheckOpenParen = $true; CheckOperator = $true; CheckSeparator = $true }
    }
}
