
# 📦 Шпаргалка: Настройка HPA в Minikube

## 📁 Шаг 0: Запуск Minikube с `metrics-server`
```bash
minikube start --addons=metrics-server
```

Проверка работы:
```bash
kubectl get deployment metrics-server -n kube-system
kubectl top pods
```

---

## 📄 Шаг 1: `deployment.yaml`
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: scalable-app
spec:
  replicas: 1
  selector:
    matchLabels:
      app: scalable-app
  template:
    metadata:
      labels:
        app: scalable-app
    spec:
      containers:
        - name: scalable-container
          image: k8s.gcr.io/hpa-example
          resources:
            requests:
              cpu: "100m"
            limits:
              cpu: "200m"
```

Применить:
```bash
kubectl apply -f deployment.yaml
```

---

## 📄 Шаг 2: `service.yaml`
```yaml
apiVersion: v1
kind: Service
metadata:
  name: scalable-app-service
spec:
  selector:
    app: scalable-app
  ports:
    - port: 80
      targetPort: 80
```

Применить:
```bash
kubectl apply -f service.yaml
```

---

## 📄 Шаг 3: `hpa.yaml`
```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: scalable-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: scalable-app
  minReplicas: 1
  maxReplicas: 5
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 50
```

Применить:
```bash
kubectl apply -f hpa.yaml
```

---

## 🔥 Шаг 4: Генерация нагрузки
```bash
kubectl run -i --tty load-generator --image=busybox /bin/sh
```

Внутри контейнера:
```sh
while true; do wget -q -O- http://scalable-app-service; done
```

---

## 🔍 Шаг 5: Мониторинг
```bash
kubectl get hpa -w
kubectl get pods
```

---

## 🧹 Очистка ресурсов
```bash
kubectl delete hpa scalable-app-hpa
kubectl delete deployment scalable-app
kubectl delete service scalable-app-service
kubectl delete pod load-generator
minikube stop
minikube delete
```
