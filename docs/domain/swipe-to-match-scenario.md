Swipe-to-Match Case Study: 

How the Domain Model Supports Mutual Interest
Purpose

This short case study walks through a single end-to-end experience in the product, two users expressing interest and forming a match, and shows how this flow is represented and implemented using the domain model.

The goal is not to list every domain concept, but to show how the relevant concepts collaborate to make one meaningful feature work.

________________________________________

1. The Scenario (User-Level)

A student named Lena opens the app and sees a role from SkyBridge Robotics. She swipes right because the internship matches her interests.

Later, Daniel, a recruiter at SkyBridge, reviews candidate suggestions. He taps Lena’s profile, watches her demo video, and swipes right as well.

A match is created. Chat becomes available. Both users are notified.

From their perspective, the system “just works”: two swipes → one connection → a conversation begins.

Behind the scenes, a set of domain objects coordinate this flow.

________________________________________

2. Domain Model Elements Involved

This scenario involves only the small portion of the domain model needed for matching:

CandidateProfile:

* Contains Lena’s skills, preferences, and media.

* Used by the discovery logic to determine which RoleCards she sees.

RecruiterProfile / RoleCard:

* Represents SkyBridge’s internship.

* Includes skills required and preferences.

Swipe:

* Records an interest expression.

* Does not guarantee any relationship on its own.

Match:

* Created only when two complementary swipes occur.

* Represents confirmed mutual interest.

Connection:

* Derived from a Match.

* Used as the container for chat and ongoing interaction.

MessageThread (activated later):

* The communication channel attached to the Connection.

________________________________________

3. How the Scenario Plays Out in Domain Terms

Below is the domain-level interpretation of the same story.

Step A — Candidate expresses interest
SwipeRight(candidateProfile, roleCard)


Result: A right-swipe is stored. No match is created yet.

Step B — Recruiter expresses interest
SwipeRight(recruiterProfile, candidateProfile)


Result: Another independent right-swipe is stored.

Step C — Domain detects mutual interest

A domain service checks for two compatible swipes:

if CandidateRightSwipe AND RecruiterRightSwipe → MutualInterestDetected

Step D — Match + Connection are created
Match(candidateProfile, roleCard)
Connection(candidateProfile, roleCard)


The pair now has a persistent, ongoing relationship.

Step E — Application reacts to domain events

A chat thread is created for the Connection.

A notification is sent to both sides.

Nothing new is created in the domain here — these are application-level reactions to domain events.

Step F — First message

The recruiter uses the new chat thread:

MessageSent(connection, sender=Recruiter)


At this point, the match is active and communication continues under the same Connection.

________________________________________

4. Why This Scenario Matters

This short scenario shows why matching sits at the core of the domain:

The system’s value comes from mutual interest detection.

Swipes are low-level signals.

The Match is the meaningful domain concept.

The Connection is the long-lived collaboration context.

Chat exists only because the Match exists.



