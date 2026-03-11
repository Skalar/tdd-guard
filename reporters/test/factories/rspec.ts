import { spawnSync } from 'node:child_process'
import { join } from 'node:path'
import type { ReporterConfig, TestScenarios } from '../types'
import { copyTestArtifacts } from './helpers'

export function createRSpecReporter(): ReporterConfig {
  const artifactDir = 'rspec'
  const testScenarios = {
    singlePassing: 'single_passing_spec.rb',
    singleFailing: 'single_failing_spec.rb',
    singleImportError: 'single_import_error_spec.rb',
  }

  return {
    name: 'RSpecReporter',
    testScenarios,
    run: (tempDir, scenario: keyof TestScenarios) => {
      copyTestArtifacts(artifactDir, testScenarios, scenario, tempDir)

      const formatterPath = join(
        __dirname,
        '../../rspec/lib/tdd_guard_rspec'
      )
      const testFile = testScenarios[scenario]

      spawnSync(
        'bundle',
        [
          'exec',
          'rspec',
          testFile,
          '--require',
          formatterPath,
          '--format',
          'TddGuardRspec::Formatter',
        ],
        {
          cwd: tempDir,
          stdio: 'pipe',
          encoding: 'utf8',
          env: {
            ...process.env,
            TDD_GUARD_PROJECT_ROOT: tempDir,
            BUNDLE_GEMFILE: join(__dirname, '../../rspec/Gemfile'),
          },
        }
      )
    },
  }
}
