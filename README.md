Service Demo
============

A small demo showing a couple general outlines I came up while learning about how to wire up user actions or tickers to service requests and subsequently receive their responses as further actions to update the app's model.

The demo itself is an extremely simple app with two services that do the exact same thing: Upon receiving a Request, they wait a couple seconds, then respond with a Float. (Number, not Rootbeer.)  The app also has a status field indicating the status of the number request, and uses this to disable the buttons so the user can't spam requests.

The outlines themselves are horribly high-level vague descriptions, because they don't always map directly to the actual implementation.  Rather, they're meant to provide a quick idea for all the essential parts of the wiring process.

In their barest essence, both processes work like so:

1. Some source signal has an update.  Examples include:
	- The User clicks a buttor or presses a key which results in sending a Message to the Address of some Actions Mailbox, the signal of that Actions Mailbox being the Source Signal.
	- A Timer ticks.
2. The request goes out into the world.  Elm then forgets anything happened because impurity is the concern of the world.  (Sending a request could trigger another Action, though, if so desired.)
3. A response appears some time later, updating a Response signal in the app.
4. An almost-final signal that maps the Response into an Update Action so that it can be used to mutate the model by the `update` function.

Following are the two outlines in greater detail.  If you'd just like to run this project, see **Running** at the bottom.



Two Port Method
---------------

This is the method that will typically be used when you must make requests against arbitrary APIs for which you have some Native (JS) component.  This is recommended over trying to make a Native module as Native modules are fragile, or at least more fragile than using Ports.

The parts are as follows:

- *Source*: Some signal which updates everytime a request is to be made.  See item 1 in the barest-essence outline in the introduction for examples of this.
- *Outflow/Request Port*: The port out through which requests flow in the form of JSON, which in Elm are Records with only primitive values such as Strings, Numbers, Lists, Maybes, and other Records of those same things.  In the Native (JS) portion of your code, you subscribe to this port for value updates and trigger the actual requests in reaction to those updates.  Upon receiving the full response, the value can be sent to the next port, the *Inflow/Response Port*.
- *Inflow/Response Port*: The port in through which responses flow, also in the form of JSON.
- *Reactor*: A Signal of Actions which can be used to update the App's model.  The Actions are a `map` of the *Inflow/Response Port* sigtal, and it is here you perform any necessary processing of the responses before they are used to update the model.



Task Executor Method
--------------------

This is the method that will typically be used when you have a library with a Native implementation, whose primary functions return Tasks which are executed by a port.

> Note that since Native modules depend on the inner workings of the Elm Runtime, writing your own is *not* recommended!  The one written here is for illustrative purposes only.

The parts of this are as follows:

- *Source*: The same as the *Source* in the Two Port Method.
- *Executor Port*: The port which actually executes the tasks in the *Request Map Signal*.
- *Response Inbox*: The Mailbox to which the Results (or whatever else you want to use as the response) are sent.
- *Reactor*: The same as the *Reactor* in the Two Port Method, except that it is a `map` of the *Response Inbox*'s Signal.



The Demo Service
----------------

In the interest of keeping this as minimal as possible, the service demonstrated in each case is kept as simple as possible.  In this case, each takes as a request any string, including the empty string, and returns in response a random number with the range `[0 5)`, and never returnning anything interpreted as an error.  To further complicate matters, this response is sent 2 seconds after the request is received.



Running
-------

To actually run this demo, you will need the following installed:

- npm
- Brunch
- Elm

First, run `npm run deps`, that will download both the Brunch and Elm dependencies.  If that ran without errors, you can run either `npm start` or `brunch watch -s` and then point your browser to `localhost:3333`.

Note: The `elm-package.json` file is only present to handle the Elm dependencies.
