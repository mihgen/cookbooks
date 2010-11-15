include_recipe "hadoop::clean_all"

node[:hadoop][:daemons].each do |daemon|
  start_daemons daemon do
    command node[:hadoop][:daemons][daemon.to_sym][:start_cmd]
  end
end

