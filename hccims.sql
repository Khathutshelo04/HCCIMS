-- ==========================================
-- HCCIMS FULL DATABASE SCHEMA & SEED DATA (STAFF & CLINICAL)
-- ==========================================

CREATE SCHEMA Staff;
GO
CREATE SCHEMA Clinical;
GO

-- ==========================================
-- STAFF SCHEMA: EMPLOYEES & SCHEDULING
-- ==========================================

CREATE TABLE Staff.Employees (
    EmployeeId INT IDENTITY(1,1), 
    IdNumber CHAR(13) NOT NULL,        
    FirstName VARCHAR(50) NOT NULL,           
    LastName VARCHAR(50) NOT NULL,
    Role VARCHAR(20) NOT NULL, 
    
    CONSTRAINT PK_Employees PRIMARY KEY (EmployeeId),
    CONSTRAINT UQ_Employees_IdNumber UNIQUE (IdNumber),
    CONSTRAINT CHK_Employees_Role CHECK (Role IN ('Doctor', 'Nurse', 'Receptionist', 'Admin'))
);

CREATE TABLE Staff.Doctors (
    EmployeeId INT, 
    HpcsaNumber VARCHAR(20) NOT NULL,
    Speciality VARCHAR(50) NOT NULL,
    
    CONSTRAINT PK_Doctors PRIMARY KEY (EmployeeId),
    CONSTRAINT FK_Doctors_Employees FOREIGN KEY (EmployeeId) REFERENCES Staff.Employees(EmployeeId),
    CONSTRAINT UQ_Doctors_HpcsaNumber UNIQUE (HpcsaNumber)
);

CREATE TABLE Staff.Nurses (
    EmployeeId INT,
    SancNumber VARCHAR(20) NOT NULL,
    
    CONSTRAINT PK_Nurses PRIMARY KEY (EmployeeId),
    CONSTRAINT FK_Nurses_Employees FOREIGN KEY (EmployeeId) REFERENCES Staff.Employees(EmployeeId),
    CONSTRAINT UQ_Nurses_SancNumber UNIQUE (SancNumber)
);

CREATE TABLE Staff.Shifts (
    ShiftId INT IDENTITY(1,1),
    EmployeeId INT NOT NULL,
    ShiftDate DATE NOT NULL,
    StartTime TIME(0) NOT NULL,
    EndTime TIME(0) NOT NULL,
    
    CONSTRAINT PK_Shifts PRIMARY KEY (ShiftId),
    CONSTRAINT FK_Shifts_Employees FOREIGN KEY (EmployeeId) REFERENCES Staff.Employees(EmployeeId),
    CONSTRAINT CHK_Shifts_Time CHECK (StartTime < EndTime)
);

-- ==========================================
-- CLINICAL SCHEMA: PATIENT & MEDICAL TABLES
-- ==========================================

CREATE TABLE Clinical.Patients (
    PatientId INT IDENTITY(1,1),
    IdNumber CHAR(13) NOT NULL,
    FirstName VARCHAR(50) NOT NULL,
    LastName VARCHAR(50) NOT NULL,
    DateOfBirth DATE NOT NULL,
    Gender CHAR(1) NOT NULL,
    Phone VARCHAR(15) NOT NULL,
    Email VARCHAR(100),
    PhysicalAddress VARCHAR(255) NOT NULL,
    EmergencyContactName VARCHAR(100) NOT NULL,
    EmergencyContactPhone VARCHAR(15) NOT NULL,
    MedicalAidName VARCHAR(50),     
    MedicalAidNumber VARCHAR(50),   
    BloodType VARCHAR(3),           
    
    CONSTRAINT PK_Patients PRIMARY KEY (PatientId),
    CONSTRAINT UQ_Patients_IdNumber UNIQUE (IdNumber),
    CONSTRAINT CHK_Patients_Gender CHECK (Gender IN ('M', 'F', 'O'))
);

CREATE TABLE Clinical.Allergies (
    AllergyId INT IDENTITY(1,1),
    PatientId INT NOT NULL, 
    Description VARCHAR(100) NOT NULL,
    Severity VARCHAR(20) NOT NULL,
    
    CONSTRAINT PK_Allergies PRIMARY KEY (AllergyId),
    CONSTRAINT FK_Allergies_Patients FOREIGN KEY (PatientId) REFERENCES Clinical.Patients(PatientId),
    CONSTRAINT CHK_Allergies_Severity CHECK (Severity IN ('Mild', 'Moderate', 'Severe', 'Critical'))
);

CREATE TABLE Clinical.Conditions (
    ConditionId INT IDENTITY(1,1),
    PatientId INT NOT NULL,
    ConditionName VARCHAR(120) NOT NULL,
    Status VARCHAR(20) NOT NULL, 
    
    CONSTRAINT PK_Conditions PRIMARY KEY (ConditionId),
    CONSTRAINT FK_Conditions_Patients FOREIGN KEY (PatientId) REFERENCES Clinical.Patients(PatientId),
    CONSTRAINT CHK_Conditions_Status CHECK (Status IN ('Active', 'Resolved'))
);

CREATE TABLE Clinical.Appointments (
    AppointmentId INT IDENTITY(1,1),
    PatientId INT NOT NULL, 
    DoctorId INT NOT NULL,  
    ApptDate DATE NOT NULL,
    StartTime TIME(0) NOT NULL,  
    EndTime TIME(0) NOT NULL,
    ReasonForVisit VARCHAR(100), 
    Status VARCHAR(20) DEFAULT 'Scheduled' NOT NULL, 
    CreatedAt SMALLDATETIME DEFAULT CURRENT_TIMESTAMP NOT NULL, 
    
    CONSTRAINT PK_Appointments PRIMARY KEY (AppointmentId),
    CONSTRAINT FK_Appointments_Patients FOREIGN KEY (PatientId) REFERENCES Clinical.Patients(PatientId),
    CONSTRAINT FK_Appointments_Doctors FOREIGN KEY (DoctorId) REFERENCES Staff.Doctors(EmployeeId),
    CONSTRAINT CHK_Appointments_Status CHECK (Status IN ('Scheduled', 'Completed', 'Cancelled', 'No Show')),
    CONSTRAINT CHK_Appointments_Time CHECK (StartTime < EndTime)
);
GO

-- ==========================================
-- HIGH-SPEED LOOKUP INDEXES
-- ==========================================
CREATE NONCLUSTERED INDEX IX_Shifts_Employee_Date ON Staff.Shifts(EmployeeId, ShiftDate);
CREATE NONCLUSTERED INDEX IX_Patients_LastName_FirstName ON Clinical.Patients(LastName, FirstName);
CREATE NONCLUSTERED INDEX IX_Appointments_Doctor_Date ON Clinical.Appointments(DoctorId, ApptDate);
CREATE NONCLUSTERED INDEX IX_Appointments_Patient ON Clinical.Appointments(PatientId);
CREATE NONCLUSTERED INDEX IX_Allergies_Patient ON Clinical.Allergies(PatientId);
CREATE NONCLUSTERED INDEX IX_Conditions_Patient ON Clinical.Conditions(PatientId);
GO

-- ==========================================
-- SEED DATA: 8 DOCTORS (2 per Specialty)
-- ==========================================

INSERT INTO Staff.Employees (IdNumber, FirstName, LastName, Role) VALUES
('6709034116081', 'Emma', 'Dlamini', 'Doctor'),
('7812104690087', 'Grace', 'Tshisudi', 'Doctor'),
('7411235020091', 'Aisha', 'Mokoena', 'Doctor'),
('6703150094075', 'Johan', 'Naidoo', 'Doctor'),
('7210193083081', 'Sanele', 'Botha', 'Doctor'),
('7707032356072', 'Emma', 'Moodley', 'Doctor'),
('8101250202055', 'Mpho', 'Govender', 'Doctor'),
('7312110953068', 'Liam', 'Tshisudi', 'Doctor');

INSERT INTO Staff.Doctors (EmployeeId, HpcsaNumber, Speciality) VALUES
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '6709034116081'), 'MP730226', 'General Practice'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7812104690087'), 'MP715011', 'General Practice'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7411235020091'), 'MP956436', 'Cardiology'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '6703150094075'), 'MP363730', 'Cardiology'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7210193083081'), 'MP194020', 'Pediatrics'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7707032356072'), 'MP838171', 'Pediatrics'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '8101250202055'), 'MP195089', 'Neurology'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7312110953068'), 'MP729318', 'Neurology');

-- ==========================================
-- SEED DATA: 15 NURSES
-- ==========================================

INSERT INTO Staff.Employees (IdNumber, FirstName, LastName, Role) VALUES
('9201114297046', 'Kagiso', 'Mahlangu', 'Nurse'),
('9303279714032', 'Mia', 'Khumalo', 'Nurse'),
('9306218517072', 'Siyabonga', 'Dlamini', 'Nurse'),
('7506233845084', 'Nomsa', 'Naidoo', 'Nurse'),
('8310203292063', 'Bongani', 'Zwane', 'Nurse'),
('7106279892078', 'Njabulo', 'Mahlangu', 'Nurse'),
('7812193977078', 'Grace', 'Mahlangu', 'Nurse'),
('8906247376057', 'Njabulo', 'van der Merwe', 'Nurse'),
('9302093710026', 'Mia', 'Louw', 'Nurse'),
('7211194083051', 'Johan', 'Louw', 'Nurse'),
('8806138681001', 'Sipho', 'Nkosi', 'Nurse'),
('9407099998033', 'Aisha', 'Petersen', 'Nurse'),
('9407072926020', 'Naledi', 'Tshabalala', 'Nurse'),
('9510061104083', 'Siyabonga', 'Williams', 'Nurse'),
('9208220691062', 'Njabulo', 'Patel', 'Nurse');

INSERT INTO Staff.Nurses (EmployeeId, SancNumber) VALUES
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '9201114297046'), 'SANC637866'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '9303279714032'), 'SANC838892'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '9306218517072'), 'SANC990900'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7506233845084'), 'SANC802287'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '8310203292063'), 'SANC109727'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7106279892078'), 'SANC477420'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7812193977078'), 'SANC947206'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '8906247376057'), 'SANC559749'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '9302093710026'), 'SANC602421'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7211194083051'), 'SANC998249'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '8806138681001'), 'SANC708845'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '9407099998033'), 'SANC146828'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '9407072926020'), 'SANC711388'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '9510061104083'), 'SANC237590'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '9208220691062'), 'SANC921494');

-- ==========================================
-- SEED DATA: STAGGERED SHIFTS
-- ==========================================

INSERT INTO Staff.Shifts (EmployeeId, ShiftDate, StartTime, EndTime) VALUES
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '6709034116081'), '2026-10-01', '08:00', '16:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7812104690087'), '2026-10-01', '09:00', '17:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7411235020091'), '2026-10-01', '10:00', '18:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '6703150094075'), '2026-10-01', '12:00', '20:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7210193083081'), '2026-10-01', '07:00', '15:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7707032356072'), '2026-10-01', '08:00', '16:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '8101250202055'), '2026-10-01', '09:00', '17:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7312110953068'), '2026-10-01', '10:00', '18:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '9201114297046'), '2026-10-01', '10:00', '18:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '9303279714032'), '2026-10-01', '12:00', '20:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '9306218517072'), '2026-10-01', '07:00', '15:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7506233845084'), '2026-10-01', '08:00', '16:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '8310203292063'), '2026-10-01', '09:00', '17:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7106279892078'), '2026-10-01', '10:00', '18:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7812193977078'), '2026-10-01', '12:00', '20:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '8906247376057'), '2026-10-01', '07:00', '15:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '9302093710026'), '2026-10-01', '08:00', '16:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7211194083051'), '2026-10-01', '09:00', '17:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '8806138681001'), '2026-10-01', '10:00', '18:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '9407099998033'), '2026-10-01', '12:00', '20:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '9407072926020'), '2026-10-01', '07:00', '15:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '9510061104083'), '2026-10-01', '08:00', '16:00'),
((SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '9208220691062'), '2026-10-01', '09:00', '17:00');

-- ==========================================
-- SEED DATA: 50 UNIQUE PATIENTS
-- ==========================================

INSERT INTO Clinical.Patients (IdNumber, FirstName, LastName, DateOfBirth, Gender, Phone, Email, PhysicalAddress, EmergencyContactName, EmergencyContactPhone, MedicalAidName, MedicalAidNumber, BloodType) VALUES
('0207304159066', 'Liam', 'Patel', '2002-07-30', 'F', '0879797368', 'liam.patel926@email.com', '7 Cape Road, Mill Park, Gqeberha', 'Tshepo Ndlovu', '0724245056', 'Bestmed', '178848440', 'A+'),
('8102180211008', 'Siyabonga', 'Botha', '1981-02-18', 'F', '0850758128', 'siyabonga.botha560@email.com', '12 Walmer Boulevard, Walmer, Gqeberha', 'Njabulo van der Merwe', '0776782671', 'Bestmed', '713770386', 'B+'),
('6310228552095', 'Mpho', 'Petersen', '1963-10-22', 'M', '0841316553', 'mpho.petersen794@email.com', '88 Summerstrand Way, Gqeberha', 'Nomsa Naidoo', '0714583896', 'Bonitas', '794958409', 'B+'),
('5401228701037', 'Khanya', 'Tshabalala', '1954-01-22', 'M', '0812747414', 'khanya.tshabalala232@email.com', '10 Beach Road, Humewood, Gqeberha', 'Johan Radebe', '0728484701', 'Bonitas', '809982702', 'B+'),
('8412263484086', 'Noah', 'Smith', '1984-12-26', 'F', '0861430266', 'noah.smith412@email.com', '42 Mulangaphuma, Tshakhuma', 'Lungile Goliath', '0745358813', 'Bestmed', '634296521', 'O+'),
('7510231449058', 'Siyabonga', 'Nkosi', '1975-10-23', 'F', '0826120303', 'siyabonga.nkosi639@email.com', '10 Beach Road, Humewood, Gqeberha', 'Liam Zwane', '0722692439', 'Bonitas', '348393869', 'A+'),
('5805102706068', 'Liam', 'Tshabalala', '1958-05-10', 'F', '0834488220', 'liam.tshabalala127@email.com', '12 Walmer Boulevard, Walmer, Gqeberha', 'Noah Goliath', '0757204606', 'GEMS', '837829360', 'B-'),
('5911044553093', 'Kagiso', 'Mokoena', '1959-11-04', 'F', '0885541950', 'kagiso.mokoena374@email.com', '10 Beach Road, Humewood, Gqeberha', 'David van der Merwe', '0745394922', 'Discovery Health', '568208209', 'B+'),
('5907077918021', 'Lindiwe', 'Botha', '1959-07-07', 'M', '0847149597', 'lindiwe.botha702@email.com', '88 Summerstrand Way, Gqeberha', 'Bongani Botha', '0731661517', 'Momentum Health', '375011139', 'A-'),
('5103312105060', 'Thabo', 'van der Merwe', '1951-03-31', 'F', '0841571416', 'thabo.van der merwe123@email.com', '19 Zwide Street, Zwide, Gqeberha', 'Aisha van der Merwe', '0785320070', 'GEMS', '476139084', 'AB-'),
('9011308311059', 'Johan', 'Petersen', '1990-11-30', 'M', '0872098495', 'johan.petersen536@email.com', '88 Summerstrand Way, Gqeberha', 'Anathi Venter', '0777278217', 'Momentum Health', '517736366', 'AB+'),
('8112198577004', 'Khanya', 'Botha', '1981-12-19', 'M', '0848863507', 'khanya.botha844@email.com', '88 Summerstrand Way, Gqeberha', 'Bongani Tshisudi', '0765920005', 'Momentum Health', '728789737', 'A+'),
('9808221617080', 'Sanele', 'van der Merwe', '1998-08-22', 'F', '0831759933', 'sanele.van der merwe733@email.com', '88 Summerstrand Way, Gqeberha', 'Aisha Khumalo', '0726868746', 'GEMS', '480148254', 'AB+'),
('5208014736025', 'Karabo', 'Naidoo', '1952-08-01', 'F', '0860624533', 'karabo.naidoo345@email.com', '55 Main Road, Tshakhuma', 'Anathi Dlamini', '0726805141', 'Bonitas', '682963499', 'A+'),
('9807262088023', 'Sipho', 'Ndlovu', '1998-07-26', 'F', '0847155703', 'sipho.ndlovu654@email.com', '90 Korsten Avenue, Korsten, Gqeberha', 'Karabo Zwane', '0752244317', 'Bonitas', '772997487', 'A-'),
('6602019211045', 'Rethabile', 'Radebe', '1966-02-01', 'M', '0852613852', 'rethabile.radebe157@email.com', '14 Newton Street, Newton Park, Gqeberha', 'Rethabile Dlamini', '0773155489', 'Discovery Health', '338197458', 'B+'),
('8510201904084', 'Naledi', 'Mbeki', '1985-10-20', 'F', '0860294942', 'naledi.mbeki467@email.com', '90 Korsten Avenue, Korsten, Gqeberha', 'Rethabile Nkosi', '0783658086', 'Bestmed', '946783894', 'AB+'),
('6611108363027', 'Emma', 'Ndlovu', '1966-11-10', 'M', '0857571095', 'emma.ndlovu933@email.com', '10 Beach Road, Humewood, Gqeberha', 'Khanya Govender', '0715034008', 'Bonitas', '190416914', 'AB+'),
('8306121130010', 'Nomsa', 'Mbeki', '1983-06-12', 'F', '0888166830', 'nomsa.mbeki414@email.com', '33 High Street, Grahamstown', 'Thabo Naidoo', '0761080833', 'GEMS', '654690657', 'B+'),
('9508245700026', 'Naledi', 'Jacobs', '1995-08-24', 'M', '0845090429', 'naledi.jacobs417@email.com', '14 Newton Street, Newton Park, Gqeberha', 'Sanele Williams', '0798887710', 'Bonitas', '274172362', 'AB+'),
('7606292926026', 'Johan', 'Louw', '1976-06-29', 'F', '0894532675', 'johan.louw109@email.com', '33 High Street, Grahamstown', 'Rethabile Mahlangu', '0766727512', 'Momentum Health', '972016138', 'B+'),
('9604236471058', 'David', 'Goliath', '1996-04-23', 'M', '0813814208', 'david.goliath219@email.com', '10 Beach Road, Humewood, Gqeberha', 'Anathi Baloyi', '0796356336', 'Discovery Health', '502177935', 'A-'),
('8301061771082', 'Lethabo', 'Petersen', '1983-01-06', 'F', '0843306810', 'lethabo.petersen229@email.com', '88 Summerstrand Way, Gqeberha', 'Naledi Mahlangu', '0724414113', 'Discovery Health', '509308853', 'AB+'),
('0505080962057', 'Njabulo', 'Mahlangu', '2005-05-08', 'F', '0826232107', 'njabulo.mahlangu668@email.com', '10 Beach Road, Humewood, Gqeberha', 'Mary Venter', '0771194403', 'GEMS', '470568629', 'A-'),
('5603129053044', 'Grace', 'Tshabalala', '1956-03-12', 'M', '0840339638', 'grace.tshabalala272@email.com', '12 Walmer Boulevard, Walmer, Gqeberha', 'Karabo Radebe', '0785373460', 'Momentum Health', '446489639', 'O-'),
('8602281447037', 'Mary', 'Baloyi', '1986-02-28', 'F', '0856781129', 'mary.baloyi877@email.com', '12 Walmer Boulevard, Walmer, Gqeberha', 'Karabo Williams', '0761221192', 'Bonitas', '265762702', 'O-'),
('0010308533045', 'Mia', 'van der Merwe', '2000-10-30', 'M', '0852954311', 'mia.van der merwe372@email.com', '90 Korsten Avenue, Korsten, Gqeberha', 'Zandile Patel', '0783164356', 'Momentum Health', '351570087', 'AB-'),
('6211157194049', 'Mpho', 'Moodley', '1962-11-15', 'M', '0863854172', 'mpho.moodley509@email.com', '14 Newton Street, Newton Park, Gqeberha', 'Nomsa Baloyi', '0754180436', 'Bestmed', '461676063', 'A-'),
('9405198476055', 'Thabo', 'Naidoo', '1994-05-19', 'M', '0833215571', 'thabo.naidoo110@email.com', '19 Zwide Street, Zwide, Gqeberha', 'Nomsa Baloyi', '0743846223', 'Bonitas', '458644464', 'O+'),
('9209122775000', 'Grace', 'Dlamini', '1992-09-12', 'F', '0895398731', 'grace.dlamini223@email.com', '19 Zwide Street, Zwide, Gqeberha', 'Naledi Ndlovu', '0738081599', 'Bestmed', '652914281', 'AB+'),
('0511160647083', 'Nomsa', 'Tshisudi', '2005-11-16', 'F', '0811529160', 'nomsa.tshisudi197@email.com', '42 Mulangaphuma, Tshakhuma', 'Naledi Dlamini', '0772205072', 'Bonitas', '750775672', 'B+'),
('7710059649068', 'Anathi', 'Williams', '1977-10-05', 'M', '0885048842', 'anathi.williams236@email.com', '88 Summerstrand Way, Gqeberha', 'Sipho Zwane', '0766309126', 'Discovery Health', '298919457', 'B-'),
('9203272814055', 'Lethabo', 'Mahlangu', '1992-03-27', 'F', '0844272441', 'lethabo.mahlangu600@email.com', '12 Walmer Boulevard, Walmer, Gqeberha', 'Mia Zwane', '0714927865', 'Bestmed', '243059249', 'A+'),
('9302142079073', 'Lungile', 'Zwane', '1993-02-14', 'F', '0878758900', 'lungile.zwane962@email.com', '55 Main Road, Tshakhuma', 'Bongani Mbeki', '0788080251', 'Discovery Health', '975034788', 'O+'),
('5510173953091', 'Noah', 'Radebe', '1955-10-17', 'F', '0880121102', 'noah.radebe710@email.com', '12 Walmer Boulevard, Walmer, Gqeberha', 'Siyabonga Botha', '0798658609', 'Momentum Health', '486632201', 'B+'),
('5701027109088', 'Noah', 'Naidoo', '1957-01-02', 'M', '0894629829', 'noah.naidoo208@email.com', '33 High Street, Grahamstown', 'Johan Ndlovu', '0772251448', 'Bonitas', '325131600', 'O+'),
('9507319208034', 'Grace', 'Baloyi', '1995-07-31', 'M', '0875576576', 'grace.baloyi239@email.com', '10 Beach Road, Humewood, Gqeberha', 'Anathi Botha', '0758821127', 'Bestmed', '671985370', 'B-'),
('6308216179029', 'Thabo', 'Tshabalala', '1963-08-21', 'M', '0814633714', 'thabo.tshabalala387@email.com', '19 Zwide Street, Zwide, Gqeberha', 'Kamogelo Goliath', '0728681589', 'Momentum Health', '680163320', 'AB-'),
('6106251378020', 'Grace', 'Goliath', '1961-06-25', 'F', '0830655901', 'grace.goliath523@email.com', '33 High Street, Grahamstown', 'Siyabonga Jacobs', '0713893609', 'Momentum Health', '337228809', 'AB-'),
('9809108814062', 'Emma', 'Botha', '1998-09-10', 'M', '0829548259', 'emma.botha831@email.com', '10 Beach Road, Humewood, Gqeberha', 'Thabo Mahlangu', '0711015315', 'Discovery Health', '201636153', 'AB-'),
('0207292693002', 'Lindiwe', 'Mbeki', '2002-07-29', 'F', '0822086821', 'lindiwe.mbeki532@email.com', '55 Main Road, Tshakhuma', 'Johan Goliath', '0742362684', 'Bonitas', '810411878', 'O-'),
('6901311298086', 'Sanele', 'Govender', '1969-01-31', 'F', '0871657845', 'sanele.govender976@email.com', '12 Walmer Boulevard, Walmer, Gqeberha', 'Khanya Mbeki', '0751433992', 'Bestmed', '700239801', 'O-'),
('5803266601011', 'Lungile', 'Baloyi', '1958-03-26', 'M', '0893508297', 'lungile.baloyi804@email.com', '42 Mulangaphuma, Tshakhuma', 'Aisha Goliath', '0737322411', 'Bestmed', '303258528', 'O+'),
('5209267201045', 'Tshepo', 'Ndlovu', '1952-09-26', 'M', '0873964741', 'tshepo.ndlovu633@email.com', '90 Korsten Avenue, Korsten, Gqeberha', 'Emma Zwane', '0757537639', 'Bestmed', '248119981', 'A-'),
('6212027940076', 'Lethabo', 'Moodley', '1962-12-02', 'M', '0889596200', 'lethabo.moodley149@email.com', '10 Beach Road, Humewood, Gqeberha', 'Naledi Tshisudi', '0744206273', 'Discovery Health', '594982285', 'O-'),
('8101137261040', 'Lerato', 'Williams', '1981-01-13', 'M', '0815620131', 'lerato.williams171@email.com', '10 Beach Road, Humewood, Gqeberha', 'Njabulo Nkosi', '0785749525', 'Discovery Health', '514715765', 'O-'),
('0501104430002', 'Emma', 'Botha', '2005-01-10', 'F', '0828028205', 'emma.botha127@email.com', '88 Summerstrand Way, Gqeberha', 'Tshepo Smith', '0732572086', 'GEMS', '373748579', 'A+'),
('5402229931081', 'Sanele', 'Botha', '1954-02-22', 'M', '0830566570', 'sanele.botha414@email.com', '90 Korsten Avenue, Korsten, Gqeberha', 'Mary Botha', '0772903586', 'Bonitas', '529538128', 'B-'),
('9602143431007', 'Mary', 'Petersen', '1996-02-14', 'F', '0834734473', 'mary.petersen549@email.com', '7 Cape Road, Mill Park, Gqeberha', 'Grace van der Merwe', '0788970129', 'Bestmed', '734100379', 'O+'),
('9304269087036', 'Sanele', 'Khumalo', '1993-04-26', 'M', '0881073294', 'sanele.khumalo576@email.com', '42 Mulangaphuma, Tshakhuma', 'Bongani Dlamini', '0779974347', 'Momentum Health', '387019563', 'O+');

-- ==========================================
-- SEED DATA: ALLERGIES & CONDITIONS
-- ==========================================

INSERT INTO Clinical.Allergies (PatientId, Description, Severity) VALUES
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '0207304159066'), 'Penicillin', 'Severe'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8102180211008'), 'Shellfish', 'Mild'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '6310228552095'), 'Aspirin', 'Moderate'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5401228701037'), 'Peanuts', 'Moderate'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8412263484086'), 'Pollen', 'Critical'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '7510231449058'), 'Peanuts', 'Mild'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5805102706068'), 'Ibuprofen', 'Critical'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5911044553093'), 'Penicillin', 'Moderate'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5907077918021'), 'Latex', 'Mild'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5103312105060'), 'Sulfonamides', 'Moderate'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9011308311059'), 'Sulfonamides', 'Severe'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8112198577004'), 'Peanuts', 'Severe'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9808221617080'), 'Shellfish', 'Mild'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5208014736025'), 'Latex', 'Mild'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9807262088023'), 'Pollen', 'Mild'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '6602019211045'), 'Aspirin', 'Critical'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8510201904084'), 'Penicillin', 'Moderate'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '6611108363027'), 'Pollen', 'Mild'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8306121130010'), 'Sulfonamides', 'Mild'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9508245700026'), 'Shellfish', 'Mild'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '7606292926026'), 'Sulfonamides', 'Moderate'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9604236471058'), 'Penicillin', 'Severe'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8301061771082'), 'Penicillin', 'Critical'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '0505080962057'), 'Sulfonamides', 'Mild'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5603129053044'), 'Shellfish', 'Moderate'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8602281447037'), 'Pollen', 'Mild'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '0010308533045'), 'Aspirin', 'Moderate'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '6211157194049'), 'Ibuprofen', 'Critical'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9405198476055'), 'Peanuts', 'Moderate'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9209122775000'), 'Penicillin', 'Mild');

INSERT INTO Clinical.Conditions (PatientId, ConditionName, Status) VALUES
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '0207304159066'), 'Eczema', 'Resolved'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8102180211008'), 'Type 2 Diabetes', 'Resolved'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '6310228552095'), 'Asthma', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5401228701037'), 'Arthritis', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8412263484086'), 'Arthritis', 'Resolved'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '7510231449058'), 'Eczema', 'Resolved'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5805102706068'), 'Asthma', 'Resolved'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5911044553093'), 'Type 2 Diabetes', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5907077918021'), 'Bronchitis', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5103312105060'), 'Asthma', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9011308311059'), 'Sinusitis', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8112198577004'), 'Bronchitis', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9808221617080'), 'Sinusitis', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5208014736025'), 'Asthma', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9807262088023'), 'Eczema', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '6602019211045'), 'Sinusitis', 'Resolved'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8510201904084'), 'Bronchitis', 'Resolved'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '6611108363027'), 'Type 2 Diabetes', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8306121130010'), 'Gastroenteritis', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9508245700026'), 'Type 2 Diabetes', 'Resolved'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '7606292926026'), 'Arthritis', 'Resolved'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9604236471058'), 'Asthma', 'Resolved'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8301061771082'), 'Hypertension', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '0505080962057'), 'Bronchitis', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5603129053044'), 'Sinusitis', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8602281447037'), 'Arthritis', 'Resolved'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '0010308533045'), 'Asthma', 'Resolved'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '6211157194049'), 'Type 2 Diabetes', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9405198476055'), 'Asthma', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9209122775000'), 'Gastroenteritis', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '0511160647083'), 'Eczema', 'Resolved'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '7710059649068'), 'Hypertension', 'Resolved'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9203272814055'), 'Gastroenteritis', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9302142079073'), 'Eczema', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5510173953091'), 'Sinusitis', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5701027109088'), 'Type 2 Diabetes', 'Active'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9507319208034'), 'Bronchitis', 'Resolved'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '6308216179029'), 'Type 2 Diabetes', 'Resolved'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '6106251378020'), 'Gastroenteritis', 'Resolved'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9809108814062'), 'Sinusitis', 'Resolved');

-- ==========================================
-- SEED DATA: APPOINTMENTS
-- ==========================================

INSERT INTO Clinical.Appointments (PatientId, DoctorId, ApptDate, StartTime, EndTime, ReasonForVisit, Status) VALUES
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '0207304159066'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '6709034116081'), '2026-10-01', '09:00', '09:30', 'Chest pains', 'No Show'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8102180211008'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7812104690087'), '2026-10-01', '09:00', '09:30', 'Fever and chills', 'No Show'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '6310228552095'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7411235020091'), '2026-10-01', '09:00', '09:30', 'Vaccination', 'Cancelled'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5401228701037'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '6703150094075'), '2026-10-01', '09:00', '09:30', 'Allergic reaction', 'Completed'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8412263484086'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7210193083081'), '2026-10-01', '09:00', '09:30', 'Severe Migraine', 'Scheduled'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '7510231449058'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7707032356072'), '2026-10-01', '09:00', '09:30', 'Prescription renewal', 'Completed'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5805102706068'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '8101250202055'), '2026-10-01', '09:00', '09:30', 'Chest pains', 'No Show'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5911044553093'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7312110953068'), '2026-10-01', '09:00', '09:30', 'Prescription renewal', 'Cancelled'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5907077918021'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '6709034116081'), '2026-10-01', '09:00', '09:30', 'Follow-up consultation', 'Scheduled'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5103312105060'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7812104690087'), '2026-10-01', '09:00', '09:30', 'Prescription renewal', 'No Show'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9011308311059'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7411235020091'), '2026-10-01', '09:00', '09:30', 'Follow-up consultation', 'Cancelled'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8112198577004'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '6703150094075'), '2026-10-01', '09:00', '09:30', 'Blood test results', 'No Show'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9808221617080'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7210193083081'), '2026-10-01', '09:00', '09:30', 'Prescription renewal', 'Cancelled'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5208014736025'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7707032356072'), '2026-10-01', '09:00', '09:30', 'Blood test results', 'No Show'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9807262088023'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '8101250202055'), '2026-10-01', '09:00', '09:30', 'Chest pains', 'Cancelled'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '6602019211045'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7312110953068'), '2026-10-01', '09:00', '09:30', 'Vaccination', 'Completed'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8510201904084'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '6709034116081'), '2026-10-01', '09:00', '09:30', 'Follow-up consultation', 'Cancelled'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '6611108363027'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7812104690087'), '2026-10-01', '09:00', '09:30', 'Routine Checkup', 'Completed'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8306121130010'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7411235020091'), '2026-10-01', '09:00', '09:30', 'Chest pains', 'Completed'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9508245700026'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '6703150094075'), '2026-10-01', '09:00', '09:30', 'Annual physical', 'Completed'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '7606292926026'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7210193083081'), '2026-10-01', '09:00', '09:30', 'Vaccination', 'No Show'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '9604236471058'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7707032356072'), '2026-10-01', '09:00', '09:30', 'Vaccination', 'Scheduled'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '8301061771082'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '8101250202055'), '2026-10-01', '09:00', '09:30', 'Fever and chills', 'Cancelled'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '0505080962057'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '7312110953068'), '2026-10-01', '09:00', '09:30', 'Routine Checkup', 'Cancelled'),
((SELECT PatientId FROM Clinical.Patients WHERE IdNumber = '5603129053044'), (SELECT EmployeeId FROM Staff.Employees WHERE IdNumber = '6709034116081'), '2026-10-01', '09:00', '09:30', 'Blood test results', 'Cancelled');
GO