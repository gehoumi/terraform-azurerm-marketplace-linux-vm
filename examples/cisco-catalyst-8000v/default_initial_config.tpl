! The following is a sample configuration file for reference only.
!
!
interface GigabitEthernet1
 description "attached to Nic0 in Azure, the First subnet"
 ip address dhcp
 no shutdown
!
interface GigabitEthernet2
 description "attached to Nic2 in Azure, the Third subnet"
 ip address dhcp
 no shutdown
!
interface GigabitEthernet3
 description "attached to Nic2 in Azure, the Third subnet"
 ip address dhcp
 no shutdown
!
interface GigabitEthernet4
 description "attached to Nic3 in Azure, the Fourth subnet"
 ip address dhcp
 no shutdown
!


