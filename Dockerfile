FROM openjdk:8-jdk
MAINTAINER 卢运强 "yunqiang.lu@hirain.com"

RUN echo $JAVA_HOME

#ENV BASE_DIR="/home/nacos"
ENV MODE="standalone" \
    PREFER_HOST_MODE="ip"\
    BASE_DIR="/home/nacos" \
    CLASSPATH=".:/home/nacos/conf:$CLASSPATH" \
    FUNCTION_MODE="all" \
    JAVA_HOME="/usr/local/openjdk-8" \
    NACOS_USER="nacos" \
    JAVA="/usr/local/openjdk-8/bin/java" \
    JVM_XMS="1g" \
    JVM_XMX="1g" \
    JVM_XMN="512m" \
    JVM_MS="128m" \
    JVM_MMS="320m" \
    NACOS_DEBUG="y" \
    TOMCAT_ACCESSLOG_ENABLED="false" \
    TIME_ZONE="Asia/Shanghai"

# 在联网环境下可以通过wget直接下载压缩文件
COPY nacos-server-2.2.1.tar.gz /home/nacos-server-2.2.1.tar.gz
WORKDIR /home

RUN echo "解压nacos文件"
RUN tar -zxvf nacos-server-2.2.1.tar.gz
RUN rm -rf nacos-server-2.2.1.tar.gz nacos/conf/*.sql nacos/conf/*.example nacos/bin/*
COPY docker-startup.sh /home/nacos/bin/docker-startup.sh

RUN mkdir -p /home/nacos/logs


#开始修改配置文件
ARG conf=nacos/conf/application.properties
RUN sed -i "s/server.servlet.contextPath=\/nacos/server.servlet.contextPath=\${SERVER_SERVLET_CONTEXTPATH:\/nacos}/g" $conf
RUN sed -i "s/server.port=8848/server.port=\${NACOS_SERVER_PORT:8848}/g" $conf
#RUN sed -i "s/\#.*spring.datasource.platform=mysql/spring.datasource.platform=\${SPRING_DATASOURCE_PLATFORM:\"mysql\"}/g" $conf
RUN sed -i "s/\#.*spring.sql.init.platform=mysql/spring.sql.init.platform=\${SPRING_DATASOURCE_PLATFORM:mysql}/g" $conf
RUN sed -i "s/\#.*db.num=1/db.num=1/g" $conf
RUN sed -i "s/\#.*db.url.0.*/db.url.0=jdbc:mysql:\/\/\${MYSQL_SERVICE_HOST}:\${MYSQL_SERVICE_PORT:3306}\/\${MYSQL_SERVICE_DB_NAME}\?characterEncoding=utf8\&connectTimeout=1000\&socketTimeout=3000\&autoReconnect=true/g" $conf
RUN sed -i "s/\#.*db.user.0=nacos/db.user=\${MYSQL_SERVICE_USER:root}/g" $conf
RUN sed -i "s/\#.*db.password.0=nacos/db.password=\${MYSQL_SERVICE_PASSWORD}/g" $conf
RUN sed -i "s/.*server.tomcat.accesslog.enabled.*/server.tomcat.accesslog.enabled=\${TOMCAT_ACCESSLOG_ENABLED:false}/g" $conf
RUN sed -i "s/.*nacos.core.auth.plugin.nacos.token.secret.key=.*/nacos.core.auth.plugin.nacos.token.secret.key=SecretKey012345678901234567890123456789012345678901234567890123456789/g" $conf

ARG LOGIN_TYPE=nacos
RUN sed -i "s/nacos.core.auth.system.type=.*/nacos.core.auth.system.type=${LOGIN_TYPE}/g" $conf
RUN if [ $LOGIN_TYPE = "nacos" ];then echo "基于普通登录方式构建";else echo "基于ldap登录方式构建"; fi

# ldap登录认证方式的额外处理
RUN if [ $LOGIN_TYPE = "ldap" ];then sed -i "s/\#nacos.core.auth.ldap.url=.*/nacos.core.auth.ldap.url=\${LDAP_URL}/g" $conf; fi
RUN if [ $LOGIN_TYPE = "ldap" ];then sed -i "s/\#nacos.core.auth.ldap.basedc=.*/nacos.core.auth.ldap.basedc=\${LDAP_BASE_DC}/g" $conf; fi
RUN if [ $LOGIN_TYPE = "ldap" ];then sed -i "s/\#nacos.core.auth.ldap.userDn=.*/nacos.core.auth.ldap.userDn=\${LDAP_USER_DN}/g" $conf; fi
RUN if [ $LOGIN_TYPE = "ldap" ];then sed -i "s/\#nacos.core.auth.ldap.password=.*/nacos.core.auth.ldap.password=\${LDAP_USER_PASSWORD}/g" $conf; fi
RUN if [ $LOGIN_TYPE = "ldap" ];then sed -i "s/\#nacos.core.auth.ldap.filter.prefix=.*/nacos.core.auth.ldap.filter.prefix=\${LDAP_UID}/g" $conf; fi
RUN if [ $LOGIN_TYPE = "ldap" ];then sed -i "s/\#nacos.core.auth.ldap.case.sensitive=.*/nacos.core.auth.ldap.case.sensitive\${LDAP_CASE_SENSITIVE}/g" $conf; fi

RUN chmod +x /home/nacos/bin/docker-startup.sh

ENTRYPOINT ["/bin/bash","/home/nacos/bin/docker-startup.sh","-m","standalone"]
