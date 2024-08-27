B4J=true
Group=Default Group
ModulesStructureVersion=1
Type=Class
Version=4.2
@EndOfDesignText@
Sub Class_Globals
	Dim App As AWTRIX
	
	Dim win As String
	Dim kill As String
	Dim xpPerMin As String
	Dim goldPerMin As String
	Dim lastHits As String
End Sub

' ignore
Public Sub Initialize() As String
	
	App.Initialize(Me,"App")
	
	'change plugin name (must be unique, avoid spaces)
	App.Name="Dota 2"
	
	'Version of the App
	App.Version="1.0"
	
	'Description of the App. You can use HTML to format it
	App.Description=$"Shows your Kills, Wins, XP per Minute, Gold per Minute, and Last Hits"$
	
	App.Author="Christian Albarracin"
	
	App.CoverIcon=2228
		
	'SetupInstructions. You can use HTML to format it
	App.setupDescription= $"
	<b>Steam ID:</b>  Your Dota 2 Steam ID<br/>
    <b>API Key:</b>  (Optional, for additional features)<br/>
	"$
	
	'How many downloadhandlers should be generated
	App.Downloads=1
	
	'IconIDs from AWTRIXER.
	App.Icons=Array As Int(199)
	
	'Tickinterval in ms (should be 65 by default)
	App.Tick=65
	
	'If set to true AWTRIX will wait for the "finish" command before switch to the next app.
	App.Lock=True
	
	'needed Settings for this App (Wich can be configurate from user via webinterface)
	App.Settings=CreateMap("SteamID": "", "APIkey": "")
	
	App.MakeSettings
	Return "AWTRIX20"
End Sub

' ignore
public Sub GetNiceName() As String
	Return App.Name
End Sub

' ignore
public Sub Run(Tag As String, Params As Map) As Object
	Return App.interface(Tag,Params)
End Sub

'Called with every update from Awtrix
'return one URL for each downloadhandler
Sub App_startDownload(jobNr As Int)
	Select jobNr
		Case 1
			App.Download("https://api.opendota.com/api/players/" & App.Get("SteamID") & "/recentMatches")
	End Select
End Sub

'Process the response from each download handler
'Using the JSON data from OpenDota API to extract stats
Sub App_evalJobResponse(Resp As JobResponse)
	Try
		If Resp.success Then
			Select Resp.jobNr
				Case 1
					Dim parser As JSONParser
					parser.Initialize(Resp.ResponseString)
					Dim root As List = parser.NextArray
					Dim lastMatch As Map = root.Get(0)  ' Get the latest match

					' Extract relevant stats
					kill = lastMatch.Get("kills")
					xpPerMin = lastMatch.Get("xp_per_min")
					goldPerMin = lastMatch.Get("gold_per_min")
					lastHits = lastMatch.Get("last_hits")
                    
					' Determine if the player won the match
					Dim playerSlot As Int = lastMatch.Get("player_slot")
					Dim radiantWin As Boolean = lastMatch.Get("radiant_win")
					If (playerSlot < 128 And radiantWin) Or (playerSlot >= 128 And Not(radiantWin)) Then
						win = "1"
					Else
						win = "0"
					End If
			End Select
		End If
	Catch
		Log("Error in: " & App.Name & CRLF & LastException)
		Log("API response: " & CRLF & Resp.ResponseString)
	End Try
End Sub

Sub App_genFrame
	App.genText(kill & " Kills        " & win & " Wins        " & xpPerMin & " XP/min        " & goldPerMin & " G/min        " & lastHits & " LH", True, 1, Null, True)
	App.drawBMP(0,0,App.getIcon(199),8,8)
End Sub