IncludeFile "bip_data_handler.pb"
IncludeFile "Custom_networkmod.pb"
IncludeFile "bip_client_ServerSelect.pbf"
Declare.i createuser(UserName$,Password$)
Declare.s ServerExtractData(FormedMessage$)
Declare.i Login(UserName$,Password$)
Declare.i serverping()
Declare.s serverstats()
UseModule net

;- enumerations

Enumeration ServerLogin
  #ServerLogin_Failed
  #ServerLogin_Success
  #ServerLogin_Invalid_NotExist
  #ServerLogin_Invalid_Password
EndEnumeration

Enumeration ServerMakeUsr
  #ServerMakeUsr_failed
  #ServerMakeUsr_Success
  #ServerMakeUsr_Invalid
  #ServerMakeUsr_Exists
  #ServerMakeUsr_ServerError
EndEnumeration



; StartClient(1,"127.0.0.1",5858)
; createuser("noisycat05","TotallyAwesomePassword")
; login("noisycat05","TotallyAwesomePassword")


openwindow_0(0,0,600,400)
If ReadFile(1,"serverlist.list")
  OpenFile(1,"serverlist.list")
  While Not Eof(1)
    server$ = ReadString(1)
  Wend
Else
  OpenFile(1,"serverlist.list")
  CloseFile(1)
EndIf




Repeat 
  event = WaitWindowEvent()
  
  If event = #PB_Event_Gadget
    Debug "window event"
    
    Select EventGadget()
        Case 3 ; add server button.
        IP$ = GetGadgetText(1) ;IP gadget 
        URL$ = GetGadgetText(2) ;URL manual
        
        If IP$ <> "" Or URL$ <> ""
          SetGadgetText(6,"Please wait while connecting server...")
          SetGadgetAttribute(4,#PB_ProgressBar_Minimum,0)
          SetGadgetAttribute(4,#PB_ProgressBar_Maximum,5)
          SetGadgetState(4,#PB_ProgressBar_Unknown)
          clithread = StartClient(1,IP$,5858)
          If clithread
            SetGadgetState(4,1)
            SetGadgetText(6,"Sending name request...")
            name$ = Clientsenddatawait(1,"(name)")
            If name$ <> ""
              SetGadgetState(4,2)
              SetGadgetText(6,"Asking for stats on server...")
              Stats$ = Serverstats()
              If Stats$ <> ""
                SetGadgetState(4,3)
                SetGadgetText(6,"Testing latency...")
                Repeat
                mill = ElapsedMilliseconds()
                serverping()
                emill = ElapsedMilliseconds()
                x+1
                Until x = 8
                latency = emill-mill
                x = 0
                
                SetGadgetText(6,"Adding Server to list...")
                OpenFile(1,"serverlist.list",#PB_File_Append)
                WriteString(1,(Chr(13)+IP$))
                CloseFile(1)
                If CountGadgetItems(5) > 0
                  AddGadgetItem(5,CountGadgetItems(5)+1,Name$+" - "+Str(latency)+"ms"+" Located at: "+IP$)
                Else
                  AddGadgetItem(5,0,Name$+" - "+Str(latency)+"ms"+" Located at: "+IP$)
                EndIf
                SetGadgetState(4,5)
                SetGadgetText(6,"Ready.")
              Else
                MessageRequester("Error","Server did not give us their stats. their computers are probably just slow.")
              EndIf
              
            Else
              MessageRequester("Error","Server did not give us its name. Thats spooky...")
            EndIf
            
              
          Else
            MessageRequester("Error","Could not connect to the server you requested. Better use discord Instead.")
          EndIf
        EndIf
        
             
    EndSelect
    
  EndIf
Until Event = #PB_Event_CloseWindow Or Connect$ <> ""






















Procedure.i createuser(UserName$,Password$)
  UseModule net
  Extract$ = ClientSendDataWait(1,"CreateUser("+UserName$+"|||"+Password$+")")
  Extract$ = ServerExtractData(Extract$)
  Debug Extract$
  Select Extract$
    Case "created"
      ProcedureReturn #ServerMakeUsr_Success
      
    Case "failed"
      ProcedureReturn #ServerMakeUsr_failed
      
    Case "invalid"
      ProcedureReturn #ServerMakeUsr_Invalid
      
    Case "exists"
      ProcedureReturn #ServerMakeUsr_Exists

    Default 
      ProcedureReturn #ServerMakeUsr_ServerError
  EndSelect
  
      
EndProcedure

Procedure.i Login(UserName$,Password$)
  UseModule net
  Global ReturnAuth$
  Extract$ = ClientSendDataWait(1,"login("+UserName$+"|||"+Password$+")")
  Extract$ = ServerExtractData(Extract$)
  response$ = StringField(Extract$,1,"|||")
  ReturnAuth$ = StringField(Extract$,2,"|||")
  Debug ReturnAuth$
  Debug response$
  Select response$
    Case "success"
      ProcedureReturn #ServerLogin_Success
      
    Case "passerr"
      ProcedureReturn #ServerLogin_Invalid_Password
      
    Case "notexist"
      ProcedureReturn #ServerLogin_Invalid_NotExist

    Default 
      ProcedureReturn #ServerLogin_Failed
  EndSelect

EndProcedure

Procedure.s ServerStats()
  UseModule net
  got$ = Clientsenddatawait(1,"(status)")
  ProcedureReturn got$
EndProcedure

Procedure.i ServerPing()
  pong$ = Clientsenddatawait(1,"(ping)")
  If pong$ = "pong"
    ProcedureReturn 1
  Else
    ProcedureReturn 0
  EndIf
EndProcedure

Procedure.s ServerExtractData(FormedMessage$)
;     Actual$ = StringField(FormedMessage$,2,"(")
;     actlen = Len(actual$)
;     Actual$ = Left(Actual$,actlen-1)
    
    count = Len(FormedMessage$)
    open = FindString(FormedMessage$,"(")
    extract = count-open
    Semi$ = Right(FormedMessage$,extract)
    Actual$ = Left(Semi$,extract-1)
    
    
    ProcedureReturn Actual$
  EndProcedure
  
  
  
; IDE Options = PureBasic 5.61 (Windows - x64)
; CursorPosition = 75
; FirstLine = 53
; Folding = g
; EnableThread
; EnableXP
; Executable = status.exe