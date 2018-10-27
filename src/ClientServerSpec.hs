module ClientServerSpec where

import Types
import TypeHelpers
import Data.Map as M


--client states
start = state "Start" []
submitLogin = msg "SubmitLogin" []
login = msg "Login" []

wait = state "Wait" []


haveFrac = state "HaveFrac" 
    [edt frac "fraction" ""
    ,edt maybeColour "c1" ""
    ,edt maybeColour "c2" ""
    ,edt maybeColour "c3" ""
    ,edt maybeColour "c4" ""
    ,playerNum
    ,edt (ElmMaybe channel) "draggingChannel" ""
    ]
ready = state "Ready" 
    [edt frac "fraction" ""
    ,edt colour "c1" ""
    ,edt colour "c2" ""
    ,edt colour "c3" ""
    ,edt colour "c4" ""
    ,playerNum
    ]
playing = state "Playing" 
    [edt frac "fraction" ""
    ,edt colour "c1" ""
    ,edt colour "c2" ""
    ,edt colour "c3" ""
    ,edt colour "c4" ""
    ,edt (ElmIntRange 0 3) "playerNum" ""
    ,edt (ElmDict (edt (ElmPair xCoord yCoord) "key" "coordinate") 
                  (edt colour "c" "box colour")
         )
         "grid" ""
    ]
playerNum = edt (ElmIntRange 0 3) "playerNum" ""
maxY = 19
maxX = 19
xCoord = edt (ElmIntRange 0 maxX) "x" ""
yCoord = edt (ElmIntRange 0 maxY) "y" ""
    

maybeColour = ElmMaybe (edt colour "colour" "")
colour = (ElmType "Colour")
channel = edt (ElmType "Channel") "channel" ""
channelType = ec "Channel" [constructor "Red" [],constructor "Green" [],constructor "Blue" []]
frac = ElmType "Frac"
fracType = ec "Frac" 
    [
        constructor "Frac" [edt (ElmIntRange 0 1000) "numerator" "",edt (ElmIntRange 1 1000) "denominator" ""]
    ]

--HaveFrac messages
startDragging = msg "StartDragging" [edt (ElmType "Channel") "channel" ""]
stopDragging = msg "StopDragging" []
dragging = msg "Dragging" [edt (ElmType "Channel") "channel" "", edt (ElmPair x y) "position" ""]
tapReady = msg "TapReady" []
x = edt (ElmFloatRange 0 0 0) "x" ""
y = edt (ElmFloatRange 0 0 0) "y" ""

--Playing messages
tapBox = msg "TapBox" [xCoord, yCoord]

-- server states
nobody = state "Nobody" [listFrac]
listFrac = edt (ElmList $ edt frac "fraction" "") "listFrac" ""

one = state "One" 
    [listFrac
    , edt colour "client1Colour" ""  
    , edt clientId "client1ID" ""
    ]
clientId = ElmType "ClientID"
two = state "Two" 
    [listFrac
    , edt colour "client1Colour" ""  
    , edt clientId "client1ID" ""
    , edt colour "client2Colour" ""  
    , edt clientId "client2ID" ""
    ]

three = state "Three" 
    [listFrac
    , edt colour "client1Colour" ""  
    , edt clientId "client1ID" ""
    , edt colour "client2Colour" ""  
    , edt clientId "client2ID" ""
    , edt colour "client3Colour" ""  
    , edt clientId "client3ID" ""
    ]

four = state "Four" 
    [listFrac
    , edt colour "client1Colour" ""  
    , edt clientId "client1ID" ""
    , edt colour "client2Colour" ""  
    , edt clientId "client2ID" ""
    , edt colour "client3Colour" ""  
    , edt clientId "client3ID" ""
    , edt colour "client4Colour" ""  
    , edt clientId "client4ID" ""
    , edt ElmBool "client1Ready" ""
    , edt ElmBool "client2Ready" ""
    , edt ElmBool "client3Ready" ""
    , edt ElmBool "client4Ready" ""
    ]

playingS = state "PlayingS" 
    [listFrac
    , edt colour "client1Colour" ""  
    , edt clientId "client1ID" ""
    , edt colour "client2Colour" ""  
    , edt clientId "client2ID" ""
    , edt colour "client3Colour" ""  
    , edt clientId "client3ID" ""
    , edt colour "client4Colour" ""  
    , edt clientId "client4ID" ""
    , edt (ElmDict (edt (ElmPair xCoord yCoord) "key" "coordinate") 
                   (edt (ElmIntRange 0 3) "boxOwner" "last player who tapped on box"))
          "grid"
          "records who last tapped on boxes"
    ]

--client outgoing messages
changeColour = msg "ChangeColour" 
    [
        edt colour "colour" ""
    ]

readyMsg = msg "Ready"
    [
    ]
tapMsg = msg "Tap"
    [
        xCoord
    ,   yCoord
    ]
--server outgoing messages
sendFrac = msg "SendFrac" 
    [edt frac "newFrac" ""
    ,edt (ElmIntRange 0 3) "newPlayer" ""
    ,edt maybeColour "newP1C" ""
    ,edt maybeColour "newP2C" ""
    ,edt maybeColour "newP3C" ""
    ,edt maybeColour "newP4C" ""
    ]

sendNewColours = msg "SendNewColours"
    [edt maybeColour "newP1C" ""
    ,edt maybeColour "newP2C" ""
    ,edt maybeColour "newP3C" ""
    ,edt maybeColour "newP4C" ""
    ]
sendTap = msg "SendTap"
    [otherPlayer,xCoord,yCoord]
otherPlayer = edt (ElmIntRange 0 3) "otherPlayer" "number of other player who tapped"

-- the actual app that is to be generated
clientServerApp :: ClientServerApp
clientServerApp = (
                "Start" --client start state
             ,  "Nobody" --server start start
             ,  M.fromList [("Start",start),("Wait",wait),("HaveFrac",haveFrac),("Ready",ready)] --client states
             ,  M.fromList [("Nobody",nobody),("One",one),("Two",two),("Three",three),("Four",four)]                                 --server states
             ,  M.fromList [("Channel",channelType),("Colour",testRGB),("Frac",fracType)]                            --extra client types
             ,  M.fromList [("Colour",testRGB),("Frac",fracType)]        --extra server types
             ,  csDiagram --client state diagram
             ,  ssDiagram --server state diagram
             )

clientConnect = ("ClientConnect",[])
clientDisconnect = ("ClientDisconnect",[])

csDiagram :: ClientStateDiagram
csDiagram = M.fromList 
            [
                (("Start",    login)     ,("Wait",    Just submitLogin))
            ,   (("Wait",     sendFrac)     ,("HaveFrac",   Nothing))
            ,   (("HaveFrac", startDragging)     ,("HaveFrac",   Nothing))
            ,   (("HaveFrac", stopDragging)     ,("HaveFrac",   Nothing))
            ,   (("HaveFrac", dragging)     ,("HaveFrac",   Just changeColour))
            ,   (("HaveFrac", sendNewColours)     ,("HaveFrac",   Nothing))
            ,   (("HaveFrac", sendFrac)     ,("HaveFrac",   Nothing))
            ,   (("HaveFrac", tapReady)     ,("Ready",   Just readyMsg))
            ]

ssDiagram :: ServerStateDiagram
ssDiagram = M.fromList 
            [
                (("Nobody", submitLogin), ("One", ToAll sendFrac))
            ,   (("Nobody", clientConnect), ("Nobody", NoClientMessage))
            ,   (("Nobody", clientDisconnect), ("Nobody", NoClientMessage))
            ,   (("One", submitLogin), ("Two", ToAll sendFrac))
            ,   (("One", changeColour), ("One", ToAll sendNewColours))
            ,   (("One", clientConnect), ("One", NoClientMessage))
            ,   (("One", clientDisconnect), ("Nobody", NoClientMessage))
            ,   (("Two", submitLogin), ("Three", ToAll sendFrac))
            ,   (("Two", changeColour), ("Two", ToAll sendNewColours))
            ,   (("Two", clientConnect), ("Two", NoClientMessage))
            ,   (("Two", clientDisconnect), ("One", ToAll sendFrac))
            ,   (("Three", submitLogin), ("Four", ToAll sendFrac))
            ,   (("Three", changeColour), ("Three", ToAll sendNewColours))
            ,   (("Three", clientConnect), ("Three", NoClientMessage))
            ,   (("Three", clientDisconnect), ("Two", ToAll sendFrac))
            ,   (("Four", submitLogin), ("Four", NoClientMessage))
            ,   (("Four", changeColour), ("Four", ToAll sendNewColours))
            ,   (("Four", clientConnect), ("Four", NoClientMessage))
            ,   (("Four", clientDisconnect), ("Three", ToAll sendFrac))
            ]

testRGB :: ElmCustom
testRGB = ElmCustom "Colour" [("RGB", 
                                    [ (ElmIntRange 0 255, "red", "defines the red value of the RGB colour")
                                    , (ElmIntRange 0 255, "green", "defines the green value of the RGB colour")
                                    , (ElmIntRange 0 255, "blue", "defines the blue value of the RGB colour")
                                     ]
                              )
                          , ("HSL", 
                                    [ (ElmFloatRange 0 1 7, "hue", "defines the hue value of the HSL colour")
                                    , (ElmFloatRange 0 1 7, "saturation", "defines the saturation value of the HSL colour")
                                    , (ElmFloatRange 0 1 7, "light", "defines the light value of the HSL colour")
                                     ]
                              )
                          , ("RGBA", 
                                    [ (ElmIntRange 0 255, "red", "defines the red value of the RGBA colour")
                                    , (ElmIntRange 0 255, "green", "defines the green value of the RGBA colour")
                                    , (ElmIntRange 0 255, "blue", "defines the blue value of the RGBA colour")
                                    , (ElmFloatRange 0 1 7, "alpha", "defines the alpha value of the RGBA colour")
                                     ]
                              )
                          , ("HSLA", 
                                    [ (ElmFloatRange 0 1 7, "hue", "defines the hue value of the HSL colour")
                                    , (ElmFloatRange 0 1 7, "saturation", "defines the saturation value of the HSL colour")
                                    , (ElmFloatRange 0 1 7, "light", "defines the light value of the HSL colour")
                                    , (ElmFloatRange 0 1 7, "alpha", "defines the alpha value of the HSLA colour")
                                     ]
                              )
                          ]