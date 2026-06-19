/* ================================================================================
   STUDENT HEADER
   Course: Data models in database systems
   Practical Work 3: Document databases and hierarchical data model
   
   Student Name, Surname:  Ngoc Bao Tram Tran
   Student ID:   	         231ADB294
   Variation #:            3
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
// My variant 3 - collection 1 - airlines: Do not change any data types

// 3.2 Fix Collection 2
// TODO: Write your updateMany script here

// Task 3 - collection "airports": convert lat/lon from data type String to Double

db.airports.updateMany(
  {},                         
  // .updateMany with filter {} means "match ALL documents" in the airports collection
  [
    // Using an array [] means using an "aggregation pipeline update",
    // which allows expressions like $convert and referencing fields as "$lat".
    {
      $set: {                  // $set operator: create/overwrite fields with new values
        lat: {                 // Set field "lat" to a converted value
          $convert: {          // $convert: convert a value to another specified type
            input: "$lat",     // input: take the current value of the field lat (from the document)
            to: "double",      // to: convert it into Double
            onError: null,     // onError: if conversion fails (invalid string), set lat = null
            onNull: null       // onNull: if input is null/missing, set lat = null
          }
        },
        lon: {                 // Same logic for "lon"
          $convert: {
            input: "$lon",
            to: "double",
            onError: null,
            onNull: null
          }
        }
      }
    }
  ]
);

// 3.3 Fix Collection 3
// TODO: Write your updateMany script here

// Task 3 - collection "flight_logs": 
// convert departure_time and arrival_time from String to Date

db.flight_logs.updateMany(
  {},  
  // .updateMany with Filter: {} means "match ALL documents" in the flight_logs collection
  [
    // Update expressed as an aggregation pipeline (array syntax)
    // which allows to use expressions like $convert and reference fields as "$departure_time".
    {
      $set: {                  // $set operator: overwrite or create fields with new values
        departure_time: {      // Update the "departure_time" field to a converted value
          $convert: {          // $convert operator: converts a value to another specified data type
            input: "$departure_time", // Take the current value of departure_time from the document
            to: "date",        // Convert the string into Date type
            onError: null,     // If conversion fails (invalid string), set the value to null
            onNull: null       // If the input value is null or missing, set the value to null
          }
        },
        arrival_time: {        // Update the "arrival_time" field (same logic as above)
          $convert: {
            input: "$arrival_time",   
            to: "date",        
            onError: null,     
            onNull: null       
          }
        }
      }
    }
  ]
);


// Task 3 - collection flight_logs: Convert passenger_count from String to Int32

db.flight_logs.updateMany(
  {},                         
  // .updateMany with Filter: {} means "match ALL documents" in the flight_logs collection
  [
    // Update defined as an aggregation pipeline (array syntax)
    // which allows the use of expressions such as $convert and reference fields as "$passenger_count".
    {
      $set: {                  // $set overwrites or creates the field with a new value
        passenger_count: {     // Target field to be updated to a converted value
          $convert: {          // $convert operator converts a value to another BSON data type
            input: "$passenger_count", // Take the current passenger_count value from the document
            to: "int",         // Convert the string value to Int32 
            onError: null,     // If conversion fails (invalid string), set value to null
            onNull: null       // If the input is null or missing, set value to null
          }
        }
      }
    }
  ]
);



print("Task 3 Complete: Data types updated.");


/* ================================================================================
   SECTION 4: TASK 4 - DENORMALIZATION
   Instructions: Create a new denomalizated collection using $lookup.
================================================================================ */

print("\n>>> Running Task 4: Creating flights_enhanced...");

// TODO: Write your aggregate pipeline here ending with $out or $merge
// db.flight_logs.aggregate([ ... ]);

db.flight_logs.aggregate([	
	// Stage 1: Look up and embed related data
	{
		$lookup: {
		  // Join flight_logs with the airports collection
		  from: "airports",
		  // Match flight_logs.dest_iata with airports.iata_code
		  localField: "dest_iata",
		  foreignField: "iata_code",
		  // Embed the matched airport document into a new field called dest_airport_details
		  as: "dest_airport_details"
		 }
	},
	
	// Unwind from array to object
	{
	  $unwind: { 
		  // $unwind with $dest_airport_details: 
		  // convert dest_airport_details from an array into a single embedded document
	    path: "$dest_airport_details",
	    preserveNullAndEmptyArrays: true 
	    // Keep the flight record even if no matching airport is found
	  }
	},
	
	// Stage 2: Calculate a new field
	{
	  $addFields: {
	    flight_duration_minutes: {
	    // Create a new field that calculates the flight duration in minutes
	      $dateDiff: { 
	      // $dateDiff returns the integer difference between the startDate and endDate 
	      // measured in the specified units
	      // The duration is calculated by subtracting departure_time from arrival_time
	        startDate: "$departure_time",
	        endDate: "$arrival_time",
	        unit: "minute"
	      }
	    }
	  }
	},
	
	// Stage 3: Output 
	{
	  // Output all transformed documents into a new collection
	  // Create (or overwrite) the collection named flights_enhanced
	  $out: "flights_enhanced"
	}
]);

print("Task 4 Complete: Collection created.");


/* ================================================================================
   SECTION 5: TASK 5 - ANALYTICAL QUERIES (INSTRUCTOR VERIFICATION)
   Instructions: 
   For each task below, you MUST use 'printjson()' to display your result.
   If you do not use printjson, the instructor cannot grade your work.
================================================================================ */

print("\n>>> Running Task 5 Queries...");

// --- Query 5.1 ---
// Title: 5.1 European Destination Analysis
print("\n[Output 5.1] ------------------------------------------------");
var result_5_1 = db.flights_enhanced.aggregate([ 
  {		// $match: filters documents 
    $match: {
      "dest_airport_details.country": { $in: ["France", "Germany"] } 
	  // Filter for flights where the destination country is France or Germany
    }
  },
  {   // $group: groups documents by a specific key
    $group: {
      _id: "$dest_airport_details.city", // Group flights by destination city
      avg_passenger_count: { $avg: "$passenger_count" } 
	  // Calculate the average number of passengers per flight
    }
  },
  {    // $sort: sorts the aggregated results
    $sort: {
      avg_passenger_count: -1 // Sort by average passenger count in descending order
    }
  },
  {  // $limit: restricts the number of output documents 
    $limit: 4 // this case is - limit output to 4
  }
]).toArray();
 printjson(result_5_1);


// --- Query 5.2 ---
// Title: 5.2 Under-Utilized Long Hauls
print("\n[Output 5.2] ------------------------------------------------");
var result_5_2 = db.flights_enhanced.aggregate([ 
  // $match: filters documents 
  {	$match: {
      flight_duration_minutes: { $gt: 400 }, // Select flights > 400 minutes 
      passenger_count: { $lt: 100 } // Select flights with < 100 passengers 
    }
  },
  // $project: choose which fields appear in the output
  {	$project: {
      _id: 0, // Hide the default MongoDB _id field
      flight_id: 1, // Include the flight ID
      destination_country: "$dest_airport_details.country", // Extract destination country 
      passenger_count: 1 // Include passenger count
    }
  },
  // $sort: sorts the aggregated results
  {	$sort: {
      passenger_count: 1 // Sort results by passenger count (ascending)
    }
  },
  // $limit: restricts the number of output documents 
  {	$limit: 7 // this case is - limit the output to 7 documents
  }
]).toArray();
printjson(result_5_2);


// --- Query 5.3 ---
// Title: 5.3 Aircraft Range Tier
print("\n[Output 5.3] ------------------------------------------------");
var result_5_3 = db.flights_enhanced.aggregate([ 
  // $group: groups documents by aircraft_model
  {	$group: {
      _id: "$aircraft_model", // _id defines the grouping key 
	  // (each unique aircraft model becomes one group)
      avg_duration: { $avg: "$flight_duration_minutes" } 
      // $avg calculates the average flight duration for each aircraft model
    }
  },
  // $match: Filters the grouped results
  {	$match: {
      avg_duration: { $lte: 650 } 
	  // Keep aircraft models whose average duration <= 650 minutes
    }
  },
  // $sort: Sorts the filtered results
  {	$sort: {
      avg_duration: -1 // Sort by avg_duration in descending order (largest first)
    }
  },
  // $limit: Restricts the output size
  {	$limit: 10   // Return only the top 10 aircraft models
  }
]).toArray();
printjson(result_5_3);


// --- Query 5.4 ---
// Title: 5.4 Busy Route Identification 
print("\n[Output 5.4] ------------------------------------------------");
var result_5_4 = db.flights_enhanced.aggregate([ 
  { // $group: groups documents by destination airport code
    $group: {
      _id: "$dest_iata", // _id: the field used as grouping key (dest_iata)
      total_flights: { $sum: 1 } 
	  // total_flights: counts how many flights go to each destination
    }
  },
  { // $match: filters documents 
    $match: {
      total_flights: { $gte: 100 } // filters only destinations with >= 100 flights 
    }
  },
  {	// $sort: sorts the aggregated results
    $sort: {
      total_flights: 1 // sorts results by total_flights in ascending order
    }
  },
  {	// $limit: restricts the number of output documents 
    $limit: 5 // limits the output to 5 destinations
  }
]).toArray();
printjson(result_5_4);


print("\n>>> EXECUTION COMPLETE. END OF FILE. <<<");