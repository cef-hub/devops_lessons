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