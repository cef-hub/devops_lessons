## 1. Создали файл с секретами mongodb-secrets.yaml

```
apiVersion: v1
kind: Secret
metadata:
   name: mongo-secret
data:
  username: c2tydWhsaWs=
  password: c2tydWhsaWs=
```

## 2. Создали файл PV mongodb-pv.yaml

```

kind: PersistentVolume
apiVersion: v1
metadata:
  name: mongo-pv-volume
  labels:
    type: local
    app: mongo
spec:
  storageClassName: gp2
  capacity:
    storage: 250Mi
  accessModes:
    - ReadWriteMany
  hostPath:
    path: "/mongo-data"

```

## 3. Создали файл PVC mongodb-pvc.yaml

```

apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongo-pv-claim
  labels:
    app: mongo
spec:
  storageClassName: gp2
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 250Mi

```


## 4. Создали файл PVC mongodb-deployment.yaml

```

apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: mongo
  labels:
    app: mongo
spec:
  selector: 
    matchLabels:
      app: mongo
  replicas: 1
  template:
    metadata:
      labels:
        app: mongo
      name: mongodb-service
    spec:
      containers:
      - image: mongo:latest
        name: mongo
        
        env:
          - name: MONGO_INITDB_ROOT_USERNAME
            valueFrom:
              secretKeyRef:
                name: mongo-secret
                key: username
          - name: MONGO_INITDB_ROOT_PASSWORD
            valueFrom:
              secretKeyRef:
                name: mongo-secret
                key: password
        ports:
        - containerPort: 27017
          name: mongo                
        volumeMounts:
        - name: mongo-persistent-storage
          mountPath: /data/db 
      volumes:
      - name: mongo-persistent-storage 
        persistentVolumeClaim:
          claimName: mongo-pv-claim          
		  
```

## 5. Run some commands

```

D:\Kubernetes\19_mongo>aws eks update-kubeconfig --name skruhlik-eks-cluster
Added new context arn:aws:eks:us-east-1:097084951758:cluster/skruhlik-eks-cluster to C:\Users\svuatoslav.kruhlik\.kube\config

D:\Kubernetes\19_mongo>kubectl apply -f mongodb-pv.yaml
persistentvolume/mongo-pv-volume created

D:\Kubernetes\19_mongo>kubectl apply -f mongodb-secrets.yaml
secret/mongo-secret created

D:\Kubernetes\19_mongo>kubectl apply -f mongodb-pvc.yaml
persistentvolumeclaim/mongo-pv-claim created

D:\Kubernetes\19_mongo>kubectl apply -f mongodb-deployment.yaml
statefulset.apps/mongo created

D:\Kubernetes\19_mongo>kubectl get pods
NAME      READY   STATUS    RESTARTS   AGE
mongo-0   1/1     Running   0          31m

```

## 6. Add PortForwarding to port 27017

![Результат PortForwarding](https://github.com/cef-hub/devops_lessons/blob/main/lesson19.kubernetes.mongo.local/images/portforwarding.png?raw=true)


