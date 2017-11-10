FROM centos:7
MAINTAINER The CentOS Project <cloud-ops@centos.org>
LABEL Vendor="CentOS" \
      License=GPLv2 \
      Version=2.4.6-40


ENV DEBIAN_FRONTEND noninteractive
ENV MAVEN_HOME /usr/share/maven

ENV JAVA_VERSION 8
ENV JAVA_UPDATE 152
ENV JAVA_BUILD 16
ENV JAVA_SIG aa0333dd3019491ca4f6ddbe78cdb6d0

ENV JAVA_HOME /usr/lib/jvm/java-${JAVA_VERSION}-oracle

# setup
RUN apt-get update -qq && \
  apt-get upgrade -qqy --no-install-recommends && \
  apt-get install curl unzip bzip2 -qqy
  
# install jdk
RUN mkdir -p "${JAVA_HOME}" && \
  curl --silent --location --insecure --junk-session-cookies --retry 3 \
	  --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
	  http://download.oracle.com/otn-pub/java/jdk/"${JAVA_VERSION}"u"${JAVA_UPDATE}"-b"${JAVA_BUILD}"/"${JAVA_SIG}"/jdk-"${JAVA_VERSION}"u"${JAVA_UPDATE}"-linux-x64.tar.gz \
	| tar -xzC "${JAVA_HOME}" --strip-components=1

RUN update-alternatives --install "/usr/bin/java" "java" "${JAVA_HOME}/bin/java" 1 && \
	update-alternatives --install "/usr/bin/javaws" "javaws" "${JAVA_HOME}/bin/javaws" 1 && \
	update-alternatives --install "/usr/bin/javac" "javac" "${JAVA_HOME}/bin/javac" 1 && \
	update-alternatives --set java "${JAVA_HOME}/bin/java" && \
	update-alternatives --set javaws "${JAVA_HOME}/bin/javaws" && \
	update-alternatives --set javac "${JAVA_HOME}/bin/javac"

# install git
RUN apt-get install git -qqy

# install maven	
RUN mkdir -p "${MAVEN_HOME}" && \
    curl -fsSL http://tux.rainside.sk/apache/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz \
    | tar -xzC "${MAVEN_HOME}" --strip-components=1 && \
    ln -s "${MAVEN_HOME}"/bin/mvn /usr/bin/mvn
  
# clean unused bzip2 is requited for npm
RUN  apt-get remove --purge --auto-remove -y curl unzip && \
     apt-get autoclean && apt-get --purge -y autoremove && \
     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*	
