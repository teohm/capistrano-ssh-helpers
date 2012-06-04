require 'capistrano/recipes/deploy/local_dependency'

Capistrano::Deploy::LocalDependency.class_eval do

  # Run a command and check the output.
  def run_cmd(command, expect, match_is_success=true, message=nil)
    expect = Regexp.new(Regexp.escape(expect.to_s)) unless expect.is_a?(Regexp)

    @configuration.logger.debug "executing \"#{command}\"" 
    output = `#{command} 2>&1`
    @configuration.logger.trace "[local] #{output}"

    is_matched = output =~ expect

    @success = if match_is_success
      is_matched ? true : false
    else
      is_matched ? false : true
    end
    
    unless @success
      @message = "#{message} (local)"
    end
    self
  end

end

