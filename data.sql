USE [Mortgage]
GO
/****** Object:  Table [dbo].[Borrower]    Script Date: 5/10/2020 9:17:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Borrower](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[EmailID] [varchar](255) NOT NULL,
	[BorrowerName] [varchar](255) NOT NULL,
	[CreatedBy] [varchar](100) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [varchar](100) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_Borrower] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Funding]    Script Date: 5/10/2020 9:17:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Funding](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LoanID] [int] NOT NULL,
	[ParentProcess] [varchar](255) NOT NULL,
	[ChildProcess] [varchar](255) NOT NULL,
	[Success] [bit] NULL,
	[Reason] [varchar](500) NULL,
	[ProcessStartTime] [datetime] NULL,
	[Comments] [varchar](max) NULL,
	[CreatedBy] [varchar](255) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [varchar](255) NULL,
	[ModifiedDate] [datetime] NULL,
	[RequestedBy] [varchar](100) NULL,
	[RequestedDateTime] [datetime] NULL,
 CONSTRAINT [PK_Funding] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Loan]    Script Date: 5/10/2020 9:17:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Loan](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[BorrowerID] [int] NOT NULL,
	[DateCreatedinHippo] [varchar](100) NULL,
	[HippoNumber] [varchar](50) NULL,
	[LoanNumber] [varchar](50) NULL,
	[Processor] [varchar](100) NULL,
	[MLO] [varchar](100) NULL,
	[Underwritter] [varchar](100) NULL,
	[Conditioner] [varchar](100) NULL,
	[Funding] [varchar](100) NULL,
	[Closing] [varchar](100) NULL,
	[CreatedBy] [varchar](100) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [varchar](100) NULL,
	[ModifiedDate] [datetime] NULL,
	[FundingAmount] [decimal](16, 2) NULL,
 CONSTRAINT [PK_Loan] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Origination]    Script Date: 5/10/2020 9:17:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Origination](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LoanID] [int] NOT NULL,
	[ParentProcess] [varchar](255) NOT NULL,
	[ChildProcess] [varchar](255) NOT NULL,
	[Success] [bit] NULL,
	[Reason] [varchar](500) NULL,
	[ProcessStartTime] [datetime] NULL,
	[Comments] [varchar](max) NULL,
	[CreatedBy] [varchar](255) NULL,
	[CreatedDate] [datetime] NULL,
	[ModifiedBy] [varchar](255) NULL,
	[ModifiedDate] [datetime] NULL,
 CONSTRAINT [PK_MLO] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[Processing]    Script Date: 5/10/2020 9:17:50 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[Processing](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[LoanID] [int] NOT NULL,
	[ParentProcess] [varchar](255) NOT NULL,
	[ChildProcess] [varchar](255) NOT NULL,
	[Success] [bit] NULL,
	[Reason] [varchar](500) NULL,
	[ProcessStartTime] [datetime] NULL,
	[Comments] [varchar](max) NULL,
	[CreatedBy] [varchar](255) NULL,
	[CreatedDate] [datetime] NULL,
	[RequestedBy] [varchar](255) NULL,
	[RequestedDateTime] [datetime] NULL,
 CONSTRAINT [PK_Processing] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
ALTER TABLE [dbo].[Funding]  WITH CHECK ADD  CONSTRAINT [FK_Funding_Loan] FOREIGN KEY([LoanID])
REFERENCES [dbo].[Loan] ([ID])
GO
ALTER TABLE [dbo].[Funding] CHECK CONSTRAINT [FK_Funding_Loan]
GO
ALTER TABLE [dbo].[Loan]  WITH CHECK ADD  CONSTRAINT [FK_Loan_Borrower] FOREIGN KEY([BorrowerID])
REFERENCES [dbo].[Borrower] ([ID])
GO
ALTER TABLE [dbo].[Loan] CHECK CONSTRAINT [FK_Loan_Borrower]
GO
ALTER TABLE [dbo].[Origination]  WITH CHECK ADD  CONSTRAINT [FK_MLO_Loan] FOREIGN KEY([LoanID])
REFERENCES [dbo].[Loan] ([ID])
GO
ALTER TABLE [dbo].[Origination] CHECK CONSTRAINT [FK_MLO_Loan]
GO
ALTER TABLE [dbo].[Origination]  WITH CHECK ADD  CONSTRAINT [FK_Processing_Loan] FOREIGN KEY([LoanID])
REFERENCES [dbo].[Loan] ([ID])
GO
ALTER TABLE [dbo].[Origination] CHECK CONSTRAINT [FK_Processing_Loan]
GO
ALTER TABLE [dbo].[Processing]  WITH CHECK ADD  CONSTRAINT [FK_Processing_Loan1] FOREIGN KEY([LoanID])
REFERENCES [dbo].[Loan] ([ID])
GO
ALTER TABLE [dbo].[Processing] CHECK CONSTRAINT [FK_Processing_Loan1]
GO
