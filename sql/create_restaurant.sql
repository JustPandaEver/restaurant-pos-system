-- MySQL Workbench Forward Engineering

-- SET GLOBAL sql_mode=(SELECT REPLACE(@@sql_mode,'ONLY_FULL_GROUP_BY',''));


SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0;
SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;
SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION';

-- -----------------------------------------------------
-- Schema restaurant
-- -----------------------------------------------------

-- -----------------------------------------------------
-- Schema restaurant
-- -----------------------------------------------------
CREATE SCHEMA IF NOT EXISTS `restaurant` DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci ;
USE `restaurant` ;

DELIMITER //

CREATE FUNCTION parseISO(iso_datetime VARCHAR(255)) RETURNS DATETIME
DETERMINISTIC
BEGIN
    DECLARE parsed_datetime DATETIME;

    SET parsed_datetime = STR_TO_DATE(iso_datetime, '%Y-%m-%dT%H:%i:%s');
    
    IF parsed_datetime IS NULL THEN
        SET parsed_datetime = STR_TO_DATE(iso_datetime, '%Y-%m-%d %H:%i:%s');
    END IF;

    RETURN parsed_datetime;
END //

DELIMITER ;


-- -----------------------------------------------------
-- Table `restaurant`.`roles`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`roles` (
  `role_id` INT NOT NULL AUTO_INCREMENT,
  `role_name` VARCHAR(50) NULL DEFAULT NULL,
  `salary_per_hour` DECIMAL(10,2) NOT NULL,
  PRIMARY KEY (`role_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `restaurant`.`employees`
-- -----------------------------------------------------
-- DROP TABLE restaurant.employees;
CREATE TABLE IF NOT EXISTS `restaurant`.`employees` (
  `emp_id` INT NOT NULL AUTO_INCREMENT,
  `role_id` INT NOT NULL,
  `emp_fname` VARCHAR(50) NOT NULL,
  `emp_lname` VARCHAR(50) NOT NULL,
  `birthday` DATE NULL DEFAULT NULL,
  `phone` VARCHAR(10) NULL DEFAULT NULL,
  `email` VARCHAR(50) NULL DEFAULT NULL,
  `gender` ENUM('m', 'f') NULL DEFAULT NULL,
  `hours_per_month` INT NOT NULL,
  `is_waiter` BOOL NOT NULL DEFAULT(FALSE),
  PRIMARY KEY (`emp_id`),
  INDEX `employees_role_ref` (`role_id` ASC) VISIBLE,
  CONSTRAINT `employees_role_ref`
    FOREIGN KEY (`role_id`)
    REFERENCES `restaurant`.`roles` (`role_id`))
ENGINE = InnoDB;


-- -----------------------------------------------------
-- Table `restaurant`.`diary`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`diary` (
  `d_id` INT NOT NULL AUTO_INCREMENT,
  `date_` DATE NOT NULL DEFAULT(curdate()),
  `emp_id` INT NOT NULL,
  `start_time` TIME NULL DEFAULT(cast(now() as time)),
  `end_time` TIME NULL DEFAULT(cast(now() as time)),
  `gone` BOOL NOT NULL DEFAULT(TRUE),
  PRIMARY KEY (`d_id`),
  INDEX `diary_emp_ref` (`emp_id` ASC) VISIBLE,
  CONSTRAINT `diary_emp_ref`
    FOREIGN KEY (`emp_id`)
    REFERENCES `restaurant`.`employees` (`emp_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `restaurant`.`dish_groups`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`dish_groups` (
  `dish_gr_id` INT NOT NULL AUTO_INCREMENT,
  `dish_gr_name` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`dish_gr_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 4
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `restaurant`.`dishes`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`dishes` (
  `dish_id` INT NOT NULL AUTO_INCREMENT,
  `dish_name` VARCHAR(50) NOT NULL,
  `dish_price` DECIMAL(10,2) NOT NULL,
  `dish_descr` TEXT DEFAULT(''),
  `dish_gr_id` INT NULL DEFAULT NULL,
  `dish_photo_index` INT NULL DEFAULT 0,
  PRIMARY KEY (`dish_id`),
  UNIQUE INDEX `dish_name` (`dish_name` ASC) VISIBLE,
  INDEX `group_ref` (`dish_gr_id` ASC) VISIBLE,
  CONSTRAINT `group_ref`
    FOREIGN KEY (`dish_gr_id`)
    REFERENCES `restaurant`.`dish_groups` (`dish_gr_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 16
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `restaurant`.`groceries`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`groceries` (
  `groc_id` INT NOT NULL AUTO_INCREMENT,
  `groc_name` VARCHAR(50) NOT NULL,
  `groc_measure` ENUM('gram', 'liter') NOT NULL,
  `ava_count` DECIMAL(10,3) NULL DEFAULT '0.000',
  PRIMARY KEY (`groc_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 12
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `restaurant`.`dish_consists`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`dish_consists` (
  `dc_id` INT NOT NULL AUTO_INCREMENT,
  `dish_id` INT NOT NULL,
  `groc_id` INT NOT NULL,
  `dc_count` DOUBLE NOT NULL,
  PRIMARY KEY (`dc_id`),
  INDEX `dish_ref` (`dish_id` ASC) VISIBLE,
  INDEX `groc_ref` (`groc_id` ASC) VISIBLE,
  CONSTRAINT `dish_ref`
    FOREIGN KEY (`dish_id`)
    REFERENCES `restaurant`.`dishes` (`dish_id`),
  CONSTRAINT `groc_ref`
    FOREIGN KEY (`groc_id`)
    REFERENCES `restaurant`.`groceries` (`groc_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 112
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `restaurant`.`waiters`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`waiters` (
  `waiter_id` INT NOT NULL,
  `waiter_login` VARCHAR(50) NULL DEFAULT NULL,
  `waiter_password` VARCHAR(50) NULL DEFAULT NULL,
  PRIMARY KEY (`waiter_id`),
  UNIQUE INDEX `waiter_login` (`waiter_login` ASC) VISIBLE,
  CONSTRAINT `waiters_id_ref`
    FOREIGN KEY (`waiter_id`)
    REFERENCES `restaurant`.`employees` (`emp_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `restaurant`.`orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`orders` (
  `ord_id` INT NOT NULL AUTO_INCREMENT,
  `ord_date` DATE NOT NULL DEFAULT(curdate()),
  `ord_start_time` TIME NOT NULL DEFAULT(cast(now() as time)),
  `ord_end_time` TIME NULL DEFAULT NULL,
  `money_from_customer` DECIMAL(10,2) NOT NULL,
  `waiter_login` VARCHAR(50) NOT NULL,
  PRIMARY KEY (`ord_id`),
  INDEX `orders_waiter_ref` (`waiter_login` ASC) VISIBLE,
  CONSTRAINT `orders_waiter_ref`
    FOREIGN KEY (`waiter_login`)
    REFERENCES `restaurant`.`waiters` (`waiter_login`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `restaurant`.`list_orders`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`list_orders` (
  `lord_id` INT NOT NULL AUTO_INCREMENT,
  `ord_id` INT NOT NULL,
  `dish_id` INT NOT NULL,
  `lord_count` INT NOT NULL,
  `comm` TINYTEXT NULL DEFAULT NULL,
  PRIMARY KEY (`lord_id`),
  INDEX `list_orders_ord_id_ref` (`ord_id` ASC) VISIBLE,
  INDEX `list_orders_dish_id_ref` (`dish_id` ASC) VISIBLE,
  CONSTRAINT `list_orders_dish_id_ref`
    FOREIGN KEY (`dish_id`)
    REFERENCES `restaurant`.`dishes` (`dish_id`),
  CONSTRAINT `list_orders_ord_id_ref`
    FOREIGN KEY (`ord_id`)
    REFERENCES `restaurant`.`orders` (`ord_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `restaurant`.`kitchen_now`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`kitchen_now` (
  `ord_id` INT NOT NULL,
  `dish_name` VARCHAR(50) NULL DEFAULT NULL,
  `comm` TINYTEXT NULL DEFAULT NULL,
  PRIMARY KEY (`ord_id`),
  CONSTRAINT `ord_ref`
    FOREIGN KEY (`ord_id`)
    REFERENCES `restaurant`.`list_orders` (`ord_id`))
ENGINE = InnoDB
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `restaurant`.`suppliers`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`suppliers` (
  `supplier_id` INT NOT NULL AUTO_INCREMENT,
  `supplier_name` VARCHAR(70) NOT NULL,
  `contacts` TINYTEXT NULL DEFAULT NULL,
  PRIMARY KEY (`supplier_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 13
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `restaurant`.`supplys`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`supplys` (
  `supply_id` INT NOT NULL AUTO_INCREMENT,
  `supply_date` DATE NULL DEFAULT(curdate()),
  `supplier_id` INT NOT NULL,
  `summ` DECIMAL(10,2) NULL DEFAULT NULL,
  PRIMARY KEY (`supply_id`),
  INDEX `supplys_sup_ref` (`supplier_id` ASC) VISIBLE,
  CONSTRAINT `supplys_sup_ref`
    FOREIGN KEY (`supplier_id`)
    REFERENCES `restaurant`.`suppliers` (`supplier_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 39
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `restaurant`.`list_supplys`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`list_supplys` (
  `l_supplys_id` INT NOT NULL AUTO_INCREMENT,
  `supply_id` INT NOT NULL,
  `groc_id` INT NOT NULL,
  `groc_count` INT NOT NULL,
  `groc_name` VARCHAR(50) NULL DEFAULT NULL,
  `groc_price` DECIMAL(10,2) NULL DEFAULT NULL,
  PRIMARY KEY (`l_supplys_id`),
  INDEX `list_supplys_supply_ref` (`supply_id` ASC) VISIBLE,
  INDEX `supply_groc_id` (`groc_id` ASC) VISIBLE,
  CONSTRAINT `list_supplys_supply_ref`
    FOREIGN KEY (`supply_id`)
    REFERENCES `restaurant`.`supplys` (`supply_id`),
  CONSTRAINT `supply_groc_id`
    FOREIGN KEY (`groc_id`)
    REFERENCES `restaurant`.`groceries` (`groc_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 34
DEFAULT CHARACTER SET = utf8mb3;


-- -----------------------------------------------------
-- Table `restaurant`.`suppliers_groc`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`suppliers_groc` (
  `id` INT NOT NULL AUTO_INCREMENT,
  `supplier_id` INT NOT NULL,
  `groc_id` INT NOT NULL,
  `sup_groc_price` DOUBLE(10,2) NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  INDEX `suppliers_sup_ref` (`supplier_id` ASC) VISIBLE,
  INDEX `suppliers_groc_ref` (`groc_id` ASC) VISIBLE,
  CONSTRAINT `suppliers_groc_ref`
    FOREIGN KEY (`groc_id`)
    REFERENCES `restaurant`.`groceries` (`groc_id`),
  CONSTRAINT `suppliers_sup_ref`
    FOREIGN KEY (`supplier_id`)
    REFERENCES `restaurant`.`suppliers` (`supplier_id`))
ENGINE = InnoDB
AUTO_INCREMENT = 130
DEFAULT CHARACTER SET = utf8mb3;

USE `restaurant` ;

-- -----------------------------------------------------
-- Placeholder table for view `restaurant`.`max_values_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`max_values_view` (`max_date` INT, `min_date` INT, `max_summ` INT);

-- -----------------------------------------------------
-- Placeholder table for view `restaurant`.`mini_suppliers_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`mini_suppliers_view` (`supplier_id` INT, `supplier_name` INT);

-- -----------------------------------------------------
-- Placeholder table for view `restaurant`.`supply_groceries_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`supply_groceries_view` (`supply_id` INT, `groc_id` INT, `groc_count` INT, `groc_name` INT, `groc_price` INT);

-- -----------------------------------------------------
-- Placeholder table for view `restaurant`.`supply_view`
-- -----------------------------------------------------
CREATE TABLE IF NOT EXISTS `restaurant`.`supply_view` (`supply_id` INT, `supply_date` INT, `supplier_id` INT, `supplier_name` INT, `summ` INT);

-- -----------------------------------------------------
-- procedure add_dish
-- -----------------------------------------------------

DELIMITER $$
USE `restaurant`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_dish`(
	name_ VARCHAR(50),
    price DECIMAL(10, 2),
    group_id INT -- default = 1 ("unsorted")
)
BEGIN
	SET group_id = IFNULL(group_id, 1);
    
	INSERT INTO dishes(dish_name, dish_price, dish_gr_id)
    VALUES (name_, price, group_id);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure add_dish_group
-- -----------------------------------------------------

DELIMITER $$
USE `restaurant`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_dish_group`(
	name_ VARCHAR(50)
)
BEGIN 
	INSERT INTO dish_groups(dish_gr_name) VALUES (name_);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure add_groc_to_certain_supply
-- -----------------------------------------------------

DELIMITER $$
USE `restaurant`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_groc_to_certain_supply`(
	sup_id INT,
    g_id INT,
    g_count INT
)
BEGIN
	INSERT INTO list_supplys(supply_id, groc_id, groc_count, groc_name, groc_price)
    VALUES (
		sup_id, 
        g_id, 
        g_count, 
        (SELECT groc_name
        FROM groceries 
        WHERE groc_id = g_id),
        (SELECT DISTINCT sup_groc_price 
        FROM suppliers_groc JOIN supplys USING(supplier_id)
        WHERE supply_id = sup_id AND groc_id = g_id)
	);
    UPDATE groceries 
    SET ava_count = ava_count + g_count
    WHERE groc_id = g_id;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure add_grocery_to_certain_dish
-- -----------------------------------------------------

DELIMITER $$
USE `restaurant`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_grocery_to_certain_dish`(
	d_id INT,
    g_id INT,
    count_ DECIMAL(10, 2)
)
BEGIN 
	INSERT INTO dish_consists(groc_id, dish_id, dc_count) 
    VALUES (g_id, d_id, count_);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure add_supply
-- -----------------------------------------------------

DELIMITER $$
USE `restaurant`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `add_supply`(sup_id INT)
BEGIN
	INSERT INTO supplys(supply_date, supplier_id) VALUES (DATE(NOW()), sup_id);
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure del_info_about_del_suppliers
-- -----------------------------------------------------

DELIMITER $$
USE `restaurant`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `del_info_about_del_suppliers`()
BEGIN
	DELETE FROM suppliers
    WHERE supplier_name = 'deleted';
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure delete_supply
-- -----------------------------------------------------

DELIMITER $$
USE `restaurant`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `delete_supply`(supl_id INT)
BEGIN 
	DELETE FROM supplys
    WHERE supply_id = supl_id;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- procedure get_min_groc_price
-- -----------------------------------------------------

DELIMITER $$
USE `restaurant`$$
CREATE DEFINER=`root`@`localhost` PROCEDURE `get_min_groc_price`(groc_id INT)
BEGIN
	SELECT s.supplier_id, s.supplier_name, MIN(sg.sup_groc_price) AS min_price
    FROM suppliers_groc sg JOIN suppliers s USING(supplier_id)
    WHERE groc_id = groc_id;
END$$

DELIMITER ;

-- -----------------------------------------------------
-- View `restaurant`.`max_values_view`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `restaurant`.`max_values_view`;
USE `restaurant`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `restaurant`.`max_values_view` AS select ifnull(max(`restaurant`.`supply_view`.`supply_date`),cast(now() as date)) AS `max_date`,ifnull(min(`restaurant`.`supply_view`.`supply_date`),cast(now() as date)) AS `min_date`,ifnull(max(`restaurant`.`supply_view`.`summ`),0) AS `max_summ` from `restaurant`.`supply_view`;

-- -----------------------------------------------------
-- View `restaurant`.`mini_suppliers_view`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `restaurant`.`mini_suppliers_view`;
USE `restaurant`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `restaurant`.`mini_suppliers_view` AS select `sup`.`supplier_id` AS `supplier_id`,`sup`.`supplier_name` AS `supplier_name` from `restaurant`.`suppliers` `sup`;

-- -----------------------------------------------------
-- View `restaurant`.`supply_groceries_view`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `restaurant`.`supply_groceries_view`;
USE `restaurant`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `restaurant`.`supply_groceries_view` AS select `restaurant`.`list_supplys`.`supply_id` AS `supply_id`,`restaurant`.`list_supplys`.`groc_id` AS `groc_id`,`restaurant`.`list_supplys`.`groc_count` AS `groc_count`,`restaurant`.`list_supplys`.`groc_name` AS `groc_name`,`restaurant`.`list_supplys`.`groc_price` AS `groc_price` from `restaurant`.`list_supplys`;

-- -----------------------------------------------------
-- View `restaurant`.`supply_view`
-- -----------------------------------------------------
DROP TABLE IF EXISTS `restaurant`.`supply_view`;
USE `restaurant`;
CREATE  OR REPLACE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `restaurant`.`supply_view` AS select `restaurant`.`supplys`.`supply_id` AS `supply_id`,`restaurant`.`supplys`.`supply_date` AS `supply_date`,`restaurant`.`supplys`.`supplier_id` AS `supplier_id`,`restaurant`.`suppliers`.`supplier_name` AS `supplier_name`,`restaurant`.`supplys`.`summ` AS `summ` from (`restaurant`.`supplys` join `restaurant`.`suppliers` on((`restaurant`.`supplys`.`supplier_id` = `restaurant`.`suppliers`.`supplier_id`)));
USE `restaurant`;

DELIMITER $$
USE `restaurant`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `restaurant`.`delete_dish`
BEFORE DELETE ON `restaurant`.`dishes`
FOR EACH ROW
BEGIN 
	DELETE FROM dish_consists
    WHERE dish_id = old.dish_id;
END$$

USE `restaurant`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `restaurant`.`del_all_info_about_supplier`
BEFORE DELETE ON `restaurant`.`suppliers`
FOR EACH ROW
BEGIN
	DELETE FROM suppliers_groc
    WHERE supplier_id = old.supplier_id;
    DELETE FROM supplys # дальше вызывает триггер на удаление из list_supplys
    WHERE supplier_id = old.supplier_id;
END$$

USE `restaurant`$$
CREATE
DEFINER=`root`@`localhost`
TRIGGER `restaurant`.`on_delete_supply`
BEFORE DELETE ON `restaurant`.`supplys`
FOR EACH ROW
BEGIN 
	DELETE FROM list_supplys
    WHERE supply_id = old.supply_id;
END$$


DELIMITER ;

SET SQL_MODE=@OLD_SQL_MODE;
SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS;

