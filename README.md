# Perennial - a Ruby Event-driven application Library #

Perennial is yet another god damned event library / framework
for Ruby, built on top of EventMachine. The whole goal of Perennial
is to make it easy to build a particular style / class of application
such as [Marvin](http://github.com/Sutto/marvin). Most of the code
has been extracted from building Marvin (and later, BirdGrinder - like
Marvin but for twitter). 

Applications built for Perennial are devised around the concept of 'clients'
and 'handlers'. Clients are things which handle the actual processing (e.g. 
Marvin's IRC client takes the IRC protocol and converts it into events) and
handlers respond to messages. In practice, it's an approach inspired by Rack
in that we do the simplest thing's possible.

Since each event processed by a handler is incredibly simple (a symbol for a name
and a hash of associated options / details), and there are typically few requirements
(e.g. a handler only typically needs to define the 'handle' method) it
makes it relatively easy to build your application how you like.

In other words, Perennial is mainly a bunch of useful mixings (Dispatchable,
Hookable, Delegateable) which fit in with some evented application design 
along with the framework for building applications around this design.