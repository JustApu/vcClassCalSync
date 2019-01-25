--
-- Database: `classCalSync`
--

-- --------------------------------------------------------

--
-- Table structure for table `curClasses`
--

CREATE TABLE IF NOT EXISTS `curClasses` (
  `ID` int(10) unsigned NOT NULL,
  `Class` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `curEnroll`
--

CREATE TABLE IF NOT EXISTS `curEnroll` (
  `Class` int(10) unsigned NOT NULL,
  `Person` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `curEnrollAthl`
--

CREATE TABLE IF NOT EXISTS `curEnrollAthl` (
  `Class` int(10) unsigned NOT NULL,
  `Person` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `curEvents`
--

CREATE TABLE IF NOT EXISTS `curEvents` (
  `eventID` char(22) NOT NULL,
  `classID` int(10) unsigned NOT NULL,
  `eventDate` date NOT NULL,
  `start` time NOT NULL,
  `end` time NOT NULL,
  `description` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `room` varchar(100) DEFAULT NULL,
  `googleID` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `curEventsAthl`
--

CREATE TABLE IF NOT EXISTS `curEventsAthl` (
  `eventID` char(22) NOT NULL,
  `classID` int(10) unsigned NOT NULL,
  `eventDate` date NOT NULL,
  `start` time NOT NULL,
  `end` time NOT NULL,
  `description` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `room` varchar(100) DEFAULT NULL,
  `googleID` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `curPersons`
--

CREATE TABLE IF NOT EXISTS `curPersons` (
  `ID` int(10) unsigned NOT NULL,
  `Email` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `curRooms`
--

CREATE TABLE IF NOT EXISTS `curRooms` (
  `recnum` int(10) unsigned NOT NULL,
  `name` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `email` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 ROW_FORMAT=COMPACT;

-- --------------------------------------------------------

--
-- Table structure for table `curTeams`
--

CREATE TABLE IF NOT EXISTS `curTeams` (
  `ID` int(10) unsigned NOT NULL,
  `Class` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tmpEnroll`
--

CREATE TABLE IF NOT EXISTS `tmpEnroll` (
  `Class` int(10) unsigned NOT NULL,
  `Person` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tmpEnrollAthl`
--

CREATE TABLE IF NOT EXISTS `tmpEnrollAthl` (
  `Class` int(10) unsigned NOT NULL,
  `Person` int(10) unsigned NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tmpEvents`
--

CREATE TABLE IF NOT EXISTS `tmpEvents` (
  `eventID` char(22) NOT NULL,
  `classID` int(10) unsigned NOT NULL,
  `eventDate` date NOT NULL,
  `start` time NOT NULL,
  `end` time NOT NULL,
  `description` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `room` varchar(100) DEFAULT NULL,
  `googleID` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `tmpEventsAthl`
--

CREATE TABLE IF NOT EXISTS `tmpEventsAthl` (
  `eventID` char(22) NOT NULL,
  `classID` int(10) unsigned NOT NULL,
  `eventDate` date NOT NULL,
  `start` time NOT NULL,
  `end` time NOT NULL,
  `description` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `room` varchar(100) DEFAULT NULL,
  `googleID` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `toAdd`
--

CREATE TABLE IF NOT EXISTS `toAdd` (
  `eventID` char(22) NOT NULL,
  `classID` int(10) unsigned NOT NULL,
  `eventDate` date NOT NULL,
  `start` time NOT NULL,
  `end` time NOT NULL,
  `description` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `room` varchar(100) DEFAULT NULL,
  `googleID` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `toAddAthl`
--

CREATE TABLE IF NOT EXISTS `toAddAthl` (
  `eventID` char(22) NOT NULL,
  `classID` int(10) unsigned NOT NULL,
  `eventDate` date NOT NULL,
  `start` time NOT NULL,
  `end` time NOT NULL,
  `description` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `room` varchar(100) DEFAULT NULL,
  `googleID` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `toDelete`
--

CREATE TABLE IF NOT EXISTS `toDelete` (
  `eventID` char(22) NOT NULL,
  `classID` int(10) unsigned NOT NULL,
  `eventDate` date NOT NULL,
  `start` time NOT NULL,
  `end` time NOT NULL,
  `description` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `room` varchar(100) DEFAULT NULL,
  `googleID` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `toDeleteAthl`
--

CREATE TABLE IF NOT EXISTS `toDeleteAthl` (
  `eventID` char(22) NOT NULL,
  `classID` int(10) unsigned NOT NULL,
  `eventDate` date NOT NULL,
  `start` time NOT NULL,
  `end` time NOT NULL,
  `description` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `room` varchar(100) DEFAULT NULL,
  `googleID` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `toUpdate`
--

CREATE TABLE IF NOT EXISTS `toUpdate` (
  `eventID` char(22) NOT NULL,
  `classID` int(10) unsigned NOT NULL,
  `eventDate` date NOT NULL,
  `start` time NOT NULL,
  `end` time NOT NULL,
  `description` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `room` varchar(100) DEFAULT NULL,
  `googleID` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- --------------------------------------------------------

--
-- Table structure for table `toUpdateAthl`
--

CREATE TABLE IF NOT EXISTS `toUpdateAthl` (
  `eventID` char(22) NOT NULL,
  `classID` int(10) unsigned NOT NULL,
  `eventDate` date NOT NULL,
  `start` time NOT NULL,
  `end` time NOT NULL,
  `description` varchar(100) CHARACTER SET utf8 COLLATE utf8_general_ci DEFAULT NULL,
  `room` varchar(100) DEFAULT NULL,
  `googleID` varchar(50) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `curClasses`
--
ALTER TABLE `curClasses`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `Title` (`Class`);

--
-- Indexes for table `curEvents`
--
ALTER TABLE `curEvents`
  ADD PRIMARY KEY (`eventID`),
  ADD UNIQUE KEY `googleID` (`googleID`);

--
-- Indexes for table `curEventsAthl`
--
ALTER TABLE `curEventsAthl`
  ADD PRIMARY KEY (`eventID`),
  ADD UNIQUE KEY `googleID` (`googleID`);

--
-- Indexes for table `curPersons`
--
ALTER TABLE `curPersons`
  ADD PRIMARY KEY (`ID`);

--
-- Indexes for table `curRooms`
--
ALTER TABLE `curRooms`
  ADD PRIMARY KEY (`recnum`),
  ADD UNIQUE KEY `email` (`email`),
  ADD KEY `room` (`name`);

--
-- Indexes for table `curTeams`
--
ALTER TABLE `curTeams`
  ADD PRIMARY KEY (`ID`),
  ADD KEY `Title` (`Class`);

--
-- Indexes for table `tmpEvents`
--
ALTER TABLE `tmpEvents`
  ADD PRIMARY KEY (`eventID`),
  ADD UNIQUE KEY `googleID` (`googleID`);

--
-- Indexes for table `tmpEventsAthl`
--
ALTER TABLE `tmpEventsAthl`
  ADD PRIMARY KEY (`eventID`),
  ADD UNIQUE KEY `googleID` (`googleID`);

--
-- Indexes for table `toUpdate`
--
ALTER TABLE `toUpdate`
  ADD UNIQUE KEY `eventID` (`eventID`);

--
-- Indexes for table `toUpdateAthl`
--
ALTER TABLE `toUpdateAthl`
  ADD UNIQUE KEY `eventID` (`eventID`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `curRooms`
--
ALTER TABLE `curRooms`
  MODIFY `recnum` int(10) unsigned NOT NULL AUTO_INCREMENT;
