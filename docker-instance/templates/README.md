kubectl create namespace argocd
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml


```yaml
apiVersion: v1
kind: Service
metadata:
  name: argocd-server-nodeport
  namespace: argocd
spec:
  type: NodePort
  ports:
    - name: https
      port: 443
      targetPort: 8080
      nodePort: 30443
  selector:
    app.kubernetes.io/name: argocd-server
---
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: argocd-server-ingress
  namespace: argocd
spec:
  ingressClassName: traefik
  rules:
  - http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: argocd-server
            port:
              number: 80

```

kubectl apply -f argocd-service.yaml
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d

vim argocd-app.yml

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: lambda-deployments
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/shirjs/argo-follow.git
    targetRevision: HEAD
    path: manifests
    directory:
      recurse: true  # Important: This enables scanning subdirectories
  destination:
    server: https://kubernetes.default.svc
    namespace: default  # This will be overridden by namespaces in the manifests
  syncPolicy:
    automated:
      prune: true  # Automatically delete resources that are no longer in Git
      selfHeal: true  # Automatically sync if cluster state deviates from Git
    syncOptions:
    - CreateNamespace=true  # Automatically create namespaces
    - PrunePropagationPolicy=foreground  # Ensure proper cleanup
    - PruneLast=true  # Delete resources last during pruning
```

kubectl apply -f argocd-app.yaml


curl -sSL -o argocd-linux-amd64 https://github.com/argoproj/argo-cd/releases/latest/download/argocd-linux-amd64

chmod +x argocd-linux-amd64

sudo mv argocd-linux-amd64 /usr/local/bin/argocd

argocd login <ec2-ip>:30443 --insecure

