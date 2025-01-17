USE [Mortgage]
GO
/****** Object:  StoredProcedure [dbo].[BorrowerUpdate]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	Insert or Update the Borrower Table
--Execution: EXEC [dbo].[BorrowerUpdate]	@EmailID = N'rakek@novigo.com',	@BorrowerName = N'Rock', @CreatedBy = N'Batman', @ModifiedBY =N'Robin'
-- =============================================
CREATE PROCEDURE [dbo].[BorrowerUpdate](
	-- Add the parameters for the stored procedure here
	 @EmailID varchar(255),
	 @BorrowerName varchar(255),
	@CreatedBy varchar(255) null, 
	@ModifiedBy varchar(255) null	
	
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	declare @count int  = 0

	SELECT @count = count(1)
	FROM Borrower
	WHERE EmailID = @EmailID

	IF(@count > 0)
	BEGIN
		  --insert
		  UPDATE Borrower SET BorrowerName=@BorrowerName,
							  ModifiedBy =@ModifiedBy,
							  ModifiedDate=GETDATE()
		  WHERE EmailID= @EmailID	
	END	
	ELSE
	BEGIN
		INSERT INTO Borrower(EmailID,BorrowerName,CreatedBy,CreatedDate) VALUES(@EmailID,@BorrowerName,@CreatedBy,GetDate())
	END

	DECLARE @BorrowerID  int 

	SELECT @BorrowerID =ID 
		 FROM Borrower
		 WHERE EmailID = @EmailID

  SELECT @BorrowerID BorrowerID    
END


GO
/****** Object:  StoredProcedure [dbo].[CheckIfMLOAlreadyAssigned]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	Check if MLO is already assigned
--Execution: EXEC [dbo].[CheckIfMLOAlreadyAssigned]	@HippoNumber = N'773472'
-- =============================================
CREATE PROCEDURE [dbo].[CheckIfMLOAlreadyAssigned](
	-- Add the parameters for the stored procedure here
	 @HippoNumber varchar(255)
	 	
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE @count int  = 0

	SELECT U.ID,U.Name,U.Email
	FROM Loan L
	JOIN UserDetails U ON U.Name= L.MLO
	WHERE HippoNumber = @HippoNumber and ISNULL(mlo,'')<>''
	

END

GO
/****** Object:  StoredProcedure [dbo].[CheckProcessorRuns]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  3/20/2020
-- Description:	Get the count of successful run counts by loan number
--Execution: EXEC [dbo].[CheckProcessorRuns] @LoanNumber='1000025556'
-- =============================================
CREATE PROCEDURE [dbo].[CheckProcessorRuns]
(
@LoanNumber varchar(100) = null
)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   

declare @output as table(
RoundRobin int,
Compliance int,
Flood int ,
DataTree int,
ApplicationFee int,
WorkNumber int,
FormFree int

)

declare @RoundRobin int = 0,
@Compliance int = 0,
@Flood int  = 0,
@DataTree int = 0,
@ApplicationFee int = 0,
@WorkNumber int = 0,
@FormFree int =0


select @FormFree = count(1) from Processing P
JOIN Loan L ON L.ID= P.LoanID
where ChildProcess='Successful' and ParentProcess='Cadence_UploadFormFreeId' and L.LoanNumber=@LoanNumber

select @WorkNumber = count(1) from Processing P
JOIN Loan L ON L.ID= P.LoanID
where ChildProcess='Successful' and ParentProcess='CadenceEmployeeVerification_UsingWorkNumber' and L.LoanNumber=@LoanNumber


select @Compliance = count(1) from Processing P
JOIN Loan L ON L.ID= P.LoanID
where ChildProcess='Successful' and ParentProcess='Compliance Report Process' and L.LoanNumber=@LoanNumber


select @DataTree = count(1) from Processing P
JOIN Loan L ON L.ID= P.LoanID
where ChildProcess='Successful' and ParentProcess='CountyMapping_ReportDownload' and L.LoanNumber=@LoanNumber


select @Flood = count(1) from Processing P
JOIN Loan L ON L.ID= P.LoanID
where ChildProcess='Successful' and ParentProcess='Flood Report Process' and L.LoanNumber=@LoanNumber

select @ApplicationFee = count(1) from Processing P
JOIN Loan L ON L.ID= P.LoanID
where ChildProcess='Successful' and ParentProcess='Review Application Fee Disclosure' and L.LoanNumber=@LoanNumber


SELECT  @RoundRobin  RoundRobin,
@Compliance Compliance ,
@Flood Flood  ,
@DataTree DataTree,
@ApplicationFee ApplicationFee,
@WorkNumber WorkNumber ,
@FormFree FormFree


END


GO
/****** Object:  StoredProcedure [dbo].[FundingUpdate]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	Insert or Update the Loan Table
-- Execution: EXEC	FundingUpdate	@LoanID = 2,@ParentProcess = N'Funding',@ChildProcess = N'RoundRobin',@Sucess = 1,@Reason =N'Pass',@ProcessStartTime = N'2/25/2019',@Comments = N'Test',@CreatedBy = N'mbot1-vm',@RequestedBy = N'angela@gesa.com',@RequestedDateTime = N'2/25/2019'
--select * from Funding
-- =============================================
CREATE PROCEDURE [dbo].[FundingUpdate](
	-- Add the parameters for the stored procedure here
	 @LoanID int,
	 @ParentProcess varchar(100) ,
	 @ChildProcess varchar(500) ,
	 @Sucess bit null,
	 @Reason varchar(500) null ,
	 @ProcessStartTime datetime null,
	 @Comments varchar(max) null,
	 @CreatedBy varchar(100) null,
	 @RequestedBy varchar(255) null,
	 @RequestedDateTime datetime null
	
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	
		INSERT INTO Funding(LoanID,ParentProcess,ChildProcess,Success,Reason,ProcessStartTime,Comments,CreatedBy,CreatedDate
					,RequestedBy,RequestedDateTime) 
			  VALUES(@LoanID,@ParentProcess,@ChildProcess,@Sucess,@Reason,@ProcessStartTime,@Comments,@CreatedBy, GetDate()
			        ,@RequestedBy,@RequestedDateTime)
	

	 
	 
END


GO
/****** Object:  StoredProcedure [dbo].[GetAssignedProcesssorsByLoanNumbers]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	Get Assigned Processsors By LoanNumbers   
--Execution: EXEC [dbo].GetAssignedProcesssorsByLoanNumbers @LoanNumbers='1000003760,1000003762'
-- =============================================
CREATE PROCEDURE [dbo].[GetAssignedProcesssorsByLoanNumbers]
(
@LoanNumbers varchar(max) = null
)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	

	SELECT LoanNumber, BorrowerName,Processor ,Conditioner 'Condition Analyst',Funding 'Funder',Underwritter 'Underwriter' 
		,P.Email ProcessorEmail
		,CA.Email ConditionAnalystEmail
		,F.Email FunderEmail
		,U.Email UnderwritterEmail
	FROM
		Loan L
	 JOIN Borrower B On B.ID=L.BorrowerID
	 LEFT JOIN ProcessingUsers P ON L.Processor=P.Name
	 LEFT JOIN ProcessingUsers CA ON L.Conditioner=CA.Name
	 LEFT JOIN ProcessingUsers F ON L.Funding=F.Name
	 LEFT JOIN ProcessingUsers U ON L.Underwritter=U.Name
	 WHERE LoanNumber In (SELECT part from fn_SplitString(@LoanNumbers,','))

END


GO
/****** Object:  StoredProcedure [dbo].[GetContactsByName]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================a
-- Author:		Rakesh Khanai
-- Create date: 4/13/2020
-- Description:	GET Get Contacts By Name
--EXEC GetContactsByName 'Bic Hickman'

-- =============================================
CREATE PROCEDURE [dbo].[GetContactsByName] 
(
@Name varchar(100)
)
AS
BEGIN
 SELECT * FROM Contacts
 where Name=@Name

END
GO
/****** Object:  StoredProcedure [dbo].[GetCountMappingSuccessByLoanNumber]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	GetMLO based on the load assigned  
--Execution: EXEC [dbo].[GetCountMappingSuccessByLoanNumber] @LoanNumber ='1000003763'
-- =============================================
CREATE PROCEDURE [dbo].[GetCountMappingSuccessByLoanNumber](
@LoanNumber varchar(50)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT * from Processing P
	JOIN Loan L On L.ID =LoanID
	WHERE ParentProcess ='CountyMapping_ReportDownload' and ChildProcess='Successful' and L.LoanNumber=@LoanNumber

END

GO
/****** Object:  StoredProcedure [dbo].[GetCountOfAvailableDMINumber]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================a
-- Author:		Rakesh Khanai
-- Create date: 7/10/2019
-- Description:	Insert or update the DMINUmber
--EXEC [GetCountOfAvailableDMINumber]

-- =============================================
CREATE PROCEDURE [dbo].[GetCountOfAvailableDMINumber]
AS
BEGIN

select count(1)
from dminumber where loannumber is null
END
GO
/****** Object:  StoredProcedure [dbo].[GETDMINumber]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================a
-- Author:		Rakesh Khanai
-- Create date: 7/10/2019
-- Description:	GET DMINUmber
--EXEC GETDMINumber

-- =============================================
CREATE PROCEDURE [dbo].[GETDMINumber] 
AS
BEGIN
 SELECT top 1 * FROM DMINUMBER
  where  LoanNumber is null
  ORDER By DMINUMBER

END


GO
/****** Object:  StoredProcedure [dbo].[GetLoanDetailsByHippoNumber]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	Get Loan details by hipppo number
--Execution: EXEC [dbo].[GetLoanDetailsByHippoNumber]	@HippoNumber = N'799212'
-- =============================================
CREATE PROCEDURE [dbo].[GetLoanDetailsByHippoNumber](
	-- Add the parameters for the stored procedure here
	 @HippoNumber varchar(255)
	 	
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	

	SELECT *
	FROM Loan L
	WHERE HippoNumber = @HippoNumber 
	

END

GO
/****** Object:  StoredProcedure [dbo].[GetMLO]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	GetMLO based on the load assigned  
--Execution: EXEC [dbo].GETMLO
-- =============================================
CREATE PROCEDURE [dbo].[GetMLO]
(
@groupName varchar(100) = null
)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	IF(@groupName ='Group2')
	BEGIN
		SELECT top 1 *
		  FROM userdetails
		  WHERE  name not like '%Brenda%' and Loancounter = (select min(loancounter) from userdetails where name not like '%Brenda%') --exclude brenda 
	END
	ELSE
	BEGIN
		SELECT * FROM USERDetails
		where name like  '%Brenda%'
	END
END


GO
/****** Object:  StoredProcedure [dbo].[GetProcessors]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	GetMLO based on the load assigned  
--Execution: EXEC [dbo].GETProcessors @LoanType ='NonFHANonVA'
-- =============================================
CREATE PROCEDURE [dbo].[GetProcessors](
@LoanType varchar(50)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	declare @team varchar(50),@processor varchar(50),@processorID int,@underwriters varchar(50),@underwritersID int,
			@conditionanalyst varchar(50), @conditionanalystId int,@funder varchar(50),@funderid int


	SELECT  @team= Team,
	        @processor=Name,
			@processorID = ID
	FROM
	(
		SELECT top 1 *
		FROM	ProcessingUsers
		WHERE	grouptype ='processor' 
		AND counter = (select min(counter) from ProcessingUsers where grouptype ='processor' AND LoanType=@LoanType)
		AND LoanType=@LoanType
	) A

	


	SELECT 
	        @underwriters=Name,
			@underwritersID = ID
	FROM
	(
	SELECT top 1 *
		FROM	ProcessingUsers
		WHERE	grouptype ='underwriters' 
		AND		Team = @team	
		AND counter = (select min(counter) from ProcessingUsers where grouptype ='underwriters' and Team = @team)  
		
	) A

	SELECT 
	        @conditionanalyst=Name,
			@conditionanalystId = ID
	FROM
	(
	SELECT top 1 *
		FROM	ProcessingUsers
		WHERE	grouptype ='condition analyst' 
		AND		Team = @team	
		AND counter = (select min(counter) from ProcessingUsers where grouptype ='condition analyst' and Team = @team)  
	) A
	
	SELECT 
	        @funder=Name,
			@funderid = ID
	FROM
	(
	SELECT top 1 *
		FROM	ProcessingUsers
		WHERE	grouptype ='funder' 
		AND		Team = @team	
		AND counter = (select min(counter) from ProcessingUsers where grouptype ='funder' and Team = @team)  
	) A
	


	SELECT	@team TeamGroup,
		 	@processorID ProcessorID
		   ,@processor ProcessorName
		   ,@underwritersID underwriterid
		   ,@underwriters underwritersName
		   ,@conditionanalystId conditionanalystid
		   ,@conditionanalyst conditionanalystName
		   ,@funderid Funderid,@funder FunderName
END

GO
/****** Object:  StoredProcedure [dbo].[GetVeritaxDownloadOrderByLoanNumber]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	GetMLO based on the load assigned  
--Execution: EXEC [dbo].[GetVeritaxDownloadOrderByLoanNumber] @LoanNumber ='1000003763'
-- =============================================
CREATE PROCEDURE [dbo].[GetVeritaxDownloadOrderByLoanNumber](
@LoanNumber varchar(50)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	SELECT * from Processing P
	JOIN Loan L On L.ID =LoanID
	WHERE ParentProcess ='EmploymentVerification _UsingVeritax_DownloadOrders' and ChildProcess='Successful' and L.LoanNumber=@LoanNumber

END

GO
/****** Object:  StoredProcedure [dbo].[InsertDMINumber]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================a
-- Author:		Rakesh Khanai
-- Create date: 7/10/2019
-- Description:	Insert or update the DMINUmber
--EXEC InsertDMINumber @DMINumber='3'

-- =============================================
CREATE PROCEDURE [dbo].[InsertDMINumber] (
	 @DMINumber varchar(100)
	 
	)
AS
BEGIN

declare @Count int =0
SELECT @Count=count(1)
		FROM DmINUMber
		WHERE DMINUMBER = @DMINumber

IF(@Count=0)
	BEGIN

		INSERT INTO DmINUMber(DMINUMBER) Values(@DMINumber)

	END	


END
GO
/****** Object:  StoredProcedure [dbo].[LoanUpdate]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	Insert or Update the Loan Table
-- EXEC	 [dbo].[LoanUpdate]	@BorrowerID = 1,@DateCreatedInHippo = N'1/28/2020',	@HippoNumber = N'1',@LoanNumber = N'124 ',	@MLO = N' ',@Processor = N' ',		@Underwritter = N' ',@Conditioner = N' ',@Funding = N' ',	@Closing = N' ',@CreatedBy = N' ', @modifiedby = N' '
-- =============================================
CREATE PROCEDURE [dbo].[LoanUpdate](
	-- Add the parameters for the stored procedure here
	 @BorrowerID int,
	 @DateCreatedInHippo varchar(100) null,
	@HippoNumber varchar(100) null, 
	@LoanNumber varchar(255) null,
	@MLO varchar(100) null,
	@Processor varchar(100) null,
	@Underwritter varchar(100) null,
	@Conditioner  varchar(100) null,
	 @Funding varchar(100) null,
	@Closing varchar(100) null,
	@CreatedBy varchar(100) null,
	@ModifiedBy Varchar(100) null	
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	declare @count int  = 0

	SELECT @count = count(1)
	FROM Loan
	WHERE HippoNumber = @HippoNumber

	IF(@count > 0)
	BEGIN
		  --insert
		  UPDATE Loan SET LoanNumber=@LoanNumber,
							  Processor =@Processor,
							  --MLO=@MLO,
							  Underwritter=@Underwritter,
							  Conditioner=@Conditioner,
							  Funding=@Funding,
							  Closing=@Closing,
							  ModifiedBy=@ModifiedBy,
							   ModifiedDate=Getdate()
		  WHERE HippoNumber= @HippoNumber	
	END	
	ELSE
	BEGIN
		INSERT INTO Loan(BorrowerID,DateCreatedinHippo,HippoNumber,MLO,Underwritter,Closing,CreatedBy,CreatedDate) 
			  VALUES(@BorrowerID,@DateCreatedInHippo,@HippoNumber,@MLO,@Underwritter,@Closing,@CreatedBy,GetDate())
	END

   
	 
	 SELECT  ID LoanID
	  FROM Loan
	 WHERE HippoNumber = @HippoNumber



END


GO
/****** Object:  StoredProcedure [dbo].[OriginationUpdate]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	Insert or Update the Loan Table
-- Execution: EXEC	 [dbo].[OriginationUpdate]	@LoanID = 1,@ParentProcess='HippoDownload',@ChildProcess=N'SSNCheck',@Sucess=1,@Reason=N' ',@ProcessStartTime='1/1/2020',@comments=N' ',@CreatedBy=N'Batman',@ModifiedBy=N' '
--select * from origination
-- =============================================
CREATE PROCEDURE [dbo].[OriginationUpdate](
	-- Add the parameters for the stored procedure here
	 @LoanID int,
	 @ParentProcess varchar(100) ,
	 @ChildProcess varchar(500) ,
	 @Sucess bit null,
	 @Reason varchar(500) null ,
	 @ProcessStartTime datetime null,
	 @Comments varchar(max) null,
	 @CreatedBy varchar(100) null,
	 @ModifiedBy Varchar(100) null
	
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	
		INSERT INTO Origination(LoanID,ParentProcess,ChildProcess,Success,Reason,ProcessStartTime,Comments,CreatedBy,CreatedDate) 
			  VALUES(@LoanID,@ParentProcess,@ChildProcess,@Sucess,@Reason,@ProcessStartTime,@Comments,@CreatedBy, GetDate())
	

	 
	 
END


GO
/****** Object:  StoredProcedure [dbo].[ProcessExecution]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  3/20/2020
-- Description:	Get the count of successful run counts by loan number
--Execution: EXEC [dbo].[ProcessExecution] @LoanNumber='1000025556',@ProcessName='Cadence_UploadFormFreeId',@tableName='Processing'
-- =============================================
CREATE PROCEDURE [dbo].[ProcessExecution]
(
@LoanNumber varchar(100) = null,
@ProcessName  varchar(100) = null,
@tableName varchar(100)
)

AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

   
declare @count int =0

if(@tableName='Processing')
BEGIN
	select @count=count(1) from Processing P
	JOIN Loan L ON L.ID= P.LoanID
	where ChildProcess='Successful' and ParentProcess=@ProcessName and L.LoanNumber=@LoanNumber
END
ELSE IF(@tableName='Funding')
BEGIN
	select @count=count(1) from Funding P
	JOIN Loan L ON L.ID= P.LoanID
	where ChildProcess='Successful' and ParentProcess=@ProcessName and L.LoanNumber=@LoanNumber
END
ELSE IF(@tableName='Origination')
BEGIN
	select @count=count(1) from Origination P
	JOIN Loan L ON L.ID= P.LoanID
	where ChildProcess='Successful' and ParentProcess=@ProcessName and L.LoanNumber=@LoanNumber
END



SELECT @count CountOfRecords
END


GO
/****** Object:  StoredProcedure [dbo].[ProcessorLoanUpdate]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	Insert or Update the Loan Table from Processor Screen
-- EXEC	 ProcesssingUpdate	@LoanID = 2,@ParentProcess = N'Processing',@ChildProcess = N'RoundRobin',@Sucess = 1,@Reason =N'Pass',@ProcessStartTime = N'2/25/2019',@Comments = N'Test',@CreatedBy = N'mbot1-vm',@RequestedBy = N'angela@gesa.com',@RequestedDateTime = N'2/25/2019',@ProcessCompleteTime = N'2/25/2019'
-- =============================================
CREATE PROCEDURE [dbo].[ProcessorLoanUpdate](
	-- Add the parameters for the stored procedure here
	@BorrowerID int,
	@LoanNumber varchar(255) null,
	@Processor varchar(100) null,
	@Underwritter varchar(100) null,
	@Funding varchar(100) null,
	@Conditioner  varchar(100) null,
	@Closing varchar(100) null,
	@CreatedBy varchar(100) null,
	@ModifiedBy Varchar(100) null	
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	DECLARE @count int  = 0

	SELECT @count = count(1)
	FROM Loan
	WHERE LoanNumber = @LoanNumber

--	select  @count

	IF(@count > 0)
	BEGIN
		  
		  UPDATE Loan SET     Processor =case when isnull(@Processor,'')=''
												then Processor
												else @Processor
												end,
							  Underwritter=case when isnull(@Underwritter,'')=''
												then Underwritter
												else @Underwritter
												end,
							  Conditioner=case when isnull(@Conditioner,'')=''
												then Conditioner
												else @Conditioner
												end,
							  Funding=case when isnull(@Funding,'')=''
												then Funding
												else @Funding
												end,
							  Closing=case when isnull(@Closing,'')=''
												then Closing
												else @Closing
												end,
							  ModifiedBy=@ModifiedBy,
							   ModifiedDate=Getdate()
		  WHERE LoanNumber= @LoanNumber
	END	
	ELSE
	BEGIN
		INSERT INTO Loan(BorrowerID,LoanNumber,Processor, Underwritter,Conditioner,Funding,Closing,CreatedBy,CreatedDate) 
			  VALUES(@BorrowerID,@LoanNumber,@Processor,@Underwritter,@Conditioner,@Funding,@Closing,@CreatedBy,GetDate())
	END
	   
	  SELECT  ID LoanID
	  FROM Loan
	 WHERE LoanNumber = @LoanNumber

END


GO
/****** Object:  StoredProcedure [dbo].[ProcesssingUpdate]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	Insert or Update the Loan Table
-- Execution: EXEC	 ProcesssingUpdate	@LoanID = 2,@ParentProcess = N'Processing',@ChildProcess = N'RoundRobin',@Sucess = 1,@Reason =N'Pass',@ProcessStartTime = N'2/25/2019',@Comments = N'Test',@CreatedBy = N'mbot1-vm',@RequestedBy = N'angela@gesa.com',@RequestedDateTime = N'2/25/2019'
--select * from Processing
-- =============================================
CREATE PROCEDURE [dbo].[ProcesssingUpdate](
	-- Add the parameters for the stored procedure here
	 @LoanID int,
	 @ParentProcess varchar(100) ,
	 @ChildProcess varchar(500) ,
	 @Sucess bit null,
	 @Reason varchar(500) null ,
	 @ProcessStartTime datetime null,
	 @Comments varchar(max) null,
	 @CreatedBy varchar(100) null,
	 @RequestedBy varchar(255) null,
	 @RequestedDateTime datetime null
	
	)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
	
		INSERT INTO Processing(LoanID,ParentProcess,ChildProcess,Success,Reason,ProcessStartTime,Comments,CreatedBy,CreatedDate
					,RequestedBy,RequestedDateTime) 
			  VALUES(@LoanID,@ParentProcess,@ChildProcess,@Sucess,@Reason,@ProcessStartTime,@Comments,@CreatedBy, GetDate()
			        ,@RequestedBy,@RequestedDateTime)
	

	 
	 
END


GO
/****** Object:  StoredProcedure [dbo].[rptGetBotUsageTime]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	Get Bot Consumption time
--Execution: EXEC [dbo].rptGetBotUsageTime @ProcessStartDate='2/15/2020',@processEndDate='2/25/2020'
-- =============================================
CREATE PROCEDURE [dbo].[rptGetBotUsageTime]
(
 
 @processStartDate date = null,
 @ProcessEndDate date=null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	


DECLARE @originaltable as table
	(
		
		 createddate datetime
		 , ProcessStartTime datetime
		 
		 )

	INSERT INTO @originaltable
	SELECT 
		 o.CreatedDate,
		 DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime--Ignore the milliseconds as while writing to cadence milliseconds are not added
		 
	FROM Origination O
		JOIN Loan L on O.LoanID =L.ID
		JOIN Borrower B ON L.BorrowerID = B.ID
	WHERE CAST(ProcessStartTime as date) between  @processStartDate and @processEndDate 


	SELECT  CAST(ProcessStartTime AS DATE) ProcessedDate,
			CAST( SUM(TimeTakenPerBatch)/60.0 AS decimal(8,2)) TimeTakenInMinutes 
	FROM
	(
	select  DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime
	,min(createddate) starttime
	,max(createddate) enddtime
	,DATEDIFF(s,min(createddate),max(createddate)) TimeTakenPerBatch
	from @originaltable
	group by DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime)
	) A
	GROUP BY CAST(ProcessStartTime AS DATE)

  

	
END


GO
/****** Object:  StoredProcedure [dbo].[rptGetFundingBotUsageTime]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	Get Bot Consumption time
--Execution: EXEC [dbo].rptGetFundingBotUsageTime @ProcessStartDate='2/15/2020',@processEndDate='4/25/2020'
-- =============================================
CREATE PROCEDURE [dbo].[rptGetFundingBotUsageTime]
(
 
 @processStartDate date = null,
 @ProcessEndDate date=null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	


DECLARE @originaltable as table
	(
		
		 createddate datetime
		 , ProcessStartTime datetime
		 
		 )

	INSERT INTO @originaltable
	SELECT 
		 o.CreatedDate,
		 DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime--Ignore the milliseconds as while writing to cadence milliseconds are not added
		 
	FROM Funding O
		JOIN Loan L on O.LoanID =L.ID
		JOIN Borrower B ON L.BorrowerID = B.ID
	WHERE CAST(ProcessStartTime as date) between  @processStartDate and @processEndDate 


	SELECT  CAST(ProcessStartTime AS DATE) ProcessedDate,
			CAST( SUM(TimeTakenPerBatch)/60.0 AS decimal(8,2)) TimeTakenInMinutes 
	FROM
	(
	select  DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime
	,min(createddate) starttime
	,max(createddate) enddtime
	,DATEDIFF(s,min(createddate),max(createddate)) TimeTakenPerBatch
	from @originaltable
	group by DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime)
	) A
	GROUP BY CAST(ProcessStartTime AS DATE)

  

	
END


GO
/****** Object:  StoredProcedure [dbo].[rptGetFundingLog]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	Get Processing Logs based on the Loan assigned  
--Execution: EXEC [dbo].[rptGetFundingLog] @LoanNumber='',@ProcessStartTime=null,@ProcessEndTIme='1/1/2020'
-- =============================================
CREATE PROCEDURE [dbo].[rptGetFundingLog]
(
 @LoanNumber varchar(100),
 @ProcessStartTime datetime = null,
 @ProcessEndTime datetime=null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	IF(@ProcessEndTime IS NOT NULL)
	BEGIN
	SELECT @ProcessEndTime = DATEADD(dd,1,@ProcessEndTime) --adding 1 day as time gets cut off at 12 a.m
	END

	

    -- Insert statements for procedure here
	SELECT B.BorrowerName, L.LoanNumber,L.HippoNumber,O.*
	FROM Funding O
	JOIN Loan L on O.LoanID =L.ID
	JOIN Borrower B ON L.BorrowerID = B.ID
	WHERE
	 ISNULL(LoanNumber,'') = CASE WHEN @LoanNumber= '' 
						    THEN ISNULL(LoanNumber,'')
							ELSE @LoanNumber
							END
	   AND 
	   ProcessStartTime BETWEEN 
					CASE WHEN (isnull(@ProcessStartTime,'') ='' or isnull(@ProcessEndTime,'')='')  THEN '1/1/1900' 
						 ELSE
						     @ProcessStartTime
						  END
						  AND
						  CASE WHEN (isnull(@ProcessStartTime,'') ='' or isnull(@ProcessEndTime,'')='')  THEN '1/1/2100'
						    ELSE
						  	@ProcessEndTime
							END

	order by ProcessStartTime desc,O.CreatedDate
END


GO
/****** Object:  StoredProcedure [dbo].[rptGetFundingStatus]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	GetStatus of the processes executed for the day for Funding
--Execution: EXEC [dbo].rptGetFundingStatus @ProcessStartDate='4/1/2020',@processEndDate='4/8/2020'

-- =============================================
CREATE PROCEDURE [dbo].[rptGetFundingStatus]
(
 
 @processStartDate date = null,
 @ProcessEndDate date=null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	

 


	
	DECLARE @originaltable as table
	(
		 LoanId int
		 ,ProcessStartTime datetime
		 ,borrowername varchar(max)
		 ,EmailID varchar(100)
		 ,ParentProcess varchar(max)
		 ,ChildProcess varchar(max)
		 ,Reason varchar(max)
		 ,comments varchar(max)
		 ,createddate datetime
		 
		 ,RequestedBy varchar(100)
		 ,RequestedDate datetime
		 ,CreatedBy varchar(100)
		 )

	INSERT INTO @originaltable
	SELECT LoanId,
		 --ProcessStartTime,
		 DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime,--Ignore the milliseconds as while writing to cadence milliseconds are not added
		 borrowername,
		 EmailID,
		 ParentProcess,
		 ChildProcess,
		 Reason,
		 comments,
		 o.createddate,
		 RequestedBy,
		 RequestedDateTime,
		 O.CreatedBy

	FROM Funding O
		JOIN Loan L on O.LoanID =L.ID
		JOIN Borrower B ON L.BorrowerID = B.ID
	WHERE CAST(ProcessStartTime as date) between  @processStartDate and @processEndDate 



	
	--select * from @originaltable order by ProcessStartTime desc

	DECLARE @success AS TABLE
	(
		loanid int,
		processstarttime datetime,
		Reason varchar(max)
	)

	INSERT INTO @success 
	SELECT LoanID
			,	 DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime
			,Reason
    FROM Funding
	WHERE ChildProcess in( 'Successfull','Succesful','Success','Successful')
	AND  CAST(ProcessStartTime as date) BETWEEN  @processStartDate AND @processEndDate 

	-- select * from @success

	 declare @finaltable as table(
	 loanid int,
	 LoanNumber varchar(100),
	 ProcessStartTime datetime,
	 BorrowerName varchar(500),
	 EmailID varchar(100),
	 LastSuccesfulProcess varchar(100),
	 LastSuccesfulEvent varchar(100),
	 Reason varchar(500),
	 Comments varchar(max)

	 )

	 

	 insert into @finaltable
	  SELECT DISTINCT s.loanid,LoanNumber,s.ProcessStartTime,b.BorrowerName,EmailID,o.ParentProcess LastSuccesfulProcess,'Success' LastSuccesfulEvent,S.Reason, '' Comments from
	  Funding O
		JOIN Loan L on O.LoanID =L.ID
		JOIN Borrower B ON L.BorrowerID = B.ID
		JOIN @success S on S.loanid = o.loanid and S.processstarttime =  DATEADD(ms, -DATEPART(ms, o.processstarttime), o.processstarttime)

	 UNION
	 
	 SELECT LoanId,LoanNumber,ProcessStartTime,borrowername,EmailID,LastSuccesfullParentProcess,LastSuccesfullChildProcess,Reason,comments from 
	 (

	 SELECT o.LoanId,L.LoanNumber, o.processstarttime, o.borrowername,EmailID,ParentProcess LastSuccesfullParentProcess,ChildProcess LastSuccesfullChildProcess,o.Reason,comments, ROW_NUMBER() over( partition by o.loanid,o.processstarttime order by o.createddate desc ) rownumber  
	 FROM  @originaltable o 
	 JOIN Loan L on O.LoanID =L.ID
	 left JOIN  @success s on  o.LoanId = s.loanid and o.ProcessStartTime = s.processstarttime
	 
	 where s.LoanId is null 
 
	 ) a
	 where a.rownumber = 1


	 declare @TotalTimeTaken decimal(18,2)

	 SELECT @TotalTimeTaken = SUM(A.TimeTakenPerBatch)
	 FROM
	 (
	select  DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime
	,min(createddate) starttime
	,max(createddate) enddtime
	,DATEDIFF(s,min(createddate),max(createddate)) TimeTakenPerBatch
	from @originaltable
	group by DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime)
	) A

	declare @output as table
(
  loanid int,
  LoanNumber varchar(100),	ProcessStartTime datetime,	BorrowerName varchar(100),	EmailID varchar(100),	LastSuccesfulProcess varchar(100),
  LastSuccesfulEvent varchar(100),	Reason varchar(max),	Comments varchar(500),
  	RequestedBy varchar(100)	,	RequestedDate datetime	,	CreatedBy varchar(100)	,
  TimeTakenPerBatch	bigint,
  TotalTimeTaken decimal(16,2)	
  )

  insert into @output
 select F.*, RequestedBy,RequestedDate,CreatedBy,C.TimeTakenPerBatch,@TotalTimeTaken TotalTimeTaken
 
  from @finaltable F
  join(

  select 
		 DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime,
		 LoanId,
		 RequestedBy,RequestedDate,CreatedBy
		from @originaltable
		 group by 
		 DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime),LoanId,RequestedBy,RequestedDate,CreatedBy
	) A on A.LoanId =f.loanid and a.ProcessStartTime =f.processstarttime
	Join
	(

	select  DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime
	,min(createddate) starttime
	,max(createddate) enddtime
	,DATEDIFF(s,min(createddate),max(createddate)) TimeTakenPerBatch
	from @originaltable
	group by DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime)
    ) C On C.ProcessStartTime= F.ProcessStartTime
  
  order by ProcessStartTime 



  SELECT * FROM @output
  



END


GO
/****** Object:  StoredProcedure [dbo].[rptGetLog]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	GetMLO based on the load assigned  
--Execution: EXEC [dbo].rptgetLog @LoanNumber='',@ProcessStartTime=null,@ProcessEndTIme='1/1/2020'
-- =============================================
CREATE PROCEDURE [dbo].[rptGetLog]
(
 @LoanNumber varchar(100),
 @ProcessStartTime datetime = null,
 @ProcessEndTime datetime=null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	IF(@ProcessEndTime IS NOT NULL)
	BEGIN
	SELECT @ProcessEndTime = DATEADD(dd,1,@ProcessEndTime) --adding 1 day as time gets cut off at 12 a.m
	END

	

    -- Insert statements for procedure here
	SELECT B.BorrowerName, L.LoanNumber,L.HippoNumber,O.ParentProcess,o.ChildProcess ,o.Success,o.Reason,o.Comments,o.ProcessStartTime,o.CreatedDate
    ,CASE WHEN ChildProcess ='SSN Check' THEN 1
		  WHEN ChildProcess ='SSN Validation' THEN 2
	      WHEN ChildProcess = 'Download FNM File' THEN 3
		  WHEN ChildProcess = 'Download FNM File' THEN 4
		  WHEN ChildProcess = 'Download Zip File' THEN 5
		  WHEN ChildProcess = 'Download Credit Reports' THEN 6
		  WHEN ChildProcess = 'Applicant Folder Creation' THEN 7
		  WHEN ChildProcess = 'Applicant FNM File Upload' THEN 8
		  WHEN ChildProcess = 'Credit Report Check' THEN 9
		  WHEN ChildProcess = 'Edit1003 Update' THEN 10
		  WHEN ChildProcess = 'Extract Credit Reference Number' THEN 11
		  WHEN ChildProcess = 'Loan Officer Assignment' THEN 12
		  WHEN ChildProcess = 'Path MemberNumber Update' THEN 13
		  --WHEN ChildProcess = 'Download FNM File' THEN 13
		  --WHEN ChildProcess = 'Download FNM File' THEN 14

		  WHEN ChildProcess like '%Upload File To VLF Folder%' THEN 99
		  ELSE
		   100
		  END OrderNumber
	FROM Origination O
	JOIN Loan L on O.LoanID =L.ID
	JOIN Borrower B ON L.BorrowerID = B.ID

	WHERE
	 ISNULL(LoanNumber,'') = CASE WHEN @LoanNumber= '' 
						    THEN ISNULL(LoanNumber,'')
							ELSE @LoanNumber
							END
	   AND 
	   ProcessStartTime BETWEEN 
					CASE WHEN (isnull(@ProcessStartTime,'') ='' or isnull(@ProcessEndTime,'')='')  THEN '1/1/1900' 
						 ELSE
						     @ProcessStartTime
						  END
						  AND
						  CASE WHEN (isnull(@ProcessStartTime,'') ='' or isnull(@ProcessEndTime,'')='')  THEN '1/1/2100'
						    ELSE
						  	@ProcessEndTime
							END

	order by ProcessStartTime desc,O.CreatedDate
END


GO
/****** Object:  StoredProcedure [dbo].[rptGetProcesorBotUsageTime]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	Get Bot Consumption time
--Execution: EXEC [dbo].rptGetProcesorBotUsageTime @ProcessStartDate='2/15/2020',@processEndDate='3/25/2020'
-- =============================================
CREATE PROCEDURE [dbo].[rptGetProcesorBotUsageTime]
(
 
 @processStartDate date = null,
 @ProcessEndDate date=null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	


DECLARE @originaltable as table
	(
		
		 createddate datetime
		 , ProcessStartTime datetime
		 
		 )

	INSERT INTO @originaltable
	SELECT 
		 o.CreatedDate,
		 DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime--Ignore the milliseconds as while writing to cadence milliseconds are not added
		 
	FROM Processing O
		JOIN Loan L on O.LoanID =L.ID
		JOIN Borrower B ON L.BorrowerID = B.ID
	WHERE CAST(ProcessStartTime as date) between  @processStartDate and @processEndDate 


	SELECT  CAST(ProcessStartTime AS DATE) ProcessedDate,
			CAST( SUM(TimeTakenPerBatch)/60.0 AS decimal(8,2)) TimeTakenInMinutes 
	FROM
	(
	select  DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime
	,min(createddate) starttime
	,max(createddate) enddtime
	,DATEDIFF(s,min(createddate),max(createddate)) TimeTakenPerBatch
	from @originaltable
	group by DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime)
	) A
	GROUP BY CAST(ProcessStartTime AS DATE)

  

	
END


GO
/****** Object:  StoredProcedure [dbo].[rptGetProcessorLog]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	Get Processing Logs based on the Loan assigned  
--Execution: EXEC [dbo].rptGetProcessorLog @LoanNumber='',@ProcessStartTime=null,@ProcessEndTIme='1/1/2020'
-- =============================================
CREATE PROCEDURE [dbo].[rptGetProcessorLog]
(
 @LoanNumber varchar(100),
 @ProcessStartTime datetime = null,
 @ProcessEndTime datetime=null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED

	IF(@ProcessEndTime IS NOT NULL)
	BEGIN
	SELECT @ProcessEndTime = DATEADD(dd,1,@ProcessEndTime) --adding 1 day as time gets cut off at 12 a.m
	END

	

    -- Insert statements for procedure here
	SELECT B.BorrowerName, L.LoanNumber,L.HippoNumber,O.*
	FROM Processing O
	JOIN Loan L on O.LoanID =L.ID
	JOIN Borrower B ON L.BorrowerID = B.ID
	WHERE
	 ISNULL(LoanNumber,'') = CASE WHEN @LoanNumber= '' 
						    THEN ISNULL(LoanNumber,'')
							ELSE @LoanNumber
							END
	   AND 
	   ProcessStartTime BETWEEN 
					CASE WHEN (isnull(@ProcessStartTime,'') ='' or isnull(@ProcessEndTime,'')='')  THEN '1/1/1900' 
						 ELSE
						     @ProcessStartTime
						  END
						  AND
						  CASE WHEN (isnull(@ProcessStartTime,'') ='' or isnull(@ProcessEndTime,'')='')  THEN '1/1/2100'
						    ELSE
						  	@ProcessEndTime
							END

	order by ProcessStartTime desc,O.CreatedDate
END


GO
/****** Object:  StoredProcedure [dbo].[rptGetProcessorStatus]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	GetStatus of the processes executed for the day
--Execution: EXEC [dbo].rptGetProcessorStatus @ProcessStartDate='4/7/2020',@processEndDate='4/7/2020'
--select * from processingusers
-- =============================================
CREATE PROCEDURE [dbo].[rptGetProcessorStatus]
(
 
 @processStartDate date = null,
 @ProcessEndDate date=null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
	

 


	
	DECLARE @originaltable as table
	(
		 LoanId int
		 ,ProcessStartTime datetime
		 ,borrowername varchar(max)
		 ,EmailID varchar(100)
		 ,ParentProcess varchar(max)
		 ,ChildProcess varchar(max)
		 ,Reason varchar(max)
		 ,comments varchar(max)
		 ,createddate datetime
		 ,Processor varchar(100)
		 ,UnderWriter varchar(100)
		 ,Funder varchar(100)
		 ,ConditionAnalyst varchar(100)
		 ,RequestedBy varchar(100)
		 ,RequestedDate datetime
		 ,CreatedBy varchar(100)
		 )

	INSERT INTO @originaltable
	SELECT LoanId,
		 --ProcessStartTime,
		 DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime,--Ignore the milliseconds as while writing to cadence milliseconds are not added
		 borrowername,
		 EmailID,
		 ParentProcess,
		 ChildProcess,
		 Reason,
		 comments,
		 o.createddate,
		 L.Processor,
		 L.Underwritter,
		 L.Funding,
		 L.Conditioner,
		 RequestedBy,
		 RequestedDateTime,
		 O.CreatedBy

	FROM Processing O
		JOIN Loan L on O.LoanID =L.ID
		JOIN Borrower B ON L.BorrowerID = B.ID
	WHERE CAST(ProcessStartTime as date) between  @processStartDate and @processEndDate 



	
	--select * from @originaltable order by ProcessStartTime desc

	DECLARE @success AS TABLE
	(
		loanid int,
		processstarttime datetime,
		Reason varchar(max)
	)

	INSERT INTO @success 
	SELECT LoanID
			,	 DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime
			,Reason
    FROM Processing
	WHERE ChildProcess in( 'Successfull','Succesful','Success','Successful')
	AND  CAST(ProcessStartTime as date) BETWEEN  @processStartDate AND @processEndDate 

	-- select * from @success

	 declare @finaltable as table(
	 loanid int,
	 LoanNumber varchar(100),
	 ProcessStartTime datetime,
	 BorrowerName varchar(500),
	 EmailID varchar(100),
	 LastSuccesfulProcess varchar(100),
	 LastSuccesfulEvent varchar(100),
	 Reason varchar(500),
	 Comments varchar(max)

	 )

	 

	 insert into @finaltable
	  SELECT DISTINCT s.loanid,LoanNumber,s.ProcessStartTime,b.BorrowerName,EmailID,o.ParentProcess LastSuccesfulProcess,'Success' LastSuccesfulEvent,S.Reason, '' Comments from
	  Processing O
		JOIN Loan L on O.LoanID =L.ID
		JOIN Borrower B ON L.BorrowerID = B.ID
		JOIN @success S on S.loanid = o.loanid and S.processstarttime =  DATEADD(ms, -DATEPART(ms, o.processstarttime), o.processstarttime)

	 UNION
	 
	 SELECT LoanId,LoanNumber,ProcessStartTime,borrowername,EmailID,LastSuccesfullParentProcess,LastSuccesfullChildProcess,Reason,comments from 
	 (

	 SELECT o.LoanId,L.LoanNumber, o.processstarttime, o.borrowername,EmailID,ParentProcess LastSuccesfullParentProcess,ChildProcess LastSuccesfullChildProcess,o.Reason,comments, ROW_NUMBER() over( partition by o.loanid,o.processstarttime order by o.createddate desc ) rownumber  
	 FROM  @originaltable o 
	 JOIN Loan L on O.LoanID =L.ID
	 left JOIN  @success s on  o.LoanId = s.loanid and o.ProcessStartTime = s.processstarttime
	 
	 where s.LoanId is null 
 
	 ) a
	 where a.rownumber = 1


	 declare @TotalTimeTaken decimal(18,2)

	 SELECT @TotalTimeTaken = SUM(A.TimeTakenPerBatch)
	 FROM
	 (
	select  DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime
	,min(createddate) starttime
	,max(createddate) enddtime
	,DATEDIFF(s,min(createddate),max(createddate)) TimeTakenPerBatch
	from @originaltable
	group by DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime)
	) A

	declare @output as table
(
  loanid int,
  LoanNumber varchar(100),	ProcessStartTime datetime,	BorrowerName varchar(100),	EmailID varchar(100),	LastSuccesfulProcess varchar(100),
  LastSuccesfulEvent varchar(100),	Reason varchar(max),	Comments varchar(500),
  Processor varchar(100),UnderWriter varchar(100)	,	Funder  varchar(100),
  ConditionAnalyst varchar(100)	,	RequestedBy varchar(100)	,	RequestedDate datetime	,	CreatedBy varchar(100)	,
  TimeTakenPerBatch	bigint,
  TotalTimeTaken decimal(16,2)	
  )

  insert into @output
 select F.*, A.Processor,UnderWriter,Funder,ConditionAnalyst,RequestedBy,RequestedDate,CreatedBy,C.TimeTakenPerBatch,@TotalTimeTaken TotalTimeTaken
 
  from @finaltable F
  join(

  select 
		 DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime,
		 LoanId,
		 Processor,UnderWriter,Funder,ConditionAnalyst,RequestedBy,RequestedDate,CreatedBy
		from @originaltable
		 group by 
		 DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime),LoanId,Processor,UnderWriter,Funder,ConditionAnalyst,RequestedBy,RequestedDate,CreatedBy
	) A on A.LoanId =f.loanid and a.ProcessStartTime =f.processstarttime
	Join
	(

	select  DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime
	,min(createddate) starttime
	,max(createddate) enddtime
	,DATEDIFF(s,min(createddate),max(createddate)) TimeTakenPerBatch
	from @originaltable
	group by DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime)
    ) C On C.ProcessStartTime= F.ProcessStartTime
  
  order by ProcessStartTime 



  SELECT * FROM @output
  



END


GO
/****** Object:  StoredProcedure [dbo].[rptGetStatus]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	GetStatus of the processes executed for the day
--Execution: EXEC [dbo].rptgetstatus @ProcessStartDate='3/10/2020',@processEndDate='3/10/2020'
-- =============================================
CREATE PROCEDURE [dbo].[rptGetStatus]
(
 
 @processStartDate date = null,
 @ProcessEndDate date=null
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;
	SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED
	
		DECLARE @originaltable as table
	(
		 LoanId int
		 ,ProcessStartTime datetime
		 ,borrowername varchar(max)
		 ,ParentProcess varchar(max)
		 ,ChildProcess varchar(max)
		 ,Reason varchar(max)
		 ,comments varchar(max)
		 ,createddate datetime
		 ,MLO varchar(100)
		 )

	INSERT INTO @originaltable
	SELECT LoanId,
		 --ProcessStartTime,
		 DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime,--Ignore the milliseconds as while writing to cadence milliseconds are not added
		 borrowername,
		 ParentProcess,
		 ChildProcess,
		 Reason,
		 comments,
		 o.createddate,
		 L.MLO
	FROM Origination O
		JOIN Loan L on O.LoanID =L.ID
		JOIN Borrower B ON L.BorrowerID = B.ID
	WHERE CAST(ProcessStartTime as date) between  @processStartDate and @processEndDate 



	
	--select * from @originaltable

	DECLARE @success AS TABLE
	(
		loanid int,
		processstarttime datetime
	)

	INSERT INTO @success 
	SELECT LoanID
			,	 DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime
    FROM Origination
	WHERE ChildProcess = 'Successfull'
	AND  CAST(ProcessStartTime as date) BETWEEN  @processStartDate AND @processEndDate 

	 --select * from @success

	 declare @finaltable as table(
	 loanid int,
	 LoanNumber varchar(100),
	 ProcessStartTime datetime,
	 BorrowerName varchar(500),

	 LastSuccesfulProcess varchar(100),
	 LastSuccesfulEvent varchar(100),
	 Reason varchar(500),
	 Comments varchar(max)

	 )

	 insert into @finaltable
	  SELECT DISTINCT s.loanid,LoanNumber,s.ProcessStartTime,b.BorrowerName,'Success' LastSuccesfulProcess,'Success' LastSuccesfulEvent,'Success' Reason, '' Comments from
	  Origination O
		JOIN Loan L on O.LoanID =L.ID
		JOIN Borrower B ON L.BorrowerID = B.ID
		JOIN @success S on S.loanid = o.loanid and S.processstarttime =  DATEADD(ms, -DATEPART(ms, o.ProcessStartTime), o.ProcessStartTime) 

	 UNION
	 
	 SELECT LoanId,LoanNumber,ProcessStartTime,borrowername,LastSuccesfullParentProcess,LastSuccesfullChildProcess,Reason,comments from 
	 (

	 SELECT o.LoanId,L.LoanNumber, o.processstarttime, o.borrowername,ParentProcess LastSuccesfullParentProcess,ChildProcess LastSuccesfullChildProcess,Reason,comments, ROW_NUMBER() over( partition by o.loanid,o.processstarttime order by o.createddate desc ) rownumber  
	 FROM  @originaltable o 
	 JOIN Loan L on O.LoanID =L.ID
	 left JOIN  @success s on  o.LoanId = s.loanid and o.ProcessStartTime = s.processstarttime
	 
	 where s.LoanId is null 
 
	 ) a
	 where a.rownumber = 1


	 declare @TotalTimeTaken decimal(18,2)

	 SELECT @TotalTimeTaken = SUM(A.TimeTakenPerBatch)
	 FROM
	 (
	select  DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime
	,min(createddate) starttime
	,max(createddate) enddtime
	,DATEDIFF(s,min(createddate),max(createddate)) TimeTakenPerBatch
	from @originaltable
	group by DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime)
	) A


 

 select case when LoanNumber is null then ''
    else
   isnull(Z.LoanOfficeStatusInCadence,'Yes')
   end LoanOfficerAssignedInCadence,A.MLO,F.*,
 
 C.TimeTakenPerBatch,@TotalTimeTaken TotalTimeTaken
		
  from @finaltable F
  join(

  select 
		 DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime,
		 LoanId,
		 MLO
		from @originaltable
		 group by 
		 DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime),LoanId,MLO
	) A on A.LoanId =f.loanid and a.ProcessStartTime =f.processstarttime
	Join
	(

	select  DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime
	,min(createddate) starttime
	,max(createddate) enddtime
	,DATEDIFF(s,min(createddate),max(createddate)) TimeTakenPerBatch
	from @originaltable
	group by DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime)
    ) C On C.ProcessStartTime= F.ProcessStartTime
  left join
  (
  select LoanID, DATEADD(ms, -DATEPART(ms, ProcessStartTime), ProcessStartTime) ProcessStartTime,' REASON:'+Reason+ ', COMMENTS:'+Comments LoanOfficeStatusInCadence from Origination
  where ChildProcess='Loan Officer Assignment' and ParentProcess='Cadence Process' and Success=0 and Reason='Loan Officer Not Assigned'
 ) Z on Z.LoanID=F.loanid AND z.ProcessStartTime = f.ProcessStartTime
 

--select * from Origination
--where LoanID =1153 and ChildProcess='Loan Officer Assignment' and ParentProcess='Cadence Process'


--select distinct reason from  Origination
--where  ChildProcess='Loan Officer Assignment' and ParentProcess='Cadence Process' and Success =0
  
	
END


GO
/****** Object:  StoredProcedure [dbo].[UpdateDMINumber]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================a
-- Author:		Rakesh Khanai
-- Create date: 7/10/2019
-- Description:	 update the DMINUmber
--EXEC UpdateDMINumber @DMINumber='3',@LoanNumber='2'

-- =============================================
CREATE PROCEDURE [dbo].[UpdateDMINumber] (
	 @DMINumber varchar(100),
	 @LoanNumber varchar(100)
	)
AS
BEGIN

	 UPDATE DmINUMber SET LoanNumber=@LoanNumber
	 WHERE DmINUMber = @DMINumber


END
GO
/****** Object:  StoredProcedure [dbo].[UpdateMLOCounter]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	update mlo after assigning the loan
--Execution: EXEC [dbo].UpdateMLOCounter @ID = 1
-- =============================================
CREATE PROCEDURE [dbo].[UpdateMLOCounter]
(
@ID int =0
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
		 UPDATE userdetails set loancounter =loancounter+1
		  WHERE id =@ID
END


GO
/****** Object:  StoredProcedure [dbo].[UpdateProcessorCounter]    Script Date: 4/23/2020 4:42:23 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Rakesh
-- Create date:  1/28/2020
-- Description:	update Processor Counter after assigning the loan
--Execution: EXEC [dbo].UpdateProcessorCounter @IDs = '7,8,9,12'
-- =============================================
CREATE PROCEDURE [dbo].[UpdateProcessorCounter]
(
@IDs  varchar(max)
)
AS
BEGIN
	-- SET NOCOUNT ON added to prevent extra result sets from
	-- interfering with SELECT statements.
	SET NOCOUNT ON;

    -- Insert statements for procedure here
	
		 UPDATE Processingusers set counter =counter + 1
		  WHERE id in (SELECT part from fn_SplitString(@IDs,','))


END


GO
