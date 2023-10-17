-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Oct 14, 2023 at 12:15 PM
-- Server version: 10.4.28-MariaDB
-- PHP Version: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `c2b`
--

-- --------------------------------------------------------

--
-- Table structure for table `order_statuses`
--

CREATE TABLE `order_statuses` (
  `id` int(11) NOT NULL,
  `status_name` varchar(255) DEFAULT NULL,
  `for_vendor` tinyint(1) DEFAULT 0,
  `for_admin` tinyint(1) DEFAULT 0,
  `for_vendor_drivers` tinyint(1) DEFAULT 0,
  `createdAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `updatedAt` timestamp NOT NULL DEFAULT current_timestamp(),
  `deletedAt` timestamp NULL DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `order_statuses`
--

INSERT INTO `order_statuses` (`id`, `status_name`, `for_vendor`, `for_admin`, `for_vendor_drivers`, `createdAt`, `updatedAt`, `deletedAt`) VALUES
(1, 'ORDER PLACED', 1, 1, 1, '2023-09-12 04:50:48', '2023-09-12 04:50:48', NULL),
(2, 'ORDER PACKED', 1, 1, 1, '2023-09-12 04:55:35', '2023-09-12 04:55:35', NULL),
(3, 'ORDER OUT FOR DELIVERY', 0, 1, 1, '2023-09-12 04:55:35', '2023-09-12 04:55:35', NULL),
(4, 'ORDER DELIVERED', 0, 1, 1, '2023-09-12 04:55:35', '2023-09-12 04:55:35', NULL),
(5, 'ORDER PICKED BY CUSTOMER', 1, 1, 0, '2023-09-12 04:55:35', '2023-09-12 04:55:35', NULL),
(13, 'ORDER CANCELLED BY VENDOR', 1, 1, 0, '2023-09-12 07:20:37', '2023-09-12 07:20:37', NULL),
(14, 'ORDER CANCELLED BY ADMIN', 0, 1, 0, '2023-09-12 07:20:53', '2023-09-12 07:20:53', NULL),
(15, 'ORDER CANCELLED BY CUSTOMER', 0, 1, 1, '2023-09-12 07:21:07', '2023-09-12 07:21:07', NULL);

--
-- Indexes for dumped tables
--

--
-- Indexes for table `order_statuses`
--
ALTER TABLE `order_statuses`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `order_statuses`
--
ALTER TABLE `order_statuses`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
