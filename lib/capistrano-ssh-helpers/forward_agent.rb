unless Capistrano::Configuration.respond_to?(:instance)
    abort "capistrano-checks requires Capistrano 2"
end

require 'capistrano-ssh-helpers/ext/local_dependency'

Capistrano::Configuration.instance.load do
  namespace :deploy do
    namespace :forward_agent do

      desc <<-DESC
        Add check to ensure local SSH agent has identity key.

        The check is added to deploy:check, when ssh_options[:forward_agent]
        is set to true.
      DESC
      task :check do
        if ssh_options[:forward_agent]
          depend :local, :run_cmd, 'ssh-add -l',
            /no identities/, false,
            "Local SSH agent has no key. To add key: 'ssh-add -K' or 'ssh-add -K private_key_file'"
        end
      end #task

    end
  end

  before 'deploy:check', 'deploy:forward_agent:check'

end
