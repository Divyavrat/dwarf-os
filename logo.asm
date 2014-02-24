org 0x6000
use16

mov ax,0x0013
int 0x10
mov ax,0x0500
int 10h
mov ch,0x20
mov ah,0x01
int 0x10

mov byte [color],0x4a

logo:
xor dx,dx
call setpos
mov cx,40
mov al,0x20
.loop:
call printf
loop .loop

xor dx,dx
call setpos
mov al,'>'
call printf
mov di,command
call getarg

mov si,command
mov di,c_exit
call cmpstr
jc exit_f

mov si,command
mov di,c_quit
call cmpstr
jc exit_f

mov si,command
mov di,c_bye
call cmpstr
jc exit_f

mov si,command
mov di,c_color
call cmpstr
jc c_color_f

mov si,command
mov di,c_dot
call cmpstr
jc c_dot_f

mov si,command
mov di,c_line
call cmpstr
jc c_line_f

mov si,command
mov di,c_bar
call cmpstr
jc c_bar_f

mov si,command
mov di,c_rect
call cmpstr
jc c_bar_f

jmp logo
;mov ah,0x01
;int 0x16
;jz logo
exit_f:
mov ax,0x0003
int 0x10
mov ax,0x0500
int 10h
mov dx,0x0a00
call setpos
mov cx,0x0506
mov ah,0x01
int 0x10
xor bx,bx
mov es,bx
ret

printf:
pusha
xor bh,bh
mov bl,[color]
mov ah,0x0E
int 0x10
popa
ret

printh:
push ax
shr al,4
cmp al,10
sbb al,69h
das
call printf
pop ax
ror al,4
shr al,4
cmp al,10
sbb al,69h
das
call printf
ret

getpos:
mov ah,0x03
xor bh,bh
int 0x10
ret

setpos:

mov ah,0x02
xor bh,bh

int 0x10
ret

getkey:
xor ah,ah
int 0x16
ret

getarg:
call getkey
call printf
cmp al,0x20
je .argf
cmp al,0x0d
je .argf
cmp ah,0x0e
je .argb
stosb
jmp getarg
.argb:
dec di
call eraseback
call getpos
dec dl
call setpos
call eraseback
jmp getarg
.argf:
mov ax,0x0000
stosb
ret

cmpstr:
lodsb
mov bl,[di]
cmp al,bl
jne .nequal
;cmp al,dh
;je .cmpend
cmp al,0
je .cmpend
inc di
jmp cmpstr
.nequal:
clc
ret
.cmpend:
stc
ret

eraseback:
call getpos
dec dl
call setpos
mov al,0x20
call printf
ret

getno:
push bx
push cx
push dx
xor bx,bx
.getno_loop:
call getkey
call printf
cmp al,0x0D
je .getno2e
cmp al,0x20
je .getno2e
sub al,0x30
mov cl,al
mov ax,bx
mov dx,0x000a
mul dx
mov bx,ax
xor ch,ch
add bx,cx
jmp .getno_loop
.getno2e:
mov ax,bx
pop dx
pop cx
pop bx
ret

; delay:
; xor ah,ah
; int 1ah
; mov [wx],dl
; .delay_loop:
; xor ah,ah
; int 1ah
; cmp [wx],dl
; je .delay_loop
; ret

dot:
pusha
;mov ah,0x0c
;int 10h
mov bx,0xA000
mov es,bx
;mov bx,320
push ax
push cx
mov ax,320
mov cx,dx
xor dx,dx
mul cx
pop cx
mov bx,ax
add bx,cx
pop ax
mov [es:bx],al
xor dx,dx
mov es,dx
popa
ret

line:
mov [x],cx
mov [y],dx
;mov [x1],bh
;mov [y1],bl
mov [x2],ax
mov [y2],bx
mov byte [eps],0
sub cx,ax
mov [wx],cx
sub dx,bx
mov [wy],dx
.loop:
xor cx,cx
xor dx,dx
mov cx,[x]
mov dx,[y]
mov al,[color]
;call setpos
;call printc
call dot
;mov dl,[x]
;mov dh,[y]
;call setpos
;mov al,0x20
;call printc
;call delay
;call getpos
;dec dl
;call setpos
mov dx,[wy]
add [eps],dx
mov dx,[eps]

shl dx,1
mov bx,[wx]
cmp dx,bx
jl .skip
sub dx,bx
mov [eps],dx
mov dx,[y2]
cmp [y],dx
jg .y_big
inc word [y]
jmp .skip
.y_big:
dec word [y]
.skip:
mov dx,[x2]
cmp [x],dx
jg .x_big
inc word [x]
jmp .x_done
.x_big:
dec word [x]
.x_done:

mov dx,[x2]
cmp [x],dx
jne .loop

;dec byte [x]
;dec byte [y]
mov dx,[y2]
cmp [y],dx
jne .y_axis
ret
.y_axis:

mov dx,[y2]
cmp [y],dx
jg .y2_big
inc word [y]
jmp .y2_done
.y2_big:
dec word [y]
.y2_done:

mov cx,[x]
mov dx,[y]
mov al,[color]
;call setpos
;call printc
call dot
ret
mov dx,[y2]
cmp [y],dx
jne .y_axis
ret

bar:
pusha
call line
popa
inc bx
inc dx
dec di
cmp di,0
jg bar
ret

gethex:
call getkey
call printf
call atohex
shl al,4
mov [wx],al

call getkey
call printf
call atohex
mov ah,[wx]
add al,ah
ret

atohex:
cmp al,0x3a
jle hex_num_found
cmp al,0x5a
jg hex_small_found
add al,0x20
hex_small_found:
sbb al,0x28
hex_num_found:
sbb al,0x2f
ret

c_color_f:
call gethex
mov [color],al
jmp logo

c_dot_f:
call getno
mov cx,ax
call getno
mov dx,ax
mov al,[color]
call dot
jmp logo

c_line_f:
call getno
mov cx,ax
call getno
mov dx,ax
call getno
mov bx,ax
call getno
xchg ax,bx

call line
jmp logo

c_bar_f:
call getno
mov cx,ax
call getno
mov dx,ax
call getno
mov bx,ax
call getno
xchg ax,bx
push ax
call getno
mov di,ax
pop ax

call bar
jmp logo

x:
dw 0
y:
dw 0
x2:
dw 0
y2:
dw 0
wx:
dw 0
wy:
dw 0
eps:
dw 0
var_a:
dw 0
color:
db 0x31

c_exit:
db 'exit',0
c_quit:
db 'quit',0
c_bye:
db 'bye',0
c_color:
db 'color',0
c_dot:
db 'dot',0
c_line:
db 'line',0
c_bar:
db 'bar',0
c_rect:
db 'rect',0

command:
times 10 db 0

times (512*2)-($-$$) db 0x90