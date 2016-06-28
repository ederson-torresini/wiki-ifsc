# Como começou
Este projeto visou, inicialmente, atender à [necessidade N.46 do PDTI 2014-2015 do IFSC](http://dtic.ifsc.edu.br/files/pdti-2014-2015-versao-1.pdf): uma [wiki](http://www.mediawiki.org/wiki/MediaWiki) institucional.
Assim que a [primeira versão de teste](https://github.com/boidacarapreta/wiki-ifsc/commit/8a995bf579aabe623b76a48b564efc86aabda9a3) ficou pronta, percebi que o ambiente poderia rodar não apenas [Mediawiki](https://mediawiki.org), mas também outras aplicações Web, como por exemplo [ownCloud](https://owncloud.org).
Para ser mais exato, praticamente todas as aplicações Web que já estão em uso no [câmpus São José](http://sj.ifsc.edu.br).
Isso implicou repensar uma nova arquitetura, não mais estática (quantidade fixa de contêineres, controlados por Puppet), mas elástica.
Nessa pesquisa, encontrei o [Kubernetes](https://kubernetes.io).
Por consequência, o uso mais intensivo de contêineres e, claro, [CoreOS](https://coreos.com) e [rkt](https://coreos.com/rkt/).
E, nesse movimento: [etcd](https://coreos.com/etcd), [flannel](https://coreos.com/flannel/), [cloud-config](https://coreos.com/os/docs/latest/cloud-config.html), [ignition](https://coreos.com/ignition/)...

# Onde chegar
A proposta deste projeto é rodar aplicações Web via [Kubernetes sobre CoreOS](https://coreos.com/kubernetes/) para obter:
- Fácil escalonamento físico (mais máquinas) e lógico (autoescalonamento de contêineres).
- Agendamento e monitoramento de contêineres.
- Atualização dos programas sem queda de serviço (sempre que possível).
- Sistema de arquivos distribuído.
- Balanceamento de carga dos serviços.
- Alta disponibilidade.

E por que exatamente Web?
- Suporte a [HTTP/2](https://http2.github.io), o que significa uma única conexão e mútltiplos fluxos de dados, compressão, etc.
- Segurança no transporte fim-a-fim, com TLS.
- _Caching_ de arquivos estáticos como imagens e folhas de estilo, conteúdo dinâmico.
- Monitoramento de _backends_ em termos de disponibilidade e mesmo latência.

Para tanto, há as ferramentas de apoio ao ambiente, tais como:
- [NGINX](https://nginx.com)
- [Prometheus](https://prometheus.io)

Dessa forma, espera-se (em breve, espero) rodar as aplicações de interesse do câmpus:
- [Puppet](https://puppet.com)
- [Mediawiki](https://www.mediawiki.org)
- [Moodle](https://moodle.org)
- [Wordpress](https://wordpress.org)
- [ShareLaTeX](https://www.sharelatex.com)
- [Owncloud](https://owncloud.org)
- [GitLab](https://gitlab.com)
- [Gerrit](https://www.gerritcodereview.com)
- [Jenkins](https://jenkins.io)
- [Eclipse Che](https://eclipse.org/che/)
- [Codenvy](https://codenvy.com)
- [Rocket Chat](https://rocket.chat)
- [Etherpad](http://etherpad.org)

Para chegar até esse estado, o primeiro passo é configuração mínima dos sistemas operacionais (CoreOS) em rede.

# Máquinas físicas
Nas máquinas `coreos-0`, `coreos-1` e `coreos-2`, foi [iniciado o CoreOS](https://coreos.com/os/docs/latest/booting-with-iso.html) e feita a [instalação e configuração manual](https://coreos.com/os/docs/latest/installing-to-disk.html) (arquivos `coreos/coreos-*.yaml`):
- Minha chave pública para acesso via SSH.
- Configuração da interface de rede.
- Sincronização de relógio por NTP.
- Rede virtual para os contêineres usando [VXLAN](https://tools.ietf.org/html/rfc7348).

# Contêineres
Para fins de documentação, estão abaixo listadas as [variáveis](https://coreos.com/kubernetes/docs/latest/getting-started.html) usadas neste cenário, considerando 3 máquinas já em operação (`coreos-0`, `coreos-1` e `coreos-2`):
- MASTER_HOST: `200.135.37.93`
- ETCD_ENDPOINTS:  `http://200.135.37.93:2380,http://200.135.37.94:2380,http://200.135.37.95:2380`
- POD_NETWORK: `10.0.0.0/16`
- SERVICE_IP_RANGE: `10.1.0.0/16`
- K8S_SERVICE_IP: `10.1.0.1`
- DNS_SERVICE_IP: `10.1.0.2`
- CLUSTER_DOMAIN: `ifsc-sj.local`

No diretório `kubernetes` há o arquivo `Makefile` que auxilia a criação dos certificados necessários ao ambiente, conforme [documentação](https://coreos.com/kubernetes/docs/latest/openssl.html).
