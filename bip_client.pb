OpenConsole()
IncludeFile "Custom_networkmod.pb"
UseModule net



StartClient(1,"192.168.0.9",5858)
Input()
Debug ClientSendDataWait(1,"ping")
Input()
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 7
; EnableThread
; EnableXP
; Executable = tester.exe