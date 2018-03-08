rpm -i splunkforwarder-7.0.2-03bbabbd5c0f-linux-2.6-x86_64.rpm
export SPLUNK_HOME=/opt/splunkforwarder/
cd $SPLUNK_HOME/bin
./splunk  --accept-license --answer-yes add  monitor -sourcetype authlog -source /var/log/secure
./splunk add  monitor -sourcetype syslog -source /var/log/messages
{% for forward_server in splunk_architecture_forward_servers %}
./splunk --accept-license --answer-yes add forward-server {{ forward_server }}
{% endfor %}
./splunk start
