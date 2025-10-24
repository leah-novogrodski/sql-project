-- יצירת מסד הנתונים
CREATE DATABASE ParkingSystem
USE ParkingSystem

-- טבלת חניונים
CREATE TABLE parking_lots (
    id INT identity(1,1) PRIMARY KEY,
    name VARCHAR(20) unique NOT NULL,
    address VARCHAR(20),
    city VARCHAR(20),
    totalSpaces SMALLINT NOT NULL,
    occupiedSpaces SMALLINT default 0,
    totalDisabledSpaces SMALLINT NOT NULL,
    occupiedDisabledSpaces SMALLINT default 0,
    isCovered BIT default 0,
    hourlyPrice SMALLINT NOT NULL,
    dailyPrice SMALLINT NOT NULL
)
USE ParkingSystem

-- טבלת מקומות חניה
CREATE TABLE parking_spaces (
    id SMALLINT PRIMARY KEY,
    parking_lotId INT REFERENCES parking_lots NOT NULL,
    numFloor SMALLINT NOT NULL,
    numLine SMALLINT NOT NULL,
    isDisabled BIT NOT NULL,
    isFull BIT NOT NULL,
    userId VARCHAR(9) REFERENCES users,
 
)
USE ParkingSystem

-- טבלת משתמשים
CREATE TABLE users (
    id VARCHAR(9) PRIMARY KEY,
    fullName VARCHAR(20),
    phoneNumber VARCHAR(10) NOT NULL,
    email VARCHAR(50),
    carNumber VARCHAR(10)
)
USE ParkingSystem

-- טבלת שימושים
CREATE TABLE uses (
    id INT PRIMARY KEY,
    userId VARCHAR(9)REFERENCES users,
    parkingLotName VARCHAR(20) NOT NULL,
    entryTime DATETIME,
    exitTime DATETIME,
    finalPrice SMALLINT,
    isDisabled BIT   
)

-- הכנסת נתונים לדוגמה
INSERT INTO parking_lots VALUES
(1, 'Central Park', 'Main St 12', 'Tel Aviv', 200, 150, 20, 10, 1, 20, 150),
(2, 'Beach Lot', 'Ocean Ave 5', 'Haifa', 100, 80, 10, 5, 0, 15, 100),
(3, 'Mall Parking', 'Mall Rd 7', 'Jerusalem', 300, 250, 30, 20, 1, 25, 200)

INSERT INTO users VALUES
('123456789', 'Dana Cohen', '0541234567', 'dana@mail.com', '123-45-678'),
('987654321', 'Avi Levi', '0529876543', 'avi@mail.com', '987-65-432'),
('456789123', 'Roni Mor', '0534567891', 'roni@mail.com', '456-78-912'),
('111222333', 'Noa Shalev', '0501112233', 'noa@mail.com', '111-22-333'),
('444555666', 'Eli Bar', '0504445566', 'eli@mail.com', '444-55-666')

INSERT INTO parking_spaces VALUES
(1, 1, 1, 10, 0, 0, NULL),
(2, 1, 1, 11, 1, 1, '123456789'),
(3, 2, 2, 20, 0, 0, NULL),
(4, 3, 3, 30, 1, 1, '987654321'),
(5, 3, 3, 31, 0, 0, NULL),
(6, 1, 2, 12, 1, 1, '111222333')

INSERT INTO uses VALUES
(1, '123456789', 'Central Park', '2025-03-01 08:00:00', '2025-03-01 12:00:00', 80, 0),
(2, '987654321', 'Mall Parking', '2025-03-02 09:30:00', '2025-03-02 15:45:00', 150, 1),
(3, '123456789', 'Beach Lot', '2025-03-03 10:00:00', '2025-03-03 13:30:00', 50, 0),
(4, '111222333', 'Central Park', '2025-03-04 14:00:00', NULL, NULL, 1),
(5, '444555666', 'Mall Parking', '2025-03-05 16:30:00', NULL, NULL, 0)
