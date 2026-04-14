SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date,,>
-- Description:	<Description,,>
-- =============================================
CREATE FUNCTION SplitText(@InputText Varchar(200), @SrcChar Char(1))
RETURNS 
@List Table(Item Varchar(200))
AS
BEGIN
	Declare @ndx1 Integer, @ndx2 Integer, @Len Integer, @SubStr Varchar(200);

	Set @ndx1 = 1

	While 1 = 1
		Begin
		Set @ndx2 = charindex(@SrcChar, @inputText, @ndx1)
		If @ndx2 <= 0 Set @ndx2 = Len(@inputText) + 1
		Set @Len = @ndx2 - @ndx1 
		Set @SubStr = rtrim(ltrim(Substring(@inputText, @ndx1 , @Len )))
		Insert into @List(Item) values(@SubStr)
		
		set @ndx1 = @ndx2 + 1;
		If @ndx2 = Len(@inputText) + 1 Break;
		end
	RETURN 
END
GO

--select * from dbo.SplitText('lenin,zaman, ziaul, kabir',',')