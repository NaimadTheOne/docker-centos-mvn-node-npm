FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive
ENV MAVEN_HOME /usr/share/maven

ENV JAVA_VERSION 8
ENV JAVA_UPDATE 152
ENV JAVA_BUILD 16
ENV JAVA_SIG aa0333dd3019491ca4f6ddbe78cdb6d0

ENV JAVA_HOME /usr/lib/jvm/java-${JAVA_VERSION}-oracle

ENV PHANTOMJS_HOME /usr/share/phantomjs

# setup
RUN apt-get update -qq && \
  apt-get upgrade -qqy --no-install-recommends && \
  apt-get install curl unzip bzip2 sudo -qqy
  
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

# check java installation
RUN echo "Testing java installation" && java -version  

# install git
RUN apt-get install git -qqy

# check git installation
RUN echo "Testing git installation" && git --version 

# install maven	
RUN mkdir -p "${MAVEN_HOME}" && \
    curl -fsSL http://tux.rainside.sk/apache/maven/maven-3/3.5.2/binaries/apache-maven-3.5.2-bin.tar.gz \
    | tar -xzC "${MAVEN_HOME}" --strip-components=1 && \
    ln -sf "${MAVEN_HOME}"/bin/mvn /usr/bin/mvn
  
# check maven installation
RUN echo "Testing maven installation" && mvn --version 

# install nodejs
RUN curl -sSL https://deb.nodesource.com/setup_8.x | sudo -E bash - && \
    sudo apt-get install -y nodejs && \
    sudo apt-get install -y build-essential

# check node and npm installation
RUN echo "Testing node installation" && node -v && npm -v

# install Phantom JS 2
RUN sudo apt-get install build-essential chrpath libssl-dev libxft-dev -y && \
    sudo apt-get install libfreetype6 libfreetype6-dev -y && \
    sudo apt-get install libfontconfig1 libfontconfig1-dev -y


RUN mkdir -p "${PHANTOMJS_HOME}" && \
    curl -sSL https://github.com/Medium/phantomjs/releases/download/v2.1.1/phantomjs-2.1.1-linux-x86_64.tar.bz2 \
    | tar -xjC "${PHANTOMJS_HOME}" --strip-components=1 && \
    ln -sf "${PHANTOMJS_HOME}"/bin/phantomjs /usr/bin/phantomjs
    

# check phantom instalation
RUN echo "Testing phantom installation" && phantomjs --version

# clean
RUN  apt-get remove --purge --auto-remove -y curl unzip bzip2 && \
     apt-get autoclean && apt-get --purge -y autoremove && \
     rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*	


# installing angular-cli globally
RUN echo "Installing angular-cli for global use"
RUN sudo node -c "npm install -g @angular/cli@$1.2.7"

# check angular-cli installation
RUN echo "Testing CLI installation" && ng --version     
