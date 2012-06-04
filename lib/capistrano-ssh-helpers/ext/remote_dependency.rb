require 'capistrano/recipes/deploy/remote_dependency'

Capistrano::Deploy::RemoteDependency.class_eval do
  def run_cmd(command, expect, match_is_success=true, message=nil, options={})
    expect = Regexp.new(Regexp.escape(expect.to_s)) unless expect.is_a?(Regexp)

    output_per_server = {}
    try("#{command} ", options) do |ch, stream, out|
      output_per_server[ch[:server]] ||= ''
      output_per_server[ch[:server]] += out
    end 

    # It is possible for some of these commands to return a status != 0
    # (for example, rake --version exits with a 1). For this check we
    # just care if the output matches, so we reset the success flag.
    @success = true

    errored_hosts = []
    output_per_server.each_pair do |server, output|
      if match_is_success
        next if output =~ expect
      else
        next unless output =~ expect
      end
      errored_hosts << server
    end

    if errored_hosts.any?
      @hosts = errored_hosts.join(', ')
      output = output_per_server[errored_hosts.first]
      default_message = "the output #{output.inspect} from #{command.inspect} did not match #{expect.inspect}"
      @message = message || default_message
      @success = false
    end

    self
  end
end

