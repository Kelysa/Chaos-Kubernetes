## Run 
Apply all k8s manifests to create monitoring namespace with Prometheus and Grafana:
```bash
make start
```
  
Delete all previously created resources:
```bash
make stop
```

Command for a general view:
```bash
kubectl get all --all-namespaces
```

view all services:
```bash
minikube service list
```

Wait 2-3 minute before using minikube dashboard

## Configure Grafana
Add Prometheus data source and set the HTTP URL `http://prometheus:9090`.  
Test by running the following query via Explore:
```
avg(irate(container_cpu_usage_seconds_total{namespace=~"monitoring"}[5m]) * 100) by (pod_name)
```

- kubectl describe node minikube


### Auto-Scaling

- Check HPA demo live:

Change snake/hpa.yml -> maxreplica 

Open three different terminal

- Terminal 1 :``` watch -n 1 kubectl get pods ```

- Terminal 2 :``` watch -n 1 kubectl get hpa ```

- Terminal 3 :```ab -c 5 -n 1000 -t 100000 http://192.168.99.100:30001/```


### Cluster Minikube and Octoshield

See all profiles :``` ll ~/.minikube/profiles ```

Change profile : ```minikube profile minikube ```
