# QUESTÕES SOBRE COMO BOOTAR O KERNEL
- [ ] Quais as expectativas do kernel acerca
   do estado da memória e da CPU?
- [ ] Como passar parâmetros de linha de comando para o kernel? 
    - [X] initrd => offsets 0x0218 e 0x021C no arquivo de modo real do kernel (/init)
    - [ ] rdinit => ? (/bin/sh)
- [ ] Como encontrar o entry point do kernel?

---

    
# Write Fields in Real Mode Kernel Header:
- type_of_loader        | obligatory
- ramdisk_image         | obligatory
- ramdisk_size          | obligatory
- heap_end_ptr          | obligatory
- ext_loader_ver        | optional
- hardware_subarch      | optional, defaults to x86/PC
- hardware_subarch_data | subarch-dependent 
- setup_data            | special


