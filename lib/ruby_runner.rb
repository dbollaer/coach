require "multi_ruby_runner/version"
require 'multi_ruby_runner/version_manager'
require 'multi_ruby_runner/version_manager/none'
require 'multi_ruby_runner/version_manager/rbenv'
require 'multi_ruby_runner/version_manager/rvm'
require 'open3'

#copy pasted from
#https://github.com/jhund/multi_ruby_runner
# Changed for streaming output
class RubyRunner

	def initialize
	end

	# Executes a command in a directory. Command will be executed in the
	# ruby environment specified in `.ruby-version` file in `directory`.
	# Returns stdout in the blocking form and pid of child process in the
	# non-blocking form.
	#
	# @param command_string [String] the shell command to run in directory
	# @param directory [String] the dir containing the ".ruby-version" file
	# @param options [Hash, optional]
	# @option options [String, optional] shell_invocation what shell to use, defaults to bash
	# @option options [Boolean, optional] blocking defaults to true.
	# @option options [String, optional] ruby_engine_invocation_override
	#   Can be used when no Ruby version manager is present, e.g., in a docker install.
	#   Example: "jruby -S "
	# @return [String, Integer, Nil] STDOUT output when blocking, pid when non-blocking.
	def execute_command_in_directory(command_string, directory, options = {})
		shell_path   = ENV['SHELL'] || '/bin/bash'
		options      = {
			blocking:         true,
			shell_invocation: "#{ shell_path } -c",
		}.merge(options)
		process_args = ruby_version_manager.compute_process_args(
			command_string,
			directory,
			options
		)
		execute_command(process_args)
	end

	# Returns the ruby version manager used
	# @return [MultiRubyRunner::VersionManager] 'rbenv', 'rvm', 'none'
	def ruby_version_manager
		MultiRubyRunner::VersionManager.detect


	end

	protected

	# @param process_args [Hash]
	#     {
	#       entire_command: includes shell invocation,
	#                       ruby version manager activation and command
	#       blocking: Boolean
	#       environment_overrides: {}
	#     }
	def execute_command(process_args)
		if process_args[:blocking]
			# Wait for command to complete
			execute_blocking_command(process_args)
		else
			# Spawn new process, execute command there and return immediately to caller.
			execute_non_blocking_command(process_args)
		end
	end

	def execute_blocking_command(process_args)
		stdout_str = stderr_str = status = nil

		puts process_args[:entire_command]
		Bundler.with_clean_env do
			#	Open3.captur3()
			#stdout_str, stderr_str, status = Open3.open3(
			Open3.popen3(
				process_args[:environment_overrides],
				process_args[:entire_command]
			) do |stdin, stdout, stderr, wait_thr|
				while line = stdout.gets
					puts line
				end
				exit_status = wait_thr.value
				unless exit_status.success?
					#abort "FAILED !!! #{cmd}"
					raise "Command failed with status #{ wait_thr.inspect }. stderr: #{ stderr.inspect }"
				end

			end
		end
	end

	def execute_non_blocking_command(process_args)
		pid = nil
		Bundler.with_clean_env do
			pid = Process.spawn(
				process_args[:environment_overrides],
				process_args[:entire_command]
			)
		end
		Process.detach(pid) # Avoid zombie process
		pid # return spawned process' pid
	end

end
