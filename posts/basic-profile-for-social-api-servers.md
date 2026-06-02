title: Initial Draft of Basic Profile for Social API Servers
author: Evan Prodromou
date: 2026-05-19 10:00
desc: New draft document from the ActivityPub API task force
tags: api
---

There is a new [Basic Profile for Social API Servers](https://swicg.github.io/activitypub-api/basicprofile) initial draft put out by the [ActivityPub API Task Force](https://swicg.github.io/activitypub-api/). Developers and community members are encouraged to provide feedback on the [issue tracker for the task force](https://github.com/swicg/activitypub-api/issues).

[ActivityPub](https://www.w3.org/TR/activitypub/) defines a "Social API" that lets applications act on behalf of a user with a social networking platform. The ActivityPub API provides an extremely flexible interface for building social applications. Because unlimited kinds of activities can be created by clients, novel applications can be built on top of the ActivityPub network.

Unfortunately, the ActivityPub API has not been widely implemented in its read-write form, even by social platforms that implement the ActivityPub federation protocol. Those servers that have implemented it have taken opinionated steps in implementation, making it hard for client developers to achieve interoperability.

This profile is a step in the direction to improve the interoperability issue. It covers three important aspects of the API:

- ActivityPub. It makes some concerted points about how the ids of ActivityPub objects are defined, and what behaviour a social API server should implement.
- [OAuth 2.0](https://oauth.net). OAuth is the default API authorization framework, used by commercial APIs worldwide. However, it's extremely flexible, which means that a client that implements OAuth will not necessarily implement the same profile as the server it's trying to connect to. The Basic Profile selects some common options to make it easier to interoperate.
- HTTP. There are a lot of options with [RESTful](https://en.wikipedia.org/wiki/REST) APIs, like rate limits, CORS, and caching. The basic profile gives some suggestions on how to apply these tools correctly.

There's a lot that's **not** in the basic profile: push notifications, search, other endpoints. That's the basic part -- these extensions can be covered in other documents, and negotiated between client and server on a case by case basis. The **basic** profile is for the parts that are needed to get to that point!

There are a few open questions with this profile. The [OAuth scopes](https://github.com/swicg/activitypub-api/issues/69) are a first draft and don't represent consensus; some task force participants suggest using [Rich Authorization Requests](https://github.com/swicg/activitypub-api/issues/72) also or instead. There are also very few MUST requirements; even supporting client-to-server interactions is a SHOULD.

Regardless, if you are interested, please consider reporting issues, and if you are a server operator, please consider implementing!
