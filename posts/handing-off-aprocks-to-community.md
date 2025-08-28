title: Handing off activitypub.rocks to the ActivityPub community
author: Christine Lemmer-Webber
date: 2025-08-28 10:00
desc: Handing off activitypub.rocks to the ActivityPub community
tags: meta, website
---
Hello everyone, Christine Lemmer-Webber here. I'm here to hand off
this humble website, built and maintained by myself but, to be honest,
not updated or stewarded nearly as well as I could have, to the
broader ActivityPub community and the
[W3C Social Web Community Group](https://www.w3.org/wiki/SocialCG)
in particular. Which is why I am handing it off.
The [last post I made to this website](https://activitypub.rocks/news/overdue-site-updates.html)
was in 2021, announcing some site updates, which were even then long
overdue.

Time flies.
On [November 14th 2016](https://activitypub.rocks/news/activitypubrocks-launches.html),
a period of time uncomfortably close to a decade ago,
this website, [activitypub.rocks](https://activitypub.rocks/), was launched.
At the time, ActivityPub hadn't even reached the Candidate Recommendation
stage of the W3C process, though work had been going on it for a long time,
and Mastodon had not begun adopting it either (Mastodon had just launched
earlier that year and I hadn't even heard of it at the time). ActivityPub
would not become a W3C standard for another two years.

It was unclear at the time this website was created that ActivityPub
would reach the level of success it has. ActivityPub has a long
history, preceding even its work in the W3C process, with its most
clear beginnings as the 
[Pump.io API](https://github.com/pump-io/pump.io/blob/master/API.md)
designed by Evan Prodromou.
Erin Shepherd transformed pump.io's API documentation into a draft of
a specification document, and Jessica Tallon and I carried the
document through the rest of the specification process, with some
major rewritings by Amy Guy. But of course this leaves out much
history too, and many contributors. There were many participants in the
[W3C Social Web Working Group](https://www.w3.org/wiki/Socialwg/)
where ActivityPub was originally standardized. And ActivityPub since
has been driven by the implementers of the specification, of which
there have been many, not to mention the numerous instance
administrators and, of course, users who have made the fediverse such
a special place.

This website was a small advocacy site put together by me, and has
been continuously referenced as if the home of ActivityPub. And,
effectively, when a thing is referenced as if it is the home of
something on the web, often that effectively makes it the home. This
website deserves better stewardship than just my own. So I am happy
to hand it off so it can get the love and care it deserves.

But since we are moving through memory lane in this post, I thought I
would end things with some historical artifacts I recently dug up.
Though ActivityPub descended from pump.io's API, the earliest
implementations of ActivityPub as-specified were my own test
implementations. They weren't very good, and they weren't really for
anything but my own testing that the ideas of ActivityPub worked, but
there were a few of them (including the test suite which, yes, was
often down, but if you heard the rumor that it was built from the
bones of a multiplayer text adventure game I wrote, those rumors are
correct). But I thought I'd dig out a couple of screenshots for them,
just for fun, just for history, just as a little parting gift.

Here is Pubstrate, a simple ActivityPub server I wrote in Guile (but
which had some neat ideas, even though if it was only minimally
usable), with these screenshots taken just shortly before this website
was made:

[![A screenshot of Pubstrate in action, with some textual posts](/static/images/blog/pubstrate-2016-09-14.png)](/static/images/blog/pubstrate-2016-09-14.png)

Even at the time, preceding Peertube's adoption, ActivityPub was
intended for adoption across a wide variety of forms of media, not
just microblogging:

[![A video in Pubstrate](/static/images/blog/video-in-pubstrate.png)](/static/images/blog/video-in-pubstrate.png)

[![An image in Pubstrate](/static/images/blog/pubstrate-ellen-terry.png)](/static/images/blog/pubstrate-ellen-terry.png)

Finally, it's often forgotten that ActivityPub has not only a
server-to-server protocol, it has a client-to-server protocol too!
Here was soci.el, an emacs client for ActivityPub, being tested
against Pubstrate:

[![soci.el in action](/static/images/blog/soci-el-2016-09-14.png)](/static/images/blog/soci-el-2016-09-14.png)

But again, time flies. I'm grateful for the fediverse for keeping
ActivityPub alive and making the work of myself and my colleagues so
meaningful and worthwhile, such an honor to be part of. And I am
grateful for the task force within the Social Web Community Group who
are volunteering to steward and maintain and carry forward this humble
website, and ActivityPub as a whole!

Onwards and upwards! See you on the fediverse!
