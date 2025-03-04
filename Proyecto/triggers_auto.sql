
DROP TRIGGER `antes_insercion_vehiculo`;
DROP TRIGGER `antes_actualizar_vehiculo`;
DROP TRIGGER `despues_actualizar_vehiculo`;
DROP TRIGGER `despues_insercion_vehiculo`;

ALTER TABLE `vehiculo`
MODIFY COLUMN `VEHICULO_PRECIO_BASE` DECIMAL(10, 2);

DELIMITER $$
CREATE TRIGGER `antes_insercion_vehiculo`
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
    
    IF NEW.VEHICULO_PRECIO_BASE < 2000.99 THEN
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


DELIMITER $$
CREATE TRIGGER `antes_actualizar_vehiculo` BEFORE UPDATE ON `vehiculo` FOR EACH ROW BEGIN
    -- Validar que el estado solo pueda ser "vendido", "disponible" o "retirado"
    IF NEW.VEHICULO_ESTADO NOT IN ('vendido', 'disponible', 'retirado') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El estado solo puede ser "vendido", "disponible" o "retirado".';
    END IF;
END
$$
DELIMITER ;

DELIMITER $$
CREATE TRIGGER `despues_actualizar_vehiculo` AFTER UPDATE ON `vehiculo` FOR EACH ROW BEGIN
	DECLARE vendido BOOLEAN;
    -- Verificar si el estado es "retirado" y el vehículo no está marcado como "vendido"
    IF NEW.VEHICULO_ESTADO = 'retirado' THEN
            UPDATE puja
            SET PUJA_ESTADO = FALSE
            WHERE VEHICULO_ID = NEW.VEHICULO_ID;
            
            
            
	INSERT INTO auditoria (COM_USUARIO_ID,VEN_USUARIO_ID, AUDITORIA_FECHA, AUDITORIA_DETALLE)
    VALUES (0,NEW.USUARIO_ID, NOW(), 'Retirado');
        
    END IF;
    
     IF NOT NEW.VEHICULO_ESTADO = 'vendido' THEN
		UPDATE subasta_vehiculo_vendido
        SET SUBASTAS_VEHICULO_VENDIDO= False
        WHERE VEHICULO_ID = NEW.VEHICULO_ID;
     
     
     END IF;
     
     

    
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `despues_insercion_vehiculo` AFTER INSERT ON `vehiculo` FOR EACH ROW BEGIN
    -- Insertar el registro en la tabla auditoria
    INSERT INTO auditoria (COM_USUARIO_ID,VEN_USUARIO_ID, AUDITORIA_FECHA, AUDITORIA_DETALLE)
    VALUES (NEW.USUARIO_ID,NEW.USUARIO_ID, NOW(), 'Inserción vehículo');
END
$$
DELIMITER ;

-- --------------------------------------------------------
