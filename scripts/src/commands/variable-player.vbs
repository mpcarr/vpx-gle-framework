Class GlfVariablePlayer

    Private m_priority
    Private m_mode
    Private m_events
    Private m_debug

    Private m_value

    Public Property Get Events(name)
        Dim newEvent : Set newEvent = (new GlfVariablePlayerEvent)(name)
        m_events.Add newEvent.BaseEvent.Name, newEvent
        Set Events = newEvent
    End Property
   
    Public Property Let Debug(value) : m_debug = value : End Property

	Public default Function init(mode)
        m_mode = mode.Name
        m_priority = mode.Priority

        Set m_events = CreateObject("Scripting.Dictionary")
        
        AddPinEventListener m_mode & "_starting", "variable_player_activate", "VariablePlayerEventHandler", m_priority, Array("activate", Me)
        AddPinEventListener m_mode & "_stopping", "variable_player_deactivate", "VariablePlayerEventHandler", m_priority, Array("deactivate", Me)
        Set Init = Me
	End Function

    Public Sub Activate()
        Dim evt
        For Each evt In m_events.Keys()
            AddPinEventListener m_events(evt).BaseEvent.EventName, m_mode & "_variable_player_play", "VariablePlayerEventHandler", m_priority, Array("play", Me, evt)
        Next
    End Sub

    Public Sub Deactivate()
        Dim evt
        For Each evt In m_events.Keys()
            RemovePinEventListener m_events(evt).BaseEvent.EventName, m_mode & "_variable_player_play"
        Next
    End Sub

    Public Sub Play(evt)
        Log "Playing: " & evt
        If Not IsNull(m_events(evt).BaseEvent.Condition) Then
            If GetRef(m_events(evt).BaseEvent.Condition)() = False Then
                Exit Sub
            End If
        End If
        Dim vKey, v
        For Each vKey in m_events(evt).Variables.Keys
            Log "Setting Variable " & vKey
            Set v = m_events(evt).Variable(vKey)
            Select Case v.VariableType
                Case "float"
                    Select Case v.Action
                        Case "add"
                            SetPlayerState vKey, GetPlayerState(vKey) + GetRef(v.Float(0))()
                        Case "set"
                            SetPlayerState vKey, GetRef(v.Float(0))()
                    End Select
                Case "int"
                    Select Case v.Action
                        Case "add"
                            SetPlayerState vKey, GetPlayerState(vKey) + GetRef(v.Int(0))()
                        Case "set"
                            SetPlayerState vKey, GetRef(v.Int(0))()
                    End Select
                Case "string"
                    SetPlayerState vKey, v.String
            End Select
        Next
    End Sub

    Private Sub Log(message)
        If m_debug = True Then
            glf_debugLog.WriteToLog m_mode & "_variable_player_play", message
        End If
    End Sub
End Class

Class GlfVariablePlayerEvent

    Private m_event
	Private m_variables

    Public Property Get BaseEvent() : Set BaseEvent = m_event : End Property
  
	Public Property Get Variable(name)
        If m_variables.Exists(name) Then
            Set Variable = m_variables(name)
        Else
            Dim new_variable : Set new_variable = (new GlfVariablePlayerItem)()
            m_variables.Add name, new_variable
            Set Variable = new_variable
        End If
    End Property
    
    Public Property Get Variables(): Set Variables = m_variables End Property

	Public default Function init(evt)
        Set m_event = (new GlfEvent)(evt)
        Set m_variables = CreateObject("Scripting.Dictionary")
	    Set Init = Me
	End Function

End Class

Class GlfVariablePlayerItem
	Private m_block, m_show, m_flaot, m_int, m_string, m_player, m_action, m_type
  
	Public Property Get Action(): Action = m_action: End Property
    Public Property Let Action(input): m_action = input: End Property

    Public Property Get Block(): Block = m_block End Property
    Public Property Let Block(input): m_block = input End Property

    Public Property Get Float(): Float = m_float :  End Property
	Public Property Let Float(input): m_float = Glf_ParseInput(input, False): m_type = "float" : End Property
  
	Public Property Get Int(): Int = m_int: End Property
	Public Property Let Int(input): m_int = Glf_ParseInput(input, False): m_type = "int" : End Property
  
	Public Property Get String(): String = m_string: End Property
	Public Property Let String(input): m_string = input: m_type = "string" : End Property

    Public Property Get VariableType(): VariableType = m_type: End Property

    Public Property Get Player(): Player = m_player: End Property
    Public Property Let Player(input): m_player = input: End Property

	Public default Function init()
        m_action = "add"
        m_type = Empty
        m_block = False
        m_float = Empty
        m_int = Empty
        m_string = Empty
        m_player = Empty
	    Set Init = Me
	End Function

End Class

Function VariablePlayerEventHandler(args)
    
    Dim ownProps, kwargs : ownProps = args(0) : kwargs = args(1) 
    Dim evt : evt = ownProps(0)
    Dim variablePlayer : Set variablePlayer = ownProps(1)
    Select Case evt
        Case "activate"
            variablePlayer.Activate
        Case "deactivate"
            variablePlayer.Deactivate
        Case "play"
            variablePlayer.Play ownProps(2)
    End Select
    VariablePlayerEventHandler = kwargs
End Function