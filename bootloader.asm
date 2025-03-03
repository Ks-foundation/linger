; bootloader.asm - Simple Bootloader for Linger Kernel
; NASM 문법 사용 (org 0x7C00)

[org 0x7C00]

start:
    ; 로딩 메시지 출력
    mov si, kernel_load_msg
    call print_string

    ; 디스크에서 커널 섹터를 읽어 메모리 0x1000으로 로드
    mov bx, 0x1000         ; 로드할 메모리 주소 (0x1000:0000)
    mov dh, 0              ; 헤드 번호
    mov dl, [boot_drive]   ; 부팅 드라이브 (기본 0x80)
    mov ch, 0              ; 실린더 0
    mov cl, 2              ; 섹터 2부터 시작 (부트로더는 1섹터)
    mov ah, 0x02           ; BIOS read sectors 함수
    mov al, 20             ; 읽을 섹터 수 (커널 크기에 맞게 조정)
    int 0x13
    jc disk_error

    ; 로드한 커널로 점프
    jmp 0x1000:0000

disk_error:
    mov si, disk_error_msg
    call print_string
    jmp $

; BIOS teletype 출력을 이용한 간단한 문자열 출력 루틴
print_string:
    mov ah, 0x0E
.print_next:
    lodsb
    cmp al, 0
    je .done
    int 0x10
    jmp .print_next
.done:
    ret

kernel_load_msg db "Loading Linger Kernel...", 0
disk_error_msg  db "Disk Read Error", 0
boot_drive db 0x80  ; 기본 부팅 드라이브

times 510 - ($ - $$) db 0
dw 0xAA55
