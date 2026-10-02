CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    RegistrationDate DATE
);
CREATE TABLE Drivers (
    DriverID INT PRIMARY KEY,
    Name VARCHAR(100),
    JoinDate DATE
);
CREATE TABLE Cabs (
    CabID INT PRIMARY KEY,
    DriverID INT,
    VehicleType VARCHAR(20),
    PlateNumber VARCHAR(20),
    FOREIGN KEY (DriverID) REFERENCES Drivers(DriverID)
);
CREATE TABLE Bookings (
    BookingID INT PRIMARY KEY,
    CustomerID INT,
    CabID INT,
    BookingDate DATETIME,
    Status VARCHAR(20),
    PickupLocation VARCHAR(100),
    DropoffLocation VARCHAR(100),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (CabID) REFERENCES Cabs(CabID)
);
CREATE TABLE TripDetails (
    TripID INT PRIMARY KEY,
    BookingID INT,
    StartTime DATETIME,
    EndTime DATETIME,
    DistanceKM FLOAT,
    Fare FLOAT,
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);
CREATE TABLE Feedback (
    FeedbackID INT PRIMARY KEY,
    BookingID INT,
    Rating FLOAT,
    Comments TEXT,
    FeedbackDate DATE,
    FOREIGN KEY (BookingID) REFERENCES Bookings(BookingID)
);
INSERT INTO Customers
(CustomerID, Name, Email, RegistrationDate)
VALUES
(1, 'Alice Johnson', 'alice@example.com', '2023-01-15'),
(2, 'Bob Smith', 'bob@example.com', '2023-02-20'),
(3, 'Charlie Brown', 'charlie@example.com', '2023-03-05'),
(4, 'Diana Prince', 'diana@example.com', '2023-04-10');
INSERT INTO Drivers
(DriverID, Name, JoinDate)
VALUES
(101, 'John Driver', '2022-05-10'),
(102, 'Linda Miles', '2022-07-25'),
(103, 'Kevin Road', '2023-01-01'),
(104, 'Sandra Swift', '2022-11-11');
INSERT INTO Cabs
(CabID, DriverID, VehicleType, PlateNumber)
VALUES
(1001, 101, 'Sedan', 'ABC1234'),
(1002, 102, 'SUV', 'XYZ5678'),
(1003, 103, 'Sedan', 'LMN8901'),
(1004, 104, 'SUV', 'PQR3456');
INSERT INTO Bookings
(BookingID, CustomerID, CabID, BookingDate, Status, PickupLocation, DropoffLocation)
VALUES
(201, 1, 1001, '2024-10-01 08:30:00', 'Completed', 'Downtown', 'Airport'),
(202, 2, 1002, '2024-10-02 09:00:00', 'Completed', 'Mall', 'University'),
(203, 3, 1003, '2024-10-03 10:15:00', 'Canceled', 'Station', 'Downtown'),
(204, 4, 1004, '2024-10-04 14:00:00', 'Completed', 'Suburbs', 'Downtown'),
(205, 1, 1002, '2024-10-05 18:45:00', 'Completed', 'Downtown', 'Airport'),
(206, 2, 1001, '2024-10-06 07:20:00', 'Canceled', 'University', 'Mall');
INSERT INTO TripDetails
(TripID, BookingID, StartTime, EndTime, DistanceKM, Fare)
VALUES
(301, 201, '2024-10-01 08:45:00', '2024-10-01 09:20:00', 18.5, 250.00),
(302, 202, '2024-10-02 09:10:00', '2024-10-02 09:40:00', 12.0, 180.00),
(303, 204, '2024-10-04 14:10:00', '2024-10-04 14:40:00', 10.0, 150.00),
(304, 205, '2024-10-05 18:50:00', '2024-10-05 19:30:00', 20.0, 270.00);
INSERT INTO Feedback
(FeedbackID, BookingID, Rating, Comments, FeedbackDate)
VALUES
(401, 201, 4.5, 'Smooth ride', '2024-10-01'),
(402, 202, 3.0, 'Driver was late', '2024-10-02'),
(403, 204, 5.0, 'Excellent service', '2024-10-04'),
(404, 205, 2.5, 'Cab was not clean', '2024-10-05');
SELECT 
    c.CustomerID,
    c.Name,
    COUNT(*) AS CompletedBookings
FROM Customers c
JOIN Bookings b 
    ON c.CustomerID = b.CustomerID
WHERE b.Status = 'Completed'
GROUP BY c.CustomerID, c.Name
ORDER BY CompletedBookings DESC;
SELECT
    CustomerID,
    SUM(CASE WHEN Status = 'Canceled' THEN 1 ELSE 0 END) AS Cancelled,
    COUNT(*) AS Total,
    ROUND(
        100.0 * SUM(CASE WHEN Status = 'Canceled' THEN 1 ELSE 0 END) / COUNT(*),
        2
    ) AS CancellationRate
FROM Bookings
GROUP BY CustomerID
HAVING CancellationRate > 30;
SELECT
    DATE_FORMAT(BookingDate, '%W') AS DayOfWeek,
    COUNT(*) AS TotalBookings
FROM Bookings
GROUP BY DATE_FORMAT(BookingDate, '%W')
ORDER BY TotalBookings DESC;
SELECT
    d.DriverID,
    d.Name,
    AVG(f.Rating) AS AvgRating
FROM Drivers d
JOIN Cabs c ON d.DriverID = c.DriverID
JOIN Bookings b ON c.CabID = b.CabID
JOIN Feedback f ON b.BookingID = f.BookingID
WHERE f.Rating IS NOT NULL
GROUP BY d.DriverID, d.Name
HAVING AVG(f.Rating) < 3.0;
SELECT
    d.DriverID,
    d.Name,
    SUM(t.DistanceKM) AS TotalDistance
FROM Drivers d
JOIN Cabs c ON d.DriverID = c.DriverID
JOIN Bookings b ON c.CabID = b.CabID
JOIN TripDetails t ON b.BookingID = t.BookingID
WHERE b.Status = 'Completed'
GROUP BY d.DriverID, d.Name
ORDER BY TotalDistance DESC
LIMIT 5;
SELECT
    d.DriverID,
    d.Name,
    ROUND(
        100.0 * SUM(CASE WHEN b.Status = 'Canceled' THEN 1 ELSE 0 END)
        / COUNT(*),
        2
    ) AS CancellationRate
FROM Drivers d
JOIN Cabs c ON d.DriverID = c.DriverID
JOIN Bookings b ON c.CabID = b.CabID
GROUP BY d.DriverID, d.Name
HAVING CancellationRate > 25;
SELECT
    DATE_FORMAT(t.EndTime, '%Y-%m') AS Month,
    SUM(t.Fare) AS Revenue
FROM TripDetails t
JOIN Bookings b
    ON t.BookingID = b.BookingID
WHERE b.Status = 'Completed'
GROUP BY DATE_FORMAT(t.EndTime, '%Y-%m')
ORDER BY Month;
SELECT
    CONCAT(PickupLocation, ' → ', DropoffLocation) AS Route,
    COUNT(*) AS TotalBookings
FROM Bookings
GROUP BY PickupLocation, DropoffLocation
ORDER BY TotalBookings DESC
LIMIT 3;
SELECT
    d.DriverID,
    d.Name,
    AVG(f.Rating) AS AvgRating,
    COUNT(t.TripID) AS TotalTrips,
    SUM(t.Fare) AS TotalEarnings
FROM Drivers d
JOIN Cabs c
    ON d.DriverID = c.DriverID
JOIN Bookings b
    ON c.CabID = b.CabID
JOIN Feedback f
    ON b.BookingID = f.BookingID
JOIN TripDetails t
    ON b.BookingID = t.BookingID
GROUP BY d.DriverID, d.Name
ORDER BY AvgRating DESC;
SELECT
    b.PickupLocation,
    AVG(
        TIMESTAMPDIFF(MINUTE, b.BookingDate, t.StartTime)
    ) AS AvgWaitTimeMins
FROM Bookings b
JOIN TripDetails t
    ON b.BookingID = t.BookingID
WHERE b.Status = 'Completed'
GROUP BY b.PickupLocation
ORDER BY AvgWaitTimeMins DESC;
SELECT
    PickupLocation,
    COUNT(*) AS CancelledBookings
FROM Bookings
WHERE Status = 'Canceled'
GROUP BY PickupLocation
ORDER BY CancelledBookings DESC;
SELECT
    CASE
        WHEN DistanceKM < 5 THEN 'Short'
        ELSE 'Long'
    END AS TripType,
    COUNT(*) AS NumTrips,
    SUM(Fare) AS TotalRevenue
FROM TripDetails
GROUP BY
    CASE
        WHEN DistanceKM < 5 THEN 'Short'
        ELSE 'Long'
    END;
    SELECT
    c.VehicleType,
    COUNT(t.TripID) AS TotalTrips,
    SUM(t.Fare) AS TotalRevenue
FROM Cabs c
JOIN Bookings b
    ON c.CabID = b.CabID
JOIN TripDetails t
    ON b.BookingID = t.BookingID
WHERE b.Status = 'Completed'
GROUP BY c.VehicleType
ORDER BY TotalRevenue DESC;
SELECT
    c.VehicleType,
    SUM(t.Fare) AS Revenue
FROM Cabs c
JOIN Bookings b
    ON c.CabID = b.CabID
JOIN TripDetails t
    ON b.BookingID = t.BookingID
WHERE b.Status = 'Completed'
GROUP BY c.VehicleType;
SELECT
    CASE
        WHEN DAYOFWEEK(b.BookingDate) IN (1, 7)
        THEN 'Weekend'
        ELSE 'Weekday'
    END AS DayType,
    COUNT(*) AS TotalBookings,
    SUM(t.Fare) AS TotalRevenue
FROM Bookings b
JOIN TripDetails t
    ON b.BookingID = t.BookingID
GROUP BY
    CASE
        WHEN DAYOFWEEK(b.BookingDate) IN (1, 7)
        THEN 'Weekend'
        ELSE 'Weekday'
    END;