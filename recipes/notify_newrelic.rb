node["deploy"].each do |application, deploy|
  if deploy[:application_type] != 'other' || deploy["environment_variables"]["APP_TYPE"] != 'docker'
    Chef::Log.debug("Skipping application #{application} as it is not deployed to this layer")
    next
  end

  deploy["containers"].each do |c|
    c.each do |app_name, app_config|
      if app_config["notifications"] && app_config["notifications"]["newrelic"]
        execute "notifying newrelic of #{app_name} deployment" do
          license_key = node["newrelic"]["license"]
          env_var = app_config["notifications"]["newrelic"]["env_var"]
          rev_var = app_config["notifications"]["newrelic"]["rev_var"]
          cmd = "docker exec #{app_name}0 sh -c 'bundle exec newrelic deployments --environment=$#{env_var} --revision=$#{rev_var}'"

          Chef::Log.info("Notifying newrelic with command `#{cmd}`")
          command cmd
        end
      end
    end
  end
end
