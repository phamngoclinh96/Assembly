.386 
.model flat,stdcall 
option casemap:none 
include C:\masm32\include\windows.inc 
include C:\masm32\include\user32.inc 
include C:\masm32\include\kernel32.inc 
include C:\masm32\include\gdi32.inc 
includelib C:\masm32\lib\user32.lib 
includelib C:\masm32\lib\kernel32.lib 
includelib C:\masm32\lib\gdi32.lib
WinMain proto :DWORD,:DWORD,:DWORD,:DWORD 
  


.data 
ClassName db "SimpleWin32ASMBitmap",0 
AppName  db "Paint",0

.data? 
hInstance HINSTANCE ? 
CommandLine LPSTR ? 
pen HPEN ?
wc WNDCLASSEX <?>
msg MSG <?>
hwnd HWND ?
ps PAINTSTRUCT <?> 
hdc HDC ?
rect RECT <?>
x1 dd ?
y1 dd ?
x2 dd ?
y2 dd ?
DOWN dd ?

.code 
start: 
 ;invoke GetModuleHandle, NULL 
 push NULL
 call GetModuleHandle
 mov    hInstance,eax 
 ;invoke GetCommandLine 
 call GetCommandLine
 mov    CommandLine,eax 
 ;invoke WinMain, hInstance,NULL,CommandLine, SW_SHOWDEFAULT 
 push SW_SHOWDEFAULT
 push CommandLine
 push NULL
 push hInstance
 call WinMain
 ;invoke ExitProcess,eax
 push eax
 call ExitProcess

WinMain proc hInst:HINSTANCE,hPrevInst:HINSTANCE,CmdLine:LPSTR,CmdShow:DWORD 
 
 mov   wc.cbSize,SIZEOF WNDCLASSEX 
 mov   wc.style, CS_HREDRAW or CS_VREDRAW 
 mov   wc.lpfnWndProc, OFFSET WndProc 
 mov   wc.cbClsExtra,NULL 
 mov   wc.cbWndExtra,NULL 
 push  hInstance 
 pop   wc.hInstance 
 mov   wc.hbrBackground,COLOR_WINDOW+1 
 mov   wc.lpszMenuName,NULL 
 mov   wc.lpszClassName,OFFSET ClassName 
 ;invoke LoadIcon,NULL,IDI_APPLICATION 
 push IDI_APPLICATION
 push NULL
 call LoadIcon
 mov   wc.hIcon,eax 
 mov   wc.hIconSm,eax 
 ;invoke LoadCursor,NULL,IDC_ARROW 
 push IDC_ARROW
 push NULL
 call LoadCursor
 mov   wc.hCursor,eax 
 ;invoke RegisterClassEx, addr wc 
 push offset wc
 call RegisterClassEx
 ;INVOKE CreateWindowEx,NULL,ADDR ClassName,ADDR AppName,\ 
 ;          WS_OVERLAPPEDWINDOW,CW_USEDEFAULT,\ 
 ;          CW_USEDEFAULT,CW_USEDEFAULT,CW_USEDEFAULT,NULL,NULL,\ 
 ;          hInst,NULL 
 push NULL
 push hInst
 push NULL
 push NULL
 push CW_USEDEFAULT
 push CW_USEDEFAULT
 push CW_USEDEFAULT
 push CW_USEDEFAULT
 push WS_OVERLAPPEDWINDOW
 push offset AppName
 push offset ClassName
 push NULL
 call CreateWindowEx
 mov   hwnd,eax 
 ;invoke ShowWindow, hwnd,SW_SHOWNORMAL 
 push SW_SHOWNORMAL
 push hwnd
 call ShowWindow
 ;invoke UpdateWindow, hwnd 
 push hwnd
 call UpdateWindow
 ;.while TRUE 
loop_message: 
  ;invoke GetMessage, ADDR msg,NULL,0,0 
  push 0
  push 0
  push NULL
  push offset msg
  call GetMessage
  ;.break .if (!eax)
  or eax,eax
  ;cmp eax,0
  je exit_loop
  ;invoke TranslateMessage, ADDR msg 
  push offset msg
  call TranslateMessage
  ;invoke DispatchMessage, ADDR msg 
  push offset msg
  call DispatchMessage
  jmp loop_message
 ;.endw 
 exit_loop:
 mov     eax,msg.wParam 
 ret 
WinMain endp

WndProc proc hWnd:HWND, uMsg:UINT, wParam:WPARAM, lParam:LPARAM 
	cmp uMsg,WM_ERASEBKGND
	je exit_proc
	cmp uMsg,WM_CREATE
	je ON_WM_CREATE
	cmp uMsg,WM_PAINT
	je ON_WM_PAINT
	cmp uMsg,WM_MOUSEMOVE
	je ON_WM_MOUSEMOVE
	cmp uMsg,WM_DESTROY
	je ON_WM_DESTROY
	jmp DEFAULT
;.if uMsg==WM_CREATE 
ON_WM_CREATE:
	;invoke CreatePen,PS_SOLID,2,12
	push 00ff00h
	push 2
	push PS_SOLID
	call CreatePen
	mov pen,eax
	jmp exit_proc
;.elseif uMsg==WM_PAINT 
ON_WM_PAINT:
      ;invoke BeginPaint,hWnd,addr ps 
	  push offset ps
	  push hWnd
	  call BeginPaint
      mov    hdc,eax 
	  
	  ;invoke MoveToEx,ps.hdc,x2,y2,NULL
	  push NULL
	  push y2
	  push x2
	  push hdc
	  call MoveToEx
	  ;invoke SelectObject ,ps.hdc,pen  
	  push pen
	  push ps.hdc
	  call SelectObject
	  ;invoke LineTo,ps.hdc,x1,y1
	  push y1
	  push x1
	  push ps.hdc
	  call LineTo
	  ;invoke EndPaint,hWnd,addr ps 
	  push offset ps
	  push hWnd
	  call EndPaint
	  mov ebx,x1
	  mov x2,ebx
	  mov ebx,y1
	  mov y2,ebx
      jmp exit_proc
;.elseif uMsg == WM_MOUSEMOVE
ON_WM_MOUSEMOVE:
		;.if wParam==MK_LBUTTON	
		cmp wParam,MK_LBUTTON
		je down
		jne notdown
		down:
			;invoke InvalidateRect,hWnd,NULL,FALSE
			push FALSE
			push NULL
			push hWnd
			call InvalidateRect
			jmp end_mousemove
		;.elseif
		notdown:
			xor ebx,ebx
			mov eax,lParam
			mov bx,ax
			mov x2,ebx
			shr eax,16
			mov bx,ax
			mov y2,ebx
			jmp end_mousemove
		;.endif
		end_mousemove:
		xor ebx,ebx
		mov eax,lParam
		mov bx,ax
		mov x1,ebx
		shr eax,16
		mov bx,ax
		mov y1,ebx
	
		jmp exit_proc
			
;.elseif uMsg==WM_DESTROY 
ON_WM_DESTROY:
	;invoke PostQuitMessage,NULL 
	push NULL
	call PostQuitMessage
	jmp exit_proc
;.ELSE 
DEFAULT:
	;invoke DefWindowProc,hWnd,uMsg,wParam,lParam 
	push lParam
	push wParam
	push uMsg
	push hWnd
	call DefWindowProc
  exit_proc:
  ret 
 ;.ENDIF 
 xor eax,eax 
 ret 
WndProc endp 
end start