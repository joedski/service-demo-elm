module ServiceDemoApp where

import Html
import Html.Events as Events
import Html.Attributes as Attrs
import Task exposing (andThen)

import PortsService
import ExecutorService



-------- Model --------
{-
The total app state is held in the model.
-}

type alias Model =
    { number : Maybe Float
    , numberStatus : Maybe NumberStatus
    }

type NumberStatus
    = WaitingForNumber
    | NumberReceived

initModel : Model
initModel =
    { number = Nothing
    , numberStatus = Nothing
    }



-------- View --------
{-
How do we display the model?
The address is included mostly because in larger apps it'd be there anyway.
-}

view : Signal.Address Action -> Model -> Html.Html
view address model =
    Html.div [ Attrs.class "app" ]
        [ viewNumber address model
        , viewControls address model
        ]

viewNumber : Signal.Address Action -> Model -> Html.Html
viewNumber address model =
    let
        displayedNumber =
            case model.number of
                Nothing ->
                    case model.numberStatus of
                        Just WaitingForNumber -> "(Waiting for a number...)"

                        Nothing -> "(Waiting for you to press something...)"

                        Just _ -> "(Waiting for something...)"

                Just n -> toString n
    in
        Html.div [ Attrs.class "displayer" ]
            [ Html.div [ Attrs.class "displayer-value" ] [ Html.text displayedNumber ]
            ]

viewControls : Signal.Address Action -> Model -> Html.Html
viewControls address model =
    let
        whenWaiting =
            (model.numberStatus == Just WaitingForNumber)
    in
        Html.div [ Attrs.class "controls" ]
            [ Html.button [ Attrs.disabled whenWaiting, Events.onClick PortsService.requestAddress "getNumber" ] [ Html.text "Get number through ports" ]
            , Html.button [ Attrs.disabled whenWaiting, Events.onClick ExecutorService.requestAddress "getNumber" ] [ Html.text "Get number through executor" ]
            ]



-------- Actions --------
{-
This section defines what actions can update the model.
In our case, we have only one action, which is to update the number to something.
-}

type Action
    = UpdateNumber Float
    | WaitForNumber



-------- Update --------
{-
This section defines how each Action actually mutates the app's model.
-}

update : Action -> Model -> Model
update action model =
    case action of
        UpdateNumber n ->
            { model
                | number <- Just n
                , numberStatus <- Just NumberReceived
            }

        WaitForNumber ->
            { model
                | number <- Nothing
                , numberStatus <- Just WaitingForNumber
            }



-------- Wiring: Ports --------
{-
Below, we define the ports, which allows the services to actually work.
-}



---- Wiring: Ports: PortsService ----
{-
The PortsService, a service implemented through the use of two ports.

With the Reactor, here we're also defining an extra action to take place
when ever a request is made: Blank out the number in preparation for the next one.
This is one way you can indicate to the user that something happened.

Also, for initialization purposes, note the order in which the merged signals occur.
When multiple signals would update at the same time, the first-most ("left"-most) wins.
-}

port portsServiceRequests : PortsService.RequestPort
port portsServiceRequests =
    PortsService.requestPort

port portsServiceResponses : PortsService.ResponsePort

portsServiceReactor : Signal Action
portsServiceReactor =
    Signal.mergeMany
        [ Signal.map UpdateNumber portsServiceResponses
        , Signal.map (\ _ -> WaitForNumber) portsServiceRequests
        ]



---- Wiring: Ports: ExecutorService ----
{-
The ExecutorService, a service implemented through the use of
a single port which executes the tasks.

Since the ExecutorService's responseSignal is of type `Signal (Result x Response),
we have to actually make Ok n to UpdateNumber n.  If we were worrying about errors,
we would have to handle Err cases, too.

Otherwise, it's the same as with portsServiceReactor,
where when we first start off an action,
we blank out the number.
-}

port executorServiceExecutor : Signal (Task.Task y Task.ThreadID)
port executorServiceExecutor =
    ExecutorService.executor

executorServiceReactor : Signal Action
executorServiceReactor =
    Signal.mergeMany
        [ Signal.map (\ (Ok n) -> UpdateNumber n) ExecutorService.responseSignal
        , Signal.map (\ _ -> WaitForNumber) executorServiceExecutor
        ]



-------- Wiring: Main --------
{-
Finally, we define the app itself.  Some people put this at the top.
It doesn't matter too much, put it where it makes the most sense to you.
-}

main : Signal Html.Html
main =
    let
        userActionsMailbox : Signal.Mailbox (Maybe Action)
        userActionsMailbox =
            Signal.mailbox Nothing

        userActionsAddress =
            Signal.forwardTo userActionsMailbox.address Just

        appActions =
            Signal.mergeMany
                [ Signal.map Just portsServiceReactor
                , Signal.map Just executorServiceReactor
                , userActionsMailbox.signal
                ]

        model =
            Signal.foldp
                (\ (Just action) model -> update action model)
                initModel
                appActions
    in
        Signal.map (view userActionsAddress) model
