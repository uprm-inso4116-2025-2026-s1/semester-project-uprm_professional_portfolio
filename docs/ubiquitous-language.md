# Ubiquitous Language Glossary - EXTENSION

This section lists terms not already defined in the base set of ubiquous language (Recruiter, Candidate, Profile, Swipe, Like, Pass, Match, Message). All definitions reflect how we’re using these concepts in the documentation.

---

### Student
A person currently enrolled at a university/college. In our domain, every Student is a Candidate, but not every Candidate is a Student. We use **Student** when context involves campus events, student portfolios, or coursework.

### User
A technical/authentication concept. A logged-in account that is either a **Student** or a **Recruiter**. We avoid using “User” to describe domain roles.

### Employer
The organization that a Recruiter represents. Owns job **Openings** and brand presence. Distinct from the person acting (Recruiter).

### Company (alias of Employer)
The institutional profile representing the Employer in the system (logo, description, sectors, location).

### StudentProfile
Typed Profile for a Student/Candidate. Contains resume, skills, preferences, visibility settings, and **Portfolio** items.

### RecruiterProfile
Typed Profile for a Recruiter. Contains company association, role/title, sectors, location, and verification status.

### ProfileCard
A condensed, swipeable view of a Profile (StudentProfile or RecruiterProfile). Shown in the **Discovery Feed**.

### Discovery Feed
The main browsing view that serves a Deck of ProfileCards for swiping.

### Deck
The ordered set of ProfileCards currently presented to a given account in the Discovery Feed. Refreshes based on preferences, prior swipes, and rules.

### Connection
A persistent relationship state created after a **Match**. Enables chat, interview scheduling, and follow-ups.

### Chat
An ordered sequence of **Messages** scoped to a Connection. Used for coordination after a Match.

### Portfolio
Evidence of work attached to a StudentProfile (projects, links, PDFs, media). Supports recruiter evaluation.

### Event
A scheduled activity relevant to recruiting (career fair, info session, meetup). Used for discovery, RSVP, and attendance tracking.

### RSVP
An explicit intent to attend an Event. Updates capacity and powers reminders.

### Attendance
A recorded participation of a Student or Recruiter at an Event (used for follow-ups and metrics).

### Notification
A system alert delivered to an account (e.g., Match created, unread Chat, Event reminder).

### Queue
An ordered waiting line (physical or digital) used to preserve turn order (e.g., at a booth or for processing requests).

### Opening (Job Opening)
A role published by an Employer with defined **Requirements** (must-haves, nice-to-haves), location, modality, and timeline.

### Requirements
Structured criteria for an Opening (skills, eligibility, language, authorization). Used to assess **Eligibility**.

### Eligibility
Whether a Student/Candidate meets the defined Requirements of an Opening (meets / partially meets / does not meet).

### Shortlist
A curated set of Candidates selected by a Recruiter for next steps (review, outreach, interview).

### Interview
A scheduled conversation between a Recruiter and a Student following a Connection/Shortlist. Must avoid overlapping time blocks.

### Visibility
Profile exposure setting for a StudentProfile:
- **Public** — appears in Recruiter search.
- **By Match** — visible only to the matched party.
- **Private** — not discoverable; shared only by explicit action.

### Consent
A Student’s permission to share specific data with an Employer or organizer. Must be recordable and revocable.

### Identity (UUID)
An immutable unique identifier assigned to core entities (Profiles, Matches, Events). Ensures stability across updates and systems.

### Session
The authenticated runtime context for an account. Authorizes actions (swipes, messages, RSVPs).

### VerificationPolicy
A rule requiring a Recruiter/Employer to satisfy verification checks before certain actions (e.g., messaging, event hosting).

### Invariant
A rule that must always hold at the model boundary.

### Factory
A creation mechanism that enforces Invariants when instantiating entities (e.g, MatchFactory ensures valid parties and uniqueness).

---

#### This glossary is a **living document**. New terms may be added as the domain evolves, but definitions must remain consistent across documentation and implementation.
