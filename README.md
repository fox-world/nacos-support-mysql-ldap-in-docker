# 背景

> 由于`nacos`官方提供的docker镜像不支持`LDAP`登录[^1]，同时部分docker版本在整合`MySQL`时会出现**No DataSource** 错误，基于官方提供的release版本自己打包为docker镜像

# 构建方式

说明： 在构建时需要将`Dockerfile`、`docker-startup.sh`以及对应的`nacos`压缩文件放到同一个目录下

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

# 参数说明

| 属性                       | 作用                     | 默认值 | 可选值      |
| -------------------------- | ------------------------ | ------ | ----------- |
| NACOS_SERVER_PORT          | nacos服务器端口          | 8848   |             |
| SPRING_DATASOURCE_PLATFORM | 指定nacos的数据源        | mysql  | `mysql`或空 |
| MYSQL_SERVICE_HOST         | mysql服务器地址          |        |             |
| MYSQL_SERVICE_PORT         | mysql服务器端口          | 3306   |             |
| MYSQL_SERVICE_DB_NAME      | mysql数据库名称          |        |             |
| MYSQL_SERVICE_USER         | mysql数据库用户名        | root   |             |
| MYSQL_SERVICE_PASSWORD     | mysql数据据密码          |        |             |
| LDAP_URL                   | ldap服务的地址和端口号   |        |             |
| LDAP_BASE_DC               | ldap搜索范围             |        |             |
| LDAP_USER_DN               | ldap绑定账号[^2]         |        |             |
| LDAP_USER_PASSWORD         | ldap绑定账号的密码       |        |             |
| LDAP_UID                   | 用户账号字段             |        |             |
| LDAP_CASE_SENSITIVE        | ldap认证时是否大小写敏感 |        |             |

[^1]: https://github.com/alibaba/nacos/issues/9751
[^2]: 部分`LDAP`数据库不支持匿名登录，此时需要管理员账号来绑定登录