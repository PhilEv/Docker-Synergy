BINARY=$1
${BINARY} apply -f - -n sysdig --validate=false <<EOF
apiVersion: extensions/v1beta1
kind: DaemonSet
metadata:
  name: sysdig-agent
  labels:
    app: sysdig-agent
spec:
  updateStrategy:
    type: RollingUpdate
  template:
    metadata:
      labels:
        app: sysdig-agent
    spec:
      volumes:
      - name: dshm
        emptyDir:
          medium: Memory
      - name: docker-sock
        hostPath:
          path: /var/run/docker.sock
      - name: dev-vol
        hostPath:
          path: /dev
      - name: proc-vol
        hostPath:
          path: /proc
      - name: boot-vol
        hostPath:
          path: /boot
      - name: modules-vol
        hostPath:
          path: /lib/modules
      - name: usr-vol
        hostPath:
          path: /usr
      hostNetwork: true
      hostPID: true
      tolerations:
        - effect: NoSchedule
          key: node-role.kubernetes.io/master
      ### OPTIONAL: If using OpenShift or Kubernetes RBAC you need to uncomment the following line
      serviceAccount: sysdig
      containers:
      - name: sysdig-agent
        image: sysdig/agent
        imagePullPolicy: Always
        securityContext:
          privileged: true
        resources:
          # Resources needed are subjective on the actual workload
          # please refer to Sysdig Support for more info about it
          requests:
            cpu: 100m
            memory: 512Mi
          limits:
            memory: 1024Mi
        readinessProbe:
          exec:
            command: [ "test", "-e", "/opt/draios/logs/draios.log" ]
          initialDelaySeconds: 10
        env:
        ### REQUIRED: replace with your Sysdig Platform access key
        - name: ACCESS_KEY
          #value: 083d1138-2658-42ef-9b37-7653cf60d57c
          value: '{{ sysdig_access_key }}'
        ### OPTIONAL: add tags for this host
        # - name: TAGS
        #   value: linux:ubuntu,dept:dev,local:nyc
        ### OPTIONAL: Needed to connect to a Sysdig On-Premises backend
        # - name: COLLECTOR
        #   value: collector-staging.sysdigcloud.com
        # - name: COLLECTOR_PORT
        #   value: "6443"
        # - name: COLLECTOR
        #   value: 192.168.183.200
        # - name: SECURE
        #   value: "true"
        # - name: CHECK_CERTIFICATE
        #   value: "false"
        ### OPTIONAL: Add additional parameters to the agent, refer to our Docs to know all options available
        - name: ADDITIONAL_CONF
          value: |
          new_k8s: true
          k8s_cluster_name: ucp_nm-ucp.cloudra.local
        volumeMounts:
        - mountPath: /host/var/run/docker.sock
          name: docker-sock
          readOnly: false
        - mountPath: /host/dev
          name: dev-vol
          readOnly: false
        - mountPath: /host/proc
          name: proc-vol
          readOnly: true
        - mountPath: /host/boot
          name: boot-vol
          readOnly: true
        - mountPath: /host/lib/modules
          name: modules-vol
          readOnly: true
        - mountPath: /host/usr
          name: usr-vol
          readOnly: true
        - mountPath: /dev/shm
          name: dshm
EOF

