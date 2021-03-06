/* default stack sizes. 

These are used by the startup in order to allocate stacks for the different modes.
*/

__Stack_Size = 0x500 ;

PROVIDE ( _Stack_Size = __Stack_Size ) ;

__Stack_Init = 0x20000000;

_estack = __Stack_Init + __Stack_Size;

/*"PROVIDE" allows to easily override these values from an object file or the commmand line.*/
PROVIDE ( _Stack_Init = __Stack_Init ) ;


/* Sections management for FLASH mode */

/* Sections Definitions */

SECTIONS
{

    /* for Cortex devices, the beginning of the startup code is stored in the .isr_vector section, which goes to FLASH */
    
    .isr_vector (DEFINED(ST_BTL) ? (0x08000000 + _BOOTLOADER_SIZE) : 0x08000000) :
    {
	. = ALIGN(4);
	__ApplicationFlashStart = . ;
	/*	. = . + _ROM_base ;*/
        KEEP(*(.isr_vector))            /* Startup code */
	. = ALIGN(4);
    } >ROM_region
 
    /* for some STRx devices, the beginning of the startup code is stored in the .flashtext section, which goes to FLASH */
    .flashtext :
    {
	. = ALIGN(4);
        *(.flashtext)            /* Startup code */
	. = ALIGN(4);
    } >ROM_region
 
    /* the program code is stored in the .text section, which goes to Flash */
    .text :
    {
	    . = ALIGN(4);
	    
        *(.text)                   /* remaining code */
        *(.text.*)                   /* remaining code */
        *(.rodata)                 /* read-only data (constants) */
        *(.rodata*)
        *(.glue_7)
        *(.glue_7t)

	    . = ALIGN(4);
   	 _etext = .;
	    /* This is used by the startup in order to initialize the .data section */
   	 _sidata = _etext;
    } >ROM_region
    /*
    NVM (NOLOAD):
    {
      . = ALIGN(1024);
      *(NVM)
      . = ALIGN(4);
    } > NVM_region
    */
    /* This is to emulate place at end of IAR linker */
    NVM (ORIGIN(ROM_region) + LENGTH(ROM_region) - _NVM_size) (NOLOAD):
    {
     *(NVM)
    } > ROM_region
    FAT (NOLOAD) :
    {
      . = ALIGN(4);
      KEEP(*(FAT))
      . = ALIGN(4);
    } > FIB_region

/*
    .FAT (NOLOAD):
    {
      KEEP(*(.FAT))
    } > FIB_region
*/
    /* after that it's only debugging information. */
    

    /* This is the initialized data section
    The program executes knowing that the data is in the RAM
    but the loader puts the initial values in the FLASH (inidata).
    It is one task of the startup to copy the initial values from FLASH to RAM. */
    .data _estack : AT ( _sidata )
    {
	    . = ALIGN(4);
        /* This is used by the startup in order to initialize the .data section */
        _sdata = . ;
        
        *(.data)
        *(.data.*)

	    . = ALIGN(4);
	    /* This is used by the startup in order to initialize the .data section */
   	 _edata = . ;
    } >RAM_region
    

    /* This is the uninitialized data section */
    .bss :
    {
	    . = ALIGN(4);
        /* This is used by the startup in order to initialize the .bss section */
        _sbss = .;
        
        *(.bss)
        *(.bss.*)
        *(COMMON)
        
	    . = ALIGN(4);
	    /* This is used by the startup in order to initialize the .bss section */
   	 _ebss = . ;
    } >RAM_region
    
    PROVIDE ( end = _ebss );
    PROVIDE ( _end = _ebss );
       
    __exidx_start = .;
    __exidx_end = .;

    /* remove the debugging information from the standard libraries */
    /DISCARD/ :
    {
     libc.a ( * )
     libm.a ( * )
     libgcc.a ( * )
     }

    /* Stabs debugging sections.  */
    .stab          0 : { *(.stab) }
    .stabstr       0 : { *(.stabstr) }
    .stab.excl     0 : { *(.stab.excl) }
    .stab.exclstr  0 : { *(.stab.exclstr) }
    .stab.index    0 : { *(.stab.index) }
    .stab.indexstr 0 : { *(.stab.indexstr) }
    .comment       0 : { *(.comment) }
    /* DWARF debug sections.
       Symbols in the DWARF debugging sections are relative to the beginning
       of the section so we begin them at 0.  */
    /* DWARF 1 */
    .debug          0 : { *(.debug) }
    .line           0 : { *(.line) }
    /* GNU DWARF 1 extensions */
    .debug_srcinfo  0 : { *(.debug_srcinfo) }
    .debug_sfnames  0 : { *(.debug_sfnames) }
    /* DWARF 1.1 and DWARF 2 */
    .debug_aranges  0 : { *(.debug_aranges) }
    .debug_pubnames 0 : { *(.debug_pubnames) }
    /* DWARF 2 */
    .debug_info     0 : { *(.debug_info .gnu.linkonce.wi.*) }
    .debug_abbrev   0 : { *(.debug_abbrev) }
    .debug_line     0 : { *(.debug_line) }
    .debug_frame    0 : { *(.debug_frame) }
    .debug_str      0 : { *(.debug_str) }
    .debug_loc      0 : { *(.debug_loc) }
    .debug_macinfo  0 : { *(.debug_macinfo) }
    /* SGI/MIPS DWARF 2 extensions */
    .debug_weaknames 0 : { *(.debug_weaknames) }
    .debug_funcnames 0 : { *(.debug_funcnames) }
    .debug_typenames 0 : { *(.debug_typenames) }
    .debug_varnames  0 : { *(.debug_varnames) }
}

__ApplicationFlashEnd = _sidata + (_edata - _sdata);
__RAMStart = __Stack_Init;
__RAMEnd = _ebss;

