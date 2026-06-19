REM   Script: GROUP_15_PW1
REM   PW1 - ARENA script

--- CUSTOMER type (Arena Management Domain)
--- Declares methods for subscribing.

CREATE OR REPLACE TYPE CUSTOMER AS OBJECT(
    -- Define the CUSTOMER object type, representing a person with his/her preferred type.
    -- Methods: To subscribe.
    
    -- Types of preferred event of the customer 
    PREFERRED_EVENT_TYPE VARCHAR2(50 CHAR),  
    -- CUSTOMER_TYPE_LIST

    -- Procedure for the customer to subscribe for a season pass / plan
    MEMBER PROCEDURE SUBSCRIBE(
        P_LEVEL      IN VARCHAR2,  -- Target subscription level (e.g., 'SILVER','GOLD','VIP')
        P_VALID_FROM IN DATE      -- Start date of the subscription/season pass
    )
);
/
/

--- EVENT_ORGANIZER type (Arena Management Domain)
--- Declare a member procedure to submit a new request

CREATE OR REPLACE TYPE EVENT_ORGANIZER AS OBJECT( 
    -- Define the EVENT_ORGANIZER object type with an organization_name, 
    -- and a procedure to submit a new request for an event.

    -- Organizer's company name
    ORGANIZATION_NAME VARCHAR2(50 CHAR),

    -- Submit a new request on behalf of this organizer
    MEMBER PROCEDURE SUBMIT_REQUEST(
        p_event_id IN CHAR,  -- target event identifier to request
        p_priority IN NUMBER DEFAULT 1,  -- request priority (1..9), lower means higher priority
        p_note     IN VARCHAR2 DEFAULT NULL  -- optional note for the arena manager
    )
); 
/

--- PERSON type (Arena Management Domain)
--- Represents a general person and embeds role-specific data.

CREATE OR REPLACE TYPE PERSON AS OBJECT( 
    -- Define the PERSON object type, representing a general person with attributes 
    -- such as ID, name, and date of birth. The type also contains attributes 
    -- for patient and doctor data (using embedded object types) and functions 
    -- for calculating age and retrieving prescriptions. 
    
    -- Unique identifier of the person (matches PK in PEOPLE table)
    PERSONAL_ID    CHAR(5 CHAR),                     -- Unique identifier for the person

    -- Basic identity and contact information
    NAME           VARCHAR2(250 CHAR),          -- First name of the person 
    SURNAME        VARCHAR2(250 CHAR),          -- Last name of the person 
    EMAIL          VARCHAR2(130 CHAR),          -- Email of the person 
    PHONE          VARCHAR2(20 CHAR),          -- Phone number of the person 
    DATE_OF_BIRTH  DATE,                       -- Date of birth of the person 

    -- Embedded role-specific data (may be NULL if the person does not hold the role)
    CUSTOMER_DATA          CUSTOMER,                    -- Data if the person is a customer
    EVENT_ORGANIZER_DATA   EVENT_ORGANIZER,             -- Data if the person is an event organizer 

    -- Function to compute the person's age in full years
    MEMBER FUNCTION GET_AGE RETURN NUMBER
);


CREATE TABLE PEOPLE OF PERSON( 
    -- Create a table PEOPLE using the PERSON object type. 
    -- The table's primary key is the ID attribute from the PERSON type, 
    -- ensuring each person has a unique identifier. 
 
    PERSONAL_ID PRIMARY KEY 
);
/


BEGIN
    -- Insert 'Person' with only CUSTOMER_DATA
    INSERT INTO PEOPLE VALUES (
        PERSON(
            PERSONAL_ID           => 'P0001',
            NAME                  => 'Ilaha',
            SURNAME               => 'Habibova',
            EMAIL                 => 'ilaha.habibova@gmail.com',
            PHONE                 => '+371-20000001',
            DATE_OF_BIRTH         => TO_DATE('2006-01-09', 'YYYY-MM-DD'), 
            CUSTOMER_DATA         => CUSTOMER('CONCERT, CONFERENCES, EXHIBITIONS'),
            EVENT_ORGANIZER_DATA  => NULL
        )
    );


    -- Insert 'Person' with only EVENT_ORGANIZER_DATA
    INSERT INTO PEOPLE VALUES (
        PERSON(
            PERSONAL_ID           => 'P0002',
            NAME                  => 'Ngoc Bao Tram',
            SURNAME               => 'Tran',
            EMAIL                 => 'ngoc-bao-tram.tran@edu.rtu.lv',
            PHONE                 => '+371-20000002',
            DATE_OF_BIRTH         => TO_DATE('2005-07-06', 'YYYY-MM-DD'),
            CUSTOMER_DATA         => NULL,
            EVENT_ORGANIZER_DATA  => EVENT_ORGANIZER('Nova Events')
        )
    );


    -- Insert 'Person' with CUSTOMER_DATA + EVENT_ORGANIZER_DATA
    INSERT INTO PEOPLE VALUES (
        PERSON(
            PERSONAL_ID           => 'P0003',
            NAME                  => 'Anh',
            SURNAME               => 'Pham',
            EMAIL                 => 'anh.pham@outlook.com',
            PHONE                 => '+371-20000004',
            DATE_OF_BIRTH         => DATE '1995-03-30',
            CUSTOMER_DATA         => CUSTOMER('SPORTS, COMMUNITY'),
            EVENT_ORGANIZER_DATA  => EVENT_ORGANIZER('Sunrise Productions')
        )
    );


    -- Insert 'Person' with none of the role-specific data
    INSERT INTO PEOPLE VALUES (
        PERSON(
            PERSONAL_ID           => 'P0004',
            NAME                  => 'Bao',
            SURNAME               => 'Vo',
            EMAIL                 => 'bao.vo@gmail.com',
            PHONE                 => '+371-20000005',
            DATE_OF_BIRTH         => DATE '2002-01-15',
            CUSTOMER_DATA         => NULL,
            EVENT_ORGANIZER_DATA  => NULL
        )
    );


    -- Insert 'Person' with only CUSTOMER_DATA 
    INSERT INTO PEOPLE VALUES (
        PERSON(
            PERSONAL_ID           => 'P0005',
            NAME                  => 'Martins',
            SURNAME               => 'Zalitis',
            EMAIL                 => 'martins.zalitis@inbox.lv',
            PHONE                 => '+371-20000006',
            DATE_OF_BIRTH         => DATE '1999-12-02',
            CUSTOMER_DATA         => CUSTOMER('TECH EVENTS, STARTUP PITCHES'),
            EVENT_ORGANIZER_DATA  => NULL
        )
    );


    -- Insert 'Person' with only CUSTOMER_DATA 
    INSERT INTO PEOPLE VALUES (
        PERSON(
            PERSONAL_ID           => 'P0006',
            NAME                  => 'Elina',
            SURNAME               => 'Krumina',
            EMAIL                 => 'elina.krumina@gmail.com',
            PHONE                 => '+371-20000007',
            DATE_OF_BIRTH         => DATE '2001-06-18',
            CUSTOMER_DATA         => CUSTOMER('FASHION SHOWS, ART EXHIBITIONS'),
            EVENT_ORGANIZER_DATA  => NULL
        )
    );

END;
/


SELECT * FROM PEOPLE 
    -- Retrieve data from PEOPLE 
    -- BAD EXAMPLE!!! Details are not displayed! 


SELECT
    -- This query retrieves detailed information from the PEOPLE object table. 
    -- It displays basic details (e.g., ID, name, surname, email, phone number and date of birth) along  
    -- with specific details from the `CUSTOMER_DATA`, and `EVENT_ORGANIZER_DATA`
    -- subtypes if they are populated. 

    -- Basic identity and contact information
    P.PERSONAL_ID,        -- Person's identifier (CHAR(5))
    P.NAME,       -- First name
    P.SURNAME,        -- Surname
    P.EMAIL,            -- Email address
    P.PHONE,            -- Phone number
    P.DATE_OF_BIRTH,    -- Date of birth

    -- Customer-specific data (if the person is a customer)
    -- Retrieve SUBSCRIPT if the person has PATIENT_DATA populated
    CASE
        WHEN P.CUSTOMER_DATA IS NOT NULL
        THEN P.CUSTOMER_DATA.PREFERRED_EVENT_TYPE
    END                        AS CUSTOMER_PREFERRED_EVENT_TYPE,

    -- Event organizer-specific data (if the person is an organizer)
    CASE
        WHEN P.EVENT_ORGANIZER_DATA IS NOT NULL
        THEN P.EVENT_ORGANIZER_DATA.ORGANIZATION_NAME
    END                        AS ORGANIZER_COMPANY

FROM
    PEOPLE P
ORDER BY
    P.PERSONAL_ID;


CREATE OR REPLACE TYPE EVENT AS OBJECT ( 
    -- Define the EVENT object type, representing a general event organized in the arena. 
    -- Contains an ID, name, description, event date, event time, and cost. 
    -- EVENT serves as a base type for specific event types, such as Sport Events 
    -- and Other Events (e.g., concerts), through inheritance. 
 
    EVENT_ID     CHAR(4),                 -- Unique identifier for the event 
    EVENT_NAME   VARCHAR2(100 CHAR),      -- Name of the event 
    EVENT_TIME   TIMESTAMP,               -- Time when the event starts 
    REF_EVENT_ORGANIZER REF PERSON,  -- Reference to event organizer 

       -- Function to to get a description of the event 
    MEMBER FUNCTION GET_DESCRIPTION RETURN VARCHAR2
 
) NOT FINAL;
/


CREATE OR REPLACE TYPE SEAT AS OBJECT(
    -- Define the SEAT object type, representing a specific seat in the arena.
    -- Contains a ID, seat category, availability flag.

    SEAT_ID CHAR(5),     -- -- Unique identifier for the seat
    SEAT_CATEGORY CHAR(1),  -- Category code (e.g., 'V','P','G', etc.)
    AVAILABILITY NUMBER(1)   -- 1=available, 0=unavailable
);


CREATE TABLE SEATS OF SEAT (
    -- Create the SEATS table based on the SEAT object type. This table stores
    -- all physical seats available in the arena. Seats can be linked to sectors
    -- via REF attributes inside SEAT (if defined in the type).

    SEAT_ID PRIMARY KEY,                                -- Unique seat identifier

    -- Domain constraints (teacher-style):
    CONSTRAINT CHECK_SEAT_AVAILABILITY CHECK (AVAILABILITY IN (0, 1)), -- 1=available, 0=unavailable
    CONSTRAINT CHECK_SEAT_CATEGORY    CHECK (SEAT_CATEGORY IN ('V','P','G')) -- VIP / Premium / General
);
/


BEGIN  
    -- Insert data for SEATS Table for various test seats.
    INSERT INTO SEATS VALUES (SEAT('A1001', 'V', 1));
    INSERT INTO SEATS VALUES (SEAT('A1002', 'V', 0));
    INSERT INTO SEATS VALUES (SEAT('B2001', 'P', 1));
    INSERT INTO SEATS VALUES (SEAT('C3001', 'G', 1));
    INSERT INTO SEATS VALUES (SEAT('C1002','G',1)); 
END;


SELECT 
    -- This query retrieves detailed information from the SEATS table. 
    -- It displays the seat ID, seat category, and a human-readable status of availability  
    -- based on the availability value. 

    S.SEAT_ID,                              -- Unique identifier for each seat 
    S.SEAT_CATEGORY,                        -- Category code or type of the seat 
     
    -- Convert availability value to descriptive status text 
    CASE S.AVAILABILITY  
        WHEN 1 THEN 'Available'  
        ELSE 'Occupied'  
    END AS SEAT_STATUS                      -- Readable availability status of the seat 

FROM  
    SEATS S                                 -- Source table containing all seats; SEATS is the original name of that table, S is the alias
ORDER BY  
    S.SEAT_ID                              -- Sort results by seat identifier
/


CREATE OR REPLACE TYPE SPORT_EVENT UNDER EVENT (
    -- Define the SPORT_EVENT subtype under EVENT. This subtype is used 
    -- for tablet sport events where ticket prices are calculated dynamically based on
    -- a BASE price, a COEFFICIENT, and a reference to SEAT (including seat id, seat category).

    BASE_PRICE   NUMBER(2),          -- Base ticket price for the sport event
    COEFFICIENT  NUMBER(2,1),        -- Price multiplier applied to the base price
    REF_SEAT     REF SEAT,           -- Reference to the seat used for pricing

    -- Function to calculate ticket price for this sport event based on the seat
    MEMBER FUNCTION get_price_for_seat RETURN NUMBER, 

    -- Function to retrieve a specific description for sport events
    OVERRIDING MEMBER FUNCTION get_description RETURN VARCHAR2
);
/


CREATE OR REPLACE TYPE OTHERS UNDER EVENT (
    -- Define the OTHERS subtype under EVENT. This subtype represents 
    -- non-sport events such as concerts, festivals, or theatre shows. 
    -- Ticket pricing for other events, the prices 
    -- may be all the same, or be split based on the sectors (e.g., for concerts)

    EVENT_CATEGORY  VARCHAR2(30 CHAR),   -- Type of the event (e.g., concerts). 
    FIXED_PRICE     NUMBER(3),           -- Fixed ticket price (if the event does not depend on sector). 
    SECTOR_NAME     VARCHAR2(20 CHAR),   -- Name of the sector. 
    SECTOR_PRICE    NUMBER(3),           -- Price of the sector for sector-based events. 

    -- Function to calculate ticket price based on sector pricing rules. 
    MEMBER FUNCTION GET_PRICE_BY_SECTOR RETURN NUMBER, 

    -- Function to retrieve a specific description for other types of events 
    OVERRIDING MEMBER FUNCTION GET_DESCRIPTION RETURN VARCHAR2 
);
/


CREATE TABLE EVENTS OF EVENT ( 
    -- Create the EVENTS table based on the EVENT object type. This table stores 
    -- general information about all events organized in the arena, including 
    -- both sport and other event types. 

    EVENT_ID PRIMARY KEY,                        -- Primary key for each event record. 
    REF_EVENT_ORGANIZER  NOT NULL            -- Organizer reference must be present for every event (common to all subtypes).
);
/


CREATE OR REPLACE TYPE BODY SPORT_EVENT AS 

    -- The GET_PRICE_FOR_SEAT function calculates the ticket price for this
    -- sport event based on the referenced seat. The calculation uses the
    -- BASE_PRICE, COEFFICIENT, and the seat category stored in the SEAT object.
    --

    -- Apply pricing rules by category:
    --      - 'V' (VIP)      → BASE_PRICE * COEFFICIENT * 1.5
    --      - 'P' (Premium)  → BASE_PRICE * COEFFICIENT * 1.2
    --      - Others (e.g., 'G') → BASE_PRICE * COEFFICIENT

    MEMBER FUNCTION get_price_for_seat RETURN NUMBER IS
        V_SEAT               SEAT;     -- Holds the dereferenced SEAT object
        V_SEAT_CATEGORY      CHAR(1);  -- Category code of the seat (e.g., 'V' - VIP,'P' - PREMIUM,'G' - GENERAL) 
        -- Things we have added due to the original description
        V_CALCULATED_PRICE   NUMBER;   -- Computed ticket price
    BEGIN
        -- Retrieve the seat object from the REF
        SELECT DEREF(SELF.REF_SEAT) INTO V_SEAT FROM DUAL;
        V_SEAT_CATEGORY := V_SEAT.SEAT_CATEGORY;

        -- Apply category-based pricing rule - the formula we have modified, 
        -- but still keep the coefficient and base price in the original formula
        V_CALCULATED_PRICE :=
            CASE V_SEAT_CATEGORY
                WHEN 'V' THEN SELF.BASE_PRICE * SELF.COEFFICIENT * 1.5  -- VIP
                WHEN 'P' THEN SELF.BASE_PRICE * SELF.COEFFICIENT * 1.2  -- Premium
                ELSE                 SELF.BASE_PRICE * SELF.COEFFICIENT  -- General/others
            END;

        RETURN ROUND(V_CALCULATED_PRICE, 2);
    END get_price_for_seat;

    -- The GET_DESCRIPTION function returns a specialized textual description for SPORT_EVENT
    OVERRIDING MEMBER FUNCTION get_description RETURN VARCHAR2 IS
    BEGIN
        RETURN 'Sport Event: ' || SELF.EVENT_NAME
             || ' | Base: ' || TO_CHAR(SELF.BASE_PRICE)
             || ' | Coefficient: ' || TO_CHAR(SELF.COEFFICIENT);
    END get_description;

END;
/


CREATE OR REPLACE TYPE BODY OTHERS AS 
    -- Function to calculate the ticket price for other events 
    -- Determines price based on EVENT_CATEGORY and sector or fixed price. 
    MEMBER FUNCTION get_price_by_sector RETURN NUMBER IS 
    BEGIN 
        IF UPPER(SELF.EVENT_CATEGORY) LIKE '%CONCERT%' THEN 
            RETURN SELF.SECTOR_PRICE;       -- Concerts use SECTOR_PRICE - this is what we assume
        ELSE 
            RETURN SELF.FIXED_PRICE;        -- Others use FIXED_PRICE - this is what we assume
        END IF; 
    END get_price_by_sector; 


    -- Specific description for other events 
    OVERRIDING MEMBER FUNCTION get_description RETURN VARCHAR2 IS 
    BEGIN 
        IF UPPER(SELF.EVENT_CATEGORY) LIKE '%CONCERT%' THEN 
            RETURN 'Other Event: ' || EVENT_NAME ||  
                   ' (Category: ' || EVENT_CATEGORY ||  
                   ', Sector: ' || SECTOR_NAME ||  
                   ', Price: ' || SECTOR_PRICE || ')'; 
        ELSE 
            RETURN 'Other Event: ' || EVENT_NAME ||  
                   ' (Category: ' || EVENT_CATEGORY ||  
                   ', Price: ' || FIXED_PRICE || ')'; 
        END IF; 
    END get_description; 
END; 
/


-- INSERT DATA INTO EVENTS TABLE (both SPORT_EVENT and OTHERS subtypes)
DECLARE
	-- This PL/SQL block demonstrates how to create REFs to specific records  
	-- (such as event organizers and seats) and use them to construct entries  
	-- in the EVENTS table, representing different types of events held in the arena.  

	-- First, it retrieves REFs to the event organizer (from the PEOPLE table)  
	-- and REFs to various seat categories (VIP, Premium, General) from the SEATS table.  

	-- Using these REFs, the block then inserts multiple events of two types:  
	-- - SPORT_EVENT: representing sports competitions like Basketball, Football, or Tennis.  
	--   Each record uses BASE_PRICE, COEFFICIENT, and a referenced SEAT to calculate ticket prices.  
	-- - OTHERS: representing non-sport events such as concerts, festivals, and theatre shows.  
	--   These records use either FIXED_PRICE or SECTOR-based pricing depending on event type.  

	-- This block illustrates how REFs (references) are used to link PEOPLE and SEATS  
	-- directly to specific EVENTS, forming a detailed object-relational model.  
	-- It also demonstrates the use of subtype inheritance where SPORT_EVENT and OTHERS  
	-- specialize the general EVENT type with their own attributes and methods  
	-- (e.g., GET_PRICE_FOR_SEAT for sports events and GET_PRICE_BY_SECTOR for others).  
	-- Such a model enables accurate real-world representation of different kinds  
	-- of events and pricing rules within a unified database structure.  


    -- References used to link organizer and seats.
    ORGANIZER_REF_P2  REF PERSON;        -- REF to the event organizer from PEOPLE - Person 2.
    ORGANIZER_REF_P3  REF PERSON;        -- REF to the event organizer from PEOPLE - Person 3.
    VIP_REF        REF SEAT;          -- REF to a VIP seat (category 'VIP').
    PREMIUM_REF    REF SEAT;          -- REF to a Premium seat (category 'PREMIUM').
    GENERAL_REF    REF SEAT;          -- REF to a General seat (category 'GENERAL').
BEGIN
    -- Fetch REF to the event organizer from PEOPLE.
    SELECT REF(P) INTO ORGANIZER_REF_P2 FROM PEOPLE P WHERE P.PERSONAL_ID = 'P0002';
    SELECT REF(P) INTO ORGANIZER_REF_P3 FROM PEOPLE P WHERE P.PERSONAL_ID = 'P0003'; 

    -- Fetch REFs to seats for pricing
    SELECT REF(S) INTO VIP_REF     FROM SEATS S WHERE S.SEAT_ID = 'A1001';  -- VIP seat.
    SELECT REF(S) INTO PREMIUM_REF FROM SEATS S WHERE S.SEAT_ID = 'B2001';  -- Premium seat.
    SELECT REF(S) INTO GENERAL_REF FROM SEATS S WHERE S.SEAT_ID = 'C3001';  -- General seat.


    -- Insert a GENERAL EVENT (Arena Open Day) into the EVENTS table 
    INSERT INTO EVENTS VALUES (
        EVENT(
            'GE01',                            -- General Event ID
            'Arena Open Day',                  -- EVENT NAME
            TIMESTAMP '2024-09-01 10:00:00',   -- EVENT TIME
            ORGANIZER_REF_P2                            -- REF_EVENT_ORGANIZER
        )
    );


    -- Insert SPORT EVENTS  

    -- Insert Sport Event 1 (Basketball - "Basketball Championship") with VIP seat reference.
    INSERT INTO EVENTS VALUES (
        SPORT_EVENT(
            'SE01',                                -- EVENT ID
            'Basketball Championship',             -- EVENT NAME
            TIMESTAMP '2024-06-15 19:00:00',       -- EVENT TIME
            ORGANIZER_REF_P2,                         -- REF_EVENT_ORGANIZER
            20,                                    -- BASE_PRICE
            1.5,                                   -- COEFFICIENT
            VIP_REF                                -- REF_SEAT
        )
    );

    -- Insert Sport Event 2 (Football - "Football Match") with Premium seat reference.
    INSERT INTO EVENTS VALUES (
        SPORT_EVENT(
            'SE02',
            'Football Match',
            TIMESTAMP '2024-06-20 20:00:00',
            ORGANIZER_REF_P2,
            25,
            1.8,
            PREMIUM_REF
        )
    );

    -- Insert Sport Event 3 (Tennis - "Tennis Tournament") with General seat reference.
    INSERT INTO EVENTS VALUES (
        SPORT_EVENT(
            'SE03',
            'Tennis Tournament',
            TIMESTAMP '2024-07-10 14:00:00',
            ORGANIZER_REF_P2,
            30,
            2.0,
            GENERAL_REF
        )
    );


    -- Insert OTHER EVENTS  
    -- Prices for these events may be fixed or sector-based (e.g., concerts).

    -- Insert Other Event 1 (Concert - "Rock Concert") – sector-based pricing.
    INSERT INTO EVENTS VALUES (
        OTHERS(
            'OE01',                          -- EVENT_ID
            'Rock Concert',                  -- EVENT_NAME
            TIMESTAMP '2024-07-05 21:00:00', -- EVENT_TIME
            ORGANIZER_REF_P3,                   -- REF_EVENT_ORGANIZER
            'Concert',                       -- EVENT_CATEGORY
            NULL,                            -- FIXED_PRICE (use sector price)
            'Front Row',                     -- SECTOR_NAME
            100                              -- SECTOR_PRICE
        )
    );

    -- Insert Other Event 2 (Theater - "Romeo and Juliet") – fixed pricing.
    INSERT INTO EVENTS VALUES (
        OTHERS(
            'OE02',
            'Romeo and Juliet',
            TIMESTAMP '2024-07-12 19:30:00',
            ORGANIZER_REF_P3,
            'Theater',
            50,                              -- FIXED_PRICE
            NULL,                            -- SECTOR_NAME (not used)
            NULL                             -- SECTOR_PRICE (not used)
        )
    );

    -- Insert Other Event 3 (Festival - "Summer Festival") – fixed pricing.
    INSERT INTO EVENTS VALUES (
        OTHERS(
            'OE03',
            'Summer Festival',
            TIMESTAMP '2024-08-15 12:00:00',
            ORGANIZER_REF_P3,
            'Festival',
            25,
            NULL,
            NULL
        )
    );

    -- Insert Other Event 4 (Concert - "Jazz Night") – sector-based pricing.
    INSERT INTO EVENTS VALUES (
        OTHERS(
            'OE04',
            'Jazz Night',
            TIMESTAMP '2024-08-20 20:00:00',
            ORGANIZER_REF_P3,
            'Concert',
            NULL,                            -- FIXED_PRICE
            'VIP Lounge',                    -- SECTOR_NAME
            120                              -- SECTOR_PRICE
        )
    );

    -- Insert Other Event 5 (Concert - "Classical Gala") – sector-based pricing.
    INSERT INTO EVENTS VALUES (
        OTHERS(
            'OE05',                           
            'Classical Gala',                 
            TIMESTAMP '2024-10-05 19:00:00',   
            ORGANIZER_REF_P3,                    
            'Concert',                         
            NULL,                                 -- FIXED_PRICE
            'Orchestra',                        -- SECTOR_NAME
            150                               -- SECTOR_PRICE
        )
    );

    COMMIT;  -- Persist inserted events.
END;
/


-- RETRIEVE DATA FROM TABLE "EVENTS"
SELECT
    -- This query retrieves all event information from the EVENTS table,
    -- including both SPORT_EVENT and OTHERS subtypes. It also determines
    -- the event type and calculates the ticket price according to each subtype.

    E.EVENT_ID,
    E.EVENT_NAME,

    CASE
        WHEN VALUE(E) IS OF (SPORT_EVENT) THEN 'Sport Event'
        WHEN VALUE(E) IS OF (OTHERS)      THEN 'Other Event'
    END AS EVENT_TYPE,

    TO_CHAR(E.EVENT_TIME, 'DD-MON-YYYY HH24:MI') AS EVENT_TIME,

    CASE
        WHEN VALUE(E) IS OF (SPORT_EVENT) THEN
            TO_CHAR(TREAT(VALUE(E) AS SPORT_EVENT).get_price_for_seat())
        WHEN VALUE(E) IS OF (OTHERS) THEN
            TO_CHAR(TREAT(VALUE(E) AS OTHERS).get_price_by_sector())
    END AS CALCULATED_PRICE

FROM EVENTS E
WHERE VALUE(E) IS OF (SPORT_EVENT) OR VALUE(E) IS OF (OTHERS)
ORDER BY E.EVENT_TIME;
/


CREATE OR REPLACE TYPE TICKET AS OBJECT ( 
    -- Define the TICKET object type, representing a purchased ticket. 
    -- Each ticket stores references to the CUSTOMER, EVENT, and SEAT. 
    -- The price is computed by delegating to the specific EVENT subtype. 

    TICKET_ID    CHAR(6),     -- Unique identifier for the ticket 
    REF_CUSTOMER REF PERSON,  -- Reference to the customer who owns the ticket 
    REF_EVENT    REF EVENT,   -- Reference to the event for which the ticket is issued 
    REF_SEAT     REF SEAT,    -- Reference to the seat assigned to the ticket 

    -- Function to compute the ticket price using the event subtype rules 
    MEMBER FUNCTION get_price_for_ticket RETURN NUMBER 
);
/


CREATE OR REPLACE TYPE BODY TICKET AS
    -- Compute ticket price by calling the appropriate method on the EVENT subtype. 
    -- For SPORT_EVENT then use GET_PRICE_FOR_SEAT(); for OTHERS then use GET_PRICE_BY_SECTOR(). 

    MEMBER FUNCTION get_price_for_ticket RETURN NUMBER IS
        V_EVENT  EVENT;   -- Dereferenced EVENT object
        V_PRICE  NUMBER;  -- Result price
   
 BEGIN
        -- Dereference the event to check its subtype
        SELECT DEREF(SELF.REF_EVENT) INTO V_EVENT FROM DUAL;

        IF V_EVENT IS OF (SPORT_EVENT) THEN
            SELECT TREAT(DEREF(SELF.REF_EVENT) AS SPORT_EVENT).get_price_for_seat()
            INTO V_PRICE FROM DUAL;

        ELSIF V_EVENT IS OF (OTHERS) THEN
            SELECT TREAT(DEREF(SELF.REF_EVENT) AS OTHERS).get_price_by_sector()
            INTO V_PRICE FROM DUAL;

        ELSE
            V_PRICE := NULL;  -- Unknown/unsupported subtype
        END IF;

        RETURN V_PRICE;
    END get_price_for_ticket;
END;
/


CREATE OR REPLACE TYPE REQUEST AS OBJECT (
    -- Define the REQUEST object type representing an event approval request.
    -- Each request links an organizer (PERSON) to a target event (EVENT),
    -- and stores priority, note, creation timestamp, and current status.

    REQUEST_ID         CHAR(6),               -- Unique request identifier 
    REF_EVENT      REF EVENT,             -- Target event (REF linking to an event)
    REF_ORGANIZER  REF PERSON,            -- Submitting organizer (REF linking to an event - organizer)
    PRIORITY       NUMBER,                -- Priority (1 = highest)
    NOTE           VARCHAR2(200 CHAR),    -- Note/reason
    CREATED_AT     DATE,                  -- Creation timestamp
    STATUS         VARCHAR2(10 CHAR)      -- Domain of status: 'PENDING','APPROVED','REJECTED'
);
/


CREATE TABLE REQUESTS OF REQUEST (
    -- Create the REQUESTS table based on the REQUEST object type.
    -- This table stores all event approval requests submitted by organizers.
    -- Each request references an EVENT and an ORGANIZER via REF attributes,
    -- and records its priority, creation date, and approval status.

    REQUEST_ID PRIMARY KEY,              -- Primary key to ensure unique requests
    REF_EVENT      NOT NULL,         -- Reference to the related event (REF EVENT)
    REF_ORGANIZER  NOT NULL,         -- Reference to the submitting organizer (REF PERSON)
    PRIORITY       NOT NULL,         -- Priority level (1..9)
    STATUS         NOT NULL          -- Request status ('PENDING','APPROVED','REJECTED')
);
/


CREATE OR REPLACE TYPE BODY EVENT_ORGANIZER AS 
    -- MEMBER PROCEDURE SUBMIT_REQUEST
    -- Submits a new event approval request from the event organizer


    MEMBER PROCEDURE SUBMIT_REQUEST(
        p_event_id IN CHAR,                                    -- Target event identifier
        p_priority IN NUMBER DEFAULT 1,               -- Priority level (1..9, 1 = highest)
        p_note     IN VARCHAR2 DEFAULT NULL      -- Optional note or description
    ) IS
        v_org_ref    REF PERSON;   -- REF to the PERSON containing this organizer
        v_event_ref  REF EVENT;    -- REF to the EVENT being requested
        v_req_id     CHAR(6);      -- Auto-generated request identifier
        v_owner_ref  REF PERSON;   -- REF of the event’s current organizer (if any)
    BEGIN
        -- Retrieve the PERSON that contains this EVENT_ORGANIZER instance
        SELECT REF(p) INTO v_org_ref
        FROM PEOPLE p
        WHERE p.EVENT_ORGANIZER_DATA = SELF;

        -- Retrieve the REF of the target EVENT by its ID.
        SELECT REF(e) INTO v_event_ref
        FROM EVENTS e
        WHERE e.EVENT_ID = p_event_id;

        -- Verify the event belongs to the same organizer to make sure.
        SELECT e.REF_EVENT_ORGANIZER INTO v_owner_ref
        FROM EVENTS e
        WHERE e.EVENT_ID = p_event_id;

        IF v_owner_ref != v_org_ref THEN
            RAISE_APPLICATION_ERROR(-20050,
                'This event is not owned by the current organizer.');
        END IF;

        -- Generate the next REQUEST_ID (6-digit, zero-padded).
        SELECT LPAD(NVL(MAX(TO_NUMBER(r.REQUEST_ID)), 0) + 1, 6, '0')
          INTO v_req_id
          FROM REQUESTS r;

        -- Insert the new request record into REQUESTS.
        INSERT INTO REQUESTS VALUES (
            REQUEST(
                v_req_id,          -- Request ID
                v_event_ref,       -- Target event reference
                v_org_ref,         -- Organizer reference
                p_priority,        -- Priority value
                p_note,            -- Optional note
                SYSDATE,           -- Creation timestamp
                'PENDING'          -- Initial status
            )
        );

        -- Display request information 
        DBMS_OUTPUT.PUT_LINE('Request ' || v_req_id ||
                             ' submitted for event ' || p_event_id ||
                             ' with priority ' || p_priority || '.');

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Raised if organizer or event not found.
            DBMS_OUTPUT.PUT_LINE('Error: Organizer or Event not found.');
        WHEN OTHERS THEN
            -- Catch-all for unexpected errors.
            DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
    END SUBMIT_REQUEST;

END;
/


SELECT 
    -- Retrieve the current organizer (owner) assigned to specific events.
    -- This query shows the event identifier and the personal ID of the
    -- organizer linked through the REF_EVENT_ORGANIZER reference.

    e.EVENT_ID,                                         -- Unique event identifier
    DEREF(e.REF_EVENT_ORGANIZER).PERSONAL_ID AS OWNER_PID  -- Organizer’s personal ID (owner)
FROM 
    EVENTS e;
/


DECLARE
    -- This test block is designed to verify the SUBMIT_REQUEST procedure  in the EVENT_ORGANIZER object type
    -- It demonstrates how multiple event organizers (retrieved from the PEOPLE table) can submit new event approval requests to the REQUESTS table. 

    -- Declare local variables for event organizers.
    -- Each variable will store the EVENT_ORGANIZER object retrieved
    -- from the PEOPLE table based on the corresponding PERSONAL_ID.

    v_org_1 EVENT_ORGANIZER;  -- Organizer with PERSONAL_ID = 'P0002'
    v_org_2 EVENT_ORGANIZER;  -- Organizer with PERSONAL_ID = 'P0003'
BEGIN
    -- Submit requests on behalf of two different organizers.
    -- Each organizer retrieves its EVENT_ORGANIZER object from PEOPLE,
    -- then submits a new event request with defined priority and note.

    -- Organizer 1 (PERSONAL_ID = 'P0002')
    SELECT p.EVENT_ORGANIZER_DATA
      INTO v_org_1
      FROM PEOPLE p
     WHERE p.PERSONAL_ID = 'P0002'
       AND p.EVENT_ORGANIZER_DATA IS NOT NULL;

    -- Submit a request for event SE01 with high priority.
    v_org_1.SUBMIT_REQUEST('SE01', 1, 'Peak season booking');

    -- Organizer 2 (PERSONAL_ID = 'P0003')
    SELECT p.EVENT_ORGANIZER_DATA
      INTO v_org_2
      FROM PEOPLE p
     WHERE p.PERSONAL_ID = 'P0003'
       AND p.EVENT_ORGANIZER_DATA IS NOT NULL;

    -- Submit a request for event OE02 with medium priority.
    v_org_2.SUBMIT_REQUEST('OE02', 2, 'Outdoor concert request');


    -- The COMMIT statement at the end confirms all insertions, ensuring that the requests are permanently stored in the REQUESTS table.
    -- Commit all operations after successful submissions.
    COMMIT;


-- If an organizer or event cannot be found, or any unexpected error occurs, appropriate error messages are displayed through the EXCEPTION block.
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Raised if one of the organizers is not found in PEOPLE.
        DBMS_OUTPUT.PUT_LINE('Error: Organizer not found in PEOPLE table.');
    WHEN OTHERS THEN
        -- Catch-all for any unexpected errors during execution.
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;
/


SELECT 
    -- This query retrieves detailed information from the REQUESTS table. 
    -- It displays the request identifier, linked organizer and event, 
    -- as well as priority level, note, creation date, and current status. 
       r.REQUEST_ID,            -- Unique request identifier
       DEREF(r.REF_ORGANIZER).PERSONAL_ID AS ORGANIZER_ID,           -- Organizer's personal ID        
       DEREF(r.REF_EVENT).EVENT_ID        AS EVENT_ID,                             -- Target event identifier 
       r.PRIORITY,                   -- Priority value (1..9)
       r.NOTE,                         -- Optional note or description
       r.CREATED_AT,              -- Timestamp of request creation
       r.STATUS                       -- Request status ('PENDING','APPROVED','REJECTED')
FROM REQUESTS R

-- Order results by request ID for clarity
ORDER BY r.REQUEST_ID;            


CREATE TYPE TICKET_LIST_TYPE AS TABLE OF TICKET; 
    -- Define a collection type TICKET_LIST_TYPE as a table of 
    -- TICKET objects, allowing multiple tickets to be stored 
    -- within a single order or season pass record.
/


CREATE OR REPLACE TYPE TICKET_ORDER AS OBJECT (
    -- Define the TICKET_ORDER object type, representing a customer's order. 
    -- Each order includes a unique order ID, a collection of tickets, and a 
    -- reference to the customer who placed the order. 
    -- The type also defines methods for calculating total price, viewing 
    -- ticket details, and adding new orders.

    ORDER_ID      CHAR(9),              -- Unique identifier for the order
    TICKET_LIST   TICKET_LIST_TYPE,     -- Nested table of TICKET objects
    REF_CUSTOMER  REF PERSON,           -- Reference to the customer placing the order

    -- MAP method to calculate the total price of all tickets in the order
    MAP MEMBER FUNCTION GET_TOTAL_PRICE RETURN NUMBER,

    -- Function returning a SYS_REFCURSOR to view all tickets in the order
    MEMBER FUNCTION VIEW_TICKETS RETURN SYS_REFCURSOR,

    -- Static procedure to add a new order for a customer
    STATIC PROCEDURE ADD_ORDER(
        P_CUSTOMER_ID IN CHAR,          -- Customer identifier
        P_EVENT_ID    IN CHAR,          -- Target event identifier
        P_TICKET_QTY  IN NUMBER DEFAULT 1 -- Number of tickets to include
    )
);
/


CREATE TABLE ORDERS OF TICKET_ORDER (
    -- Create the ORDERS table based on the TICKET_ORDER object type.
    -- This table stores all customer orders, each linked to a specific
    -- customer and containing a nested table of TICKET objects.

    ORDER_ID PRIMARY KEY                -- Primary key to ensure unique orders
)
NESTED TABLE TICKET_LIST STORE AS TICKETS;  
    -- Store the nested table of TICKET_LIST for each order in a separate
    -- storage table named TICKETS.
/


CREATE OR REPLACE TRIGGER TRG_VALIDATE_ORDER_TICKETS
BEFORE INSERT OR UPDATE ON ORDERS
FOR EACH ROW
DECLARE
    v_cnt INTEGER := 0;  -- Counter for validation check
BEGIN
    -- TRIGGER PURPOSE
    -- Validates ticket ownership consistency before inserting or updating an order in the ORDERS table.
  
    -- Description:
    -- This trigger ensures that all TICKET objects included in the nested
    -- TICKET_LIST belong to the same customer referenced by REF_CUSTOMER
    -- in the order. This enforces data integrity and prevents mismatched customer-to-ticket relationships.


    -- Validate only when the nested list of tickets is not empty.
    IF :NEW.TICKET_LIST IS NOT NULL THEN

        -- Count tickets whose REF_CUSTOMER does not match the order's REF_CUSTOMER. 
        -- Counts how many tickets in the list belong to a different customer.
        SELECT COUNT(*)
          INTO v_cnt
          FROM TABLE(:NEW.TICKET_LIST) t
         WHERE t.REF_CUSTOMER != :NEW.REF_CUSTOMER;

        -- If mismatch found, raise error and stop the transaction. If such tickets exist, raises an application error (-20060)
        --     to prevent the operation from completing.
        IF v_cnt > 0 THEN
            RAISE_APPLICATION_ERROR(
                -20060,
                'All tickets in an order must belong to the same customer as the order.'
            );
        END IF;
    END IF;
END;
/


CREATE OR REPLACE TYPE BODY TICKET_ORDER AS 

    -- MAP MEMBER FUNCTION GET_TOTAL_PRICE
    -- Calculates the total price of all tickets included in this order.
    -- This method iterates through all tickets stored in the nested table
    -- TICKET_LIST and sums up their individual prices returned by the
    -- GET_PRICE_FOR_TICKET() method of the TICKET object.
    -- If the list is empty, the function returns 0.

    MAP MEMBER FUNCTION GET_TOTAL_PRICE RETURN NUMBER IS
        v_sum NUMBER := 0;  -- Variable to store the accumulated total price
    BEGIN
        -- Check if the nested ticket list is not null, then compute the total.
        IF SELF.TICKET_LIST IS NOT NULL THEN
            SELECT NVL(SUM(t.GET_PRICE_FOR_TICKET()), 0)
              INTO v_sum
              FROM TABLE(SELF.TICKET_LIST) t;
        END IF;

        RETURN v_sum;  -- Return the total ticket price for this order
    END GET_TOTAL_PRICE;



    -- MEMBER FUNCTION VIEW_TICKETS
    -- Returns a SYS_REFCURSOR containing detailed information about all tickets in this order.
    -- This method opens a cursor over the nested table TICKET_LIST,
    -- retrieving each ticket’s identifier, linked customer, event, and seat
    -- references, as well as the calculated ticket price.

    MEMBER FUNCTION VIEW_TICKETS RETURN SYS_REFCURSOR IS
        c SYS_REFCURSOR;  -- Cursor to store the list of tickets
    BEGIN
        OPEN c FOR
            SELECT 
                t.TICKET_ID,                                      -- Ticket identifier
                DEREF(t.REF_CUSTOMER).PERSONAL_ID AS CUSTOMER_ID, -- Customer personal ID
                DEREF(t.REF_EVENT).EVENT_ID       AS EVENT_ID,    -- Event identifier
                DEREF(t.REF_SEAT).SEAT_ID         AS SEAT_ID,     -- Seat identifier
                t.GET_PRICE_FOR_TICKET()          AS PRICE        -- Ticket price
            FROM TABLE(SELF.TICKET_LIST) t;

        RETURN c;  -- Return the cursor containing ticket details
    END VIEW_TICKETS;



    -- STATIC PROCEDURE ADD_ORDER
    -- Creates and inserts a new order record into the ORDERS table.
    -- This procedure generates a new order ID, constructs a nested table
    -- of tickets, and associates it with the specified customer and event.

    STATIC PROCEDURE ADD_ORDER(
        p_customer_id IN CHAR,  --  Identifier of the customer placing the order.
        p_event_id    IN CHAR,     -- Identifier of the event to attend.
        p_ticket_qty  IN NUMBER DEFAULT 1  -- Number of tickets (default = 1).
    ) IS
        v_cust REF PERSON;                -- REF to the customer in PEOPLE
        v_event REF EVENT;                -- REF to the target event in EVENTS
        v_seat  REF SEAT;                 -- REF to the assigned seat in SEATS
        v_ticket_list TICKET_LIST_TYPE := TICKET_LIST_TYPE(); -- Nested table for tickets
        v_new_order_id CHAR(9);           -- Auto-generated order ID
    BEGIN
        -- Retrieve REFs for customer, event, and seat.
        SELECT REF(p) INTO v_cust FROM PEOPLE p WHERE p.PERSONAL_ID = p_customer_id;
        SELECT REF(e) INTO v_event FROM EVENTS e WHERE e.EVENT_ID = p_event_id;
        SELECT REF(s) INTO v_seat  FROM SEATS  s WHERE s.SEAT_ID = 'A1001';  -- Sample seat reference

        -- Generate new order ID (9-digit, zero-padded).
        SELECT LPAD(NVL(MAX(TO_NUMBER(ORDER_ID)), 0) + 1, 9, '0')
          INTO v_new_order_id
          FROM ORDERS;

        -- Create tickets and append them to the nested table.
        FOR i IN 1 .. p_ticket_qty LOOP
            v_ticket_list.EXTEND;
            v_ticket_list(i) := TICKET(
                'T' || LPAD(i, 5, '0'),  -- Ticket ID format
                v_cust,                  -- REF to customer
                v_event,                 -- REF to event
                v_seat                   -- REF to seat
            );
        END LOOP;

        -- Insert new order record into the ORDERS table.
        INSERT INTO ORDERS VALUES (
            TICKET_ORDER(v_new_order_id, v_ticket_list, v_cust)
        );

        DBMS_OUTPUT.PUT_LINE('Order ' || v_new_order_id || ' added successfully.');
    END ADD_ORDER;

END;
/


DECLARE
    -- TEST BLOCK: INSERT ORDER (There are 3 tickets for Ilaha's order in that time)
    -- This block is designed to verify the correct behavior
    -- of the TICKET_ORDER object type. It demonstrates how to create REFs
    -- for customers, events, and seats, populate a nested table of tickets,
    -- and insert a complete order into the ORDERS table.


    v_cust  REF PERSON;                        -- REF to the customer
    v_e1    REF EVENT;  v_e2 REF EVENT;  v_e3 REF EVENT;  -- REFs to events
    v_s1    REF SEAT;   v_s2 REF SEAT;   v_s3 REF SEAT;   -- REFs to seats
    v_list  TICKET_LIST_TYPE := TICKET_LIST_TYPE();       -- Nested table for tickets
    v_orderid CHAR(9);           -- Order ID
BEGIN
    -- Retrieve REFs for the customer, events, and seats. [Retrieves REFs for a specific customer (PERSON), several events,
    -- and seats from their respective object tables].

    SELECT REF(p) INTO v_cust FROM PEOPLE p WHERE p.PERSONAL_ID = 'P0001';
    SELECT REF(e) INTO v_e1  FROM EVENTS e WHERE e.EVENT_ID = 'SE01';
    SELECT REF(e) INTO v_e2  FROM EVENTS e WHERE e.EVENT_ID = 'OE01';
    SELECT REF(e) INTO v_e3  FROM EVENTS e WHERE e.EVENT_ID = 'SE02';
    SELECT REF(s) INTO v_s1  FROM SEATS  s WHERE s.SEAT_ID = 'A1001';
    SELECT REF(s) INTO v_s2  FROM SEATS  s WHERE s.SEAT_ID = 'B2001';
    SELECT REF(s) INTO v_s3  FROM SEATS  s WHERE s.SEAT_ID = 'C3001';


    -- Create TICKET objects,appends them to the TICKET_LIST, and populate the nested TICKET_LIST.
    v_list.EXTEND;  v_list(1) := TICKET('TKT001', v_cust, v_e1, v_s1);
    v_list.EXTEND;  v_list(2) := TICKET('TKT002', v_cust, v_e2, v_s2);
    v_list.EXTEND;  v_list(3) := TICKET('TKT003', v_cust, v_e3, v_s3);


    -- Insert the new TICKET_ORDER record into the ORDERS table.
    -- Constructs a TICKET_ORDER object with a generated order ID,
    --  the prepared TICKET_LIST, and the customer reference.
    SELECT LPAD(NVL(MAX(TO_NUMBER(order_id)), 0) + 1, 9, '0')
    INTO v_orderid
    FROM ORDERS;

    INSERT INTO ORDERS VALUES (
        TICKET_ORDER(v_orderid, v_list, v_cust)
    );

    -- Commit all changes to finalize the insertion.
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Order ' || v_orderid || ' inserted successfully.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Raised if any of the REFs (customer, event, or seat) could not be found.
        DBMS_OUTPUT.PUT_LINE('Error: Missing reference data for customer, event, or seat.');
    WHEN OTHERS THEN
        -- Catch-all for unexpected errors during the order creation process.
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;
/


DECLARE
    -- TEST BLOCK: INSERT A NEW TICKET INTO EXISTING ORDER OR NOT, CREATING NEW ORDER
    -- This case: Add one more ticket for Ilaha's existing order
    -- This block demonstrates how to add a new ticket
    -- (TKT004) to an existing order belonging to a specific customer.

    v_cust    REF PERSON;       -- REF to the customer (PERSON)
    v_ev      REF EVENT;        -- REF to the target event
    v_seat    REF SEAT;         -- REF to the selected seat
    v_orderid CHAR(9);          -- Identifier of the order (existing or newly created)

BEGIN
    -- Retrieve REF for the customer (PERSONAL_ID = 'P0001').

    SELECT REF(p)
      INTO v_cust
      FROM PEOPLE p
     WHERE p.PERSONAL_ID = 'P0001';


    -- Retrieve or create an order for the customer if none exists.
    -- Checks if the customer already has an order:
    --        - If yes, reuses that order.
    --        - If no, creates a new TICKET_ORDER object and inserts it into ORDERS.

    BEGIN
        -- Try to find an existing order for the given customer.
        SELECT ORDER_ID
          INTO v_orderid
          FROM ORDERS
         WHERE REF_CUSTOMER = v_cust
         FETCH FIRST 1 ROWS ONLY;  -- If found, reuse the same order.
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Create a new order if the customer has none.
            SELECT LPAD(NVL(MAX(TO_NUMBER(ORDER_ID)), 0) + 1, 9, '0')
              INTO v_orderid
              FROM ORDERS;

            INSERT INTO ORDERS VALUES (
                TICKET_ORDER(v_orderid, TICKET_LIST_TYPE(), v_cust)
            );

            DBMS_OUTPUT.PUT_LINE('New order ' || v_orderid || ' created for customer P0001.');
    END;


    -- Retrieve REFs for the event and seat for the new ticket (TKT004).

    SELECT REF(e) INTO v_ev   FROM EVENTS e WHERE e.EVENT_ID = 'OE04';
    SELECT REF(s) INTO v_seat FROM SEATS  s WHERE s.SEAT_ID  = 'A1001';


    -- Insert the new ticket (TKT004) into the nested TICKET_LIST table.

    INSERT INTO TABLE(
        SELECT o.TICKET_LIST
          FROM ORDERS o
         WHERE o.ORDER_ID = v_orderid
    )
    VALUES (
        TICKET('TKT004', v_cust, v_ev, v_seat)
    );


    -- Finalize the transaction - commit the transaction.

    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Ticket TKT004 successfully added to order ' || v_orderid || '.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Raised if required references (customer, event, or seat) are missing.
        DBMS_OUTPUT.PUT_LINE('Error: Missing reference for customer, event, or seat.');
    WHEN OTHERS THEN
        -- Catch-all for unexpected errors.
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;
/


SELECT  
    -- This query retrieves detailed information from the ORDERS table,  
    -- including all tickets stored in the nested TICKET_LIST and their  
    -- related details such as customer name, event information, and seat data.  
    -- This case: Table has only one order from Ilaha

    O.ORDER_ID,                            -- Unique order identifier  
    T.TICKET_ID,                          -- Ticket identifier within the order

    -- Fetch the customer's full name by dereferencing REF_CUSTOMER    
    (SELECT P.NAME || ' ' || P.SURNAME  
       FROM PEOPLE P  
      WHERE REF(P) = T.REF_CUSTOMER) AS CUSTOMER_NAME, -- Customer's full name

    -- Fetch the event name linked to the ticket 
    (SELECT E.EVENT_NAME  
       FROM EVENTS E  
      WHERE REF(E) = T.REF_EVENT) AS EVENT_NAME,       -- Event name associated with the ticket  

    -- Identify event subtype: Sport or Other  
    CASE  
        WHEN (SELECT VALUE(E) FROM EVENTS E WHERE REF(E) = T.REF_EVENT) IS OF (SPORT_EVENT)  
            THEN 'Sport Event'  
        WHEN (SELECT VALUE(E) FROM EVENTS E WHERE REF(E) = T.REF_EVENT) IS OF (OTHERS)  
            THEN 'Other Event'  
    END AS EVENT_TYPE,                                 -- Type of the event (Sport/Other)  

    -- Retrieve seat details from SEATS table via REF  
    (SELECT S.SEAT_ID  
       FROM SEATS S  
      WHERE REF(S) = T.REF_SEAT) AS SEAT_ID,           -- Seat identifier  

    (SELECT S.SEAT_CATEGORY  
       FROM SEATS S  
      WHERE REF(S) = T.REF_SEAT) AS SEAT_CATEGORY,     -- Seat category (V/P/G)  

    -- Display formatted ticket price  
    TO_CHAR(T.GET_PRICE_FOR_TICKET(), '999.00') AS TICKET_PRICE  -- Formatted ticket price  

FROM ORDERS O,
TABLE(O.TICKET_LIST) T -- Un-nest the nested TICKET_LIST collection into individual ticket records.  
ORDER BY O.ORDER_ID, T.TICKET_ID;


DECLARE
    -- TEST BLOCK: VIEW_TICKETS FUNCTION
    -- This block tests the VIEW_TICKETS member function of the TICKET_ORDER object type. 
    -- It retrieves all tickets belonging to a specific order by opening a SYS_REFCURSOR
    --  and displaying each ticket’s details in a formatted output.


    C_TICKETS SYS_REFCURSOR;     -- Cursor returned by VIEW_TICKETS
    V_TID   CHAR(6);             -- Ticket ID
    V_CID   CHAR(5);             -- Customer ID
    V_EID   CHAR(4);             -- Event ID
    V_SID   CHAR(5);             -- Seat ID
    V_PRICE NUMBER;              -- Ticket price

BEGIN
    -- Open the cursor by calling the VIEW_TICKETS function on order '000000001'.
    SELECT O.VIEW_TICKETS()
      INTO C_TICKETS
      FROM ORDERS O
     WHERE O.ORDER_ID = '000000001';

    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('Ticket ID | Customer ID | Event ID | Seat ID | Ticket price');
    DBMS_OUTPUT.PUT_LINE('----------------------------------------');


    -- Fetches each ticket record from the returned cursor. 
    --     Display each ticket record about the ticket’s ID, customer ID, event ID, seat ID, and price.
    LOOP
        FETCH C_TICKETS INTO V_TID, V_CID, V_EID, V_SID, V_PRICE;
        EXIT WHEN C_TICKETS%NOTFOUND;

        DBMS_OUTPUT.PUT_LINE(V_TID || ' | ' || V_CID || ' | ' || V_EID || ' | ' || V_SID || ' | ' || V_PRICE);
    END LOOP;


    -- Close the cursor after processing all records. 
    CLOSE C_TICKETS;

    DBMS_OUTPUT.PUT_LINE('----------------------------------------');
    DBMS_OUTPUT.PUT_LINE('All tickets have been displayed.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Raised if the order is not found or contains no tickets.
        DBMS_OUTPUT.PUT_LINE('Error: Order not found or contains no tickets.');
    WHEN OTHERS THEN
        -- Catch-all for unexpected errors.
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;
/


CREATE OR REPLACE TYPE SEASON_PASS AS OBJECT (
    -- Define the SEASON_PASS object type to represent a reusable season pass.
    -- A pass may exist unassigned (inventory) and, once assigned, is linked
    -- to a specific customer via REF_CUSTOMER.

    PASS_ID      CHAR(4),                 -- Unique pass identifier (e.g., 'SV01','VIP1')
    PASS_LEVEL   VARCHAR2(100 CHAR),      -- Tier/level (e.g., Silver, Gold, VIP)
    VALID_FROM   DATE,                    -- Start of validity period (inclusive)
    VALID_TO     DATE,                    -- End of validity period (inclusive)
    REF_CUSTOMER REF PERSON               -- Owner reference; if it is NULL = unassigned
);
/


CREATE TABLE SEASON_PASSES OF SEASON_PASS (  
    -- Create the SEASON_PASSES table based on the SEASON_PASS object type.  
 
    PASS_ID PRIMARY KEY                  -- Primary key to ensure each pass is unique  
);  


CREATE OR REPLACE TYPE BODY CUSTOMER AS
    -- SUBSCRIBE function
    -- Create & assign a season pass to this customer.


    MEMBER PROCEDURE SUBSCRIBE(
        P_LEVEL      IN VARCHAR2,         -- Season pass tier/level (e.g., 'Silver','Gold','VIP')
        P_VALID_FROM IN DATE             -- Start date of validity window
    ) IS
        v_cust_ref  REF PERSON;    -- REF to PERSON that contains this CUSTOMER
        v_person_id CHAR(5);       -- Customer's PERSON.PERSONAL_ID for logging/auditing
        v_new_id    CHAR(4);       -- New generated PASS_ID
        v_to        DATE;          -- Computed VALID_TO

    BEGIN
        -- Locate containing PERSON row for CUSTOMER
        SELECT REF(p), p.personal_id
          INTO v_cust_ref, v_person_id
          FROM PEOPLE p
         WHERE p.CUSTOMER_DATA = SELF;

        -- Generate next PASS_ID (zero-padded 4 chars)
        SELECT LPAD(NVL(MAX(TO_NUMBER(sp.pass_id)), 0) + 1, 4, '0')
          INTO v_new_id
          FROM SEASON_PASSES sp;

        -- Compute validity window - VALID_TO = full 3 months starting at p_valid_from
        v_to := ADD_MONTHS(TRUNC(P_VALID_FROM), 3) - 1;

        -- Insert the assigned pass for customer
        INSERT INTO SEASON_PASSES
        VALUES (
            SEASON_PASS(
                v_new_id,           -- PASS_ID
                P_LEVEL,            -- PASS_LEVEL
                TRUNC(P_VALID_FROM),-- VALID_FROM (normalize to date)
                v_to,               -- VALID_TO
                v_cust_ref          -- REF_CUSTOMER (owner)
            )
        );

        DBMS_OUTPUT.PUT_LINE(
            'Season pass ' || v_new_id || ' ('||P_LEVEL||') for customer ' || v_person_id ||
            ' from ' || TO_CHAR(TRUNC(P_VALID_FROM),'YYYY-MM-DD') ||
            ' to '  || TO_CHAR(v_to,'YYYY-MM-DD')
        );
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Customer container PERSON row was not found
            DBMS_OUTPUT.PUT_LINE('Error: Customer not found in PEOPLE.');
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Error occurred: '||SQLERRM);
    END SUBSCRIBE;
END;
/


DECLARE
    -- This PL/SQL block tests the SUBSCRIBE procedure of the CUSTOMER object type.
    -- It creates new season passes for customers with IDs P0001 and P0003
    -- by calling their respective CUSTOMER_DATA.SUBSCRIBE method.
    -- This case is testing with SYSDATE

    -- Formula:
    --  Season pass for customer from <date> to <+3 months - 1 day>

    v_person1 PERSON;   -- Variable to hold the PERSON object for P0001
    v_person3 PERSON;   -- Variable to hold the PERSON object for P0003
BEGIN
    -- Retrieve PERSON with ID 'P0001'
    SELECT VALUE(p) INTO v_person1
    FROM PEOPLE p
    WHERE p.personal_id = 'P0001';

    -- Call SUBSCRIBE for Customer P0001 (e.g., SILVER level)
    v_person1.CUSTOMER_DATA.SUBSCRIBE('SILVER', SYSDATE);

    -- Retrieve PERSON with ID 'P0003'
    SELECT VALUE(p) INTO v_person3
    FROM PEOPLE p
    WHERE p.personal_id = 'P0003';

    -- Call SUBSCRIBE for Customer P0003 (e.g., GOLD level)
    v_person3.CUSTOMER_DATA.SUBSCRIBE('GOLD', SYSDATE);

    DBMS_OUTPUT.PUT_LINE('--- Subscription Test Completed ---');
END;
/


DECLARE
    -- This PL/SQL block tests the SUBSCRIBE procedure of the CUSTOMER object type.
    -- It creates new season passes for customers with IDs P0001 and P0003
    -- by calling their respective CUSTOMER_DATA.SUBSCRIBE method.
    -- This case is testing with specific date

    -- Formula:
    --  Season pass for customer from <date> to <+3 months - 1 day>

    v_person1 PERSON;   -- Variable to hold the PERSON object for P0001
    v_person3 PERSON;   -- Variable to hold the PERSON object for P0003
BEGIN
    -- Retrieve PERSON with ID 'P0001'
    SELECT VALUE(p) INTO v_person1
    FROM PEOPLE p
    WHERE p.personal_id = 'P0001';

    -- Call SUBSCRIBE for Customer P0001 (e.g., GOLD level)
    v_person1.CUSTOMER_DATA.SUBSCRIBE('GOLD', TO_DATE('2026-11-01', 'YYYY-MM-DD'));

    -- Retrieve PERSON with ID 'P0003'
    SELECT VALUE(p) INTO v_person3
    FROM PEOPLE p
    WHERE p.personal_id = 'P0003';

    -- Call SUBSCRIBE for Customer P0003 (e.g., VIP level)
    v_person3.CUSTOMER_DATA.SUBSCRIBE('VIP', TO_DATE('2024-11-01', 'YYYY-MM-DD'));

    DBMS_OUTPUT.PUT_LINE('--- Subscription Test Completed ---');
END;
/


SELECT
    -- This query retrieves detailed information about season passes,
    -- including their level, validity period, and the customer who owns them (if assigned).

    SP.PASS_ID,                                  -- Unique ID of the season pass
    SP.PASS_LEVEL,                               -- Tier of the pass (Silver, Gold, VIP)
    TO_CHAR(SP.VALID_FROM, 'YYYY-MM-DD') AS VALID_FROM,  -- Start date of validity
    TO_CHAR(SP.VALID_TO, 'YYYY-MM-DD')   AS VALID_TO,    -- End date of validity

    -- Retrieve customer name if assigned; otherwise show "Unasssigned"
    CASE
        WHEN SP.REF_CUSTOMER IS NOT NULL THEN
            (SELECT P.NAME || ' ' || P.SURNAME
             FROM PEOPLE P
             WHERE REF(P) = SP.REF_CUSTOMER)
        ELSE
            'Unassigned'
    END AS CUSTOMER_NAME

FROM
    SEASON_PASSES SP
ORDER BY
    SP.PASS_ID;


CREATE OR REPLACE TYPE BODY PERSON AS
    -- Complete body for the PERSON type with all functions: age calculation


    -- GET_AGE
    -- Function to calculate the age of the person by comparing the current date with the birth date 


    MEMBER FUNCTION GET_AGE RETURN NUMBER IS
        v_age NUMBER;  -- Calculated age in whole years
    BEGIN
    --   If DATE_OF_BIRTH is NULL → return NULL.
    --   Check if the person has already had their birthday this year. 
    --   If birthday has occurred this year -> calculate the age as the difference in years: year(SYSDATE) - year(DATE_OF_BIRTH)
    --   Else -> subtract one year to account for the upcoming birthday. 

        -- Handle missing birth date safely
        IF DATE_OF_BIRTH IS NULL THEN
            RETURN NULL;
        END IF;

        -- Compare month-day to determine if the birthday has passed this year
        IF TO_CHAR(SYSDATE, 'MMDD') >= TO_CHAR(DATE_OF_BIRTH, 'MMDD') THEN
            -- Birthday has occurred this year, so use the direct year difference
            v_age := EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM DATE_OF_BIRTH);
        ELSE
            -- Birthday hasn't occurred yet this year; subtract one year 
            v_age := EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM DATE_OF_BIRTH) - 1;
        END IF;

        RETURN v_age;      -- Return the calculated age 
    END GET_AGE;
END;
/


SELECT 
    -- Test the function GET_AGE() to verify it calculates 
    -- each person's age in full years based on DATE_OF_BIRTH. 
     
    P.PERSONAL_ID,                         -- Unique personal identifier  
    P.NAME,                                -- Person's first name  
    P.SURNAME,                             -- Person's last name  
    P.DATE_OF_BIRTH,                       -- Date of birth of the person  
    P.GET_AGE() AS AGE_YEARS               -- Calculated age in full years 

FROM PEOPLE P 
ORDER BY P.PERSONAL_ID;


CREATE OR REPLACE TYPE BODY EVENT AS

    -- GET_DESCRIPTION
    -- Provides a general description for any event (default implementation).
    -- Subtypes like SPORT_EVENT and OTHERS override this to provide their own specialized details.


    MEMBER FUNCTION GET_DESCRIPTION RETURN VARCHAR2 IS
    BEGIN
        RETURN 'General Event: ' || SELF.EVENT_NAME ||
               ' on ' || TO_CHAR(SELF.EVENT_TIME, 'DD-MON-YYYY HH24:MI');
    END GET_DESCRIPTION;

END;
/


SELECT 
    -- Select statement to display each event's name and its description 
    -- This query will output customized descriptions based on the event type 

    E.EVENT_NAME AS Event_Name, 
    E.GET_DESCRIPTION() AS Description 

FROM EVENTS E;


DECLARE
    -- TEST BLOCK: INSERT A NEW TICKET INTO EXISTING ORDER OR NOT, CREATING NEW ORDER
    -- This block demonstrates how to add a new ticket
    -- (TKT005) to an existing order belonging to a specific customer.
    -- This case is adding new ticket for non-existing order -> so it has to create new order (specifically for Anh - different customer)
    

    v_cust    REF PERSON;       -- REF to the customer (PERSON)
    v_ev      REF EVENT;        -- REF to the target event
    v_seat    REF SEAT;         -- REF to the selected seat
    v_orderid CHAR(9);          -- Identifier of the order (existing or newly created)

BEGIN
    -- Retrieve REF for the customer (PERSONAL_ID = 'P0003').

    SELECT REF(p)
      INTO v_cust
      FROM PEOPLE p
     WHERE p.PERSONAL_ID = 'P0003';


    -- Retrieve or create an order for the customer if none exists. 
    -- Checks if the customer already has an order: 
    --        - If yes, reuses that order. 
    --        - If no, creates a new TICKET_ORDER object and inserts it into ORDERS. 
    BEGIN
        -- Try to find an existing order for the given customer.
        SELECT ORDER_ID
          INTO v_orderid
          FROM ORDERS
         WHERE REF_CUSTOMER = v_cust
         FETCH FIRST 1 ROWS ONLY;  -- If found, reuse the same order.
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            -- Create a new order if the customer has none.
            SELECT LPAD(NVL(MAX(TO_NUMBER(ORDER_ID)), 0) + 1, 9, '0')
              INTO v_orderid
              FROM ORDERS;

            INSERT INTO ORDERS VALUES (
                TICKET_ORDER(v_orderid, TICKET_LIST_TYPE(), v_cust)
            );

            DBMS_OUTPUT.PUT_LINE('New order ' || v_orderid || ' created for customer P0003.');
    END;


    -- Retrieve REFs for the event and seat for the new ticket (TKT005). 
    SELECT REF(e) INTO v_ev   FROM EVENTS e WHERE e.EVENT_ID = 'SE03';
    SELECT REF(s) INTO v_seat FROM SEATS  s WHERE s.SEAT_ID  = 'C1002';


    -- Insert the new ticket (TKT005) into the nested TICKET_LIST table. 
    INSERT INTO TABLE(
        SELECT o.TICKET_LIST
          FROM ORDERS o
         WHERE o.ORDER_ID = v_orderid
    )
    VALUES (
        TICKET('TKT005', v_cust, v_ev, v_seat)
    );


    -- Finalize the transaction - commit the transaction. 
    COMMIT;

    DBMS_OUTPUT.PUT_LINE('Ticket TKT005 successfully added to order ' || v_orderid || '.');

EXCEPTION
    WHEN NO_DATA_FOUND THEN
        -- Raised if required references (customer, event, or seat) are missing.
        DBMS_OUTPUT.PUT_LINE('Error: Missing reference for customer, event, or seat.');
    WHEN OTHERS THEN
        -- Catch-all for unexpected errors.
        DBMS_OUTPUT.PUT_LINE('Error occurred: ' || SQLERRM);
END;
/


SELECT  
    -- This query retrieves detailed information from the ORDERS table,  
    -- including all tickets stored in the nested TICKET_LIST and their  
    -- related details such as customer name, event information, and seat data.  

    O.ORDER_ID,                            -- Unique order identifier  
    T.TICKET_ID,                          -- Ticket identifier within the order

    -- Fetch the customer's full name by dereferencing REF_CUSTOMER    
    (SELECT P.NAME || ' ' || P.SURNAME  
       FROM PEOPLE P  
      WHERE REF(P) = T.REF_CUSTOMER) AS CUSTOMER_NAME, -- Customer's full name

    -- Fetch the event name linked to the ticket 
    (SELECT E.EVENT_NAME  
       FROM EVENTS E  
      WHERE REF(E) = T.REF_EVENT) AS EVENT_NAME,       -- Event name associated with the ticket  

    -- Identify event subtype: Sport or Other  
    CASE  
        WHEN (SELECT VALUE(E) FROM EVENTS E WHERE REF(E) = T.REF_EVENT) IS OF (SPORT_EVENT)  
            THEN 'Sport Event'  
        WHEN (SELECT VALUE(E) FROM EVENTS E WHERE REF(E) = T.REF_EVENT) IS OF (OTHERS)  
            THEN 'Other Event'  
    END AS EVENT_TYPE,                                 -- Type of the event (Sport/Other)  

    -- Retrieve seat details from SEATS table via REF  
    (SELECT S.SEAT_ID  
       FROM SEATS S  
      WHERE REF(S) = T.REF_SEAT) AS SEAT_ID,           -- Seat identifier  

    (SELECT S.SEAT_CATEGORY  
       FROM SEATS S  
      WHERE REF(S) = T.REF_SEAT) AS SEAT_CATEGORY,     -- Seat category (V/P/G)  

    -- Display formatted ticket price  
    TO_CHAR(T.GET_PRICE_FOR_TICKET(), '999.00') AS TICKET_PRICE  -- Formatted ticket price  

FROM ORDERS O,
TABLE(O.TICKET_LIST) T  -- Un-nest the nested TICKET_LIST collection into individual ticket records.   
ORDER BY O.ORDER_ID, T.TICKET_ID;


DECLARE
    -- TEST BLOCK: MAP method TICKET_ORDER.GET_TOTAL_PRICE
    --   Build two in-memory TICKET_ORDER objects with real REFs taken from
    --   PEOPLE / EVENTS / SEATS, print their totals, then compare them using
    --   relational operators (<, >, =) which internally invoke the MAP method.


    -- Customer REFs
    r_ref_customer_ilaha   REF PERSON;
    r_ref_customer_anh     REF PERSON;

    -- Event REFs (Sport/Others)
    r_ref_event_se01   REF EVENT;  -- Basketball (Sport; VIP in event)
    r_ref_event_oe01   REF EVENT;  -- Rock Concert (Others; sector price 100)
    r_ref_event_se02   REF EVENT;  -- Football (Sport; Premium in event)
    r_ref_event_oe04   REF EVENT;  -- Jazz Night (Others; sector price 120)
    r_ref_event_se03   REF EVENT;  -- Tennis (Sport; General in event)

    -- Seat REFs
    r_ref_seat_vip     REF SEAT;   -- A1001 
    r_ref_seat_premium REF SEAT;   -- B2001
    r_ref_seat_general REF SEAT;   -- C3001

    -- Two orders built as objects for MAP comparison
    order1 TICKET_ORDER;
    order2 TICKET_ORDER;

BEGIN
    -- Fetch all required REFs from existing object tables
    SELECT REF(p) INTO r_ref_customer_ilaha FROM PEOPLE p WHERE p.PERSONAL_ID = 'P0001'; 
    SELECT REF(p) INTO r_ref_customer_anh   FROM PEOPLE p WHERE p.PERSONAL_ID = 'P0003';

    SELECT REF(e) INTO r_ref_event_se01 FROM EVENTS e WHERE e.EVENT_ID = 'SE01';
    SELECT REF(e) INTO r_ref_event_oe01 FROM EVENTS e WHERE e.EVENT_ID = 'OE01';
    SELECT REF(e) INTO r_ref_event_se02 FROM EVENTS e WHERE e.EVENT_ID = 'SE02';
    SELECT REF(e) INTO r_ref_event_oe04 FROM EVENTS e WHERE e.EVENT_ID = 'OE04';
    SELECT REF(e) INTO r_ref_event_se03 FROM EVENTS e WHERE e.EVENT_ID = 'SE03';

    SELECT REF(s) INTO r_ref_seat_vip     FROM SEATS s WHERE s.SEAT_ID = 'A1001';
    SELECT REF(s) INTO r_ref_seat_premium FROM SEATS s WHERE s.SEAT_ID = 'B2001';
    SELECT REF(s) INTO r_ref_seat_general FROM SEATS s WHERE s.SEAT_ID = 'C3001';


    -- Construct two TICKET_ORDER objects with real REFs and nested tickets
   
    -- Order1: Ilaha Habibova’s order (expected total ≈ 319 EUR)
    --   Contains four tickets corresponding to events stored in the database:
    --     • T001 → SE01 (Basketball Championship, Sport, VIP seat A1001) → 45 EUR
    --     • T002 → OE01 (Rock Concert, Others, Premium seat B2001)       → 100 EUR
    --     • T003 → SE02 (Football Match, Sport, General seat C3001)      → 54 EUR
    --     • T004 → OE04 (Jazz Night, Others, VIP seat A1001)             → 120 EUR
    --
    --   => Expected total: 45 + 100 + 54 + 120 = 319 EUR


    order1 := TICKET_ORDER(
        '000000001',
        TICKET_LIST_TYPE(
            TICKET('TKT001', r_ref_customer_ilaha, r_ref_event_se01, r_ref_seat_vip),
            TICKET('TKT002', r_ref_customer_ilaha, r_ref_event_oe01, r_ref_seat_premium),
            TICKET('TKT003', r_ref_customer_ilaha, r_ref_event_se02, r_ref_seat_general),
            TICKET('TKT004', r_ref_customer_ilaha, r_ref_event_oe04, r_ref_seat_vip)
        ),
        r_ref_customer_ilaha
    );


    -- Order2: Anh Pham’s order (expected total ≈ 60 EUR)
    --   Contains a single ticket:
    --     TKT005 → SE03 (Tennis Tournament, Sport, General seat C3001) → 60 EUR
    --   => Expected total: 60 EUR

    order2 := TICKET_ORDER(
        '000000002',
        TICKET_LIST_TYPE(
            TICKET('T005', r_ref_customer_anh, r_ref_event_se03, r_ref_seat_general)
        ),
        r_ref_customer_anh
    );


    -- Print totals via MAP method and compare order objects
    DBMS_OUTPUT.PUT_LINE('Total Price of Order 1 = ' || order1.GET_TOTAL_PRICE);
    DBMS_OUTPUT.PUT_LINE('Total Price of Order 2 = ' || order2.GET_TOTAL_PRICE);

    IF order1 < order2 THEN
        DBMS_OUTPUT.PUT_LINE('Order1 < Order2 (Total Price of Order 1 is smaller than Total Price of Order 2).');
    ELSIF order1 > order2 THEN
        DBMS_OUTPUT.PUT_LINE('Order1 > Order2 (Total Price of Order 1  is greater than Total Price of Order 2).');
    ELSE
        DBMS_OUTPUT.PUT_LINE('Order 1 = Order 2 (Total Price of them are equal).');
    END IF;
END;
/


BEGIN
    -- TEST BLOCK: STATIC PROCEDURE ADD_ORDER
    -- This block is intended to demonstrate and verify the functionality of
    -- the static procedure ADD_ORDER() defined in the TICKET_ORDER object type.

    -- The procedure is executed several times with different customers and
    -- event identifiers to ensure correct insertion of new orders into
    -- the ORDERS object table, along with their associated ticket data.

    -- Expected outcome:
    --   - Two new orders are inserted successfully.
    --   - Each order corresponds to a unique customer and event combination.

    -- Add an order for customer P0005 with 2 tickets for Arena Open Day (GE01)
    TICKET_ORDER.ADD_ORDER('P0005', 'GE01', 1);

    -- Add an order for customer P0006 with 1 ticket for Summer Festival (OE03)
    TICKET_ORDER.ADD_ORDER('P0006', 'OE03', 1);

    -- Display confirmation message in the console
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
    DBMS_OUTPUT.PUT_LINE('All orders were added successfully using the');
    DBMS_OUTPUT.PUT_LINE('static procedure ADD_ORDER().');
    DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
END;
/


SELECT   
    -- This query retrieves detailed information from the ORDERS table,   
    -- including all tickets stored in the nested TICKET_LIST and their   
    -- related details such as customer name, event information, and seat data.   
 
    O.ORDER_ID,                            -- Unique order identifier   
    T.TICKET_ID,                          -- Ticket identifier within the order 
 
    -- Fetch the customer's full name by dereferencing REF_CUSTOMER     
    (SELECT P.NAME || ' ' || P.SURNAME   
       FROM PEOPLE P   
      WHERE REF(P) = T.REF_CUSTOMER) AS CUSTOMER_NAME, -- Customer's full name 
 
    -- Fetch the event name linked to the ticket  
    (SELECT E.EVENT_NAME   
       FROM EVENTS E   
      WHERE REF(E) = T.REF_EVENT) AS EVENT_NAME,       -- Event name associated with the ticket   
 
    -- Identify event subtype: Sport or Other   
    CASE   
        WHEN (SELECT VALUE(E) FROM EVENTS E WHERE REF(E) = T.REF_EVENT) IS OF (SPORT_EVENT)   
            THEN 'Sport Event'   
        WHEN (SELECT VALUE(E) FROM EVENTS E WHERE REF(E) = T.REF_EVENT) IS OF (OTHERS)   
            THEN 'Other Event'   
    END AS EVENT_TYPE,                                 -- Type of the event (Sport/Other)   
 
 
    (SELECT S.SEAT_CATEGORY   
       FROM SEATS S   
      WHERE REF(S) = T.REF_SEAT) AS SEAT_CATEGORY,     -- Seat category (V/P/G)   
 
    -- Display formatted ticket price   
    TO_CHAR(T.GET_PRICE_FOR_TICKET(), '999.00') AS TICKET_PRICE  -- Formatted ticket price   
 
FROM ORDERS O,  
TABLE(O.TICKET_LIST) T  -- Un-nest the nested TICKET_LIST collection into individual ticket records.  
ORDER BY O.ORDER_ID, T.TICKET_ID



