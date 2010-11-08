define :start_daemons, :action => :start do
  
  daemon_nodes = search(:node, %Q{run_list:"recipe[hadoop::#{params[:name]}]"}).map{ |e| e["fqdn"] }
  log "Found nodes for #{params[:name]}: #{daemon_nodes.join(',')}. Applying '#{params[:command]}' for them."

  daemon_nodes.each do |n|
    script "Start Hadoop cluster daemon #{params[:name]}..." do
      interpreter "bash"
      user node[:hadoop][:user]
      cwd node[:hadoop][:userhome]
      code <<-EOH
        ssh #{n} "#{params[:command]}" 2>&1 &
        sleep 1
      EOH
    end
  end
end
