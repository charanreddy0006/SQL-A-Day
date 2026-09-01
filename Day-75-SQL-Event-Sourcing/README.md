Day 75 — SQL Event Sourcing & Temporal Data

Project

SQL-A-Day — Day 75

Topic: SQL Event Sourcing and Temporal Data

Database: event_sourcing_lab

SQL Dialect: MySQL 8+

1. Overview

Day 75 introduces a different way of thinking about database state.

In a traditional database, we often store the latest state:

Account
----------------
balance = 16500

The database tells us the current value, but the current row does not necessarily tell us how that value was produced.

Event sourcing takes a different approach.

Instead of treating only the current state as important, the system stores a sequence of business events:

ACCOUNT_OPENED
      ↓
DEPOSITED ₹10,000
      ↓
DEPOSITED ₹5,000
      ↓
WITHDRAWN ₹2,000
      ↓
TRANSFER_OUT ₹3,000
      ↓
DEPOSITED ₹8,000
      ↓
WITHDRAWN ₹1,500

The current balance can then be reconstructed by replaying the events.

For Account 1:

0
+ 10,000
+  5,000
-  2,000
-  3,000
+  8,000
-  1,500
----------------
= 16,500

The central idea is:

Events → Replay → State

2. Why This Topic Is Interesting

Most SQL learning focuses on querying and modifying current relational state:

SELECT
JOIN
GROUP BY
CTE
Window Functions
Indexes
Transactions

Event sourcing introduces an architectural way of thinking about data:

What happened?

instead of only:

What is the current value?

This becomes valuable when a system needs:

Complete history
Auditability
State reconstruction
Historical state
Event replay
Debugging
Business-event tracking
Temporal analysis

3. Real-World Applications

Event sourcing can be useful in:

Banking
Payments
Orders
Inventory
Financial systems
Trading
Billing
Insurance
Workflow systems
Microservices
Distributed systems
Audit systems

It is especially useful when understanding why the current state exists is as important as knowing the current state.

4. Folder Structure

Day-75-SQL-Event-Sourcing/
├── day75.sql
└── README.md

5. Main Learning Objectives

By completing Day 75, you will understand:

1. Event sourcing
2. Event streams
3. Append-only event concepts
4. Event sequence numbers
5. State reconstruction
6. Event replay
7. Current state from events
8. Point-in-time state
9. Audit trails
10. Business events
11. Event metadata
12. JSON event metadata
13. Idempotency keys
14. Event references
15. Event validation
16. Sequence validation
17. Transfer event pairing
18. Historical queries
19. Temporal analysis
20. Event-driven database design

6. Traditional State-Based Model

A normal banking design might contain:

account_id
customer_name
balance
status

Example:

account_id = 1
balance = 16500
status = ACTIVE

The database knows the current state.

But suppose someone asks:

Why is the balance ₹16,500?

The current balance alone cannot answer that question.

7. Event-Sourced Model

With event sourcing, the database stores business events:

ACCOUNT_OPENED
DEPOSITED +10000
DEPOSITED +5000
WITHDRAWN -2000
TRANSFER_OUT -3000
DEPOSITED +8000
WITHDRAWN -1500

The balance can be derived from:

SUM(balance_delta)

This means:

Event History
     ↓
Replay
     ↓
Current State

8. What Is an Event?

An event represents something that happened in the business domain.

Examples:

ACCOUNT_OPENED
DEPOSITED
WITHDRAWN
TRANSFER_IN
TRANSFER_OUT
ACCOUNT_FROZEN
ACCOUNT_UNFROZEN
ACCOUNT_CLOSED

An event should describe a fact.

For example:

DEPOSITED ₹10,000

means that a deposit happened.

9. Event Stream

An event stream is the ordered sequence of events associated with one entity.

For Account 1:

Sequence 1 → ACCOUNT_OPENED
Sequence 2 → DEPOSITED
Sequence 3 → DEPOSITED
Sequence 4 → WITHDRAWN
Sequence 5 → TRANSFER_OUT
Sequence 6 → DEPOSITED
Sequence 7 → WITHDRAWN

The ordering matters because event replay depends on it.

10. Sequence Number

The event table contains:

sequence_no

Example:

account_id | sequence_no | event
-----------+-------------+----------------
1          | 1           | ACCOUNT_OPENED
1          | 2           | DEPOSITED
1          | 3           | DEPOSITED
1          | 4           | WITHDRAWN

The project creates:

UNIQUE(account_id, sequence_no)

This prevents duplicate sequence numbers inside one account stream.

11. Append-Only Concept

A key event-sourcing principle is that historical events are generally treated as append-only facts.

Conceptually:

Event 1
Event 2
Event 3
Event 4

A new event is added:

Event 5

rather than silently rewriting an old event.

This preserves the historical sequence.

The SQL project models this concept using the account_events table.

12. Accounts Table

The accounts table contains identity and account metadata:

account_id
account_number
customer_name
account_type
currency
status
created_at

The detailed transaction history is stored in:

account_events

13. Event Types Table

The event_types table defines the supported business event vocabulary.

Examples:

ACCOUNT_OPENED
DEPOSITED
WITHDRAWN
TRANSFER_IN
TRANSFER_OUT

This makes the event model explicit.

14. Account Events Table

The main event table contains:

event_id
account_id
sequence_no
event_type_code
balance_delta
event_amount
reference_id
idempotency_key
event_time
metadata

Each field supports a different part of the event model.

15. event_id

event_id uniquely identifies an event row.

Example:

event_id = 101

It is the database identity of the event.

16. account_id

This identifies which account owns the event.

Example:

account_id = 1

means the event belongs to Account 1.

17. sequence_no

This represents the event's position in the account's event stream.

Example:

1
2
3
4
5

The sequence provides deterministic replay order.

18. event_type_code

This identifies the business event.

Examples:

DEPOSITED
WITHDRAWN
TRANSFER_IN
TRANSFER_OUT

19. balance_delta

This represents the event's effect on the account balance.

Positive:

+10000

means money is added.

Negative:

-2000

means money is removed.

Zero:

0

can represent an event that does not directly change the balance.

20. event_amount

This stores the magnitude of the business event.

For a withdrawal:

event_amount = 2000
balance_delta = -2000

This separates:

Business amount

from:

Effect on state

21. reference_id

A reference ID can connect related events.

For a transfer:

TRANSFER_OUT → TX-1001
TRANSFER_IN  → TX-1001

The shared reference lets us identify both sides of the same business operation.

22. Idempotency Key

The project stores:

idempotency_key

An idempotency key can identify a unique business request.

For example:

ACC1-EVT-002

A unique constraint prevents another event from using the same key.

This is an important concept for retry-safe payment operations.

23. Event Time

Each event contains:

event_time

This allows historical queries.

For example:

What was the balance on January 12?

can be answered by considering events up to that point in time.

24. JSON Metadata

The project also stores:

metadata JSON

Example:

{
  "source": "ATM",
  "location": "Hyderabad"
}

This provides flexible contextual information for events.

Possible metadata includes:

Source
Channel
Device
Location
Application
Additional business context

25. Reconstructing Current State

The current balance can be reconstructed with:

SELECT
    account_id,
    SUM(balance_delta)
FROM account_events
GROUP BY account_id;

Conceptually:

All Events
    ↓
Balance Deltas
    ↓
SUM
    ↓
Current Balance

26. Event Replay

Event replay means processing historical events to reconstruct state.

Conceptually:

Initial State
     ↓
Event 1
     ↓
State 1
     ↓
Event 2
     ↓
State 2
     ↓
Event 3
     ↓
State 3

Eventually:

Final Event
     ↓
Current State

The SQL project demonstrates this using cumulative window functions.

27. Running Balance

The project calculates the balance after every event using:

SUM(balance_delta) OVER (
    PARTITION BY account_id
    ORDER BY sequence_no
)

Example:

Event             Delta       Balance
--------------------------------------
OPENED              0             0
DEPOSITED       +10000         10000
DEPOSITED        +5000         15000
WITHDRAWN        -2000         13000
TRANSFER_OUT      -3000         10000
DEPOSITED        +8000         18000
WITHDRAWN        -1500         16500

This makes state reconstruction visible step by step.

28. Point-in-Time State

One of the most useful concepts is reconstructing historical state.

For example:

What was Account 1's balance
at 2026-01-12 16:00?

The query considers events where:

event_time <= '2026-01-12 16:00:00'

and then calculates:

SUM(balance_delta)

This produces the balance at that cutoff.

29. Historical Queries

Event history allows questions such as:

What was the balance yesterday?

What was the balance before a withdrawal?

What was the balance after event 5?

What events happened before a specific timestamp?

When did the balance cross ₹20,000?

30. First Event

The first event in an account stream is identified with:

sequence_no = 1

For these sample accounts it represents:

ACCOUNT_OPENED

This marks the beginning of the event stream.

31. Latest Event

The latest event can be found with:

MAX(sequence_no)

for each account.

This gives:

Latest event
Latest sequence
Latest event time

32. Event Count

The number of events can be calculated with:

COUNT(event_id)

This gives a basic activity measure for each account.

33. Financial Summary

The project calculates:

Total inflow
Total outflow
Net change

Conceptually:

Total Inflow
     ↓
Total Outflow
     ↓
Net Change

The net change corresponds to the reconstructed balance when the initial balance is zero.

34. Previous Event with LAG()

The project uses:

LAG()

to inspect the previous event.

This can answer:

What happened immediately before this event?

Example:

Current Event      Previous Event
----------------------------------
WITHDRAWN          DEPOSITED
TRANSFER_OUT       WITHDRAWN
DEPOSITED          TRANSFER_OUT

35. Time Between Events

The project combines:

LAG(event_time)

with:

TIMESTAMPDIFF()

to calculate the time gap between events.

This can help identify:

Long inactive periods
High-frequency activity
Transaction bursts
Behavior patterns

36. Detecting Balance Thresholds

The project finds the first time an account's reconstructed balance exceeds:

₹20,000

The pattern is:

Events
   ↓
Running Balance
   ↓
Filter Balance > Threshold
   ↓
Find First Sequence

The same idea can be applied to:

Credit limits
Inventory levels
Loyalty points
Spending limits
Account limits

37. Transfer Modeling

A transfer creates two related events.

Sender:

TRANSFER_OUT
-3000

Receiver:

TRANSFER_IN
+3000

Both can share:

reference_id = TX-1001

This allows the database to connect the two sides.

38. Transfer Pair Query

The project joins transfer events using:

e1.reference_id = e2.reference_id

The resulting report can show:

Transfer Reference
Sender
Receiver
Amount
Time

This is a useful pattern for financial event analysis.

39. JSON Metadata Queries

The project uses:

JSON_EXTRACT()

to read event metadata.

For example:

source = ATM

can be extracted from the JSON document.

This demonstrates combining:

Relational columns
+
Semi-structured JSON

inside SQL.

40. Idempotency

Imagine a client sends:

Deposit ₹5,000

The network fails.

The client retries the same request.

Without protection, the deposit might be recorded twice.

An idempotency key can identify the original request:

REQUEST-12345

The database can reject another event with the same key.

This is particularly important for:

Payments
Banking
Orders
Financial APIs

41. Sequence Validation

The project checks for gaps in event sequences.

Correct:

1
2
3
4
5

Potential problem:

1
2
4
5

Sequence 3 is missing.

The validation query uses LAG() to detect such gaps.

42. Audit Trail

An event stream naturally provides a historical audit trail.

Instead of only:

balance = 16500

we can see:

Deposit 10000
Deposit 5000
Withdrawal 2000
Transfer 3000
Deposit 8000
Withdrawal 1500

This makes the sequence of changes visible.

43. Why Auditability Matters

Historical event data can be useful for:

Financial investigations
Debugging
Customer support
Compliance
Fraud analysis
Dispute resolution
System debugging

44. Event Sourcing vs CRUD

Traditional CRUD:

UPDATE accounts
SET balance = balance + 5000;

The current state changes.

Event sourcing:

Create DEPOSITED event
        ↓
Append event
        ↓
Replay / update projection

The business action is preserved as an event.

45. Fundamental Difference

Traditional approach:

State is primary
History may be secondary

Event-sourced approach:

Business events are the historical facts
State can be derived from those events

This is the main conceptual difference.

46. Benefits

Potential benefits include:

Complete history
Auditability
Historical reconstruction
Debugging
Event replay
Temporal analysis
Business-event visibility

47. Trade-Offs

Event sourcing is not automatically the best design for every application.

Potential challenges include:

More complex reads
Event schema evolution
Large event streams
Replay cost
Data migration
Concurrency
Consistency design
Operational complexity

It should be used when the requirements justify the additional complexity.

48. Large Event Streams

Suppose an account has:

10 events

Replay is easy.

Now suppose it has:

10 million events

Replaying every event for every read may become expensive.

Production systems may introduce:

Snapshots
Materialized projections
Cached current state
Projection tables

49. Snapshots

A snapshot stores a previously reconstructed state.

Conceptually:

Events 1 → 1,000,000
        ↓
Snapshot at event 1,000,000
        ↓
New events
        ↓
Replay only new events

This reduces replay work.

The Day 75 project focuses on the underlying event-replay concept and does not implement a complete snapshot subsystem.

50. Event Schema Evolution

Real systems change over time.

An event might initially contain:

amount

Later it may require:

amount
currency
channel
merchant
location

Event schemas therefore need an evolution strategy.

The project demonstrates flexible metadata using JSON, but does not implement a complete event-versioning framework.

51. CQRS Connection

Event sourcing is often discussed together with:

CQRS

CQRS means:

Command Query Responsibility Segregation

A simplified architecture is:

Commands
   ↓
Business Logic
   ↓
Events
   ↓
Event Store
   ↓
Projections
   ↓
Query Models

Day 75 focuses primarily on the event-store and state-reconstruction concepts.

52. Event Store

The:

account_events

table acts as a simplified relational event store.

It contains:

Event identity
Aggregate identity
Sequence
Event type
Event data
Event time
Reference
Metadata

A production event store may use a different architecture depending on system requirements.

53. Aggregate Concept

In Domain-Driven Design, an aggregate is a consistency boundary around related business state.

For this project:

Account

can be treated as the entity whose event stream is being reconstructed.

The stream is identified by:

account_id

54. Account 1 Event Replay

Account 1 contains:

ACCOUNT_OPENED
       ↓
DEPOSITED +10000
       ↓
DEPOSITED +5000
       ↓
WITHDRAWN -2000
       ↓
TRANSFER_OUT -3000
       ↓
DEPOSITED +8000
       ↓
WITHDRAWN -1500

Replay:

0
+10000 = 10000
+5000  = 15000
-2000  = 13000
-3000  = 10000
+8000  = 18000
-1500  = 16500

Final reconstructed state:

₹16,500

55. Current State Query

The current state can be reconstructed using:

SUM(balance_delta)

over all events belonging to the account.

For a high-volume production system, a materialized projection may be used when repeatedly replaying large streams is too expensive.

56. Historical State Query

Historical state uses the same principle but limits the event stream.

Conceptually:

All Events
    ↓
Events up to Time T
    ↓
Replay
    ↓
State at Time T

This is the foundation of temporal state reconstruction.

57. Event Time vs Processing Time

Large event-driven systems may distinguish:

Event Time

from:

Processing Time

Event time describes when the business event occurred.

Processing time describes when the system processed the event.

These timestamps can differ in distributed systems.

The project primarily models business event time using:

event_time

58. Event Ordering

Event ordering is critical for deterministic replay.

The project uses:

sequence_no

to establish order within an account stream.

For example:

Event 1
Event 2
Event 3

should not be arbitrarily replayed as:

Event 3
Event 1
Event 2

when ordering affects state.

59. Event Immutability

A historical event should represent something that happened.

For example:

DEPOSITED ₹10,000

should not silently become:

DEPOSITED ₹20,000

after the fact.

If a correction is needed, an event-driven design can record an appropriate corrective or compensating event according to business rules.

60. Corrective Events

Suppose an incorrect event was recorded.

Instead of silently rewriting history:

Original Event
      ↓
Correction Event

can preserve what actually happened and how it was corrected.

The exact correction strategy depends on the business domain.

61. Event Sourcing in Banking

A banking account can be modeled as:

ACCOUNT_OPENED
DEPOSITED
WITHDRAWN
TRANSFER_OUT
TRANSFER_IN

Current balance:

SUM(balance_delta)

Historical balance:

SUM(events up to time T)

This is a natural example of event sourcing.

62. Event Sourcing in Orders

An order lifecycle might be:

ORDER_CREATED
      ↓
PAYMENT_RECEIVED
      ↓
ORDER_CONFIRMED
      ↓
ORDER_SHIPPED
      ↓
ORDER_DELIVERED

The current state is:

ORDER_DELIVERED

but the complete lifecycle remains available.

63. Event Sourcing in Inventory

Inventory events could be:

STOCK_RECEIVED +100
SALE -10
SALE -5
RETURN +2
STOCK_ADJUSTMENT -3

Current inventory can be reconstructed from the event stream.

64. Event Sourcing in Payments

Payment events might include:

PAYMENT_CREATED
PAYMENT_AUTHORIZED
PAYMENT_CAPTURED
PAYMENT_FAILED
PAYMENT_REFUNDED

This provides a complete payment lifecycle.

65. Event Sourcing in Microservices

Business events can be consumed by multiple services.

Conceptually:

Order Service
     ↓
ORDER_CREATED
     ↓
Event Stream
     ↓
Payment Service
Inventory Service
Notification Service
Analytics Service

This connects event sourcing with event-driven architecture.

66. Data Engineering Connection

Event-sourced data is highly relevant to data engineering.

A pipeline can consume:

Account Events
Order Events
Payment Events
Inventory Events

and produce:

Data Warehouse
Analytics Tables
Dashboards
Fraud Models
Customer Metrics
Operational Reports

The event stream preserves detailed historical information.

67. Streaming Connection

A larger architecture might look like:

Application
    ↓
Event Store
    ↓
Message Broker
    ↓
Stream Processing
    ↓
Data Warehouse
    ↓
Analytics

This connects SQL event modeling with technologies such as:

Kafka
Flink
Spark
Streaming pipelines
Data warehouses

68. Backend Development Connection

A backend could expose commands such as:

POST /deposit
POST /withdraw
POST /transfer

A simplified flow is:

API Request
    ↓
Validation
    ↓
Business Logic
    ↓
Create Event
    ↓
Append Event
    ↓
Update / Rebuild Projection

69. Production Considerations

A production event-sourcing implementation should consider:

Event immutability
Event ordering
Idempotency
Concurrency
Schema evolution
Event versioning
Stream partitioning
Snapshots
Projection rebuilding
Data retention
Audit requirements
Failure recovery
Observability

The Day 75 project demonstrates the database concepts behind these concerns.

70. Performance Considerations

As event streams become large, repeatedly calculating:

SUM(balance_delta)

over millions of rows can become expensive.

Possible techniques include:

Indexes
Snapshots
Materialized projections
Cached current state
Partitioning
Stream processing

The correct solution depends on the workload and consistency requirements.

71. Event Store Indexes

The project indexes common access paths:

(account_id, event_time)
(account_id, event_type_code)
reference_id

The unique constraint:

(account_id, sequence_no)

supports stream ordering and integrity.

72. Practical Exercise 1

Calculate the reconstructed current balance for every account.

Use:

SUM(balance_delta)

grouped by:

account_id

73. Practical Exercise 2

Replay Account 1 manually.

Create a table on paper:

Sequence
Event
Delta
Balance

Verify your result against the SQL query.

74. Practical Exercise 3

Find Account 1's balance:

Before 2026-01-12

and compare it with:

After 2026-01-12

75. Practical Exercise 4

Find the first event where an account's balance exceeds:

₹20,000

Then change the threshold and run the query again.

76. Practical Exercise 5

Find every transfer and display:

Transfer Reference
Sender
Receiver
Amount
Time

77. Practical Exercise 6

Find all events generated from:

ATM

using JSON metadata.

78. Practical Exercise 7

Test sequence validation.

Insert a controlled test event with a sequence gap and run the sequence-validation query.

Example:

1
2
4
5

The query should identify the missing sequence.

79. Practical Exercise 8

Add a new event type:

FEE_CHARGED

with:

balance_delta = -250
event_amount = 250

Then replay the account and observe the new balance.

80. Practical Exercise 9

Create a historical balance report:

Account
Date
Balance

for multiple cutoff dates.

This is a useful temporal analytics exercise.

81. Practical Exercise 10

Design an order event stream:

ORDER_CREATED
PAYMENT_RECEIVED
PACKED
SHIPPED
DELIVERED

Then build SQL that reconstructs the current order state from those events.

82. Common Mistakes

Mistake 1 — Treating events like ordinary mutable rows

Historical events should generally be treated as facts.

Mistake 2 — Ignoring event order

Replay requires deterministic ordering.

Use:

sequence_no

or another reliable ordering mechanism.

Mistake 3 — Storing only current state

The purpose of event sourcing is to preserve historical events.

Mistake 4 — Allowing duplicate business events

Idempotency mechanisms are important for retry-safe operations.

Mistake 5 — Ignoring event-stream growth

Very large streams may require snapshots or projections.

Mistake 6 — Assuming event sourcing is always better

It is an architectural choice with trade-offs.

83. Interview Questions

What is event sourcing?

An architectural pattern where business changes are stored as events and application state can be reconstructed by replaying those events.

What is an event?

A record representing something that happened in the business domain.

What is an event stream?

An ordered sequence of events associated with an entity or aggregate.

Why is event order important?

Because replaying events in the wrong order can produce an incorrect state.

What is event replay?

Processing historical events to reconstruct state.

What is a point-in-time query?

A query that reconstructs state as it existed at a particular point in time.

Why use an idempotency key?

To identify repeated attempts of the same business request and prevent duplicate processing.

What is a snapshot?

A stored state checkpoint that reduces how much historical event data must be replayed.

What is CQRS?

Command Query Responsibility Segregation, an architecture that separates command/write responsibilities from query/read responsibilities.

Is event sourcing the same as an audit table?

No. An audit table records changes for auditing, while event sourcing uses business events as the basis for reconstructing application state.

84. Event Sourcing vs Audit Logging

Audit logging:

Record what changed

Event sourcing:

Record business events
        ↓
Use events to reconstruct state

They can look similar in a database but have different architectural purposes.

85. Event Sourcing vs Temporal Tables

Temporal tables generally preserve versions of database state.

Event sourcing preserves:

Business events

from which state can be reconstructed.

They solve related but different problems.

86. Why This Is a Strong SQL Project

Day 75 combines several SQL capabilities:

Relational modeling
Constraints
Foreign keys
JSON
Window functions
Aggregation
CTEs
Temporal filtering
LAG()
TIMESTAMPDIFF()
Indexes
Audit queries
Data validation

But the central topic is:

Modeling application history as events.

87. Day 75 Key Takeaways

1. Event sourcing stores business events.
2. Events represent facts that happened.
3. Events can form an ordered event stream.
4. Sequence numbers help preserve stream order.
5. Current state can be reconstructed from events.
6. Event replay rebuilds state.
7. Historical state can be reconstructed at a timestamp.
8. Event streams provide detailed audit history.
9. Balance changes can be represented using deltas.
10. Transfers can use shared reference IDs.
11. Idempotency keys help prevent duplicate processing.
12. JSON can store flexible event metadata.
13. Sequence validation can detect missing events.
14. Window functions can show state after each event.
15. Event streams support temporal analysis.
16. Large streams may require snapshots or projections.
17. Event sourcing has architectural trade-offs.
18. Event sourcing differs from ordinary CRUD.
19. Event sourcing differs from simple audit logging.
20. Event sourcing connects SQL with event-driven architecture.

88. Completion Checklist

[ ] Created event-sourcing database
[ ] Created accounts table
[ ] Created event_types table
[ ] Created account_events table
[ ] Added event types
[ ] Added account event streams
[ ] Added sequence numbers
[ ] Added balance deltas
[ ] Added event amounts
[ ] Added reference IDs
[ ] Added idempotency keys
[ ] Added event timestamps
[ ] Added JSON metadata
[ ] Created event stream view
[ ] Reconstructed current balances
[ ] Replayed an event stream
[ ] Calculated running balances
[ ] Performed point-in-time reconstruction
[ ] Found first events
[ ] Found latest events
[ ] Calculated event counts
[ ] Calculated inflows and outflows
[ ] Compared previous events
[ ] Calculated time gaps
[ ] Detected balance thresholds
[ ] Paired transfer events
[ ] Extracted JSON metadata
[ ] Checked idempotency keys
[ ] Validated sequence numbers
[ ] Built audit reports
[ ] Reviewed event-sourcing architecture

89. Final Architecture

                     BUSINESS APPLICATION
                              |
                              ↓
                       Business Command
                              |
                              ↓
                       Business Logic
                              |
                              ↓
                         EVENT CREATED
                              |
                              ↓
                    ┌──────────────────┐
                    │    EVENT STORE   │
                    │                  │
                    │ ACCOUNT_OPENED   │
                    │ DEPOSITED        │
                    │ WITHDRAWN        │
                    │ TRANSFER_OUT     │
                    │ TRANSFER_IN      │
                    └────────┬─────────┘
                             |
                 ┌───────────┴───────────┐
                 ↓                       ↓
            Event Replay            Event Consumers
                 ↓                       ↓
           Current State           Analytics / Audit
                 ↓
            Query Model
                 ↓
             Application

90. Final Lesson

The most important idea of Day 75 is:

Do not only store what the system IS.

Store what HAPPENED.

Instead of only storing:

balance = 16500

we preserve:

DEPOSITED +10000
DEPOSITED +5000
WITHDRAWN -2000
TRANSFER_OUT -3000
DEPOSITED +8000
WITHDRAWN -1500

Then:

Events
   ↓
Replay
   ↓
State

This gives the system a detailed history that can support:

Auditability
Temporal analysis
Historical reconstruction
Debugging
Business-event tracking

91. Day 75 Summary

                 EVENT SOURCING

                      Event
                        ↓
                  Event Stream
                        ↓
                 Ordered Events
                        ↓
                     Replay
                        ↓
                State Reconstruction
                        ↓
             ┌──────────┴──────────┐
             ↓                     ↓
       Current State        Historical State
             ↓                     ↓
         Querying             Audit / Analysis

The core pattern is:

Event → Store → Replay → State

The temporal pattern is:

Events up to Time T
        ↓
      Replay
        ↓
State at Time T

92. Day 75 Completion

After completing this project, you should be able to look at a system and ask:

What events happen in this system?

What should be immutable?

How should events be ordered?

Can current state be reconstructed?

Can historical state be reconstructed?

How can duplicate events be prevented?

How can related events be connected?

How can the event history be audited?

What happens when the event stream becomes huge?

Would snapshots or projections be necessary?

That is the foundation of:

SQL Event Sourcing
Temporal State Reconstruction
Event-Driven Database Design

93. Final Day 75 Concept

Traditional SQL thinking:

Current State
     ↓
UPDATE ROW
     ↓
New Current State

Event-sourcing thinking:

Business Action
      ↓
    Event
      ↓
 Append Event
      ↓
 Event Stream
      ↓
    Replay
      ↓
Derived State

Day 75 = SQL + Event History + State Reconstruction + Temporal Thinking.