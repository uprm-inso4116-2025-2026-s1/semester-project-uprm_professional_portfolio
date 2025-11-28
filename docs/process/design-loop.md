-Introduction
The lectures referenced remind us that design is not a one-time actionstep between the requirement and the code, but an ongoing loop.

This document describes how that design loop looks in our project using the principles discussed in class. It also shows how the ideas were applied to the project using the swiping feature. It will also dicuss practical guidelines that we can use when designing new features.

The goal is to make our design process explicit and repeatable, so that future additions can be guided by domain understanding.


- Summary of the Design Process:
We must utilize the information we currently possess to design a system that will function properly in the future. The quality of the end product relies on the effectiveness of the planning.

The design begins with our desired results, such as students and recruiters connecting, participating in events, exchanging messages, and more. We then reverse engineer to determine the behaviors, structures, and data required to achieve these outcomes.

Effective design requires the understanding of domain language and concepts first. The frameworks and databases are chosen to work with our understanding of the domain, not as the starting point.

The domain model serves as an abstract depiction of the key concepts within the domain

In this project, we are following the design loop introduced in the lectures.
1. Understand and refine the domain and requirements
2. Model the key concepts and relationships
3. Plan the system structure and behavior
4. Implement and integrate
5. Learn from feedback and tests
6. Refactor the model and code


Case Study 1 – Swiping & Matching Feature
This shows our design loop in use: understand → model → plan/implement → refactor.

Problem:
At first, the behavior of swiping and matching was dispersed throughout UI descriptions and prototype code. Gestures, card transitions, and "like/pass" meanings were combined, creating difficulty in addressing inquiries such as:
When exactly does a Match exist?
What counts as mutual interest?
When is a persistent Connection created and when is messaging allowed?

Requirements:
The need was to consolidate swipe and match rules within the Domain layer, utilizing the project’s ubiquitous language, so that:
- The system behaves consistently across screens and milestones.
- UI changes (new animations or interactions) do not change the domain rules.
- The team can reason about swipe → match → connection as a clear sequence.

Domain understanding:
- Swipe – An action within the domain signifying interest (“Like”) or rejection (“Pass”) on a ProfileCard. The users are linked to the action.
- Match – A situation formed solely when there is shared interest between a student and a recruiter.
- Connection – A continual relationship formed as a result of a Match and utilized as the backdrop for messaging.
- Session – The environment in which swipes and profile displays happen (the existing swipe “deck”).
A **Like** merely indicates interest and doesn't constitute a match on its own, while a Connection represents something stronger and longer-lived than a single Match event.

Domain model decisions:
1. Swipe- The user indicates a Like or Pass on a ProfileCard. Swipe is recorded as a domain event associated to the user.
2. Evaluate Swipe- The Domain layer logs the action and analyzes its impact. A Pass removes the profile from the active **Session**. A Like indicates interest but does not initiate additional actions by itself.
3. Verify Mutual Interest- Mutual interest occurs only when both individuals have previously marked a Like on each other’s ProfileCard. This rule can be expressed as:
    - Like(A, B) AND Like(B, A) ⇒ Candidate for Match.
4. Create Match- A Match is established only for valid “candidate pairs” with mutual interest. A Match is distinct for each Recruiter–Student pair and must not duplicate an existing connection. Matches cannot be formed for invalid, blocked, or private profiles.
5. Trigger Connection- A Connection is established as the domain result of a valid Match. The Connection remains in effect beyond the temporary Match event and acts as the only context for messaging.

From these behaviors the domain enforces the following invariants:
- A Match cannot be formed without mutual interest.
- A Connection cannot be formed without a Match.
- A Pass prevents the same ProfileCard from reappearing within the same **Session**.
- A Match must be unique and cannot be duplicated.
- Messaging requires an active Connection.
- Blocked users cannot form new Matches or Connections.
The domain also explicitly separates UI responsibilities:
- Swipe gestures, card animations, drag distances, and undo actions are UI concerns.
- Presentation logic (which card appears where) stays in the UI.
- The Domain layer only recognizes committed domain actions and events (Swipe, Match, Connection).

Implementation path:
To reflect these decisions, the team treated the Domain layer as the single source of truth for all swipe and match logic:
- The UI layer reports high-level actions (e.g., “user swiped right on profile X”), but does not decide whether a match or connection exists.
- Domain services and aggregates (e.g., Match, Connection, and their associated services/repositories) implement:
    - Recording Swipe actions.
    - Evaluating swipes and checking mutual interest.
    - Creating Match events.
    - Creating and maintaining Connections as persistent relationships.
- Infrastructure (repositories) persists swipes, matches, and connections, but follows the invariants defined by the domain rules.
- Messaging features consult the Connection state instead of ad-hoc flags in the UI.
This structure keeps the matching behavior aligned with the ubiquitous language and independent from changes in UI frameworks or gesture libraries.

Refinements:
Before this refactoring, much of the swipe behavior was implicit:
- Some decisions (e.g., when to hide a card, when a match “really” existed) were placed into UI controllers and swipe widgets.
- Terms like “like”, “match”, and “connection” were sometimes used interchangeably, leading to confusion and duplicated logic.
Through the design loop and the lectures on domain modeling:
- The team moved rules from UI to the Domain layer, making Swipe, Match, Connection, and Session explicit concepts.
- They defined invariants (no match without mutual interest, no connection without a match, uniqueness of match, messaging only with active connection, etc.) and checked them in domain code instead of UI conditions.

As a result, the swiping feature now clearly demonstrates the design loop:
- Clarify domain language and behaviors.
- Express them as explicit domain rules and invariants.
- Implement those rules in the Domain layer.
- Refine UI and infrastructure to depend on the domain model instead of ad-hoc behavior.

- Guidelines:
**Begin with domain terminology, rather than widgets or tables** before suggesting a UI or database design, specify the domain concepts at play.
**Maintain synchronization between the domain model and code** each time we create or alter a concept, ensuring both the domain documentation and the pertinent classes are updated.
**Utilize case studies as models** When creating a new feature, reference a documented case study and replicate the same process

- References:
Schütz-Schmuck, Marko. **The Nature of the Design Process**
Schütz-Schmuck, Marko. **Putting the Domain Model to Work**
LTT #338 Ensure Swipe & Match Logic Belongs to the Domain
