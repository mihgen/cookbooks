include_recipe "simple-httpd"

template "/var/www/html/index.html" do
  mode 0644
  source "index.html.erb"
end

