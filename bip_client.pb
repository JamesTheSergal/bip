OpenConsole()


InitNetwork()
String$ = "hello."
server = OpenNetworkConnection("192.168.0.9",5858)
Delay(1000)
go:
SendNetworkString(server,String$,#PB_Unicode)
string$ = Input()
Goto go
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 4
; EnableThread
; EnableXP
; Executable = tester.exe