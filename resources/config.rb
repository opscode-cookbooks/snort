property :home_net, String,     default: 'any'
property :external_net, String, default: 'any'

property :http_ports, String,      default: '80,81,311,383,591,593,901,1220,1414,1741,1830,2301,2381,2809,3037,3128,3702,4343,4848,5250,6988,7000,7001,7144,7145,7510,7777,7779,8000,8008,8014,8028,8080,8085,8088,8090,8118,8123,8180,8181,8243,8280,8300,8800,8888,8899,9000,9060,9080,9090,9091,9443,9999,11371,34443,34444,41080,50002,55555'
property :shellcode_ports, String, default: '!80'
property :oracle_ports, String,    default: '1024'
property :ssh_ports, String,       default: '22'
property :ftp_ports, String,       default: '21,2100,3535'
property :sip_ports, String,       default: '5060,5061,5600'
property :file_data_ports, String, default: '$HTTP_PORTS,110,143'
property :gtp_ports, String,       default: '2123,2152,3386'
property :aim_servers, String,     default: '64.12.24.0/23,64.12.28.0/23,64.12.161.0/24,64.12.163.0/24,64.12.200.0/24,205.188.3.0/24,205.188.5.0/24,205.188.7.0/24,205.188.9.0/24,205.188.153.0/24,205.188.179.0/24,205.188.248.0/24'

property :decoder_config, Array, default: ['disable_decode_alerts', 'disable_tcpopt_experimental_alerts','disable_tcpopt_obsolete_alerts','disable_tcpopt_ttcp_alerts','disable_tcpopt_alerts','disable_ipopt_alerts','checksum_mode: all']
property :detection_config, Hash, default: {
  'config pcre_match_limit' => '3500',
  'config pcre_match_limit_recursion' =>  '1500',
  'config detection' => 'search-method ac-split search-optimize max-pattern-len 20',
  'config event_queue' => 'max_queue 8 log 5 order_events content_length'
}
property :perfprofiling_config, Hash, default: {}
property :paf_max, String, default: '16000'
property :dynamic_config, Hash, default: {
'dynamicpreprocessor directory' => '/usr/lib64/snort-2.9.9.0_dynamicpreprocessor/',
'dynamicengine' => '/usr/lib64/snort-2.9.9.0_dynamicengine/libsf_engine.so',
'dynamicdetection directory' => '/usr/lib/snort_dynamicrules'
}
property :output_config, Hash, default: { 'unified2' => 'filename merged.log, limit 128, nostamp, mpls_event_types, vlan_event_types' }
property :preprocessor, [Array, Hash], default: [
  'normalize_ip4',
  'normalize_tcp: ips ecn stream',
  'normalize_icmp4',
  'normalize_ip6',
  'normalize_icmp6',
  'frag3_global: max_frags 65536',
  'frag3_engine: policy windows detect_anomalies overlap_limit 10 min_fragment_length 100 timeout 180']
property :site_rules_include, Array
property :decoder_preproc_rules, Array
property :dynamic_rules_include, Array, default: %w(
bad-traffic.rules
chat.rules
dos.rules
exploit.rules
icmp.rules
imap.rules
misc.rules
multimedia.rules
netbios.rules
nntp.rules
p2p.rules
smtp.rules
snmp.rules
specific-threats.rules
web-activex.rules
web-client.rules
web-iis.rules
web-misc.rules
)

action :create do
  template '/etc/snort/snort.conf' do
    cookbook 'snort'
    source 'snort.conf.erb'
    owner root
    group root
    mode '0644'
    notifies :restart, "service[#{svc_name}]", :delayed
    variables(
      home_net: new_resource.home_net,
      external_net: new_resource.external_net,
    )
    action :create
  end

end
