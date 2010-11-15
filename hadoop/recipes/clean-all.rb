include_recipe "hadoop::stop-all"

node[:hadoop][:daemons].each do |daemon|
  unless node[:hadoop][:daemons][daemon[0].to_sym][:clean_cmd].nil?
    start_daemons daemon[0] do
      command node[:hadoop][:daemons][daemon[0].to_sym][:clean_cmd]
    end
  end
end
