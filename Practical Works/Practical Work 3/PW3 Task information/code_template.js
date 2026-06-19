/* ================================================================================
   STUDENT HEADER
   Course: Data models in database systems
   Practical Work 3: Document databases and hierarchical data model
   
   Student Name, Surname:  [ENTER NAME HERE]
   Student ID:   	         [ENTER ID HERE]
   Variation #:            [ENTER VARIATION NUMBER HERE]
================================================================================ */

// --- SECTION 2: DATABASE SETUP ---
// Change this to the apropriate database name
use('aviationDB');
print(">>> Database selected.");


/* ================================================================================
   SECTION 3: TASK 3 - DATA TYPE CORRECTION
   Instructions: Write the scripts to fix the data types for your 3 collections.
================================================================================ */

print("\n>>> Running Task 3: Type Correction...");

// 3.1 Fix Collection 1
// TODO: Write your updateMany script here


// 3.2 Fix Collection 2
// TODO: Write your updateMany script here


// 3.3 Fix Collection 3
// TODO: Write your updateMany script here

print("Task 3 Complete: Data types updated.");


/* ================================================================================
   SECTION 4: TASK 4 - DENORMALIZATION
   Instructions: Create a new denomalizated collection using $lookup.
================================================================================ */

print("\n>>> Running Task 4: Creating flights_enhanced...");

// TODO: Write your aggregate pipeline here ending with $out or $merge
// db.flight_logs.aggregate([ ... ]);

print("Task 4 Complete: Collection created.");


/* ================================================================================
   SECTION 5: TASK 5 - ANALYTICAL QUERIES (INSTRUCTOR VERIFICATION)
   Instructions: 
   For each task below, you MUST use 'printjson()' to display your result.
   If you do not use printjson, the instructor cannot grade your work.
================================================================================ */

print("\n>>> Running Task 5 Queries...");

// --- Query 5.1 ---
// Title: [Insert Title Here]
print("\n[Output 5.1] ------------------------------------------------");
// TODO: Uncomment and fill in your query
// var result_5_1 = db.flights_enhanced.aggregate([ 
//      ... your stages here ...
// ]).toArray();
// printjson(result_5_1);


// --- Query 5.2 ---
// Title: [Insert Title Here]
print("\n[Output 5.2] ------------------------------------------------");
// TODO: Uncomment and fill in your query
// var result_5_2 = db.flights_enhanced.aggregate([ 
//      ... your stages here ...
// ]).toArray();
// printjson(result_5_2);


// --- Query 5.3 ---
// Title: [Insert Title Here]
print("\n[Output 5.3] ------------------------------------------------");
// TODO: Uncomment and fill in your query
// var result_5_3 = db.flights_enhanced.aggregate([ 
//      ... your stages here ...
// ]).toArray();
// printjson(result_5_3);


// --- Query 5.4 ---
// Title: [Insert Title Here]
print("\n[Output 5.4] ------------------------------------------------");
// TODO: Uncomment and fill in your query
// var result_5_4 = db.flights_enhanced.aggregate([ 
//      ... your stages here ...
// ]).toArray();
// printjson(result_5_4);


print("\n>>> EXECUTION COMPLETE. END OF FILE. <<<");