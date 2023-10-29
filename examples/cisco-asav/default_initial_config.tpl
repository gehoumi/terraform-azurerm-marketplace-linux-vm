! The following is a sample configuration file for reference only.
!
interface GigabitEthernet0/0
 no shutdown
 description "attached to Nic1 in Azure, the Second subnet"
 ip address dhcp 
!
interface GigabitEthernet0/1
 no shutdown
 description "attached to Nic2 in Azure, the Third subnet"
 ip address dhcp 
!
interface GigabitEthernet0/2
 no shutdown
 description "attached to Nic3 in Azure, the Fourth subnet"
 ip address dhcp 
!
!interface Management0/0
! no management-only
! nameif management
! security-level 0
! ip address dhcp setroute
! description "attached to Nic0 in Azure, the First subnet"

