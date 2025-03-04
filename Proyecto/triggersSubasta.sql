
-- TRIGGER ANTES DE INSERTAR UNA SUBASTA
DELIMITER //

CREATE TRIGGER antes_insertar_subasta
BEFORE INSERT ON subasta
FOR EACH ROW
BEGIN
    -- Hace que la fecha de inicio sea obligatoriamente hoy forzando la inserción
    SET NEW.SUBASTA_FECHA_INICIO = CURDATE();
    
    -- Hace que la fecha final sea obligatoiamente 30 días después de la fecha inicio forzando la inserción
    SET NEW.FECHA_FIN = DATE_ADD(NEW.FECHA_INICIO, INTERVAL 30 DAY);
END//

DELIMITER ;

-- TRIGGER DESPUÉS DE INSERTAR UNA SUBASTA
DELIMITER //

CREATE TRIGGER despues_insertar_subasta
AFTER INSERT ON subasta
FOR EACH ROW
BEGIN
    -- Insertar en la tabla auditoria el registro de la apertura de la subasta
    INSERT INTO auditoria (COM_USUARIO_ID, VEN_USUARIO_ID, AUDITORIA_FECHA, AUDITORIA_DETALL)
    VALUES (NULL, NEW.USUARIO_ID, NOW(), CONCAT('Apertura de subasta ID ', NEW.SUBASTA_ID));
END//

DELIMITER ;

-- TRIGGER ANTES DE ACTUALIZAR SUBASTA
DELIMITER //

CREATE TRIGGER antes_actualizar_subasta
BEFORE UPDATE ON subasta
FOR EACH ROW
BEGIN
    -- Validar que la nueva fecha de fin solo pueda ser extendida
    IF NEW.SUBASTA_FECHA_FIN < OLD.SUBASTA_FECHA_FIN THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede reducir la fecha de fin de la subasta';
    END IF;

    -- Validar que la vigencia solo pueda cambiar si actualmente es TRUE
    IF OLD.SUBASTA_VIGENTE = FALSE AND NEW.SUBASTA_VIGENTE <> OLD.SUBASTA_VIGENTE THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede modificar la vigencia de una subasta no vigente';
    END IF;
END //

DELIMITER ;

-- TRIGGER DESPUÉS DE ACTUALIZAR SUBASTA
DELIMITER //

CREATE TRIGGER despues_actualizar_subasta
AFTER UPDATE ON subasta
FOR EACH ROW
BEGIN
    -- Insertar auditoría si se extiende la fecha de fin
    IF NEW.SUBASTA_FECHA_FIN > OLD.SUBASTA_FECHA_FIN THEN
        INSERT INTO auditoria (COM_USUARIO_ID, VEN_USUARIO_ID, AUDITORIA_FECHA, AUDITORIA_DETALLE)
        VALUES (0, 0, NOW(), 'Subasta extensión');
    END IF;

    -- Insertar auditoría si la vigencia cambió a FALSE
    IF OLD.SUBASTA_VIGENTE = TRUE AND NEW.SUBASTA_VIGENTE = FALSE THEN
        INSERT INTO auditoria (COM_USUARIO_ID, VEN_USUARIO_ID, AUDITORIA_FECHA, AUDITORIA_DETALLE)
        VALUES (0, 0, NOW(), 'Subasta vigencia acabada');
    END IF;
END //

DELIMITER ;




