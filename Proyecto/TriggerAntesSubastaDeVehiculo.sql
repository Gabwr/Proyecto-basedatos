 DELIMITER //
CREATE TRIGGER trigger_antes_de_subastar_vehiculo
BEFORE INSERT
ON SUBASTA_VEHICULO
FOR EACH ROW
BEGIN
	DECLARE fecha_init_subasta DATETIME;
    DECLARE fecha_end_subasta DATETIME;
    DECLARE fecha_hoy DATETIME;
    DECLARE estado_vehiculo VARCHAR(32);
    DECLARE ID_subasta INT; 
    DECLARE ID_auto INT; 
    /*Comprueba que la subasta id exista*/
    SELECT SUBASTA_ID  INTO ID_subasta FROM SUBASTA sb WHERE sb.SUBASTA_ID= new.SUBASTA_ID;
    IF ID_subasta = null THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede ingresar el vehiculo si no selecciona una subasta existente';
    END IF;
    
    /*Comprueba que el vehiculo id exista*/
    SELECT v.VEHICULO_ID INTO ID_auto FROM VEHICULO v WHERE v.VEHICULO_ID= new.VEHICULO_ID;
    
    IF ID_auto IS NULL THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede ingresar el vehiculo si no referencia a un vehiculo existente';
    END IF;
    
    
    /*Comprueba que no se inserte SUBASTA_VEHICULO_VENDIDO como nulo*/
    IF NEW.SUBASTA_VEHICULO_VENDIDO IS NULL THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El vehiculo ingresado en el campo SUBASTA_VEHICULO_VENDIDO no puede ser nulo';
    END IF;
    
    /*Comprueba que no se inserte SUBASTA_VEHICULO el mismo id de subasta y el mismo id de vehiculo*/
	IF EXISTS (SELECT 1 FROM SUBASTA_VEHICULO sv WHERE sv.SUBASTA_ID = NEW.SUBASTA_ID AND sv.VEHICULO_ID = NEW.VEHICULO_ID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Este vehiculo ya está registrado en esta subasta';
    END IF;
    
      /*Comprueba que este detro de una subasta aun activa*/
    SET fecha_hoy = CURRENT_TIMESTAMP;
	SELECT sb.SUBASTA_FECHA_INICIO INTO fecha_init_subasta 
    FROM SUBASTA sb WHERE sb.SUBASTA_ID= new.SUBASTA_ID ;
	
    SELECT sb.SUBASTA_FECHA_FIN INTO fecha_end_subasta 
    FROM SUBASTA sb WHERE sb.SUBASTA_ID= new.SUBASTA_ID ;
    
    
    /*Comprobar que no se ingrese un auto que esta en otra subasta activa*/
		IF EXISTS (SELECT 1 FROM SUBASTA_VEHICULO sv
				   JOIN SUBASTA s ON s.SUBASTA_ID = sv.SUBASTA_ID
				   WHERE sv.VEHICULO_ID = NEW.VEHICULO_ID
				   AND s.SUBASTA_VIGENTE = true 
				   AND sv.SUBASTA_ID != NEW.SUBASTA_ID) THEN
			SIGNAL SQLSTATE '45000'
			SET MESSAGE_TEXT = 'Este vehiculo ya está registrado en subasta aun vigente';
		END IF;

    
    IF fecha_hoy NOT BETWEEN fecha_init_subasta AND fecha_end_subasta THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede ingresar el vehiculo en una subasta que ya ha terminado';
    END IF;
    
    SELECT v.VEHICULO_ESTADO INTO  estado_vehiculo 
    FROM VEHICULO v WHERE v.VEHICULO_ID= new.VEHICULO_ID;
    
    IF estado_vehiculo != "disponible" THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No se puede ingresar el vehiculo si no esta disponible';
    END IF;
	/*Comprueba que no ingrese en la tabla subasta_autos como un auto ya vendido*/
    IF new.SUBASTA_VEHICULO_VENDIDO IS true then
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El vehiculo ingresado no puede ser vendido aun sin terminar la subasta';
    END IF;
    
END//

DELIMITER ;

DELIMITER //
CREATE TRIGGER trigger_despues_de_subastar_vehiculo
AFTER INSERT
ON SUBASTA_VEHICULO
FOR EACH ROW
BEGIN
	DECLARE usuario int;
    SELECT USUARIO_ID INTO usuario FROM VENDEDOR WHERE USUARIO_ID IN (SELECT USUARIO_ID FROM VEHICULO WHERE VEHICULO_ID = new.VEHICULO_ID);
    
    INSERT INTO AUDITORIA (VEN_USUARIO_ID, AUDITORIA_FECHA, AUDITORIA_DETALLE)
    VALUES (usuario, CURRENT_TIMESTAMP ,CONCAT("inscripción de un vehiculo en la subasta ",new.AUDITORIA_ID));
    
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER trigger_antes_de_actualizar_subastar_vehiculo
BEFORE UPDATE
ON SUBASTA_VEHICULO
FOR EACH ROW
BEGIN
/*Permite solo cambar el valor de auto vendido o no*/
    IF NEW.VEHICULO_ID <> OLD.VEHICULO_ID THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se permite modificar el VEHICULO_ID de una subasta';
    END IF;
    
    IF NEW.SUBASTA_ID <> OLD.SUBASTA_ID THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No se permite modificar SUBASTA_ID de una subasta';
    END IF;
    
	IF new.SUBASTA_VEHICULO_VENDIDO IS NULL THEN
    SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'El vehiculo ingresado no puede ser cambiado a tener ningun valor';
    END IF;
END//

DELIMITER ;
drop TRIGGER trigger_despues_de_actualizar_subastar_vehiculo;

DELIMITER //
CREATE TRIGGER trigger_despues_de_actualizar_subastar_vehiculo
AFTER UPDATE
ON SUBASTA_VEHICULO
FOR EACH ROW
BEGIN
	DECLARE marca VARCHAR(64);
    DECLARE modelo VARCHAR(64);
    DECLARE anio INT;
    DECLARE auditoria TEXT;

    /* Recuperar información del vehículo */
    SELECT VEHICULO_MARCA INTO marca FROM VEHICULO WHERE VEHICULO_ID = 1;
    SELECT VEHICULO_MODELO, VEHICULO_ANIO INTO modelo, anio
    FROM VEHICULO WHERE VEHICULO_ID = NEW.VEHICULO_ID;

    /* Verificar si el vehículo fue vendido */
       IF NEW.SUBASTA_VEHICULO_VENDIDO = 1 THEN
        SET auditoria = CONCAT('Venta de vehículo: '+ marca+ ' ',
            modelo, ' Año: ', anio, 
            ' en la subasta: ', NEW.SUBASTA_ID
        );
        INSERT INTO AUDITORIA (VEN_USUARIO_ID, AUDITORIA_FECHA, AUDITORIA_DETALLE)
        VALUES (0, CURRENT_TIMESTAMP, auditoria);
    END IF;
    
END//
DELIMITER ;


