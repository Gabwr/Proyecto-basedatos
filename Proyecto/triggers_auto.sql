DELIMITER $$
CREATE TRIGGER antes_insercion_vehiculo
BEFORE INSERT 
ON vehiculo
FOR EACH ROW
BEGIN 
	IF NOT NEW.VEHICULO_PLACA REGEXP  '^[A-Za-z0-9]+$' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre solo puede contener letras y números.';
    END IF;
    
    IF LENGTH(NEW.VEHICULO_PLACA) > 10 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El nombre no puede exceder los 10 caracteres.';
    END IF;
    
    
	IF YEAR(NEW.VEHICULO_ANIO) > YEAR(CURDATE()) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El año de nacimiento no puede ser mayor al año actual.';
    END IF;
    
    IF NEW.VEHICULO_PRECIO_BASE <= 2000.99 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El precio debe ser mayor a 2000.99.';
    END IF;
    
    IF NOT NEW.VEHICULO_COLOR REGEXP '^[A-Za-z]+$' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El nombre solo puede contener letras.';
    END IF; 
    IF NEW.VEHICULO_ESTADO IS NULL THEN
		SET NEW.VEHICULO_ESTADO = 'disponible';
    END IF;
     IF NEW.VEHICULO_ESTADO != 'disponible' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El estado solo puede ser "disponible".';
    END IF;
    
	IF NOT NEW.VEHICULO_KILOMETRAJE > 0 THEN
		SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El kilometraje debe de ser mayor a 0.';
    END IF;
    
END $$
DELIMITER ;