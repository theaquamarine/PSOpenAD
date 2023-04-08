. ([IO.Path]::Combine($PSScriptRoot, 'common.ps1'))

BeforeDiscovery {
	$commands = Get-Command -Module PSOpenAD
}

Describe "Help for <_>" -ForEach $commands {
	BeforeDiscovery {
		$parameters = $_.Parameters.GetEnumerator() | Select-Object -ExpandProperty Key |
			Where-Object {$_ -notin [System.Management.Automation.PSCmdlet]::CommonParameters} |
			Where-Object {$_ -notin [System.Management.Automation.PSCmdlet]::OptionalCommonParameters}
		$outputTypes = $_ | Select-Object -expand OutputType
	}

	BeforeAll {
		$command = $_
		$help = Get-Help $command -ErrorAction SilentlyContinue
	}

	It "Should exist" {
		$help | Should -Not -BeNullOrEmpty
	}

	It "Should have a synopsis" {
		$help.synopsis | Should -Not -BeNullOrEmpty
	}

	It "Should have a description" {
		$help.description | Should -Not -BeNullOrEmpty
	}

	Context "Parameter <_>" -ForEach $parameters {
		BeforeAll {
			$paramhelp = $help.parameters.parameter | Where-Object name -eq $_
		}

		It "Should have a description" {
			$paramhelp.description | Should -Not -BeNullOrEmpty
		}
	}

	Context "Output type <_>" -ForEach $outputTypes {
		BeforeAll {
			$type = $_
			$outputhelp = $help.returnValues.returnValue | Where-Object {$_.type.Name -eq $type.Name}
		}

		It "Should be in help" {
			$outputhelp | Should -Not -BeNullOrEmpty
		}

		It "Should have a description" {
			$outputhelp.Description | Should -Not -BeNullOrEmpty
		}
	}
}
