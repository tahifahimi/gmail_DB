-- phpMyAdmin SQL Dump
-- version 5.0.2
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 10, 2020 at 11:18 AM
-- Server version: 10.4.11-MariaDB
-- PHP Version: 7.4.5

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `firstdb`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_cc` (IN `e_id` INT, IN `user` VARCHAR(50))  BEGIN
	INSERT INTO `cc` VALUES(e_id, user);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_notif` (IN `id` BIGINT(255), IN `user` VARCHAR(50), IN `disc` VARCHAR(512))  BEGIN
      INSERT INTO `notifs` VALUES(id,user,CURRENT_TIME,disc);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_person_info` (IN `user` VARCHAR(50), IN `fname` VARCHAR(50), IN `lname` VARCHAR(50), IN `address` VARCHAR(50), IN `nickname` VARCHAR(50), IN `ph` VARCHAR(15), IN `birthdate` DATE, IN `id` VARCHAR(10), OUT `output` VARCHAR(50))  BEGIN
    SET @b = (
    SELECT COUNT(*) 
    FROM person_info
    WHERE LOWER(person_info.username) = LOWER(user)
	);
    SET @length = LENGTH(user);
    IF @b = 0 THEN
    	IF @length >6 THEN
    		INSERT INTO person_info(`username`, `fname`,`lname`, `address`, `nickname`, `phone_no`, `birth_date`, `ID_Number`, `full_access`) VALUES (user , fname , lname , address , nickname , ph, birthdate, id, 1);
        set output = 'done';
        END IF;
    ELSE
    	set output = 'error in creating personal info';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `add_user_system_info` (IN `user` VARCHAR(50), IN `pass` VARCHAR(50), IN `ph` VARCHAR(50), OUT `output` VARCHAR(50))  BEGIN
    SET @b = (
    SELECT COUNT(*) 
    FROM system_info
    WHERE LOWER(system_info.username) = LOWER(user)
	);
    SET @length = LENGTH(user);
    
	IF @b = 0 THEN
    	IF @length >6 THEN
			INSERT INTO system_info VALUES (user , PASSWORD(pass), CURRENT_TIME,ph);
			SET output = 'done';
		END IF;
    ELSE SET output = 'error in adding person';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `authenticate` (IN `user` VARCHAR(50), IN `pass` VARCHAR(50), OUT `output` VARCHAR(50))  BEGIN
      SET @counter = (SELECT COUNT(*)  
    FROM system_info
    WHERE LOWER(system_info.username) = LOWER(user) AND system_info.password = PASSWORD(pass) 
	);
    IF @counter = 1 THEN
    		SET output = 'done';
            INSERT INTO `entered_accounts`(`username`, `time`) VALUES(LOWER(user),CURRENT_TIME);
      ELSE
            SET output = 'error';
      END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `change_info` (IN `pass` VARCHAR(50), IN `ph` VARCHAR(50), IN `firstname` VARCHAR(50), IN `lastname` VARCHAR(50), IN `addr` VARCHAR(50), IN `nick` VARCHAR(50), IN `pho` VARCHAR(15), IN `birth` DATE, IN `id_` VARCHAR(10), IN `access` SMALLINT, OUT `output` VARCHAR(50))  BEGIN
    set @user = ( SELECT entered_accounts.username
				FROM entered_accounts
				WHERE entered_accounts.time = (SELECT Max(entered_accounts.time) FROM entered_accounts));
    SET @length = LENGTH(pass);
    IF @LENGTH > 6 THEN
    	UPDATE person_info SET
			fname = firstname,
        	lname = lastname,
        	address = addr,
        	nickname = nick,
        	phone_no = pho,
        	birth_date = birth,
        	ID_Number = id_,
        	full_access = access
		WHERE
    		person_info.username = @user;
        
        UPDATE system_info SET
			system_info.password = PASSWORD(pass),
            system_info.phone = ph
		WHERE
    		system_info.username = @user;
		SET output = 'changes Done';
	ELSE
    	SET output = 'error happened';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `close_access` (IN `user_closed` VARCHAR(50))  BEGIN
	set @user = ( SELECT entered_accounts.username
	FROM entered_accounts
	WHERE entered_accounts.time = (SELECT Max(entered_accounts.time) FROM entered_accounts));
    
    INSERT INTO access_closed(`closer_id`, `closed_id`) VALUES (@user, user_closed);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `current_user_notifs` ()  BEGIN
	set @user = ( SELECT entered_accounts.username
FROM entered_accounts
WHERE entered_accounts.time = (SELECT Max(entered_accounts.time) FROM entered_accounts));
    SELECT notifs.disc
    FROM notifs
    WHERE LOWER(notifs.username) = LOWER(@user)
    ORDER BY notifs.time DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_account` (OUT `output` VARCHAR(50))  BEGIN   
    set @curr = ( SELECT entered_accounts.username
				FROM entered_accounts
				WHERE entered_accounts.time = (SELECT Max(entered_accounts.time) FROM entered_accounts));
    DELETE FROM entered_accounts WHERE entered_accounts.username = @curr;
    DELETE FROM system_info WHERE system_info.username = @curr;
    DELETE FROM person_info WHERE person_info.username = @curr;
    DELETE FROM notifs WHERE notifs.username = @curr;
    DELETE FROM access_closed WHERE access_closed.closer_id = @curr;
    DELETE FROM entered_accounts WHERE entered_accounts.username = @curr;
    
    
    DELETE FROM email WHERE email.username = @curr;
    DELETE FROM state WHERE state.username = @curr;
    DELETE FROM reciever WHERE reciever.username = @curr;
    DELETE FROM cc WHERE cc.username = @curr;
    DELETE FROM access_closed WHERE access_closed.closer_id = @curr;
    DELETE FROM access_closed WHERE access_closed.closed_id = @curr;
    SET output = 'Done';
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_email` (IN `e_id` INT, OUT `output` VARCHAR(50))  BEGIN
	set @curr = ( SELECT entered_accounts.username
				FROM entered_accounts
				WHERE entered_accounts.time = (SELECT Max(entered_accounts.time) FROM entered_accounts));
   	
    SET @check = (SELECT COUNT(*) 
    			FROM state
    			WHERE LOWER(state.username)=LOWER(@curr) AND state.email_id= e_id);
    
    IF @check =1 THEN
    	UPDATE state SET
			deleted = 1
		WHERE
    		username = @curr AND email_id = e_id;
        SET output = 'deleted';
    ELSE
    	SET output = 'error in deleting';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `find_notifs` (IN `user` VARCHAR(50))  BEGIN
    SELECT notifs.disc
    FROM notifs
    WHERE LOWER(notifs.username) = LOWER(user);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_all_info` ()  BEGIN
	set @user = ( SELECT entered_accounts.username
	FROM entered_accounts
	WHERE entered_accounts.time = (SELECT Max(entered_accounts.time) FROM entered_accounts));
    
    SELECT person_info.username,person_info.fname,person_info.lname,person_info.address,person_info.nickname,person_info.phone_no,person_info.birth_date, person_info.ID_Number,system_info.password,system_info.phone
    FROM person_info JOIN system_info ON person_info.username=system_info.username
    WHERE person_info.username = @user;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_another_user_info` (IN `other` VARCHAR(50), OUT `output` VARCHAR(50))  BEGIN
	IF NOT EXISTS(SELECT person_info.username
                 FROM person_info
                 WHERE LOWER(person_info.username) = LOWER(other)) THEN
    	SET output = 'user not exist';
    ELSE
   		set @curr = ( SELECT entered_accounts.username
					FROM entered_accounts
					WHERE entered_accounts.time = (SELECT Max(entered_accounts.time) FROM entered_accounts));
        
        set @fullAccess = ( SELECT person_info.full_access
                           FROM person_info
                           WHERE LOWER(person_info.username) = LOWER(other));
        IF @fullAccess = 0 THEN
        	SELECT *
            FROM person_info
        	WHERE person_info.username = '*';
            SET @message = CONCAT(@curr,'some one get your information and access was closed for all');
            INSERT INTO `notifs` VALUES(900, other,CURRENT_TIME,@message);
        ELSE
        	set @ac_table = (SELECT COUNT(*)
                       FROM access_closed
                       WHERE LOWER(access_closed.closer_id) = LOWER(other) AND LOWER(access_closed.closed_id) = LOWER(@curr) );
            IF @ac_table = 1 THEN
            	SELECT *
            	FROM person_info
        		WHERE person_info.username = '*';
                SET @mess2 =CONCAT(@curr,'access is closed and wants to see ninfo');
                INSERT INTO `notifs` VALUES(901, other,CURRENT_TIME,@mess2);
            ELSE
            SET @tmp1 = RAND()*1000;
	SET @tmp2 = FLOOR(@tmp1);
            	SET @mess3 = CONCAT(@curr,'accessed to your data');
                INSERT INTO `notifs` VALUES(@tmp2, other,CURRENT_TIME,@mess3);
                
            	SELECT *
            	FROM person_info
        		WHERE LOWER(person_info.username) = LOWER(other);
        		
            END IF;
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `give_email` (OUT `output` VARCHAR(255))  BEGIN
    SET @curr = ( SELECT entered_accounts.username
                FROM entered_accounts
                WHERE entered_accounts.time = (SELECT Max(entered_accounts.time) FROM entered_accounts));

    SELECT CONCAT(output, email.body)
    FROM email 
    WHERE LOWER(email.username) = LOWER(@curr)
    ORDER BY email.time DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `inbox` (IN `page_size` INT, IN `page_number` INT)  BEGIN
    DECLARE v_offset INT;
    SET @curr = ( SELECT entered_accounts.username
                FROM entered_accounts
                WHERE entered_accounts.time = (SELECT Max(entered_accounts.time) FROM entered_accounts));
    SET @tmp = page_number-1;
    SET v_offset = page_size * @tmp;

    SELECT email.email_id, email.subject, email.time, email.body, state.readed
    FROM email INNER JOIN reciever ON email.email_id=reciever.email_id 
                INNER JOIN state ON reciever.email_id = state.email_id AND LOWER(reciever.username) = LOWER(state.username)
    WHERE LOWER(state.username) = LOWER(@curr) AND state.deleted=0
    ORDER BY email.time DESC
    LIMIT v_offset, page_size;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_cc` (IN `e_id` BIGINT, IN `user` VARCHAR(50), OUT `message` VARCHAR(50))  BEGIN
	SET @count = (SELECT COUNT(*)
                 FROM system_info
                 WHERE system_info.username=user);
   	IF @count = 1 THEN
		INSERT INTO `cc` VALUES(e_id, user);
        SET message = 'Done';
    ELSE
    	SET message = 'error';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insert_reciever` (IN `e_id` BIGINT, IN `user` VARCHAR(50), OUT `message` VARCHAR(50))  BEGIN
	SET @count = (SELECT COUNT(*)
                 FROM system_info
                 WHERE system_info.username=user);
   	IF @count = 1 THEN
		INSERT INTO `reciever` VALUES(e_id, user);
        SET message = 'Done';
    ELSE
    	SET message = 'error';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `read_email` (IN `e_id` INT, OUT `output` VARCHAR(50))  BEGIN
	set @curr = ( SELECT entered_accounts.username
				FROM entered_accounts
				WHERE entered_accounts.time = (SELECT Max(entered_accounts.time) FROM entered_accounts));
   	
    
    SET @check = (SELECT COUNT(*) 
    			FROM state
    			WHERE LOWER(state.username)=LOWER(@curr) AND state.email_id= e_id);
    
    IF @check =1 THEN
    	UPDATE state SET
			readed = 1
		WHERE
    		username = @curr AND email_id = e_id;
        SET output = 'readed';
    ELSE
    	SET output = 'error in reading';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `register` (IN `user` VARCHAR(50), IN `pass` VARCHAR(50), IN `ph` VARCHAR(50), IN `fname` VARCHAR(50), IN `lname` VARCHAR(50), IN `address` VARCHAR(50), IN `nickname` VARCHAR(50), IN `un_phon` VARCHAR(15), IN `birthdate` DATE, IN `id` VARCHAR(10), OUT `output` VARCHAR(50))  BEGIN
    SET @b = (
    SELECT COUNT(*) 
    FROM person_info
    WHERE LOWER(person_info.username) = LOWER(user)
	);
    SET @length = LENGTH(user);
    SET @passLen = LENGTH(pass);
    
    IF @b = 0 THEN
    	SAVEPOINT saving;
    	IF @length >6 THEN
        	IF @passLen>6 THEN
    			INSERT INTO person_info(`username`, `fname`,`lname`, `address`, `nickname`, `phone_no`, `birth_date`, `ID_Number`, `full_access`) VALUES (user , fname , lname , address , nickname , un_phon, birthdate, id, 1);
            	INSERT INTO system_info VALUES (user , PASSWORD(pass), CURRENT_TIME,ph);
                set output = 'done';
              ELSE
                ROLLBACK TO saving;
              	SET output = 'password is short';
               END IF;
        ELSE 
        ROLLBACK TO saving;
        SET output = 'little username';
        END IF;
    ELSE
    	set @output = 'repeated username';
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `send_box` (IN `page_size` INT, IN `page_number` INT)  BEGIN
	DECLARE v_offset INT;
	set @curr = ( SELECT entered_accounts.username
				FROM entered_accounts
				WHERE entered_accounts.time = (SELECT Max(entered_accounts.time) FROM entered_accounts));
   	SET @tmp = page_number-1;
	SET v_offset = page_size * @tmp;
    
    SELECT email.email_id, email.subject, email.time, email.body, state.readed
    FROM email INNER JOIN state ON LOWER(state.username)=LOWER(email.username) AND state.email_id=email.email_id
    WHERE  LOWER(state.username) = LOWER(@curr) AND state.deleted=0
   LIMIT v_offset,page_size; 
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `send_email` (IN `sub` VARCHAR(50), IN `body` VARCHAR(512), OUT `email_id` BIGINT)  BEGIN
	SET @tmp = RAND()*1000;
	SET @id = FLOOR(@tmp);
    SET email_id = @id;
    set @curr = ( SELECT entered_accounts.username
				FROM entered_accounts
				WHERE entered_accounts.time = (SELECT Max(entered_accounts.time) FROM entered_accounts));
                
	INSERT INTO `email` VALUES(@id, @curr, sub,CURRENT_TIME,body);
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `access_closed`
--

CREATE TABLE `access_closed` (
  `closer_id` varchar(50) NOT NULL,
  `closed_id` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `cc`
--

CREATE TABLE `cc` (
  `email_id` bigint(20) NOT NULL,
  `username` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Triggers `cc`
--
DELIMITER $$
CREATE TRIGGER `after_insert_cc` AFTER INSERT ON `cc` FOR EACH ROW BEGIN
	SET @tmp = RAND()*100+10;
    SET @id = FLOOR(@tmp);
    INSERT INTO `notifs` VALUES(@id,NEW.username,CURRENT_TIME,'you have new email');
	INSERT INTO `state` VALUES(NEW.email_id,NEW.username,0,0);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `email`
--

CREATE TABLE `email` (
  `email_id` bigint(20) NOT NULL,
  `username` varchar(50) NOT NULL,
  `subject` varchar(50) NOT NULL,
  `time` int(11) NOT NULL DEFAULT current_timestamp(),
  `body` varchar(512) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `email`
--

INSERT INTO `email` (`email_id`, `username`, `subject`, `time`, `body`) VALUES
(13, 'tahere', 'first subject', 164935, 'this is the body'),
(34, 'tahere', '', 235309, ''),
(53, 'tahere', '', 234936, ''),
(93, 'tahere', 'rrrrrrrrrr', 235928, 'bodyyyyyy'),
(385, 'tahere', 'kjba', 173431, 'hcbai'),
(396, 'tahere', '', 235052, ''),
(399, 'fatima1010', 'jwwww', 174725, 'wwww'),
(550, 'tahere', '', 235040, ''),
(555, 'tahere', 'uuuuulj;alj;lcj', 2, 'ksgaksc'),
(607, 'tahere', 'bablcb', 155921, 'bvqd'),
(639, 'tahere', 'hhahh', 200, 'kjbjkca'),
(687, 'tahere', 'uuuu', 155532, 'nbkbckbeq'),
(775, 'tahere', '', 235135, ''),
(785, 'tahere', 'kjba', 173440, 'hcbai'),
(821, 'tahere', 'lknc', 174259, 'blib'),
(885, 'tahere', 'jlallla', 914, 'jkbkjac'),
(953, 'tahere', 'nlsnvlsk', 2603, 'knlcw');

--
-- Triggers `email`
--
DELIMITER $$
CREATE TRIGGER `after_insert_email` AFTER INSERT ON `email` FOR EACH ROW BEGIN
	INSERT INTO `state` VALUES(NEW.email_id,NEW.username,1,0);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `entered_accounts`
--

CREATE TABLE `entered_accounts` (
  `username` varchar(50) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `entered_accounts`
--

INSERT INTO `entered_accounts` (`username`, `time`) VALUES
('ass hole', '2020-05-25 09:37:03'),
('dad', '2020-05-25 10:49:40'),
('fatima1010', '2020-05-29 13:16:39'),
('fuck you', '2020-05-25 10:39:04'),
('kjbjkjbcs', '2020-05-25 11:25:24'),
('mmmmmmmmm', '2020-05-24 18:56:08'),
('mom', '2020-05-25 10:49:40'),
('pppwwwqq', '2020-05-24 18:58:05'),
('tahere', '2020-05-25 10:49:40'),
('tahere', '2020-05-28 12:13:55'),
('tahere', '2020-05-28 12:20:15'),
('who', '2020-05-25 06:37:10');

--
-- Triggers `entered_accounts`
--
DELIMITER $$
CREATE TRIGGER `after_authenticate` AFTER INSERT ON `entered_accounts` FOR EACH ROW BEGIN
    SET @tmp = RAND()*10000;
	SET @id = FLOOR(@tmp);
    INSERT INTO `notifs` VALUES(@id,NEW.username,CURRENT_TIME,'you entered');
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `notifs`
--

CREATE TABLE `notifs` (
  `notif_id` bigint(255) NOT NULL,
  `username` varchar(50) NOT NULL,
  `time` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `disc` varchar(512) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `notifs`
--

INSERT INTO `notifs` (`notif_id`, `username`, `time`, `disc`) VALUES
(15, 'dad', '2020-05-29 13:12:59', 'you have new email'),
(19, 'dad', '2020-05-28 19:56:03', 'you have new email'),
(38, 'dad', '2020-05-29 11:25:32', 'you have new email'),
(50, '*', '2020-05-25 06:36:10', 'some one wants to acecss your data'),
(90, 'dad', '2020-05-29 09:36:36', 'some one get your information'),
(105, 'dad', '2020-05-29 13:17:25', 'you have new email'),
(106, 'dad', '2020-05-29 13:04:40', 'you have new email'),
(109, 'dad', '2020-05-29 11:29:21', 'you have new email'),
(309, 'mmmmmmmmm', '2020-05-24 18:56:08', 'you are registered!'),
(310, 'pppwwwqq', '2020-05-24 18:58:05', 'you are registered!'),
(313, 'ass hole', '2020-05-25 09:37:03', 'you are registered!'),
(314, 'fuck you', '2020-05-25 10:39:04', 'you are registered!'),
(315, 'tahere', '2020-05-25 10:49:40', 'you are registered!'),
(316, 'mom', '2020-05-25 10:49:40', 'you are registered!'),
(317, 'dad', '2020-05-25 10:49:40', 'you are registered!'),
(319, 'kjbjkjbcs', '2020-05-25 11:25:24', 'you are registered!'),
(496, 'mom', '2020-06-10 09:18:01', 'fatima1010accessed to your data'),
(542, 'tahere', '2020-05-29 11:03:47', 'the information changed'),
(543, 'fatima1919', '2020-05-29 13:03:20', 'you are registered!'),
(544, 'fatima1010', '2020-05-29 13:12:16', 'you are registered!'),
(903, 'dad', '2020-05-29 13:58:31', 'fatima1010accessed to your data');

-- --------------------------------------------------------

--
-- Table structure for table `person_info`
--

CREATE TABLE `person_info` (
  `username` varchar(50) CHARACTER SET armscii8 NOT NULL,
  `fname` varchar(50) CHARACTER SET armscii8 NOT NULL,
  `lname` varchar(50) CHARACTER SET armscii8 NOT NULL,
  `address` varchar(50) CHARACTER SET armscii8 NOT NULL,
  `nickname` varchar(50) CHARACTER SET armscii8 NOT NULL,
  `phone_no` varchar(15) CHARACTER SET armscii8 NOT NULL,
  `birth_date` date NOT NULL,
  `ID_Number` varchar(10) CHARACTER SET armscii8 NOT NULL,
  `full_access` tinyint(1) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='personal information of users';

--
-- Dumping data for table `person_info`
--

INSERT INTO `person_info` (`username`, `fname`, `lname`, `address`, `nickname`, `phone_no`, `birth_date`, `ID_Number`, `full_access`) VALUES
('*', '*', '*', '*', '*', '*', '0000-00-00', '0000-0-0', 0),
('dad', 'dad', 'fahimi', 'tehran', 'd', '0915', '0000-00-00', '1970-16-1', 127),
('fatima1010', 'nl', 'noln', ';jbb', 'ljjo', 'nbonbo', '1880-01-01', 'bcaib', 1),
('fatima1919', 'bcosb', 'njnaocn', 'lonbcao', 'lkbcal', 'pch', '1880-01-01', 'kqgwf', 1),
('kjbjkjbcs', 'jkbcakjd', 'jkbkjacb', 'kjbkjb', 'lhhb', 'hgug', '1990-01-01', 'jkbkjh', 1),
('mom', 'mom', 'fahimi', 'tehran', 'm', '0935', '0000-00-00', '1980-1-1', 127),
('tahere', 'nca;lnc', 'kbadkkj', 'ljbadsclbca', 'bibi', 'hblibbb', '1990-11-01', 'hbbi', 1);

--
-- Triggers `person_info`
--
DELIMITER $$
CREATE TRIGGER `after_change_info` AFTER UPDATE ON `person_info` FOR EACH ROW BEGIN
	SET @r = RAND()*1000;
	SET @ran = FLOOR(@r);
    CALL add_notif(
        @ran,
        NEW.username,
        'the information changed'
    );
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `reciever`
--

CREATE TABLE `reciever` (
  `email_id` int(11) NOT NULL,
  `username` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `reciever`
--

INSERT INTO `reciever` (`email_id`, `username`) VALUES
(399, 'dad'),
(607, 'dad'),
(687, 'dad'),
(785, 'dad'),
(821, 'dad'),
(953, 'dad');

--
-- Triggers `reciever`
--
DELIMITER $$
CREATE TRIGGER `after_insert_reciever` AFTER INSERT ON `reciever` FOR EACH ROW BEGIN
	SET @tmp = RAND()*100+10;
    SET @id = FLOOR(@tmp);
    INSERT INTO `notifs` VALUES(@id,NEW.username,CURRENT_TIME,'you have new email');
    INSERT INTO `state` VALUES(NEW.email_id,NEW.username,0,0);
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `state`
--

CREATE TABLE `state` (
  `email_id` bigint(20) NOT NULL,
  `username` varchar(50) NOT NULL,
  `readed` tinyint(4) NOT NULL,
  `deleted` tinyint(4) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `state`
--

INSERT INTO `state` (`email_id`, `username`, `readed`, `deleted`) VALUES
(13, 'tahere', 1, 0),
(34, 'tahere', 1, 0),
(53, 'tahere', 1, 0),
(93, 'tahere', 1, 0),
(385, 'tahere', 1, 0),
(396, 'tahere', 1, 0),
(399, 'dad', 0, 0),
(399, 'fatima1010', 1, 0),
(550, 'tahere', 1, 0),
(555, 'tahere', 1, 0),
(607, 'dad', 0, 0),
(607, 'tahere', 1, 0),
(639, 'tahere', 1, 0),
(687, 'dad', 0, 0),
(687, 'tahere', 1, 0),
(775, 'tahere', 1, 0),
(785, 'dad', 0, 0),
(785, 'tahere', 1, 0),
(821, 'dad', 0, 0),
(821, 'tahere', 1, 0),
(885, 'tahere', 1, 0),
(953, 'dad', 0, 0),
(953, 'tahere', 1, 0);

-- --------------------------------------------------------

--
-- Table structure for table `system_info`
--

CREATE TABLE `system_info` (
  `username` varchar(50) NOT NULL,
  `password` varchar(50) NOT NULL,
  `account_time` datetime NOT NULL DEFAULT current_timestamp(),
  `phone` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='system information of the accounts';

--
-- Dumping data for table `system_info`
--

INSERT INTO `system_info` (`username`, `password`, `account_time`, `phone`) VALUES
('ass hole', 'ass hole pass', '2020-05-25 14:07:03', 'ooo'),
('dad', 'dadpass', '2020-05-25 15:19:40', 'dadphone'),
('fatima1010', '*098236F44E15EEF333905412837984A55C791B05', '2020-05-29 17:42:16', 'ehhh'),
('fatima1919', 'fatima1919', '2020-05-29 17:33:20', 'nvco'),
('fuck you', 'ass hole pass', '2020-05-25 15:09:04', 'ooo'),
('kjbjkjbcs', 'lhlasclanc', '2020-05-25 15:55:24', 'jkbcaskj'),
('mmmmmmmmm', 'pppppppppp', '2020-05-24 23:26:08', '9090'),
('mom', 'mompass', '2020-05-25 15:19:40', 'momphone'),
('pppwwwqq', 'pppppppppp', '2020-05-24 23:28:05', '9090'),
('tahere', 'qqqwwwee', '2020-05-25 15:19:40', 'cacnjsac');

--
-- Triggers `system_info`
--
DELIMITER $$
CREATE TRIGGER `after_register` AFTER INSERT ON `system_info` FOR EACH ROW BEGIN
    CALL authenticate(
        NEW.username,
        NEW.password,
        @check
    );
    CALL  add_notif(
        0,
        NEW.username,
        'you are registered!'
    );
END
$$
DELIMITER ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `access_closed`
--
ALTER TABLE `access_closed`
  ADD PRIMARY KEY (`closer_id`,`closed_id`);

--
-- Indexes for table `cc`
--
ALTER TABLE `cc`
  ADD PRIMARY KEY (`email_id`,`username`);

--
-- Indexes for table `email`
--
ALTER TABLE `email`
  ADD PRIMARY KEY (`email_id`,`username`);

--
-- Indexes for table `entered_accounts`
--
ALTER TABLE `entered_accounts`
  ADD PRIMARY KEY (`username`,`time`);

--
-- Indexes for table `notifs`
--
ALTER TABLE `notifs`
  ADD PRIMARY KEY (`notif_id`);

--
-- Indexes for table `person_info`
--
ALTER TABLE `person_info`
  ADD PRIMARY KEY (`username`);

--
-- Indexes for table `reciever`
--
ALTER TABLE `reciever`
  ADD PRIMARY KEY (`email_id`,`username`);

--
-- Indexes for table `state`
--
ALTER TABLE `state`
  ADD PRIMARY KEY (`email_id`,`username`);

--
-- Indexes for table `system_info`
--
ALTER TABLE `system_info`
  ADD PRIMARY KEY (`username`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `notifs`
--
ALTER TABLE `notifs`
  MODIFY `notif_id` bigint(255) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=975;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
