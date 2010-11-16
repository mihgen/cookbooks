include_recipe "hadoop::stop-all"

node[:hadoop][:daemons_in_order].each do |daemon|
  unless node[:hadoop][:daemons][daemon.to_sym][:clean_cmd].nil?
    start_daemons daemon do
      command node[:hadoop][:daemons][daemon.to_sym][:clean_cmd]
    end
  end
end
