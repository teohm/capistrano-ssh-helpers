unless Capistrano::Configuration.respond_to?(:instance)
    abort "capistrano-checks requires Capistrano 2"
end

require 'capistrano-ssh-helpers/ext/local_dependency'

Capistrano::Configuration.instance.load do
  namespace :deploy do
    namespace :checks do

      desc <<-DESC
        Add check to ensure Git SSH host is verified on remote server.
        
        The check is added to deploy:check, when :scm is set to :git
        and :repository looks like a ssh path/url.
      DESC
      task :check_git_host do
        return unless scm == :git

        LIKE_SSH_HOST = /^([^@]+@[^:]+):.*$/
        LIKE_SSH_URL  = %r[^(ssh://[^/]+).*$]

        repo_url = fetch(:repository, '')
        ssh_host = if repo_url =~ LIKE_SSH_HOST
                     $1
                   elsif repo_url =~ LIKE_SSH_URL
                     $1
                   end

        if ssh_host
          depend :remote, :run_cmd, "ssh #{ssh_host}",
            /Host key verification failed/, false,
            "Git SSH host is not verified. To verify as known host, run this on server: 'ssh #{ssh_host}'"
        end
      end # task

    end
  end

  before 'deploy:check', 'deploy:checks:git_host_verified'
end
