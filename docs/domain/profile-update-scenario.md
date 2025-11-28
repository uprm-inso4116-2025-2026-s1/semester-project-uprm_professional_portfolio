Profile Update Propagation Case Study


This short case study explains how a candidate updating their profile propagates through the domain model.
The goal is to show how a seemingly simple action, editing a profile, affects other parts of the system, especially when the candidate already has active Matches and Connections.

-----------------------------

1. Scenario (User-Level)

A candidate named Alicia has an active profile on the platform and has already matched with three companies for potential internship roles.

One afternoon, she completes a new certification in data analytics and wants to reflect this on her profile. She opens the app, updates her StudentProfile by adding the certification, adjusts her skills list, and uploads a short new video explaining the project she worked on.

After saving, Alicia notices that all her existing matches now show the updated information. Recruiters who previously matched with her can immediately see the changes when they revisit the Connection or open the chat thread attached to it.

From Alicia’s perspective, she simply edited her profile.
Behind the scenes, however, the update triggered domain events and consistency rules across parts of the system that depend on profile data.

-----------------------------

2. Domain Concepts Involved
   StudentProfile

The candidate’s primary domain object containing academic details, skills, preferences, and media. It is directly edited by the user.

Match:

* Represents an established mutual interest between Alicia and a company’s role. Matches rely on the current version of the profile whenever a recruiter views it.

Connection:

* A long-lived container created from a Match. It is the context for chat, follow-up actions, and visibility of the candidate’s updated information.

MessageThread:

* Attached to each Connection. When a recruiter opens the chat, the UI draws from the most recent StudentProfile, not a cached copy.

Read Models (Supporting Concept):

* Used by Discovery and Messaging to present the most up-to-date snapshot of Alicia’s profile to matched recruiters.

3. Domain Sequence

-----------------------------

Below is the domain-level interpretation of the scenario:

Step A — Candidate Edits Profile
updateProfile(studentProfile, newDataAnalyticsCert)


The StudentProfile aggregate validates and saves the new information.

Step B — Domain Emits ProfileUpdated Event

A domain event signals that the candidate’s profile has changed:

ProfileUpdated(studentId)


No Matches or Connections are modified directly — they reference the profile, not a duplicated copy.

Step C — Application Reacts to ProfileUpdated

Application services react to the event:

Refresh profile read models for:

* Discovery

* Connections

* Recruiter views

Trigger background updates for cached lists (e.g., candidate suggestions).

No domain objects beyond the profile are mutated here.

Step D — Recruiters See Updated Info

When a recruiter opens:

* A Match

* A Connection

* A MessageThread

the UI retrieves the current StudentProfile, so the new certification and updated skills appear immediately.

Step E — Optional System Behaviors

Depending on configuration:

Recruiters may receive a “Profile Updated” ribbon or hint.

Ranking or recommendations may adjust based on her new skills.

These are application-level reactions, not domain mutations.

4. Why This Scenario Matters

-----------------------------

This case study shows how:

* Updating a profile does not require modifying Matches or Connections.

* The domain model is designed so that profile data is referenced, not copied into separate aggregates.

* A single event (ProfileUpdated) ensures consistency across all parts of the system.

* Active matches automatically reflect new information without needing a second matching process.

* The design supports future extensibility (e.g., recruiters subscribing to profile changes).
