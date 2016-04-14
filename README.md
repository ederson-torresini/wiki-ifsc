# Como começou
Este projeto visou, inicialmente, atender à [necessidade N.46 do PDTI 2014-2015 do IFSC](http://dtic.ifsc.edu.br/files/pdti-2014-2015-versao-1.pdf): uma [wiki](http://www.mediawiki.org/wiki/MediaWiki) institucional. Assim que a [primeira versão de teste](https://github.com/boidacarapreta/wiki-ifsc/commit/8a995bf579aabe623b76a48b564efc86aabda9a3) ficou pronta, percebi que o ambiente poderia rodar não apenas [Mediawiki](https://mediawiki.org), mas também outras aplicações Web, como [ownCloud](https://owncloud.org). Para ser mais exato, praticamente todas as aplicações Web que já estão em uso no [câmpus São José](http://sj.ifsc.edu.br): [Mediawiki](https://mediawiki.org), [Wordpress](https://wordpress.org), [Moodle](https://moodle.org), entre outros. Isso implicou repensar uma nova arquitetura, não mais estática (quantidade fixa de contêineres, controlados por Puppet), mas elástica. Nessa pesquisa, encontrei o [Kubernetes](https://kubernetes.io). Por consequência, o uso mais intensivo de contêineres e, claro, [CoreOS](https://coreos.com) e [rkt](https://coreos.com/rkt/). E, nesse movimento: [etcd](https://coreos.com/etcd), [flannel](https://coreos.com/flannel/), [cloud-config](https://coreos.com/os/docs/latest/cloud-config.html), [ignition](https://coreos.com/ignition/)...

# Onde chegar
A proposta deste projeto é rodar aplicações Web via [Kubernetes sobre CoreOS](https://coreos.com/kubernetes/) para obter:
- Fácil escalonamento físico (mais máquinas) e lógico (autoescalonamento de contêineres).
- Agendamento e monitoramento de contêineres.
- Atualização dos programas sem queda de serviço (sempre que possível).
- Sistema de arquivos distribuído.
- Balanceamento de carga dos serviços.
- Alta disponibilidade.

Para chegar até esse estado, o primeiro passo é a [instalação e configuração automatizada das máquinas físicas](https://github.com/coreos/coreos-baremetal/): do PXE à instalação do sistema operacional (CoreOS) e serviços básicos.
