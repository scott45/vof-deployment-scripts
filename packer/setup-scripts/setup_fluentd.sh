
# this configures the application logging by google-fluentd to send application logs to
# the google logging web UI just like all other logs like syslog and VM logs. For indepth explanation on how this is done and why everything is where it is
# check out the logging documentation on this application's repo.
configure_google_fluentd_logging() {

  sudo cat <<EOF > /etc/google-fluentd/config.d/vof_development_logs.conf
<source>
  @type tail
  format none
  path /home/vof/app/log/development.log
  pos_file /var/lib/google-fluentd/pos/vof.pos
  read_from_head true
  tag vof_development_logs
</source>
EOF

  sudo cat <<EOF > /etc/google-fluentd/config.d/vof_sandbox_logs.conf
<source>
  @type tail
  format none
  path /home/vof/app/log/sandbox.log
  pos_file /var/lib/google-fluentd/pos/vof.pos
  read_from_head true
  tag vof_sandbox_logs
</source>
EOF

  sudo cat <<EOF > /etc/google-fluentd/config.d/vof_production_logs.conf
<source>
  @type tail
  format none
  path /home/vof/app/log/production.log
  pos_file /var/lib/google-fluentd/pos/vof.pos
  read_from_head true
  tag vof_production_logs
</source>
EOF

  sudo cat <<EOF > /etc/google-fluentd/config.d/vof_production_test_logs.conf
<source>
  @type tail
  format none
  path /home/vof/app/log/production_test.log
  pos_file /var/lib/google-fluentd/pos/vof.pos
  read_from_head true
  tag vof_production_test_logs
</source>
EOF

  sudo cat <<EOF > /etc/google-fluentd/config.d/vof_staging_logs.conf
<source>
  @type tail
  format none
  path /home/vof/app/log/staging.log
  pos_file /var/lib/google-fluentd/pos/vof.pos
  read_from_head true
  tag vof_staging_logs
</source>
EOF

}

# This configures the file responsible for tracking the last read position of the logs
# by google-fluentd.
configure_log_reader_positioning(){
  sudo cat <<EOF > /var/lib/google-fluentd/pos/vof.pos
/home/vof/app/log/production.log   000000000000000  000000000000000
/home/vof/app/log/staging.log   000000000000000  000000000000000
/home/vof/app/log/production_test.log  000000000000000  000000000000000
/home/vof/app/log/development.log  000000000000000  000000000000000
/home/vof/app/log/sandbox.log  000000000000000  000000000000000
EOF
}

# this right here restarts the google fluentd service so that the above changes can take effect.
restart_google_fuentd(){
  sudo service google-fluentd stop
  sudo service google-fluentd start
}
