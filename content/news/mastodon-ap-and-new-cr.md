---
title: Mastodon launches their ActivityPub support, and a new CR!
date: 2017-09-10T00:00:00Z
author: Christine Lemmer-Webber
tags:
  - old
---

Greetings!
Big news this week, from multiple directions!

## Mastodon and ActivityPub, together at last!

First of all,
[Mastodon](https://joinmastodon.org/)
has
[launched version 1.6 with ActivityPub support](https://hackernoon.com/mastodon-and-the-w3c-f75f376f422)!
This is a *huge* piece of news.
While Mastodon is not the first implementer of ActivityPub, they
are by far the largest existing implementation, with approximately
850k registered users.
We're excited to have them on board!

## A new Candidate Recommendation!

This week we published a
[new Candidate Recommendation](https://www.w3.org/TR/2017/CR-activitypub-20170907/)
(aka "CR") of
[ActivityPub](https://www.w3.org/TR/activitypub/).
This release contains two major changes:

* <code>[Follow](https://www.w3.org/TR/activitypub/#follow-activity-inbox)</code>
  requests are now explicitly replied to with either an
  <code>[Accept](https://www.w3.org/TR/activitypub/#accept-activity-inbox)</code>
  or
  <code>[Reject](https://www.w3.org/TR/activitypub/#reject-activity-inbox)</code>.
* `publicInbox`
  is now renamed to
  <code>[sharedInbox](https://www.w3.org/TR/activitypub/#shared-inbox-delivery)</code>
  and in addition to being used for distributing and reading public
  posts, it may also be used to deliver posts to followers to reduce
  the number of HTTP requests made on followers-only posts between federated
  servers.

These changes are normative, so update your implementations!

The Candidate Recommendation is the period in which we try to
stabilize the standard and get enough implementation to make it to
Recommendation status.
We don't take normative changes lightly, but sometimes we such changes
are found to be necessary in this stage... in this case, we found that
both of these changes were necessary for Mastodon, and projects the
size of Mastodon, to adopt ActivityPub.

## What's next?

We've quietly launched the
[test suite](https://test.activitypub.rocks/)...
very quietly, because not all test suite functionality is added yet!
Only the "client-to-server server" section is yet working.
However, we're working on the rest of it and hope to have it up
sometime within the next few weeks.

That's it for now.
Happy implementing, everyone!
