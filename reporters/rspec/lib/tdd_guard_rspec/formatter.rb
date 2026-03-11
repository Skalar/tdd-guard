# frozen_string_literal: true

require "json"
require "fileutils"
require "rspec/core"
require "rspec/core/formatters/base_formatter"

module TddGuardRspec
  class Formatter < RSpec::Core::Formatters::BaseFormatter
    RSpec::Core::Formatters.register self, :example_passed, :example_failed, :message, :dump_summary, :close

    def initialize(output)
      super
      @test_modules = {}
      @load_errors = []
      @reason = nil
    end

    def example_passed(notification)
      record_example(notification.example, "passed")
    end

    def example_failed(notification)
      record_example(notification.example, "failed", notification.example.execution_result.exception)
    end

    def message(notification)
      msg = notification.message
      match = msg.match(/An error occurred while loading (.+)\./)
      return unless match

      @load_errors << { file_path: match[1], message: msg }
    end

    def dump_summary(notification)
      @reason = if notification.failure_count > 0 || notification.errors_outside_of_examples_count > 0
                  "failed"
                else
                  "passed"
                end
    end

    def close(_notification)
      record_load_errors
      project_root = ENV["TDD_GUARD_PROJECT_ROOT"] || Dir.pwd
      output_dir = File.join(project_root, ".claude", "tdd-guard", "data")
      FileUtils.mkdir_p(output_dir)

      result = {
        "testModules" => @test_modules.values,
        "reason" => @reason
      }
      File.write(File.join(output_dir, "test.json"), JSON.generate(result))
    end

    private

    def record_example(example, state, exception = nil)
      file_path = example.metadata[:file_path]
      module_data = @test_modules[file_path] ||= {
        "moduleId" => file_path,
        "tests" => []
      }

      test_data = {
        "name" => example.description,
        "fullName" => example.id,
        "state" => state
      }

      if exception
        error = { "message" => exception.message }
        error["stack"] = exception.backtrace.join("\n") if exception.backtrace
        test_data["errors"] = [error]
      end

      module_data["tests"] << test_data
    end

    def record_load_errors
      @load_errors.each do |load_error|
        file_path = load_error[:file_path]
        module_data = @test_modules[file_path] ||= {
          "moduleId" => file_path,
          "tests" => []
        }

        module_data["tests"] << {
          "name" => "load error",
          "fullName" => "load error",
          "state" => "failed",
          "errors" => [{ "message" => load_error[:message] }]
        }
      end
    end
  end
end
