DeclareModule net
  Declare.i StartServer(port)
  ;Declare.i StartClient(serveraddress$,port)
  Global NewList serverIDs.i()
  Global mapaccess = CreateMutex()
  Global mapmemlis = CreateMutex()
  
  
  
EndDeclareModule


Module net
  Declare serverthread(port)
  Declare ServerIndividualThread(ClientID)
  InitNetwork()
  
  ;- Server
  
  Procedure.i StartServer(port)
    ;CreateThread(@serverthread(),port)
    serverthread(port)
  EndProcedure
  
  Procedure serverthread(port)
    Global NewMap Threads.i()
    Global NewMap Memlist.i()
    Debug "Server Started"
    ServerID = Random(9999,0)
    Debug ServerID
    CreateNetworkServer(ServerID,5858)
    
    Repeat
      
      ServerEvent = NetworkServerEvent()
      
      If ServerEvent
        ClientID = EventClient()
        Debug ServerEvent
        Select ServerEvent
            
          Case #PB_NetworkEvent_Connect
            Debug "Client connected."
            Thread = CreateThread(@ServerIndividualThread(),ClientID)
            ResetMap(Threads())
            AddMapElement(Threads(),Str(ClientID))
            Threads() = Thread
            
            
          Case #PB_NetworkEvent_Disconnect
            Debug "Client: "+Str(ClientID)+" Disconnected."
            LockMutex(mapaccess)
            Debug Str(Threads(Str(ClientID)))+" Is the Thread ID."
            KillThread(Threads(Str(ClientID)))
            DeleteMapElement(Threads(),Str(ClientID))
            UnlockMutex(mapaccess)
            Debug "killed thread"
            
          Case #PB_NetworkEvent_Data
            *ReceiveBuffer = AllocateMemory(65536)
            ReceiveNetworkData(ClientID,*ReceiveBuffer,65536)
            LockMutex(mapmemlis)
            AddMapElement(Memlist(),Str(ClientID))
            Memlist() = *ReceiveBuffer
            UnlockMutex(mapmemlis)
            *ReceiveBuffer = AllocateMemory(65536)
            
            
        EndSelect
      Else
        Delay(1)
      EndIf

    ForEver

  EndProcedure
  
  Procedure ServerIndividualThread(ClientID)
    Debug "Individual thread started."
    Repeat  
      If FindMapElement(Memlist(),Str(ClientID))
        LockMutex(mapmemlis)
        memory = Memlist()
        DeleteMapElement(Memlist(),Str(ClientID))
        UnlockMutex(mapmemlis)
            command$ = PeekS(memory)
      FreeMemory(memory)
    EndIf
    ;- custom commands section
    
    
    Select command$
        Case "ping"
        SendNetworkString(ClientID,"pong")
    
    EndSelect
    
    ;- end of custom commands section
      Delay(5)
    Until exit = 1
  EndProcedure
  
  ;- Client
  
EndModule 

; IDE Options = PureBasic 5.62 (Windows - x64)
; CursorPosition = 15
; Folding = j
; EnableXP