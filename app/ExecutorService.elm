module ExecutorService
    ( Request
    , Response
    , send
    , requestAddress
    , responseSignal
    , executor
    )
    where

import Native.ExecutorService
import Task exposing (andThen)

-- in this case, we're not really so complicated...
type alias Request = String
type alias Response = Float

{-
Implementation note: When packaged as a separate library,
only the send function would normally be present and exposed.
The mailboxes, the addresses, and the executor signal would be defined in your app's code base,
since you may need to perform some extra processing yourself to make things in your app uniform.

The parts in this service are as such:
- Source: `requestMailbox.signal` acts as the action source which kicks off the whole process.
- Executor Port: `executor` does what it says on the tin, at least when actually made into a port.
    In this particular case, it uses Task.spawn to handle tasks asyncronously rather than
    strictly-sequentially
- Response Inbox: `responseMailbox` receives the actual Results from the Tasks executer in `executor`.
- Reactor: The Reactor is not defined here because it's very much app specific.
    It will at some point use `responseSignal` to create Actions in reaction to those responses.
-}

send : Request -> Task.Task x Response
send =
    Native.ExecutorService.send

requestMailbox : Signal.Mailbox (Maybe Request)
requestMailbox =
    Signal.mailbox Nothing

requestAddress =
    Signal.forwardTo requestMailbox.address Just

responseMailbox : Signal.Mailbox (Result x Response)
responseMailbox =
    Signal.mailbox (Result.Ok 0)

responseSignal =
    responseMailbox.signal

-- It's of type (Task x ()) because it ends with a Signal.send.
executor : Signal (Task.Task y Task.ThreadID)
executor =
    let
        maybeSend maybeRequest =
            case maybeRequest of
                Nothing ->
                    Task.succeed ()

                Just request ->
                    Task.toResult (send request)
                    `andThen` Signal.send responseMailbox.address

        --execTaskAndSendResult task =
        --    Task.toResult task
        --    `andThen` \ result -> Signal.send responseMailbox.address result
    in
        {-
        This uses the function composer (>>) to first 'send' the request,
        which creates a Task of Error and Response,
        then pass it to execTaskAndSendResult which converts that first Task
        into a Result and then sends that to the response mailbox.
        Lastly, the final send Task is sent to a 'thread' with Task.spawn.
        -}
        Signal.map (maybeSend >> Task.spawn) requestMailbox.signal
