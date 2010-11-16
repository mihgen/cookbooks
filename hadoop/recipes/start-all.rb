node[:hadoop][:daemons_in_order].each do |daemon|
  start_daemons daemon do
    command node[:hadoop][:daemons][daemon.to_sym][:start_cmd]
  end
end

