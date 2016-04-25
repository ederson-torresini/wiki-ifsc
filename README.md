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

# Rede
Conforme as políticas de VLAN do IFSC, a rede está dividida em 3 redes virtuais para atender ao cenário:
- 110: acesso externo às aplicações Web.
- 111: instalação, configuração e aglomeração (_cluster_) das máquinas físicas, o que inclui [PXE](https://coreos.com/os/docs/latest/booting-with-pxe.html), [iPXE](https://coreos.com/os/docs/latest/booting-with-ipxe.html), [DHCP](https://github.com/coreos/coreos-baremetal/tree/master/contrib/dnsmasq), [bootcfg](https://github.com/coreos/coreos-baremetal/blob/master/Documentation/bootcfg.md) e [etcd](https://coreos.com/etcd).
- 900: acesso externo às máquinas físicas, o que inclui [Intel IPMI](http://www.intel.com/content/www/us/en/servers/ipmi/ipmi-home.html), [IBM IMM](https://lenovopress.com/tips0849), [HP iLO](http://www.hp.com/go/iLO/docs), [Dell iDRAC](http://www.dell.com/learn/us/en/555/solutions/integrated-dell-remote-access-controller-idrac) e SSH.

Temporariamente, há um switch Cisco Catalyst 2960 interligando todas as máquinas físicas. Como aquele não permite alternância de bonding/EtherChannel na mesma porta (com ou sem LACP), a solução adotada é de utilizar:
- Primeira máquina, `coreos-0`, com todas as [interfaces agregadas](https://coreos.com/ignition/docs/latest/network-configuration.html#bonded-nics), uma vez que é o servidor DHCP e bootcfg.
- Para toas as outras máquinas: a primeira interface de rede para a VLAN 111 e demais interfaces agregadas para VLANs 110 e 900.

Para o ambiente de produção, esperam-se 10 máquinas físicas. Por enquanto, estão alocadas para o projeto 4 máquinas físicas. Assim, a configuração do switch está assim definida:
- Máquina `coreos-0`: interfaces `GigabitEthernet0/1` e `0/2` agregadas (`Port-Channel1`) e VLANs etiquetadas (_ tagged VLANs_) 110, 111 e 900.
```
interface Port-channel1
    description coreos-0
    switchport trunk allowed vlan 110,111,900
    switchport mode trunk
!
interface GigabitEthernet0/1
    description coreos-0 - COM PROBLEMA
    switchport trunk allowed vlan 110,111,900
    switchport mode trunk
    channel-group 1 mode active
    shutdown
!
interface GigabitEthernet0/2
    description coreos-0
    switchport trunk allowed vlan 110,111,900
    switchport mode trunk
    channel-group 1 mode active
```
- Máquina `coreos-1`: interface `GigabitEthernet0/3` com VLAN 111 não etiquetada (_untagged VLAN_), e interfaces `GigabitEthernet0/4` e `0/5` agregadas (`Port-Channel2`) e VLANs etiquetadas 110 e 900.
```
interface Port-channel2
    description coreos-1
    switchport trunk allowed vlan 110,900
    switchport mode trunk
!
interface GigabitEthernet0/3
    description coreos-1
    switchport access vlan 111
    switchport mode access
    spanning-tree portfast
!
interface GigabitEthernet0/4
    description coreos-1
    switchport trunk allowed vlan 110,900
    switchport mode trunk
    channel-group 2 mode active
!
interface GigabitEthernet0/5
    description coreos-1
    switchport trunk allowed vlan 110,900
    switchport mode trunk
    channel-group 2 mode active
```
- Máquina `coreos-2`: interface `GigabitEthernet0/6` com VLAN 111 não etiquetada (_untagged VLAN_), e interfaces `GigabitEthernet0/7` e `0/8` agregadas (`Port-Channel3`) e VLANs etiquetadas 110 e 900.
```
interface Port-channel3
    description coreos-2
    switchport trunk allowed vlan 110,900
    switchport mode trunk
!
interface GigabitEthernet0/6
    description coreos-2
    switchport access vlan 111
    switchport mode access
    spanning-tree portfast
!
interface GigabitEthernet0/7
    description coreos-2
    switchport trunk allowed vlan 110,900
    switchport mode trunk
    channel-group 3 mode active
!
interface GigabitEthernet0/8
    description coreos-2
    switchport trunk allowed vlan 110,900
    switchport mode trunk
    channel-group 3 mode active
```
- Máquina `coreos-3`: interface `GigabitEthernet0/9` com VLAN 111 não etiquetada (_untagged VLAN_), e interfaces `GigabitEthernet0/10` e `0/11` agregadas (`Port-Channel4`) e VLANs etiquetadas 110 e 900.
```
interface Port-channel4
    description coreos-3
    switchport trunk allowed vlan 110,900
    switchport mode trunk
!
interface GigabitEthernet0/9
    description coreos-3
    switchport access vlan 111
    switchport mode access
    spanning-tree portfast
!
interface GigabitEthernet0/10
    description coreos-3
    switchport trunk allowed vlan 110,900
    switchport mode trunk
    channel-group 3 mode active
!
interface GigabitEthernet0/11
    description coreos-3
    switchport trunk allowed vlan 110,900
    switchport mode trunk
    channel-group 3 mode active
```
Por fim, a interface de conexão com a rede do câmpus (_uplink_). A interface `GigabitEthernet0/24` e VLANs etiquetadas 110 e 900:
```
interface GigabitEthernet0/24
    switchport trunk allowed vlan 110,900
    switchport mode trunk
```

# Máquinas físicas
Em `coreos-0`, foi [iniciado o CoreOS](https://coreos.com/os/docs/latest/booting-with-iso.html) e feita a [instalação e configuração manual](https://coreos.com/os/docs/latest/installing-to-disk.html). No arquivo único de configuração,  `coreos-0.yaml`, tem-se:
- Minha chave pública para acesso via SSH.
- Configuração das interfaces de rede, incluindo agregada e VLANs.
- Sincronização de reógio por NTP.
- Roteamento e NAT para provisionamento.
- Configuração do etcd2.

Essa máquina é o servidor DHCP/PXE/iPXE e bootcfg para [provisionamento das outras máquinas](https://github.com/coreos/coreos-baremetal), cujos serviços estão implementados (por enquanto) com Docker (e fortemente baseados no projeto [coreos-baremetal](https://github.com/coreos/coreos-baremetal)):
- dnsmasq:
```bash
cd wiki-ifsc/docker/dnsmasq
chmod 0700 get-tftp-files
./get-tftp-files
docker run -d --restart=always --name=dnsmasq --net=host \
--cap-add=NET_ADMIN -v ${PWD}/tftpboot:/var/lib/tftpboot:ro \
quay.io/coreos/dnsmasq -d --log-queries --log-dhcp --interface=vlan111 \
--enable-tftp --tftp-root=/var/lib/tftpboot \
--dhcp-userclass=set:ipxe,iPXE \
--dhcp-boot=tag:ipxe,http://172.18.111.100:8080/boot.ipxe \
--dhcp-boot=tag:#ipxe,undionly.kpxe,172.18.111.100,172.18.111.100 \
--dhcp-range=172.18.111.201,172.18.111.206 \
--dhcp-option=3,172.18.111.100
```
- bootcfg:
```bash
cd wiki-ifsc/docker/bootcfg
chmod 0700 get-coreos
./get-coreos
docker run -d --restart=always --name=bootcfg --net=host \
-v ${PWD}/data:/data:Z -v ${PWD}/assets:/assets:Z \
quay.io/coreos/bootcfg \
-address=0.0.0.0:8080 -log-level=debug --config /data/ifsc.yaml
```

Nota: antes de iniciar a máquina nova, deve-se adicionar, em `coreos-0`, a máquina nova à aglomeração:
```
etcdctl member add <nome_da_máquina> <peerURL>
```
Exemplo:
```
etcdctl member add coreos-1 http://172.18.111.101:2380
```
