# Ubiquitous Language Glossary

This glossary defines the core terms used consistently throughout the Professional Portfolio project. Its purpose is to ensure shared understanding across documentation, design, and implementation. Terms are domain-specific and must not be used interchangeably.

---

### Student
An individual seeking opportunities by creating and maintaining a **StudentProfile**. A Student provides personal, academic, and professional information, including skills, resume, and portfolio.

### Recruiter
A hiring professional representing a company or organization. A Recruiter interacts with Students through the app by creating a **RecruiterProfile**, posting opportunities, and reviewing matches.

### User
A generic term for any participant interacting with the application. In this system, a User is either a **Student** or a **Recruiter**. This abstraction is used for system operations (authentication, sessions) but should not replace specific roles in domain logic.

### StudentProfile
A persistent digital entity associated with a single **Student**. It includes identity (UUID), resume, skills, preferences, and portfolio. It serves as the Student’s primary representation within the system.

### RecruiterProfile
A persistent digital entity associated with a single **Recruiter**. It contains company information, job postings, filters, and professional details. It represents the Recruiter in all interactions.

### Swipe
A binary action performed by a **User** on a **ProfileCard**.  
- Right swipe → expression of interest.  
- Left swipe → dismissal.  
Swipes are logged events that may lead to a **Match**.

### Match
A domain event that occurs only when a **Student** and a **Recruiter** have both expressed interest (via right swipe). A Match is mutual and enables further interaction.

### Connection
The persistent relationship state created after a **Match**. A Connection allows messaging and ongoing engagement between a Student and a Recruiter.

### Portfolio
A collection of projects, media, and achievements uploaded by a **Student**. The Portfolio demonstrates skills and capabilities, and is embedded within the **StudentProfile**.

### Event
A scheduled activity, such as a job fair, networking session, or company presentation. Events are external occasions represented in the system so that Students and Recruiters can coordinate participation.

### ProfileCard
A condensed, swipeable view of either a **StudentProfile** or **RecruiterProfile**. ProfileCards appear in the **Discovery Feed**.

### Discovery Feed
The main interface where **Users** browse ProfileCards and perform swipe actions. It represents the entry point to the matching process.

### Notification
A system-generated message delivered to a **User**. Notifications communicate important events such as Matches, new Messages, or Event reminders.

### Message
A communication object exchanged between a **Student** and a **Recruiter** once a **Connection** exists. Messages enable coordination and follow-up.

### Queue
The ordered waiting mechanism in front of a Recruiter booth or Event slot. Used conceptually in both physical (career fair) and digital contexts.

### Identity
The unique, immutable identifier (UUID) assigned to entities like **StudentProfile** or **RecruiterProfile**. Identity persists across updates and guarantees uniqueness.

### Session
The authenticated state of a **User** after logging into the system. A Session grants temporary access rights and links actions (swipes, messages) to the correct identity.

---

This glossary is a **living document**. New terms may be added as the domain evolves, but definitions must remain consistent across documentation and implementation.
