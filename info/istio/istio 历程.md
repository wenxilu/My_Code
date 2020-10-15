[toc]

---

# 概述
```
istio : 服务治理
k8s   : 服务部署运维
```

## 服务治理发展
服务治理发展 : `代码实现 --> SDK --> ServiceMesh`

## Architecture

![](https://istio.io/v1.6/docs/ops/deployment/architecture/arch.svg)



![](https://istio.io/v1.4/docs/ops/deployment/architecture/arch.svg)

### Control Plan
#### Pilot
![](https://istio.io/v1.4/docs/ops/deployment/architecture/discovery.svg)

Config data to proxies   
主要用来配置一些服务路由规则到proxy,  比如会获取k8s endpoint 元信息, 自定义


##### 服务发现
pilot-discovery : 
:   https://istio.io/latest/docs/reference/commands/pilot-discovery/
:   https://istio-releases.github.io/v0.1/docs/concepts/traffic-management/load-balancing.html
:   https://zhaohuabing.com/post/2018-09-25-istio-traffic-management-impl-intro/

![](https://istio-releases.github.io/v0.1/docs/concepts/traffic-management/img/manager/LoadBalancing.svg)


Pilot 服务发现机制的Adapter机制:
:    数据面的envoy 与控制面的Pilot 链接, Pilot 通过 Platform Adapter 获取对接到平台上的数据,实现服务发现.
    
:    Pilot 只是服务发现的定义, 并没有服务发现的实现, 服务发现的实现是通过 Platform Adapter 对接的平台完成的(kubernetes, Eureka, consul, CloudFoundry, )



kubernetes & istio 服务模型对照




```
istio : 
    service
        instance

k8s :
    service
        endpoint


istio :
    service
        version

k8s :
    service
        Deployment


提示:
    istio 的service 就是 k8s 的service
```
##### 服务访问规则维护和工作机制
![Communication between services](https://istio-releases.github.io/v0.1/docs/concepts/traffic-management/img/manager/ServiceModel_Versions.svg)

真正去做服务治理或要对envoy做控制的时, 我们需要在控制面去维护这些规则, 把这些规则下发到envoy上去,让envoy去做执行.

管理员会在控制面上配置一堆规则描述(manifest), 数据面的envoy 这个 proxy 就会通过grpc获取到这个规则描述. 从而进行规则治理.

一般流程是:
:   配置: 管理员通过pilot配置治理规则.
:   下发: Envoy通过grpc从pilot获取规则.
:   执行: 在流量访问的时候执行治理规则.


问题思考:
    服务治理是在服务的发起方还是服务的调用方.
    


**治理规则 :**
:   * VirutalService
    * DestinationRule
    * Gateway
    * ServiceEntry
    * ...

#### Mixer
Policy Checks [服务间通信策略]  
telemetry [监控, 调用链分析]



#### Citadel
![](https://istio.io/v1.4/docs/concepts/security/architecture.svg)


TLS certs to proxies


#### Galley
Galley is Istio’s configuration validation, ingestion, processing and distribution component. It is responsible for insulating the rest of the Istio components from the details of obtaining user configuration from the underlying platform (e.g. Kubernetes).

### Data Plan
#### Envoy
Envoy 官网 : https://www.envoyproxy.io/

* 基于c++的 L4/L7 Proxy转发器
* CNCF 第三个毕业项目


**Envoy 里的四个概念**
```
Listeners (LDS)
Routes (RDS)
Clusters (CDS)
Endpoints (EDS)
```


# 安装 & 卸载
## 安装
### istioctl install
```
manifest apply --set profile=dem
```

创建的内容:
```
CustomResourceDefinition
    mixer            mixer-adapter
    istio-pilot 

ValidatingWebhookConfiguration
    istiod-istio-system

MutatingWebhookConfiguration
    istio-sidecar-injector

PodDisruptionBudget
    istio-egressgateway
    istio-ingressgateway
    istiod

Role
    istio-egressgateway-sds
    istio-ingressgateway-sds
    istiod-istio-system

RoleBinding
    istio-egressgateway-sds
    istio-ingressgateway-sds
    istiod-istio-system


ClusterRole
    istio-reader-istio-system
    istiod-istio-system
    
ClusterRoleBinding
    istio-reader-istio-system
    istiod-pilot-istio-system


ServiceAccount
    istio-egressgateway-service-account
    istio-ingressgateway-service-account
    istio-reader-service-account
    istiod-service-account



Deployment
    istio-egressgateway
    istio-ingressgateway
    istiod
    

Service
    istio-egressgateway
    istio-ingressgateway
    istiod
    

ConfigMap
    istio
    istio-sidecar-injector



EnvoyFilter
    metadata-exchange-1.6
    metadata-exchange-1.7
    stats-filter-1.6
    stats-filter-1.7
    tcp-metadata-exchange-1.6
    tcp-metadata-exchange-1.7
    tcp-stats-filter-1.6
    tcp-stats-filter-1.7
    
```

### Helm

```
wget https://get.helm.sh/helm-v3.3.3-linux-amd64.tar.gz
tar xfzv helm-v3.3.3-linux-amd64.tar.gz
cd istio-1.6.8
kubectl apply -f ./manifests/charts/base/templates/crds.yaml
helm template install/kubernetes/helm/istio --name istio --namespace istio-system > $HOME/istio.yaml
kubectl create namespace istio-system
kubectl apply -f $HOME/istio.yaml


```

## 卸载
```
istioctl manifest generate --set profile=demo | kubectl delete -f -
```



# bookinfo

![](https://istio.io/v1.6/docs/examples/bookinfo/noistio.svg)


![](https://istio.io/v1.6/docs/examples/bookinfo/withistio.svg)

```

```



# Traffic Management
## VirtualService
服务访问路由控制. 控制满足特定条件的请求的流向.治理的规则包括: 请求重写, 重试, 故障注入等.


## DestinationRule
目标服务的策略, 包括目标服务的负载均衡, 链接池管理等.

## Gateway
## ServiceEntry




```
istioctl register -n vm mysqldb <ip-address-of-vm> 3306
```