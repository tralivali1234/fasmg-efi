include 'x64.inc'
include 'efi.inc'
include 'format/format.inc'

format pe64 dll efi
entry efi_main

section '.text' code executable readable
efi_main:
	sub rsp, 4*8;

	mov [Handle], rcx
	mov [SystemTable], rdx

;	SystemTable->ConOut->OutputString(SystemTable->ConOut, Hello);
	mov rcx, [SystemTable]
	mov rcx, [rcx + EFI_SYSTEM_TABLE.ConOut]
	lea rdx, [Hello]
	call [rcx + SIMPLE_TEXT_OUTPUT_INTERFACE.OutputString]

;	SystemTable->ConIn->Reset(SystemTable->ConIn, FALSE);
	mov rcx, [SystemTable]
	mov rcx, [rcx + EFI_SYSTEM_TABLE.ConIn]
	mov rdx, 0
	call [rcx + SIMPLE_TEXT_INPUT_INTERFACE.Reset]

;	while (SystemTable->ConIn->ReadKeyStroke(SystemTable->ConIn, &Key) == EFI_NOT_READY);
wait_for_key:
	mov rcx, [SystemTable]
	mov rcx, [rcx + EFI_SYSTEM_TABLE.ConIn]
	lea rdx, [InputKey]
	call [rcx + SIMPLE_TEXT_INPUT_INTERFACE.ReadKeyStroke]
	mov rbx, EFI_NOT_READY
	cmp rax, rbx
	je wait_for_key

;	RT->ResetSystem(EfiResetShutdown, EFI_SUCCESS, 0, NULL);
	mov rax, [SystemTable]
	mov rax, [rax + EFI_SYSTEM_TABLE.RuntimeServices]
	mov rcx, EfiResetShutdown
	mov rdx, EFI_SUCCESS
	mov r8, 0
	mov r9, 0
	call [rax + EFI_RUNTIME_SERVICES.ResetSystem]

	add rsp, 4*8
	mov eax, EFI_SUCCESS
	retn

section '.data' data readable writeable
	Handle      dq ?
	SystemTable dq ?
	InputKey    dq ?
	Hello       dw 13,10,'H','e','l','l','o',' ','E','F','I',' ','W','o','r','l','d','!',13,10,0

section '.reloc' fixups data discardable