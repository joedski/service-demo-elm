module PortsService
    ( Request
    , Response
    , requestAddress
    , RequestPort
    , requestPort
    , ResponsePort
    )
    where

-- in this case, we're not really so complicated...
type alias Request = String
type alias Response = Float

{-
Unlike with the Executor Service, the Ports Service won't have any
"library only" code since a Native module is not included.
Rather, this pattern is more for interacting with JS libraries.
About the only code worth including in a Library would be functions for
translating between Elmish values and JSish values.

The parts are as such:
- Source: `requestMailbox.signal` is the Source of updates that set everything in motion.
    It's done of course by sending messages to the mailbox, leading to updates in this signal.
- Outflow/Request Port: `requestPort` is the set as an outflow/request port.
    In this case, it is merely `requestMailbox.signal`,
    with no additional preprocessing before it's handed to the JS.
- Inflow/Response Port: `ResponsePort` defines the type of the inflow/response port.
    No actual definition is needed because any declared port without a definition
    is assumed to be an inflow port.  It's initial value is defined
    when the Elm App is initialized in the JS.
- Reactor: The Reactor is not defined in the module because
    it depends on the Actions that the App has available to it.

The module is set up so as to try to minimize the amount of code in the wiring section.
Basically all that should be needed is:

    port requests : PortsService.RequestPort
    port requests =
        PortsService.requestPort

    port responses : PortsService.ResponsePort

Note that `port responses` has only a type annotation and does not have a definition.
Its initial value must be defined in the JS.

    var app = Elm.fullscreen( Elm.ServiceDemoApp, {
        responses: 0
    });

-}

requestMailbox : Signal.Mailbox Request
requestMailbox =
    Signal.mailbox ""

requestAddress =
    requestMailbox.address

requestPort =
    requestMailbox.signal

--responsePort : Signal Response
type alias RequestPort = Signal Request
type alias ResponsePort = Signal Response
