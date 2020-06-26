set termout off

-- Administrator Tables

create table Users(
	UserId integer,
	Username varchar(32),
	Password varchar(32),
	constraint user_unique unique (Username),
	primary key (UserId));

create table Roles(
	RoleId integer,
	RoleName varchar(32),
	constraint role_unique unique (RoleName),
	primary key (RoleId));

create table UserRoles(
	UserId integer,
	RoleId integer,
	primary key (userId, RoleId),
	foreign key (UserId) references Users(UserId),
	foreign key (RoleId) references Roles(RoleId));

create table Privileges(
	PrivId integer,
	PrivName varchar(32),
	constraint priv_unique unique (PrivName),
	primary key (PrivId));

create table UserPrivileges(
	RoleId integer,
	PrivId integer,
	TableName varchar(32),
	primary key(RoleId, PrivId, TableName),
	foreign key (RoleId) references Roles(RoleId),
	foreign key (PrivId) references Privileges(PrivId));

----------------------------------------------------------------------------------------------------

-- User Tables

create table Doctors(
	DoctorId integer,
	FirstName varchar(30),
	LastName varchar(30),
	Address varchar(50),
	OwnerRole number(10, 0),
        primary key (DoctorId));

create table Patients(
	PatientId integer,
	FirstName varchar(30),
	LastName varchar(30),
	Address varchar(50),
	OwnerRole number(10, 0),
	primary key(PatientId));

create table Pharmacists(
	PharmaId integer,
	FirstName varchar(30),
	LastName varchar(32),
        Address varchar(20),
	OwnerRole number(10, 0),
	primary key(PharmaId));

create table PharmaCompanies(
	CompanyId integer,
	CompanyName varchar(50),
      Address varchar(50),
	primary key(CompanyId));

create table PharmaProducts(
	ProductId integer,
	Count integer,
	UnitPrice Number(10,4),
	OrderDate date,
	Status varchar(20), --delivered or not delivered
	primary key(ProductId));

create table TreatmentDetails(
	DoctorId integer,
	PatientId integer,
	PharmaId integer,
        ProductId integer,
	CompanyId integer,
	primary key(DoctorId, PatientId, PharmaId, ProductId, CompanyId),
        foreign key (DoctorId) references Doctors(DoctorId),
        foreign key (PatientId) references Patients(PatientId),
        foreign key (PharmaId) references Pharmacists(PharmaId),
        foreign key (ProductId) references PharmaProducts(ProductId),
        foreign key (CompanyId) references PharmaCompanies(CompanyId));

set termout on
