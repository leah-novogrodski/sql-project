
------------------------------scalar function-----------------------------------------------------------
----או -1 אם החניון מלא (id) בדיקה האם יש מקום פנוי בחניון והחזרה של המקום הראשון     
create function isAvailable(@parkingLotId smallint,@isDisable bit) returns smallint as
 begin
   if(@isDisable!=1)
   begin
      if((select [numPlacesParking] from parking_lots 
      where id=@parkingLotId)-
      (select [numPlacesFullParking] from parking_lots 
      where id=@parkingLotId)>0)
          begin
            declare @p smallint
            select top(1) @p=parkingSpaces.id from parkingSpaces
             where parkingLotId=@parkingLotId and isFull!=1
            return @p
          end
      return -1
   end
   if ((select [numPlacesParkingDisabled] from parking_lots 
      where id=@parkingLotId)-
      (select [numPlacesFullParkingDisabled] from parking_lots 
      where id=@parkingLotId)>0)
          begin
            declare @p1 smallint
            select top(1) @p1=parkingSpaces.id from parkingSpaces
             where parkingLotId=@parkingLotId and isFull!=1
            return @p1
          end
      return -1
   end
-------------------------------procedure-------------------------------------------------------------------------------------
-----עדכון המקום חנייה כתפוס - פרוצדורה 
alter procedure updateParking(@place int, @isDisable bit, @parkingLotid int ) as 
begin
  update [dbo].[parkingSpaces] set [isFull]=1 where id=@place
  if (@isDisable!=1)
     update [dbo].[parking_lots] set [numPlacesFullParking]=[numPlacesFullParking]+1 where  @parkingLotid=id
  else
     update [dbo].[parking_lots] set [numPlacesFullParkingDisabled]=[numPlacesFullParkingDisabled]+1 where  @parkingLotid=id
 end
 -----------------------------------------------טריגר כניסה---------------------------------------------------------
----enter:
-----בעת הוספת שורה לטבלת שימושים:
 go
alter trigger enter on uses after insert 
as 
begin
----בדיקה האם אתה משתמש רשום
 begin try
 insert into [dbo].[uses] ([userId])value (select u
end try
 begin catch
print 'You are not a registered user, you have to register.'+ 'אינך רשום,עליך להירשם'
 end catch
declare @parkingLotid int 
select @parkingLotid = parking_lots.id from inserted join [dbo].[parking_lots] 
on [dbo].[parking_lots].[name]=inserted.parkingLotName 
declare @isDisable bit
select @isDisable = disabledP  from inserted
declare @place smallint
set @place= dbo.isAvailable(@parkingLotId,@isDisable)
if (@place=-1)
begin
print 'Sorry, the parking lot is full.'            
rollback 
end
-----עדכון המקום חנייה כתפוס
else
begin
exec updateParking @place,@isDisable,@parking
---------------------------
INSERT INTO paparkingSpaces(userId)
VALUES (inserted.userId);
end
----------------------------------------------------------------------------------------------------------------------------------

-----------------------------------------------------------טריגר יציאה------------------------------------------------
-----exit 

alter trigger carExit on uses
after update
as
    begin
----------------------------------------חישוב מחיר סופי----------------------------------------
-------------------החישוב הוא לפי הכללים הבאים:אם חנה פחות מ24 שעות המחיר הוא לפי מחיר שעתי  
--------------------------אם חנה יותר מ24 שעות מחשבים כל יום לפי המחיר היומי+ השעות הנותרות
-------------------------------------------------(המחיר הוא אוניברסלי(לא משנה האם מדובר בנכה
	if UPDATE(exitTime)
	 begin
        update uses
        set finleprice = 
            (datediff(day, inserted.entryTime, inserted.exitTime) * parking_lots.dailyPrice) +
            (((datediff(hour, inserted.entryTime, inserted.exitTime) - (datediff(day, inserted.entryTime, inserted.exitTime) * 24)))*parking_lots.hourlyPrice)
        from uses 
        join inserted  on uses.userId = inserted.id
        join parking_lots  on parking_lots.name = inserted.parkingLotName
        where inserted.exitTime is not null
	
--------------------------------------------שחרור החניות---------------------------------------------------
		 update parkingSpaces set isFull=0 where parkingSpaces.[userId]  in (select userId from inserted)
      end
    end
update [dbo].[uses] set [exitTime]=GETDATE() where   [userId]=216275032
select userId from parkingSpaces
select*from parkingSpaces
INSERT INTO [dbo].[uses] (userId, parkingLotName)
VALUES ('21627502', 'חניון ממילא');
select * FROM [dbo].[uses]
