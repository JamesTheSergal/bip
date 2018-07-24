OpenConsole()
IncludeFile "Custom_networkmod.pb"
Declare.i createuser(UserName$,Password$)
UseModule net



StartClient(1,"192.168.0.9",5858)
redo:
Input()
PrintN(ClientSendDataWait(1,"CreateUser(noisy(cat05),PasswordExample(That works))"))
Goto redo
Input()


Procedure.i createuser(UserName$,Password$)
  ClientSendDataWait(1,"CreateUser("+UserName$+"|||"+Password$+")")
  
  
EndProcedure

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 16
; Folding = -
; EnableThread
; EnableXP
; Executable = status.exe