----------------------------���� ����� �����-----------------
 -------------���� ������ �� �� ������ ����
create or alter trigger InsteadOfInsert on dbo.uses
instead of insert
as
begin
    declare @userId varchar(9),@parkingLotName varchar(20)

    select @userId = userId,@parkingLotName=parkingLotName from inserted;

    -- ����� �� ������ ���� ����� ��������
    if not exists(select * from dbo.users where id = @userId)
	        -- �� ������ �� ����, ������ ����� �����
	        print 'You are not a registered user, you have to register';
    else if not exists(select * from parking_lots where name = @parkingLotName)
           	        print 'the parking lot you request is incorrect'
    else
	begin
        insert into dbo.uses (userId, parkingLotName,isDisabled)
        select userId, parkingLotName, isDisabled from inserted
    end
end

use ParkingSystem

-----------------------------------------------����� �����---------------------------------------------------------
----enter:
-----��� ����� ���� ����� �������:
go
create or alter trigger enter on uses after insert 
as 
begin
declare @parkingLotid int, @isDisable bit, @place int ,@userId varchar(9)
---- isAvailable ����� ��������
select @parkingLotid = parking_lots.id ,@isDisable = isDisabled, @userId=userId 
from inserted join [dbo].[parking_lots] 
on [dbo].[parking_lots].name=inserted.parkingLotName 
 
set @place= dbo.isAvailable(@parkingLotId,@isDisable)
  if (@place=-1)
    begin
       print 'Sorry, the parking lot is full.'            
       rollback 
  end
-----����� ����� ����� �����
  else
    begin
       exec  updateParking @place,@isDisable,@parkingLotid,@userId
	   declare @s varchar(200),@numFloor smallint,@numLine smallint
	    select @numFloor = numfloor, @numLine = numLine 
        from parking_spaces 
        WHERE id = @place
        set @s='Welcome.
        We are happy you came to park in our parking lot
         The parking location is:'+
        ', Floor: ' + CAST(@numFloor as varchar(20)) + 
        ', Line: ' + CAST(@numLine as varchar(20))
print @s        
end
end
INSERT INTO [dbo].[uses] (userId, parkingLotName)
VALUES ('123456789', 'Mall Parking')

------------------------------scalar function-----------------------------------------------------------
---- �� -1 �� ������ ��� (id) ����� ��� �� ���� ���� ������ ������ �� ����� ������     
create or alter function isAvailable(@parking_lotId smallint,@isDisable bit) 
returns smallint as
begin
if(@isDisable!=1)
begin
    declare @p smallint
	if((select totalSpaces-occupiedSpaces 
	from parking_lots 
	where id=@parking_lotId)>0)
		begin
		select top(1) @p=parking_spaces.id from parking_spaces
			where parking_lotId=@parking_lotId and isFull!=1
		return @p
		end
end
else
begin
if ((select totalDisabledSpaces-occupiedDisabledSpaces 
     from parking_lots 
	 where id=@parking_lotId)>0)
		begin
		select top(1) @p=parking_spaces.id from parking_spaces
			where parking_lotId=@parking_lotId and isFull!=1
		return @p
		end
		end
	return -1
end

use ParkingSystem
-------------------------------procedure-------------------------------------------------------------------------------------
-----����� ����� ����� ����� - �������� 
create or alter procedure updateParking(@place int, @isDisable bit, @parkingLotid int,@userId varchar(9) ) as 
begin
update [dbo].[parking_spaces] set [isFull]=1,userId=@userId where id=@place
if (@isDisable!=1)
	update [dbo].[parking_lots] set occupiedSpaces=occupiedSpaces+1 where  @parkingLotid=id
else
	update [dbo].[parking_lots] set occupiedDisabledSpaces=occupiedDisabledSpaces+1 where  @parkingLotid=id
end

 
-----------------------------------------------------------����� �����------------------------------------------------
-----exit 

alter trigger carExit on uses after update as
begin
----����� ���� ����
----���� ��� ������ �� ��� ���� 30 �"�
-----�� ��� ���� �24 ���� ����� ��� ��� ���� ���� �� ��� ���� �24 ���� ������ �� ��� ��� ����� �����+ ����� �������
--(����� ��� ���������(�� ���� ��� ����� ����
if UPDATE(exitTime)
	begin
	update uses
	set finalPrice = 
	case
	when (datediff(hour, inserted.entryTime, inserted.exitTime))<1 then 30
	when (datediff(hour, inserted.entryTime, inserted.exitTime))<24 then (datediff(hour, inserted.entryTime, inserted.exitTime))*parking_lots.hourlyPrice
	else  (datediff(day, inserted.entryTime, inserted.exitTime) * parking_lots.dailyPrice)+
	(((datediff(hour, inserted.entryTime, inserted.exitTime) - (datediff(day, inserted.entryTime, inserted.exitTime) * 24)))*parking_lots.hourlyPrice)
	end
	from uses 
	join inserted  on uses.id = inserted.id
	join parking_lots  on parking_lots.name = inserted.parkingLotName
	WHERE uses.id = inserted.id
--------------------------------------------����� ������---------------------------------------------------
		  update parking_spaces set isFull=0 ,[userId]=null where parking_spaces.userId  in (select userId from inserted)
		if((select[isDisabled]  from [dbo].[parking_spaces] where parking_spaces.userId  in (select userId from inserted))=0)
			update parking_lots set [occupiedSpaces]=[occupiedSpaces]-1 where name in (select [parkingLotName]from inserted)
			else
			update parking_lots set[occupiedDisabledSpaces]=[occupiedDisabledSpaces]-1 where name in(select [parkingLotName]from inserted)
	end
end
update [dbo].[uses] set [exitTime]=GETDATE()  where [userId]=123456789

------------------------------------------------------cursor-----------------------------------------------------------------
-----------------������ �� ���� ����� ����� �� �������� ����� ����� ���� ���� ��� 
-----------------�� �� ������ ��� ����� 10% ������ ����� �������� �������� ��� ����  
create procedure UpdateTelAvivPrices(@id int) as
update [dbo].[parking_lots] set [dailyPrice]=[dailyPrice]*0.9 

declare updatePrice cursor  for
select id , dailyPrice from parking_lots where city='Tel Aviv'
open updatePrice
declare @id int ,@price smallint
fetch next from updatePrice into @id,@price
while @@FETCH_STATUS=0
begin
  IF @price > 120
      exec UpdateTelAvivPrices @id
fetch next from updatePrice into @id,@price
end
close updatePrice --����� ���
deallocate updatePrice

select *from parking_lots
-------------------------------------------------- view --------------------------------------------------------
--------������� ����� ���� ���� �� ����� �� ����� ������� ���� ��� ��� ���� ������ ���� �������
------����� ��� ��� ������ ����� 0
alter view high_monthly_income as 
select *from(
select name,coalesce( sum(finalPrice),0) 'sumIncome',datename(MONTH,month(exitTime)) 'MONTH',
row_number() over( partition by name order by sum(finalPrice) desc) 'row_num'
from uses full join parking_lots on uses.parkingLotName=name where year(exitTime)=year(GETDATE()) or exitTime is null
group by name ,MONTH(exitTime))q1
where row_num<=3

select * from high_monthly_income
-------------------------------------Except
----------------����� ������� ��� ��� �����
create or alter view userNotParked as
select * from users 
Except
select * from users where id in(select distinct userId from uses)

select * from userNotParked

--------------------------------------table function---------------------------------------------------------------------------------------------------
--(�������� ������ �� ��� ������ ���� ���� �� ����� �� ���� ��� ����(���/����
---����� �� ����� ���� ����� ���� ������ ����� ����� ����
 function GetParkingStatusByCity(@city VARCHAR(20)) 
returns table as
    return
       select [name],[address],
           case 
            when [totalSpaces]-[occupiedSpaces]>0 then '����'
           else  '���'
         end as 'status_parking_lots'
  from [dbo].[parking_lots] where city=@city

  SELECT * FROM dbo.GetParkingStatusByCity('Tel Aviv')