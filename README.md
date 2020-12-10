# Registry Cache Proxy

install helm & docker

```
git clone https://github.com/morlay/registry-cache-proxy.git

export BASE_HOST=xxx
export DOCKER_USERNAME=xxx
export DOCKER_PASSOWRD=xxx
DEBUG=0 make vhost crs npm
```

added A-records for `BASE_HOST` on cloudflare or some CDN provdier support `*.BASE_HOST` like aliyun.