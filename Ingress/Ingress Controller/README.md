## What is an Ingress Controller in Kubernetes?

An **Ingress Controller** is a specialized type of load balancer responsible for managing HTTP and HTTPS traffic to the cluster. It watches the Ingress resources in the cluster and configures the backend (e.g., NGINX, Traefik) to route traffic based on the rules defined in these resources.

### Key Features of an Ingress Controller:

1. **Path-Based Routing**:
   - Routes requests to different services based on URL paths (e.g., `/app1` to Service A, `/app2` to Service B).

2. **Host-Based Routing**:
   - Routes traffic based on domain names (e.g., `app1.example.com` to Service A).

3. **TLS Termination**:
   - Handles HTTPS traffic by terminating TLS/SSL at the ingress point.

4. **Custom Rules**:
   - Supports advanced traffic control with annotations or custom configuration.

5. **External Exposure**:
   - Makes cluster services available to external clients via a single IP.

---

## Example: Deploying an Ingress Controller and Ingress Resource

### Step 1: Deploy NGINX Ingress Controller

This example uses the NGINX Ingress Controller.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ingress-nginx-controller
  namespace: ingress-nginx
spec:
  replicas: 2
  selector:
    matchLabels:
      app.kubernetes.io/name: ingress-nginx
  template:
    metadata:
      labels:
        app.kubernetes.io/name: ingress-nginx
    spec:
      containers:
      - name: controller
        image: k8s.gcr.io/ingress-nginx/controller:v1.9.0
        args:
        - /nginx-ingress-controller
        - --configmap=$(POD_NAMESPACE)/nginx-configuration
        env:
        - name: POD_NAMESPACE
          valueFrom:
            fieldRef:
              fieldPath: metadata.namespace
        ports:
        - name: http
          containerPort: 80
        - name: https
          containerPort: 443
```

### Step 2: Create a Service for the Ingress Controller

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ingress-nginx
  namespace: ingress-nginx
spec:
  type: LoadBalancer
  selector:
    app.kubernetes.io/name: ingress-nginx
  ports:
  - port: 80
    targetPort: 80
  - port: 443
    targetPort: 443
```

### Step 3: Define an Ingress Resource

This example demonstrates routing traffic to two services (`service-a` and `service-b`) based on paths.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: example-ingress
  annotations:
    nginx.ingress.kubernetes.io/rewrite-target: /$1
spec:
  rules:
  - host: "example.com"
    http:
      paths:
      - path: /service-a(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: service-a
            port:
              number: 80
      - path: /service-b(/|$)(.*)
        pathType: ImplementationSpecific
        backend:
          service:
            name: service-b
            port:
              number: 80
  tls:
  - hosts:
    - "example.com"
    secretName: example-tls
```

---

### Key Notes:

1. **Ingress Controller**:
   - Must be installed and running to handle `Ingress` resources.

2. **Ingress Resource**:
   - Defines the routing rules for HTTP(S) traffic.

3. **Annotations**:
   - Add custom configurations like URL rewriting or request headers.

4. **TLS Secret**:
   - Specify a Kubernetes `Secret` for TLS termination.

---

Let me know if you'd like to expand on any section or need help deploying these configurations!
