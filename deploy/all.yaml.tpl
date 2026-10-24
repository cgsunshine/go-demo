apiVersion: apps/v1
kind: Deployment
metadata:
  name: go-demo
  labels:
    app: go-demo
    env: ${APP_ENV}
spec:
  replicas: ${REPLICAS}
  selector:
    matchLabels:
      app: go-demo
  template:
    metadata:
      labels:
        app: go-demo
        env: ${APP_ENV}
    spec:
      containers:
        - name: web
          image: ${IMAGE_NAME}:${IMAGE_TAG}
          imagePullPolicy: IfNotPresent
          env:
            - name: APP_VERSION
              value: "${IMAGE_TAG}"
            - name: APP_ENV
              value: "${APP_ENV}"
          ports:
            - containerPort: 8080
          readinessProbe:
            httpGet:
              path: /healthz
              port: 8080
            initialDelaySeconds: 1
            periodSeconds: 5
          resources:
            requests:
              cpu: 20m
              memory: 32Mi
            limits:
              cpu: 100m
              memory: 64Mi
---
apiVersion: v1
kind: Service
metadata:
  name: go-demo
  labels:
    app: go-demo
spec:
  selector:
    app: go-demo
  ports:
    - port: 80
      targetPort: 8080