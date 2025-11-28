1. Scenario Overview

This case study describes the flow:
> **“Recruiter invites a matched student to an event.”**

It shows how the project connects domain concepts:
- StudentProfile and JobSeekerProfile – how candidates present themselves and their interests.
- RecruiterProfile and RoleCard – how companies and roles are represented.
- Match and Connection – how mutual interest is captured.
- Event – how companies organize fairs, info sessions, and networking activities.

2. Narrative in Plain Language

    2.1 Story from the Student’s Perspective

Mariana is a third-year student. She signs up as a **student** and creates her **student profile**, adding her major, graduation year, preferred job locations, skills, and desired job type (internship). She can also upload a resume, add portfolio links, and optionally record a short intro video.

Once her profile is saved, Mariana goes to **Discovery & Swiping**. The app shows company/role cards with logos, role titles, and culture highlights. When Mariana sees a company she likes, she swipes right (interested) on the card. If a company does not match her interests, she swipes left (pass).

After some time using the app, Mariana receives a notification: **“It’s a match with Company X!”** From her perspective, all she did was swipe right on a few interesting companies; behind the scenes, one of those companies also swiped right on her profile. Because both sides showed interest, the system created a **match** and a persistent **connection** between Mariana and that recruiter.

Later in the semester, Mariana gets another notification in her Events feed: **“Company X is hosting a Networking Night and you’re invited.”** She opens the event, sees the date, time, and location, and chooses to RSVP. The event is added to her upcoming activities. On the day of the event, she checks the details again in the app and uses the opportunity to talk in person with the recruiter she previously matched with.

Throughout this story, Mariana mainly sees screens, buttons, and notifications—but underneath, the system is working with domain concepts like StudentProfile, RecruiterProfile, Match, Connection, and Event.

    2.2 Story from the Recruiter’s Perspective

A recruiter from **Company X** signs up as a **Recruiter**. They create a **RecruiterProfile** with company information, mission, culture, and benefits. They also define one or more **RoleCards** that specify the titles, location, skills, and minimum requirements for the roles they are hiring for, as well as preferences for candidates.

In **Talent Discovery & Swiping**, the recruiter sees candidate cards (Students and Job Seekers) that match their role filters. For each candidate, they can tap to view their full profile  and then swipe right to signal interest or left to pass. When there is a mutual right-swipe between Company X and a candidate, the system creates a **Match** and a **Connection**, and both parties are notified.

When planning “Networking Night”, the recruiter creates an **Event** under the RecruiterProfile. They add a title, description, date/time, location, audience, and RSVP capacity. The recruiter then wants to focus the event on matched candidates who fit the role criteria. Using the app, they see a list of existing Matches and pick a subset of candidates who match the event’s criteria (for example, CS/SE majors with GPA above a threshold).

For those candidates, the system records that they have been **invited** to the Event. Candidates see the event in their Events area with RSVP options. The recruiter can later check which candidates have confirmed attendance and use this information for follow-up conversations and pipeline tracking.

From the recruiter’s point of view, they are just creating events, filtering matches, and sending invitations. Behind the scenes, the domain model ties together RecruiterProfile, RoleCard, Match, Connection, and Event.

3. Domain Concepts and Relationships

    3.1 Key Domain Concepts

- **StudentProfile**  
  Represents a university student in the system. It includes:
  - Academic information (major, graduation year).
  - Location preferences and job preferences (internship/full-time).
  - Skills, interests, and optional media (resume, portfolio links, intro video).
  The StudentProfile is used to drive discovery, swiping, and matching.
- **JobSeekerProfile**  
  Represents a non-student candidate (alumni, career switcher, professional). Similar to StudentProfile but oriented around experience and career history rather than enrollment status.
- **RecruiterProfile**  
  Represents a company or recruiter account. It includes:
  - Company information, branding, and culture.
  - A collection of RoleCards.
  - Target preferences for candidates (majors, experience level, locations, etc.).
- **RoleCard**  
  Represents a specific role or position a recruiter is hiring for:
  - Title, location, pay band (if provided).
  - Required and nice-to-have skills.
  - Minimum requirements and preferences.
  RoleCards are what candidates swipe on during discovery.
- **Match**  
  Captures **mutual interest** between a candidate profile (Student or Job Seeker) and a Recruiter/Role:
  - Created only when both sides have swiped right.
  - Enforces uniqueness per candidate–recruiter/role pair.
  A Match signals that both sides are open to talking.
- **Connection**  
  A persistent relationship derived from a Match:
  - Used as the context for chat, scheduling, and event-related invitations.
  - Exists beyond a single screen or session and can be revisited later.
- **Event**  
  Represents a career-related activity organized by a recruiter:
  - Career fairs, info sessions, networking nights, virtual talks, etc.
  - Includes audience (students, job seekers), RSVP cap, date/time, and logistics.
  Events can be discovered through following companies and/or via matches.

3.2 Relationships Between Concepts

- A **RecruiterProfile** can host many **Events**.
- A **RecruiterProfile** can own many **RoleCards**.
- A **Match** links exactly one candidate profile (Student or Job Seeker) to one Recruiter/Role.
- A **Connection** is derived from a Match and represents an ongoing relationship:
  - One Connection per candidate–recruiter/role pair.
- An **Event** can be associated with:
  - Many candidate profiles (invited or attending).
  - One host RecruiterProfile.
- A **StudentProfile** (or JobSeekerProfile) can:
  - Have many Matches and Connections.
  - Be associated with many Events through invitations/RSVPs.
- Notifications are produced by domain events such as:
  - MatchCreated
  - EventCreated
  - “Candidate invited to Event”
  and consumed by the application/infrastructure layers.

4. Scenario as Domain Sequence
This section rewrites parts of the Student (S), Job Seeker (J), and Recruiter (R) flows in **domain terms**:

> Student discovers a recruiter → mutual Match → recruiter creates event → student is invited and attends.

    4.1 Create Profiles
    (From S1/S2, J1/J2, R1/R2)
        1. A candidate signs up and chooses role = Student or Job Seeker.
        2. The candidate creates or updates a StudentProfile or JobSeekerProfile:
            - Academic or professional background.
            - Skills and interests.
            - Job preferences and optional media.
        3. A recruiter signs up and creates a RecruiterProfile:
            - Company information.
            - One or more RoleCards with role details and candidate preferences.

    4.2 Discovery & Swiping
    (From S3/J3 and R3)
        4. The candidate enters Discovery & Swiping:
            - The system selects a set of RoleCards based on the candidate’s profile and preferences.
        5. For each role card:
            - SwipeRight(candidate, roleCard) records candidate interest.
            - SwipeLeft(candidate, roleCard) records a pass.
        6. The recruiter enters Talent Discovery:
            - The system selects a set of candidate profiles (Student/Job Seeker) based on role filters and preferences.
        7. For each candidate:
            - SwipeRight(recruiter, candidateProfile) records recruiter interest.
            - SwipeLeft(recruiter, candidateProfile) records a pass.

    4.3 Match & Connection
    (From S4/J4 and R4)
        8. The Domain layer evaluates swipes:
            - When both sides have swiped right on each other (candidate ↔ recruiter), it creates:
                - Match(candidateProfile, recruiterOrRoleCard)
                - Connection(candidateProfile, recruiterOrRoleCard)
        9. The Domain emits a MatchCreated event.
        10. The Application layer listens for this and triggers notifications:
                - Candidate and recruiter see “It’s a match!” and can open chat or scheduling from the Connection context.

    4.4 Event Creation and Targeting
    (From S7/J7 and R7)
        11. The recruiter creates an Event under the RecruiterProfile:
                - Event type (career fair, info session, networking).
                - Audience (students, job seekers, or both).
                - Date, time, location/URL, RSVP cap.
        12. The recruiter optionally filters candidates to invite:
                - By existing Matches/Connections.
                - By attributes such as major, experience level, or skills.

    4.5 Invite Matched Candidates
    (From R3, R4, R7, plus domain rules)
        13. The Application layer retrieves a list of Matches or Connections for the recruiter’s company or roles.
        14. For each candidate that satisfies the Event criteria, the application requests the domain to record an invitation:
                - Conceptually: inviteCandidateToEvent(event, candidateProfile, connection)
        15. The Domain enforces rules such as:
                - Only candidates with a valid Connection to the recruiter can be invited.
                - No duplicate invitations for the same candidate and event.
        16. A domain event is emitted to indicate that a candidate has been invited to an Event. The Application/Infrastructure layers then trigger notifications.

    4.6 RSVP and Participation
    (From S7/J7)
        17. Candidate receives a notification and views Event details in the app.
        18. Candidate responds by RSVPing:
                - acceptEvent(event, candidateProfile) → candidate is marked as attending.
                - declineEvent(event, candidateProfile) → candidate will not attend.
        19. The Event keeps track of who is attending:

    4.7 Post-Event and Follow-Up
    (From S7, S9, R8)
        20. After the Event, the recruiter can:
                - Move candidates through pipeline stages (screening, onsite, offer).
                - Export candidate information.
        21. Candidates can:
                 See their post-match status.
                - Continue messaging recruiters through the Connection.
        22. All of this continues to rely on the same core domain concepts:
                - StudentProfile / JobSeekerProfile, RecruiterProfile, RoleCard, Match, Connection, and Event.

5. References
- Schütz-Schmuck, Marko. **Putting the Domain Model to Work**  
- Schütz-Schmuck, Marko. **Isolating the Domain**  
- Schütz-Schmuck, Marko. **A Model Expressed in Software**  
- **Student Flows (S1–S9)**  
- **Job Seeker Flows (J1–J9)**  
- **Recruiter Flows (R1–R8)**
