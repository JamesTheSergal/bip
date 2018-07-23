OpenConsole()
IncludeFile "Custom_networkmod.pb"
UseModule net



StartClient(1,"192.168.0.9",5858)
redo:
Input()
PrintN(ClientSendDataWait(1,"CreateUser((this boi)noisycat05,PasswordExample)"))
Goto redo
Input()
; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 9
; EnableThread
; EnableXP
; Executable = status.exe