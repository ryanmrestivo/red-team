-- phpMyAdmin SQL Dump
-- version 4.8.3
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 23, 2018 at 01:51 PM
-- Server version: 10.1.36-MariaDB
-- PHP Version: 7.2.11

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `plague`
--

-- --------------------------------------------------------

--
-- Table structure for table `clients`
--

CREATE TABLE `clients` (
  `GUID` varchar(40) COLLATE utf8_bin NOT NULL,
  `Nickname` text COLLATE utf8_bin NOT NULL,
  `IPAddress` varchar(45) COLLATE utf8_bin NOT NULL,
  `OperatingSystem` varchar(255) COLLATE utf8_bin NOT NULL,
  `ComputerName` varchar(255) COLLATE utf8_bin NOT NULL,
  `Username` varchar(255) COLLATE utf8_bin NOT NULL,
  `CPU` varchar(255) COLLATE utf8_bin NOT NULL,
  `GPU` varchar(255) COLLATE utf8_bin NOT NULL,
  `Antivirus` varchar(255) COLLATE utf8_bin NOT NULL,
  `Defences` text COLLATE utf8_bin NOT NULL,
  `Location` varchar(255) COLLATE utf8_bin NOT NULL,
  `Infected` varchar(40) COLLATE utf8_bin NOT NULL,
  `LastSeen` timestamp NULL DEFAULT CURRENT_TIMESTAMP,
  `Commands` text COLLATE utf8_bin NOT NULL,
  `Result` varchar(255) COLLATE utf8_bin NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `Username` varchar(255) COLLATE utf8_bin NOT NULL,
  `Password` varchar(101) COLLATE utf8_bin NOT NULL,
  `Permission` varchar(40) COLLATE utf8_bin NOT NULL,
  `Created` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`Username`, `Password`, `Permission`, `Created`) VALUES
('Raffy', '83F4B0E3529DF15F25D5E4F69E7AEFEC1C513ED7DE587D8C3963D42FD306C931', 'Master', '2018-12-20 22:20:57'),
('Tibix', '689210C983600446C914E1D6EBB6D7E3E66BAFF9683C8F59ED472C1FD6668B38', 'Observer', '2018-12-20 22:34:00');
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
