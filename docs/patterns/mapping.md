# Pattern–Model Relationships

## Overview
This document links key design patterns in the system to the domain concepts they support. It ensures that the architecture aligns with the business logic and can evolve without breaking domain consistency.

---

## Pattern–Concept Relationships

| Design Pattern | Supported Domain Concept(s) | Description / Example |
|----------------|-----------------------------|------------------------|
| **Strategy** | `MatchingPolicy`, `Match` | Enables different matching strategies (e.g., skill-priority, GPA-priority) to be swapped without altering core logic. |
| **Composite** | `Event`, `SubEvent` | Models complex events (e.g., job fairs with workshops) as hierarchical structures that behave as one. |
| **Specification** | `EligibleCandidate`, `RecruiterSelection` | Encapsulates business rules for filtering candidates or matches based on recruiter criteria. |

---

## Notes
- Each pattern reflects a real-world domain behavior.  
- Patterns can evolve independently while preserving the meaning of domain concepts.  
- Example: `MatchingPolicy` (Strategy) allows adding new match criteria without modifying the `Match` entity.

---

## UML (Simplified)
```mermaid
classDiagram
    class MatchingPolicy {
        +applyCriteria()
    }

    class SkillPriorityPolicy
    class GPAPriorityPolicy
    MatchingPolicy <|-- SkillPriorityPolicy
    MatchingPolicy <|-- GPAPriorityPolicy

    class Event {
        +name
        +subEvents
    }
    class SubEvent
    Event o-- SubEvent

    class EligibleCandidateSpecification
    class RecruiterSelectionSpecification
    EligibleCandidateSpecification <|-- RecruiterSelectionSpecification
