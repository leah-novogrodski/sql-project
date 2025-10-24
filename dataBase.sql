create database Parking
go
use Parking
create table parking_lots
(
id smallint identity(1056,7) primary key,
addressP varchar(20),
numPlacesParking smallint not null,
numPlacesFullParking smallint default 0 ,
numPlacesParkingDisabled smallint not null,
numPlacesFullParkingDisabled  smallint default 0  ,
isCovered bit, 
hourlyPrice smallint not null,
dailyPrice smallint not null
)
use Parking
create table users(
id int primary key not null,
fullName varchar(20),
phoneNumber varchar(10),
disabledP bit default 0 
)
use Parking
create table uses
(
id smallint identity(10000,1) primary key,
userId smallint references users,
parkingLotId smallint references parking_lots,
----parkingId smallint references parkingSpaces ,
entryTime datetime not null,
exitTime datetime,
finlePrice smallint
)
use Parking
create table parkingSpaces 
(
id smallint identity(1,1) primary key,
parkingLotId smallint references parking_lots,
numFloor smallint not null,
numLine smallint not null,
isDisabled  bit default 0,
isFull bit default 0 
)
