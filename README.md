[[_TOC_]]

> 由于`nacos`官方提供的docker镜像不支持`LDAP`登录[^1]，同时部分docker版本在整合`MySQL`时会出现**No DataSource 错误，估计基于官方提供的release版本自己打包为docker镜像

# 打包方式

## 普通登录

```bash
# 不传递登录参数
docker build -t nacos_custom:v1.0 .

# 显示指定登录参数
docker build -t nacos_custom:v1.0 --build-arg LOGIN_TYPE=nacos .
```

## LDAP登录

```bash
docker build -t nacos_custom:v1.0 --build-arg LOGIN_TYPE=ldap .
```

# 使用方式

## 普通账号登录

```yaml
version: "3"
services:
  nacos:
    image: nacos_custom:v1.0
    restart: always
    container_name: nacos_custom
    ports:
      - 8858:8858
    environment:
      - TZ=Asia/Shanghai
      - NACOS_SERVER_PORT=8858
      - SPRING_DATASOURCE_PLATFORM=mysql
      - MYSQL_SERVICE_HOST=xxxx
      - MYSQL_SERVICE_PORT=xxxx
      - MYSQL_SERVICE_DB_NAME=nacos_test
      - MYSQL_SERVICE_USER=root
      - MYSQL_SERVICE_PASSWORD=654321
    volumes:
      - $PWD/logs:/home/nacos/logs/
```

## LDAP单点登录

```yaml
version: "3"
services:
  nacos:
    image: nacos_custom:v1.0
    restart: always
    container_name: nacos_custom
    ports:
      - 8858:8858
    environment:
      - TZ=Asia/Shanghai
      - NACOS_SERVER_PORT=8858
      - SPRING_DATASOURCE_PLATFORM=mysql
      - MYSQL_SERVICE_HOST=xxxx
      - MYSQL_SERVICE_PORT=3316
      - MYSQL_SERVICE_DB_NAME=nacos_test
      - MYSQL_SERVICE_USER=root
      - MYSQL_SERVICE_PASSWORD=xxxx
      - LDAP_URL=ldap://xxxx:389
      - LDAP_BASE_DC=dc=xxx,dc=xxx
      - LDAP_USER_DN=cn=xxx,dc=xxx,dc=com
      - LDAP_USER_PASSWORD=xxxx
      - LDAP_UID=uid
      - LDAP_CASE_SENSITIVE=false
    volumes:
      - $PWD/logs:/home/nacos/logs/
```

[^1]: https://github.com/alibaba/nacos/issues/9751

