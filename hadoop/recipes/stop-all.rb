node[:hadoop][:daemons].each do |daemon|
  start_daemons daemon[0] do
    command node[:hadoop][:daemons][daemon[0].to_sym][:stop_cmd]
  end
end
