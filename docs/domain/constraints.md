= Explicit Domain Constraints in the Matching Subsystem
:revnumber: 1.0
:revdate: 2025-11-20
:toc: left
:sectnums:

== Summary
This document formalizes the core domain constraints governing the Matching subsystem.  
These rules were previously implicit or scattered in code; they are now centralized for consistency, correctness, and future scalability.

The two primary constraints addressed:

1. **Minimum Candidate GPA Requirement**
2. **Maximum Active Chats Limit**

Both constraints are now explicitly part of the domain model and validated consistently across Matching operations.

== Goals
- Remove hidden or duplicated business rules.
- Ensure MatchingService behaves predictably and consistently.
- Create a structured model (`MatchingConstraints`) that owns all constraint definitions.
- Provide clear validation entry points.
- Prepare the subsystem for future scaling and new constraints.

== Non-Goals
- UI-level enforcement (this must be domain-driven, not frontend-driven).
- Runtime configuration for constraints (possible future enhancement).
- Legal or policy enforcement outside the matching domain.

== Domain Constraints

=== Constraint 1: Minimum GPA Requirement
*Rule:*  
A candidate must have a **GPA ≥ 2.5** to participate in matching activities.

*Why:*  
- Maintains recruiter expectations and filters out academically ineligible candidates.  
- Prevents unnecessary match computations.  
- Keeps domain logic consistent across all matching flows.

*Applies to:*  
- Match generation  
- Compatibility scoring  
- Recruiter profile delivery  
- New chat creation triggered by a match  

=== Constraint 2: Maximum Active Chats Limit
*Rule:*  
A candidate may have **at most 3 active recruiter chats** simultaneously.

*Why:*  
- Prevents candidate overload.  
- Protects recruiter resources and avoids spam-like behavior.  
- Maintains fairness by narrowing focus to meaningful conversations.

*Applies to:*  
- Opening a new chat  
- Accepting a new match  
- Re-activating archived chats  

== Centralized Constraint Model

=== MatchingConstraints Object
All constraints must be referenced through a single domain object.

[source,python]
----
class MatchingConstraints:
    MIN_GPA = 2.5
    MAX_ACTIVE_CHATS = 3
----

No hardcoded numbers (“magic numbers”) may appear in MatchingService.

=== Validation Functions

[source,python]
----
def validateCandidateEligibility(candidate):
    if candidate.gpa < MatchingConstraints.MIN_GPA:
        raise DomainError("Candidate GPA below minimum threshold (2.5).")


def validateCanOpenChat(activeChats):
    if activeChats >= MatchingConstraints.MAX_ACTIVE_CHATS:
        raise DomainError("Cannot open more than 3 active chats.")
----
These validations must run *before* any matching logic.

== Enforcement Points

=== GPA Enforcement Locations
- Before computing candidate rankings  
- Before selecting compatible profiles  
- Before delivering candidates to recruiters  
- Before automatically opening chats  

=== Active Chat Limit Enforcement
- Before new 1:1 chat creation  
- During match acceptance  
- Before resurrecting or reactivating archived chats  

== ASCII Diagrams

=== GPA Validation Flow
Candidate ---> validateCandidateEligibility()
| |
| valid? |
+------ YES -----+----> Proceed with matching
|
NO
|
Reject


=== Active Chat Limit Flow


Request New Chat ---> countActiveChats()
|
validateCanOpenChat()
|
+------+------+
| |
OK (0–2) BLOCK (3)
| |
Create Chat Return Error


== Documentation: constraints.md

The documentation file must include:
- All constraints
- Rationale
- Enforcement locations
- Error messages or domain exceptions
- Guidance for extending rules

== Extensibility
Future constraints may include:
- Per-week match limits  
- Recruiter priority match weighting  
- Industry-specific GPA thresholds  
- Daily chat rate limits  
- Cooldown windows for new matches  

To add a new rule:
1. Add it to `MatchingConstraints`.
2. Write a dedicated validator.
3. Add enforcement to MatchingService.
4. Include it in constraints.adoc.
5. Add full test coverage.

== Testing Strategy

=== GPA Tests
- GPA = **2.4** → must fail  
- GPA = **2.5** → must pass  
- GPA = **3.7** → must pass  

=== Active Chat Limit Tests
- Chats: 0 → allowed  
- Chats: 1 → allowed  
- Chats: 2 → allowed  
- Chats: 3 → reject  

=== Validation Order Tests
- Validators must run **before** match creation or chat creation.  
- No magic numbers allowed outside the constraint object.  
- Domain errors must be descriptive.

== Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Magic numbers leaking into code | inconsistent behavior | enforce constraint model usage |
| Developer bypasses validation | breaks domain invariants | service-level guards |
| Constraint changes in the future | breaks older matches | version constraints with soft warnings |
| Over-enforcement | harms UX | allow UI to signal state clearly |

== Conclusion
Centralizing and documenting Matching constraints increases system reliability, reinforces domain invariants, and improves maintainability.  
This file serves as the canonical source of truth for business rules governing eligibility and chat concurrency.

