'VPX Game Logic Framework (https://mpcarr.github.io/vpx-gle-framework/)

'
Dim glf_currentPlayer : glf_currentPlayer = Null
Dim glf_canAddPlayers : glf_canAddPlayers = True
Dim glf_PI : glf_PI = 4 * Atn(1)
Dim glf_plunger
Dim glf_gameStarted : glf_gameStarted = False
Dim glf_pinEvents : Set glf_pinEvents = CreateObject("Scripting.Dictionary")
Dim glf_pinEventsOrder : Set glf_pinEventsOrder = CreateObject("Scripting.Dictionary")
Dim glf_playerEvents : Set glf_playerEvents = CreateObject("Scripting.Dictionary")
Dim Glf_EventBlocks : Set Glf_EventBlocks = CreateObject("Scripting.Dictionary")
Dim Glf_ShotProfiles : Set Glf_ShotProfiles = CreateObject("Scripting.Dictionary")
Dim glf_playerEventsOrder : Set glf_playerEventsOrder = CreateObject("Scripting.Dictionary")
Dim playerState : Set playerState = CreateObject("Scripting.Dictionary")
Dim bcpController : bcpController = Null
Dim useBCP : useBCP = False
Dim bcpPort : bcpPort = 5050
Dim bcpExeName : bcpExeName = ""
Dim lightCtrl : Set lightCtrl = new LStateController
Dim glf_BIP : glf_BIP = 0
Dim glf_FuncCount : glf_FuncCount = 0

Dim glf_ballsPerGame : glf_ballsPerGame = 3
Dim glf_troughSize : glf_troughSize = tnob

Dim glf_debugLog : Set glf_debugLog = (new GlfDebugLogFile)()
Dim glf_debugEnabled : glf_debugEnabled = True

Dim Glf_FlashColor : Glf_FlashColor = Array(Array("(lights)|100|(color)"), Array("(lights)|0|(color)"))

lightCtrl.RegisterLights Glf_Lights
lightCtrl.Debug = False
Dim glf_ball1, glf_ball2, glf_ball3, glf_ball4, glf_ball5, glf_ball6, glf_ball7, glf_ball8	

Public Sub Glf_ConnectToBCPMediaController
    Set bcpController = (new GlfVpxBcpController)(bcpPort	, bcpExeName)
End Sub

Public Sub Glf_Init()
	If useBCP = True Then
		Glf_ConnectToBCPMediaController
	End If

	swTrough1.DestroyBall
	swTrough2.DestroyBall
	swTrough3.DestroyBall
	swTrough4.DestroyBall
	swTrough5.DestroyBall
	swTrough6.DestroyBall
	swTrough7.DestroyBall
	swTrough8.DestroyBall
	If glf_troughSize > 0 Then : Set glf_ball1 = swTrough1.CreateSizedballWithMass(Ballsize / 2,Ballmass) : gBot = Array(glf_ball1) : End If
	If glf_troughSize > 1 Then : Set glf_ball2 = swTrough2.CreateSizedballWithMass(Ballsize / 2,Ballmass) : gBot = Array(glf_ball1, glf_ball2) : End If
	If glf_troughSize > 2 Then : Set glf_ball3 = swTrough3.CreateSizedballWithMass(Ballsize / 2,Ballmass) : gBot = Array(glf_ball1, glf_ball2, glf_ball3) : End If
	If glf_troughSize > 3 Then : Set glf_ball4 = swTrough4.CreateSizedballWithMass(Ballsize / 2,Ballmass) : gBot = Array(glf_ball1, glf_ball2, glf_ball3, glf_ball4) : End If
	If glf_troughSize > 4 Then : Set glf_ball5 = swTrough5.CreateSizedballWithMass(Ballsize / 2,Ballmass) : gBot = Array(glf_ball1, glf_ball2, glf_ball3, glf_ball4, glf_ball5) : End If
	If glf_troughSize > 5 Then : Set glf_ball6 = swTrough6.CreateSizedballWithMass(Ballsize / 2,Ballmass) : gBot = Array(glf_ball1, glf_ball2, glf_ball3, glf_ball4, glf_ball5, glf_ball6) : End If
	If glf_troughSize > 6 Then : Set glf_ball7 = swTrough7.CreateSizedballWithMass(Ballsize / 2,Ballmass) : gBot = Array(glf_ball1, glf_ball2, glf_ball3, glf_ball4, glf_ball5, glf_ball6, glf_ball7) : End If
	If glf_troughSize > 7 Then : Set glf_ball8 = swTrough8.CreateSizedballWithMass(Ballsize / 2,Ballmass) : gBot = Array(glf_ball1, glf_ball2, glf_ball3, glf_ball4, glf_ball5, glf_ball6, glf_ball7, glf_ball8) : End If
	
	Dim switch, switchHitSubs
	switchHitSubs = ""
	For Each switch in Glf_Switches
		switchHitSubs = switchHitSubs & "Sub " & switch.Name & "_Hit() : DispatchPinEvent """ & switch.Name & "_active"", ActiveBall : End Sub" & vbCrLf
		switchHitSubs = switchHitSubs & "Sub " & switch.Name & "_UnHit() : DispatchPinEvent """ & switch.Name & "_inactive"", ActiveBall : End Sub" & vbCrLf
	Next
	ExecuteGlobal switchHitSubs
End Sub

Sub Glf_Options(ByVal eventId)
	Dim ballsPerGame : ballsPerGame = Table1.Option("Balls Per Game", 1, 2, 1, 1, 0, Array("3 Balls", "5 Balls"))
	If ballsPerGame = 1 Then
		glf_ballsPerGame = 3
	Else
		glf_ballsPerGame = 5
	End If
End Sub

Public Sub Glf_Exit()
	If Not IsNull(bcpController) Then
		bcpController.Disconnect
		Set bcpController = Nothing
	End If
End Sub

Public Sub Glf_KeyDown(ByVal keycode)
    If glf_gameStarted = True Then
		If keycode = LeftFlipperKey Then
			'DispatchPinEvent GLF_SWITCH_LEFT_FLIPPER_DOWN, Null
		End If
		
		If keycode = RightFlipperKey Then
			'DispatchPinEvent GLF_SWITCH_RIGHT_FLIPPER_DOWN, Null
		End If
		
		If keycode = StartGameKey Then
			If glf_canAddPlayers = True Then
				Glf_AddPlayer()
			End If
		End If
	Else
		If keycode = StartGameKey Then
			Glf_AddPlayer()
			Glf_StartGame()
		End If
	End If
End Sub

Public Sub Glf_KeyUp(ByVal keycode)
	If glf_gameStarted = True Then
		If KeyCode = PlungerKey Then
			Plunger.Fire
		End If
	End If
End Sub

Public Sub Glf_EventTimer_Timer()
	DelayTick
End Sub

Public Sub Glf_BCPUpdateTimer_Timer()
	Glf_BcpUpdate
End Sub

Public Function Glf_ParseInput(value, isTime)
	Dim templateCode : templateCode = ""
	Dim tmp: tmp = value
    Select Case VarType(value)
        Case 8 ' vbString
			tmp = Glf_ReplaceCurrentPlayerAttributes(tmp)
			If InStr(tmp, " if ") Then
				templateCode = "Function Glf_" & glf_FuncCount & "()" & vbCrLf
				templateCode = templateCode & vbTab & Glf_ConvertIf(tmp, "Glf_" & glf_FuncCount) & vbCrLf
				templateCode = templateCode & "End Function"
			Else
				templateCode = "Function Glf_" & glf_FuncCount & "()" & vbCrLf
				templateCode = templateCode & vbTab & "Glf_" & glf_FuncCount & " = " & tmp & vbCrLf
				templateCode = templateCode & "End Function"
			End IF
        Case Else
			templateCode = "Function Glf_" & glf_FuncCount & "()" & vbCrLf
			If isTime Then
				templateCode = templateCode & vbTab & "Glf_" & glf_FuncCount & " = " & tmp * 1000 & vbCrLf
			Else
				templateCode = templateCode & vbTab & "Glf_" & glf_FuncCount & " = " & tmp & vbCrLf
			End If
			templateCode = templateCode & "End Function"
    End Select
	msgbox templateCode
	ExecuteGlobal templateCode
	Dim funcRef : funcRef = "Glf_" & glf_FuncCount
	glf_FuncCount = glf_FuncCount + 1
	Glf_ParseInput = Array(funcRef, value)
End Function

Public Function Glf_ParseEventInput(value)
	Dim templateCode : templateCode = ""
	Dim condition : condition = Glf_IsCondition(value)
	If IsNull(condition) Then
		Glf_ParseEventInput = Array(value, value, Null)
	Else
		dim conditionReplaced : conditionReplaced = Glf_ReplaceCurrentPlayerAttributes(condition)
		templateCode = "Function Glf_" & glf_FuncCount & "()" & vbCrLf
		templateCode = templateCode & vbTab & Glf_ConvertCondition(conditionReplaced, "Glf_" & glf_FuncCount) & vbCrLf
		templateCode = templateCode & "End Function"
		'msgbox templateCode
		ExecuteGlobal templateCode
		Dim funcRef : funcRef = "Glf_" & glf_FuncCount
		glf_FuncCount = glf_FuncCount + 1
		Glf_ParseEventInput = Array(Replace(value, "{"&condition&"}", funcRef) ,Replace(value, "{"&condition&"}", ""), funcRef)
	End If
End Function

Function Glf_ReplaceCurrentPlayerAttributes(inputString)
    Dim pattern, replacement, regex, outputString
    pattern = "current_player\.([a-zA-Z0-9_]+)"
    Set regex = New RegExp
    regex.Pattern = pattern
    regex.IgnoreCase = True
    regex.Global = True
    replacement = "GetPlayerState(""$1"")"
    outputString = regex.Replace(inputString, replacement)
    Set regex = Nothing
    Glf_ReplaceCurrentPlayerAttributes = outputString
End Function

Function Glf_ConvertIf(value, retName)
    Dim parts, condition, truePart, falsePart
    parts = Split(value, " if ")
    truePart = Trim(parts(0))
    Dim conditionAndFalsePart
    conditionAndFalsePart = Split(parts(1), " else ")
    condition = Trim(conditionAndFalsePart(0))
    falsePart = Trim(conditionAndFalsePart(1))
    Dim vbscriptIfStatement
    vbscriptIfStatement = "If " & condition & " Then" & vbCrLf & _
                          "    "&retName&" = " & truePart & vbCrLf & _
                          "Else" & vbCrLf & _
                          "    "&retName&" = " & falsePart & vbCrLf & _
                          "End If"
	Glf_ConvertIf = vbscriptIfStatement
End Function

Function Glf_ConvertCondition(value, retName)
	value = Replace(value, "==", "=")
	value = Replace(value, "!=", "<>")
	Glf_ConvertCondition = "    "&retName&" = " & value
End Function

Public Sub Glf_GameTimer_Timer()
	lightCtrl.Update()
End Sub

Function GlfShotProfiles(name)
	If Glf_ShotProfiles.Exists(name) Then
		Set GlfShotProfiles = Glf_ShotProfiles(name)
	Else
		Dim new_shotprofile : Set new_shotprofile = (new GlfShotProfile)(name)
		Glf_ShotProfiles.Add name, new_shotprofile
		Set GlfShotProfiles = new_shotprofile
	End If
End Function

Function Glf_ConvertShow(show, tokens)

	Dim showStep, light, lightsCount, x,tagLight, tagLights, lightParts, token, stepIdx
	Dim newShow
	ReDim newShow(UBound(show))
	stepIdx = 0
	For Each showStep in show
		lightsCount = 0 
		For Each light in showStep
			lightParts = Split(light, "|")
			If IsArray(lightParts) Then
				token = Glf_IsToken(lightParts(0))
				If IsNull(token) And IsNull(lightCtrl.GetLightIdx(lightParts(0))) Then
					tagLights = lightCtrl.GetLightsForTag(lightParts(0))
					lightsCount = UBound(tagLights)+1
				Else
					If IsNull(token) Then
						lightsCount = lightsCount + 1
					Else
						'resolve token lights
						If IsNull(lightCtrl.GetLightIdx(tokens(token))) Then
							'token is a tag
							tagLights = lightCtrl.GetLightsForTag(tokens(token))
							lightsCount = UBound(tagLights)+1
						Else
							lightsCount = lightsCount + 1
						End If
					End If
				End If
			End If
		Next
	
		Dim seqArray
		ReDim seqArray(lightsCount-1)
		x=0
		For Each light in showStep
			lightParts = Split(light, "|")
			Dim lightColor
			If Ubound(lightParts) = 2 Then 
				If IsNull(Glf_IsToken(lightParts(2))) Then
					lightColor = lightParts(2)
				Else
					lightColor = tokens(Glf_IsToken(lightParts(2)))
				End If
			End If

			If IsArray(lightParts) Then
				token = Glf_IsToken(lightParts(0))
				If IsNull(token) And IsNull(lightCtrl.GetLightIdx(lightParts(0))) Then
					tagLights = lightCtrl.GetLightsForTag(lightParts(0))
					For Each tagLight in tagLights
						If UBound(lightParts) >=1 Then
							seqArray(x) = tagLight & "|"&lightParts(1)&"|"&lightColor
						Else
							seqArray(x) = tagLight & "|"&lightParts(1)
						End If
						x=x+1
					Next
				Else
					If IsNull(token) Then
						If UBound(lightParts) >= 1 Then
							seqArray(x) = lightParts(0) & "|"&lightParts(1)&"|"&lightColor
						Else
							seqArray(x) = lightParts(0) & "|"&lightParts(1)
						End If
						x=x+1
					Else
						'resolve token lights
						If IsNull(lightCtrl.GetLightIdx(tokens(token))) Then
							'token is a tag
							tagLights = lightCtrl.GetLightsForTag(tokens(token))
							For Each tagLight in tagLights
								If UBound(lightParts) >=1 Then
									seqArray(x) = tagLight & "|"&lightParts(1)&"|"&lightColor
								Else
									seqArray(x) = tagLight & "|"&lightParts(1)
								End If
								x=x+1
							Next
						Else
							If UBound(lightParts) >= 1 Then
								seqArray(x) = tokens(token) & "|"&lightParts(1)&"|"&lightColor
							Else
								seqArray(x) = tokens(token) & "|"&lightParts(1)
							End If
							x=x+1
						End If
					End If
				End If
			End If
		Next
		glf_debugLog.WriteToLog "Convert Show", Join(seqArray)
		newShow(stepIdx) = seqArray
		stepIdx = stepIdx + 1
	Next
	Glf_ConvertShow = newShow
End Function

Private Function Glf_IsToken(mainString)
	' Check if the string contains an opening parenthesis and ends with a closing parenthesis
	If InStr(mainString, "(") > 0 And Right(mainString, 1) = ")" Then
		' Extract the substring within the parentheses
		Dim startPos, subString
		startPos = InStr(mainString, "(")
		subString = Mid(mainString, startPos + 1, Len(mainString) - startPos - 1)
		Glf_IsToken = subString
	Else
		Glf_IsToken = Null
	End If
End Function

Private Function Glf_IsCondition(mainString)
	' Check if the string contains an opening { and ends with a closing }
	If InStr(mainString, "{") > 0 And Right(mainString, 1) = "}" Then
		Dim startPos, subString
		startPos = InStr(mainString, "{")
		subString = Mid(mainString, startPos + 1, Len(mainString) - startPos - 1)
		Glf_IsCondition = subString
	Else
		Glf_IsCondition = Null
	End If
End Function

'******************************************************
'*****   GLF Pin Events                             ****
'******************************************************

Const GLF_GAME_STARTED = "game_started"
Const GLF_GAME_OVER = "game_ended"
Const GLF_BALL_ENDED = "ball_ended"
Const GLF_NEXT_PLAYER = "next_player"
Const GLF_BALL_DRAIN = "ball_drain"
Const GLF_BALL_STARTED = "ball_started"

'******************************************************
'*****   GLF Player State                          ****
'******************************************************

Const GLF_SCORE = "score"
Const GLF_CURRENT_BALL = "current_ball"
Const GLF_INITIALS = "initials"

