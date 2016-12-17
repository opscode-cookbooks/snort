provides :snort_service, os: 'linux' do |_node|
  Chef::Platform::ServiceHelpers.service_resource_providers.include?(:systemd)
end

property :service_name, String

action :start do
  cleanup_old_service
  create_init

  service svc_name do
    supports status: true, restart: true
    action :start
  end
end

action :stop do
  service svc_name do
    supports status: true
    action :stop
    only_if { ::File.exist?("/etc/systemd/system/#{svc_name}.service") }
  end
end

action :restart do
  service svc_name do
    action :restart
    supports status: true, restart: true
  end
end

action :enable do
  cleanup_old_service
  create_init

  service svc_name do
    supports status: true
    action :enable
  end
end

action :disable do
  service svc_name do
    supports status: true
    action :disable
    only_if { ::File.exist?("/etc/systemd/system/#{svc_name}.service") }
  end
end

action_class.class_eval do
  def create_init
    template "/etc/systemd/system/#{svc_name}.service" do
      source 'init_systemd.erb'
      cookbook 'snort'
      notifies :run, 'execute[Load systemd unit file]', :immediately
    end

    execute 'Load systemd unit file' do
      command 'systemctl daemon-reload'
      action :nothing
    end
  end

  def cleanup_old_service
    return unless ::File.exist?('/etc/init.d/snort')
    service 'disable sys-v init snort' do
      service_name svc_name
      action [:stop, :disable]
    end

    file '/etc/init.d/snort' do
      action :delete
    end
  end

  # Determine the service_name either by platform or via user override
  def svc_name
    if service_name
      service_name
    else
      case node['platform_family']
      when 'debian'
        'snort'
      else
        'snortd'
      end
    end
  end
end
