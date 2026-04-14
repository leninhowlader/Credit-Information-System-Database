SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<Author,,Name>
-- Create date: <Create Date, ,>
-- Description:	<Description, ,>
-- =============================================
CREATE FUNCTION ChequePurpose(@Code Int)
RETURNS Varchar(50)
With Encryption
AS
BEGIN
	DECLARE @Purpose Varchar(50);

	Set @Purpose = (Select Purpose From dmn_ChequePurpose Where Code = @Code);

	-- Return the result of the function
	RETURN @Purpose

END
GO

-- Select dbo.ChequePurpose(3)