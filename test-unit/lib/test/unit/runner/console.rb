module Test
  module Unit
    AutoRunner.register_runner(:console) do |auto_runner|
      require 'test/unit/ui/console/testrunner'
      Test::Unit::UI::Console::TestRunner
    end

    AutoRunner.setup_option do |auto_runner, opts|
      require 'test/unit/ui/console/outputlevel'

      output_levels = [
        [:silent, UI::Console::OutputLevel::SILENT],
        [:progress, UI::Console::OutputLevel::PROGRESS_ONLY],
        [:normal, UI::Console::OutputLevel::NORMAL],
        [:verbose, UI::Console::OutputLevel::VERBOSE],
      ]
      opts.on('-v', '--verbose=[LEVEL]', output_levels,
              "Set the output level (default is verbose).",
              "(#{auto_runner.keyword_display(output_levels)})") do |level|
        level ||= output_levels.assoc(:verbose)[1]
        auto_runner.runner_options[:output_level] = level
      end

      use_color_options = [
        [:auto, :auto],
        ["-", false],
        ["no", false],
        ["false", false],
        ["+", true],
        ["yes", true],
        ["true", true],
      ]
      opts.on("--[no-]use-color=[auto]", use_color_options,
              "Use color output",
              "(default is auto") do |use_color|
        case use_color
        when nil
          use_color = true
        when :auto
          use_color = nil
        end
        auto_runner.runner_options[:use_color] = use_color
      end
    end
  end
end
