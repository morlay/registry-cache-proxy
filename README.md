# Registry Cache Proxy

* setup k8s first (k3s for single node)
* install helm

```
git clone https://github.com/morlay/registry-cache-proxy.git

export DOCKER_USERNAME=xxx
export DOCKER_PASSOWRD=xxx

make crs DEBUG=0 BASE_HOST=x.io
make npm DEBUG=0 BASE_HOST=x.io
```

added A-records for `BASE_HOST` on cloudflare or some CDN provdier support `*.BASE_HOST` like aliyun.