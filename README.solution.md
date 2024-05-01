# CERN Techincal Studentship Solution

## TASKS

- Containerize server (backed) ✔️
- Containerize Client (frontend) ✔️
- Add Postgresql with Persistent Volume ✔️
- Create a compose file that will run the backend, frontend and Database together in development mode ✔️
- Add reverse Proxy to compose file ✔️
- Add SSL support to the proxy ✔️
- Hot code reloading for backend ✔️
- Hot code reloading for frontend 🛠️
- Write a ```.gitlab-ci.yaml``` that has "test" Stage and "build Stage", automatically gets triggered main branch ✔️
- Deploy DB ✔️
- Deploy Backend ✔️
- Deploy Frontend ✔️
- Add Reverse Proxy 🛠️(🤔✔️)
- Add SSL support to remote proxy 🛠️(🤔✔️)

## Understanding the problem & Approaching it

![Solution Approach](https://lh7-us.googleusercontent.com/-8-wdDch0KRYU4t__zglaYgEveEDC-ftHqUXnrPAoLv9Iu-os6thoqiqkKJIW2Kv_Vbr3o_a6DMBNqHXMXofuSk33OIl3dHbKzgKBfeGZZ7SATMUeN_yqaqbZGOJbovmk_lWvGVYGEHUx84EMd-PMm4)

We were given a restaurant application and it has 3 components, namely:

    - A Vue application (Presentation Tier)
    - A FastApi server (Logical Tier)
    - A PostgreSQL DB (Data Tier)

First step was to containarize the application, follow the following steps to reproduce the solution. Best practices like `least-priviledge principle` were followed.

To initialise the environment variables create a `.env` file in the root of the folder.
I have given an `.env.sample` file with prepopulated values. It can be used instead of the prior by just renaming the latter.

```bash
mv .env.sample .env
```

To run the services individually, we can use the following commands

#### Running DB

```
docker compose up -d db
```

The image below shows initiliasation of database via the `init.sql` file provided

![Docker DB INIT](https://lh7-us.googleusercontent.com/uT5v3ovF53WFB6H-FMiLRhzlcykEjskSmkcyVvYcyYkW4CZam1-c4oGcHfquhqCWY2X4rqz0QZs9fefWT4Hkjg3AvLmS_BIVExuIFEEnhf6Iq0KtSnlDOXo_Dh9t-JpqKuzLJZCL_IxI18qjLK50v3E)

#### Running Server

```
docker compose up -d server
```

#### Running Server

```
docker compose up -d client
```

#### Running Server

```
docker compose up -d nginx-proxy
```

To run all the servies together we can directly use

#### Running Application

```
docker compose up -d 
```

![Docker Compose response](https://lh7-us.googleusercontent.com/1IxO6gj-qC-5FECxluc0eGDs_kbiNejiSYq4eoRZ26TMXcDHgli0Fb3gXhykMOJAhnvy7CeYCQ2k3OOJ6aHUYZzw4XtX-GmZ4QNZ0k50E8_C3kOLsX6Hq-_qSyA6jBUVc8hC8VxhBrYvRmRzFzJjkVQ)

Run without `-d` if you want to see the logs as well

![Docker Compose logs](https://lh7-us.googleusercontent.com/J3WEpD0NGs8JGRejP6mg8KQ6EpYcNmWQJj_Bg5t5btKDVhufDnytNjiGV-FgMrIp7vs4FrhC4zITHadhbOzMR4hj3qwdyMfguu4phDepE3T4TqZdDC662fEQkC5-lduqIuZ0IAtLE72U0H0P_CGDL8o)

#### Accessing the Backend API(docs)

[http://localhost:8080/api/docs/](http://localhost:8080/api/docs/)

![HTTP backend](https://lh7-us.googleusercontent.com/hpzP6ZvTAllsX0sI1KrIV6KO0Jbebr9i7rZJUAfcskiueX2UmTiRIf7NMf3pXPxH4qHULmdyorYrDK3bSRy2oZIO41EMYV_-6n8UKsNVmWF1wkEoiTEk12rUMVn57xZkxvKV5-jub37TAHZavLPvejw)

or

[https://localhost:5050/api/docs/](https://localhost:5050/api/docs/)

![HTTPS backend](https://lh7-us.googleusercontent.com/yagRAO34fPbuigfTkKtFlxOQ_m3jvD4axtrrHpMVLJ-jvRiYUfYYreqsT1EaNbsKiAcCgU5QloOezfjZxcVKCyUj_2JJH077SCB8hny7pzK_7hqSqEBRZdAogY9VHc2UBI425PPs5KsXDXdfCM-jtjY)

#### Accessing the Frontend

[http://localhost:8080/client/](http://localhost:8080/client/)

![HTTP frontend](https://lh7-us.googleusercontent.com/P4IC8E8wGdxWRPdA0NwpuUXyt54THr7dRBYBcADLTAfCz816-8gHLTwrDQoGYqqt5sL97ESBCnC3xTP2NZQpBgfcu04Qb4jd9UFagT-iqosRVyacd1u7edIVKym0yvjhTthEo7UVKnlXqJ442jFzmJc)

or

[https://localhost:5050/client/](https://localhost:5050/client/)

![HTTPS frontend](https://lh7-us.googleusercontent.com/R_OV3Ep7iP-LZa2U2aHQvtIxo868eobh1MrxzqQcencqZUckkqmTVDpNuUrHPJQiFrd6LmYBkwBtxLAg8ngUZ-BgnNXhzPieKbyXGBZSeaBVynfU5HmTyrJuH0Z3-7UeX6WZh54yh-EOUfz7Sj0RSdQ)

## What is going inside Docker 🐳 and how is reverse proxy working?

    So every request coming with "/client" is redirected to frontend container's port (5000) on which Vue
    code is running & the one with "/api" is redirected to backend container's port (8000) on which FASTAPI code is running.

![Docker Network](https://lh7-us.googleusercontent.com/pHYvQIwLLmqB3aPFM_hsH30eYmFtwuPfHU7QcCnwixqDWCb1X4GQYps3fEYXa5d-hFbiXq92996P7-W0_iA0IKK1PoaODv1Eub1YfKOJuTR3O2nf6X24B6YEWQs2ZumWHN_zasDXbK7XEFoSUzbt96g)

## GitLab CI/CD

The image below shows how the `.gitlab-ci.yaml` automatically gets triggered for  `main` branch.
The Pipeline pushesh the build images to docker hub. The pushed images can be accessed via the following links:

- [Client](https://hub.docker.com/r/utkarsh4tech/frontend_test)

- [Server](https://hub.docker.com/r/utkarsh4tech/backend_test)

    NOTE: There are two variables which come from GitLab variables, namely DOCKER_USER & DOCKER_PASSWORD

![CI-Pipeline](https://lh7-us.googleusercontent.com/o83s1xAozNzZX7iJD-fFfMa7bb9lcgtUwoqIkRTxNxWFDnmrnCsfzstI9l9jkRjQ_3615KE4eHZ9WhK9khGL1MTlQRoiOxvsVvvmvY_n4hq47zGMK9i_f4ijGwKDBOmCPYd2Up9qRAPxkcOscEhfzvA)

The image below shows how the pipeline passing and the author receiving mail updates

![CI-Pipeline-Pass](https://lh7-us.googleusercontent.com/ZipMTv_XuU3Bmu_Pf0Hr06Zq6fhvMnTGHcAqJYJI0c7GVvu8cxme6JiZs-LpXW1FCHz0Y_6UjSzkZn1U5BJJXLRjyCJMiPyrC21I98aah-YnMG1mwIAfR5OMpfIS0OWEgCmEaimEXeMl4avRKif6Tmk)

## Deployment to K8S

To make use of the auto healing capacities and other benifits of Kubernetes(K8S) we deploy our individual containers via deployments. These deployments create replica-sets that make sure that given number of replica is always running as pods.
This is the directory structure of `k8s` folder which contains all the manifest files for kubernetes.

    k8s:
    ├───client
    │       client-configmap.yaml
    │       client-deployment.yaml
    │       client-svc.yaml
    │
    ├───db
    │       db-configmap.yaml
    │       db-deployment.yaml
    │       db-pv.yaml
    │       db-secrets.yaml
    │       db-svc.yaml
    │
    ├───ingress
    │       ingress-cert.yaml
    │       ingress.yaml
    │
    └───server
            server-configmap.yaml
            server-deployment.yaml
            server-secret.yaml
            server-svc.yaml

**NOTE:** I use `kcl` as an alias for `kubectl`, hence you will see the same in the pictures,

### Creating a Namespace

Namespaces are the way to partition a single Kubernetes cluster into multiple virtual clusters.
It will help us in structuring resources in groups.

```bash
kubectl create namespace cern
```

### Deploying DB

```bash
kubectl apply -f ./k8s/db -n cern
```

![kcl-db](https://lh7-us.googleusercontent.com/nZiLXG-MAuieQU-6c-4i4ai7ln148Gf1lHbrk23gSgSNfySXznRlBOjBVVmn1D4mDvo0dzl2wmYEp2JMzz2uvApesFYdQV_SrGs62YhRh9QKb5RCOqeCoEOlYqfjHd276z22dk_orS33JYg7lPwY-zU)

### Deploying Server

```bash
kubectl apply -f ./k8s/server -n cern
```

![kcl-server](https://lh7-us.googleusercontent.com/19-JuRGUzOHcKlXEz3M3vGS9I2Xp7ykXoj7gug2u-1rd8u9YwnrBptVeJk9pC70YV4TtZUAtse0GG-QNuopJjjZm8eLaqo2DT2PSborbRfEQYPJ-m7BxO_qfUPQ6tzlJ_0Pmt6F7-huJmWh34-qkaPw)

### Deploying Client

```bash
kubectl apply -f ./k8s/client -n cern
```

![kcl-client](https://lh7-us.googleusercontent.com/GAGQaeJt9nBoiML4hg-Xmp_RgoLnZzXnGCK3_G5NiEcSDmTct05Ue0SxhcGItPtXiUlrueT3m0AVV-pWefKEM3aF8SOOsP-HPaJ6s4Y4H-oaUYbsK1iOROG0Hb1BbZtpucH2wrOcRxhewrMuJYyXmAo)

### Checking everything

To check all the resources in the `cern` namespace that we had created we will use the following command.

```bash
kubectl get all -n cern
```

![kcl-everything](https://lh7-us.googleusercontent.com/5ikFiXmCS-9Ky1rEaSw6F7-W0HDS2vpHPBs5YbZP_eiBjLlDQp1JUYsxUb0ooF-3iYivc6LNi6H1G2zJ3hCh4CwsCXYwMoCpSvwtKiyHQtUyPb6_JT19ZbooAIuRLswyUkjskcbxVqHMqEkiQZaqL5M)

### Setting up ingress and Why do we need it?

We could have opened the access via `NodePort` but then we need to open firewall rules to allow access to ports.
Also, it is not a good security practice to do the same. Hence we use `Ingress` controller.

```
kubectl apply -f ./k8s/ingress -n cern
```

![kcl-ingress](https://lh7-us.googleusercontent.com/y_pAu6Ty6uAa0_IRtHBB4XmbqBzaj_l4n97CN3jRGT5gJJrNw6-meg4XRr4hvMIPGsIHZdUEtxFqZso5a85bKEXiG0XuPWjoF8VeD2b3uq3JtRS1dgJ4mNmgy3GO6hUXvXfqA8rhb8hKWaKSOEwq0t0)

#### Adding SSL support

We create a `secret` of special type, i.e., `kubernetes.io/tls` that will have our certificate and key.

```
apiVersion: v1

kind: Secret

metadata:
  name: ing-secret-tls
  namespace: cern

type: kubernetes.io/tls

data:

  # base 64 encoded values of localhost.crt and localhost.key.
  # Eg: cat localhost.key | base64

  tls.crt: "<BASE64 encoded certificate>"
  
  tls.key: "<BASE64 encoded key>"
```

## How to improve and what Can be done better?

Due to my end semester exams going on, I could not perform at my best. 
I believe there were few areas where I could have done better. 

- Hot Code Reloading: I believe there was some issue with websockets else, code changes in my file system were reflecting in the container's file system. Probably making changes in `nginx.conf` file might help. [Refrence](https://github.com/vitejs/vite/discussions/6473#discussioncomment-2548321)
- Packaging the k8s manifests: Would be better to use `heml`, as it gives many functionalities like rollback and seemless install via a sigle command.
- Ingress Controller: I will have to make some changes to ingress so that It will catch up the domain and corresponding IP.
