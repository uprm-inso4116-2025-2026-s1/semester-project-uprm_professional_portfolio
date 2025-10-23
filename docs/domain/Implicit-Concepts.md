# Implicit Domain Concepts

## Interviews Summary
**Student interview highlights:**
- Mentioned "profile visibility" (how often their profile appears to recruiters).
- Talked about "career alignment" (matching jobs to long-term goals).

**Recruiter interview highlights:**
- Used the phrase "soft skill fit" and "candidate engagement rate."

---

## New Domain Concepts
1. **Profile Visibility**
   - Definition: How often a student’s profile appears in recruiter searches.
   - Related to: `StudentProfile` entity.
   - Added in UML diagram (see updated domain model).

2. **Career Alignment**
   - Definition: The match degree between a student’s career goals and recruiter job opportunities.

---

## Glossary Updates
| Term | Definition |
|------|-------------|
| **Profile Visibility** | How often a student’s profile appears in recruiter searches or match results. |
| **Career Alignment** | The match degree between a student’s career goals and recruiter job opportunities. |

---

## Updated UML
```plantuml
@startuml
title Implicit Domain Concepts - UML Extension

' Existing related entities
class StudentProfile {
  +profileId: String
  +name: String
  +skills: List<String>
}

class JobOpportunity {
  +jobId: String
  +title: String
  +requiredSkills: List<String>
}

' New implicit concepts
class ProfileVisibility {
  +visibilityScore: double
  +updateVisibility()
}

class CareerAlignment {
  +alignmentScore: double
  +calculateAlignment()
}

' Relationships
StudentProfile "1" -- "1" ProfileVisibility : tracks >
CareerAlignment "1" -- "1" StudentProfile : evaluates goals of >
CareerAlignment "1" -- "1" JobOpportunity : compares with >

@enduml