# Weak Spots Identified and Refactored

## Overview
This document reviews two structural weaknesses found in the domain model and proposes a more refined design to address possible domain issues.  
The UML diagram shows the **improved relationships and reduced duplication**.

---

## Weak Spot A – Chat and Message Duplication
**Issue:**  
Two separate message models (`Message` in `conversation.dart` and another in `message.dart`) cause inconsistency and duplication in logic.  
**Refactor:**  
Unified the message handling logic into a single `Message` entity used consistently across `Conversation` and `ChatService`.  
This reduces redundancy and ensures all chat components share the same structure.

---

## Weak Spot B – Profile Duplication and Rigid Inheritance
**Issue:**  
`JobSeekerProfile` and `RecruiterProfile` duplicated several shared attributes (e.g., `bio`, `location`, `phoneNumber`, `createdAt`).  
**Refactor:**  
Introduced a shared `BaseProfile` or `UserProfile` abstraction containing the common fields.  
`JobSeekerProfile` and `RecruiterProfile` now extend or compose it, improving consistency and maintainability.

---


## Refactored Model


**Updated UML:**
https://lucid.app/lucidchart/e3d47e86-4096-43dd-b307-cce580cfa31a/edit?viewport_loc=1404%2C184%2C923%2C1096%2C0_0&invitationId=inv_d9f34411-ba0e-4cd5-9beb-97ae931def64

---


